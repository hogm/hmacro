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
        -- TODO : ���C���J�[�\����錾
        CURSOR c_source -- �J�[�\�����͕�����₷���I
        IS
        SELECT  *
        FROM    source
        WHERE   status_code IN ('PENDING', 'RETRY')
        ORDER BY
                source_id
        FOR UPDATE -- �s���b�N�ł���Ƃ���FOR UPDATE���g���ƃJ�[�\���I�[�v�����̌��q�����ۂ����I
        ;

        l_source c_source%ROWTYPE; -- �J�[�\���ϐ����e�v���V�[�W���Ŏg�p���邽�߂̈ꎞ�ϐ�

        -- TODO : ���ʂ��J�[�\�����Ƀt�B�[�h�o�b�N����v���V�[�W��
        -- �������ʂ����C���J�[�\���Ƀt�B�[�h�o�b�N���Ă�����΃g���[�T�r���e�B�̌���ɁI
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

        -- TODO : �����������s���v���V�[�W��
        PROCEDURE initialize
        IS
        BEGIN
            zn_helper.set_mark('main_process->initialize');

            -- TODO : zn_helper.set_status��last_status�ɐݒ肳���l��ݒ�
            -- �f�t�H���g�ŉ��L���ݒ肳��Ă���B
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

        -- TODO : �ϐ��̏�����
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
            ); -- ���ݏ������̃��R�[�hID(���ʉ\�ȕ�����)��ݒ�
            initialize_variables;
            l_source := r_source; -- �ÖكJ�[�\���ϐ��̃X�R�[�v�ł͊e�v���V�[�W���ŎQ�Ƃł��Ȃ����߃��[�J���ϐ��ɐݒ�
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
        -- TODO : �A�h�I������啶���Őݒ�
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
        -- TODO �p���s�\�Ȓv���I�G���[�����������ꍇ�ɃG���[��ߑ����������I������
        terminate_fatal;
    WHEN OTHERS THEN
        -- TODO �R���J�����g���s�̂��ߌĂяo�����ɃG���[��ʒm����K�v�����邽��OTHERS�őS�Ă̗�O���L���b�`���ďI������
        zn_helper.set_last_message(SQLERRM);
        zn_helper.show_errors;
        terminate_fatal;
    END;
END;
/
