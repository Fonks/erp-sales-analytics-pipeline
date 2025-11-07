# 🚀 Projektplan: Shoebadoo ERP Data Engineering & Analytics Pipeline

---

## 📋 PHASE 1: Projekt-Setup & Infrastruktur
**🎯 Ziel:** Professionelle Grundstruktur schaffen

### Step 1.1: GitHub Repository & Ordnerstruktur
- Repository anlegen mit README  
- Komplette Ordnerstruktur erstellen  
- `.gitignore` für Python/Data-Projekte  
- Erste `README.md` mit Projekt-Übersicht  

### Step 1.2: Docker Setup
- `Dockerfile` für PySpark-Umgebung  
- `docker-compose.yml` (PySpark + Streamlit)  
- Requirements-Management (`requirements.txt`)  

---

## 📊 PHASE 2: Data Exploration & Quality
**🎯 Ziel:** Daten verstehen und qualitätssichern

### Step 2.1: Explorative Datenanalyse (EDA)
- Parquet-Dateien laden und inspizieren  
- Datenqualitätsprobleme identifizieren  
- Statistiken & erste Visualisierungen  
- EDA-Notebook dokumentieren  

### Step 2.2: Data Cleaning Pipeline
- Duplikate entfernen  
- Missing Values behandeln  
- NLP: Kategorie/Marke aus Freitext extrahieren  
- Datentyp-Konvertierung  
- Bereinigte Parquets speichern  

### Step 2.3: Data Quality Framework
- 5–8 Quality Checks implementieren (z. B. *Great Expectations*)  
- Data Contract Schema (JSON) erstellen  
- Automatische Validierung einbauen  
- Quality Report generieren  

---

## 🏗️ PHASE 3: Data Warehouse Modellierung <- MOMENTAN HIER
**🎯 Ziel:** Star Schema für Analytics

### Step 3.1: Dimensional Modeling
- Star Schema Design (Kimball)  
- ERD-Diagramm erstellen  
- Dimensionstabellen definieren  
- Faktentabelle(n) designen  

### Step 3.2: ETL Pipeline (PySpark)
- Delta Lake Setup  
- Inkrementelle Load-Logik  
- Dimension & Fact Tables erstellen  
- Pipeline orchestrieren  

---

## 📈 PHASE 4: Analytics & Visualization
**🎯 Ziel:** Interaktives Dashboard

### Step 4.1: Streamlit Dashboard
- Multi-Page App Struktur  
- KPI-Karten (Umsatz, Retouren, etc.)  
- Interaktive Plotly-Charts  
- Filter & Date-Range Selektor  

### Step 4.2: Analytics Features
- Umsatz-Analyse (Kanal/Produkt/Zeit)  
- Retourenquote-Monitoring  
- Customer Segmentation  
- Top-Produkte Rankings  

---

## 🎨 PHASE 5: Deployment & Dokumentation
**🎯 Ziel:** Production-Ready Portfolio Piece

### Step 5.1: CI/CD & Testing
- GitHub Actions (optional)  
- Unit Tests für kritische Funktionen  
- Docker Deployment testen  

### Step 5.2: Finale Dokumentation
- Ausführliche `README.md`  
- Architecture Documentation  
- Setup-Anleitung  
- Screenshots/Demo-Video  

---
