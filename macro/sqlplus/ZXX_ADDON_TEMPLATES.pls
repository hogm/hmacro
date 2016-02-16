CREATE OR REPLACE PACKAGE apps.package_name
IS
    PROCEDURE main(
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2
    );
END;
/
