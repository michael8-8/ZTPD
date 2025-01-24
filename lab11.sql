-- 1.

CREATE TABLE CYTATY AS
SELECT * FROM ZTPD.CYTATY;

-- 2.

SELECT AUTOR, TEKST FROM CYTATY
WHERE UPPER(TEKST) LIKE UPPER('%optymista%') 
OR UPPER(TEKST) LIKE UPPER('%pesymista%');

-- 3.

CREATE INDEX TEKST_INDEKS ON CYTATY(TEKST) 
INDEXTYPE IS CTXSYS.CONTEXT;

-- 4.

SELECT AUTOR, TEKST FROM CYTATY
WHERE CONTAINS(TEKST, 'optymista or pesymista') > 0;


-- 5.

SELECT AUTOR, TEKST FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista not optymista') > 0;

-- 6.

SELECT AUTOR, TEKST FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista and optymista') > 0
AND CONTAINS(TEKST, 'pesymista and optymista') < 3;

-- 7.

SELECT AUTOR, TEKST FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista and optymista') > 0
AND CONTAINS(TEKST, 'pesymista and optymista') < 10;

-- 8.

SELECT AUTOR, TEKST FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0;

-- 9.

SELECT AUTOR, TEKST, CONTAINS(TEKST, 'życi%') AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0;

-- 10.

SELECT AUTOR, TEKST, CONTAINS(TEKST, 'życi%') AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0
ORDER BY CONTAINS(TEKST, 'życi%') DESC
FETCH FIRST 1 ROWS ONLY;

-- 11.

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'fuzzy(probelm)') > 0;

-- 12.

INSERT INTO CYTATY VALUES (39, 'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;

-- 13.

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy') > 0;
-- indeks nie jest zaktualizowany

-- 14.

SELECT * FROM DR$TEKST_INDEKS$I;

-- 15.

DROP INDEX TEKST_INDEKS;
CREATE INDEX TEKST_INDEKS ON CYTATY(TEKST) 
INDEXTYPE IS CTXSYS.CONTEXT;

-- 16.

SELECT * FROM DR$TEKST_INDEKS$I;

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy') > 0;

-- 17.

DROP INDEX TEKST_INDEKS;
DROP TABLE CYTATY;

-- 1.

CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;

-- 2.

CREATE INDEX TEKST_INDEKS ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;

-- 3.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'work') > 0;

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, '$work') > 0;

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'working') > 0;

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, '$working') > 0;

-- 4.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'it') > 0;
-- nie jest to słowo, które niesie ze sobą jakąś przydatną informację, bardziej nadaje się na listę stopwords

-- 5.

SELECT * FROM CTX_STOPLISTS;
-- wykorzystywał default

-- 6.

SELECT * FROM CTX_STOPWORDS;

-- 7.

DROP INDEX TEKST_INDEKS;
CREATE INDEX TEKST_INDEKS ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');

-- 8.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'it') > 0;
-- teraz zwróciło wyniki

-- 9.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'fool and humans') > 0;

-- 10.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'fool and computer') > 0;

-- 11.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and humans) WITHIN SENTENCE', 1) > 0;
-- sekcja SENTENCE nie istnieje, czyli jakby cały tekst nie jest podzielony na zdania

-- 12.

DROP INDEX TEKST_INDEKS;

-- 13.

BEGIN
    ctx_ddl.create_section_group('sgnull', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('sgnull', 'SENTENCE');
    ctx_ddl.add_special_section('sgnull', 'PARAGRAPH');
END;

-- 14.

CREATE INDEX TEKST_INDEKS ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('section group sgnull');

-- 15.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and humans) WITHIN SENTENCE', 1) > 0;

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and computer) WITHIN SENTENCE', 1) > 0;

-- 16.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'humans') > 0;
-- tak, zwrócił, zakładam, że myślnik w non-humans powoduje zamieszanie w zwracanych wynikach

-- 17.

DROP INDEX TEKST_INDEKS;

begin
    ctx_ddl.create_preference('pref','BASIC_LEXER');
    ctx_ddl.set_attribute('pref','printjoins', '-');
end;

CREATE INDEX TEKST_INDEKS ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('LEXER pref');

-- 18.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'humans') > 0;
-- nie zwróciło non-humans

-- 19.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, 'non\-humans') > 0;

-- 20.

DROP TABLE QUOTES;
BEGIN
    CTX_DDL.DROP_SECTION_GROUP('sgnull');
    CTX_DDL.DROP_PREFERENCE('pref');
END;