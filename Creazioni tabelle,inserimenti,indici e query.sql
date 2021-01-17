--DROP SCHEMA public CASCADE;
--CREATE SCHEMA public;
--GRANT ALL ON SCHEMA public TO postgres;
--GRANT ALL ON SCHEMA public TO public;
--COMMENT ON SCHEMA public IS 'standard public schema';

CREATE TABLE Prodotto (
 Codice_prodotto INT PRIMARY KEY,
 Nome VARCHAR(30) NOT NULL,
 Categoria VARCHAR(20) NOT NULL,
 Prezzo NUMERIC(7,2) NOT NULL,
 Produttore VARCHAR(20) NOT NULL
);
ALTER TABLE Prodotto
ADD CHECK (Prezzo >= 0);

--DROP TABLE IF EXISTS Magazzino;
CREATE TABLE Magazzino  (
 Codice_magazzino INT,
 Citta VARCHAR(20) NOT NULL,
 PRIMARY KEY (Codice_magazzino)
);

--DROP TABLE IF EXISTS Magazzino;
CREATE TABLE Rimanenza  (
 Codice_prodotto_rimanenza INT,
 Codice_magazzino_rimanenza INT,
 Numero_pezzi SMALLINT NOT NULL,
 PRIMARY KEY (Codice_prodotto_rimanenza, Codice_magazzino_rimanenza),
 FOREIGN KEY (Codice_prodotto_rimanenza) REFERENCES Prodotto(Codice_prodotto) ON DELETE NO ACTION,
 FOREIGN KEY (Codice_magazzino_rimanenza) REFERENCES Magazzino(Codice_magazzino) ON DELETE NO ACTION
);
ALTER TABLE Rimanenza
ADD CHECK (Numero_pezzi >= 0);

--DROP TABLE IF EXISTS Carrello;
CREATE TYPE TIPOCARRELLO AS ENUM ('PERSONALE', 'AMICO');
CREATE TABLE Carrello  (
 Codice_carrello INT,
 Totale NUMERIC(8,2) NOT NULL,
 Tipo_carrello TIPOCARRELLO NOT NULL,
 PRIMARY KEY (Codice_carrello)
);

--DROP TABLE IF EXISTS Inclusione;
CREATE TABLE Inclusione  (
 Codice_carrello_inclusione INT,
 Codice_prodotto_inclusione INT,
 Quantita SMALLINT NOT NULL,
 PRIMARY KEY (Codice_carrello_inclusione, Codice_prodotto_inclusione),
 FOREIGN KEY (Codice_carrello_inclusione) REFERENCES Carrello(Codice_carrello) ON DELETE CASCADE,
 FOREIGN KEY (Codice_prodotto_inclusione) REFERENCES Prodotto(Codice_prodotto) ON DELETE CASCADE
 );

 --DROP TABLE IF EXISTS Cliente;
CREATE TABLE Cliente  (
 Email VARCHAR (50) CHECK (Email LIKE '%_@__%.__%') PRIMARY KEY,
 password_utente VARCHAR (30) NOT NULL,
 amico varchar(50),
 Nome VARCHAR(30) NOT NULL,
 Cognome VARCHAR(30) NOT NULL,
 Cellulare VARCHAR(9),
 Citta VARCHAR(20) NOT NULL,
 Via VARCHAR(30) NOT NULL,
 Civico VARCHAR(3) NOT NULL,
 Cap VARCHAR(5) NOT NULL
);
ALTER TABLE Cliente
ADD FOREIGN KEY (amico) REFERENCES Cliente(Email) ON DELETE NO ACTION;

 --DROP TABLE IF EXISTS Corriere;
CREATE TABLE Corriere  (
 Targa VARCHAR(8),
 Tipo VARCHAR(20),
 PRIMARY KEY (Targa)
);

