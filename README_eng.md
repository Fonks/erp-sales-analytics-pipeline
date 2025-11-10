# ERP Sales Analytics Pipeline

> **A production-ready data engineering project demonstrating end-to-end ETL pipeline development with PySpark, Docker, and modern data quality practices.**

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org/)
[![PySpark](https://img.shields.io/badge/PySpark-3.5-orange.svg)](https://spark.apache.org/)

---

## 📖 Quick Navigation

| **What are you looking for?** | **Go here** |
|-------------------------------|-------------|
| 🎯 Project overview & tech stack | [About This Project](#about-this-project) |
| 🗓️ Project roadmap & progress tracker | [`01_Projektplan.md`](01_Projektplan.md) |
| 🔍 Data exploration & analysis | [`notebooks/01_data_exploration.ipynb`](notebooks/01_data_exploration.ipynb) |
| 🧹 Data cleaning pipeline | [`notebooks/02_data_cleaning.ipynb`](notebooks/02_data_cleaning.ipynb) |
| ✅ Quality validation & checks | [`notebooks/03_data_quality_validation.ipynb`](notebooks/03_data_quality_validation.ipynb) |
| 🏗️ Star schema implementation (WIP) | [`notebooks/04_star_schema_WIP.ipynb`](notebooks/04_star_schema_WIP.ipynb) |
| 📊 Business SQL queries | [`data_warehouse/`](data_warehouse/) |
| 📸 Results & visualizations | [`result_documentation/`](result_documentation/) |
| 🚀 How to run this project | [Getting Started](#getting-started) |
| 🇩🇪 Deutsche Version | [README_DE.md](README_DE.md) |

---

## 🎯 About This Project

This project showcases a complete **data engineering workflow** for an e-commerce company (Shoebadoo), transforming messy real-world sales data into a reliable analytics platform.

### The Problem
Raw e-commerce data with quality issues (missing values, duplicates, inconsistent formats) needs to be transformed into clean, analysis-ready datasets that support business decisions.

### The Solution
A scalable ETL pipeline built with industry-standard tools that:
- Ingests raw Parquet files (sales, customers, products, returns)
- Applies automated data quality checks and cleaning
- Models data using Kimball methodology (Star Schema)
- Enables business intelligence through SQL queries

### Key Technologies
- **Data Processing:** PySpark 3.5, Pandas, Dask
- **Storage:** Delta Lake, Parquet format
- **Quality Assurance:** Great Expectations, JSON Schema contracts
- **Infrastructure:** Docker, Docker Compose
- **Visualization:** Streamlit (planned)

---

## 📂 Project Structure

```
erp-sales-analytics-pipeline/
│
├── 📓 notebooks/                    # Jupyter notebooks - main workflow
│   ├── 01_data_exploration.ipynb    # ← Start here: EDA & initial analysis
│   ├── 02_data_cleaning.ipynb       # Data cleaning & transformation
│   ├── 03_data_quality_validation.ipynb  # Quality checks & validation
│   └── 04_star_schema_WIP.ipynb     # 🚧 Star schema (work in progress)
│
├── 📁 data/                         # Data files (not in Git)
│   ├── raw/                         # Original Parquet files
│   ├── cleaned/                     # Processed data
│   └── delta/                       # Delta Lake tables
│
├── 🏢 data_warehouse/               # Business logic & analytics
│   ├── star_schema_design/          # ER diagrams & documentation
│   └── sql_queries/                 # Business intelligence queries
│
├── 📋 contracts/                    # Data contracts (JSON Schema)
│   └── sales_data_contract.json     # Schema validation rules
│
├── 📊 result_documentation/         # Analysis results & screenshots
│   ├── notebook_01_results/         # EDA findings
│   └── notebook_02_results/         # Cleaning results (planned)
│
├── 🐳 docker-compose.yml            # Container orchestration
├── 🐳 Dockerfile                    # Spark environment setup
├── 📦 requirements.txt              # Python dependencies
└── 📖 README.md                     # ← You are here
```

---

## 🗺️ Workflow Overview

The project follows a **4-phase approach**:

### **Phase 1: Data Exploration** 
📓 [`notebooks/01_data_exploration.ipynb`](notebooks/01_data_exploration.ipynb)

**What it does:**
- Loads raw Parquet files (437K+ sales records)
- Performs exploratory data analysis (EDA)
- Identifies data quality issues
- Documents findings with visualizations

**Key findings:**
- Missing values in product categories (~15%)
- Duplicate sales records requiring deduplication
- Inconsistent date formats
- Results documented in [`result_documentation/notebook_01_results/`](result_documentation/notebook_01_results/)

---

### **Phase 2: Data Cleaning** 
📓 [`notebooks/02_data_cleaning.ipynb`](notebooks/02_data_cleaning.ipynb)

**What it does:**
- Deduplicates sales records
- Handles missing values with intelligent strategies
- Standardizes formats (dates, currencies, text)
- Extracts categories/brands from product descriptions using NLP
- Saves cleaned data to Delta Lake

**Technical highlights:**
- Native PySpark functions (20x faster than UDFs)
- Preserves data lineage with Delta Lake
- Flags unknowns instead of deleting (maintains referential integrity)

---

### **Phase 3: Data Quality Validation** 
📓 [`notebooks/03_data_quality_validation.ipynb`](notebooks/03_data_quality_validation.ipynb)

**What it does:**
- Validates data against contracts (JSON Schema)
- Runs automated quality checks (Great Expectations)
- Enforces business rules (price > 0, valid dates)
- Generates quality reports (HTML/JSON)

**Validation layers:**
1. Schema validation (data types, required fields)
2. Business rules (logical constraints)
3. Referential integrity (foreign key checks)
4. Duplicate detection

---

### **Phase 4: Star Schema Design** 🚧
📓 [`notebooks/04_star_schema_WIP.ipynb`](notebooks/04_star_schema_WIP.ipynb) *(Work in Progress)*

**What it does:**
- Implements Kimball methodology (Star Schema)
- Creates fact and dimension tables
- Prepares data for business analytics
- Draft design & SQL queries in [`data_warehouse/`](data_warehouse/)

**Schema design:**
- **Fact Table:** `fact_sales` (transactions)
- **Dimensions:** `dim_customer`, `dim_product`, `dim_date`, `dim_channel`

---

## 💼 Business Use Cases

This pipeline answers critical business questions:

| **Business Question** | **Solution** |
|-----------------------|--------------|
| Which sales channel generates the most revenue? | Multi-dimensional analysis by channel, time, product |
| What's our return rate by product category? | Return rate monitoring with product/channel/time drilldown |
| How many new customers do we acquire monthly? | Customer cohort analysis with growth trends |
| Which products are top sellers? | Product rankings by revenue, quantity, return rate |
| Are there data quality issues in our sales data? | Automated quality checks with detailed violation reports |

**Example SQL queries available in:** [`data_warehouse/sql_queries/`](data_warehouse/)

---

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose installed
- 8GB+ RAM recommended
- Git

### Quick Start (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/Fonks/erp-sales-analytics-pipeline.git
cd erp-sales-analytics-pipeline

# 2. Add your data files to data/raw/
# Required files: customers.parquet, products.parquet, sales.parquet, returns.parquet

# 3. Start Docker containers
docker-compose up -d

# 4. Access Jupyter notebooks
# Open browser: http://localhost:8888
# Start with: notebooks/01_data_exploration.ipynb

# 5. (Optional) Run the full pipeline
docker-compose exec spark python src/etl/pipeline.py
```

### For Recruiters/Managers: **Just Want to See Results?**

No setup needed! Check out:
- **📊 Analysis Results:** [`result_documentation/`](result_documentation/)
- **🔍 Code Samples:** Browse notebooks directly on GitHub
- **📈 Business Queries:** [`data_warehouse/sql_queries/`](data_warehouse/sql_queries/)

---

## 🎓 Key Technical Learnings

### Why PySpark for This Dataset?
While the current dataset (~437K records) could be handled by Pandas, this project uses **PySpark** to demonstrate:
- ✅ **Scalability:** Architecture designed for millions of records
- ✅ **Distributed computing:** Parallel processing capabilities
- ✅ **Industry standards:** PySpark is used in production pipelines
- ✅ **Big data skills:** Enterprise-grade tool proficiency

**Production-ready:** The architecture scales to millions of records without code changes.

### Performance Optimization Learnings
- **Native Spark functions** over UDFs → 20x faster execution
- **Delta Lake** for ACID transactions & time travel
- **Partitioning strategies** for efficient queries
- **Data contracts** to catch issues early

### Data Quality Strategy
1. **Text Extraction (NLP):** Extract brands/categories from descriptions (~80-90% success)
2. **Statistical Imputation:** Missing prices filled with category averages
3. **Flagging over Deletion:** Preserve transaction history, enable future enrichment

---

## 🔮 Future Enhancements

- [ ] Complete Star Schema implementation (Phase 4)
- [ ] Build interactive Streamlit dashboard
- [ ] Add Apache Airflow for workflow orchestration
- [ ] Implement SCD Type 2 for dimension tables
- [ ] Add CI/CD pipeline with GitHub Actions
- [ ] Performance benchmarking with larger datasets

---

## 🤖 Development Transparency

### AI-Assisted Documentation
This project demonstrates **authentic technical skills** while leveraging AI as a productivity tool:

**✅ What I coded myself:**
- **All PySpark data pipelines** - ETL logic, transformations, Delta Lake operations
- **Data quality framework** - validation rules, Great Expectations suite
- **SQL queries** - business analytics, star schema implementation
- **Docker infrastructure** - container setup, orchestration
- **Data modeling** - schema design, dimensional modeling decisions

**🛠️ How I used AI (Claude):**
- **Documentation polish** - README formatting, grammar, professional tone
- **Learning resource** - explaining PySpark concepts, debugging guidance

**Why this matters:** Modern data engineers use AI tools to accelerate work, but the core technical skills, problem-solving, and domain knowledge are mine. This README itself was created with AI assistance to communicate my work professionally.

---



## 👤 Author

**Phuong Minh Nguyen**  
*Transitioning from Fashion Design to Data Engineering*

I'm a self-taught data engineer with a unique background in 3D sportswear design (Adidas, Hunkemöller). This project showcases my technical skills while demonstrating how I approach real-world data problems with creativity and rigor.

📫 **Let's connect:**
- 💼 [LinkedIn](https://www.linkedin.com/in/phuong-minh-nguyen-30b92b1a3/)
- 🐙 [GitHub](https://github.com/Fonks)
- ✉️ phuongminhnguyenmails@gmail.com

*Always happy to discuss data engineering, share knowledge, and connect with fellow learners!* 🚀

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Data generation inspired by real e-commerce patterns
- Built as part of my self-taught data engineering journey
- Special thanks to the open-source community for amazing tools

---

**⭐ If you find this project helpful, please consider giving it a star!**
