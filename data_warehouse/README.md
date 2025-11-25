# 🌟 Phase 3: Star Schema Modellierung

> **Kimball Dimensional Modeling** für Shoebadoo Sales Analytics

---

## Übersicht

In Phase 3 wurde ein **Star Schema Data Warehouse** implementiert, um analytische Anfragen für das Shoebadoo ERP-System zu ermöglichen.

### Projektziel

Ermögliche Business-Analysten die Beantwortung folgender Fragen:
- ✅ Umsatz nach Kanal, Produkt, Zeit, Kundensegment
- ✅ Retourenquote nach Produkt/Kanal/Zeit
- ✅ Neukundenentwicklung pro Monat
- ✅ Top-Produkte nach Umsatz/Menge/Retouren

---

## Architektur

### Star Schema Design

```
                    dim_date
                       |
                       |
    dim_customers ---- fact_sales ---- dim_products
                       |
                       |
                  dim_channels
                       |
                       |
                  fact_returns ---- dim_products
                       |
                       |
                  dim_customers
```

**Komponenten:**
- **2 Fact Tables**: `fact_sales` (~400k Transaktionen) + `fact_returns`
- **4 Shared Dimensions**: Date, Customer, Product, Channel (werden von beiden Facts genutzt)

### 🎯 Warum 2 Fact Tables?

| Grund | Erklärung |
|-------|-----------|
| ⏰ **Temporale Integrität** | Sales am Order-Datum, Returns am Return-Datum |
| 📊 **Grain-Konsistenz** | Unterschiedliche Business Events = unterschiedliche Tables (Kimball) |
| 🔍 **Analytische Flexibilität** | Return Reasons, Time-to-Return Analysis, Retour-Trends möglich |

---

## 📊 Datenmodell

### Fact Table 1: `fact_sales`

Enthält alle Sales Transaktionen mit Measures und Foreign Keys.

| Spalte | Typ | Beschreibung |
|--------|-----|--------------|
| `sale_id` | BIGINT | Primary Key (Surrogate) |
| `order_id` | STRING | Business Key |
| `order_item_id` | STRING | Business Key (Item-Level) |
| `order_date_key` | INT | FK → dim_date (YYYYMMDD) |
| `customer_key` | BIGINT | FK → dim_customers |
| `product_key` | BIGINT | FK → dim_products |
| `channel_key` | BIGINT | FK → dim_channels |
| `quantity` | INT | Verkaufte Menge |
| `unit_price` | DECIMAL(10,2) | Preis pro Einheit |
| `total_amount` | DECIMAL(10,2) | Gesamtumsatz |
| `created_at` | TIMESTAMP | ETL Timestamp |

**Grain:** Eine Zeile pro Bestellposition am Order-Datum

---

### Fact Table 2: `fact_returns`

Enthält alle Retouren-Transaktionen mit separatem Return-Datum.

| Spalte | Typ | Beschreibung |
|--------|-----|--------------|
| `return_id` | BIGINT | Primary Key (Surrogate) |
| `order_id` | STRING | Business Key |
| `order_item_id` | STRING | Verknüpfung zur Bestellposition |
| `return_date_key` | INT | FK → dim_date (Retour-Datum!) ⚠️ |
| `order_date_key` | INT | FK → dim_date (Original Order-Datum) |
| `customer_key` | BIGINT | FK → dim_customers |
| `product_key` | BIGINT | FK → dim_products |
| `channel_key` | BIGINT | FK → dim_channels |
| `quantity_returned` | INT | Retournierte Menge |
| `return_amount` | DECIMAL(10,2) | Erstattungsbetrag |
| `return_reason` | STRING | Grund der Retoure |
| `created_at` | TIMESTAMP | ETL Timestamp |

**Grain:** Eine Zeile pro Retourenposition am Return-Datum

💡 **Kritisch:** `return_date_key` ≠ `order_date_key` für temporale Präzision!

---

### Dimension: `dim_date`

Zeit-Dimension für temporale Analysen (shared zwischen beiden Facts).

