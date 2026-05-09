DROP TRIGGER IF EXISTS check_coeff_rischio;
DELIMITER $$

CREATE TRIGGER check_coeff_rischio
BEFORE INSERT ON Sicurezza
FOR EACH ROW 
BEGIN
	DECLARE check_rischio INTEGER DEFAULT 1;

	IF (NEW.coefficienteDiRischio BETWEEN 0 AND 10) THEN 
		SET check_rischio=0;
	END IF;
	IF check_rischio = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valore coefficiente di rischio sballato';
	END IF;
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS  check_ubicazione;
DELIMITER $$

CREATE TRIGGER check_ubicazione
BEFORE INSERT ON puntodiaccesso
FOR EACH ROW 
BEGIN
	DECLARE check_ubicazione INTEGER DEFAULT 1;

	IF (NEW.ubicazione='N' OR NEW.ubicazione='S' OR NEW.ubicazione='W' OR NEW.ubicazione='E' OR NEW.ubicazione='SW' OR NEW.ubicazione='SE' OR 
    NEW.ubicazione='NE' OR NEW.ubicazione='NW') THEN 
		SET check_ubicazione=0;
	END IF;
	IF check_ubicazione = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ubicazione inesistente';
	END IF;
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS  check_ubicazione2;
DELIMITER $$

CREATE TRIGGER check_ubicazione2
BEFORE INSERT ON elemento
FOR EACH ROW 
BEGIN
	DECLARE check_ubicazione INTEGER DEFAULT 1;

	IF (NEW.ubicazione='N' OR NEW.ubicazione='S' OR NEW.ubicazione='W' OR NEW.ubicazione='E' OR NEW.ubicazione='SW' OR NEW.ubicazione='SE' OR 
    NEW.ubicazione='NE' OR NEW.ubicazione='NW') THEN 
		SET check_ubicazione=0;
	END IF;
	IF check_ubicazione = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ubicazione inesistente';
	END IF;
END $$
DELIMITER ;




DROP TRIGGER IF EXISTS check_livello_gravità;
DELIMITER $$

CREATE TRIGGER check_livello_gravità
BEFORE INSERT ON Manifestazione 
FOR EACH ROW 
BEGIN
	DECLARE check_livello INTEGER DEFAULT 1;

	IF (NEW.livelloGravita BETWEEN 0 AND 10) THEN 
		SET check_livello=0;
	END IF;
	IF check_livello = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valore di livello di gravità sballato';
	END IF;
END $$
DELIMITER ;




DROP TRIGGER IF EXISTS  check_entita_danno;
DELIMITER $$

CREATE TRIGGER check_entita_danno
BEFORE INSERT ON Subire 
FOR EACH ROW 
BEGIN
	DECLARE check_danno INTEGER DEFAULT 1;

	IF (NEW.entitaDanno BETWEEN 0 AND 10) THEN 
		SET check_danno=0;
	END IF;
	IF check_danno = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valore di livello di danno sballato';
	END IF;
END $$
DELIMITER ;




DROP TRIGGER IF EXISTS check_data_progetto;
DELIMITER $$

CREATE TRIGGER check_data_progetto
BEFORE INSERT ON ProgettoEdilizio
FOR EACH ROW 
BEGIN
	DECLARE check_date INTEGER DEFAULT 1;

	IF (NEW.DataPresentazione <= NEW.dataInizio AND NEW.DataInizio <= NEW.DataFine) THEN
		SET check_date=0;
	END IF;
	IF check_date = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date inserite incoerenti';
	END IF;

END $$
DELIMITER ;



DROP TRIGGER IF EXISTS check_date;
DELIMITER $$

CREATE TRIGGER check_date 
BEFORE INSERT ON Stadio
FOR EACH ROW 
BEGIN
	
    DECLARE check_date_inizioStadio INTEGER DEFAULT 1;
    SET @dataInizio =(SELECT dataInizioProgetto
						FROM progettoEdilizio
						WHERE NEW.codiceProgettoEdilizio=codice);
	SET @dataFine =(SELECT dataFineProgetto
						FROM progettoEdilizio
						WHERE NEW.codiceProgettoEdilizio=codice);
	IF (NEW.dataInizio >= @dataInizio AND dataInizio <= @dataFine AND NEW.dataFineStimata >= @dataInizio AND NEW.dataFineStimata <= @dataFine AND NEW.dataInizio <= NEW.dataFineStimata ) THEN 
		SET check_date_inizioStadio=0;
	END IF;
	IF check_date_inizioStadio = 1 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'date di inizio stadio inserite incoerenti con il progetto';
	END IF;

	
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS refresh_numero_vani;
DELIMITER $$

CREATE TRIGGER refresh_numero_vani
AFTER INSERT ON vano
FOR EACH ROW 
BEGIN
	WITH edificioTarget AS(SELECT codiceEdificio
				FROM piano
				WHERE codice=NEW.codicePiano)
	UPDATE edificio
	SET numeroVani=numeroVani+1
            WHERE codice=edificioTarget;
	
END $$
DELIMITER ;
