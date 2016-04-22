-- Author: Pavol Loffay xloffa00@stud.fit.vutbr.cz
-- Team: xloffa00, xlukac05 
-- Date: 13.03.2012
-- Project: Projekt do predmetu IDS, skript obsahujuci SELECT
--          nad databazou restauracie.

--Zadanie stranka predmetu:
--  SQL skript obsahujici dotazy SELECT musi obsahovat nekolik dotazu 
--  pracujicich s databazi vytvorenou predchozim skriptem. Konkretne 
--  by mal obsahovat dva dotazy vyuzivajici spojeni dvou tabulek, 
--  jeden vyuzivajici spujeni tri tabuklek, dva dotazy s klauzuli
--  GROUP BY a agregcni funkci, jeden dotaz obsahujici predikat
--  EXISTS a jeden prikaz s predikatem IN.

--Zadanie wis:
--Skript bude odevzdavat pouze jeden clen resitelského tymu.
--Nazev souboru musi obsahovat loginy obou resitelu, tedy napr. xlogin01_xlogin02.sql.
--Skript musi obsahovat dotazy pracujici s databazi vytvorenou predchozim
--skriptem, konkretni dva dotazy vyuzivajici spojení dvou tabulek, jeden
--vyuzivajici spujeni tri tabulek, dva dotazy s klauzuli GROUP BY a agregacni
--funkci, jeden dotaz obsahujicí predikat EXISTS a jeden prikaz s predikátem IN.
--Zacatek skriptu musi obsahovat prikazy pro vytvoreni databazovych objektu
--odevzdavane v ramci predchoziho skriptu. U kazdeho dotazu by v poznamce malo
--byt (slovy) uvedeno, co dany dotaz z databaze ziska 

-------------------------------------------------------------------------------
--                            Vymazanie tabuliek
-------------------------------------------------------------------------------
--DROP TABLE if exists
--pozor v pripade ze sa tabulka neda odstranit nevypise chybu!
BEGIN 
    EXECUTE immediate 'DROP TABLE Objednavka_Produkt CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Produkt CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Rezervacia_Stol CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Objednavka CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Rezervacia CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Stol CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Uctenka CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/
BEGIN 
    EXECUTE immediate 'DROP TABLE Zamestnanec CASCADE CONSTRAINTS';
    EXCEPTION WHEN others THEN NULL;
END;
/

-------------------------------------------------------------------------------
--                          Vytvorenie tabuliek
-------------------------------------------------------------------------------
CREATE TABLE Zamestnanec (
    rodne_cislo CHAR(11),
    --
    meno VARCHAR(20) NOT NULL,
    priezvysko VARCHAR(20) NOT NULL,
    funkcia VARCHAR(20) NOT NULL,   
    tel_cislo VARCHAR(20),
    --
    CONSTRAINT PK_zamestnanec PRIMARY KEY (rodne_cislo),
    CONSTRAINT zamestnanec_enum CHECK (funkcia IN ('casnik', 'veduci',
            'majitel', 'vyhodeny'))
);

CREATE TABLE Produkt (
    pk INTEGER NOT NULL,
    --
    nazov VARCHAR(30) NOT NULL,
    cena NUMERIC(8,2) NOT NULL,
    popis VARCHAR(150),
    --
    CONSTRAINT PK_produkt PRIMARY KEY (pk)
);

CREATE TABLE Stol (
    pk INTEGER NOT NULL,
    --
    miestnost VARCHAR(20) NOT NULL, 
    popis VARCHAR(50),
    pocet_miest NUMERIC(2, 0) NOT NULL,
    --
    CONSTRAINT PK_Stol PRIMARY KEY (pk),
    CONSTRAINT stol_enum CHECK (miestnost IN ('salon1', 'salon2', 'salon3'))
);

CREATE TABLE Uctenka (
    pk NUMBER NOT NULL,
    zamestnanec CHAR(11) NOT NULL,
    --
    datum_vystavenia DATE NOT NULL,
    datum_zaplatenia DATE,
    cena NUMERIC(10,2),
    --
    CONSTRAINT PK_uctenka PRIMARY KEY (pk)
);

