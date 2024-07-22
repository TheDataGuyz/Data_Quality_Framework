CREATE OR REPLACE PROCEDURE DATA_LABS.DAX_BAU.DEV_DQ_CHECK ( )
RETURNS VARCHAR (16777216)
LANGUAGE SQL
EXECUTE AS OWNER
'BEGIN
DECLARE
failed_records_script STRING;
result_script STRING;
DQ_RULE_ID INT;
DQ_JOB_ID_MAX INT;
DQ_ JOB_ID_NEW INT;
SUBJECT_AREA STRING;
DATABASE_NAME STRING;
SCHEMA_NAME STRING;
TABLE_NAME STRING;
COLUMN_NAME STRING;
COLUMN_SPLIT STRING;
PRIMARY_KEY_COLUMN STRING;
PRIMARY_KEY_SPLIT STRING;
RULE_DESCRIPTION STRING;
RULE_THRESHOLD FLOAT;
RULE_CATEGORY STRING;
RULE_SEVERITY STRING;
RULE_VALIDATION_SCRIPT STRING;
PII_FLAG STRING;
RULE_TYPE STRING;
cursor_rule CURSOR FOR
SELECT DQ_RULE_ID
,SUBJECT_AREA
,DATABASE_NAME
,SCHEMA_NAME
,TABLE_NAME
,COLUMN_NAME
,PRIMARY_KEY_COLUMN
,RULE_DESCRIPTION
,RULE_THRESHOLD
,RULE_CATEGORY
,RULE_SEVERITY
,RULE_VALIDATION_SCRIPT
,PII_FLAG
,RULE_TYPE
FROM DATA_LABS. DAX_BAU.DQ_RULE
WHERE 1=1
AND DQ_ACTIVE_FG = 1
ORDER BY DQ_RULE_ID;

BEGIN

/* delete records older than 60 days from failed records table */

  DELETE FROM DATA_LABS. DAX_BAU. DEV_DQ_FAILED_RECORDS
  WHERE DATEDIFF (DAY, DQ_RUN_TIMESTAMP, CURRENT_TIMESTAMP) >60;

/* generate new DQ_JOB_ID * /
  DQ_JOB_ID_NEW : = (SELECT COALESCE (MAX (DQ_JOB_ID), 0) + 1 FROM DATA_LABS. DAX_BAU.DQ_RESULT);

/* Loop through DQ_RULE table * /

OPEN cursor_rule;
FOR record IN cursor_rule DO
  BEGIN
    DQ_RULE_ID := record.DQ_RULE_ID;
    SUBJECT_AREA := record. SUBJECT_AREA;
    DATABASE_NAME: = record. DATABASE_NAME;
    SCHEMA_NAME : = record. SCHEMA_NAME:
    TABLE_NAME:= record. TABLE_NAME;
    COLUMN_NAME: = record. COLUMN_NAME;
    PRIMARY_KEY_COLUMN := record. PRIMARY_KEY_COLUMN;
    RULE_DESCRIPTION := record.RULE_DESCRIPTION;
    RULE_THRESHOLD : = record.RULE_THRESHOLD;
    RULE_CATEGORY: = record. RULE_CATEGORY;
    RULE_SEVERITY := record. RULE_SEVERITY:
    RULE_VALIDATION_SCRIPT := record. RULE_VALIDATION_SCRIPT;
    RULE_TYPE := record. RULE_TYPE;
    PII_FLAG := record. PII_FLAG;


/* handle multiple primary keys and multiple columns*/



/* if else condition of RULE_TYPE to determine how to run the validation script*/
IF (: RULE_TYPE = ''1'') THEN
/* date quality failed records script */
failed_records_script :=
''
INSERT INTO
DATA_LABS. DAX_BAU. DEV_DQ_FAILED_RECORDS /
DQ_RULE_ID
, DQ_JOB_ID
, SUBJECT_AREA
, DATABASE_NAME
, SCHEMA_NAME
, TABLE_NAME
, COLUMN_NAME
, COLUMN_VALUE
, PRIMARY_KEY_NAME
, PRIMARY_KEY_VALUE
, DQ_RESULT
, RULE_SEVERITY
, RULE_DESCRIPTION
, DQ_RUN_TIMESTAMP
, PII_FLAG)

