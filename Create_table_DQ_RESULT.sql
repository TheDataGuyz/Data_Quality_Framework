CREATE TABLE PRODUCT.SECURITY.DQ_RESULT (
    DQ_RESULT_ID INT IDENTITY(1,1) PRIMARY KEY,
    DQ_RULE_ID INT,
    DQ_JOB_ID INT,
    SUBJECT_AREA VARCHAR(100),
    DATABASE_NAME VARCHAR(100),
    SCHEMA_NAME VARCHAR(100),
    TABLE_NAME VARCHAR(200),
    COLUMN_NAME VARCHAR(200),
    DQ_RESULT VARCHAR(200),
    RULE_SEVERITY VARCHAR(200),
    RULE_DESCRIPTION NVARCHAR(MAX),
    RULE_THRESHOLD DECIMAL(5, 2),
    COUNT_OF_PASSED INT,
    COUNT_OF_FAILED INT,
    PCT_OF_FAILED DECIMAL(10, 2),
    PCT_OF_PASSED DECIMAL(10, 2),
    DQ_RUN_TIMESTAMP DATETIME2(3),
    FOREIGN KEY (DQ_RULE_ID) REFERENCES PRODUCT.SECURITY.DQ_RULE(DQ_RULE_ID)
);

--DROP TABLE PRODUCT.SECURITY.DQ_RESULT;