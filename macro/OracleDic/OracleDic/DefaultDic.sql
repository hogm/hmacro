SELECT  DISTINCT dictionary_item
FROM    (
            SELECT  LOWER(
                        CASE
                        WHEN object_type = 'DATABASE LINK' THEN
                            '@' || object_name
                        ELSE
                            object_name
                        END
                    )                                                           dictionary_item

            FROM    user_objects
            WHERE   object_type IN  (   'TABLE'
                                    ,   'VIEW'
                                    ,   'FUNCTION'
                                    ,   'PROCEDURE'
                                    ,   'DATABASE LINK'
                                    ,   'SYNONYM'
                                    ,   'SEQUENCE'
                                    )
            UNION ALL
            SELECT  LOWER(column_name)                                          dictionary_item
            FROM    user_tab_columns
        )
ORDER BY 1