import configparser
from sqlalchemy import create_engine
from urllib.parse import quote_plus

class Config:
    def __init__(self, config_path="C:\\Users\\muiva\\OneDrive\\Desktop\\Data Analysis\\Projects\\6.Car Sale Analysis\\WebScrape\\links.txt"):
        self.config_path = config_path
        self.db_engine = self.load_db_config()
        self.links = self.load_links()

    def load_db_config(self):
        try:
            with open(self.config_path, "r") as file:
                db_config_path = file.readline().strip()

            config = configparser.ConfigParser()
            config.read(db_config_path)

            db_host = config.get("DEFAULT", "host")
            db_user = config.get("DEFAULT", "user")
            db_password = quote_plus(config.get("DEFAULT", "password").strip())
            db_name = config.get("DEFAULT", "database")

            return create_engine(f"mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}")
        except Exception as e:
            print(f"Error loading database configuration: {e}")
            raise

    def load_links(self):
        try:
            with open(self.config_path, "r") as file:
                lines = [line.strip() for line in file.readlines()]
                return lines[1:] 
        except Exception as e:
            print(f"Error reading {self.config_path}: {e}")
            raise

if __name__ == "__main__":
    config = Config()
    print("Database connection established.")
    print("Links retrieved:", config.links)
