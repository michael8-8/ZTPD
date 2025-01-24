-- 1.

CREATE TYPE samochod AS OBJECT (
 marka VARCHAR2(20),
 model VARCHAR2(20),
 kilometry NUMBER,
 data_produkcji DATE,
 cena NUMBER(10,2)
);

desc samochod

CREATE TABLE samochody
OF samochod;

INSERT INTO samochody VALUES
(NEW samochod('audi','tt',150000,
 DATE '2005-07-01',50000));
INSERT INTO samochody VALUES
(NEW samochod('toyota','supra',250000,
 DATE '1995-07-01',25000));
INSERT INTO samochody VALUES
(NEW samochod('vw','polo',120000,
 DATE '1999-07-01',30000));
 
select * from samochody;

-- 2.
 
 CREATE TABLE wlasciciele (
 imie VARCHAR2(100), nazwisko VARCHAR2(100),
 auto samochod);

desc wlasciciele

 INSERT INTO wlasciciele VALUES
('Ewa','Kowal',NEW samochod('mercedes','citan',170000,
 DATE '2007-07-01',70000));
INSERT INTO wlasciciele VALUES
('Jan','Nowak',NEW samochod('toyota','yaris',160000,
 DATE '2006-07-01',60000));
 
 select * from wlasciciele;

-- 3.
 
 ALTER TYPE samochod REPLACE AS OBJECT (
 marka VARCHAR2(20),
 model VARCHAR2(20),
 kilometry NUMBER,
 data_produkcji DATE,
 cena NUMBER(10,2),
 MEMBER FUNCTION wartosc RETURN NUMBER
 );
 
CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena*((0.9)**(EXTRACT (YEAR FROM CURRENT_DATE) -
            EXTRACT (YEAR FROM data_produkcji)));
    END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

-- 4.

ALTER TYPE samochod ADD MAP MEMBER FUNCTION ocen
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena*((0.9)**(EXTRACT (YEAR FROM CURRENT_DATE) -
            EXTRACT (YEAR FROM data_produkcji)));
    END wartosc;
    MAP MEMBER FUNCTION ocen RETURN NUMBER IS
    BEGIN
        RETURN (kilometry/10000) + (EXTRACT (YEAR FROM CURRENT_DATE) -
            EXTRACT (YEAR FROM data_produkcji));
    END ocen;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

-- 5.

CREATE TYPE wlasciciel AS OBJECT (
 imie VARCHAR2(30),
 nazwisko VARCHAR2(30)
);

desc wlasciciel

alter type samochod add attribute posiadacz REF wlasciciel cascade

select * from samochody;

CREATE TABLE wlascicieleREF OF wlasciciel;

INSERT INTO wlascicieleREF VALUES
(NEW wlasciciel('Ada','Adamska'));
INSERT INTO wlascicieleREF VALUES
(NEW wlasciciel('Basia','Basiamska'));

UPDATE samochody s
SET s.posiadacz = (
SELECT REF(w) FROM wlascicieleREF w
WHERE w.imie = 'Basia' );

SELECT s.marka, s.model, DEREF(s.posiadacz)
FROM samochody s;

-- 6.

DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
 moje_przedmioty(1) := 'MATEMATYKA';
 moje_przedmioty.EXTEND(9);
 FOR i IN 2..10 LOOP
 moje_przedmioty(i) := 'PRZEDMIOT_' || i;
 END LOOP;
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 moje_przedmioty.TRIM(2);
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.EXTEND();
 moje_przedmioty(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

-- 7.

DECLARE
 TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(50);
 moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
 moje_ksiazki(1) := 'Na Zachodzie bez zmian';
 moje_ksiazki.EXTEND(4);
 FOR i IN 2..5 LOOP
 moje_ksiazki(i) := 'Harry Potter ' || i;
 END LOOP;
 moje_ksiazki.TRIM(2);
 FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;

-- 8.

DECLARE
 TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
 moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
 moi_wykladowcy.EXTEND(2);
 moi_wykladowcy(1) := 'MORZY';
 moi_wykladowcy(2) := 'WOJCIECHOWSKI';
 moi_wykladowcy.EXTEND(8);
 FOR i IN 3..10 LOOP
 moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
 END LOOP;
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.TRIM(2);
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.DELETE(5,7);
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 moi_wykladowcy(5) := 'ZAKRZEWICZ';
 moi_wykladowcy(6) := 'KROLIKOWSKI';
 moi_wykladowcy(7) := 'KOSZLAJDA';
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- 9.

DECLARE
 TYPE t_miesiace IS TABLE OF VARCHAR2(20);
 miesiace t_miesiace := t_miesiace();
BEGIN
 miesiace.EXTEND(12);
 miesiace(1) := 'STYCZEN';
 miesiace(2) := 'LUTY';
 FOR i IN 3..12 LOOP
 miesiace(i) := 'MIESIAC_' || i;
 END LOOP;
 miesiace.DELETE(4,6);
 miesiace.DELETE(9);
 FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
 IF miesiace.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(miesiace(i));
 END IF;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
END;

-- 10.

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
 nazwa VARCHAR2(50),
 kraj VARCHAR2(30),
 jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
 numer NUMBER,
 egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

-- 11.

CREATE TYPE koszyk_produktow AS TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT (
 numer NUMBER,
 produkty koszyk_produktow );

CREATE TABLE zakupy OF zakup
NESTED TABLE produkty STORE AS tab_produkty;
INSERT INTO zakupy VALUES
(zakup(1,koszyk_produktow('CHLEB','MLEKO')));
INSERT INTO zakupy VALUES
(zakup(2,koszyk_produktow('MLEKO','JAJKA')));
INSERT INTO zakupy VALUES
(zakup(3,koszyk_produktow('RYBA','SOS')));
SELECT z.numer, p.*
FROM zakupy z, TABLE(z.produkty) p;

DELETE FROM zakupy 
WHERE numer IN(
SELECT z.numer
FROM zakupy z, TABLE ( z.produkty ) p
where p.column_value = 'MLEKO');

SELECT z.numer, p.*
FROM zakupy z, TABLE(z.produkty) p;

-- 12.

CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
 
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN dzwiek;
 END;
END;
/

CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
 
CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
 RETURN glosnosc||':'||dzwiek;
 END;
END;
/

CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
 
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;
/

DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
 dbms_output.put_line(tamburyn.graj);
 dbms_output.put_line(trabka.graj);
 dbms_output.put_line(trabka.graj('glosno'));
 dbms_output.put_line(fortepian.graj);
END;

-- 13.

CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
 
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
 
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
 RETURN 'upolowana ofiara: '||ofiara;
 END;
END;

DECLARE
 KrolLew lew := lew('LEW',4);
 InnaIstota istota := istota('JAKIES ZWIERZE'); --próba utworzenia instancji typu, który jest NOT INSTANTIABLE
BEGIN
 DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

-- 14.

DECLARE
 tamburyn instrument;
 cymbalki instrument;
 trabka instrument_dety;
 saksofon instrument_dety;
BEGIN
 tamburyn := instrument('tamburyn','brzdek-brzdek');
 cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
 trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
 --saksofon := instrument('saksofon','tra-taaaa'); --wyrażenie jest niewłaściwego typu
 --saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety); --błąd liczby lub wartości: nie można przypisać instancji supertypu do podtypu
END;

-- 15.

CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa'));
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );

SELECT i.nazwa, i.graj() FROM instrumenty i;



