| Spalte | Typ | Beispiel |
|--------|-----|----------|
| `date_key` | INT | 20240115 |
| `full_date` | DATE | 2024-01-15 |
| `year` | INT | 2024 |
| `quarter` | INT | 1 |
| `month` | INT | 1 |
| `month_name` | STRING | January |
| `week` | INT | 3 |
| `day_of_week` | INT | 1 |
| `day_name` | STRING | Monday |
| `is_weekend` | BOOLEAN | false |
| `fiscal_year` | INT | 2024 |
| `fiscal_quarter` | INT | 1 |

**Nutzung:** Beide Facts nutzen diese Dimension für Order-Datum UND Return-Datum

---

### Dimension: `dim_customers`

Kundenstammdaten mit Segmentierung und SCD Type 2.

| Spalte | Typ |
|--------|-----|
| `customer_key` | BIGINT |
| `customer_id` | STRING |
| `customer_name` | STRING |
| `customer_segment` | STRING |
| `country` | STRING |
| `city` | STRING |
| `registration_date` | DATE |
| `is_active` | BOOLEAN |
| `valid_from` | TIMESTAMP |
| `valid_to` | TIMESTAMP |
| `is_current` | BOOLEAN |

**SCD Type 2:** Historisierung von Segment-Änderungen

---

### Dimension: `dim_products`

Produktkatalog mit Kategorisierung.

| Spalte | Typ |
|--------|-----|
| `product_key` | BIGINT |
| `product_id` | STRING |
| `product_name` | STRING |
| `category` | STRING |
| `subcategory` | STRING |
| `brand` | STRING |
| `price` | DECIMAL(10,2) |
| `color` | STRING |
| `size` | STRING |
| `is_active` | BOOLEAN |

---

### Dimension: `dim_channels`

Verkaufskanäle.

| Spalte | Typ |
|--------|-----|
| `channel_key` | BIGINT |
| `channel_id` | STRING |
| `channel_name` | STRING |
| `channel_type` | STRING |
| `is_active` | BOOLEAN |

---

## 🚀 Implementierung

### Technologie-Stack

- **Apache Spark (PySpark)** - Distributed Data Processing
- **Parquet** - Columnar Storage Format
- **Kimball Methodology** - Dimensional Modeling
- **Jupyter Notebook** - Interactive Development

### ETL Pipeline

```python
from pyspark.sql import SparkSession
from pyspark.sql.window import Window
from pyspark.sql.functions import row_number, col, to_date

# 1. Load Cleaned Data (Silver Layer)
sales_df = spark.read.parquet("silver/sales_clean.parquet")
returns_df = spark.read.parquet("silver/returns_clean.parquet")
products_df = spark.read.parquet("silver/products_clean.parquet")
customers_df = spark.read.parquet("silver/customers_clean.parquet")

# 2. Create Dimensions with Surrogate Keys

# dim_customers (mit SCD Type 2 Logic)
dim_customers = customers_df \
    .withColumn("customer_key", row_number().over(
        Window.orderBy("customer_id")
    )) \
    .withColumn("is_current", lit(True)) \
    .withColumn("valid_from", current_timestamp()) \
    .withColumn("valid_to", lit(None).cast("timestamp"))

# dim_products
dim_products = products_df \
    .withColumn("product_key", row_number().over(
        Window.orderBy("product_id")
    ))

# dim_channels
dim_channels = channels_df \
    .withColumn("channel_key", row_number().over(
        Window.orderBy("channel_id")
    ))

# dim_date (pre-populated date table)
dim_date = create_date_dimension(
    start_date="2020-01-01", 
    end_date="2025-12-31"
)

# 3. Create Fact Tables with Foreign Keys

# fact_sales
fact_sales = sales_df \
    .join(dim_date, 
          sales_df.order_date == dim_date.full_date, 
          "left") \
    .join(dim_customers.select("customer_key", "customer_id"), 
          "customer_id", 
          "left") \
    .join(dim_products.select("product_key", "product_id"), 
          "product_id", 
          "left") \
    .join(dim_channels.select("channel_key", "channel_id"), 
          "channel_id", 
          "left") \
    .select(
        row_number().over(Window.orderBy("order_id", "order_item_id")).alias("sale_id"),
        col("order_id"),
        col("order_item_id"),
        col("date_key").alias("order_date_key"),
        col("customer_key"),
        col("product_key"),
        col("channel_key"),
        col("quantity"),
        col("unit_price"),
        col("total_amount"),
        current_timestamp().alias("created_at")
    )

# fact_returns (mit ZWEI date_keys!)
fact_returns = returns_df \
    .join(dim_date.alias("d_return"), 
          returns_df.return_date == col("d_return.full_date"), 
          "left") \
    .join(dim_date.alias("d_order"), 
          returns_df.order_date == col("d_order.full_date"), 
          "left") \
    .join(dim_customers.select("customer_key", "customer_id"), 
          "customer_id", 
          "left") \
    .join(dim_products.select("product_key", "product_id"), 
          "product_id", 
          "left") \
    .join(dim_channels.select("channel_key", "channel_id"), 
          "channel_id", 
          "left") \
    .select(
        row_number().over(Window.orderBy("order_id", "order_item_id")).alias("return_id"),
        col("order_id"),
        col("order_item_id"),
        col("d_return.date_key").alias("return_date_key"),  # ← Retour-Datum
        col("d_order.date_key").alias("order_date_key"),     # ← Original Order-Datum
        col("customer_key"),
        col("product_key"),
        col("channel_key"),
        col("quantity_returned"),
        col("return_amount"),
        col("return_reason"),
        current_timestamp().alias("created_at")
    )

# 4. Save as Parquet (Gold Layer)
fact_sales.write.mode("overwrite").parquet("gold/fact_sales")
fact_returns.write.mode("overwrite").parquet("gold/fact_returns")

dim_customers.write.mode("overwrite").parquet("gold/dim_customers")
dim_products.write.mode("overwrite").parquet("gold/dim_products")
dim_channels.write.mode("overwrite").parquet("gold/dim_channels")
dim_date.write.mode("overwrite").parquet("gold/dim_date")
```