--DROP TABLE IF EXISTS Ordine;
CREATE TYPE TIPOPAGAMENTO AS ENUM ('CONTRASSEGNO', 'PAYPAL', 'VISA', 'MASTERCARD');
CREATE TABLE Ordine  (
 Codice_ordine INT,
 Codice_carrello_ordine INT,
 Email_cliente_ordine VARCHAR(40),
 Data_ordine DATE NOT NULL,
 Tipo_pagamento TIPOPAGAMENTO NOT NULL,
 PRIMARY KEY (Codice_ordine),
 FOREIGN KEY (Codice_carrello_ordine) REFERENCES Carrello(Codice_carrello) ON DELETE NO ACTION,
 FOREIGN KEY (Email_cliente_ordine) REFERENCES Cliente(Email) ON DELETE NO ACTION
);
 
--DROP TABLE IF EXISTS Fattura;
CREATE TABLE Fattura  (
 Codice_fattura INT PRIMARY KEY,
 Codice_ordine_fattura INT,
 Data_fattura DATE NOT NULL,
 Totale NUMERIC(8,2) NOT NULL,
 FOREIGN KEY (Codice_ordine_fattura) REFERENCES Ordine(Codice_ordine) ON DELETE CASCADE
);

 --DROP TABLE IF EXISTS Spedizione;
CREATE TABLE Spedizione  (
 Codice_ordine_spedizione INT,
 Targa_spedizione VARCHAR(8),
 Data_spedizione DATE,
 PRIMARY KEY (Codice_ordine_spedizione),
 FOREIGN KEY (Codice_ordine_spedizione) REFERENCES Ordine(Codice_ordine) ON DELETE NO ACTION,
 FOREIGN KEY (Targa_spedizione) REFERENCES Corriere(Targa) ON DELETE NO ACTION
);

-- FINE CREAZIONE TABELLE, INIZIO INSERIMENTO DATI --

ALTER TABLE Ordine DISABLE TRIGGER ALL;
ALTER TABLE Fattura DISABLE TRIGGER ALL;
ALTER TABLE Carrello DISABLE TRIGGER ALL;
ALTER TABLE Spedizione DISABLE TRIGGER ALL;
ALTER TABLE Inclusione DISABLE TRIGGER ALL;

INSERT INTO Prodotto (Codice_prodotto, Nome, Categoria, Prezzo, Produttore) 
VALUES 
('10001','Ipod','Speaker','69.00','Apple'),('10002','Cuffie bose','Speaker','28.00','Bose'),
('10003','Subwoofer','Speaker','188.00','Philips'),('10004','Amplificatore max','Speaker','169.00','Apple'),
('10005','Auricolari filo','Speaker','19.00','Sony'),('10006','Ipad','Tablet','429.00','Apple'),
('10007','Galaxy tab 10.2','Tablet','349.00','Samsung'),('10008','Mipad','Tablet','129.00','HP'),
('10009','Tablet clementoni','Tablet','29.00','Clementoni'),('10010','Iphone 12 pro','Smartphone','1229.00','Apple'),
('10011','Iphone 12 mini','Smartphone','819.00','Apple'),('10012','P40 pro','Smartphone','699.00','Huawei'),
('10013','P30 mini','Smartphone','229.00','Huawei'),('10014','Vaio 15','PC','899.00','Sony'),
('10015','Thinkpad 13','PC','1149.00','HP'),('10016','Macbookpro 14','PC','1449.00','Apple'),
('10017','MatePro 15','PC','549.00','Huawei'),('10018','Microonde','Cucina','69.00','Samsung'),
('10019','Frullatore','Cucina','39.00','Philips'),('10020','Piano cottura','Cucina','654.00','Sony'),
('10021','Frigorifero','Cucina','669.00','Huawei'),('10022','Freezer','Cucina','244.00','HP'),
('10023','3DS','Console','128.00','Nintendo'),('10024','Switch','Console','250.00','Nintendo'),
('10025','Xbox One','Console','294.00','Microsoft'),('10026','Xbox 360','Console','369.00','Microsoft'),
('10027','PS4','Console','349.00','Sony'),('10028','PS5','Console','499.00','Sony'),
('10029','Super mario 65','Giochi','6.00','Nintendo'),('10030','Mario kart 9','Giochi','27.00','Nintendo'),
('10031','Call of duty 3','Giochi','4.00','Microsoft'),('10032','Gears of war 6','Giochi','17.00','Microsoft'),
('10033','Gran turismo 7','Giochi','14.00','Sony'),('10034','Crash 5','Giochi','8.00','Sony'),
('10035','Lavasciuga','Casa','123.00','Huawei'),('10036','Lavatrice','Casa','472.00','HP'),
('10037','Televisore oled','Casa','3456.00','Apple'),('10038','Televisore lcd','Casa','1777.00','Philips'),
('10039','Telecomando','Casa','8.00','Sony'),('10040','Aspirapolvere','Casa','126.00','HP');

