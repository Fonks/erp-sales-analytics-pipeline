# 🌟 PHASE 3: Star Schema Design - Shoebadoo Analytics

##  1. STAR SCHEMA ÜBERSICHT

```
                    dim_date
                        |
                        |
    dim_customer ---- FACT_sales ---- dim_product
                        |
                        |
                    dim_channel
```

###  Warum Star Schema?

| Vorteil | Erklärung |
|---------|-----------|
|  **Schnell** | Wenige JOINs = schnelle Queries |
|  **Einfach** | Business User verstehen es |
|  **Analytics** | Perfekt für BI-Tools (Tableau, PowerBI) |
|  **Flexibel** | Neue Dimensionen leicht hinzufügen |

---

##  2. FACT TABLE: `fact_sales`

**= Die Transaktionen (Sales)**

| Column | Type | Beschreibung | Key Type |
|--------|------|--------------|----------|
| `sale_id` | STRING | Eindeutige Sale ID | PRIMARY KEY |
| `date_key` | INT | Date Surrogate Key (YYYYMMDD) | FOREIGN KEY → dim_date |
| `customer_key` | INT | Customer Surrogate Key | FOREIGN KEY → dim_customer |
| `product_key` | INT | Product Surrogate Key | FOREIGN KEY → dim_product |
| `channel_key` | INT | Channel Surrogate Key | FOREIGN KEY → dim_channel |
| `quantity` | INT | Anzahl verkaufte Einheiten | MEASURE |
| `unit_price` | DECIMAL | Preis pro Einheit | MEASURE |
| `total_amount` | DECIMAL | Gesamtumsatz | MEASURE |
| `is_returned` | BOOLEAN | Wurde retourniert? | FLAG |

**💡 Tipp:** Nur **Measures** (Zahlen) und **Foreign Keys** in der Fact Table!

---

##  3. DIMENSION: `dim_date`

**= Zeit-Dimensionen (für Zeit-Analysen)**

| Column | Type | Beschreibung |
|--------|------|--------------|
| `date_key` | INT | YYYYMMDD (z.B. 20240115) |
| `full_date` | DATE | Vollständiges Datum |
| `year` | INT | Jahr (2024) |
| `quarter` | INT | Quartal (1-4) |
| `month` | INT | Monat (1-12) |
| `month_name` | STRING | Monat Name (January) |
| `week` | INT | Woche (1-52) |
| `day` | INT | Tag (1-31) |
| `day_of_week` | INT | Wochentag (1=Montag) |
| `day_name` | STRING | Wochentag Name (Monday) |
| `is_weekend` | BOOLEAN | Ist Wochenende? |

** Nutzen:** "Zeig mir Umsatz pro Quartal" = easy!

---

##  4. DIMENSION: `dim_customer`

**= Kunde-Details**

| Column | Type | Beschreibung |
|--------|------|--------------|
| `customer_key` | INT | Surrogate Key (Auto-increment) |
| `customer_id` | STRING | Original Customer ID |
| `customer_name` | STRING | Name |
| `customer_segment` | STRING | Segment (B2B/B2C) |
| `country` | STRING | Land |
| `city` | STRING | Stadt |
| `postal_code` | STRING | PLZ |
| `registration_date` | DATE | Registrierungsdatum |

** Nutzen:** "Top 10 Kunden nach Segment" = easy!

---

##  5. DIMENSION: `dim_product`

**= Produkt-Details**

| Column | Type | Beschreibung |
|--------|------|--------------|
| `product_key` | INT | Surrogate Key |
| `product_id` | STRING | Original Product ID |
| `product_name` | STRING | Name |
| `category` | STRING | Kategorie |
| `subcategory` | STRING | Unterkategorie |
| `brand` | STRING | Marke |
| `price` | DECIMAL | Listenpreis |
| `color` | STRING | Farbe |
| `size` | STRING | Größe |

** Nutzen:** "Umsatz pro Kategorie/Brand" = easy!

---

##  6. DIMENSION: `dim_channel`

**= Verkaufskanal**

| Column | Type | Beschreibung |
|--------|------|--------------|
| `channel_key` | INT | Surrogate Key |
| `channel_id` | STRING | Original Channel ID |
| `channel_name` | STRING | Name (Online/Retail/Wholesale) |
| `channel_type` | STRING | Typ (Digital/Physical) |

** Nutzen:** "Retourenquote pro Kanal" = easy!

---

##  7. BUSINESS QUESTIONS → QUERIES

### Frage 1: Umsatz nach Kanal, Produkt, Zeit, Kundensegment

```sql
SELECT 
    d.year,
    d.month_name,
    ch.channel_name,
    p.category,
    c.customer_segment,
    SUM(f.total_amount) as total_revenue,
    SUM(f.quantity) as total_quantity
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_channel ch ON f.channel_key = ch.channel_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE d.year = 2024
GROUP BY d.year, d.month_name, ch.channel_name, p.category, c.customer_segment
ORDER BY total_revenue DESC;
```

### Frage 2: Retourenquote nach Produkt/Kanal/Zeit

```sql
SELECT 
    p.product_name,
    ch.channel_name,
    d.year,
    d.quarter,
    COUNT(*) as total_sales,
    SUM(CASE WHEN f.is_returned THEN 1 ELSE 0 END) as returns,
    ROUND(SUM(CASE WHEN f.is_returned THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as return_rate_pct
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_channel ch ON f.channel_key = ch.channel_key
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY p.product_name, ch.channel_name, d.year, d.quarter
ORDER BY return_rate_pct DESC;
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

```sql
-- Top 10 nach Umsatz
SELECT 
    p.product_name,
    p.brand,
    p.category,
    SUM(f.total_amount) as total_revenue,
    SUM(f.quantity) as total_quantity,
    SUM(CASE WHEN f.is_returned THEN 1 ELSE 0 END) as total_returns
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name, p.brand, p.category
ORDER BY total_revenue DESC
LIMIT 10;
```

---

## ✅ ZUSAMMENFASSUNG

### Was haben wir designed?

1.  **1 Fact Table** (fact_sales) mit Measures
2.  **4 Dimension Tables** (date, customer, product, channel)
3.  **Surrogate Keys** für Performance
4.  **Business Questions** sind beantwortbar

### Nächster Schritt: Implementation in PySpark!

**→ Siehe `04_star_schema_creation.ipynb`**

---

##  BEGRIFFE ERKLÄRT

| Begriff | Einfach erklärt |
|---------|-----------------|
| **Fact Table** | Die Transaktionen/Events (Sales, Orders) |
| **Dimension Table** | Die Details/Attribute (Customer, Product) |
| **Surrogate Key** | Auto-increment ID (1, 2, 3...) statt natürlicher IDs |
| **Measure** | Zahlen zum Aggregieren (SUM, AVG, COUNT) |
| **Grain** | Detaillierungsgrad (hier: 1 Zeile = 1 Sale) |
| **Star Schema** | Fact in der Mitte, Dimensions drumherum |

---

**🎯 Ziel erreicht:** Alle Business-Fragen können mit simplen JOINs beantwortet werden!