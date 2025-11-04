# ERP Sales Analytics Platform

## 🎯 Projektübersicht

Dieses Projekt demonstriert einen vollständigen **Data-Engineering-Workflow** für ein E-Commerce-Unternehmen (Shoebadoo) und umfasst:

1. **Datenaufnahme** → Roh-Parquet-Dateien (Verkäufe, Kunden, Produkte, Rücksendungen)
2. **Datenqualität und -bereinigung** → Automatisierte Validierung, Deduplizierung und NLP-basierte Anreicherung
3. **Datenmodellierung** → Sternschema (Kimball-Methodik) mit Delta Lake
4. **Analyse und Visualisierung** → Interaktives Streamlit-Dashboard mit geschäftlichen KPIs

**Problemstellung:**  
Umwandlung unübersichtlicher, realer E-Commerce-Daten in eine zuverlässige Analyseplattform, die datengestützte Entscheidungen über Vertriebskanäle, Produktleistung und Kundenverhalten ermöglicht.

## 📋 Inhaltsverzeichnis

- [Projektübersicht](#-project-overview)
- [Wichtigste Funktionen](#-key-features)
- [Tech Stack](#-tech-stack)
- [Architektur](#-architecture)
- [Anwendungsfälle in der Wirtschaft](#-business-use-cases)
- [Projektstruktur](#-project-structure)
- [Erste Schritte](#-getting-started)
- [Datenpipeline](#-data-pipeline)
- [Dashboard-Vorschau](#-dashboard-preview)
- [Wichtigste Erkenntnisse](#-key-learnings)
- [Zukünftige Verbesserungen](#-future-enhancements)


## 🛠️ Tech Stack
- **Data Processing:** PySpark, Pandas, Dask
- **Storage:** Delta Lake, Parquet
- **Quality:** Data Contracts (JSON Schema), Great Expectations
- **Visualization:** Streamlit, Plotly
- **Infrastructure:** Docker, Docker Compose

## 🛠️ Technical Highlights

### Warum PySpark?

Dieses Projekt verwendet **Apache Spark (PySpark)** für die Datenverarbeitung, um Folgendes zu demonstrieren:

- ✅ **Skalierbarkeit:** Architektur, die für wachsende Datenmengen ausgelegt ist
- ✅ **Verteiltes Rechnen:** Parallele Verarbeitungsmöglichkeiten für große Datensätze
- ✅ **Industriestandard:** PySpark wird häufig in Produktionsdatenpipelines verwendet
- ✅ **Big-Data-Kenntnisse:** Demonstriert die Beherrschung von Tools der Enterprise-Klasse

**Aktuelle Datensatzgröße:** Über 437.000 Verkaufsdatensätze, 500 Produkte, 8.000 Kunden  
**Produktionsreif:** Die Architektur kann ohne Codeänderungen auf Millionen von Datensätzen skaliert werden

**Technologien:**
- PySpark 3.5 für die verteilte Datenverarbeitung
- Delta Lake für ACID-Transaktionen
- Pandas für Datenkonvertierung und Kompatibilität



## ✨ Hauptmerkmale

### 🔄 **Datenverarbeitung**
- ✅ **Inkrementelle ETL-Pipeline** mit PySpark & Delta Lake
- ✅ **Automatisierte Datenqualitätsprüfungen** (Great Expectations)
- ✅ **Validierung von Datenverträgen** (JSON-Schema)
- ✅ **NLP-basierte Datenanreicherung** (Extrahieren von Kategorien/Marken aus Freitext)
- ✅ **Imputation fehlender Werte** mit intelligenten Standardwerten

### 🏗️ **Datenarchitektur**
- ✅ **Star-Schema-Modellierung** (1 Faktentabelle + 4 Dimensionstabellen)
- ✅ **Langsam veränderliche Dimensionen** (SCD Typ 2-fähig)
- ✅ **Durchsetzung der referenziellen Integrität**
- ✅ **Delta Lake Storage** für ACID-Transaktionen

### 📊 **Analytik-Dashboard**
- ✅ **Echtzeit-KPI-Überwachung** (Umsatz, Renditen, Kundenwachstum)
- ✅ **Mehrdimensionale Analyse** (Kanal, Produkt, Zeit, Kundensegment)
- ✅ **Interaktive Visualisierungen** (Plotly-Diagramme mit Filtern)
- ✅ **Drilldown-Funktionen** für detaillierte Einblicke

### 🛡️ **Datenqualitäts-Framework**
- ✅ **Schema-Validierung** (Pflichtfelder, Datentypen)
- ✅ **Überprüfung von Geschäftsregeln** (Preis > 0, Menge > 0)
- ✅ **Referenzielle Integrität** (Validierung von Fremdschlüsseln)
- ✅ **Duplikaterkennung** mit Analyse zusammengesetzter Schlüssel
- ✅ **Automatisierte Qualitätsberichte** (HTML/JSON-Ausgaben)


## 🏗️ Architektur
<img width="648" height="1007" alt="grafik" src="https://github.com/user-attachments/assets/d8ee9f48-9027-4609-b207-3a81fd0eda74" />



## 💼 Anwendungsfälle für Unternehmen

Diese Analyseplattform beantwortet wichtige geschäftliche Fragen:

| Frage | Lösung |
|----------|----------|
| **Welcher Vertriebskanal generiert den meisten Umsatz?** | Mehrdimensionale Umsatzanalyse nach Kanal, Zeit und Produkt |
| **Wie hoch ist unsere Rücklaufquote nach Produktkategorie?** | Überwachung der Rücklaufquote mit Drilldown nach Produkt/Kanal/Zeit |
| **Wie viele Neukunden gewinnen wir monatlich?** | Kundenkohortenanalyse mit Wachstumstrends |
| **Welche Produkte sind unsere Top-Seller?** | Produktrankings nach Umsatz, verkaufter Menge und Rücklaufquote |
| **Gibt es Probleme mit der Datenqualität in unseren Verkaufsdaten?** | Automatisierte Qualitätsprüfungen mit detaillierten Berichten zu Verstößen |



## 🚀 Erste Schritte

### Voraussetzungen

- Docker & Docker Compose
- Git
- 8 GB+ RAM empfohlen

### Schnellstart (5 Minuten)

```bash
# 1. Klonen Sie das Repository.
git clone https://github.com/YOUR_USERNAME/erp-sales-analytics.git
cd erp-sales-analytics

# 2. Legen Sie Ihre Datendateien in data/raw/ ab.
# Erforderliche Dateien: customers.parquet, products.parquet, sales.parquet, returns.parquet

# 3. Starten Sie die Docker-Container.
docker-compose up -d

# 4. Führen Sie die ETL-Pipeline aus.
docker-compose exec spark python src/etl/pipeline.py

# 5. Starten Sie das Dashboard.
docker-compose exec dashboard streamlit run dashboard/app.py
```

Das Dashboard ist unter **http://localhost:8501** verfügbar.



## 👤 Author

**Phuong Minh Nguyen**
Hi! Do you have any feedback or questions? Feel free to add and contact me :) Always happy to share knowledge among self-taught enthusiasts! <3 
- 💼 LinkedIn: [Phuong Minh Nguyen]([https://linkedin.com/in/yourprofile](https://www.linkedin.com/in/phuong-minh-nguyen-30b92b1a3/))
- 🐙 GitHub: [@Fonks]([https://github.com/YourUsername](https://github.com/Fonks))
- 📧 Email: phuongminhnguyenmails@gmail.com


