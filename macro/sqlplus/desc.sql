Rem
Rem USAGE
Rem
Rem sqlplus -S -R 3 pahku001/pahku001ps@dev.cs.astome @c:\desc.sql desc zpo zpo_attributes @cs_nkb_tran.apps desc
Rem sqlplus -S -R 3 pahku001/pahku001ps@dev.cs.astome @c:\desc.sql desc pahku001 zpo_orders_v1 "" desc
Rem sqlplus -S -R 3 pahku001/pahku001ps@dev.cs.astome @"C:\Program Files\Hidemaru\macro\sqlplus\desc.sql" pahku001 zpo_orders_v1 "" src
Rem
set define on
set verify on
set feedback off
set serveroutput on size 1000000
set long 100000
set longchunksize 100000
set linesize 32767
set pagesize 50000
set tab off
set termout on
set trimspool on
DECLARE
    CURSOR c_all_tab_columns(
        p_owner VARCHAR2
    ,   p_table_name VARCHAR2
    )
    IS
    SELECT  *
    FROM    all_tab_columns&3
    WHERE   owner = p_owner
        AND table_name = p_table_name
    ORDER BY
            column_id
    ;
    l_mode VARCHAR2(30) := UPPER('&4');
    l_owner VARCHAR2(30) := UPPER('&1');
    l_table_name VARCHAR2(30) := UPPER('&2');
    l_object_name VARCHAR2(30) := UPPER('&2');
    l_database_link VARCHAR2(30) := UPPER('&3');
    l_current_comment VARCHAR2(4000);
    l_all_tab_columns all_tab_columns&3%ROWTYPE;
    l_all_tab_comments all_tab_comments&3%ROWTYPE;
    l_all_col_comments all_col_comments&3%ROWTYPE;
    g_TAB VARCHAR2(1) := CHR(9);

    FUNCTION table_name_full
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN LOWER(l_owner || '.' || l_table_name || l_database_link);
    END;

    PROCEDURE log(i_log IN VARCHAR2 DEFAULT NULL)
    IS
        PROCEDURE put_line
        IS
            l_spos PLS_INTEGER DEFAULT 1;
        BEGIN
            WHILE l_spos < LENGTH(i_log) LOOP
                DBMS_OUTPUT.put_line(SUBSTR(i_log, l_spos, 125));
                l_spos := l_spos + 125;
            END LOOP;
        END;
    BEGIN
        IF i_log IS NULL THEN
            DBMS_OUTPUT.new_line;
            RETURN;
        END IF;
        DBMS_OUTPUT.put_line(i_log);
    EXCEPTION
    WHEN OTHERS THEN
        put_line;
    END;

    PROCEDURE find_table_comment
    IS
    BEGIN
        SELECT  *
        INTO    l_all_tab_comments
        FROM    all_tab_comments&3
        WHERE   owner = l_owner
            AND table_name = l_table_name
        ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    PROCEDURE find_column_commnets
    IS
    BEGIN
        SELECT  *
        INTO    l_all_col_comments
        FROM    all_col_comments&3
        WHERE   owner = l_owner
            AND table_name = l_table_name
            AND column_name = l_all_tab_columns.column_name
        ;
        l_current_comment := l_all_col_comments.comments;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_current_comment := NULL;
    END;

    FUNCTION remove_crlf_from_comments
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE(REPLACE(l_current_comment, CHR(10)), CHR(13));
    END;

    FUNCTION add_comment
    RETURN VARCHAR2
    IS
    BEGIN
        IF l_current_comment IS NULL THEN
            RETURN NULL;
        END IF;
        RETURN ' -- ' || remove_crlf_from_comments;
    END;

    PROCEDURE describe_columns
    IS
        FUNCTION get_column_name
        RETURN VARCHAR2
        IS
        BEGIN
            RETURN LOWER('l_' || l_table_name || '.' || l_all_tab_columns.column_name);
        END;

        FUNCTION get_data_type
        RETURN VARCHAR2
        IS
            FUNCTION get_data_length
            RETURN VARCHAR2
            IS
                l_length VARCHAR2(4000) DEFAULT NULL;
                FUNCTION get_number_length
                RETURN VARCHAR
                IS
                    l_string VARCHAR2(4000) DEFAULT NULL;
                BEGIN
                    IF l_all_tab_columns.data_precision IS NOT NULL THEN
                        l_string := l_all_tab_columns.data_precision;
                        IF l_all_tab_columns.data_scale IS NOT NULL THEN
                            l_string := l_string || ',' || l_all_tab_columns.data_scale;
                        END IF;
                    END IF;
                    RETURN l_string;
                END;
                FUNCTION get_char_length
                RETURN VARCHAR2
                IS
                BEGIN
                    RETURN l_all_tab_columns.data_length;
                END;
            BEGIN
                IF l_all_tab_columns.data_type = 'NUMBER' THEN
                    l_length := get_number_length;
                ELSIF l_all_tab_columns.data_type IN ('CHAR', 'NCHAR', 'VARCHAR2', 'NVARCHAR2') THEN
                    l_length := get_char_length;
                END IF;

                IF l_length IS NOT NULL THEN
                    RETURN '(' || l_length  || ')';
                END IF;
                RETURN NULL;
            END;
        BEGIN
            RETURN l_all_tab_columns.data_type || get_data_length;
        END;

        PROCEDURE describe_columns
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            FOR r_all_tab_columns IN c_all_tab_columns(l_owner, l_table_name) LOOP
                l_all_tab_columns := r_all_tab_columns;
                find_column_commnets;
                l_describe := 'rem ' || RPAD(get_column_name, 63) || RPAD(get_data_type, 30) || add_comment;
                log(l_describe);
            END LOOP;
        END;

        PROCEDURE describe_header
        IS
            l_describe VARCHAR2(4000) := 'rem ' || table_name_full;
        BEGIN
            find_table_comment;
            IF l_all_tab_comments.comments IS NOT NULL THEN
                l_describe := l_describe || ' -- ' || l_all_tab_comments.comments;
            END IF;
            log(l_describe);
        END;
    BEGIN
        describe_header;
        describe_columns;
    END;

    PROCEDURE describe_select_statement
    IS
        FUNCTION first_column
        RETURN BOOLEAN
        IS
        BEGIN
            RETURN l_all_tab_columns.column_id = 1;
        END;

        PROCEDURE describe_column
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            IF first_column THEN
                l_describe := 'SELECT  ';
            ELSE
                l_describe := g_TAB || ',   ';
            END IF;
            l_describe := l_describe || RPAD(LOWER(l_all_tab_columns.column_name), 30) || add_comment;
            log(l_describe);
        END;

        PROCEDURE describe_columns
        IS
        BEGIN
            FOR r_all_tab_columns IN c_all_tab_columns(l_owner, l_table_name) LOOP
                l_all_tab_columns := r_all_tab_columns;
                find_column_commnets;
                describe_column;
            END LOOP;
        END;

        PROCEDURE describe_table
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            log('FROM    ' || table_name_full);
        END;

        PROCEDURE describe_header
        IS
            l_describe VARCHAR2(4000) := 'rem ' || table_name_full;
        BEGIN
            find_table_comment;
            IF l_all_tab_comments.comments IS NOT NULL THEN
                l_describe := l_describe || ' -- ' || l_all_tab_comments.comments;
            END IF;
            log(l_describe);
        END;
    BEGIN
        describe_header;
        describe_columns;
        describe_table;
    END;

    PROCEDURE describe_insert_statement
    IS
        FUNCTION first_column
        RETURN BOOLEAN
        IS
        BEGIN
            RETURN l_all_tab_columns.column_id = 1;
        END;

        PROCEDURE describe_column
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            IF first_column THEN
                l_describe := '(       ';
            ELSE
                l_describe := g_TAB || ',   ';
            END IF;
            l_describe := l_describe || RPAD(LOWER(l_all_tab_columns.column_name), 30) || add_comment;
            log(l_describe);
        END;

        PROCEDURE describe_value
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            IF first_column THEN
                l_describe := '(       ';
            ELSE
                l_describe := g_TAB || ',   ';
            END IF;
            l_describe := l_describe || 'l_' || LOWER(l_table_name || '.' || RPAD(l_all_tab_columns.column_name, 30)) || add_comment;
            log(l_describe);
        END;

        PROCEDURE describe_columns
        IS
        BEGIN
            FOR r_all_tab_columns IN c_all_tab_columns(l_owner, l_table_name) LOOP
                l_all_tab_columns := r_all_tab_columns;
                find_column_commnets;
                describe_column;
            END LOOP;
            log(')');
        END;

        PROCEDURE describe_values
        IS
        BEGIN
            log('VALUES');
            FOR r_all_tab_columns IN c_all_tab_columns(l_owner, l_table_name) LOOP
                l_all_tab_columns := r_all_tab_columns;
                find_column_commnets;
                describe_value;
            END LOOP;
            log(');');
        END;

        PROCEDURE describe_header
        IS
            l_describe VARCHAR2(4000) := 'INSERT INTO ' || table_name_full;
        BEGIN
            find_table_comment;
            IF l_all_tab_comments.comments IS NOT NULL THEN
                l_describe := l_describe || ' -- ' || l_all_tab_comments.comments;
            END IF;
            log(l_describe);
        END;

    BEGIN
        describe_header;
        describe_columns;
        describe_values;
    END;

    PROCEDURE describe_update_statement
    IS
        FUNCTION first_column
        RETURN BOOLEAN
        IS
        BEGIN
            RETURN l_all_tab_columns.column_id = 1;
        END;

        PROCEDURE describe_column
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            IF first_column THEN
                l_describe := 'SET     ';
            ELSE
                l_describe := g_TAB || ',   ';
            END IF;
            l_describe := l_describe || RPAD(LOWER(l_all_tab_columns.column_name), 31) || '= '
                                     || LOWER('l_' || l_table_name || '.' || RPAD(l_all_tab_columns.column_name, 30)) || add_comment;
            log(l_describe);
        END;

        PROCEDURE describe_columns
        IS
        BEGIN
            FOR r_all_tab_columns IN c_all_tab_columns(l_owner, l_table_name) LOOP
                l_all_tab_columns := r_all_tab_columns;
                find_column_commnets;
                describe_column;
            END LOOP;
        END;

        PROCEDURE describe_where
        IS
            l_describe VARCHAR2(4000);
        BEGIN
            log('WHERE   CURRENT OF c1');
        END;

        PROCEDURE describe_header
        IS
            l_describe VARCHAR2(4000) := 'UPDATE  ' || table_name_full;
        BEGIN
            find_table_comment;
            IF l_all_tab_comments.comments IS NOT NULL THEN
                l_describe := l_describe || ' -- ' || l_all_tab_comments.comments;
            END IF;
            log(l_describe);
        END;

    BEGIN
        describe_header;
        describe_columns;
        describe_where;
    END;

    PROCEDURE describe_source
    IS
        CURSOR  c_all_objects
        IS
        SELECT  *
        FROM    all_objects&3
        WHERE   owner = l_owner
            AND object_name = l_table_name
        ;

        PROCEDURE initialize
        IS
        BEGIN
            DBMS_METADATA.set_transform_param
            (   transform_handle => DBMS_METADATA.session_transform
            ,   name => 'SQLTERMINATOR'
            ,   value => TRUE
            );

            DBMS_METADATA.set_transform_param
            (
                transform_handle => DBMS_METADATA.session_transform
            ,   name => 'SEGMENT_ATTRIBUTES'
            ,   value => TRUE
            );

            DBMS_METADATA.set_transform_param
            (   transform_handle => DBMS_METADATA.session_transform
            ,   name => 'STORAGE'
            ,   value => TRUE
            );

            DBMS_METADATA.set_transform_param
            (
                transform_handle => DBMS_METADATA.session_transform
            ,   name => 'TABLESPACE'
            ,   value => TRUE
            );

            DBMS_METADATA.set_transform_param
            (   transform_handle => DBMS_METADATA.session_transform
            ,   name => 'CONSTRAINTS'
            ,   value => TRUE
            );

            DBMS_METADATA.set_transform_param
            (   transform_handle => DBMS_METADATA.session_transform
            ,   name => 'CONSTRAINTS_AS_ALTER'
            ,   value => TRUE
            );
        END;

        PROCEDURE describe
        IS
            CURSOR c_all_objects
            (   p_owner VARCHAR2
            ,   p_object_name VARCHAR2
            )
            IS
            SELECT  *
            FROM    all_objects&3
            WHERE   owner = p_owner
                AND object_name = p_object_name
                AND object_type IN
                        (   'DIRECTORY'
                        ,   'FUNCTION'
                        ,   'INDEX'
                        ,   'MATERIALIZED VIEW'
                        ,   'PACKAGE'
                        ,   'PROCEDURE'
                        ,   'SEQUENCE'
                        ,   'SYNONYM'
                        ,   'TABLE'
                        ,   'TRIGGER'
                        ,   'TYPE'
                        ,   'TYPE BODY'
                        ,   'VIEW'
                        )
            ORDER BY
                    object_type
            ;
            l_all_objects c_all_objects%ROWTYPE;
            PROCEDURE describe_ddl
            IS
                l_ddl CLOB;
                l_clob_len INTEGER;
                l_spos INTEGER;
                l_epos INTEGER;
                FUNCTION get_epos
                RETURN INTEGER
                IS
                BEGIN
                    RETURN DBMS_LOB.instr(l_ddl, CHR(10), l_spos);
                END;
                FUNCTION get_line
                RETURN VARCHAR2
                IS
                    l_length INTEGER;
                BEGIN
                    IF l_epos > 0 THEN
                        l_length := l_epos - l_spos;
                    ELSE
                        l_length := l_clob_len - l_spos + 1;
                    END IF;
                    RETURN DBMS_LOB.substr(l_ddl, l_length, l_spos);
                END;
            BEGIN
                log(l_all_objects.object_type || ' ' || l_all_objects.owner || '.' || l_all_objects.object_name);
                l_ddl := DBMS_METADATA.get_ddl(l_all_objects.object_type, l_all_objects.object_name, l_all_objects.owner);
                l_clob_len := DBMS_LOB.getlength(l_ddl);
                l_spos := 1;
                l_epos := get_epos;
                WHILE l_epos > 0 LOOP
                    log('--' || get_line);
                    l_spos := l_epos + 1;
                    l_epos := get_epos;
                END LOOP;
                log('' || get_line);
            END;
        BEGIN
            FOR r_all_objects IN c_all_objects(l_owner, l_object_name) LOOP
                l_all_objects := r_all_objects;
                describe_ddl;
            END LOOP;
        END;
    BEGIN
        initialize;
        describe;
    END;
BEGIN
    CASE
    WHEN l_mode  IN ('DESC', 'DESCRIBE') THEN
        describe_columns;
    WHEN l_mode  IN ('SEL', 'SELECT') THEN
        describe_select_statement;
    WHEN l_mode  IN ('INS', 'INSERT') THEN
         describe_insert_statement;
    WHEN l_mode  IN ('UPD', 'UPDATE') THEN
         describe_update_statement;
    WHEN l_mode  IN ('SRC', 'SOURCE') THEN
         describe_source;
    END CASE;
END;
/
EXIT;
