# include <cstdio>
# include <iostream>
# include <fstream>
# include "dependencies/include/libpq-fe.h"

using namespace std;

#define PG_HOST "127.0.0.1"
#define PG_USER "postgres" // modificare con il vostro user
#define PG_DB "Cometa" // modificare con il nome del db
#define PG_PASS "password" // modificare con la vostra password
#define PG_PORT 5432


void checkResults(PGresult *res, const PGconn *conn) {
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		cout << " Risultati inconsistenti " << PQerrorMessage(conn);
		PQclear(res);
		exit(1);
	}
}

int main() {
	char conninfo[250];
	
	sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d",
	        PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);
	
	PGconn *conn = PQconnectdb(conninfo);
	
	if (PQstatus(conn) != CONNECTION_OK) {
		cout << " Errore di connessione \n" << PQerrorMessage(conn);
		PQfinish(conn);
		exit(1);
	}
	
	cout << " Connessione avvenuta correttamente " << endl << endl;
	
	PGresult *res;
	cout << "Mostrare i giochi acquistati nel 2020 e il loro ricavo totale, insieme al numero di pezzi rimasti dal magazzino acquistato e le loro relativa citta' di appartenenza" << endl;
	
	res = PQexec(conn, "SELECT P.nome, inc.quantita AS VENDUTI, (p.prezzo * inc.quantita) AS RICAVOTOTALE, rim.numero_pezzi AS INSTOCK, mag.citta\n"
	                   "FROM prodotto p JOIN inclusione inc ON p.codice_prodotto = inc.codice_prodotto_inclusione\n"
	                   "                JOIN carrello c ON inc.codice_carrello_inclusione = c.codice_carrello\n"
	                   "                JOIN ordine o ON c.codice_carrello = o.codice_carrello_ordine\n"
	                   "                JOIN cliente cli ON o.email_cliente_ordine = cli.email\n"
	                   "                JOIN rimanenza rim ON p.codice_prodotto = rim.codice_prodotto_rimanenza\n"
	                   "                JOIN magazzino mag ON rim.codice_magazzino_rimanenza = mag.codice_magazzino\n"
	                   "WHERE p.categoria = 'Giochi' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020' AND mag.citta = cli.citta\n"
	                   "GROUP BY p.nome, inc.quantita, p.prezzo, rim.numero_pezzi, mag.citta;");
	
	checkResults(res, conn);
	
	int tuple = PQntuples(res);
	int campi = PQnfields(res);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+19s", PQgetvalue(res, i, j));
			
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	PGresult *res2;
	cout << "Mostrare il nome e cognome e il totale speso in fattura dei clienti residenti a Milano e Bologna che hanno rispettivamente effettuato almeno un ordine con pagamento tramite VISA e CONTRASSEGNO il cui costo sia\n"
	        "maggiore del prezzo medio degli ordini dei clienti di Padova. Infine mostrare la loro percentuale di spesa in carrello rispetto alla media padovana" << endl;
	res2 = PQexec(conn, "DROP VIEW IF EXISTS CarrelloMedioPadova;\n"
	                    "CREATE VIEW CarrelloMedioPadova(MEDIA) AS\n"
	                    "SELECT AVG(car.totale)\n"
	                    "FROM Cliente cl JOIN ordine ord ON cl.email = ord.email_cliente_ordine\n"
	                    "                JOIN fattura fat on ord.codice_ordine = fat.codice_ordine_fattura\n"
	                    "                JOIN carrello car on ord.codice_carrello_ordine = car.codice_carrello\n"
	                    "WHERE cl.citta = 'Padova'");
	
	
	res2 = PQexec(conn, "SELECT cl.nome, cl.cognome , CONCAT(COALESCE (fat.totale, car.totale + '10.00'), ' €') AS SPESOINTOTALE, CONCAT(ROUND(cmp.MEDIA, 2), ' €') AS MEDIAPADOVA,\n"
	                    "       concat(ROUND(CAR.totale *100 /cmp.MEDIA, 2), '%') AS RISPETTOAPADOVA\n"
	                    "FROM Cliente cl JOIN ordine ord ON cl.email = ord.email_cliente_ordine\n"
	                    "                JOIN carrello car on ord.codice_carrello_ordine = car.codice_carrello\n"
	                    "                JOIN CarrelloMedioPadova cmp on car.totale >= cmp.MEDIA\n"
	                    "                LEFT JOIN fattura fat on ord.codice_ordine = fat.codice_ordine_fattura\n"
	                    "WHERE ord.tipo_pagamento = 'VISA' AND cl.citta = 'Milano'\n"
	                    "GROUP BY cl.nome, cl.cognome, fat.totale, CMP.MEDIA, CAR.totale\n"
	                    "UNION\n"
	                    "SELECT cl.nome, cl.cognome, CONCAT(COALESCE (fat.totale, car.totale + '20.00'), ' €') AS SPESOINTOTALE, CONCAT(ROUND(cmp.MEDIA, 2), ' €') AS MEDIAPADOVA,\n"
	                    "       concat(ROUND(CAR.totale *100 /cmp.MEDIA, 2), '%') AS RISPETTOAPADOVA\n"
	                    "FROM Cliente cl JOIN ordine ord ON cl.email = ord.email_cliente_ordine\n"
	                    "                JOIN carrello car on ord.codice_carrello_ordine = car.codice_carrello\n"
	                    "                JOIN CarrelloMedioPadova cmp on car.totale >= cmp.MEDIA\n"
	                    "                LEFT JOIN fattura fat on ord.codice_ordine = fat.codice_ordine_fattura\n"
	                    "WHERE ord.tipo_pagamento = 'CONTRASSEGNO' AND cl.citta = 'Bologna'\n"
	                    "GROUP BY cl.nome, cl.cognome, fat.totale, CMP.MEDIA, CAR.totale");
	
	checkResults(res2, conn);
	
	tuple = PQntuples(res2);
	campi = PQnfields(res2);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res2, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+21s", PQgetvalue(res2, i, j));
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	
	cout << "**** Query 3 ****" << endl;
	cout << "Mostrare l'e-mail di tutti i clienti padovani, in ordine alfabetico, solo se hanno ricevuto almeno 2 regali e almeno uno di essi tramite corriere espresso.\n"
	        "Mostrare inoltre il numero di regali tramite corriere espresso ricevuti da quel cliente" << endl;
	PGresult *res3;
	res3 = PQexec(conn, "SELECT cli.amico, count(*)\n"
	                    "FROM cliente cli JOIN ordine o ON cli.email = o.email_cliente_ordine\n"
	                    "                 JOIN carrello car ON car.codice_carrello = o.codice_carrello_ordine\n"
	                    "                 JOIN spedizione s ON o.codice_ordine = s.codice_ordine_spedizione -- per capire se economica\n"
	                    "                 JOIN corriere cor ON cor.targa = s.targa_spedizione -- per capire se economica\n"
	                    "WHERE car.tipo_carrello = 'AMICO'\n"
	                    "  AND cli.amico IN (SELECT cli2.email FROM cliente cli2 WHERE cli2.citta = 'Padova')\n"
	                    "  AND EXISTS(SELECT *\n"
	                    "             FROM cliente cli2 JOIN ordine o2 ON cli2.email = o2.email_cliente_ordine\n"
	                    "                               JOIN carrello car2 ON car2.codice_carrello = o2.codice_carrello_ordine\n"
	                    "             WHERE car2.tipo_carrello = 'AMICO' AND o2.codice_ordine <> o.codice_ordine AND cli2.amico = cli.amico)\n"
	                    "  AND cor.tipo = 'espresso'\n"
	                    "GROUP BY cli.amico\n"
	                    "ORDER BY cli.amico");
	
	checkResults(res3, conn);
	
	tuple = PQntuples(res3);
	campi = PQnfields(res3);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res3, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+20s", PQgetvalue(res3, i, j));
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	
	cout << "Mostrare per ogni filiale il numero di ordini ricevuti, il ricavo totale, quanto hanno fatturato nel 2020 e la differenza tra fatturato e ricavato dai prodotti" << endl;
	PGresult *res4;
	res4 = PQexec(conn, "SELECT cli.citta AS FILIALE , count(*) AS NUMEROORDINI, concat(SUM(c.totale), ' €') AS RICAVITOTALI, concat(SUM(f.totale),' €') AS FATTURATI,\n"
	                    "       concat(SUM(f.totale) - SUM(c.totale), ' €') AS GUADAGNODAMETODOPAGAMENTO\n"
	                    "FROM cliente cli JOIN ordine o on cli.email = o.email_cliente_ordine\n"
	                    "                 JOIN carrello c on c.codice_carrello = o.codice_carrello_ordine\n"
	                    "                 join fattura f on o.codice_ordine = f.codice_ordine_fattura\n"
	                    "                -- JOIN inclusione i on c.codice_carrello = i.codice_carrello_inclusione\n"
	                    "WHERE c.tipo_carrello = 'PERSONALE' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020'\n"
	                    "GROUP BY cli.citta\n"
	                    "UNION\n"
	                    "SELECT c3.citta AS FILIALE , count(*) AS NUMEROORDINI, concat(SUM(c.totale), ' €') AS RICAVITOTALI, concat(SUM(f.totale),' €') AS FATTURATI,\n"
	                    "       concat(SUM(f.totale) - SUM(c.totale), ' €') AS GUADAGNODAMETODOPAGAMENTO\n"
	                    "FROM cliente cli JOIN ordine o on cli.email = o.email_cliente_ordine\n"
	                    "                 JOIN carrello c on c.codice_carrello = o.codice_carrello_ordine\n"
	                    "                 join fattura f on o.codice_ordine = f.codice_ordine_fattura\n"
	                    "                 JOIN cliente c3 on cli.amico = c3.email\n"
	                    "WHERE c.tipo_carrello = 'AMICO' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020'\n"
	                    "GROUP BY c3.citta");
	
	checkResults(res4, conn);
	
	tuple = PQntuples(res4);
	campi = PQnfields(res4);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res4, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+24s", PQgetvalue(res4, i, j));
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	
	cout << "Mostrare le filiale che hanno venduto almeno una console nel 2020.\n"
	        "Poi, per ognuna di esse, elencare i prodotti per la casa e la loro quantità presente in magazzino" << endl;
	PGresult *res5;
	res5 = PQexec(conn, "SELECT m.citta, p.nome, r.numero_pezzi\n"
	                    "FROM magazzino m JOIN rimanenza r on m.codice_magazzino = r.codice_magazzino_rimanenza\n"
	                    "                 JOIN prodotto p on p.codice_prodotto = r.codice_prodotto_rimanenza\n"
	                    "WHERE p.categoria = 'Casa' AND M.citta IN (SELECT C2.citta\n"
	                    "                      FROM prodotto prod JOIN inclusione i on prod.codice_prodotto = i.codice_prodotto_inclusione\n"
	                    "                                       JOIN carrello c on c.codice_carrello = i.codice_carrello_inclusione\n"
	                    "                                       JOIN ordine o on c.codice_carrello = o.codice_carrello_ordine\n"
	                    "                                       JOIN cliente c2 on c2.email = o.email_cliente_ordine\n"
	                    "                      WHERE o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020'\n"
	                    "                      EXCEPT\n"
	                    "                      SELECT C2.citta\n"
	                    "                      FROM prodotto prod JOIN inclusione i on prod.codice_prodotto = i.codice_prodotto_inclusione\n"
	                    "                                         JOIN carrello c on c.codice_carrello = i.codice_carrello_inclusione\n"
	                    "                                         JOIN ordine o on c.codice_carrello = o.codice_carrello_ordine\n"
	                    "                                         JOIN cliente c2 on c2.email = o.email_cliente_ordine\n"
	                    "                      WHERE prod.categoria = 'Console' AND o.data_ordine >= '01-01-2020' AND o.data_ordine <= '31-12-2020')\n"
	                    "GROUP BY m.citta, p.nome, r.numero_pezzi");
	
	checkResults(res5, conn);
	
	tuple = PQntuples(res5);
	campi = PQnfields(res5);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res5, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+20s", PQgetvalue(res5, i, j));
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	
	cout << "Mostrare la filiale/i (i in caso remoto di ordini uguali...) che ha eseguito piu' ordini da sempre" << endl;
	PGresult *res6;
	res6 = PQexec(conn, "SELECT citta, COUNT(email) AS NUMEROORDINI\n"
	                    "FROM ordine JOIN cliente c on ordine.email_cliente_ordine = c.email\n"
	                    "GROUP BY citta\n"
	                    "HAVING COUNT(citta) >= ALL (SELECT COUNT(cli2.citta)\n"
	                    "                            FROM ordine JOIN cliente cli2 on ordine.email_cliente_ordine = cli2.email\n"
	                    "                            GROUP BY cli2.citta)");
	
	checkResults(res6, conn);
	
	tuple = PQntuples(res6);
	campi = PQnfields(res6);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res6, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+20s", PQgetvalue(res6, i, j));
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	
	cout << "Mostrare il cliente/i (i in caso remoto di ordini uguali...) che ha eseguito piu' ordini da sempre usando il corriere espresso e la sua filiale di appartenenza" << endl;
	PGresult *res7;
	res7 = PQexec(conn, "SELECT c.email, COUNT(c.email) AS ORDINICORRIEREESPRESSO, c.citta\n"
	                    "FROM ordine ord JOIN cliente c on ord.email_cliente_ordine = c.email\n"
	                    "    join spedizione s on ord.codice_ordine = s.codice_ordine_spedizione\n"
	                    "    join corriere corr on s.targa_spedizione = corr.targa\n"
	                    "WHERE corr.tipo = 'normale'\n"
	                    "GROUP BY c.email, c.citta\n"
	                    "HAVING COUNT(c.email) >= ALL (SELECT COUNT(cli2.email)\n"
	                    "                              FROM ordine or2 JOIN cliente cli2 on or2.email_cliente_ordine = cli2.email\n"
	                    "                                          join spedizione s on or2.codice_ordine = s.codice_ordine_spedizione\n"
	                    "                                          join corriere corr on s.targa_spedizione = corr.targa\n"
	                    "                              WHERE corr.tipo = 'normale'\n"
	                    "                              GROUP BY cli2.email)");
	
	checkResults(res7, conn);
	
	tuple = PQntuples(res7);
	campi = PQnfields(res7);
	
	// Stampo intestazioni
	cout << "\t\t";
	for (int i = 0; i < campi; ++i) {
		cout << PQfname(res7, i) << "\t\t";
	}
	cout << endl;
	
	// Stampo i valori selezionati
	for (int i = 0; i < tuple; ++i) {
		for (int j = 0; j < campi; ++j) {
			printf("%+23s", PQgetvalue(res7, i, j));
		}
		cout << endl;
	}
	cout << endl;
	cout << endl;
	
	
	PQclear(res);
	PQclear(res2);
	PQclear(res3);
	PQclear(res4);
	PQclear(res5);
	PQclear(res6);
	PQclear(res7);
//
	// BLOCCO LA CHIUSURA DEL PROGRAMMA
	//int x;
	//cin >> x;
}