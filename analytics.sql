-- Consigli di intervento --

/*
	La analytic function "Consigli di intervento" è una procedura che prende in ingresso un edificio, e consiglia alcuni interventi da poter fare su di esso, 
    in caso di necessità, con relativa priorità e su quale elemento in particolare.
*/

/* 	
	Di seguito è presente una stored procedure che serve a calcolare lo stato di un edificio, la quale verrà chiamata ogni giorno da un event per aggiornare
	il proprio valore di ogni edificio presente nel database, il quale potrebbe cambiare in seguito a nuove registrazioni di sensori.
    Per il calcolo dello stato si considerano tutti i valori misurati dai sensori dell'edificio preso in ingresso, che superano il relativo valore di soglia,
    (ossia quelli che fanno scattare un alert). Per ciascuno di essi viene calcolato il distacco tra il valore misurato e il valore di soglia, 
    e verranno poi sommati tutti insieme. Si considera inoltre: se per ogni elemento l'andamento dei valori sballati è in miglioramento,
    in tal caso viene diminuito di 1 il valore della somma calcolata al passo precedente.
    Un valore dello stato basso sta ad indicare che le condizioni dell'edificio sono buone, al contrario, se è alto, non sono ottimali.
    Quindi il valore dello stato cresce se la condizione dell'edificio peggiora nel tempo.
*/    

DROP PROCEDURE IF EXISTS calcoloStatoEdificio;

DELIMITER $$

CREATE PROCEDURE calcoloStatoEdificio (IN cod INT)
BEGIN 
	
    DECLARE sommaDistacco DOUBLE DEFAULT 0;
    DECLARE dis DOUBLE DEFAULT 0;
    DECLARE disPrec DOUBLE DEFAULT 0;
    DECLARE elem INT DEFAULT 0;
    DECLARE elemPrec INT DEFAULT 0;
    DECLARE miglioramento INT DEFAULT 0;
    DECLARE finito INT DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    
	WITH valoriSensori AS
    (
		SELECT E.codice, E.tipologia, L.grandezzaSensore, L.timestampAlert, (L.valoreMisurato - L.sogliaSicurezza) AS distacco
        FROM Piano P INNER JOIN Vano V
			ON P.codice = V.codicePiano
            INNER JOIN Strutturazione S
            ON V.codice = S.codiceVano
            INNER JOIN Elemento E
            ON S.codiceElemento = E.codice
            INNER JOIN Locazione L
            ON E.codice = L.codiceElemento
        WHERE P.codiceEdificio = cod 
			AND L.sogliaSicurezza < L.valoreMisurato
    )
    
	SELECT VS.codice, VS.distacco
	FROM valoriSensori VS
	ORDER BY VS.codice, VS.timestampAlert ;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND 
    SET finito=1 ;
    
    OPEN cursore;
    scan: LOOP
    
		FETCH cursore INTO elem, dis ;
        IF finito=1 THEN
			LEAVE scan;
        END IF;
        
        -- si sommano tutti i distacchi di ciascun valore misurato 
        
        SET sommaDistacco = sommaDistacco + dis;
        
        IF elem = elemPrec THEN
			IF dis < disPrec THEN
				SET miglioramento = 1;
            END IF;
        END IF;
        
        -- il miglioramento avviene solo se l'elemento preso in considerazione è lo stesso e il distacco diminuisce rispetto a quello precedente
        
        IF miglioramento = 1 THEN 
			SET sommaDistacco = sommaDistacco - 1;
        END IF;    
        
        SET elemPrec = elem;
        SET disPrec = dis;
    
    END LOOP scan;
    CLOSE cursore;
    
    -- inserimento del valore aggiornato dello stato in edificio
    
    UPDATE Edificio
    SET stato = sommaDistacco
    WHERE codice = cod;
    
END $$

DELIMITER ;



DROP EVENT IF EXISTS statoEdificio ;

DELIMITER $$

CREATE EVENT statoEdificio
ON SCHEDULE EVERY 1 DAY 
DO
BEGIN

	CALL calcoloStatoEdificio(1) ;
    CALL calcoloStatoEdificio(2) ;
    CALL calcoloStatoEdificio(3) ;
    CALL calcoloStatoEdificio(4) ;
    CALL calcoloStatoEdificio(5) ;
    CALL calcoloStatoEdificio(6) ;
    CALL calcoloStatoEdificio(7) ;
    CALL calcoloStatoEdificio(8) ;
    CALL calcoloStatoEdificio(9) ;

