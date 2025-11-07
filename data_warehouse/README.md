# 🌟 Phase 3: Star Schema Modellierung

> **Kimball Dimensional Modeling** für Shoebadoo Sales Analytics

---

## 📋 Übersicht

In Phase 3 wurde ein **Star Schema Data Warehouse** implementiert, um analytische Anfragen für das Shoebadoo ERP-System zu ermöglichen.

### 🎯 Projektziel

Ermögliche Business-Analysten die Beantwortung folgender Fragen:
- ✅ Umsatz nach Kanal, Produkt, Zeit, Kundensegment
- ✅ Retourenquote nach Produkt/Kanal/Zeit
- ✅ Neukundenentwicklung pro Monat
- ✅ Top-Produkte nach Umsatz/Menge/Retouren

---

## 🏗️ Architektur

### Star Schema Design

```
                    dim_date
                        │
                        │
    dim_customer ──── FACT_sales ──── dim_product
                        │
                        │
                    dim_channel
```

**Komponenten:**
- **1 Fact Table**: `fact_sales` (~400k Transaktionen)
- **4 Dimension Tables**: Date, Customer, Product, Channel

---

## 📊 Datenmodell

### Fact Table: `fact_sales`

Enthält alle Sales Transaktionen mit Measures und Foreign Keys.

| Spalte | Typ | Beschreibung |
|--------|-----|--------------|
| `sale_id` | STRING | Primary Key |
| `date_key` | INT | FK → dim_date |
| `customer_key` | INT | FK → dim_customer |
| `product_key` | INT | FK → dim_product |
| `channel_key` | INT | FK → dim_channel |
| `quantity` | INT | Verkaufte Menge |
| `unit_price` | DECIMAL | Preis pro Einheit |
| `total_amount` | DECIMAL | Gesamtumsatz |
| `is_returned` | BOOLEAN | Retourniert? |

### Dimension: `dim_date`

Zeit-Dimension für temporale Analysen.

| Spalte | Typ | Beispiel |
|--------|-----|----------|
| `date_key` | INT | 20240115 |
| `full_date` | DATE | 2024-01-15 |
| `year` | INT | 2024 |
| `quarter` | INT | 1 |
| `month` | INT | 1 |
| `month_name` | STRING | January |
| `is_weekend` | BOOLEAN | false |

### Dimension: `dim_customer`

Kundenstammdaten mit Segmentierung.

| Spalte | Typ |
|--------|-----|
| `customer_key` | INT |
| `customer_id` | STRING |
| `customer_name` | STRING |
| `customer_segment` | STRING |
| `country` | STRING |
| `city` | STRING |

### Dimension: `dim_product`

Produktkatalog mit Kategorisierung.

| Spalte | Typ |
|--------|-----|
| `product_key` | INT |
| `product_id` | STRING |
| `product_name` | STRING |
| `category` | STRING |
| `subcategory` | STRING |
| `brand` | STRING |
| `price` | DECIMAL |

### Dimension: `dim_channel`

Verkaufskanäle.

| Spalte | Typ |
|--------|-----|
| `channel_key` | INT |
| `channel_id` | STRING |
| `channel_name` | STRING |
| `channel_type` | STRING |

---

## 🚀 Implementierung

### Technologie-Stack

- **Apache Spark (PySpark)** - Distributed Data Processing
- **Parquet** - Columnar Storage Format
- **Kimball Methodology** - Dimensional Modeling
- **Jupyter Notebook** - Interactive Development

### ETL Pipeline

```python
# 1. Load Cleaned Data
sales_df = spark.read.parquet("cleaned/sales_clean.parquet")
products_df = spark.read.parquet("cleaned/products_clean.parquet")
customers_df = spark.read.parquet("cleaned/customers_clean.parquet")

# 2. Create Dimensions with Surrogate Keys
dim_customer = customers_df.withColumn("customer_key", row_number())
dim_product = products_df.withColumn("product_key", row_number())

# 3. Create Fact Table with Foreign Keys
fact_sales = sales_df \
    .join(dim_date, "date") \
    .join(dim_customer, "customer_id") \
    .join(dim_product, "product_id") \
    .select("sale_id", "date_key", "customer_key", "product_key", ...)

# 4. Save as Parquet
fact_sales.write.parquet("warehouse/fact_sales")
```

