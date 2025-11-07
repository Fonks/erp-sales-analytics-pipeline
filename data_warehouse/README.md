# 🌟 Phase 3: Star Schema Modellierung

> **Kimball Dimensional Modeling** für Shoebadoo Sales Analytics

---

## Übersicht

In Phase 3 wurde ein **Star Schema Data Warehouse** implementiert, um analytische Anfragen für das Shoebadoo ERP-System zu ermöglichen.

### Projektziel

Ermögliche Business-Analysten die Beantwortung folgender Fragen (SQL Queries unten):
- ✅ Umsatz nach Kanal, Produkt, Zeit, Kundensegment
- ✅ Retourenquote nach Produkt/Kanal/Zeit
- ✅ Neukundenentwicklung pro Monat
- ✅ Top-Produkte nach Umsatz/Menge/Retouren

---

## Architektur

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

##  BUSINESS QUESTIONS → QUERIES

### Frage 1: Umsatz nach Kanal, Produkt, Zeit, Kundensegment

```sql
SELECT
    d.year,
    d.month,
    ch.channel_name,
    p.product_name,
    c.customer_segment,
    SUM(fs.total_amount) AS revenue
FROM fact_sales fs
JOIN dim_date d
    ON fs.date_key = d.date_key
JOIN dim_customer c
    ON fs.customer_key = c.customer_key
JOIN dim_product p
    ON fs.product_key = p.product_key
JOIN dim_channel ch
    ON fs.channel_key = ch.channel_key
WHERE fs.is_returned = FALSE  -- nur echte Verkäufe
GROUP BY
    d.year,
    d.month,
    ch.channel_name,
    p.product_name,
    c.customer_segment
ORDER BY
    d.year,
    d.month,
    ch.channel_name,
    revenue DESC;
```

### Frage 2: Retourenquote nach Produkt/Kanal/Zeit

```sql
WITH sales AS (
    SELECT
        fs.product_key,
        fs.channel_key,
        fs.date_key,
        SUM(fs.quantity) AS qty_total,
        SUM(CASE WHEN fs.is_returned = TRUE THEN fs.quantity ELSE 0 END) AS qty_returned
    FROM fact_sales fs
    GROUP BY
        fs.product_key,
        fs.channel_key,
        fs.date_key
)
SELECT
    d.year,
    d.month,
    ch.channel_name,
    p.product_name,
    qty_total,
    qty_returned,
    CASE 
        WHEN qty_total = 0 THEN 0
        ELSE qty_returned * 1.0 / qty_total
    END AS return_rate
FROM sales s
JOIN dim_date d
    ON s.date_key = d.date_key
JOIN dim_product p
    ON s.product_key = p.product_key
JOIN dim_channel ch
    ON s.channel_key = ch.channel_key
ORDER BY
    d.year,
    d.month,
    ch.channel_name,
    p.product_name;
```

### Frage 3: Neukundenentwicklung pro Monat

```sql
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT c.customer_key) as new_customers
FROM dim_customer c
JOIN dim_date d ON DATE_FORMAT(c.registration_date, 'yyyyMM') = DATE_FORMAT(d.full_date, 'yyyyMM')
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```


### Frage 4: Top-Produkte nach Umsatz/Menge/Retouren

``` sql
WITH agg AS (
    SELECT
        fs.product_key,
        SUM(CASE WHEN fs.is_returned = FALSE THEN fs.total_amount ELSE 0 END) AS revenue,
        SUM(CASE WHEN fs.is_returned = FALSE THEN fs.quantity ELSE 0 END) AS qty_sold,
        SUM(CASE WHEN fs.is_returned = TRUE THEN fs.quantity ELSE 0 END) AS qty_returned
    FROM fact_sales fs
    GROUP BY fs.product_key
)
SELECT
    p.product_name,
    p.category,
    p.subcategory,
    a.revenue,
    a.qty_sold,
    a.qty_returned
FROM agg a
JOIN dim_product p
    ON a.product_key = p.product_key
ORDER BY
    a.revenue DESC;
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