SELECT DISTINCT
,DQ_RULE_ID
,DQ_ JOB_ID_NEW
,SUBJECT_AREA
,DATABASE_NAME
,SCHEMA_NAME
,TABLE_NAME
,COLUMN_NAME
,CONCAT ('' ||COLUMN_SPLIT || '') AS COLUMN_VALUE
,PRIMARY_KEY_COLUMN
,CONCAT (''|| PRIMARY_KEY_SPLIT || '') AS PRIMARY_KEY_VALUE,
,''FAIL'' AS DQ_RESULT,
,RULE_SEVERITY
,$$'' || RULE_DESCRIPTIONI ||''$$ AS RULE_DESCRIPTION
,CURRENT_TIMESTAMP AS DQ_RUN_TIMESTAMP,
,PII_FLAG
FROM
'' || DATABASE_NAME || ''.'' || SCHEMA_NAME || ''.'' || TABLE_NAME || ''
WHERE 1=1
AND ''|| RULE_VALIDATION_SCRIPT ||'';'':

/* date quality result script */
result_script ：=
'' INSERT INTO DATA_LABS.DAX_BAU.DEV_DQ_RESULT (
DQ_RULE_ID
, DQ_JOB_ID
, SUBJECT_AREA
, DATABASE_NAME
, SCHEMA_NAME
, TABLE_NAME
, COLUMN_NAME
, DQ_RESULT
, RULE_SEVERITY
, RULE_DESCRIPTION
, RULE_THRESHOLD
, COUNT_OF_FAILED
, COUNT_OF_PASSED
, PCT_OF_FAILED
, PCT_OF_PASSED
, DQ_RUN_TIMESTAMP)

