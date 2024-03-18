CREATE OR REPLACE TABLE DATABASE.SCHEMA.DQ_RULE (
    DQ_RULE_ID NUMBER(38,0) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 ORDER,
    SUBJECT_AREA VARCHAR(100),
    DATABASE_NAME VARCHAR(100),
    SCHEMA_NAME VARCHAR(100),
    TABLE_NAME VARCHAR(200),
    COLUMN_NAME VARCHAR(200),
    PRIMARY_KEY_COLUMN VARCHAR(200),
    RULE_CATEGORY VARCHAR(200),
    RULE_THRESHOLD NUMBER(3,2),
    RULE_SEVERITY VARCHAR(200),
    RULE_DESCRIPTION VARCHAR(16777216),
    RULE_VALIDATION_SCRIPT VARCHAR(16777216),
    CREATED_TIMESTAMP TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP,
    UPDATED_TIMESTAMP TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    DO_ACTIVE_FG VARCHAR(50),
    RULE_TYPE VARCHAR(50),
    PII_FLAG VARCHAR(50),
    PRIMARY KEY (DQ_RULE_ID)
);