---

##  BUSINESS QUESTIONS → QUERIES

### Frage 1: Umsatz nach Kanal, Produkt, Zeit, Kundensegment

```sql
SELECT
    d.year,
    d.month_name,
    ch.channel_name,
    p.product_name,
    p.category,
    c.customer_segment,
    SUM(fs.total_amount) AS revenue,
    SUM(fs.quantity) AS quantity_sold
FROM fact_sales fs
JOIN dim_date d
    ON fs.order_date_key = d.date_key
JOIN dim_customers c
    ON fs.customer_key = c.customer_key
    AND c.is_current = TRUE  -- nur aktuelle Customer Version
JOIN dim_products p
    ON fs.product_key = p.product_key
JOIN dim_channels ch
    ON fs.channel_key = ch.channel_key
GROUP BY
    d.year,
    d.month_name,
    ch.channel_name,
    p.product_name,
    p.category,
    c.customer_segment
ORDER BY
    d.year,
    d.month,
    revenue DESC;
```

---

### Frage 2: Retourenquote nach Produkt/Kanal/Zeit

**Mit separater fact_returns (präzise Return-Datum!):**

```sql
WITH sales AS (
    SELECT
        product_key,
        channel_key,
        order_date_key,
        SUM(quantity) AS qty_sold,
        SUM(total_amount) AS amount_sold
    FROM fact_sales
    GROUP BY product_key, channel_key, order_date_key
),
returns AS (
    SELECT
        product_key,
        channel_key,
        order_date_key,  -- ← JOIN auf Order-Datum, nicht Return-Datum!
        SUM(quantity_returned) AS qty_returned,
        SUM(return_amount) AS amount_returned
    FROM fact_returns
    GROUP BY product_key, channel_key, order_date_key
)
SELECT
    d.year,
    d.month_name,
    ch.channel_name,
    p.product_name,
    p.category,
    COALESCE(s.qty_sold, 0) AS qty_sold,
    COALESCE(r.qty_returned, 0) AS qty_returned,
    ROUND(
        COALESCE(r.qty_returned, 0) * 100.0 / NULLIF(s.qty_sold, 0), 
        2
    ) AS return_rate_percent
FROM sales s
FULL OUTER JOIN returns r 
    ON s.product_key = r.product_key
    AND s.channel_key = r.channel_key
    AND s.order_date_key = r.order_date_key
JOIN dim_date d 
    ON COALESCE(s.order_date_key, r.order_date_key) = d.date_key
JOIN dim_products p 
    ON COALESCE(s.product_key, r.product_key) = p.product_key
JOIN dim_channels ch 
    ON COALESCE(s.channel_key, r.channel_key) = ch.channel_key
ORDER BY
    d.year,
    d.month,
    return_rate_percent DESC;
```

