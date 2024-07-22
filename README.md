# Data Quality Automation Framework Documentation

## 1. Introduction

The Data Quality Automation Framework is designed to ensure the quality and integrity of data within our organization's databases. It provides a systematic approach to defining, executing, and monitoring data quality rules across various data sources.

## 2. Components

### 2.1. DQ_RULE Table

The `DQ_RULE` table stores metadata about data quality rules defined within the framework, that needs to be applied to the data. It includes information such as the rule category, severity, description, validation script, and timestamps for creation and updates.

### 2.2. DQ_RESULT Table

The `DQ_RESULT` table records the results of data quality checks performed by the framework. It captures metrics such as the count of passed and failed checks, percentage of failed checks, and timestamps.

### 2.3. DQ_FAILED_RECORDS Table

The `DQ_FAILED_RECORDS` table logs errors encountered during data quality checks. It provides details such as the affected rule, subject area, database, schema, table, column, column value, primary key and key values, result, description, audit timestamp, and PII flag.

### 2.4. DQ_RUN_STATUS Table

The `DQ_RUN_STATUS` table keeps track of the overall status of the data quality rule executions.

### 2.5. DQ_ERROR_HANDLE_LOG Table

The `DQ_ERROR_HANDLE_LOG` table logs any errors with the arrow rules ideas encountered during the data quality execution process.

### 2.6. DQ_CHECK()

The stored procedure is designed to automate the execution of data qualit rules check defined in the DQ_RULE table. It validates the data according to the rules.

<img width="800px" src="DQ_CHECK_flowchart.png" alt="flow chart png" />

### 2.7. Data Quality Dashboard

The Data Quality Dashboard provides a visual representation of data quality metrics and trends. It offers insights into the overall health of data quality across different dimensions such as rule adherence, error rates, and compliance levels.


## 3. Maintenance

- Regularly review and update data quality rules based on evolving data requirements and business needs.
- Monitor and optimize the performance of data quality checks to ensure timely execution.
- Periodically review and clean up historical data in the `DQ_FAILED_RECORDS` tables to manage storage resources.

## 4. Conclusion

The Data Quality Automation Framework, coupled with the Data Quality Dashboard, plays a critical role in maintaining the quality and integrity of our organization's data. By defining, executing, and monitoring data quality rules and metrics, we ensure that our data remains accurate, consistent, and reliable for decision-making processes.