END $$

DELIMITER ;


/*
	La analytic prende in ingresso un edificio e in base al suo stato stabilisce il grado di priorità degli interventi; 
    più è alto lo stato, più il grado di priorità cresce.
    Successivamente si cerca l'elemento che ha avuto il maggiore distacco dal valore di soglia del sensore,
    e in base alla sua tipologia, si consiglia un intervento da fare.
*/

DROP PROCEDURE IF EXISTS consigliInterventi;

DELIMITER $$

CREATE PROCEDURE consigliInterventi (IN cod INT, OUT lavoro VARCHAR(100), OUT elem INT, OUT priorita INT)
BEGIN 

    DECLARE statoEdificio DOUBLE DEFAULT 0;
    DECLARE tip VARCHAR(50) DEFAULT "";
    
    SET statoEdificio =
    (
		SELECT E.stato
        FROM Edificio E
        WHERE E.codice = cod
    );
    
    IF statoEdificio < 5 THEN
		SET priorita = 1;
    END IF;    
    IF statoEdificio >= 5 AND statoEdificio < 15 THEN
		SET priorita = 2;
    END IF;      
    IF statoEdificio >= 15 AND statoEdificio < 30 THEN
		SET priorita = 3;
    END IF;
    IF statoEdificio >= 30 AND statoEdificio < 50 THEN
		SET priorita = 4;
    END IF;
    IF statoEdificio >= 50  THEN
		SET priorita = 5;
    END IF;
    
	WITH valoriSensori AS
    (
		SELECT E.codice, E.tipologia, (L.sogliaSicurezza - L.valoreMisurato) AS distacco
        FROM Piano P INNER JOIN Vano V
			ON P.codice = V.codicePiano
            INNER JOIN Strutturazione S
            ON V.codice = S.codiceVano
            INNER JOIN Elemento E
            ON S.codiceElemento = E.codice
            INNER JOIN Locazione L
            ON E.codice = L.codiceElemento
        WHERE P.codiceEdificio = cod 
			AND L.sogliaSicurezza > L.valoreMisurato
    ),
    
    distaccoMax AS
    (
		SELECT MAX(VS.distacco) as Massimo
		FROM valoriSensori VS
    )
    
    SELECT VS.codice, VS.tipologia INTO elem, tip
    FROM distaccoMax DM 
		INNER JOIN valoriSensori VS
        ON DM.Massimo = VS.distacco 
    LIMIT 1;
    
    IF tip = "parete" THEN
		SET lavoro = "rifacimento dell'intonaco" ;
    END IF;    
    IF tip = "soffitto" THEN
		SET lavoro = "riparazione" ;
    END IF;
    IF tip = "pavimento" THEN
		SET lavoro = "rifacimento di pavimentazione" ;
    END IF;    
        
END $$

DELIMITER ;

-- chiamata di prova

CALL consigliInterventi(7, @lavoro, @elemento, @priorita);

-- l'output ha il seguente significato: @lavoro consigliato da fare sull' @elemento con un certo grado di @priorità.

SELECT @lavoro, @elemento, @priorita ;




-- Stima dei danni --

/*
	La analytic "Stima dei danni" è una function che prende in ingresso un edificio,
    e sommando tutti i danni arrecati agli elementi di quell'edificio al suo stato, 
    calcola un valore in base al quale attribuisce la previsione dei possibili danni all'edificio stesso.
*/

DROP FUNCTION IF EXISTS stimaDeiDanni;
DELIMITER $$

CREATE FUNCTION stimaDeiDanni(edificio INT(50))
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
    DECLARE condizioneEdificio DOUBLE DEFAULT 0;
    DECLARE statoEdificio DOUBLE DEFAULT 0;
    DECLARE stima VARCHAR(50) DEFAULT "";
    
    SELECT ED.stato INTO statoEdificio
    FROM Edificio ED
    WHERE ED.codice=edificio;
    
	WITH vaniTarget AS (
			SELECT V.codice
			FROM Piano P INNER JOIN Vano V ON P.codice=V.codicePiano
			WHERE P.codiceEdificio=edificio
		),
		elementiTarget AS (
			SELECT S.codiceElemento, E.tipologia
			FROM (vaniTarget VT INNER JOIN Strutturazione S ON VT.codice=S.codiceVano) INNER JOIN Elemento E ON S.codiceElemento=E.codice

		),
		danniElementiTerremoti AS (
			SELECT ET.codiceElemento, ET.tipologia AS tipologiaElemento, SU.tipoDanno, SU.entitaDanno 
			FROM elementiTarget ET NATURAL JOIN Subire SU
            WHERE SU.tipoDanno='crollo' OR SU.tipoDanno='cedimento' OR SU.tipoDanno='crepa'
		)
	
    SELECT SUM(DET.entitaDanno) INTO condizioneEdificio
    FROM danniElementiTerremoti DET;
    
    SET condizioneEdificio=condizioneEdificio + statoEdificio;
    
	IF condizioneEdificio<10 THEN
		SET stima='nessun danno';
	ELSEIF condizioneEdificio>=10 AND statoEdificio<=30 THEN
		SET stima='crollo, cedimento, crepa';
	ELSEIF condizioneEdificio>30 THEN
		SET stima='cedimento totale della struttura';
	END IF;
    
    IF condizioneEdificio IS NULL THEN 
		SET stima='dati insufficienti';
	END IF;
	
    RETURN stima;
