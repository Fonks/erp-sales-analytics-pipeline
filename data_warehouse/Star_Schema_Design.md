# 🌟 PHASE 3: Star Schema Design - Shoebadoo Analytics

##  1. STAR SCHEMA ÜBERSICHT

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
                  fact_returns
```

###  Warum Star Schema?

| Vorteil | Erklärung |
|---------|-----------|
|  **Schnell** | Wenige JOINs = schnelle Queries |
|  **Einfach** | Business User verstehen es |
|  **Analytics** | Perfekt für BI-Tools (Tableau, PowerBI) |
|  **Flexibel** | Neue Dimensionen leicht hinzufügen |

---

###  Warum 2 Fact Tables?

| Grund | Erklärung |
|-------|-----------|
| ⏰ **Temporale Integrität** | Sales am Order-Datum, Returns am Return-Datum |
| 📊 **Grain-Konsistenz** | Unterschiedliche Business Events = unterschiedliche Tables |
| 🔍 **Analytische Flexibilität** | Return Reasons, Time-to-Return Analysis möglich |

---

## Tabellendefinitionen

### 1. Faktentabelle: `fact_sales`

**Zweck:** Speichert alle Verkaufstransaktionen (Grain: eine Zeile pro Bestellposition)

| Spalte | Datentyp | Beschreibung |
|--------|----------|--------------|
| `sale_id` | BIGINT | Primary Key (Surrogate Key) |
| `order_id` | STRING | Business Key der Bestellung |
| `order_item_id` | STRING | Business Key der Bestellposition |
| `customer_key` | BIGINT | Foreign Key → dim_customers |
| `product_key` | BIGINT | Foreign Key → dim_products |
| `channel_key` | BIGINT | Foreign Key → dim_channels |
| `order_date_key` | INT | Foreign Key → dim_date (Format: YYYYMMDD) |
| `quantity` | INT | Verkaufte Menge |
| `unit_price` | DECIMAL(10,2) | Einzelpreis |
| `total_amount` | DECIMAL(10,2) | Gesamtumsatz (quantity × unit_price) |
| `created_at` | TIMESTAMP | ETL Timestamp |

**Grain:** Eine Zeile pro Bestellposition (Order Item)

---

### 2. Faktentabelle: `fact_returns`

**Zweck:** Speichert alle Retourenvorgänge

| Spalte | Datentyp | Beschreibung |
|--------|----------|--------------|
| `return_id` | BIGINT | Primary Key (Surrogate Key) |
| `order_id` | STRING | Business Key der ursprünglichen Bestellung |
| `order_item_id` | STRING | Verknüpfung zur Bestellposition |
| `customer_key` | BIGINT | Foreign Key → dim_customers |
| `product_key` | BIGINT | Foreign Key → dim_products |
| `channel_key` | BIGINT | Foreign Key → dim_channels |
| `return_date_key` | INT | Foreign Key → dim_date |
| `order_date_key` | INT | Foreign Key → dim_date (ursprüngliches Bestelldatum) |
| `quantity_returned` | INT | Retournierte Menge |
| `return_amount` | DECIMAL(10,2) | Erstattungsbetrag |
| `return_reason` | STRING | Grund der Retoure |
| `created_at` | TIMESTAMP | ETL Timestamp |

**Grain:** Eine Zeile pro Retourenposition

---

### 3. Dimensionstabelle: `dim_customers`

**Zweck:** Kundenstammdaten mit Segmentierung

| Spalte | Datentyp | Beschreibung |
|--------|----------|--------------|
| `customer_key` | BIGINT | Primary Key (Surrogate Key) |
| `customer_id` | STRING | Business Key (natürliche Kunden-ID) |
| `customer_name` | STRING | Kundenname |
| `customer_segment` | STRING | Kundensegment (z.B. "Premium", "Standard", "New") |
| `registration_date` | DATE | Erstregistrierungsdatum |
| `country` | STRING | Land |
| `city` | STRING | Stadt |
| `is_active` | BOOLEAN | Aktiv-Status |
| `valid_from` | TIMESTAMP | SCD Type 2: Gültig ab |
| `valid_to` | TIMESTAMP | SCD Type 2: Gültig bis |
| `is_current` | BOOLEAN | SCD Type 2: Aktueller Eintrag? |
| `created_at` | TIMESTAMP | ETL Timestamp |

**SCD Type:** Type 2 (Historisierung für Kundensegment-Änderungen)

---

### 4. Dimensionstabelle: `dim_products`

**Zweck:** Produktstammdaten mit Hierarchien

| Spalte | Datentyp | Beschreibung |
|--------|----------|--------------|
| `product_key` | BIGINT | Primary Key (Surrogate Key) |
| `product_id` | STRING | Business Key (SKU) |
| `product_name` | STRING | Produktname |
| `category` | STRING | Produktkategorie (z.B. "Sneakers", "Boots") |
| `subcategory` | STRING | Unterkategorie |
| `brand` | STRING | Marke |
| `color` | STRING | Farbe |
| `size` | STRING | Größe |
| `price` | DECIMAL(10,2) | Listenpreis |
| `is_active` | BOOLEAN | Aktiv im Sortiment? |
| `created_at` | TIMESTAMP | ETL Timestamp |

**Hierarchie:** Brand → Category → Subcategory → Product

---

### 5. Dimensionstabelle: `dim_channels`

**Zweck:** Vertriebskanäle

| Spalte | Datentyp | Beschreibung |
|--------|----------|--------------|
| `channel_key` | BIGINT | Primary Key (Surrogate Key) |
| `channel_id` | STRING | Business Key |
| `channel_name` | STRING | Kanalname (z.B. "Online Shop", "Retail Store") |
| `channel_type` | STRING | Kanaltyp (z.B. "E-Commerce", "Brick & Mortar") |
| `is_active` | BOOLEAN | Aktiv-Status |
| `created_at` | TIMESTAMP | ETL Timestamp |

---

### 6. Dimensionstabelle: `dim_date`

**Zweck:** Zeit-Dimension mit vorberechneten Attributen

| Spalte | Datentyp | Beschreibung |
|--------|----------|--------------|
| `date_key` | INT | Primary Key (Format: YYYYMMDD) |
| `full_date` | DATE | Vollständiges Datum |
| `day_of_week` | INT | Wochentag (1-7) |
| `day_name` | STRING | Wochentagsname |
| `day_of_month` | INT | Tag des Monats |
| `day_of_year` | INT | Tag des Jahres |
| `week_of_year` | INT | Kalenderwoche |
| `month` | INT | Monat (1-12) |
| `month_name` | STRING | Monatsname |
| `quarter` | INT | Quartal (1-4) |
| `year` | INT | Jahr |
| `is_weekend` | BOOLEAN | Wochenende? |
| `is_holiday` | BOOLEAN | Feiertag? |
| `fiscal_year` | INT | Geschäftsjahr |
| `fiscal_quarter` | INT | Geschäftsquartal |

---

## Beantwortung der Business-Fragen

### 1. **Umsatz nach Kanal, Produkt, Zeit, Kundensegment**

```sql
SELECT 
    d.year,
    d.month_name,
    c.channel_name,
    p.product_name,
    p.category,
    cu.customer_segment,
    SUM(f.total_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_date d ON f.order_date_key = d.date_key
JOIN dim_channels c ON f.channel_key = c.channel_key
JOIN dim_products p ON f.product_key = p.product_key
JOIN dim_customers cu ON f.customer_key = cu.customer_key
WHERE cu.is_current = TRUE
GROUP BY d.year, d.month_name, c.channel_name, p.product_name, p.category, cu.customer_segment
ORDER BY total_revenue DESC;
```

---

### 2. **Retourenquote nach Produkt/Kanal/Zeit**

```sql
WITH sales AS (
    SELECT 
        product_key,
        channel_key,
        order_date_key,
        SUM(quantity) AS sold_quantity,
        SUM(total_amount) AS sold_amount
    FROM fact_sales
    GROUP BY product_key, channel_key, order_date_key
),
returns AS (
    SELECT 
        product_key,
        channel_key,
        order_date_key,
        SUM(quantity_returned) AS returned_quantity,
        SUM(return_amount) AS returned_amount
    FROM fact_returns
    GROUP BY product_key, channel_key, order_date_key
)
SELECT 
    d.year,
    d.month_name,
    c.channel_name,
    p.product_name,
    p.category,
    COALESCE(s.sold_quantity, 0) AS sold_quantity,
    COALESCE(r.returned_quantity, 0) AS returned_quantity,
    ROUND(COALESCE(r.returned_quantity, 0) * 100.0 / NULLIF(s.sold_quantity, 0), 2) AS return_rate_percent
FROM sales s
FULL OUTER JOIN returns r 
    ON s.product_key = r.product_key 
    AND s.channel_key = r.channel_key 
    AND s.order_date_key = r.order_date_key
JOIN dim_date d ON COALESCE(s.order_date_key, r.order_date_key) = d.date_key
JOIN dim_channels c ON COALESCE(s.channel_key, r.channel_key) = c.channel_key
JOIN dim_products p ON COALESCE(s.product_key, r.product_key) = p.product_key
ORDER BY return_rate_percent DESC;
```

---

### 3. **Neukundenentwicklung pro Monat**

```sql
SELECT 
    YEAR(c.registration_date) AS year,
    MONTH(c.registration_date) AS month,
    DATE_FORMAT(c.registration_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT c.customer_key) AS new_customers
FROM dim_customers c
WHERE c.is_current = TRUE
GROUP BY YEAR(c.registration_date), MONTH(c.registration_date), DATE_FORMAT(c.registration_date, '%Y-%m')
ORDER BY year, month;
```

---

### 4. **Top-Produkte nach Umsatz/Menge/Retouren**

**Top-Produkte nach Umsatz:**
```sql
SELECT 
    p.product_name,
    p.category,
    p.brand,
    SUM(f.total_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name, p.category, p.brand
ORDER BY total_revenue DESC
LIMIT 10;
```

**Top-Produkte nach Retouren:**
```sql
SELECT 
    p.product_name,
    p.category,
    SUM(r.quantity_returned) AS total_returns,
    SUM(r.return_amount) AS total_return_amount
FROM fact_returns r
JOIN dim_products p ON r.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY total_returns DESC
LIMIT 10;
```


---

## ✅ ZUSAMMENFASSUNG

### Was haben wir designed?

1.  **2 Fact Tables** (fact_sales + fact_returns) mit unterschiedlichen Grains
2.  **4 Dimension Tables** (date, customer, product, channel) - shared zwischen beiden Facts
3.  **Surrogate Keys** für Performance (BIGINT)
4.  **Alle Business Questions** sind beantwortbar
5.  **Zusätzliche Analysen** durch temporale Trennung möglich

### Design-Entscheidungen

| Entscheidung | Begründung |
|--------------|------------|
| Separate fact_returns | Temporale Integrität, unterschiedlicher Grain |
| Shared Dimensions | Konsistenz, keine Duplizierung |
| SCD Type 2 für Kunden | Historisierung von Segment-Änderungen |
| Date Key als INT | Performance, einfache Joins |
| BIGINT für Keys | Skalierbarkeit für Production |

### Nächster Schritt: Implementation in PySpark!

**→ Siehe `04_star_schema_creation.ipynb`**

---

##  10. BEGRIFFE ERKLÄRT

| Begriff | Einfach erklärt |
|---------|-----------------|
| **Fact Table** | Die Transaktionen/Events (Sales, Returns) |
| **Dimension Table** | Die Details/Attribute (Customer, Product) |
| **Surrogate Key** | Auto-increment ID (1, 2, 3...) statt natürlicher IDs |
| **Measure** | Zahlen zum Aggregieren (SUM, AVG, COUNT) |
| **Grain** | Detaillierungsgrad (fact_sales: 1 Zeile = 1 Sale, fact_returns: 1 Zeile = 1 Return) |
| **Star Schema** | Fact(s) in der Mitte, Dimensions drumherum |
| **Shared Dimension** | Eine Dimension wird von mehreren Facts genutzt |
| **SCD Type 2** | Slowly Changing Dimension mit Historisierung |

---

##  11. VORTEILE DES 2-FACT DESIGNS

### vs. Single Fact mit is_returned Flag

| Aspekt | Single Fact + Flag | 2 Separate Facts |
|--------|-------------------|------------------|
| **Temporale Genauigkeit** | ❌ Nur Order-Datum | ✅ Order-Datum + Return-Datum |
| **Grain-Konsistenz** | ❌ Gemischte Grains | ✅ Klare Grains |
| **NULL-Werte** | ❌ Viele NULLs bei return_date | ✅ Keine NULLs |
| **Query-Einfachheit** | ✅ Weniger JOINs für manche Queries | ⚠️ Mehr JOINs für Retourenquote |
| **Return Reasons** | ⚠️ Kompliziert hinzuzufügen | ✅ Natürlich als Spalte |
| **Semantik** | ❌ Gemischte Bedeutung | ✅ Klare Trennung |
| **Time-to-Return Analyse** | ❌ Nicht möglich | ✅ Einfach möglich |

---

**🎯 Ziel erreicht:** 
- ✅ Alle Business-Fragen beantwortbar
- ✅ Temporale Integrität gewahrt
- ✅ Zusätzliche Analysen möglich
- ✅ Kimball Best Practices befolgt

---

## 👨‍💻 Autor

**Phuong** - Junior Data Engineer  
Portfolio Project: Shoebadoo Sales Analytics

---
