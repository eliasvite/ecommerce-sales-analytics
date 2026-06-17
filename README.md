# End-to-End E-Commerce Data Pipeline & Analytics Warehouse

This repository contains a production-grade, defensive Data Engineering pipeline designed to extract, clean, transform, and load transactional e-commerce sales records into a Relational Data Warehouse utilizing a relational **Star Schema** architecture. 

The pipeline is engineered using **Python, Pandas, and SQLAlchemy** to process large-scale dirty source data, implement structural data quality overrides, and stream high-velocity bulk inserts into **Microsoft SQL Server**.

---

## 1. Project Architecture & Data Flow

The architecture follows a classic **ELT/ETL operational pattern**, moving raw analytical transactional records into a clean, relational Star Schema optimization layer, making it instantly consumable by Business Intelligence platform Power BI or downstream data consumers.

[ Raw E-Commerce CSV/Excel Dataset ]
                   │
                   ▼
   [ Python / Pandas Processing Layer ]
     ├── Data Normalization & Cleaning
     ├── Missing Value Imputation ('Unknown' Failsafes)
     └── Ghost-Row / Null Record Removal
                   │
                   ▼
   [ SQLAlchemy / pyodbc Database Engine ]
                   │
                   ▼
     ┌─────────────┴─────────────┐
     ▼                           ▼
     [ Dimensional Tables ]      [ Fact Table (Streaming) ]
     ├── Dim_Products             └── Fact_Sales (Bulk Insert)
     ├── Dim_Geography
     └── Dim_Status

     ---

## 2. Data Warehouse Star Schema Design

To optimize query execution, diminish storage redundancy, and provide clear analytical checkpoints, the database schema was normalized from a flat file into a centralized **Star Schema**:

┌──────────────────────────────────┐
│           Dim_Products           │
├──────────────────────────────────┤
│ PK │ Product_ID (INT, IDENTITY)  │◀┐
│    │ SKU (VARCHAR)               │ │
│    │ ASIN (VARCHAR)              │ │
│    │ Style (VARCHAR)             │ │
│    │ Category (VARCHAR)          │ │
│    │ Size (VARCHAR)              │ │
└──────────────────────────────────┘ │
                                     │
┌──────────────────────────────────┐ │ ┌──────────────────────────────────┐
│          Dim_Geography           │ │ │            Fact_Sales            │
├──────────────────────────────────┤ │ ├──────────────────────────────────┤
│ PK │ Location_ID (INT, IDENTITY) │◀┼─┼─┤ FK │ Order_ID (VARCHAR, NOT NULL)│
│    │ Ship_City (VARCHAR)         │ │ │      │ Date (DATETIME)           │
│    │ Ship_State (VARCHAR)        │ │ │      │ Qty (FLOAT)               │
│    │ Amount (FLOAT)              │ │ │      │ Amount (FLOAT)            │
└──────────────────────────────────┘ │ │ FK │ Status_ID (INT)             │
                                     │ │ FK │ Product_ID (INT)            │
┌──────────────────────────────────┐ │ │ FK │ Location_ID (INT)           │
│            Dim_Status            │ │ └──────────────────────────────────┘
├──────────────────────────────────┤ │
│ PK │ Status_ID (INT, IDENTITY)   │─┘
│    │ Status (VARCHAR)            │
│    │ Courier_Status (VARCHAR)    │
│    │ Fulfilment (VARCHAR)        │
│    │ Market_Channel (VARCHAR)    │
└──────────────────────────────────┘

---

## 3. Production Data Challenges & Defensive Solutions

During development, the pipeline encountered several critical data quality anomalies common in real-world transactional systems. The engine was refactored with **defensive programming techniques** to guarantee maximum uptime and integrity:

### Challenge 1: Referential Integrity & Orphan Records (`KeyError` / Missing Demographics)
* **Problem:** Source transactional records frequently referenced missing or unpopulated product styles, status variations, or geographical locations, causing foreign key constraints to fail during structural loads.
* **Solution:** Injected standardized fallback records labeled `'Unknown'` inside the dimension loaders. Implemented a dynamic database scanner to fetch auto-generated surrogate identity keys at runtime, safely re-routing orphaned records into classified `Unknown` buckets without stopping execution.

### Challenge 2: Combinatorial Matrix Explosions on Data Merges
* **Problem:** Cross-relational left joins inside Pandas performed matrix-like multipliers whenever blank or invalid dimensional criteria combined with generic `'Unknown'` markers. This resulted in phantom records containing populated foreign keys but empty financial matrices.
* **Solution:** Enforced strict string data normalization (`.str.strip()`, `.fillna('Unknown')`) across both local processing frames and raw database extractions to align joining keys accurately before merging.

### Challenge 3: SQL Server Null Value Constraints (`IntegrityError 23000`)
* **Problem:** Pandas read floating trailing blanks from the source files as `NaN`. When attempting bulk insertions, SQL Server threw a `Cannot insert the value NULL into column 'Order_ID'` constraint violation, terminating database operations.
* **Solution:** Developed an aggressive transactional filtration layer directly prior to streaming:
  ```python
  df_fact = df_fact.dropna(subset=['Order_ID'])
  df_fact = df_fact[df_fact['Order_ID'].astype(str).str.lower() != 'nan']

  