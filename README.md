# Snowflake + dbt E-commerce Analytics

An analytics-engineering project that turns raw e-commerce data (customers, products, orders, order items) into clean, tested, documented tables in **Snowflake** using **dbt**.

It follows a standard layered design:

```
seeds (raw_*)  ->  staging (stg_*)  ->  marts (fct_*, dim_*, mart_*)
   raw CSVs         clean + rename        business-ready tables
```

## Tech stack

- **Snowflake**: cloud data warehouse
- **dbt Core** (`dbt-snowflake`): SQL transformations, tests, and documentation
- **GitHub Actions**: runs `dbt seed` and `dbt build` on every pull request
- **SQL**: CTEs, joins, aggregations, `IFF`, `COUNT_IF`, Jinja macros and variables

## Models

| Layer | Model | Description |
|---|---|---|
| Staging | `stg_customers` | Cleaned customers, lower-cased emails |
| Staging | `stg_products` | Product catalogue |
| Staging | `stg_orders` | Orders from the source system |
| Staging | `stg_order_items` | Line items with a calculated `line_total` |
| Marts | `fct_orders` | One row per order, totals recalculated from line items |
| Marts | `dim_customers` | One row per customer with lifetime revenue and a value segment |
| Marts | `mart_daily_revenue` | Daily revenue and average order value (completed orders) |

## Data quality

- Generic tests: `unique`, `not_null`, `accepted_values`, `relationships`
- A custom singular test (`assert_order_totals_match_items`) checks that each order total equals the sum of its line items
- Customer segment thresholds are configurable in `dbt_project.yml` (`high_value_threshold`, `medium_value_threshold`)

## Getting started

1. **Snowflake setup** (free trial works): create a warehouse, a database (for example `ANALYTICS_DEV`) and a role that can create schemas and tables in it.
2. **Install dependencies**
   ```bash
   python -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
   ```
3. **Configure the connection**: copy `profiles.yml.example` to `~/.dbt/profiles.yml` and set these environment variables:
   `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, and optionally `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`.
4. **Run the project**
   ```bash
   dbt debug        # check the connection
   dbt seed         # load the sample CSVs
   dbt build        # run models and tests
   dbt docs generate && dbt docs serve   # browse the lineage graph
   ```

Tables are created in schemas named `<your_schema>_raw`, `<your_schema>_staging` and `<your_schema>_marts` (for example `dbt_dev_marts`).

## CI

`.github/workflows/dbt_ci.yml` runs `dbt seed` and `dbt build` on pull requests and pushes to `main`. Add the Snowflake values as repository secrets (Settings -> Secrets and variables -> Actions): `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`.

## Project structure

```
.
├── dbt_project.yml
├── profiles.yml.example
├── requirements.txt
├── seeds/        sample raw data (CSV)
├── models/
│   ├── staging/  stg_* models + tests
│   └── marts/    fct_*, dim_*, mart_* models + tests
├── macros/       reusable Jinja macros
├── tests/        custom data tests
└── .github/workflows/dbt_ci.yml
```

## Ideas for next steps

- Replace the seeds with real source tables and add dbt `sources` with freshness checks
- Add incremental models for large fact tables
- Add dbt snapshots (SCD Type 2) for customer changes
- Add Snowflake cost controls (warehouse auto-suspend, query tags)

## Notes

All data in `seeds/` is fictional sample data. Amounts are in INR.