INSERT INTO Inclusione (Codice_carrello_inclusione, Codice_prodotto_inclusione, Quantita) 
VALUES 
('20001','10001','3'),						 
('20001','10010','1'), ('20001','10034','4'),
('20002','10021','1'), ('20002','10032','2'),
('20003','10033','6'), ('20003','10016','7'),
('20003','10040','2'), ('20003','10019','7'),
('20004','10032','8'), ('20005','10010','9'),
('20006','10011','6'), ('20006','10002','8'),
('20007','10016','3'), ('20008','10007','4'),
('20009','10019','4'), ('20009','10001','3'),
('20009','10012','6'), ('20009','10029','2'),
('20010','10011','4'), ('20011','10031','6'),
('20011','10005','6'), ('20011','10003','4'),
('20012','10007','2'), ('20013','10024','3'),
('20014','10008','5'), ('20014','10022','6'),
('20015','10035','8'), ('20015','10033','4'),
('20016','10015','4'), ('20016','10006','6'),
('20017','10029','8'), ('20018','10018','3'),
('20019','10013','4'), ('20020','10037','2'),
('20021','10039','5'), ('20021','10020','6');

INSERT INTO Magazzino (Codice_magazzino, Citta) 
VALUES 
('70001', 'Padova'),
('70002', 'Bologna'),
('70003', 'Milano');

INSERT INTO Rimanenza (Codice_prodotto_rimanenza, Codice_magazzino_rimanenza, Numero_pezzi) 
VALUES 
('10001', '70001', '13'), ('10002', '70001', '5'), ('10003', '70001', '9'), ('10004', '70001', '8'),
('10005', '70001', '10'), ('10006', '70001', '9'), ('10007', '70001', '4'), ('10008', '70001', '11'),
('10009', '70001', '7'), ('10010', '70001', '11'), ('10011', '70001', '30'), ('10012', '70001', '27'),
('10013', '70001', '11'), ('10014', '70001', '67'), ('10015', '70001', '19'), ('10016', '70001', '32'),
('10017', '70001', '1'), ('10018', '70001', '21'), ('10019', '70001', '6'), ('10020', '70001', '14'),
('10021', '70001', '13'), ('10022', '70001', '29'), ('10023', '70001', '7'), ('10024', '70001', '18'),
('10025', '70001', '9'), ('10026', '70001', '5'), ('10027', '70001', '23'), ('10028', '70001', '8'),
('10029', '70001', '21'), ('10030', '70001', '2'), ('10031', '70001', '20'), ('10032', '70001', '28'),
('10033', '70001', '6'), ('10034', '70001', '50'), ('10035', '70001', '10'), ('10036', '70001', '20'),
('10037', '70001', '13'), ('10038', '70001', '41'), ('10039', '70001', '9'), ('10040', '70001', '30'),

