# ERP Sales Analytics Platform

## 🎯 Projekt-Übersicht
End-to-End Data Engineering Pipeline für E-Commerce Sales Analytics
mit Data Quality Checks, Star Schema Modellierung und Interactive Dashboard.

## 🛠️ Tech Stack
- **Data Processing:** PySpark, Pandas, Dask
- **Storage:** Delta Lake, Parquet
- **Quality:** Data Contracts (JSON Schema), Great Expectations
- **Visualization:** Streamlit, Plotly
- **Infrastructure:** Docker, Docker Compose

## 📊 Features
✅ Inkrementelle ETL Pipeline 
    - "Frische" Daten werden dem Data Lakehouse geordnet hinzugefügt
✅ Automated Data Quality Checks and Data-Cleaning
    - Null-Werte, Duplikate und ungültige Werte(negative Preise z.B)
    - sind alle Preisbeträge numerisch? -> Datentyp-Prüfunng
    - Automatisches einfügen von fehlenden Strings durch Freitext
✅ Star Schema (Kimball Methodology)
✅ Real-time Analytics Dashboard
✅ Data Anonymization
✅ Data Contract Validation

## 🏗️ Architektur
[Star Schema Diagramm hier]

## 🚀 Quick Start
```bash
docker-compose up
streamlit run dashboards/streamlit_app.py
```

## 📈 Use Cases
- Revenue Analysis by Channel/Product/Time
- Return Rate Monitoring
- Customer Segmentation
- Top Product Rankings
