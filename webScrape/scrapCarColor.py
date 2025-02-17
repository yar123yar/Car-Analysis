import asyncio
import pandas as pd
from sqlalchemy.exc import SQLAlchemyError
from playwright.async_api import async_playwright
from config import Config

class CarColorScraper:
    def __init__(self):
        self.config = Config()
        self.engine = self.config.db_engine
        self.url = self.config.links[1]  
        self.batch_size = 50  
        self.concurrent_requests = 10  

    def fetch_vins(self):
        """Fetch unprocessed VINs that need color information."""
        query = """
        SELECT vin 
        FROM forVin 
        WHERE (vin NOT IN (SELECT vin FROM carcolor)) AND (color IS NULL OR interior IS NULL)
        LIMIT 500;  -- Process in chunks
        """
        try:
            return pd.read_sql(query, self.engine)
        except SQLAlchemyError as e:
            print(f"Error fetching VINs: {e}")
            return None

    async def get_color(self, page, vin):
        colors = {"vin": vin, "interior": "Not found", "color": "Not found"}
        try:
            await page.fill("#VIN", "")
            if len(vin) == 17:
                await page.type("#VIN", vin.strip())

            await page.click(".MuiButtonBase-root.MuiButton-root")
            await page.wait_for_selector(".bh-m.spacing-s", timeout=3000)

            color_elements = await page.locator(".bh-m.spacing-s").all_text_contents()

            if color_elements:
                colors["color"] = color_elements[0]
                colors["interior"] = color_elements[1] if len(color_elements) > 1 else "Not found"

        except Exception as e:
            print(f"Error extracting color data for VIN {vin}: {e}")

        return colors

    async def process_vins(self, vin_list):
        results = []
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            context = await browser.new_context()
            tasks = []
            
            for i, vin in enumerate(vin_list):
                if len(tasks) >= self.concurrent_requests:
                    batch_results = await asyncio.gather(*tasks)
                    results.extend(batch_results)
                    self.store_data(batch_results)
                    tasks = []  # Reset task list

                page = await context.new_page()
                await page.goto(self.url)
                tasks.append(self.get_color(page, vin))

            if tasks:
                batch_results = await asyncio.gather(*tasks)
                results.extend(batch_results)
                self.store_data(batch_results)

            await browser.close()
        return results

    def store_data(self, data):
        try:
            df = pd.DataFrame(data)
            if not df.empty:
                with self.engine.begin() as connection:
                    df.to_sql("carcolor", connection, if_exists="append", index=False)
                print(f"Stored {len(df)} records in carColor.")
        except SQLAlchemyError as e:
            print(f"Database insert error: {e}")

    async def run(self):
        while True:
            df = self.fetch_vins()
            if df is not None and not df.empty:
                vin_list = df["vin"].tolist()
                await self.process_vins(vin_list)
            else:
                print("All VINs processed. No new VINs found.")
                break 

if __name__ == "__main__":
    asyncio.run(CarColorScraper().run())