('10001', '70002', '22'), ('10002', '70002', '2'), ('10003',  '70002', '7'), ('10004',  '70002', '5'),
('10005', '70002', '11'), ('10006', '70002', '5'), ('10007',  '70002', '1'), ('10008',  '70002', '19'),
('10009', '70002', '26'), ('10010',  '70002', '9'), ('10011', '70002', '23'), ('10012', '70002', '26'),
('10013', '70002', '10'), ('10014', '70002', '50'), ('10015', '70002', '17'), ('10016', '70002', '14'),
('10017', '70002', '3'), ('10018',  '70002', '22'), ('10019', '70002', '8'), ('10020',  '70002', '11'),
('10021', '70002', '23'), ('10022', '70002', '20'), ('10023', '70002', '17'), ('10024',  '70002', '9'),
('10025', '70002', '6'), ('10026',  '70002', '7'), ('10027',  '70002', '22'), ('10028', '70002', '16'),
('10029', '70002', '31'), ('10030', '70002', '3'), ('10031',  '70002', '30'), ('10032', '70002', '33'),
('10033', '70002', '20'), ('10034', '70002', '30'), ('10035', '70002', '14'), ('10036', '70002', '21'),
('10037', '70002', '10'), ('10038', '70002', '31'), ('10039', '70002', '8'), ('10040',  '70002', '13'),

('10001', '70003', '4'), ('10002', '70003', '15'), ('10003',  '70003', '10'), ('10004',  '70003', '25'),
('10005', '70003', '13'), ('10006', '70003', '8'), ('10007',  '70003', '8'), ('10008',  '70003', '25'),
('10009', '70003', '2'), ('10010',  '70003', '16'), ('10011', '70003', '41'), ('10012', '70003', '8'),
('10013', '70003', '21'), ('10014', '70003', '32'), ('10015', '70003', '39'), ('10016', '70003', '14'),
('10017', '70003', '12'), ('10018',  '70003', '12'), ('10019', '70003', '25'), ('10020',  '70003', '4'),
('10021', '70003', '18'), ('10022', '70003', '31'), ('10023', '70003', '31'), ('10024',  '70003', '8'),
('10025', '70003', '4'), ('10026',  '70003', '2'), ('10027',  '70003', '20'), ('10028', '70003', '27'),
('10029', '70003', '26'), ('10030', '70003', '4'), ('10031',  '70003', '10'), ('10032', '70003', '12'),
('10033', '70003', '10'), ('10034', ' 70003', '9'), ('10035', '70003', '7'), ('10036', '70003', '10'),
('10037', '70003', '15'), ('10038', '70003', '14'), ('10039', '70003', '12'), ('10040',  '70003', '7');

INSERT INTO Cliente (Email, Password_utente, Amico, Nome, Cognome, Cellulare, Citta, Via, Civico, Cap) 
VALUES 
('aleber@gmail.com', 'password123', NULL, 'Alessio','Berton','345678910','Padova', 'Via del bafo', '23', '35132'),
('alesantin@gmail.com','password123', NULL, 'Alessandro','Santin','34565291','Padova', 'Via ancestrale','12', '35132'),
('batman@gmail.com','password321', 'alesantin@gmail.com','Bruce','Waine','3949338','Bologna', 'Via del Porticato', '77', '25562'),
('superman@gmail.com','password3231', 'alesantin@gmail.com','Clark','Kent ','8549974','Bologna', 'Via del Municipio antico', '6', '12798'),
('spiderman@gmail.com','password434324', NULL, 'Peter','Parker','34263328','Milano', 'Via Dell Accoglienza', '11', '64321'),
('ricmene@gmail.com','password432432', 'aleber@gmail.com','Riccardo','Menestrello','3562278','Padova', 'Via della Luna', '92', '35127'),
('tango77@gmail.com','password12121131', NULL,'Alberto','Tomba','93829382','Padova', 'Via delle Stelle', '18', '33333'),
('maestra22@gmail.com','password432432', 'spiderman@gmail.com','Francesca','Marzotto','56373457','Bologna', 'Via Ferrara', '5', '31276'),
('filippoMari@gmail.com','password432231', 'spiderman@gmail.com','Filippo','Marino','39289829','Milano', 'Via Cogoleto', '1', '34111'),
('maretax@gmail.com','password12523131', 'maestra22@gmail.com','Marina','Rossi','74584384','Padova', 'Via del Tramonto', '121','31199'),
('theoH@gmail.com','password125243231', NULL, 'Theo','hernandez','54654384','Milano', 'Via del matto', '333','34399'),
('mulino59@gmail.com','password16352342', 'spiderman@gmail.com','Simona','Galletto','76328829','Milano', 'Via Camporosso', '63', '61999');

