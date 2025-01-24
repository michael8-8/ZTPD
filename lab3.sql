-- 1.

CREATE TABLE DOKUMENTY (
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

-- 2.

DECLARE
    tekst CLOB;
BEGIN
    tekst := '';
    FOR i IN 1..10000 LOOP
        tekst := tekst || 'Oto tekst. ';
    END LOOP;
    INSERT INTO DOKUMENTY VALUES (1, tekst);
END;

-- 3.

SELECT * FROM DOKUMENTY;
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT dbms_lob.getlength(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT dbms_lob.substr(DOKUMENT, 1000, 5) FROM DOKUMENTY;

-- 4.

INSERT INTO DOKUMENTY VALUES (2, EMPTY_CLOB());

-- 5.

INSERT INTO DOKUMENTY VALUES (3, NULL);
COMMIT;

-- 6.

SELECT * FROM DOKUMENTY;
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT dbms_lob.getlength(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT dbms_lob.substr(DOKUMENT, 1000, 5) FROM DOKUMENTY;

-- 7.

DECLARE
    bplik BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    clo CLOB;
    dest_offset NUMBER := 1;
    src_offset NUMBER := 1;
    bfile_csid NUMBER := 0;
    lang_contex NUMBER := 0;
    warn NUMBER := null;
BEGIN
    SELECT DOKUMENT INTO clo
    FROM DOKUMENTY
    WHERE ID = 2
    FOR UPDATE;
    dbms_lob.fileopen(bplik);
    dbms_lob.loadclobfromfile(clo, bplik, dbms_lob.getlength(bplik), dest_offset, src_offset, bfile_csid, lang_contex, warn);    
    dbms_lob.fileclose(bplik);
    COMMIT;
    dbms_output.put_line(warn);
END;

-- 8.

UPDATE DOKUMENTY SET DOKUMENT = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt')) WHERE ID = 3;

-- 9.

SELECT * FROM DOKUMENTY;

-- 10.

SELECT ID, dbms_lob.getlength(DOKUMENT) FROM DOKUMENTY;

-- 11.

DROP TABLE DOKUMENTY;

-- 12.

CREATE OR REPLACE PROCEDURE CLOB_CENSOR(clo IN OUT CLOB, tekst VARCHAR2) IS
    offset NUMBER := 1;
    dots VARCHAR2(32767);
BEGIN
    dots := RPAD('.', LENGTH(tekst), '.');  
    LOOP
        offset := dbms_lob.INSTR(LOB_LOC  => clo, PATTERN  => tekst, OFFSET  => 1, NTH  => 1);
        EXIT WHEN offset = 0;                        
        dbms_lob.write(clo, LENGTH(tekst), offset, dots);   
    END LOOP;          
    dbms_output.put_line(clo);   
END;
/

-- 13.

CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZTPD.BIOGRAPHIES;
SELECT * FROM BIOGRAPHIES;
/
DECLARE
    bio CLOB;
BEGIN
    SELECT BIO INTO bio
    FROM BIOGRAPHIES
    FOR UPDATE;
    CLOB_CENSOR(bio, 'Cimrman');
    COMMIT;
END;
/
SELECT * FROM BIOGRAPHIES;

-- 14.

DROP TABLE BIOGRAPHIES;