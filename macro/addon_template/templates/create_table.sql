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
COMMENT ON COLUMN user.name.created_by             IS 'WHOカラム(作成者ID)';
COMMENT ON COLUMN user.name.creation_date          IS 'WHOカラム(作成者日)';
COMMENT ON COLUMN user.name.last_updated_by        IS 'WHOカラム(最終更新者ID)';
COMMENT ON COLUMN user.name.last_update_date       IS 'WHOカラム(最終更新日)';
COMMENT ON COLUMN user.name.last_update_login      IS 'WHOカラム(最終ログインユーザーID)';
COMMENT ON COLUMN user.name.request_id             IS 'WHOカラム(要求ID)';
COMMENT ON COLUMN user.name.program_application_id IS 'WHOカラム(アプリケーションID)';
COMMENT ON COLUMN user.name.program_id             IS 'WHOカラム(プログラムID)';
COMMENT ON COLUMN user.name.program_update_date    IS 'WHOカラム(プログラム最終更新日)';
COMMENT ON COLUMN user.name.processing_date        IS 'プロセス日';
COMMENT ON COLUMN user.name.process_id             IS 'プロセスID';
COMMENT ON COLUMN user.name.id                     IS 'ID';