INSERT INTO Carrello (Codice_carrello, Totale, Tipo_carrello) 
VALUES 
('20001', '1451.00', 'PERSONALE'), 
('20002', '736.00', 'PERSONALE'), 
('20003', '10772.00', 'PERSONALE'),	
('20004', '144.00', 'PERSONALE'), 
('20005', '11070.00', 'PERSONALE'),
('20006', '5140.00', 'PERSONALE'), 
('20007', '4350.00', 'PERSONALE'),
('20008', '1400.00', 'PERSONALE'), 
('20009', '4584.00', 'PERSONALE'),
('20010', '3280.00', 'PERSONALE'),
('20011', '906.00', 'PERSONALE'),
('20012', '700.00', 'PERSONALE'), 
('20013', '753.00', 'PERSONALE'),
('20014', '1860.00', 'PERSONALE'),
('20015', '1052.00', 'PERSONALE'), 
('20016', '7180.00', 'PERSONALE'),
('20017', '48.00', 'AMICO'),
('20018', '207.00', 'AMICO'),
('20019', '916.00', 'AMICO'),
('20020', '6912.00', 'AMICO'),
('20021', '3964.00', 'PERSONALE');


--PAYPAL += 0 EURO 
--MASTERCARD += 10 EURO
--VISA += 10 EURO
--CONTRASSEGNO += 20 EURO
INSERT INTO Fattura (Codice_fattura, Codice_ordine_fattura, Data_fattura, Totale) 
VALUES 
('40001','30001','10-01-2020','1451.00'),
('40002','30002','15-02-2020','746.00'),
('40003','30003','10-01-2020','10782.00'),
('40004','30004','30-06-2020','164.00'),
('40005','30005','12-03-2020','11080.00'),
('40006','30006','09-12-2020','5149.00'),
('40007','30007','13-09-2020','4360.00'),
('40008','30008','22-07-2020','1410.00'),
('40009','30009','06-02-2020','4584.00'),
('40010','30010','17-06-2020','3290.00'),
('40011','30011','25-08-2020','926.00'),
('40012','30012','24-06-2020','710.00'),
('40013','30013','12-10-2020','753.00'),
('40014','30014','03-03-2020','1870.00'),
('40015','30015','22-03-2020','1062.00'),
('40016','30016','06-06-2020','7200.00'),
('40017','30017','09-06-2020','58.00'),
('40018','30018','17-06-2020','208.00'),
('40019','30019','25-06-2020','936.00'),
('40020','30020','11-09-2020','6912.00');
--('40021','30021', NULL, '3974.00');

INSERT INTO Corriere (Targa, Tipo)  VALUES 
('CD 590DA','normale'), ('AB 740TR','espresso'),('BM 891ER','normale'),
('AX 777DW','espresso'),('MR 423AE','normale');

INSERT INTO Spedizione (Codice_ordine_spedizione, Targa_spedizione, Data_spedizione) 
VALUES 
('30001','CD 590DA','10-01-2020'),
('30002','AX 777DW','15-02-2020'),
('30003','MR 423AE','10-01-2020'),
('30004','AB 740TR','30-07-2020'),
('30005','BM 891ER','12-03-2020'),
('30006','CD 590DA','09-12-2020'),
('30007','AX 777DW','13-09-2020'),
('30008','MR 423AE','22-07-2020'),
('30009','BM 891ER','06-11-2020'),
('30010','BM 891ER','17-06-2020'),
('30011','CD 590DA','25-08-2020'),
('30012','AX 777DW','24-06-2020'),
('30013','MR 423AE','12-10-2020'),
('30014','AB 740TR','03-03-2020'),
('30015','BM 891ER','22-03-2020'),
('30016','AB 740TR','06-06-2020'),
('30017','MR 423AE','09-06-2020'), 
('30018','AB 740TR','17-06-2020'),
('30019','AB 740TR','25-06-2020'),
('30020','MR 423AE','11-09-2020'),
('30021','AX 777DW',NULL);