---

## 📈 Business Queries

### Beispiel 1: Umsatz nach Kanal und Quartal

```sql
SELECT 
    d.year,
    d.quarter,
    c.channel_name,
    SUM(f.total_amount) as revenue,
    SUM(f.quantity) as units_sold
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_channel c ON f.channel_key = c.channel_key
GROUP BY d.year, d.quarter, c.channel_name
ORDER BY revenue DESC;
```

### Beispiel 2: Retourenquote pro Produktkategorie

```sql
SELECT 
    p.category,
    COUNT(*) as total_sales,
    SUM(CASE WHEN f.is_returned THEN 1 ELSE 0 END) as returns,
    ROUND(returns * 100.0 / total_sales, 2) as return_rate_pct
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY return_rate_pct DESC;
```

---

## ✅ Quality Assurance

### Data Validation Checks

```python
# Foreign Key Completeness
assert fact_sales.filter(col("date_key").isNull()).count() == 0
assert fact_sales.filter(col("customer_key").isNull()).count() == 0
assert fact_sales.filter(col("product_key").isNull()).count() == 0
assert fact_sales.filter(col("channel_key").isNull()).count() == 0

# Referential Integrity
assert fact_sales.join(dim_date, "date_key", "left_anti").count() == 0
```

**Ergebnis:** ✅ Alle Checks passed

---

## 📁 Projektstruktur

```
phase3_star_schema/
├── 04_star_schema_creation.ipynb   # PySpark Implementation
├── PHASE3_STAR_SCHEMA_DESIGN.md    # Design Documentation
├── star_schema_diagram.mermaid      # ERD Diagram
├── STAR_SCHEMA_CHEATSHEET.md        # Quick Reference
└── data/
    └── warehouse/
        ├── dim_date/
        ├── dim_customer/
        ├── dim_product/
        ├── dim_channel/
        └── fact_sales/
```

---

## 🎓 Key Learnings

### Design Patterns

✅ **Surrogate Keys**
- Integer Keys (1, 2, 3...) statt Natural Keys
- Vorteil: Schneller, kleiner, unabhängig vom Source System

✅ **Date Dimension**
- Zentrale Zeit-Dimension für alle temporalen Analysen
- Date Key als Integer (YYYYMMDD) für Performance

✅ **Star Schema vs. Snowflake**
- Star: Denormalisiert, weniger JOINs, schneller
- Optimiert für Analytics statt Transactional Systems

### Performance Optimierung

- **Parquet Format**: Columnar Storage für Analytics Queries
- **Partitioning**: Nach Jahr/Monat für schnellere Queries
- **Minimal JOINs**: Star Schema reduziert JOIN-Komplexität

---

## 📊 Metrics

| Metric | Wert |
|--------|------|
| Fact Table Rows | 397,962 |
| Dimensions | 4 |
| Total Tables | 5 |
| Storage Format | Parquet |
| Compression | Snappy |
| Avg Query Time | < 2s |

---

## 🔄 Next Steps

**Phase 4: Analytics & Visualization**
- [ ] Streamlit Dashboard
- [ ] Interactive Plotly Charts
- [ ] KPI Cards
- [ ] Filter & Date Range Selection

---

## 📚 Referenzen

- [Kimball Dimensional Modeling](https://www.kimballgroup.com/)
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Parquet Format](https://parquet.apache.org/)

---

## 👨‍💻 Autor

**Phuong** - Junior Data Engineer  
Portfolio Project: Shoebadoo Sales Analytics

---

## 📝 Lizenz

Dieses Projekt ist Teil eines Data Engineering Portfolios.

---

**⭐ Star dieses Repo wenn es dir hilft!**