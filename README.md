# ERP Sales Analytics Pipeline

> **Ein produktionsreifes Data-Engineering-Projekt, das eine End-to-End-ETL-Pipeline mit PySpark, Docker und modernen Data-Quality-Praktiken demonstriert.**

## 📖 Schnellnavigation

| **Was suchst du?** | **Hier lang** |
|--------------------|---------------|
| 🎯 Projektübersicht & Tech-Stack | [Über dieses Projekt](README.md) |
| 🗓️ Projekt-Roadmap & Fortschritt | [`01_Projektplan.md`](01_Projektplan.md) |
| 🔍 Datenexploration & Analyse | [`notebooks/01_data_exploration.ipynb`](notebooks/01_data_exploration.ipynb) |
| 🧹 Data-Cleaning-Pipeline | [`notebooks/02_data_cleaning.ipynb`](notebooks/02_data_cleaning.ipynb) |
| ✅ Qualitätsvalidierung & Checks | [`notebooks/03_data_quality_validation.ipynb`](notebooks/03_data_quality_validation.ipynb) |
| 🏗️ Star-Schema-Implementierung (WIP) | [`notebooks/04_star_schema_WIP.ipynb`](notebooks/04_star_schema_WIP.ipynb) |
| ⭐ Star-Schema-Design | [`Star_Schema_Design.md`](data_warehouse/) |
| 📊 Business-SQL-Queries | [`data_warehouse/BUSINESS_QUERIES`](https://github.com/Fonks/erp-sales-analytics-pipeline/tree/main/data_warehouse#business-questions--queries)|
| 📸 Ergebnisse & Visualisierungen | [`result_documentation/`](result_documentation/) |
| 🚀 Projekt starten | [Getting Started](#getting-started) |
| 🇬🇧 English Version | [README_eng.md](README_eng.md) |

---

## 🎯 Über dieses Projekt

Dieses Projekt zeigt einen vollständigen **Data-Engineering-Workflow** für ein E-Commerce-Unternehmen (Shoebadoo), der chaotische Real-World-Daten in eine verlässliche Analyseplattform transformiert.

### Das Problem
Rohe E-Commerce-Daten mit Qualitätsproblemen (fehlende Werte, Duplikate, inkonsistente Formate) müssen in saubere, analysefreundliche Datensätze umgewandelt werden, die Geschäftsentscheidungen unterstützen.

### Die Lösung
Eine skalierbare ETL-Pipeline, gebaut mit Industrie-Standard-Tools, die:
- Rohe Parquet-Dateien einliest (Verkäufe, Kunden, Produkte, Retouren)
- Automatisierte Datenqualitätschecks und -bereinigung anwendet
- Daten nach Kimball-Methodik modelliert (Star Schema)
- Business Intelligence durch SQL-Queries ermöglicht

### Zentrale Technologien
- **Datenverarbeitung:** PySpark 3.5, Pandas, Dask
- **Speicherung:** Delta Lake, Parquet-Format
- **Qualitätssicherung:** Great Expectations, JSON-Schema-Contracts
- **Infrastruktur:** Docker, Docker Compose
- **Visualisierung:** Streamlit (geplant)

---

## 📂 Projektstruktur

```
erp-sales-analytics-pipeline/
│
├── 📓 notebooks/                    # Jupyter Notebooks - Haupt-Workflow
│   ├── 01_data_exploration.ipynb    # ← Hier starten: EDA & erste Analyse
│   ├── 02_data_cleaning.ipynb       # Datenbereinigung & Transformation
│   ├── 03_data_quality_validation.ipynb  # Qualitätschecks & Validierung
│   └── 04_star_schema_WIP.ipynb     # 🚧 Star Schema (Work in Progress)
│
├── 📁 data/                         # Datendateien (nicht in Git)
│   ├── raw/                         # Original-Parquet-Dateien
│   ├── cleaned/                     # Verarbeitete Daten
│   └── delta/                       # Delta-Lake-Tabellen
│
├── 🏢 data_warehouse/               # Business-Logik & Analytics
│   ├── star_schema_design/          # ER-Diagramme & Dokumentation
│   └── sql_queries/                 # Business-Intelligence-Queries
│
├── 📋 contracts/                    # Data Contracts (JSON Schema)
│   └── sales_data_contract.json     # Schema-Validierungsregeln
│
├── 📊 result_documentation/         # Analyseergebnisse & Screenshots
│   ├── notebook_01_results/         # EDA-Erkenntnisse
│   └── notebook_02_results/         # Cleaning-Ergebnisse (geplant)
│
├── 📅 01_Projektplan.md             # Detaillierte Roadmap mit Phasen
├── 🐳 docker-compose.yml            # Container-Orchestrierung
├── 🐳 Dockerfile                    # Spark-Umgebungssetup
├── 📦 requirements.txt              # Python-Dependencies
└── 📖 README.md                     # ← Du bist hier
```

---

## 🗺️ Workflow-Übersicht

Das Projekt folgt einem **4-Phasen-Ansatz**:

### **Phase 1: Datenexploration** 
📓 [`notebooks/01_data_exploration.ipynb`](notebooks/01_data_exploration.ipynb)

**Was es macht:**
- Lädt rohe Parquet-Dateien (437K+ Verkaufsdatensätze)
- Führt explorative Datenanalyse (EDA) durch
- Identifiziert Datenqualitätsprobleme
- Dokumentiert Erkenntnisse mit Visualisierungen

**Zentrale Erkenntnisse:**
- Fehlende Werte in Produktkategorien (~15%)
- Duplizierte Verkaufsdatensätze, die dedupliziert werden müssen
- Inkonsistente Datumsformate
- Ergebnisse dokumentiert in [`result_documentation/notebook_01_results/`](result_documentation/notebook_01_results/)

---

### **Phase 2: Datenbereinigung** 
📓 [`notebooks/02_data_cleaning.ipynb`](notebooks/02_data_cleaning.ipynb)

**Was es macht:**
- Dedupliziert Verkaufsdatensätze
- Behandelt fehlende Werte mit intelligenten Strategien
- Standardisiert Formate (Datum, Währung, Text)
- Extrahiert Kategorien/Marken aus Produktbeschreibungen mittels NLP
- Speichert bereinigte Daten in Delta Lake

**Technische Highlights:**
- Native PySpark-Funktionen (20x schneller als UDFs)
- Bewahrt Data Lineage mit Delta Lake
- Markiert Unbekannte statt zu löschen (erhält referenzielle Integrität)

---

### **Phase 3: Datenqualitäts-Validierung** 
📓 [`notebooks/03_data_quality_validation.ipynb`](notebooks/03_data_quality_validation.ipynb)

**Was es macht:**
- Validiert Daten gegen Contracts (JSON Schema)
- Führt automatisierte Qualitätschecks aus (Great Expectations)
- Erzwingt Business-Regeln (Preis > 0, gültige Daten)
- Generiert Qualitätsreports (HTML/JSON)

**Validierungsebenen:**
1. Schema-Validierung (Datentypen, Pflichtfelder)
2. Business-Regeln (logische Constraints)
3. Referenzielle Integrität (Foreign-Key-Checks)
4. Duplikaterkennung

---

### **Phase 4: Star-Schema-Design** 🚧
📓 [`notebooks/04_star_schema_WIP.ipynb`](notebooks/04_star_schema_WIP.ipynb) *(Work in Progress)*

**Was es macht:**
- Implementiert Kimball-Methodik (Star Schema)
- Erstellt Fact- und Dimension-Tabellen
- Bereitet Daten für Business Analytics vor
- Entwurf & SQL-Queries in [`data_warehouse/`](data_warehouse/)

**Schema-Design:**
- **Faktentabelle:** `fact_sales` (Transaktionen)
- **Dimensionen:** `dim_customer`, `dim_product`, `dim_date`, `dim_channel`

---

## 💼 Business Use Cases

Diese Pipeline beantwortet kritische Geschäftsfragen:

| **Geschäftsfrage** | **Lösung** |
|--------------------|------------|
| Welcher Vertriebskanal generiert den meisten Umsatz? | Multi-dimensionale Analyse nach Kanal, Zeit, Produkt |
| Wie hoch ist unsere Retourenquote nach Produktkategorie? | Retourenquoten-Monitoring mit Produkt/Kanal/Zeit-Drilldown |
| Wie viele Neukunden gewinnen wir monatlich? | Kundenkohorten-Analyse mit Wachstumstrends |
| Welche Produkte sind Top-Seller? | Produkt-Rankings nach Umsatz, Menge, Retourenquote |
| Gibt es Datenqualitätsprobleme in unseren Verkaufsdaten? | Automatisierte Qualitätschecks mit detaillierten Verstoßberichten |

**Beispiel-SQL-Queries verfügbar in:** [`data_warehouse/sql_queries/`](data_warehouse/sql_queries/)

---

## 🚀 Getting Started

### Voraussetzungen
- Docker & Docker Compose installiert
- 8GB+ RAM empfohlen
- Git

### Schnellstart (5 Minuten)

```bash
# 1. Repository klonen
git clone https://github.com/Fonks/erp-sales-analytics-pipeline.git
cd erp-sales-analytics-pipeline

# 2. Datendateien zu data/raw/ hinzufügen
# Benötigte Dateien: customers.parquet, products.parquet, sales.parquet, returns.parquet

# 3. Docker-Container starten
docker-compose up -d

# 4. Jupyter Notebooks aufrufen
# Browser öffnen: http://localhost:8888
# Starten mit: notebooks/01_data_exploration.ipynb

# 5. (Optional) Vollständige Pipeline ausführen
docker-compose exec spark python src/etl/pipeline.py
```

### Für Recruiter/Manager: **Nur Ergebnisse sehen?**

Kein Setup nötig! Schau dir an:
- **📊 Analyseergebnisse:** [`result_documentation/`](result_documentation/)
- **🔍 Code-Samples:** Notebooks direkt auf GitHub durchsuchen
- **📈 Business-Queries:** [`data_warehouse/sql_queries/`](data_warehouse/sql_queries/)

---

## 🎓 Zentrale technische Learnings

### Warum PySpark für dieses Dataset?
Obwohl das aktuelle Dataset (~437K Datensätze) mit Pandas verarbeitet werden könnte, nutzt dieses Projekt **PySpark**, um zu demonstrieren:
- ✅ **Skalierbarkeit:** Architektur für Millionen von Datensätzen ausgelegt
- ✅ **Verteiltes Computing:** Parallele Verarbeitungsfähigkeiten
- ✅ **Industriestandards:** PySpark wird in Produktions-Pipelines verwendet
- ✅ **Big-Data-Skills:** Enterprise-Grade-Tool-Kompetenz

**Produktionsreif:** Die Architektur skaliert auf Millionen von Datensätzen ohne Code-Änderungen.

### Performance-Optimierungs-Learnings
- **Native Spark-Funktionen** statt UDFs → 20x schnellere Ausführung
- **Delta Lake** für ACID-Transaktionen & Time Travel
- **Partitionierungs-Strategien** für effiziente Queries
- **Data Contracts**, um Probleme früh zu erkennen

### Datenqualitäts-Strategie
1. **Text-Extraktion (NLP):** Extrahiere Marken/Kategorien aus Beschreibungen (~80-90% Erfolgsrate)
2. **Statistische Imputation:** Fehlende Preise mit Kategorie-Durchschnitten gefüllt
3. **Flagging statt Löschen:** Bewahrt Transaktionshistorie, ermöglicht zukünftige Anreicherung

---

## 🔮 Zukünftige Verbesserungen

- [ ] Star-Schema-Implementierung abschließen (Phase 4)
- [ ] Interaktives Streamlit-Dashboard bauen
- [ ] Apache Airflow für Workflow-Orchestrierung hinzufügen
- [ ] SCD Typ 2 für Dimensionstabellen implementieren
- [ ] CI/CD-Pipeline mit GitHub Actions hinzufügen
- [ ] Performance-Benchmarking mit größeren Datasets

---

## 📅 Projekt-Roadmap

Detaillierte Phasen und Fortschritt findest du im **[Projektplan](01_Projektplan.md)**:

**✅ Abgeschlossen:**
- Phase 1: Projekt-Setup & Infrastruktur
- Phase 2: Data Exploration & Quality
- Phase 3.1: Dimensional Modeling

**🚧 Aktuell:**
- Phase 3.2: ETL-Pipeline & Star-Schema-Implementierung

**📋 Geplant:**
- Phase 4: Analytics & Visualization (Streamlit Dashboard)
- Phase 5: Deployment & Finale Dokumentation

---

## 👤 Autor

**Phuong Minh Nguyen**  
*Transition von Fashion Design zu Data Engineering*

Ich bin ein autodidaktischer Data Engineer mit einem einzigartigen Hintergrund im 3D-Sportswear-Design (Adidas, Hunkemöller). Dieses Projekt zeigt meine technischen Fähigkeiten und demonstriert, wie ich reale Datenprobleme mit Kreativität und Präzision angehe.

📫 **Lass uns connecten:**
- 💼 [LinkedIn](https://www.linkedin.com/in/phuong-minh-nguyen-30b92b1a3/)
- 🐙 [GitHub](https://github.com/Fonks)
- ✉️ phuongminhnguyenmails@gmail.com

*Ich freue mich immer, über Data Engineering zu diskutieren, Wissen zu teilen und mit anderen Lernenden zu connecten!* 🚀

---

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) für Details.

---

## 🙏 Danksagungen

- Datengenerierung inspiriert von echten E-Commerce-Mustern
- Gebaut als Teil meiner autodidaktischen Data-Engineering-Reise
- Besonderer Dank an die Open-Source-Community für großartige Tools

---

**⭐ Wenn du dieses Projekt hilfreich findest, gib ihm gerne einen Stern!**
