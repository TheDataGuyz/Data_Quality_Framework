CREATE OR REPLACE TABLE DATABASE.SCHEMA.DQ_RESULT (
    DQ_RULE_ID NUMBER(38, 0),
    D_JOB_ID NUMBER(38, 0),
    DQ_AUDIT_ID NUMBER(38, 0) AUTOINCREMENT START 1 INCREMENT 1 ORDER,
    SUBJECT_AREA VARCHAR(100),
    DATABASE_NAME VARCHAR(100),
    SCHEMA_NAME VARCHAR(100),
    TABLE_NAME VARCHAR(200),
    COLUMN_NAME VARCHAR(200),
    D_RESULT VARCHAR(200),
    RULE_SEVERITY VARCHAR(200),
    RULE_DESCRIPTION VARCHAR(16777216),
    RULE_THRESHOLD NUMBER(3, 2),
    COUNT_OF_PASSED VARCHAR(100),
    COUNT_OF_FAILED VARCHAR(100),
    PCT_OF_FAILED NUMBER(38, 0),
    PCT_OF_PASSED NUMBER(38, 0),
    AUDIT_TIMESTAMP TIMESTAMP_NTZ(9),
    FOREIGN KEY (DQ_RULE_ID) REFERENCES DATA_LABS.DAX_BAU.DEV_NC_DQ_RULE(DQ_RULE_ID)
);