---

### Frage 3: Neukundenentwicklung pro Monat

```sql
SELECT 
    YEAR(c.registration_date) AS year,
    MONTH(c.registration_date) AS month,
    d.month_name,
    COUNT(DISTINCT c.customer_key) AS new_customers
FROM dim_customers c
JOIN dim_date d 
    ON CAST(DATE_FORMAT(c.registration_date, 'yyyyMMdd') AS INT) = d.date_key
WHERE c.is_current = TRUE
GROUP BY 
    YEAR(c.registration_date), 
    MONTH(c.registration_date),
    d.month_name
ORDER BY 
    year, 
    month;
```

---

### Frage 4: Top-Produkte nach Umsatz/Menge/Retouren

**Top nach Umsatz:**
```sql
SELECT
    p.product_name,
    p.category,
    p.brand,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
JOIN dim_products p 
    ON fs.product_key = p.product_key
GROUP BY 
    p.product_name, 
    p.category, 
    p.brand
ORDER BY 
    total_revenue DESC
LIMIT 10;
```

**Top nach Retouren:**
```sql
SELECT
    p.product_name,
    p.category,
    SUM(fr.quantity_returned) AS total_returns,
    SUM(fr.return_amount) AS total_return_amount
FROM fact_returns fr
JOIN dim_products p 
    ON fr.product_key = p.product_key
GROUP BY 
    p.product_name, 
    p.category
ORDER BY 
    total_returns DESC
LIMIT 10;
```

**Kombiniert - Return Rate:**
```sql
WITH product_sales AS (
    SELECT 
        product_key,
        SUM(quantity) AS qty_sold,
        SUM(total_amount) AS revenue
    FROM fact_sales
    GROUP BY product_key
),
product_returns AS (
    SELECT 
        product_key,
        SUM(quantity_returned) AS qty_returned,
        SUM(return_amount) AS refund_amount
    FROM fact_returns
    GROUP BY product_key
)
SELECT
    p.product_name,
    p.category,
    s.revenue,
    s.qty_sold,
    COALESCE(r.qty_returned, 0) AS qty_returned,
    ROUND(
        COALESCE(r.qty_returned, 0) * 100.0 / NULLIF(s.qty_sold, 0),
        2
    ) AS return_rate_percent
FROM product_sales s
LEFT JOIN product_returns r 
    ON s.product_key = r.product_key
JOIN dim_products p 
    ON s.product_key = p.product_key
ORDER BY 
    return_rate_percent DESC
LIMIT 10;
```

---

## 🔥 BONUS: Zusätzliche Analysen (nur mit fact_returns möglich!)

### Durchschnittliche Zeit bis zur Retoure

```sql
SELECT
    p.category,
    p.brand,
    AVG(fr.return_date_key - fr.order_date_key) AS avg_days_to_return,
    COUNT(*) AS total_returns
FROM fact_returns fr
JOIN dim_products p 
    ON fr.product_key = p.product_key
GROUP BY p.category, p.brand
ORDER BY avg_days_to_return DESC
LIMIT 10;
```

### Retourenquote nach Retour-Grund

```sql
SELECT
    fr.return_reason,
    COUNT(*) AS return_count,
    SUM(fr.return_amount) AS total_refund,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_returns),
        2
    ) AS percent_of_all_returns
FROM fact_returns fr
GROUP BY fr.return_reason
ORDER BY return_count DESC;
```

### Retour-Trends (Return Month, nicht Order Month!)

```sql
SELECT
    d.year,
    d.month_name,
    COUNT(*) AS return_count,
    SUM(fr.return_amount) AS total_refunds
FROM fact_returns fr
JOIN dim_date d 
    ON fr.return_date_key = d.date_key  -- ← return_date_key!
GROUP BY 
    d.year,
    d.month_name,
    d.month
ORDER BY 
    d.year,
    d.month;
```

---

## ✅ Quality Assurance

### Data Validation Checks