INSERT INTO Ordine (Codice_ordine, Codice_carrello_ordine, Email_cliente_ordine, Data_ordine, Tipo_pagamento) 
VALUES 
('30001', '20001','aleber@gmail.com', '1-01-2020','PAYPAL'),
('30002', '20002','superman@gmail.com', '11-02-2020', 'MASTERCARD'),
('30003', '20003','spiderman@gmail.com', '8-01-2020', 'VISA'),
('30004', '20004','tango77@gmail.com', '27-06-2020', 'CONTRASSEGNO'),
('30005', '20005','alesantin@gmail.com', '9-03-2020', 'VISA'),
('30006', '20006','maestra22@gmail.com', '29-11-2020', 'PAYPAL'),
('30007', '20007','aleber@gmail.com', '11-09-2020', 'MASTERCARD'),
('30008', '20008','alesantin@gmail.com', '19-07-2020', 'MASTERCARD'),
('30009', '20009','superman@gmail.com','24-01-2020', 'PAYPAL'),
('30010', '20010','mulino59@gmail.com', '13-06-2020', 'MASTERCARD'),
('30011', '20011','ricmene@gmail.com', '20-08-2020', 'CONTRASSEGNO'),
('30012', '20012','alesantin@gmail.com', '19-06-2020', 'MASTERCARD'),     
('30013', '20013','mulino59@gmail.com','22-09-2020', 'PAYPAL'),     
('30014', '20014','maestra22@gmail.com', '28-02-2020', 'MASTERCARD'),     
('30015', '20015','tango77@gmail.com', '20-03-2020', 'VISA'),     
('30016', '20016','maretax@gmail.com', '02-06-2020', 'CONTRASSEGNO'),
('30017', '20017','batman@gmail.com', '05-06-2020', 'MASTERCARD'),
('30018', '20018','superman@gmail.com', '14-06-2020', 'VISA'),
('30019', '20019','ricmene@gmail.com', '22-06-2020', 'CONTRASSEGNO'),
('30020', '20020','ricmene@gmail.com', '03-09-2020', 'PAYPAL'),
('30021', '20021','theoH@gmail.com', '12-11-2020', 'VISA');



DROP INDEX IF EXISTS idx_prodotto;
CREATE INDEX idx_prodotto ON Prodotto(categoria, prezzo); 
DROP INDEX IF EXISTS idx_ordine;
CREATE INDEX idx_ordine ON Ordine USING hash (email_cliente_ordine);

ALTER TABLE Ordine ENABLE TRIGGER ALL;
ALTER TABLE Fattura ENABLE TRIGGER ALL;
ALTER TABLE Carrello ENABLE TRIGGER ALL;
ALTER TABLE Spedizione ENABLE TRIGGER ALL;
ALTER TABLE Inclusione ENABLE TRIGGER ALL;

-- QUERY
SELECT P.nome, inc.quantita AS VENDUTI, concat(p.prezzo * inc.quantita, ' €') AS RICAVOTOTALE, rim.numero_pezzi AS INSTOCK, mag.citta
FROM prodotto p JOIN inclusione inc ON p.codice_prodotto = inc.codice_prodotto_inclusione
                JOIN carrello c ON inc.codice_carrello_inclusione = c.codice_carrello
                JOIN ordine o ON c.codice_carrello = o.codice_carrello_ordine
                JOIN cliente cli ON o.email_cliente_ordine = cli.email
                JOIN rimanenza rim ON p.codice_prodotto = rim.codice_prodotto_rimanenza
                JOIN magazzino mag ON rim.codice_magazzino_rimanenza = mag.codice_magazzino
WHERE p.categoria = 'Giochi' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020' AND mag.citta = cli.citta
GROUP BY p.nome, inc.quantita, p.prezzo, rim.numero_pezzi, mag.citta;


