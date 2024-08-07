CREATE TABLE PRODUCT.SECURITY.DQ_ERROR_HANDLE_LOG (
    DQ_JOB_ID INT,
    ERR_DQ_RULE_ID INT,
    ERR_MESSAGE VARCHAR (200),
    DQ_RUN_TIMESTAMP DATETIME2(3)
    FOREIGN KEY (ERR_DQ_RULE_ID) REFERENCES PRODUCT.SECURITY.DQ_RULE(DQ_RULE_ID)
);