END $$
DELIMITER ;

-- esempio di chiamata 

SELECT stimaDeiDanni(6) ;




-- Custom analytics --

/*
	L'ultima analytic fa uso del coefficiente di gravità delle varie manifestazioni di calamità, il quale è calcolato mediante il trigger sottostante,
    il quale in base alla media degli stati degli edifici presenti nell'area geografica della manifestazione, attribuisce un valore al livello di gravità.
    La analytic, facendo la media dei livelli di gravità delle calamità avvenute in passato, 
    stabilisce se è possibile o meno costruire (o se possibile sotto certe condizioni) nell'area geografica presa in ingresso. 
*/

DROP TRIGGER IF EXISTS calcolo_livello_gravita;
DELIMITER $$

CREATE TRIGGER calcolo_livello_gravita
BEFORE INSERT ON Manifestazione
FOR EACH ROW 
BEGIN
	
    SET @media_stato=(SELECT AVG(stato)
						FROM edificio
						WHERE nomeAreaGeografica=NEW.nomeAreaGeografica);
	IF (@media_stato BETWEEN 0 AND 10) THEN
		SET NEW.livelloGravita=1;
	END IF;
	IF (@media_stato BETWEEN 11 AND 20) THEN
		SET NEW.livelloGravita=2;
	END IF;
    IF (@media_stato BETWEEN 21 AND 30) THEN
		SET NEW.livelloGravita=3;
	END IF;
    IF (@media_stato BETWEEN 31 AND 40) THEN
		SET NEW.livelloGravita=4;
	END IF;
    IF (@media_stato BETWEEN 41 AND 50) THEN
		SET NEW.livelloGravita=5;
	END IF;
    IF (@media_stato BETWEEN 51 AND 60) THEN
		SET NEW.livelloGravita=6;
	END IF;
    IF (@media_stato BETWEEN 61 AND 70) THEN
		SET NEW.livelloGravita=7;
	END IF;
    IF (@media_stato BETWEEN 71 AND 80) THEN
		SET NEW.livelloGravita=8;
	END IF;
    IF (@media_stato BETWEEN 81 AND 90) THEN
		SET NEW.livelloGravita=9;
	END IF;
    IF (@media_stato>90) THEN
		SET NEW.livelloGravita=10;
	END IF;
    
END $$
DELIMITER ;



DROP FUNCTION IF EXISTS stimaCostruzione;
DELIMITER $$

CREATE FUNCTION stimaCostruzione(areageografica VARCHAR(50))
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
	DECLARE stima VARCHAR(50);
	DECLARE mediaGravita INTEGER DEFAULT 0;
    
	WITH livelliGravita AS(SELECT M.livelloGravita
				FROM  manifestazione M
				WHERE M.nomeAreaGeografica=areaGeografica)
   
	SELECT AVG(LG.livellogravita) INTO mediaGravita
    FROM livelliGravita LG;

	IF mediaGravita<4 AND mediaGravita>0 THEN
		SET stima='puoi costruire in questa area geografica';
	ELSEIF mediaGravita>=4 AND statoEdificio<=6 THEN
		SET stima='possibile costruire in questa area geografica con particolare riguardo';
	ELSEIF mediaGravita>6 THEN
		SET stima='impossibile costruire in questa area geografica';
	END IF;
    
    IF mediaGravita=0 THEN 
		SET stima='dati insufficienti';
	END IF;
	
    RETURN stima;
END $$

-- esempio di chiamata 

SELECT stimaCostruzione("Empoli") ;