DROP VIEW IF EXISTS CarrelloMedioPadova;
CREATE VIEW CarrelloMedioPadova(MEDIA) AS
SELECT AVG(car.totale)
FROM Cliente cl JOIN ordine ord ON cl.email = ord.email_cliente_ordine
                JOIN fattura fat on ord.codice_ordine = fat.codice_ordine_fattura
                JOIN carrello car on ord.codice_carrello_ordine = car.codice_carrello
WHERE cl.citta = 'Padova';

SELECT cl.nome, cl.cognome , CONCAT(COALESCE (fat.totale, car.totale + '10.00'), ' €') AS SPESOINTOTALE, CONCAT(ROUND(cmp.MEDIA, 2), ' €') AS MEDIAPADOVA,
       concat(ROUND(CAR.totale *100 /cmp.MEDIA, 2), '%') AS RISPETTOAPADOVA
FROM Cliente cl JOIN ordine ord ON cl.email = ord.email_cliente_ordine
                JOIN carrello car on ord.codice_carrello_ordine = car.codice_carrello
                JOIN CarrelloMedioPadova cmp on car.totale >= cmp.MEDIA
                LEFT JOIN fattura fat on ord.codice_ordine = fat.codice_ordine_fattura
WHERE ord.tipo_pagamento = 'VISA' AND cl.citta = 'Milano'
GROUP BY cl.nome, cl.cognome, fat.totale, CMP.MEDIA, CAR.totale
UNION
SELECT cl.nome, cl.cognome, CONCAT(COALESCE (fat.totale, car.totale + '20.00'), ' €') AS SPESOINTOTALE, CONCAT(ROUND(cmp.MEDIA, 2), ' €') AS MEDIAPADOVA,
       concat(ROUND(CAR.totale *100 /cmp.MEDIA, 2), '%') AS RISPETTOAPADOVA
FROM Cliente cl JOIN ordine ord ON cl.email = ord.email_cliente_ordine
                JOIN carrello car on ord.codice_carrello_ordine = car.codice_carrello
                JOIN CarrelloMedioPadova cmp on car.totale >= cmp.MEDIA
                LEFT JOIN fattura fat on ord.codice_ordine = fat.codice_ordine_fattura
WHERE ord.tipo_pagamento = 'CONTRASSEGNO' AND cl.citta = 'Bologna'
GROUP BY cl.nome, cl.cognome, fat.totale, CMP.MEDIA, CAR.totale;


SELECT cli.amico, count(*)
FROM cliente cli JOIN ordine o ON cli.email = o.email_cliente_ordine
                 JOIN carrello car ON car.codice_carrello = o.codice_carrello_ordine
                 JOIN spedizione s ON o.codice_ordine = s.codice_ordine_spedizione -- per capire se economica
                 JOIN corriere cor ON cor.targa = s.targa_spedizione -- per capire se economica
WHERE car.tipo_carrello = 'AMICO'
  AND cli.amico IN (SELECT cli2.email FROM cliente cli2 WHERE cli2.citta = 'Padova')
  AND EXISTS(SELECT *
             FROM cliente cli2 JOIN ordine o2 ON cli2.email = o2.email_cliente_ordine
                               JOIN carrello car2 ON car2.codice_carrello = o2.codice_carrello_ordine
             WHERE car2.tipo_carrello = 'AMICO' AND o2.codice_ordine <> o.codice_ordine AND cli2.amico = cli.amico)
  AND cor.tipo = 'espresso'
GROUP BY cli.amico
ORDER BY cli.amico;


SELECT cli.citta AS FILIALE , count(*) AS NUMEROORDINI, concat(SUM(c.totale), ' €') AS RICAVITOTALI, concat(SUM(f.totale),' €') AS FATTURATI,
       concat(SUM(f.totale) - SUM(c.totale), ' €') AS GUADAGNODAMETODOPAGAMENTO
