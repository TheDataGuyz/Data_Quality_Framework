CREATE TABLE PRODUCT.SECURITY.DQ_FAILED_RECORDS (
    DQ_AUDIT_ID INT IDENTITY(1,1) PRIMARY KEY,
    DQ_RULE_ID INT,
    DQ_JOB_ID INT,
    SUBJECT_AREA VARCHAR(100),
    DATABASE_NAME VARCHAR(100),
    SCHEMA_NAME VARCHAR(100),
    TABLE_NAME VARCHAR(200),
    COLUMN_NAME VARCHAR(200),
    COLUMN_VALUE VARCHAR(200),
    PRIMARY_KEY_NAME VARCHAR(200),
    PRIMARY_KEY_VALUE VARCHAR(200),
    DQ_RESULT VARCHAR(200),
    RULE_SEVERITY VARCHAR(200),
    RULE_DESCRIPTION NVARCHAR(MAX),
    DQ_RUN_TIMESTAMP DATETIME2(3),
    FOREIGN KEY (DQ_RULE_ID) REFERENCES PRODUCT.SECURITY.DQ_RULE(DQ_RULE_ID)
);
