CREATE OR REPLACE PACKAGE BODY apps.package_name
/*..5....10...15...20...25...30...35...40...45...50...55...60...65...70.
* ======================================================================
*
*   NAME
*       package_name
*
*   DESCRIPTION
*       description
*
*   HISTORY
*       1.00  yyyy/mm/dd  author
*
* =====================================================================*/
IS
    PROCEDURE main_process
    IS
        -- TODO : メインカーソルを宣言
        CURSOR c_source -- カーソル名は分かりやすく！
        IS
        SELECT  *
        FROM    source
        WHERE   status_code IN ('PENDING', 'RETRY')
        ORDER BY
                source_id
        FOR UPDATE -- 行ロックできるときはFOR UPDATEを使うとカーソルオープン中の原子性が保たれる！
        ;

        l_source c_source%ROWTYPE; -- カーソル変数を各プロシージャで使用するための一時変数

        -- TODO : 結果をカーソル等にフィードバックするプロシージャ
        -- 処理結果をメインカーソルにフィードバックしておければトレーサビリティの向上に！
        PROCEDURE feedback_status
        IS
        BEGIN
            zn_helper.set_mark('main_process->feedback_status');
            UPDATE  source
            SET     last_update_date = SYSDATE
                ,   last_updated_by = fnd_global.user_id
                ,   last_update_login = fnd_global.login_id
                ,   request_id = fnd_global.conc_request_id
                ,   program_application_id = fnd_global.prog_appl_id
                ,   program_id = fnd_global.conc_program_id
                ,   process_id = zn_global.process_id
                ,   status_code = zn_helper.get_last_status
                ,   message = zn_helper.get_last_message
            WHERE   CURRENT OF c_source
            ;
        END;

        -- TODO : 初期処理を行うプロシージャ
        PROCEDURE initialize
        IS
        BEGIN
            zn_helper.set_mark('main_process->initialize');

            -- TODO : zn_helper.set_statusでlast_statusに設定される値を設定
            -- デフォルトで下記が設定されている。
            -- zn_helper.g_success_status := zn_helper.SUCCESS;
            -- zn_helper.g_warning_status := zn_helper.WARNING;
            -- zn_helper.g_error_status := zn_helper.ERROR;
            -- zn_helper.g_fatal_status := zn_helper.FATAL;
            -- zn_helper.g_retry_status := zn_helper.RETRY;
            -- zn_helper.g_skip_status := zn_helper.SKIP;
        END;

        PROCEDURE save
        IS
            l_result result%ROWTYPE;

            PROCEDURE edit_attributes
            IS
            BEGIN
                zn_helper.set_mark('main_process->edit_and_save_values->edit_attributes');
                l_result.last_update_date       := SYSDATE;
                l_result.last_updated_by        := fnd_global.user_id;
                l_result.creation_date          := SYSDATE;
                l_result.created_by             := fnd_global.user_id;
                l_result.last_update_login      := fnd_global.login_id;
                l_result.request_id             := fnd_global.conc_request_id;
                l_result.program_application_id := fnd_global.prog_appl_id;
                l_result.program_id             := fnd_global.conc_program_id;
                l_result.program_update_date    := SYSDATE;
                l_result.process_id             := zn_global.process_id;
            END;

            PROCEDURE save_attributes
            IS
            BEGIN
                zn_helper.set_mark('main_process->edit_and_save_values->save_attributes');
                INSERT INTO result VALUES l_result;
            EXCEPTION
            WHEN DUP_VAL_ON_INDEX OR VALUE_ERROR THEN
                zn_helper.raise_warn('( main_process->save->save_attributes ) : ' || SQLERRM);
            END;
        BEGIN
            edit_attributes;
            save_attributes;
        END;

        PROCEDURE validates
        IS
        BEGIN
            NULL;
        END;

        PROCEDURE finds
        IS
            l_mtl_parameters mtl_parameters%ROWTYPE;
            FUNCTION find_mtl_parameter(
                p_organization_code IN mtl_parameters.organization_code%TYPE
            )
            RETURN mtl_parameters%ROWTYPE
            IS
                l_result mtl_parameters%ROWTYPE;
            BEGIN

                SELECT  *
                INTO    l_result
                FROM    mtl_parameters
                WHERE   organization_code = p_organization_code
                ;

                RETURN l_result;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                zn_helper.raise_warn(
                    '( main_process->finds->find_mtl_parameter ) : ' ||
                    'organization_code => [ ' || p_organization_code || ' ] ' ||
                    SQLERRM
                );
            END;
        BEGIN
            l_mtl_parameters :=
                find_mtl_parameter(
                    p_organization_code => l_zpo_requisitions_if.organization_code
                );
        END;

        -- TODO : 変数の初期化
        PROCEDURE initialize_variables
        IS
        BEGIN
            zn_helper.set_mark('main_process->initialize_variables');
            zn_helper.reset_current_status;
            l_source := NULL;
        END;
    BEGIN
        zn_helper.set_mark('main_process');

        initialize;

        FOR r_source IN c_source LOOP
            zn_helper.push_id(
                'source_id => [ ' || r_source.source_id || ' ]'
            ); -- 現在処理中のレコードID(識別可能な文字列)を設定
            initialize_variables;
            l_source := r_source; -- 暗黙カーソル変数のスコープでは各プロシージャで参照できないためローカル変数に設定
            BEGIN
                finds;
                validates;
                save;
                zn_helper.set_status;
            EXCEPTION
            WHEN zn_helper.RETRY_RAISED THEN
                NULL;
            WHEN zn_helper.SKIP_RAISED THEN
                NULL;
            WHEN zn_helper.WARN_RAISED THEN
                NULL;
            WHEN zn_helper.ERROR_RAISED THEN
                NULL;
            WHEN zn_helper.FATAL_RAISED THEN
                feedback_status;
                RAISE;
            END;
            feedback_status;
            zn_helper.pop_id;
        END LOOP;
        zn_helper.clear_id;
    END;

    PROCEDURE main(
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2
    )
    AS
        -- TODO : アドオン名を大文字で設定
        PROGRAM_ID CONSTANT zn_helper.program_id_type := 'package_name';
        PROCEDURE terminate_fatal
        IS
        BEGIN
            errbuf := zn_helper.get_last_message;
            retcode := zn_helper.ERROR;
            ROLLBACK;
            zn_helper.print_id('last processed information');
            zn_logger.log('last marked information : ' || zn_helper.get_mark);
            zn_logger.log('last message : ' || zn_helper.get_last_message);
            zn_helper.terminate;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;
    BEGIN
        zn_helper.initialize(PROGRAM_ID);

        main_process;

        zn_helper.print_counted_each_status('The results of processed.');

        zn_helper.terminate(zn_helper.ERROR);

        retcode := zn_helper.get_result;
    EXCEPTION
    WHEN zn_helper.FATAL_RAISED THEN
        -- TODO 継続不能な致命的エラーが発生した場合にエラーを捕捉し処理を終了する
        terminate_fatal;
    WHEN OTHERS THEN
        -- TODO コンカレント実行のため呼び出し元にエラーを通知する必要があるためOTHERSで全ての例外をキャッチして終了する
        zn_helper.set_last_message(SQLERRM);
        zn_helper.show_errors;
        terminate_fatal;
    END;
END;
/
