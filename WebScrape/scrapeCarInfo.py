import asyncio
from playwright.async_api import async_playwright
import pandas as pd
from config import Config
from sqlalchemy.exc import SQLAlchemyError

class CarInfoScraper:
    def __init__(self):
        self.config = Config()
        self.engine = self.config.db_engine
        self.url = self.config.links[0]
        self.batch_size = 20 

    def fetch_vins(self):
        """Fetch VINs that are not already in carInfo."""
        query = """
        SELECT vin, year 
        FROM forVin 
        WHERE (vin NOT IN (SELECT vin FROM carinfo)) AND 
        (make IS NULL OR body IS NULL OR model IS NULL OR transmission IS NULL)
        LIMIT 500;  -- Limit to avoid overloading
        """
        try:
            return pd.read_sql(query, self.engine)
        except SQLAlchemyError as e:
            print(f"Error fetching VINs: {e}")
            return None

    async def get_info(self, page, vin, year):
        """Scrape vehicle information."""
        info = {"vin": vin, "year": year, "body": "Not found", "make": "Not found",
                "model": "Not found", "transmission": "Not found"}

        try:
            await page.fill("#VIN", vin.strip())
            await page.fill("#ModelYear", str(year))
            await page.click("#btnSubmit")
            await page.wait_for_selector(".col-md-6", timeout=3000) 

            details_div = page.locator(".col-md-6")
            decoded_make = details_div.locator("#decodedMake")
            decoded_model = details_div.locator("#decodedModel")

            if await decoded_make.count() > 0:
                info["make"] = await decoded_make.inner_text()
            if await decoded_model.count() > 0:
                info["model"] = await decoded_model.inner_text()

            p_elements = await details_div.locator("p").all_inner_texts()
            for text in p_elements:
                if "Body Class:" in text:
                    info["body"] = text.replace("Body Class:", "").strip()

            panel_bodies = await page.locator(".panel-body").nth(1).inner_text()
            transmission = "Not found"

            for text in panel_bodies.split('\n'):
                if "Transmission Style:" in text:
                    transmission = text.split(":", 1)[-1].strip()
                    break  

            if "Automatic" in transmission:
                info["transmission"] = "Automatic"
            elif "Manual" in transmission:
                info["transmission"] = "Manual"

        except Exception as e:
            print(f"Error extracting vehicle info for VIN {vin}: {e}")
        
        return info

    async def process_vins(self, vin_list, year_list):
        results = []

        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            tasks = []

            for vin, year in zip(vin_list, year_list):
                page = await browser.new_page()
                await page.goto(self.url)
                tasks.append(self.get_info(page, vin, year))

                if len(tasks) >= self.batch_size:
                    batch_results = await asyncio.gather(*tasks)  
                    results.extend(batch_results)
                    self.store_data(batch_results) 
                    print(f"Stored batch of {self.batch_size} records")
                    tasks = []  

            if tasks:
                batch_results = await asyncio.gather(*tasks)
                results.extend(batch_results)
                self.store_data(batch_results)

            await browser.close()
        return results

    def store_data(self, data):
        try:
            df = pd.DataFrame(data).drop_duplicates(subset=["vin"])
            df.to_sql("carinfo", self.engine, if_exists="append", index=False, method="multi")
            print(f"Successfully stored {len(df)} records in carInfo.")
        except SQLAlchemyError as e:
            print(f"Error inserting vehicle data: {e}")

    async def run(self):
        df = self.fetch_vins()
        if df is not None and not df.empty:
            vin_list, year_list = df["vin"].tolist(), df["year"].tolist()
            await self.process_vins(vin_list, year_list)
        else:
            print("No data found in forVin table.")

if __name__ == "__main__":
    scraper = CarInfoScraper()
    asyncio.run(scraper.run())
