# World Agricultural Production Analysis & Crop Yield Prediction

## Overview
End-to-end analytics and data science project analyzing global agricultural production and predicting crop yields using statistical modeling.

Designed and built a complete pipeline integrating **SQL, R, and Power BI** to transform raw multi-source data into **actionable insights and predictive models**.

The project combines:
- Data engineering (data integration & cleaning)
- Analytics (SQL-based exploration)
- Data science (regression modeling)
- Business intelligence (interactive dashboards)

---

## Business Problem
Agricultural production is influenced by multiple complex factors such as:

- Climate (temperature, rainfall)
- Fertilization (N, P, K)
- Irrigation and mechanization
- Pest management

However, decision-makers often lack:
- Integrated datasets across sources  
- Clear understanding of key production drivers  
- Predictive tools to estimate crop yields  

This limits the ability to optimize production and plan effectively.

---

## Solution
An end-to-end analytics solution was developed to:

- Integrate global agricultural datasets into a structured SQL database  
- Clean and standardize multi-source data  
- Perform exploratory and analytical queries  
- Build predictive models for crop yields  
- Deliver insights through interactive Power BI dashboards  

The system enables both **descriptive analytics** and **predictive decision-making**.

---

## Architecture

### Data Flow
Raw Data (Multiple Sources)  
→ Data Cleaning (SQL, Excel, R)  
→ Structured Database (PostgreSQL)  
→ Analysis (SQL)  
→ Modeling (R)  
→ Visualization (Power BI)

---

## Data Sources

The project integrates multiple global datasets at country level:

- Agricultural production (crops)
- Temperature (avg, min, max)
- Rainfall
- Fertilizer usage (N, P, K)
- Pesticide usage
- Irrigation
- Tractor density

Sources include FAO, World Bank, Kaggle, and research datasets.

---

## Data Engineering

- Data cleaning and standardization across sources  
- Country name normalization for joins  
- Removal of aggregated categories to avoid duplication  
- Transformation of raw datasets into structured tables  

SQL was used to build a clean and scalable analytical dataset.

---

## Data Analysis (SQL)

Key analyses performed:

- Global production growth trends  
- Yield vs harvested area contribution  
- Top crops by production  
- Country-level production distribution  
- Time-series analysis (40+ years)  

### Key Insight
Global agricultural production growth is primarily driven by **yield improvements rather than expansion of cultivated area** :contentReference[oaicite:2]{index=2}  

---

## Predictive Modeling (R)

Multiple linear regression models were built to predict crop yields:

- All-crop average yield  
- Maize yield  
- Wheat yield  
- Potato yield  

### Approach

- Stepwise regression for feature selection  
- Multicollinearity control (VIF)  
- Residual diagnostics:
  - Normality (Shapiro-Wilk)
  - Independence (Durbin-Watson)
  - Homoscedasticity (Breusch-Pagan)
- Feature transformations:
  - Log
  - Square root
  - Polynomial terms
  - Box-Cox

(Full modeling workflow implemented in R script :contentReference[oaicite:3]{index=3})

---

## Model Performance

- All-crop model → R² ≈ 0.76  
- Maize model → R² ≈ 0.85  
- Wheat model → R² ≈ 0.76  
- Potato model → R² ≈ 0.84  

All models are statistically significant (p < 0.0001) and validated through residual analysis.

---

## Key Drivers of Yield

The models identify key variables influencing crop yield:

- Nitrogen fertilizer (strongest driver globally)
- Pesticide usage
- Temperature (climate impact)
- Fertilized area and nutrient balance
- Mechanization (tractor density)

These insights directly support **agricultural optimization strategies**.

---

## Dashboard (Power BI)

Two dashboards were developed:

- **Storytelling Dashboard (2023)** → communicates key insights  
- **Interactive Dashboard (2024)** → user-driven analysis  

Features:
- Global production overview  
- Country-level analysis  
- Crop comparison  
- Trend visualization  
- KPI tracking (production, yield, area)

---

## Business Value

This project enables:

- Data-driven agricultural decision-making  
- Identification of high-impact yield drivers  
- Better resource allocation (fertilizers, irrigation, etc.)  
- Strategic planning for production growth  
- Insights for agribusiness, investors, and policymakers  

---

## Tech Stack

- SQL (PostgreSQL)
- R (Statistical Modeling)
- Power BI (DAX, dashboards)
- Excel (data preprocessing)

---

## Key Techniques

- Data integration across heterogeneous sources  
- SQL-based analytical modeling  
- Multiple linear regression  
- Feature engineering & transformations  
- Model validation and diagnostics  
- Data storytelling and dashboarding  

---

## Real-World Applications

- Agricultural production optimization  
- Yield forecasting for farming operations  
- Agri-investment analysis  
- Government and policy planning  
- Climate impact assessment on crops  

---

## 🔗 Links

- 🚀 Project Repository  
- 🌐 https://federicogarland.github.io/FedericoGarlandWebsite/  
- 💼 https://www.linkedin.com/in/federico-garland/