# Geospatial Data Management and Analytics 🚖🌍

**Authors:** Michalis Kovaios & Vasileios Karampelas  
**Emails:** [mixalis.koveos@gmail.com](mailto:mixalis.koveos@gmail.com) | [vkarampelas@outlook.com](mailto:vkarampelas@outlook.com)  
**University:** University of Piraeus  

---

## 📜 Introduction

This project analyzes GPS data from yellow cabs in San Francisco, featuring over 11 million records. The primary goals are:  
- **Data extraction and cleaning**  
- **Database creation**  
- **Advanced geospatial analytics**  
- **Clustering to detect behavioral patterns**

The project highlights the use of Python and SQL to process and extract meaningful insights from large geospatial datasets.

---

## 📂 Repository Structure

📁 data/ # Contains raw and processed datasets 

📁 code/ # Python scripts and SQL queries for tasks 

📁 results/ # Screenshots and outputs from the analysis 

📁 docs/ # Documentation, including the detailed report

---

## 🔍 Key Features

### ✅ Data Preparation
- Extracted and combined TXT files into a consolidated CSV using Python.
- Created spatially-aware tables in PostgreSQL/PostGIS for efficient geospatial querying.

### ✅ Data Cleaning and Optimization
- Removed outliers and near-duplicate records using SQL.
- Calculated taxi speeds and flagged unrealistic data (e.g., speeds > 120 km/h).

### ✅ Geospatial Queries
- Identified close encounters between moving vehicles using KD-Trees.
- Mapped speed violations using spatial joins and buffered geometry.

### ✅ Clustering for Behavioral Patterns
- Applied K-Means clustering to detect activity patterns in vehicle locations.
- Visualized results using GeoPandas and OpenStreetMap basemaps.

---

## 🛠️ Tech Stack

- **Languages**: Python, SQL  
- **Libraries**: GeoPandas, scikit-learn, SciPy, matplotlib, contextily  
- **Database**: PostgreSQL with PostGIS extension  
- **Tools**: QGIS  

---