CREATE TABLE Objednavka (
    pk INTEGER NOT NULL,
    zamestnanec CHAR(11) NOT NULL,
    stol INTEGER,
    --
    uctenka INTEGER,
    rezervacia INTEGER,
    --
    popis VARCHAR(100),
    datum DATE NOT NULL,
    --
    CONSTRAINT PK_objednavka PRIMARY KEY (pk)
);

CREATE TABLE Objednavka_Produkt (
    produkt INTEGER NOT NULL,
    objednavka INTEGER NOT NULL,
    --
    mnozstvo NUMERIC(8,2) NOT NULL,
    --
    CONSTRAINT PK_objednavka_produkt PRIMARY KEY (produkt, objednavka)
);

CREATE TABLE Rezervacia (
    pk INTEGER NOT NULL,
    zamestnanec CHAR(11) NOT NULL,
    --
    na_meno VARCHAR(20) NOT NULL,
    pocet_osob NUMERIC(2, 0) NOT NULL,
    datum_rezervacie DATE,
    datum_prichodu DATE NOT NULL,
    popis VARCHAR(20),
    stav VARCHAR(10),
    --
    CONSTRAINT PK_rezervacia PRIMARY KEY (pk),
    CONSTRAINT rezervacia_enum CHECK (stav in ('prisli', 'neprisli', ''))
);

CREATE TABLE Rezervacia_Stol (
    rezervacia INTEGER NOT NULL,
    stol INTEGER NOT NULL,
    --
    CONSTRAINT PK_rezervacia_stol PRIMARY KEY (rezervacia, stol)
);

-------------------------------------------------------------------------------
--                          Uprava tabuliek
-------------------------------------------------------------------------------
--FK foreign key
--ak sa vymaze Produkt vymaze sa aj Objednavka_produkt
--ak sa vymaze Objednavka vymaze sa aj Objednavka_produkt
--ak sa vymaze Uctenka vymaze sa Objednavka a aj Objednavka_produkt
--ak sa vymaze Rezervacia vymaze sa Objednavka a aj Rezervacia_Stol
--ak sa vymze Stol vymaze sa Rezervacia_stol a aj Objednavka,

--UCTENKA
ALTER TABLE Uctenka ADD CONSTRAINT FK_uctenka_rodne_cislo
    FOREIGN KEY (zamestnanec) REFERENCES Zamestnanec;

--OBJEDNAVKA
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_casnik FOREIGN KEY (zamestnanec)
        REFERENCES Zamestnanec;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_stol FOREIGN KEY (stol)
        REFERENCES Stol ON DELETE CASCADE;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_uctenka FOREIGN KEY (uctenka)
        REFERENCES Uctenka ON DELETE CASCADE;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_rezervaia FOREIGN KEY (rezervacia)
        REFERENCES Rezervacia ON DELETE CASCADE;

--OBJEDNAVKA_PRODUKT
ALTER TABLE Objednavka_Produkt ADD CONSTRAINT FK_objednavka_produkt_produkt
    FOREIGN KEY (produkt) REFERENCES Produkt ON DELETE CASCADE;
ALTER TABLE Objednavka_Produkt ADD CONSTRAINT FK_objednavka_produkt_objedn
    FOREIGN KEY (objednavka) REFERENCES Objednavka ON DELETE CASCADE;

--REZERVACIA_STOL
ALTER TABLE Rezervacia_stol ADD CONSTRAINT FK_rezervacia_stol_rezervacia
    FOREIGN KEY (rezervacia) REFERENCES Rezervacia ON DELETE CASCADE;
ALTER TABLE Rezervacia_stol ADD CONSTRAINT FK_rezervacia_stol_stol
    FOREIGN KEY (stol) REFERENCES Stol ON DELETE CASCADE;

--REZERVACIA
ALTER TABLE Rezervacia ADD CONSTRAINT FK_rezervacia_casnik
    FOREIGN KEY (zamestnanec) REFERENCES Zamestnanec;

-------------------------------------------------------------------------------
--                             Vkladanie dat
-------------------------------------------------------------------------------
INSERT INTO Zamestnanec 
    VALUES('440726/0672', 'Peter', 'Dobrovsky', 'casnik', '0905294355');
INSERT INTO Zamestnanec 
    VALUES('477796/7842', 'Pavol', 'Emil', 'casnik', '0298426877');
INSERT INTO Zamestnanec 
    VALUES('140726/0697', 'Frantisek', 'Kahan', 'casnik', '0903698266');
