CREATE PROCEDURE PRODUCT.SECURITY.DQ_CHECK
AS
BEGIN
    DECLARE @error_script NVARCHAR(MAX);
    DECLARE @result_script NVARCHAR(MAX);
    DECLARE @DQ_RULE_ID INT;
    DECLARE @DQ_JOB_ID_MAX INT;
    DECLARE @DQ_JOB_ID_NEW INT;
    DECLARE @SUBJECT_AREA NVARCHAR(100);
    DECLARE @DATABASE_NAME NVARCHAR(100);
    DECLARE @SCHEMA_NAME NVARCHAR(100);
    DECLARE @TABLE_NAME NVARCHAR(100);
    DECLARE @COLUMN_NAME NVARCHAR(100);
    DECLARE @PRIMARY_KEY_COLUMN NVARCHAR(200); -- Adjust the size as needed
    DECLARE @PRIMARY_KEY_VALUE NVARCHAR(200); -- Adjust the size as needed
    DECLARE @RULE_DESCRIPTION NVARCHAR(500);
    DECLARE @RULE_THRESHOLD FLOAT;
    DECLARE @RULE_CATEGORY NVARCHAR(100);
    DECLARE @RULE_SEVERITY NVARCHAR(100);
    DECLARE @RULE_VALIDATION_SCRIPT NVARCHAR(MAX);
    DECLARE @ROW_COUNT INT;

    DECLARE cursor_rule CURSOR FOR
    SELECT DQ_RULE_ID, SUBJECT_AREA, DATABASE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, PRIMARY_KEY_COLUMN,
           RULE_DESCRIPTION, RULE_THRESHOLD, RULE_CATEGORY, RULE_SEVERITY, RULE_VALIDATION_SCRIPT
    FROM PRODUCT.SECURITY.DQ_RULE
    WHERE DQ_ACTIVE_FG = 1
    ORDER BY DQ_RULE_ID;

    OPEN cursor_rule;
    FETCH NEXT FROM cursor_rule INTO @DQ_RULE_ID, @SUBJECT_AREA, @DATABASE_NAME, @SCHEMA_NAME, @TABLE_NAME, @COLUMN_NAME, @PRIMARY_KEY_COLUMN,
                                       @RULE_DESCRIPTION, @RULE_THRESHOLD, @RULE_CATEGORY, @RULE_SEVERITY, @RULE_VALIDATION_SCRIPT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Splitting the primary key column to get individual column names
        DECLARE @Columns TABLE (ColumnName NVARCHAR(100));
        INSERT INTO @Columns
        SELECT value FROM STRING_SPLIT(@PRIMARY_KEY_COLUMN, ',');

        DECLARE @ColumnCount INT = (SELECT COUNT(*) FROM @Columns);
        DECLARE @Counter INT = 1;
        DECLARE @PrimaryKeyQuery NVARCHAR(MAX) = '';

        -- Constructing the CONCAT function to concatenate values of primary key columns
        DECLARE @ColumnName NVARCHAR(100);
        DECLARE @ColumnValue NVARCHAR(100);

        DECLARE ColumnCursor CURSOR FOR
        SELECT ColumnName FROM @Columns;

        OPEN ColumnCursor;
        FETCH NEXT FROM ColumnCursor INTO @ColumnName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @ColumnValue = QUOTENAME(@ColumnName);
            SET @PrimaryKeyQuery = @PrimaryKeyQuery + @ColumnValue;

            IF @Counter < @ColumnCount
            BEGIN
                SET @PrimaryKeyQuery = @PrimaryKeyQuery + ', ';
            END

            FETCH NEXT FROM ColumnCursor INTO @ColumnName;
            SET @Counter = @Counter + 1;
        END

        CLOSE ColumnCursor;
        DEALLOCATE ColumnCursor;

        -- Executing the query to get the concatenated primary key value
        SET @PrimaryKeyQuery = 'SELECT CONCAT(' + @PrimaryKeyQuery + ') AS PRIMARY_KEY_VALUE';
        EXEC sp_executesql @PrimaryKeyQuery, N'@PrimaryKeyValue NVARCHAR(200) OUTPUT', @PrimaryKeyValue OUTPUT;

        -- Assigning the concatenated primary key value to @PRIMARY_KEY_VALUE
        SET @PRIMARY_KEY_VALUE = @PrimaryKeyValue;

        -- Constructing error script
        SET @error_script = 'INSERT INTO PRODUCT.SECURITY.DQ_ERROR (PRIMARY_KEY_NAME, PRIMARY_KEY_VALUE, DO_RULE_ID, DQ_JOB_ID, SUBJECT_AREA, DATABASE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, COLUMN_VALUE, DO_RESULT, RULE_SEVERITY, RULE_DESCRIPTION, AUDIT_TIMESTAMP, PIT_FLAG)
                             SELECT ''' + @PRIMARY_KEY_COLUMN + ''' AS PRIMARY_KEY_NAME, ''' + @PRIMARY_KEY_VALUE + ''' AS PRIMARY_KEY_VALUE, ' + CAST(@DQ_RULE_ID AS NVARCHAR(10)) + ' AS DO_RULE_ID, ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(10)) + ' AS DQ_JOB_ID, ''' + @SUBJECT_AREA + ''' AS SUBJECT_AREA, ''' + @DATABASE_NAME + ''' AS DATABASE_NAME, ''' + @SCHEMA_NAME + ''' AS SCHEMA_NAME, ''' + @TABLE_NAME + ''' AS TABLE_NAME, ''' + @COLUMN_NAME + ''' AS COLUMN_NAME, CONCAT('''', '''') AS COLUMN_VALUE, ''FAIL'' AS DO_RESULT, ''' + @RULE_SEVERITY + ''' AS RULE_SEVERITY, ''' + @RULE_DESCRIPTION + ''' AS RULE_DESCRIPTION, CURRENT_TIMESTAMP AS AUDIT_TIMESTAMP, ''PIT_FLAG'' AS PIT_FLAG
                             FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.' + @TABLE_NAME + '
                             WHERE 1=1 AND ' + @RULE_VALIDATION_SCRIPT + ';';

        -- Constructing result script
        SET @result_script = 'INSERT INTO PRODUCT.SECURITY.DQ_RESULT (DO_RULE_ID, DO_JOB_ID, SUBJECT_AREA, DATABASE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, DQ_RESULT, RULE_SEVERITY, RULE_DESCRIPTION, RULE_THRESHOLD, COUNT_OF_FAILED, COUNT_OF_PASSED, PCT_OF_FAILED, PCT_OF_PASSED, AUDIT_TIMESTAMP)
                              SELECT ' + CAST(@DQ_RULE_ID AS NVARCHAR(10)) + ' AS DO_RULE_ID, ' + CAST(@DQ_JOB_ID_NEW AS NVARCHAR(10)) + ' AS DO_JOB_ID, ''' + @SUBJECT_AREA + ''' AS SUBJECT_AREA, ''' + @DATABASE_NAME + ''' AS DATABASE_NAME, ''' + @SCHEMA_NAME + ''' AS SCHEMA_NAME, ''' + @TABLE_NAME + ''' AS TABLE_NAME, ''' + @COLUMN_NAME + ''' AS COLUMN_NAME,
                                     CASE
                                        WHEN ' + CAST(@RULE_THRESHOLD AS NVARCHAR(100)) + ' <= ROUND((SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) THEN ''BELOW THRESHOLD''
                                        WHEN SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END) > 0 THEN ''FAIL''
                                        ELSE ''PASS''
                                     END AS DQ_RESULT,
                                     ''' + @RULE_SEVERITY + ''' AS RULE_SEVERITY, ''' + @RULE_DESCRIPTION + ''' AS RULE_DESCRIPTION, ' + CAST(@RULE_THRESHOLD AS NVARCHAR(100)) + ' AS RULE_THRESHOLD,
                                     COALESCE(SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END), 0) AS COUNT_OF_FAILED,
                                     COALESCE(SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 0 ELSE 1 END), 0) AS COUNT_OF_PASSED,
                                     COALESCE(ROUND((SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2), 0) AS PCT_OF_FAILED,
                                     COALESCE(ROUND((SUM(CASE WHEN ' + @RULE_VALIDATION_SCRIPT + ' THEN 0 ELSE 1 END) / COUNT(*)) * 100, 2), 0) AS PCT_OF_PASSED,
                                     CURRENT_TIMESTAMP AS AUDIT_TIMESTAMP
                              FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.' + @TABLE_NAME + ';';

        -- Execute error_script and result_script
        -- After constructing error_script and result_script
        PRINT 'Error Script: ';
        PRINT @error_script;

        PRINT 'Result Script: ';
        PRINT @result_script;

        -- Execute error_script and result_script
        -- EXECUTE sp_executesql @error_script;
        -- EXECUTE sp_executesql @result_script;


        FETCH NEXT FROM cursor_rule INTO @DQ_RULE_ID, @SUBJECT_AREA, @DATABASE_NAME, @SCHEMA_NAME, @TABLE_NAME, @COLUMN_NAME, @PRIMARY_KEY_COLUMN,
                                           @RULE_DESCRIPTION, @RULE_THRESHOLD, @RULE_CATEGORY, @RULE_SEVERITY, @RULE_VALIDATION_SCRIPT;
    END;

    CLOSE cursor_rule;
    DEALLOCATE cursor_rule;
END;
