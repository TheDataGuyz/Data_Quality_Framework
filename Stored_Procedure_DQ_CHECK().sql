CREATE OR ALTER PROCEDURE SECURITY.DQ_CHECK
AS
BEGIN
    DECLARE @failed_record_script NVARCHAR(MAX);
    DECLARE @result_script NVARCHAR(MAX);
	DECLARE @run_status_script NVARCHAR(MAX);
    DECLARE @DQ_RULE_ID INT;
    DECLARE @DQ_JOB_ID_NEW INT;
    DECLARE @SUBJECT_AREA NVARCHAR(100);
    DECLARE @DATABASE_NAME NVARCHAR(100);
    DECLARE @SCHEMA_NAME NVARCHAR(100);
    DECLARE @TABLE_NAME NVARCHAR(100);
    DECLARE @COLUMN_NAME NVARCHAR(100);
	DECLARE @COLUMN_VALUE NVARCHAR(100);
    DECLARE @PRIMARY_KEY_COLUMN NVARCHAR(200); -- Adjust the size as needed
	DECLARE @PRIMARY_KEY_VALUE NVARCHAR(200);
    DECLARE @RULE_DESCRIPTION NVARCHAR(500);
	DECLARE @RULE_TYPE NVARCHAR(100);
    DECLARE @RULE_THRESHOLD FLOAT;
    DECLARE @RULE_CATEGORY NVARCHAR(100);
    DECLARE @RULE_SEVERITY NVARCHAR(100);
    DECLARE @RULE_VALIDATION_SCRIPT NVARCHAR(MAX);
	DECLARE @PII_FLAG NVARCHAR(100);
    DECLARE @ROW_COUNT INT;


    DECLARE cursor_rule CURSOR FOR
    SELECT  DQ_RULE_ID
			, SUBJECT_AREA
			, DATABASE_NAME
			, SCHEMA_NAME
			, TABLE_NAME
			, COLUMN_NAME
			, PRIMARY_KEY_COLUMN
			, PII_FLAG
			, RULE_TYPE
			, RULE_DESCRIPTION
			, RULE_THRESHOLD
			, RULE_CATEGORY
			, RULE_SEVERITY
			, RULE_VALIDATION_SCRIPT								
    FROM PRODUCT.SECURITY.DQ_RULE
    WHERE DQ_ACTIVE_FG = 1
    ORDER BY DQ_RULE_ID;

	--Get the new @DQ_JOB_ID_NEW
	SET @DQ_JOB_ID_NEW = (
            SELECT COALESCE(MAX(DQ_JOB_ID),0) + 1
            FROM (
                SELECT DQ_JOB_ID FROM PRODUCT.SECURITY.DQ_RESULT
                UNION ALL
                SELECT DQ_JOB_ID FROM PRODUCT.SECURITY.DQ_FAILED_RECORDS
                UNION ALL
                SELECT DQ_JOB_ID FROM PRODUCT.SECURITY.DQ_RUN_STATUS
                UNION ALL
                SELECT DQ_JOB_ID FROM PRODUCT.SECURITY.DQ_ERROR_HANDLE_LOG
            ) AS combined
        );

    OPEN cursor_rule;
    FETCH NEXT FROM cursor_rule INTO @DQ_RULE_ID
									, @SUBJECT_AREA
									, @DATABASE_NAME
									, @SCHEMA_NAME
									, @TABLE_NAME
									, @COLUMN_NAME
									, @PRIMARY_KEY_COLUMN
									, @PII_FLAG
									, @RULE_TYPE
									, @RULE_DESCRIPTION
									, @RULE_THRESHOLD
									, @RULE_CATEGORY
									, @RULE_SEVERITY
									, @RULE_VALIDATION_SCRIPT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		--HANDLE MUTIPLE COLUMNS AND KEYS
		IF CHARINDEX(',', @PRIMARY_KEY_COLUMN) > 0
			BEGIN
				SET @PRIMARY_KEY_VALUE = 'CONCAT(' + @PRIMARY_KEY_COLUMN + ')';
			END
		ELSE
			BEGIN
			SET @PRIMARY_KEY_VALUE = @PRIMARY_KEY_COLUMN;
			END;

		IF CHARINDEX(',', @COLUMN_NAME) > 0
			BEGIN
				SET @COLUMN_VALUE = 'CONCAT(' + @COLUMN_NAME + ')';
			END
		ELSE
			BEGIN
				SET @COLUMN_VALUE = @COLUMN_NAME;
			END;

		
        SET @failed_record_script = 'INSERT INTO PRODUCT.SECURITY.DQ_FAILED_RECORDS (
													PRIMARY_KEY_NAME
													, PRIMARY_KEY_VALUE
													, DQ_RULE_ID
													, DQ_JOB_ID
													, SUBJECT_AREA
													, DATABASE_NAME
													, SCHEMA_NAME
													, TABLE_NAME
													, COLUMN_NAME
													, COLUMN_VALUE
													, DQ_RESULT
													, RULE_SEVERITY
													, RULE_DESCRIPTION
													, DQ_RUN_TIMESTAMP)
									SELECT 
									''' + @PRIMARY_KEY_COLUMN + ''' AS PRIMARY_KEY_NAME, 
									' + @PRIMARY_KEY_VALUE + ' AS PRIMARY_KEY_VALUE, 
									' + CAST(@DQ_RULE_ID AS NVARCHAR(100)) + ' AS DQ_RULE_ID, 
									' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + ' AS DQ_JOB_ID, 
									''' + @SUBJECT_AREA + ''' AS SUBJECT_AREA, 
									''' + @DATABASE_NAME + ''' AS DATABASE_NAME, 
									''' + @SCHEMA_NAME + ''' AS SCHEMA_NAME, 
									''' + @TABLE_NAME + ''' AS TABLE_NAME, 
									''' + @COLUMN_NAME + ''' AS COLUMN_NAME, 
									' + @COLUMN_VALUE + ' AS COLUMN_VALUE, 
									''FAIL'' AS DQ_RESULT, 
									''' + @RULE_SEVERITY + ''' AS RULE_SEVERITY, 
									''' + @RULE_DESCRIPTION + ''' AS RULE_DESCRIPTION, 
									CURRENT_TIMESTAMP
                             FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.' + @TABLE_NAME + '
                             WHERE 1 = 1 
							 AND ' + @RULE_VALIDATION_SCRIPT + ';';

        -- Constructing result script
        SET @result_script = 'INSERT INTO PRODUCT.SECURITY.DQ_RESULT (
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
									' + CAST(@DQ_RULE_ID AS NVARCHAR(100)) + ' AS DQ_RULE_ID
									, ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + ' AS DQ_JOB_ID
									, ''' + @SUBJECT_AREA + ''' AS SUBJECT_AREA
									, ''' + @DATABASE_NAME + ''' AS DATABASE_NAME
									, ''' + @SCHEMA_NAME + ''' AS SCHEMA_NAME
									, ''' + @TABLE_NAME + ''' AS TABLE_NAME
									, ''' + @COLUMN_NAME + ''' AS COLUMN_NAME
									,CASE
                                        WHEN ' + CAST(@RULE_THRESHOLD AS NVARCHAR(100)) + ' <= ROUND((SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) THEN ''BELOW THRESHOLD''
                                        WHEN SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END) > 0 THEN ''FAIL''
                                        ELSE ''PASS''
                                     END AS DQ_RESULT
									 ,''' + @RULE_SEVERITY + ''' AS RULE_SEVERITY
									 , ''' + @RULE_DESCRIPTION + ''' AS RULE_DESCRIPTION
									 , ' + CAST(@RULE_THRESHOLD AS NVARCHAR(100)) + ' AS RULE_THRESHOLD
									 ,COALESCE(SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END), 0) AS COUNT_OF_FAILED
									 ,COALESCE(SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 0 ELSE 1 END), 0) AS COUNT_OF_PASSED
									 ,COALESCE(ROUND((SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2), 0) AS PCT_OF_FAILED
									 ,COALESCE(ROUND((SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 0 ELSE 1 END) / COUNT(*)) * 100, 2), 0) AS PCT_OF_PASSED
									 ,CURRENT_TIMESTAMP
                              FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.' + @TABLE_NAME + ';';
		
		--Error handle  
		BEGIN TRY
		-- Execute error_script and result_script
			EXECUTE sp_executesql @failed_record_script;
			EXECUTE sp_executesql @result_script;
			--PRINT @COLUMN_VALUE;
			--PRINT @failed_record_script;
		END TRY  
		BEGIN CATCH
		-- Constructing error script
			 INSERT INTO PRODUCT.[Security].[DQ_ERROR_HANDLE_LOG] (
							[DQ_JOB_ID]
							,[ERR_DQ_RULE_ID]
							,[ERR_MESSAGE]
							,[DQ_RUN_TIMESTAMP])
             SELECT @DQ_JOB_ID_NEW
					,@DQ_RULE_ID
					,CONCAT(ERROR_NUMBER(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE()) AS [ERR_MESSAGE]
					,CURRENT_TIMESTAMP;
		END CATCH;


        FETCH NEXT FROM cursor_rule INTO  @DQ_RULE_ID
									, @SUBJECT_AREA
									, @DATABASE_NAME
									, @SCHEMA_NAME
									, @TABLE_NAME
									, @COLUMN_NAME
									, @PRIMARY_KEY_COLUMN
									, @PII_FLAG
									, @RULE_TYPE
									, @RULE_DESCRIPTION
									, @RULE_THRESHOLD
									, @RULE_CATEGORY
									, @RULE_SEVERITY
									, @RULE_VALIDATION_SCRIPT;
    END;

    CLOSE cursor_rule;
    DEALLOCATE cursor_rule;

	-- Constructing run_status script
		SET @run_status_script ='INSERT INTO PRODUCT.SECURITY.DQ_RUN_STATUS(
							DQ_JOB_ID
							, DQ_RUN_STATUS
							, EXPECTED_DQ_RUN_COUNT
							, ACTUAL_DQ_RUN_COUNT
							, ACTUAL_DQ_PASS_COUNT
							, ACTUAL_DQ_FAIL_COUNT
							, DQ_RUN_TIMESTAMP)
							SELECT
							' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + '
							,CASE WHEN ((SELECT COUNT(*) FROM PRODUCT.SECURITY.DQ_ERROR_HANDLE_LOG
										  WHERE DQ_JOB_ID = ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + ') = 0)
								  THEN ''Completed Successfully''
								  ELSE ''Completed with error''
							END AS DQ_RUN_STATUS
							,(SELECT COUNT (*) FROM PRODUCT.SECURITY.DQ_RULE WHERE DQ_ACTIVE_FG = 1)
							,(SELECT COUNT(*) FROM PRODUCT.SECURITY.DQ_RESULT WHERE DQ_JOB_ID = ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + ')
							,(SELECT COUNT (*) FROM PRODUCT.SECURITY.DQ_RESULT WHERE DQ_JOB_ID = ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + ' AND DQ_RESULT = ''PASS'' )
							,(SELECT COUNT (*) FROM PRODUCT.SECURITY.DQ_RESULT WHERE DQ_JOB_ID = ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(100)) + ' AND DQ_RESULT <> ''PASS'')
							, CURRENT_TIMESTAMP';
	-- Execute run_status script
	EXECUTE sp_executesql @run_status_script;
END;


-- Execute [Security].[DQ_CHECK]