INSERT INTO Zamestnanec 
    VALUES('480526/0771', 'Brano', 'Nemcek', 'veduci', '0901294395');
INSERT INTO Zamestnanec 
    VALUES('440726/1234', 'Edmund', 'Litvak', 'casnik', '0675297359');
INSERT INTO Zamestnanec 
    VALUES('785697/5678', 'Matej', 'Zuffa', 'majitel', '0707294395');

INSERT INTO Produkt
    VALUES(1, 'Pecena Kacka', 250, 'Pecena kacka s knedlou.');
INSERT INTO Produkt
    VALUES(2, 'Segedinsky gulas', 180, 'Segedinsky gulas na paprike.');
INSERT INTO Produkt
    VALUES(3, 'Opekane zemiaky', 50, 'Opekane zemiaky s
        kecupom alebo tatarskou omackou.');
INSERT INTO Produkt
    VALUES(4, 'Kapustova polievka', 89, 'Domaca kapustova polievka.');
INSERT INTO Produkt
    VALUES(5, 'Kuracie stehno pecene', 154, 'Pecene kuracie stehno na vine.');
INSERT INTO Produkt
    VALUES(6, 'Coca Cola', 30, 'Napoj Coca Cola vo flaske.');
INSERT INTO Produkt
    VALUES(7, 'Dzus', 25, 'Nalievany pomarancovy dzus.');
INSERT INTO Produkt
    VALUES(8, 'Fanta', 30, 'Napoj Fanta vo flaske.');

INSERT INTO Stol 
    VALUES (1, 'salon1', 'Pri okne s nadherny vyhladom.', 4);
INSERT INTO Stol 
    VALUES (2, 'salon2', 'Pri dverach do salonu 1.', 2);
INSERT INTO Stol 
    VALUES (3, 'salon3', 'V strede salonku 3.', 6);
INSERT INTO Stol 
    VALUES (4, 'salon1', 'Okruhly stol v strede salonku 1.', 7);
INSERT INTO Stol 
    VALUES (5, 'salon2', 'Stol pri vchode do kuchine.', 4);

INSERT INTO Uctenka
    VALUES (1, '440726/0672', TO_DATE('10.10.2011 21:02:44', 'dd.mm.yyyy
            hh24:mi:ss'), TO_DATE('10.10.2011 22:00:00', 'dd.mm.yyyy
            hh24:mi:ss'), 860);
INSERT INTO Uctenka
    VALUES (2, '477796/7842', TO_DATE('12.2.2011 15:02:44', 'dd.mm.yyyy
            hh24:mi:ss'), TO_DATE('10.10.2011 18:00:0', 'dd.mm.yyyy
            hh24:mi:ss'), 308);
INSERT INTO Uctenka
    VALUES (3, '140726/0697', TO_DATE('18.6.2011 19:02:44', 'dd.mm.yyyy
            hh24:mi:ss'), TO_DATE('10.10.2011 19:05:44', 'dd.mm.yyyy
            hh24:mi:ss'), 2034);
INSERT INTO Uctenka
    VALUES (4, '440726/1234', TO_DATE('17.2.2011 16:02:44', 'dd.mm.yyyy
            hh24:mi:ss'), TO_DATE('10.10.2011 16:08:55', 'dd.mm.yyyy
            hh24:mi:ss'), 720);
INSERT INTO Uctenka
    VALUES (5, '440726/0672', TO_DATE('18.1.2011 13:02:44', 'dd.mm.yyyy
            hh24:mi:ss'), TO_DATE('18.1.2011 13:30:22', 'dd.mm.yyyy
            hh24:mi:ss'), 100);

INSERT INTO Rezervacia
    VALUES (1, '440726/0672', 'Frantisek Pec', 6, TO_DATE('18.1.2011 13:02:44', 
            'dd.mm.yyyy hh24:mi:ss'), TO_DATE('18.1.2011 18:00:00', 'dd.mm.yyyy
            hh24:mi:ss'), 'Oslava narodenin', 'prisli');
INSERT INTO Rezervacia
    VALUES (2, '440726/0672', 'Jozes Cobrd', 2, TO_DATE('22.2.2011 08:09:55',
            'dd.mm.yyyy hh24:mi:ss'), TO_DATE('25.3.2011 16:00:00', 'dd.mm.yyyy
            hh24:mi:ss'), 'Velmi dobry klienti.', 'prisli');
INSERT INTO Rezervacia
    VALUES (3, '140726/0697', 'Peter Blaha', 4, TO_DATE('17.9.2011 10:00:44',
            'dd.mm.yyyy hh24:mi:ss'), TO_DATE('15.10.2011 13:00:00', 'dd.mm.yyyy
            hh24:mi:ss'), 'Pracovny obed.', 'prisli');
INSERT INTO Rezervacia
    VALUES (4, '140726/0697', 'Brano Skoda', 15, TO_DATE('25.8.2011 11:02:44',
            'dd.mm.yyyy hh24:mi:ss'), TO_DATE('25.10.2011 19:00:00', 'dd.mm.yyyy
            hh24:mi:ss'), 'Oslava menin.', '');
INSERT INTO Rezervacia
    VALUES (5, '477796/7842', 'Karol Dzurek', 2, TO_DATE('17.1.2011 14:09:41',
            'dd.mm.yyyy hh24:mi:ss'), TO_DATE('26.1.2011 15:00:00', 'dd.mm.yyyy
            hh24:mi:ss'), '', 'prisli');

--objednavky pre rezervacie 2 a 5 
INSERT INTO Objednavka
    VALUES (6, '440726/0672', 1, 1, 2, 'Objednavka na stol 1 z rezervacie 2.', 
        TO_DATE('21.1.2011 15:09:41', 'dd.mm.yyyy hh24:mi:ss'));
INSERT INTO Objednavka
    VALUES (7, '477796/7842', 1, 1, 5, 'Objednavka na stol 1 z rezervacie 5', 
        TO_DATE('27.2.2011 19:08:12', 'dd.mm.yyyy hh24:mi:ss'));
INSERT INTO Objednavka_produkt
    VALUES (1,6,2);
INSERT INTO Objednavka_produkt
    VALUES (2,7,2);

INSERT INTO  Rezervacia_Stol 
    VALUES (1, 1);
INSERT INTO  Rezervacia_Stol 
    VALUES (1, 2);
INSERT INTO  Rezervacia_Stol 
    VALUES (2, 2);
INSERT INTO  Rezervacia_Stol 
    VALUES (3, 5);
INSERT INTO  Rezervacia_Stol 
    VALUES (4, 4);
INSERT INTO  Rezervacia_Stol 
    VALUES (4, 3);
INSERT INTO  Rezervacia_Stol 
    VALUES (4, 1);
INSERT INTO  Rezervacia_Stol 
    VALUES (5, 2);

INSERT INTO Objednavka
    VALUES (1, '440726/0672', 1, 1, '', 'Objednavka na stol 1', 
        TO_DATE('17.1.2011 14:09:41', 'dd.mm.yyyy hh24:mi:ss'));
INSERT INTO Objednavka
    VALUES (2, '440726/0672', 2, 2, '', 'Objednavka na stol 2',
        TO_DATE('17.1.2011 15:09:41', 'dd.mm.yyyy hh24:mi:ss'));
INSERT INTO Objednavka
    VALUES (3, '140726/0697', 3, 3, '', '' , 
        TO_DATE('17.1.2011 18:09:41', 'dd.mm.yyyy hh24:mi:ss'));
INSERT INTO Objednavka
    VALUES (4, '477796/7842', 1, 4, '', 'Objednavka na stol 1', 
        TO_DATE('17.1.2011 11:09:41', 'dd.mm.yyyy hh24:mi:ss'));
INSERT INTO Objednavka
    VALUES (5, '477796/7842', 2, 5, '', '', 
        TO_DATE('17.1.2011 10:09:41', 'dd.mm.yyyy hh24:mi:ss'));

INSERT INTO Objednavka_Produkt
    VALUES (1,1,2);
INSERT INTO Objednavka_Produkt
    VALUES (2,1,2);
INSERT INTO Objednavka_Produkt
    VALUES (5,2,2);
INSERT INTO Objednavka_Produkt
    VALUES (4,3,6);
INSERT INTO Objednavka_Produkt
    VALUES (1,3,6);
INSERT INTO Objednavka_Produkt
    VALUES (2,4,4);
INSERT INTO Objednavka_Produkt
    VALUES (3,5,2);

alter session set NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS';

COMMIT;

-------------------------------------------------------------------------------
--                2 dotazy spojenia dvoch tabuliek
-------------------------------------------------------------------------------
-- Ktory zamestnanci maju spravene objednavky?
SELECT DISTINCT Z.meno, Z.priezvysko, Z.rodne_cislo, Z.funkcia
    FROM Zamestnanec Z, Objednavka O
    WHERE Z.rodne_cislo=O.zamestnanec;

-- Ktory zamenstananci maju spravene uctenky?
SELECT DISTINCT Z.meno, Z.priezvysko, Z.rodne_cislo, Z.funkcia
    FROM Zamestnanec Z, Uctenka U
    WHERE Z.rodne_cislo=U.zamestnanec;

-------------------------------------------------------------------------------
--                1 dotaz spojenia troch tabuliek
-------------------------------------------------------------------------------
-- Casnici, ktory maju objednavku a k tej objednavke aj uctenku?
SELECT DISTINCT Z.meno, Z.priezvysko, Z.rodne_cislo, Z.funkcia 
    FROM Zamestnanec Z, Uctenka U, Objednavka O
    WHERE Z.rodne_cislo=O.zamestnanec AND
          U.pk=O.uctenka AND Z.funkcia='casnik';

-------------------------------------------------------------------------------
--                2 dotazy s klauzuli GROUP BY a agregacnou funkciou
-------------------------------------------------------------------------------
-- Ktory zamestnanci maju kolko nauctovane na uctenkach? 
SELECT Z.meno, Z.priezvysko, U.Zamestnanec, SUM(U.cena) suma_ceny_na_ucetenkach
    FROM Uctenka U, Zamestnanec Z
    WHERE U.zamestnanec=Z.rodne_cislo
    GROUP BY U.Zamestnanec, Z.priezvysko, Z.meno;

-- Kolko ma restauracia stolov v jednotlivych miestnostiach?
SELECT miestnost, COUNT(*) pocet_stolov
    FROM Stol 
    GROUP BY miestnost;

-------------------------------------------------------------------------------
--                           preditkaty IN a EXISTS 
-------------------------------------------------------------------------------
-- IN
-- Ktory zamestnanci robili objednavky v salon1 a salon2?
SELECT DISTINCT Z.meno, Z.priezvysko, Z.rodne_cislo
    FROM Objednavka O, Stol S, Zamestnanec Z
    WHERE O.stol=S.pk AND S.miestnost IN ('salon1', 'salon2')
        AND Z.rodne_cislo=O.zamestnanec;

-- EXIST
-- Ktory su zamestnanci(nie majitel) co nemaju spravenu ziadnu objednavku?
SELECT meno, priezvysko, funkcia
    FROM Zamestnanec Z
    WHERE  Z.funkcia NOT IN ('majitel') 
           AND NOT EXISTS (SELECT *
                                FROM Objednavka O
                                WHERE Z.rodne_cislo=O.zamestnanec);


-------------------------------------------------------------------------------
--                             Moje poznamky
-------------------------------------------------------------------------------
--Spojenie tabuliek
--  1. v FROM uvedieme vsetky tabulky, a v WHERE podmienku ako sa spoja
--  2. v FROM pouzijeme vyraz spojeni - jeho vysledkom je tabulta
--      NATURAL - iba tak isto pojmenovane stlpce tam budu iba 1x - rovnost ich hodnot

--vybere vsetko zo zamestnanca
--SELECT * 
--    FROM Zamestnanec;

--vypise iba rodne_cislo meno
--SELECT ALL rodne_cislo, meno 
--    FROM Zamestnanec;
--vypise jedinecne mena zamestnancov
-- DISTINCT - eliminuje duplikujuce hodnoty
-- ALL vypise vsetko
--SELECT DISTINCT meno 
--    FROM Zamestnanec;

--WHERE <podmienka>
--SELECT meno, priezvysko, rodne_cislo 
--    FROM Zamestnanec
--   WHERE funkcia='casnik';

--premenovanie stlpcov
--SELECT meno AS Name, priezvysko  Surname, rodne_cislo AS Primary_key_in_database
--    FROM Zamestnanec 
--    WHERE funkcia='casnik';

--Ceny vsetkych jedal v EUR, 1EUR = 25KC
--SELECT nazov, cena AS cena_v_czk, cena/25 cena_v_eur
--    FROM Produkt
--    ORDER BY cena_v_eur;

