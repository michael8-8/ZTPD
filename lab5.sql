-- 1A

INSERT INTO USER_SDO_GEOM_METADATA
VALUES ('FIGURY','KSZTALT', MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 0, 10, 0.01),
    MDSYS.SDO_DIM_ELEMENT('Y', 0, 8, 0.01) ),
    null
);

-- 1B

SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(NUMBER_OF_GEOMS  => 3000000,
                                   DB_BLOCK_SIZE  => 8192,
                                   SDO_RTR_PCTFREE  => 10,
                                   NUM_DIMENSIONS  => 2,
                                   IS_GEODETIC  => 0)
FROM FIGURY;

-- 1C

CREATE INDEX indeks_rdrzewo ON FIGURY(KSZTALT) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- 1D

select ID from FIGURY
where SDO_FILTER(KSZTALT,
    SDO_GEOMETRY(2001,null,
        SDO_POINT_TYPE(3,3,null), null,null)) = 'TRUE';

-- wynik nie odpowiada rzeczywistości, bo wykorzystuje jedynie pierwszą fazę zapytania - zwraca zbiór kandydatów

-- 1E

select ID from FIGURY
where SDO_RELATE(KSZTALT,
    SDO_GEOMETRY(2001,null,
        SDO_POINT_TYPE(3,3,null), null,null), 'mask=ANYINTERACT') = 'TRUE';

-- wynik odpowiada rzeczywistości

-- 2A

select GEOM from MAJOR_CITIES where CITY_NAME = 'Warsaw';

select M.CITY_NAME as MIASTO, SDO_NN_DISTANCE(1) ODL
from MAJOR_CITIES M
where SDO_NN(GEOM,MDSYS.SDO_GEOMETRY(2001, 8307, null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1, 1, 1),
        MDSYS.SDO_ORDINATE_ARRAY(21.0118794,52.2449452)),
    'sdo_num_res=10 unit=km',1) = 'TRUE' and M.CITY_NAME <> 'Warsaw';

-- 2B

select M.CITY_NAME as MIASTO
from MAJOR_CITIES M
where SDO_WITHIN_DISTANCE(M.GEOM,
    SDO_GEOMETRY(2001, 8307, null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1, 1, 1),
        MDSYS.SDO_ORDINATE_ARRAY(21.0118794,52.2449452)),
    'distance=100 unit=km') = 'TRUE' and M.CITY_NAME <> 'Warsaw';

-- 2C

select CB.CNTRY_NAME as KRAJ, MC.CITY_NAME
from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC
where SDO_RELATE(MC.GEOM, CB.GEOM, 'mask=INSIDE') = 'TRUE' and CB.CNTRY_NAME = 'Slovakia';

-- 2D

select CB2.CNTRY_NAME as PANSTWO, SDO_GEOM.SDO_DISTANCE(CB1.GEOM, CB2.GEOM, 1, 'unit=km') ODL
from COUNTRY_BOUNDARIES CB1, COUNTRY_BOUNDARIES CB2
where CB1.CNTRY_NAME = 'Poland' and CB2.CNTRY_NAME <> 'Poland'
and not SDO_RELATE(CB1.GEOM, CB2.GEOM, 'mask=TOUCH') = 'TRUE';

-- 3A

select CB2.CNTRY_NAME, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(CB1.GEOM, CB2.GEOM, 1), 1, 'unit=km') ODLEGLOSC
from COUNTRY_BOUNDARIES CB1, COUNTRY_BOUNDARIES CB2
where CB1.CNTRY_NAME = 'Poland' and CB2.CNTRY_NAME <> 'Poland'
and SDO_RELATE(CB1.GEOM, CB2.GEOM, 'mask=TOUCH') = 'TRUE';

-- 3B

select CB.CNTRY_NAME
from COUNTRY_BOUNDARIES CB
order by SDO_GEOM.SDO_AREA(CB.GEOM, 1, 'unit=SQ_KM') desc
fetch first 1 rows only;

-- 3C

select ( SDO_GEOM.SDO_AREA((
            SDO_GEOM.SDO_MBR(
            SDO_GEOM.SDO_UNION(MC1.GEOM, MC2.GEOM, 1))), 1, 'unit=SQ_KM')) as SQ_KM
from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC1, MAJOR_CITIES MC2
where SDO_RELATE(MC1.GEOM, CB.GEOM, 'mask=INSIDE') = 'TRUE'
and CB.CNTRY_NAME = 'Poland'
and MC1.CITY_NAME = 'Warsaw'
and MC2.CITY_NAME = 'Lodz';

-- 3D

select SDO_GEOM.SDO_UNION(CB.GEOM, MC.GEOM, 1).SDO_GTYPE as GTYPE
from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC
where CB.CNTRY_NAME = 'Poland' and MC.CITY_NAME = 'Prague';

-- 3E

select  MC.CITY_NAME, CB.CNTRY_NAME
from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC
order by round(SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(CB.GEOM,1), MC.GEOM, 1, 'unit=km'))
fetch first 1 rows only;

-- 3F

select R."NAME", sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(CB.GEOM, R.GEOM, 1), 1, 'unit=km')) as DLUGOSC
from COUNTRY_BOUNDARIES CB, RIVERS R
where SDO_RELATE(R.GEOM, CB.GEOM, 'mask=ANYINTERACT') = 'TRUE'
and CB.CNTRY_NAME = 'Poland'
group by R."NAME";