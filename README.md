# Car Analysis

<u><h2>This Project is Ongoing.</h2></u>


# Overview

This project focuses on analyzing car data using Python, SQL, and Power BI to derive meaningful insights and create an interactive dashboard. The dataset contains over 500,000 records,and the analysis aims to derive insights from various attributes such as vehicle specifications, pricing trends, and availability.

# Technologies Used

<ul>
<li><b>Python</b>: Used for web scraping to fill missing values.</li>
<li><b>MySQL</b>: Used for data cleaning, standardization, and transformation.</li>
<li><b>Power BI</b>: Used to create an interactive dashboard for data visualization.</li>
</ul>

# Project Workflow

The project consists of the following main steps

## 1. Data Cleaning (MySQL)
The raw dataset was first processed in MySQL to:
<ol>
<li><b>Standardize Data</b>: Ensuring consistent formatting of text and numerical values.</li>
<li><b>Correct Data Types</b>: Converting columns to appropriate formats (e.g., dates, integers, floats, etc.).</li>
<li><b>Handle Missing Values</b>: Identifying gaps in data that needed to be addressed.</li>
<li><b>Work with Date Columns</b>: Extracting useful time-based insights.</li>
<li><b>Create New Columns</b>: Derived meaningful attributes for analysis.</li>
<li><b>Fill NULL Values</b>: Identified missing data that required further processing.</li>
</ol>

## 2. Handling Missing Values (Python & Web Scraping)
Approximately 100,000 values were missing in the dataset. These were filled using a Python-based web scraping approach:
<ol>
<li><b>Web Scraping</b>: Used Python to scrape car details based on VIN code and year from automotive databases.</li>
<li><b>Data Integration</b>: Fetched missing information and merged it with the cleaned MySQL data.</li>
</ol>

## 3. Data Visualization (Power BI)

Importing Clean Data: Loaded the processed data into Power BI.
<ol>
<li><b>Creating Interactive Dashboards</b>: Built visuals to represent car trends, pricing patterns, and other insights.</li>
<li><b>KPIs and Filters</b>: Designed interactive elements for deeper analysis.</li>
</ol>

## 4.Key Features
<ul>
<li><b>Automated Data Cleaning</b>: Used SQL to standardize and preprocess the data.</li>
<li><b>Dynamic Data Completion</b>: Python-based web scraping for missing car details.</li>
<li><b>Interactive Dashboard</b>: Power BI dashboard to visualize key metrics and trends.</li>
<li><b>End-to-End Data Processing</b>: Ensuring data quality from raw input to final visualization.</li>
</ul>




