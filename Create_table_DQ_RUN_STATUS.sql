CREATE TABLE PRODUCT.SECURITY.DQ_RUN_STATUS (
    DQ_JOB_ID INT,
    DO_RUN_STATUS VARCHAR (50),
    EXPECTED_DQ_RUN_COUNT INT,
    ACTUAL_DO_RUN_COUNT INT,
    ACTUAL_DO_PASS_COUNT INT,
    ACTUAL_DQ_FAIL_COUNT NINT,
    DO_RUN_TIMESTAMP DATETIME2(3)
);
