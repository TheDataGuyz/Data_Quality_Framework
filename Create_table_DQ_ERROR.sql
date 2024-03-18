CREATE OR REPLACE TABLE DATABASE.SCHEMA.DQ_ERROR (
    DQ_RULE_ID NUMBER(38,0),
    DQ_JOB_ID NUMBER(38,0),
    DQ_AUDIT_ID NUMBER(38,0) AUTOINCREMENT START 1 INCREMENT 1 ORDER,
    SUBJECT_AREA VARCHAR(100),
    DATABASE_NAME VARCHAR(100),
    SCHEMA_NAME VARCHAR(100),
    TABLE_NAME VARCHAR(200),
    COLUMN_NAME VARCHAR(200),
    COLUMN_VALUE VARCHAR(200),
    PRIMARY_KEY_VALUE_PAIR VARCHAR(200),
    DQ_RESULT VARCHAR(200),
    RULE_SEVERITY VARCHAR(200),
    RULE_DESCRIPTION VARCHAR(16777216),
    AUDIT_TIMESTAMP TIMESTAMP_NTZ(9),
    PII_FLAG VARCHAR(50),
    FOREIGN KEY (DQ_RULE_ID) REFERENCES DATA_LABS.DAX_BAU.DEV_NC_DQ_RULE(DQ_RULE_ID)
);
