INSERT INTO PRODUCT.SECURITY.DQ_RULE (
    SUBJECT_AREA,
    DATABASE_NAME,
    SCHEMA_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    PRIMARY_KEY_COLUMN,
	PII_FLAG,
    RULE_TYPE,
    RULE_CATEGORY,
    RULE_THRESHOLD,
    RULE_SEVERITY,
    RULE_DESCRIPTION,
    RULE_VALIDATION_SCRIPT,
    DQ_ACTIVE_FG
)
VALUES (
    'PRODUCT',
    'PRODUCT',
    'dbo',
    'Orders',
    'ShipRegion',
    'OrderID', -- OrderID is the primary key
	'N',
    'DQ1',
    'CATEGORY1',
    0, -- Set threshold to 0 since ShipRegion should not be null
    'High',
    'ShipRegion should not be null',
    'ShipRegion IS NULL', -- Validation script to check if ShipRegion is not null
    '1' -- Active flag
);

INSERT INTO PRODUCT.SECURITY.DQ_RULE (
    SUBJECT_AREA,
    DATABASE_NAME,
    SCHEMA_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    PRIMARY_KEY_COLUMN,
	PII_FLAG,
    RULE_TYPE,
    RULE_CATEGORY,
    RULE_THRESHOLD,
    RULE_SEVERITY,
    RULE_DESCRIPTION,
    RULE_VALIDATION_SCRIPT,
    DQ_ACTIVE_FG
)
VALUES (
    'PRODUCT',
    'PRODUCT',
    'dbo',
    '[Order Details]',
    'ProductID,UnitPrice',
    'OrderID', -- OrderID is the primary key
	'N',
    'DQ1',
    'CATEGORY1',
    0, -- Set threshold to 0
    'High',
    'ProductID and UnitPrice should not be null',
    'ProductID IS NULL OR UnitPrice IS NULL', -- Validation script to check if ShipRegion is not null
    '1' -- Active flag
);