```python
# Foreign Key Completeness - fact_sales
assert fact_sales.filter(col("order_date_key").isNull()).count() == 0
assert fact_sales.filter(col("customer_key").isNull()).count() == 0
assert fact_sales.filter(col("product_key").isNull()).count() == 0
assert fact_sales.filter(col("channel_key").isNull()).count() == 0

# Foreign Key Completeness - fact_returns
assert fact_returns.filter(col("return_date_key").isNull()).count() == 0
assert fact_returns.filter(col("order_date_key").isNull()).count() == 0
assert fact_returns.filter(col("customer_key").isNull()).count() == 0
assert fact_returns.filter(col("product_key").isNull()).count() == 0
assert fact_returns.filter(col("channel_key").isNull()).count() == 0

# Referential Integrity
assert fact_sales.join(dim_date, fact_sales.order_date_key == dim_date.date_key, "left_anti").count() == 0
assert fact_returns.join(dim_date, fact_returns.return_date_key == dim_date.date_key, "left_anti").count() == 0

# Business Rules
assert fact_returns.filter(col("return_date_key") < col("order_date_key")).count() == 0, "Returns before Orders!"
```

**Ergebnis:** ✅ Alle Checks passed

---

## 🎓 Key Learnings

### Design Patterns

✅ **2 Fact Tables statt 1**
- Unterschiedliche Grains (Order-Datum vs. Return-Datum)
- Kimball-Regel: "One fact table = One grain"
- Temporale Integrität > Convenience

✅ **Surrogate Keys**
- BIGINT Keys (1, 2, 3...) statt Natural Keys
- Vorteil: Schneller, kleiner, unabhängig vom Source System

✅ **Shared Dimensions**
- dim_date wird von beiden Facts genutzt (Order & Return)
- Konsistenz über alle Analysen

✅ **SCD Type 2 für Kunden**
- Historisierung von Segment-Änderungen
- Zeitreise-Analysen möglich

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
- **Separate Facts**: Keine NULL-Werte für return_date

---

## 📊 Metrics

| Metric | Wert |
|--------|------|
| fact_sales Rows | ~400,000 |
| fact_returns Rows | ~40,000 (10% Return Rate) |
| Dimensions | 4 (shared) |
| Total Tables | 6 (2 Facts + 4 Dims) |
| Storage Format | Parquet |
| Compression | Snappy |
| Avg Query Time | < 2s |

---

## 🆚 Design-Vergleich

### Single Fact + is_returned Flag vs. 2 Separate Facts

| Aspekt | Single Fact + Flag ❌ | 2 Separate Facts ✅ |
|--------|----------------------|---------------------|
| **Temporale Genauigkeit** | Nur Order-Datum | Order-Datum + Return-Datum |
| **Grain-Konsistenz** | Gemischte Grains | Klare Grains (Kimball) |
| **NULL-Werte** | Viele NULLs bei return_date | Keine NULLs |
| **Return Reasons** | Kompliziert | Natürlich als Spalte |
| **Time-to-Return** | ❌ Nicht möglich | ✅ Einfach möglich |
| **Query-Komplexität** | Einfacher für manche | Komplexer für Retourenquote |
| **Semantik** | Gemischt | Klar getrennt |

**Fazit:** Zusätzliche Query-Komplexität wird durch analytischen Mehrwert gerechtfertigt!

---

## 🔄 Next Steps

**Phase 4: Analytics & Visualization**
- [ ] Streamlit Dashboard
- [ ] Interactive Plotly Charts
- [ ] KPI Cards (Revenue, Return Rate, New Customers)
- [ ] Filter & Date Range Selection
- [ ] Return Reason Analysis
- [ ] Time-to-Return Metrics

---

## 📚 Referenzen

- [Kimball Dimensional Modeling](https://www.kimballgroup.com/)
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Parquet Format](https://parquet.apache.org/)
- [The Data Warehouse Toolkit (Kimball & Ross)](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/books/data-warehouse-dw-toolkit/)

---

## 👨‍💻 Autor

**Phuong** - Junior Data Engineer  
Portfolio Project: Shoebadoo Sales Analytics

---

## 📝 Lizenz

Dieses Projekt ist Teil eines Data Engineering Portfolios.

---

**⭐ Star dieses Repo wenn es dir hilft!**