FROM cliente cli JOIN ordine o on cli.email = o.email_cliente_ordine
                 JOIN carrello c on c.codice_carrello = o.codice_carrello_ordine
                 join fattura f on o.codice_ordine = f.codice_ordine_fattura
WHERE c.tipo_carrello = 'PERSONALE' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020'
GROUP BY cli.citta
UNION
SELECT c3.citta AS FILIALE , count(*) AS NUMEROORDINI, concat(SUM(c.totale), ' €') AS RICAVITOTALI, concat(SUM(f.totale),' €') AS FATTURATI,
       concat(SUM(f.totale) - SUM(c.totale), ' €') AS GUADAGNODAMETODOPAGAMENTO
FROM cliente cli JOIN ordine o on cli.email = o.email_cliente_ordine
                 JOIN carrello c on c.codice_carrello = o.codice_carrello_ordine
                 join fattura f on o.codice_ordine = f.codice_ordine_fattura
                 JOIN cliente c3 on cli.amico = c3.email
WHERE c.tipo_carrello = 'AMICO' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020'
GROUP BY c3.citta;


SELECT m.citta, p.nome, r.numero_pezzi
FROM magazzino m
         JOIN rimanenza r on m.codice_magazzino = r.codice_magazzino_rimanenza
         JOIN prodotto p on p.codice_prodotto = r.codice_prodotto_rimanenza
WHERE p.categoria = 'Casa'
  AND p.nome LIKE 'T%'
  AND m.citta IN (SELECT C2.citta
                  FROM prodotto prod
                           JOIN inclusione i on prod.codice_prodotto = i.codice_prodotto_inclusione
                           JOIN carrello c on c.codice_carrello = i.codice_carrello_inclusione
                           JOIN ordine o on c.codice_carrello = o.codice_carrello_ordine
                           JOIN cliente c2 on c2.email = o.email_cliente_ordine
                  WHERE o.data_ordine >= '01-01-2020'
                    AND o.data_ordine <= '31-12-2020'
                      EXCEPT
                  SELECT C2.citta
                  FROM prodotto prod
                           JOIN inclusione i on prod.codice_prodotto = i.codice_prodotto_inclusione
                           JOIN carrello c on c.codice_carrello = i.codice_carrello_inclusione
                           JOIN ordine o on c.codice_carrello = o.codice_carrello_ordine
                           JOIN cliente c2 on c2.email = o.email_cliente_ordine
                  WHERE prod.categoria = 'Console'
                    AND o.data_ordine >= '01-01-2020'
                    AND o.data_ordine <= '31-12-2020')
  AND EXISTS(SELECT COUNT(*)
             FROM CLIENTE cli
             WHERE cli.citta = m.citta
             GROUP BY cli.citta
             HAVING count(cli.email) > 3)

GROUP BY m.citta, p.nome, r.numero_pezzi;


SELECT citta, COUNT(email) AS NUMEROORDINI
FROM ordine JOIN cliente c on ordine.email_cliente_ordine = c.email
GROUP BY citta
HAVING COUNT(citta) >= ALL (SELECT COUNT(cli2.citta)
                            FROM ordine JOIN cliente cli2 on ordine.email_cliente_ordine = cli2.email
                            GROUP BY cli2.citta);
                            
                            
SELECT c.email, COUNT(c.email) AS ORDINICORRIEREESPRESSO, c.citta
FROM ordine ord JOIN cliente c on ord.email_cliente_ordine = c.email
    join spedizione s on ord.codice_ordine = s.codice_ordine_spedizione
    join corriere corr on s.targa_spedizione = corr.targa
WHERE corr.tipo = 'normale'
GROUP BY c.email, c.citta
HAVING COUNT(c.email) >= ALL (SELECT COUNT(cli2.email)
                              FROM ordine or2 JOIN cliente cli2 on or2.email_cliente_ordine = cli2.email
                                          join spedizione s on or2.codice_ordine = s.codice_ordine_spedizione
                                          join corriere corr on s.targa_spedizione = corr.targa
                              WHERE corr.tipo = 'normale'
                              GROUP BY cli2.email);

