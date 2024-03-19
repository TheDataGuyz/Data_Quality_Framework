INSERT INTO PRODUCT.SECURITY.DQ_RULE (
    SUBJECT_AREA,
    DATABASE_NAME,
    SCHEMA_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    PRIMARY_KEY_COLUMN,
    RULE_CATEGORY,
    RULE_THRESHOLD,
    RULE_SEVERITY,
    RULE_DESCRIPTION,
    RULE_VALIDATION_SCRIPT,
    DQ_ACTIVE_FG,
    RULE_TYPE
)
VALUES (
    'PRODUCT',
    'PRODUCT',
    'dbo',
    'Orders',
    'ShipRegion',
    'OrderID', -- Assuming OrderID is the primary key
    'DQ1',
    1, -- Set threshold to 1 since ShipRegion should not be null
    'High',
    'Check if ShipRegion is not null',
    'ShipRegion IS NOT NULL', -- Validation script to check if ShipRegion is not null
    '1', -- Active flag
    'Data Quality Rule'
);
