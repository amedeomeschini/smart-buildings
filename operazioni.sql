-- Operazione 1
DROP PROCEDURE IF EXISTS Operazione1;
DELIMITER $$
CREATE PROCEDURE Operazione1(IN codice INT(50))
BEGIN
	SELECT DISTINCT C.tipologiaLavoro
	FROM (ProgettoEdilizio P INNER JOIN Composizione C ON P.codice=C.codiceProgettoEdilizio)
	WHERE P.codiceEdificio=codice;
END $$
DELIMITER ;

-- chiamata di prova
CALL Operazione1(3);



-- Operazione 2
DROP PROCEDURE IF EXISTS Operazione2;
DELIMITER $$
CREATE PROCEDURE Operazione2(IN inizioStadio DATE, IN fineStadio DATE, IN progettoEdilizio INT(50))
BEGIN
DECLARE costoManodoperaTot INT DEFAULT 0;
DECLARE costoMaterialiTot INT DEFAULT 0;
DECLARE costoTot INT DEFAULT 0;

WITH lavoriTarget AS (
	SELECT S.tipologiaLavoro
    FROM Svolgimento S
    WHERE S.dataInizioStadio=inizioStadio AND S.dataFineStimataStadio=fineStadio AND S.codiceProgettoEdilizio=progettoEdilizio
)

SELECT SUM(L.costoManodopera) INTO costoManodoperaTot
FROM Lavoro L INNER JOIN lavoriTarget LT ON L.tipologia=LT.tipologiaLavoro;

WITH lavoriTarget AS (
	SELECT S.tipologiaLavoro
    FROM Svolgimento S
    WHERE S.dataInizioStadio=inizioStadio AND S.dataFineStimataStadio=fineStadio AND S.codiceProgettoEdilizio=progettoEdilizio
)

SELECT SUM(M.Prezzo) INTO costoMaterialiTot 
FROM (lavoriTarget LT2 INNER JOIN Utilizzo U ON LT2.tipologiaLavoro=U.tipologiaLavoro) INNER JOIN Materiale M ON (U.nomeMateriale=M.nome AND U.codiceLottoMateriale=M.codiceLotto);

SET costoTot=costoManodoperaTot+costoMaterialiTot;
SELECT costoTot AS costoTotale;
END $$
DELIMITER ;

-- chiamata di prova
CALL Operazione2("2020-02-05","2020-04-18",1);



-- Operazione 3
DROP PROCEDURE IF EXISTS Operazione3;
DELIMITER $$

CREATE PROCEDURE Operazione3(IN edificio INT(50))
BEGIN
WITH pianiTarget AS(
	SELECT P.codice
    FROM Piano P
    WHERE P.codiceEdificio=edificio
),
vaniTarget AS(
	SELECT V.codice
    FROM Vano V INNER JOIN pianiTarget PT ON V.codicePiano=PT.codice
),
elementiTarget AS(
	SELECT S.codiceElemento
    FROM Strutturazione S INNER JOIN vaniTarget VT ON S.codiceVano=VT.codice
)

SELECT ET.codiceElemento, SU.tipoDanno
FROM Subire SU NATURAL JOIN elementiTarget ET;
END $$
DELIMITER ;

-- chiamata di prova
CALL Operazione3(3);


-- Operazione 4
DROP PROCEDURE IF EXISTS Operazione4;
DELIMITER $$

CREATE PROCEDURE Operazione4()
BEGIN
WITH areeGeograficheTarget AS (
	SELECT DISTINCT M.nomeAreaGeografica, M.livelloGravita
	FROM Manifestazione M
	WHERE M.livelloGravita>=ALL	(
									SELECT M2.livelloGravita
									FROM Manifestazione M2
									WHERE M2.nomeAreaGeografica=M.nomeAreaGeografica
								)
)

SELECT AGT.nomeAreaGeografica, DENSE_RANK() OVER(
													ORDER BY AGT.livelloGravita DESC
												) AS Classifica
FROM areeGeograficheTarget AGT;
END $$
DELIMITER ;

-- chiamata di prova
CALL Operazione4();



-- Operazione 5
DROP PROCEDURE IF EXISTS Operazione5;
DELIMITER $$

CREATE PROCEDURE Operazione5(IN numeroMaxLavoratori INT, IN giorniSettimana VARCHAR(100), IN orarioLavoro VARCHAR(50), IN dataInizioS DATE, IN dataFineStimataS DATE, codicePE INT(50))
BEGIN
INSERT INTO Turno
VALUES(numeroMaxLavoratori,giorniSettimana,orarioLavoro,dataInizioS,dataFineStimataS,codicePE);
END $$
DELIMITER ;


-- Operazione 6
DROP PROCEDURE IF EXISTS Operazione6;
DELIMITER $$

CREATE PROCEDURE Operazione6(timestampRegistrazione BIGINT, tipologiaRegistrazione VARCHAR(50), diagnosi VARCHAR(100))
BEGIN
INSERT INTO Registrazione
VALUES(timestampRegistrazione,tipologiaRegistrazione,diagnosi);
END $$
DELIMITER ;



-- Operazione 7
DROP PROCEDURE IF EXISTS Operazione7;
DELIMITER $$

CREATE PROCEDURE Operazione7(IN codiceEd INT(50))
BEGIN
DECLARE numeroVani INT DEFAULT 0;
    
SELECT COUNT(*) INTO NumeroVani
FROM Piano P INNER JOIN Vano V ON P.codice=V.codicePiano
WHERE P.codiceEdificio=codiceEd;
    
SELECT numeroVani;
END $$
DELIMITER ;

-- chiamata di prova 
CALL Operazione7(4);


-- Operazione 8
DROP PROCEDURE IF EXISTS Operazione8;
DELIMITER $$

CREATE PROCEDURE Operazione8(IN nomeAG VARCHAR(50))
BEGIN
SELECT S.tipologiaRischio, S.dataAggiornamentoRischio, S.coefficienteDiRischio
FROM Sicurezza S
WHERE S.nomeAreaGeografica=nomeAG
ORDER BY S.tipologiaRischio, S.dataAggiornamentoRischio;
END $$
DELIMITER ;

-- chiamata di prova
CALL Operazione8("Empoli");