SELECT
DQ_RULE_ID
,DQ_JOB_ID_NEW
,SUBJECT_AREA
,DATABASE_NAME
,SCHEMA_NAME
,TABLE_NAME
,COLUMN_NAME
,CASE WHEN
SUM (
CASE WHEN
AND THEN
RULE_THRESHOLD * 100 || ''RULE_VALIDATION_SCRIPT ||''THEN 1 ELSE 0 END) > 0
'FAIL
<= TO_VARIANT ( ROUND((SUM(CASE WHEN
WHEN
SUM (
CASE WHEN
11
{'
RULE_VALIDATION_SCRIPT ||'' THEN 1 ELSE 0 END) > 0
RULE_VALIDATION_SCRIPT ||'' THEN 1 ELSE 0 END) / COUNT (1)) * 100.
AND THEN
|I RULE_THRESHOLD * 100|| > TO_VARIANT ( ROUND ( (SUM(CASE WHEN
2））
WHEN
BELOW_THRESHOLD'•••
SUM (
CASE WHEN
"'I RULE_VALIDATION_SCRIPT |1'•
OR SUM ( CASE WHEN
THEN 1 ELSE O END) = 0
II RULE_VALIDATION_SCRIPT II"
THEN 1 ELSE O END）/COUNT（1））*100.2）））
RULE_VALIDATION_SCRIPT |/''
THEN 1 ELSE O END)
IS NULL
THEN
PASS
END AS D_RESULT.
RULE_SEVERITY
$$
RULE_DESCRIPTIONI
SS
AS RULE_SEVERITY, AS RULE_DESCRIPTION,
11 RULE_THRESHOLD
AS RULE_THRESHOLD,
IFNULL (SUM ( CASE WHEN ''|| RULE_VALIDATION_SCRIPT ||''
THEN 1 ELSE 0 END), 0)
AS COUNT_OF_FAILED,
IFNULL (SUM ( CASE WHEN
''|| RULE_VALIDATION_SCRIPT ||'' THEN O ELSE 1 END), 0) AS COUNT_OF_PASSED,
IFNULL (TO_VARIANT ( ROUND ( (SUM ( CASE WHEN
''|| RULE_VALIDATION_SCRIPT ||''
THEN 1 ELSE 0 END) / COUNT (1))
IFNULL (TO_VARIANT ( ROUND ( (SUM(CASE WHEN ''|| RULE_VALIDATION_SCRIPT ||''
THEN 0 ELSE 1 END) / COUNT (1) )* 100,0) AS PCT_OF_FAILED, AS PCT_OF_PASSED,
CURRENT_TIMESTAMP AS DQ_RUN_TIMESTAMP
FROM DATABASE_NAME.SCHEMA_NAME.TABLE_NAME


ELSEIF (: RULE_TYPE = '2') THEN
      failed_records_script = ''RULE_VALIDATION_SCRIPT'';
      result_script = ''RULE_VALIDATION_SCRIPT'';
END IF:


/* Execute failed_records_script and result_script */
EXECUTE
IMMEDIATE failed_records_script;
EXECUTE
IMMEDIATE result_script;

/* error handle for the failed scripts, Log error rules to DQ_ERROR_HANDLE_LOG table */

EXCEPTION
    WHEN OTHER THEN
        INSERT INTO
          DATA_LABS.DAX_BAU.DEV_DQ_ERROR_HANDLE_LOG (
              DQ_JOB_ID
              ,ERR_DQ_RULE_ID
              ,ERR_MESSAGE
              ,DQ_RUN_TIMESTAMP)
          VALUES (
              :DQ_JOB_ID_NEW
              ,:DQ_RULE_ID
              ,CONCAT (''ERROR CODE'' , :sqlcode, :sqlmessage)
              ,CURRENT_TIMESTAMP
END;
END FOR;
CLOSE cursor_rule;


/*date quality run status */
INSERT INTO DATA_LABS.DAX_BAU.DEV_DQ_RUN_STATUS(
DQ_JOB_ID
, DQ_RUN_STATUS
, EXPECTED_DQ_RUN_COUNT
, ACTUAL_DQ_RUN_COUNT
, ACTUAL_DQ_PASS_COUNT
, ACTUAL_DQ_FAIL_COUNT
, DQ_RUN_TIMESTAMP)
SELECT
:DQ_JOB_ID
,CASE WHEN ((SELECT COUNT(*) FROM DATA_LABS.DAX_BAU.DEV_DQ_ERROR_HANDLE_LOG
              WHERE DQ_ JOB_ID = :DQ_JOB_ID_NEW) = 0)
      THEN 'Completed Successfully'
      ELSE 'Completed with error'
END AS DQ_RUN_STATUS
,(SELECT COUNT (*) FROM DATA_LABS.DAX_BAU.DEV_DQ_RULE WHERE DQ_ACTIVE_FG = 1)
,(SELECT COUNT(*) FROM DATA_LABS.DAX_BAU.DEV_DQ_RESULT WHERE DQ_JOB_ID = :DQ_JOB_ID_NEW)
,(SELECT COUNT (*) FROM DATA_LABS. DAX_BAU.DEV_DQ_RESULT WHERE DQ_JOB_ ID = :DQ_JOB_ID_NEW AND DQ_RESULT = 'PASS' )
,(SELECT COUNT (*) FROM DATA_LABS. DAX_BAU. DEV_DQ_RESULT WHERE DQ_JOB_ID = :D0_JOB_ID_NEW AND DQ_RESULT <> 'PASS')
"'PASS'')
, CURRENT_TIMESTAMP;

RETURN ''Data Quality Check Completed'';


/* error handle for any other error */
WHEN OTHER THEN rollback;
RETURN OBJECT_CONSTRUCT (ERROR CODE, ERROR MESSAGE, :sqlcode, :sqlerrm);

END;

END;'