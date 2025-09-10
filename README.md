# Comprehensive Data Engineering Pipeline for Analytics

## 1\. Project Overview

This project demonstrates a complete, end-to-end data engineering lifecycle using a combination of shell scripts, SQL, and command-line tools. It encompasses two distinct data pipelines:

  * **Automated Financial Data ETL**: A fully automated, scheduled pipeline that extracts the "Annual Enterprise Survey" data from a public source, performs transformations (column renaming and selection), and loads the cleaned data into a structured `GOLD` directory, simulating a data lake.

  * **Parch and Posey Competitor Analysis**: A manually triggered pipeline that sets up a PostgreSQL database, loads a set of relational CSV files (sales, accounts, etc.), and provides a suite of SQL queries for business analysis.

This repository is designed to serve as a practical example of data orchestration, transformation, database management, and analytics using common and robust tools.



## 2\. Prerequisites

Before running any scripts, ensure the following dependencies are installed on your system:

  * **Bash Shell**: A Unix-like command line (e.g., on Linux, macOS, or Windows via WSL).
  * **Core Utilities**: `wget` or `curl` for downloading data.
  * **PostgreSQL**: An active PostgreSQL server instance.
  * **psql**: The PostgreSQL command-line client.
  * **Miller (mlr)**: A powerful command-line tool for processing structured data. Install it via your system's package manager (e.g., `sudo apt-get install miller` or `brew install miller`).



## 3\. Project Structure

The repository is organized into the following directories and key files:

```bash
.
├── logs/                 # Directory for storing logs from scheduled jobs.
├── raw/                  # Raw, unmodified data extracted from sources.
├── Transformed/          # Intermediate storage for transformed data.
├── GOLD/                 # Final, cleaned data ready for use (Data Lake).
├── json_and_csv/         # Destination for json and csv files from move_csv_json.sh.
├── parch_and_posey/  
    ├── pnp_data/             # Directory for Parch and Posey source CSVs.
    ├── sql_script/           # Contains all SQL files.
    │   ├── create_tables.sql # Schema definition for the PostgreSQL database.
    │   └── analytics.sql     # Analytical queries for the P&P data.
    ├── analysis.sh           # Script to set up and load the P&P database.
├── extract.sh            # Script to download data from a URL.
├── transform_load.sh     # Script to clean and load the financial data.
├── schedule.sh           # Orchestrator script to run the automated ETL.
├── move_csv_json.sh      # Script that moves all CSV and JSON file to json_and_csv folder.
└── README.md             # Documentation.
```



## 4\. Setup and Execution

### Step 1: Clone & Configure

1.  Clone this repository to your local machine.
2.  **Important**: Configure PostgreSQL connection details inside `analysis.sh` to match your local setup (`PG_USER`, `PG_HOST`, etc.).
3.  Set your PostgreSQL password as an environment variable for security:
    ```bash
    export PGPASSWORD="your_postgres_password"
    ```

### Step 2: Running the Automated ETL (Pipeline 1)

This pipeline is orchestrated by `schedule.sh`.

**Manual Run (for testing):**
Execute the script directly from the project root directory. It will create the `logs`, `raw`, `Transformed`, and `GOLD` directories.

```bash
./schedule.sh
```

**Scheduled Run (Production):**
The `schedule.sh` script is designed to be run by `cron`. To set it up to run daily at midnight, edit your crontab:

```bash
crontab -e
```

And add the following line (adjust the path to be absolute):

```bash
0 0 * * * /path/to/your/project/schedule.sh
```

### Step 3: Running the Parch & Posey Analysis (Pipeline 2)

This pipeline requires manual setup and execution.

1.  **Place Data**: Download the "Parch and Posey" CSV files and place them inside a directory named `pnp_data` in the project root. The files must be named `region.csv`, `sales_reps.csv`, `accounts.csv`, `orders.csv`, and `web_events.csv`.
2.  **Run the Script**: Execute the `analysis.sh` script. It will create the `posey` database, define the schema, and load all the data from the CSVs.
    ```bash
    ./analysis.sh
    ```
3.  **Run Queries**: You can now connect to the `posey` database using `psql` or any SQL client and run the queries found in `sql_script/analytics.sql`.

    ### Output

    The following queries were executed to answer the questions from management. The full script can be found in `Scripts/SQL/analysis_queries.sql`.

    ### Query 1: Orders with High Gloss or Poster Quantity

    **Question**: Find a list of order IDs where either `gloss_qty` or `poster_qty` is greater than 4000. Only include the `id` field in the resulting table.

    ```sql
    SELECT id
    FROM orders
    WHERE gloss_qty > 4000 OR poster_qty > 4000;
    ```

    This query scans the `orders` table and uses an `OR` condition to filter for rows where either of the specified quantity fields exceeds the threshold.

    ### Query 2: Orders with Zero Standard Quantity

    **Question**: Write a query that returns a list of orders where the `standard_qty` is zero and either the `gloss_qty` or `poster_qty` is over 1000.

    ```sql
    SELECT *
    FROM orders
    WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);
    ```

    This query combines an `AND` condition with a grouped `OR` condition. The parentheses are crucial to ensure the logic correctly filters for orders with zero standard quantity *and* a high quantity in one of the other categories.



## 5\. Script Breakdown

  * **schedule.sh**: The main orchestrator for the automated pipeline. It calls the extract and transform/load scripts in sequence and handles logging. It is designed to be run by a scheduler like `cron`.
  * **move_csv_json.sh**: This bash script moves all CSV and JSON files from one folder to another folder named `json_and_CSV`. Use any JSON and CSV of your choice; the script should be able to work with one or more JSON and CSV files
  * **extract.sh**: A robust script that downloads a file from a given URL using `wget` or `curl`. It handles creating the destination directory.
  * **transform\_load.sh**: This is the core of the T & L process for the financial data. It uses **Miller (mlr)** to efficiently perform CSV-safe transformations:
      * Renames the `Variable_code` column to `variable_code`.
      * Selects a specific subset of columns (`Year`,`Value`,`Units`,`variable_code`).
      * Verifies that the output header matches expectations.
      * Finally, it copies the clean data to the `GOLD` directory.
  * **analysis.sh**: A setup script for the P\&P analysis. It connects to PostgreSQL, creates the `posey` database if it doesn't exist, runs the `create_tables.sql` script to build the schema, and then systematically copies data from the `pnp_data` CSVs into the database tables in the correct dependency order.
  * **create\_tables.sql**: The Data Definition Language (DDL) for the `posey` database. It defines all tables and their foreign key relationships, ensuring data integrity.
  * **analytics.sql**: Contains four distinct business queries for the Parch and Posey data, complete with comments explaining the logic of each query.