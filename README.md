# Car-Sale'

<u><h2>This Project is Ongoing.</h2></u>


# Overview

This project focuses on analyzing car data using Python, SQL, and Power BI to derive meaningful insights and create an interactive dashboard. The dataset initially contained missing values, which were handled through web scraping based on VIN codes and year information. The cleaned and processed data was then used for visualization in Power BI.

# Technologies Used

<ul>
<li>Python: Used for web scraping to fill missing values.</li>
<li>MySQL: Used for data cleaning, standardization, and transformation.</li>
<li>Power BI: Used to create an interactive dashboard for data visualization.</li>
</ul>

# Project Workflow

The project consists of the following main steps

## 1. Data Cleaning (MySQL)
The raw dataset was first processed in MySQL to:
<ol>
<li>Standardize Data: Ensuring consistent formatting of text and numerical values.</li>
<li>Correct Data Types: Converting columns to appropriate formats (e.g., dates, integers, floats, etc.).</li>
<li>Handle Missing Values: Identifying gaps in data that needed to be addressed.</li>
<li>Work with Date Columns: Extracting useful time-based insights.</li>
<li>Create New Columns: Derived meaningful attributes for analysis.</li>
<li>Fill NULL Values: Identified missing data that required further processing.</li>
</ol>

## 2. Handling Missing Values (Python & Web Scraping)

To fill missing values in the dataset:
<ol>
<li>Web Scraping: Used Python to scrape car details based on VIN code and year from automotive databases.</li>
<li>Data Integration: Fetched missing information and merged it with the cleaned MySQL data.</li>
</ol>

## 3. Data Visualization (Power BI)

Importing Clean Data: Loaded the processed data into Power BI.
<ol>
<li>Creating Interactive Dashboards: Built visuals to represent car trends, pricing patterns, and other insights.</li>
<li>KPIs and Filters: Designed interactive elements for deeper analysis.</li>
</ol>

## 4.Key Features
<ul>
<li>Automated Data Cleaning: Used SQL to standardize and preprocess the data.</li>
<li>Dynamic Data Completion: Python-based web scraping for missing car details.</li>
<li>Interactive Dashboard: Power BI dashboard to visualize key metrics and trends.</li>
<li>End-to-End Data Processing: Ensuring data quality from raw input to final visualization.</li>
</ul>




