-- 1.

CREATE TABLE movies AS SELECT * FROM ZTPD.MOVIES;

-- 2.

DESC movies;
SELECT * FROM movies;

-- 3.

SELECT id, title FROM movies WHERE cover IS NULL;

-- 4.

SELECT id, title, dbms_lob.getlength(cover) AS FILESIZE FROM movies WHERE cover IS NOT NULL;

-- 5.

SELECT id, title, dbms_lob.getlength(cover) AS FILESIZE FROM movies WHERE cover IS NULL;

-- 6.

SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'TPD_DIR';

-- 7.

UPDATE movies SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg' WHERE id = 66;
COMMIT;

-- 8.

SELECT id, title, dbms_lob.getlength(cover) AS FILESIZE FROM movies WHERE id IN (65, 66);

-- 9.

DECLARE
    bplik BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
    pob BLOB;
BEGIN
    SELECT cover INTO pob
    FROM movies
    WHERE id = 66
    FOR UPDATE;
    dbms_lob.fileopen(bplik);
    dbms_lob.loadfromfile(pob, bplik, dbms_lob.getlength(bplik));    
    dbms_lob.fileclose(bplik);
    COMMIT;
END;

-- 10.

CREATE TABLE TEMP_COVERS (
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

-- 11.

INSERT INTO TEMP_COVERS VALUES(65, BFILENAME('TPD_DIR', 'escape.jpg'), 'image/jpeg');
COMMIT;

-- 12.

SELECT movie_id, dbms_lob.getlength(image) AS FILESIZE FROM TEMP_COVERS;

-- 13.

DECLARE
    bplik BFILE;
    pob BLOB;
    mime VARCHAR2(50);
BEGIN
    SELECT mime_type, image INTO mime, bplik
    FROM TEMP_COVERS
    WHERE movie_id = 65; 
    dbms_lob.createtemporary(pob, TRUE);
    dbms_lob.fileopen(bplik);
    dbms_lob.loadfromfile(pob, bplik, dbms_lob.getlength(bplik));    
    dbms_lob.fileclose(bplik);
    UPDATE movies SET cover = pob, mime_type = mime WHERE id = 65;
    dbms_lob.freetemporary(pob);
    COMMIT;
END;

-- 14.

SELECT id AS MOVIE_ID, dbms_lob.getlength(cover) AS FILESIZE FROM movies WHERE id IN (65, 66);

-- 15.

DROP TABLE movies;