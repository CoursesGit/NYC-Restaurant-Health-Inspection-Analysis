# NYC Restaurant Health Inspection Analysis

## Project Overview

This project analyzes NYC restaurant health inspection data using SQL and Power BI.

The goal is to clean the raw inspection data, explore inspection and violation patterns, and build a dashboard to show restaurant risk trends by borough, neighborhood, cuisine type, and time.

This project includes:

- Data cleaning in SQL
- Exploratory analysis in SQL
- Power BI dashboard
- Basic recommendations based on the analysis

---

## Dataset

The dataset comes from NYC Open Data:

[NYC Open Data - DOHMH New York City Restaurant Inspection Results](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j)

The original raw dataset is not included in this repository because the file size is too large for GitHub upload.

More dataset information is included here:

```text
data/data_source.txt
```

The data dictionary is included in the `data/` folder.

This analysis uses inspection records from 2015 to 2025 after removing invalid placeholder dates such as `01/01/1900`.

One important point is that the original dataset is at the violation-record level. This means one restaurant inspection can have multiple violation records.

---

## Business Questions

This project answers the following questions:

### 1. Data Preparation

- Handle missing values
- Standardize cuisine names
- Clean inspection and grade date fields

### 2. Overall Insights

- Count total inspections by borough
- Check grade distribution across NYC
- Find the most common inspection types

### 3. Violation Analysis

- Find the top 10 most frequent violations
- Compare critical and non-critical violations
- Identify boroughs or neighborhoods with higher critical violation rates

### 4. Cuisine Analysis

- Compare grades by cuisine type
- Find cuisines with the lowest average scores
- Identify cuisines with the highest proportion of critical violations

### 5. Geographic and Time Trends

- Visualize grade records across boroughs
- Check whether scores or critical violation rates changed over time
- Highlight neighborhoods with higher critical violation rates

### 6. Recommendations

- Suggest where targeted inspections or public health campaigns should focus
- Identify cuisines and areas where food safety training may help
- Highlight possible policy focus areas

---

## Tools Used

- MySQL
- MySQL Workbench
- Power BI
- Excel
- GitHub

---

## Project Structure

```text
NYC-Restaurant-Health-Inspection-Analysis/
│
├── data/
│   ├── data_source.txt
│   └── RestaurantInspectionDataDictionary.xlsx
│
├── images/
│   └── dashboard_screenshot.png
│
├── powerbi/
│   └── NYC_Restaurant_Inspection_Dashboard.pbix
│
├── sql/
│   ├── 01_nyc_restaurant_data_cleaning.sql
│   └── 02_nyc_restaurant_exploratory_analysis.sql
│
└── README.md
```

---

## Data Cleaning

The cleaning process was kept simple and focused on the fields needed for analysis.

Main cleaning steps:

- Converted blank values into `NULL`
- Filled missing borough, neighborhood, cuisine, grade, and critical flag values
- Standardized selected cuisine names
- Replaced invalid placeholder dates with `NULL`
- Created cleaned date fields for analysis

Cleaning script:

```text
sql/01_nyc_restaurant_data_cleaning.sql
```

---

## SQL Analysis

The SQL analysis covers three main areas.

### Overall Insights

- Inspections by borough
- Grade distribution
- Most common inspection types

### Violation Analysis

- Top 10 most frequent violations
- Critical vs non-critical violations
- Boroughs or neighborhoods with higher critical violation rates

### Cuisine Analysis

- Grades by cuisine type
- Cuisines with the lowest average scores
- Cuisines with higher critical violation rates

Analysis script:

```text
sql/02_nyc_restaurant_exploratory_analysis.sql
```

---

## Power BI Dashboard

The Power BI dashboard focuses on risk, trends, and recommendations.

The dashboard includes:

- Critical violation hotspot map
- Grade records by borough
- Total violation records
- Critical violations
- Critical violation rate
- Average score trend by year
- Critical violation rate trend by year
- Top cuisines by critical violation rate
- Borough filter

![Dashboard Screenshot](images/dashboard_screenshot.png)

---

## Key Findings

- Critical violations make up a large share of valid violation records.
- Some neighborhoods have higher critical violation rates than others.
- Certain cuisine categories show higher critical violation rates.
- Violation-record average scores increased in later years, which may suggest worse inspection results over time.
- Critical violation rates changed year by year and did not show a clear stable improvement pattern.

In NYC restaurant inspections, a higher score means a worse result because scores represent violation points.

---

## Recommendations

Based on the analysis, I would recommend:

1. Focus inspection resources on neighborhoods with higher critical violation rates.
2. Provide more food safety training for cuisine categories with higher critical violation rates.
3. Monitor score and critical violation trends over time.
4. Use borough and neighborhood patterns to support more targeted public health campaigns.
5. Review high-risk areas more closely if they continue to show repeated violation problems.

---

## Notes

This project is meant to show basic junior data analyst skills, including SQL cleaning, exploratory analysis, Power BI dashboard building, and turning analysis results into simple recommendations.

Some dashboard visuals use violation-record level data, so the labels are written carefully to avoid treating every row as a separate inspection.
