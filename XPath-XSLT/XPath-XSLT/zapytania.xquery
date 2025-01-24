(:36.:)
for $k in sum(doc('file:///C:/Users/Huawei/Desktop/zesp_prac.xml')/ZESPOLY/ROW/PRACOWNICY/ROW[ID_ZESP = /ZESPOLY/ROW/PRACOWNICY/ROW[NAZWISKO = 'BRZEZINSKI']/ID_ZESP]/PLACA_POD)
return $k

(:35.:)
(:for $k in doc('file:///C:/Users/Huawei/Desktop/zesp_prac.xml')/ZESPOLY/ROW/PRACOWNICY/ROW[ID_SZEFA = 100]
return $k/NAZWISKO:)

(:34.:)
(:for $k in count(doc('file:///C:/Users/Huawei/Desktop/zesp_prac.xml')/ZESPOLY/ROW[ID_ZESP = 10]/PRACOWNICY/ROW)
return $k:)

(:32/33:)
(:for $k in doc('file:///C:/Users/Huawei/Desktop/zesp_prac.xml')/ZESPOLY/ROW[NAZWA = 'SYSTEMY EKSPERCKIE']/PRACOWNICY/ROW
return $k/NAZWISKO:)

(:30.:)
(:doc('file:///C:/Users/Huawei/Desktop/XPath-XSLT/XPath-XSLT/swiat.xml')//KRAJ:)

(:29.:)
(:for $k in doc('file:///C:/Users/Huawei/Desktop/XPath-XSLT/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ[substring(NAZWA, 1, 1)=substring(STOLICA, 1, 1)]
return <KRAJ>
 {$k/NAZWA, $k/STOLICA}
</KRAJ>:)

(:28.:)
(:for $k in doc('file:///C:/Users/Huawei/Desktop/XPath-XSLT/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ[starts-with(NAZWA, 'A')]
return <KRAJ>
 {$k/NAZWA, $k/STOLICA}
</KRAJ>:)