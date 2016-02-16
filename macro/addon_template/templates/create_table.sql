REM *
REM *
REM * Create TABLE SQL Statement
REM *
REM * User
REM *   : user
REM * Name
REM *   : name
REM * Comment
REM *   : comment
REM *
REM *
CREATE TABLE user.name
(       created_by NUMBER
    ,   creation_date DATE NOT NULL
    ,   last_updated_by NUMBER
    ,   last_update_date DATE NOT NULL
    ,   last_update_login NUMBER
    ,   request_id NUMBER
    ,   program_application_id NUMBER
    ,   program_id NUMBER
    ,   program_update_date DATE
    ,   processing_date DATE
    ,   process_id NUMBER
    ,   id NUMBER
    ,   CONSTRAINT name_p PRIMARY KEY (id) USING INDEX TABLESPACE znx
)
TABLESPACE znd
STORAGE
    (   INITIAL            100K
        NEXT               100K
        MINEXTENTS         1
        MAXEXTENTS         UNLIMITED
        PCTINCREASE        0
    )
;
COMMENT ON TABLE  user.name                        IS 'comment';
COMMENT ON COLUMN user.name.created_by             IS 'WHO�J����(�쐬��ID)';
COMMENT ON COLUMN user.name.creation_date          IS 'WHO�J����(�쐬�ғ�)';
COMMENT ON COLUMN user.name.last_updated_by        IS 'WHO�J����(�ŏI�X�V��ID)';
COMMENT ON COLUMN user.name.last_update_date       IS 'WHO�J����(�ŏI�X�V��)';
COMMENT ON COLUMN user.name.last_update_login      IS 'WHO�J����(�ŏI���O�C�����[�U�[ID)';
COMMENT ON COLUMN user.name.request_id             IS 'WHO�J����(�v��ID)';
COMMENT ON COLUMN user.name.program_application_id IS 'WHO�J����(�A�v���P�[�V����ID)';
COMMENT ON COLUMN user.name.program_id             IS 'WHO�J����(�v���O����ID)';
COMMENT ON COLUMN user.name.program_update_date    IS 'WHO�J����(�v���O�����ŏI�X�V��)';
COMMENT ON COLUMN user.name.processing_date        IS '�v���Z�X��';
COMMENT ON COLUMN user.name.process_id             IS '�v���Z�XID';
COMMENT ON COLUMN user.name.id                     IS 'ID';
