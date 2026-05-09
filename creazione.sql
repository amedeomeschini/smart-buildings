DROP DATABASE IF EXISTS SmartBuildings;
CREATE DATABASE SmartBuildings;
USE SmartBuildings;
SET foreign_key_checks = 1;

DROP TABLE IF EXISTS `AreaGeografica`;
CREATE TABLE `AreaGeografica` (
  `nome` varchar(50) NOT NULL,
  PRIMARY KEY (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Rischio`;
CREATE TABLE `Rischio` (
  `tipologia` varchar(50) NOT NULL,
  `dataAggiornamento` date NOT NULL,
  PRIMARY KEY (`tipologia`,`dataAggiornamento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Sicurezza`;
CREATE TABLE `Sicurezza` (
  `nomeAreaGeografica` varchar(50) NOT NULL,
  `tipologiaRischio` varchar(50) NOT NULL,
  `dataAggiornamentoRischio` date NOT NULL,
  `coefficienteDiRischio` int DEFAULT NULL,
  PRIMARY KEY (`nomeAreaGeografica`,`tipologiaRischio`,`dataAggiornamentoRischio`),
  KEY `Tipologia rischio_idx` (`tipologiaRischio`),
  CONSTRAINT `Sicurezza - AreaGeografica` FOREIGN KEY (`nomeAreaGeografica`) REFERENCES `AreaGeografica` (`nome`),
  CONSTRAINT `Tipologia rischio` FOREIGN KEY (`tipologiaRischio`) REFERENCES `Rischio` (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Edificio`;
CREATE TABLE `Edificio` (
  `codice` int NOT NULL,
  `tipologia` varchar(50) DEFAULT NULL,
  `topologia` varchar(50) DEFAULT NULL,
  `stato` double DEFAULT NULL,
  `numeroVani` int DEFAULT NULL,
  `nomeAreaGeografica` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`codice`),
  KEY `Nome area geografica_idx` (`nomeAreaGeografica`),
  CONSTRAINT `Edificio - AreaGeografica` FOREIGN KEY (`nomeAreaGeografica`) REFERENCES `AreaGeografica` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Piano`;
CREATE TABLE `Piano` (
  `codice` int NOT NULL,
  `pianta` varchar(50) DEFAULT NULL,
  `codiceEdificio` int DEFAULT NULL,
  PRIMARY KEY (`codice`),
  KEY `Codice edificio_idx` (`codiceEdificio`),
  CONSTRAINT `Piano - Edificio` FOREIGN KEY (`codiceEdificio`) REFERENCES `Edificio` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Vano`;
CREATE TABLE `Vano` (
  `codice` int NOT NULL,
  `codicePiano` int DEFAULT NULL,
  `altezzaMinimaMansarda` int DEFAULT NULL,
  `altezzaMediaMansarda` int DEFAULT NULL,
  `altezza` int DEFAULT NULL,
	CHECK (`altezza` > 0),
  `larghezza` int DEFAULT NULL,
	CHECK (`larghezza` > 0),
  `lunghezza` int DEFAULT NULL,
	CHECK (`lunghezza` > 0),
  PRIMARY KEY (`codice`),
  KEY `Codice piano_idx` (`codicePiano`),
  CONSTRAINT `Vano - Piano` FOREIGN KEY (`codicePiano`) REFERENCES `Piano` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Mansarda`;
CREATE TABLE `Mansarda` (
  `altezzaMinima` int NOT NULL,
	CHECK (`altezzaMinima` > 0),
  `altezzaMedia` int NOT NULL,
	CHECK (`altezzaMedia` > 0),
  PRIMARY KEY (`altezzaMinima`,`altezzaMedia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Impiego`;
CREATE TABLE `Impiego` (
  `nomeFunzionalita` varchar(50) NOT NULL,
  `codiceVano` int NOT NULL,
  PRIMARY KEY (`nomeFunzionalita`,`codiceVano`),
  KEY `Impiego - Vano_idx` (`codiceVano`),
  CONSTRAINT `Impiego - Vano` FOREIGN KEY (`codiceVano`) REFERENCES `Vano` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Funzionalita`;
CREATE TABLE `Funzionalita` (
  `nome` varchar(50) NOT NULL,
  PRIMARY KEY (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `DimensioniMax`;
CREATE TABLE `DimensioniMax` (
  `altezza` int NOT NULL,
	CHECK (`altezza` > 0),
  `lunghezza` int NOT NULL,
	CHECK (`lunghezza` > 0),
  `larghezza` int NOT NULL,
	CHECK (`larghezza` > 0),
  PRIMARY KEY (`altezza`,`lunghezza`,`larghezza`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Esterno`;
CREATE TABLE `Esterno` (
  `tipologia` varchar(50) NOT NULL,
  PRIMARY KEY (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `PuntoDiAccesso`;
CREATE TABLE `PuntoDiAccesso` (
  `codice` int NOT NULL,
  `ubicazione` varchar(50) DEFAULT NULL,
  `tipologia` varchar(50) DEFAULT NULL,
  `larghezza` int DEFAULT NULL,
	CHECK (`larghezza` > 0),
  `altezza` int DEFAULT NULL,
	CHECK (`altezza` > 0),
  `tipologiaEsterno` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`codice`),
  KEY `Punto di accesso - esterno_idx` (`tipologiaEsterno`),
  CONSTRAINT `Punto di accesso - esterno` FOREIGN KEY (`tipologiaEsterno`) REFERENCES `Esterno` (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Collegamento`;
CREATE TABLE `Collegamento` (
  `codiceVano` int NOT NULL,
  `codicePuntoDiAccesso` int NOT NULL,
  PRIMARY KEY (`codiceVano`,`codicePuntoDiAccesso`),
  KEY `Collegamento - punto di accesso_idx` (`codicePuntoDiAccesso`),
  CONSTRAINT `Collegamento - punto di accesso` FOREIGN KEY (`codicePuntoDiAccesso`) REFERENCES `PuntoDiAccesso` (`codice`),
  CONSTRAINT `Collegamento - vano` FOREIGN KEY (`codiceVano`) REFERENCES `Vano` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Dimensioni`;
CREATE TABLE `Dimensioni` (
  `altezza` int NOT NULL,
	CHECK (`altezza` > 0),
  `larghezza` int NOT NULL,
	CHECK (`larghezza` > 0),
  PRIMARY KEY (`altezza`,`larghezza`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Elemento`;
CREATE TABLE `Elemento` (
  `codice` int NOT NULL,
  `tipologia` varchar(50) DEFAULT NULL,
  `ubicazione` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Strutturazione`;
CREATE TABLE `Strutturazione` (
  `codiceVano` int NOT NULL,
  `codiceElemento` int NOT NULL,
  PRIMARY KEY (`codiceVano`,`codiceElemento`),
  KEY `Strutturazione - elemento_idx` (`codiceElemento`),
  CONSTRAINT `Strutturazione - elemento` FOREIGN KEY (`codiceElemento`) REFERENCES `Elemento` (`codice`),
  CONSTRAINT `Strutturazione - vano` FOREIGN KEY (`codiceVano`) REFERENCES `Vano` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `ProgettoEdilizio`;
CREATE TABLE `ProgettoEdilizio` (
  `codice` int NOT NULL,
  `dataPresentazione` date DEFAULT NULL,
  `tipologia` varchar(50) DEFAULT NULL,
  `dataInizio` date DEFAULT NULL,
  `dataFine` date DEFAULT NULL,
  `codiceEdificio` int DEFAULT NULL,
  PRIMARY KEY (`codice`),
  KEY `ProgettoEdilizio - Edificio_idx` (`codiceEdificio`),
  CONSTRAINT `ProgettoEdilizio - Edificio` FOREIGN KEY (`codiceEdificio`) REFERENCES `Edificio` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Lavoro`;
CREATE TABLE `Lavoro` (
  `tipologia` varchar(50) NOT NULL,
  `costoManodopera` int DEFAULT NULL,
	CHECK (`costoManodopera` > 0),
  PRIMARY KEY (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Composizione`;
CREATE TABLE `Composizione` (
  `codiceProgettoEdilizio` int NOT NULL,
  `tipologiaLavoro` varchar(50) NOT NULL,
  PRIMARY KEY (`codiceProgettoEdilizio`,`tipologiaLavoro`),
  KEY `Composizione - Lavoro_idx` (`tipologiaLavoro`),
  CONSTRAINT `Composizione - Lavoro` FOREIGN KEY (`tipologiaLavoro`) REFERENCES `Lavoro` (`tipologia`),
  CONSTRAINT `Composizione - ProgettoEdilizio` FOREIGN KEY (`codiceProgettoEdilizio`) REFERENCES `ProgettoEdilizio` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Costo`;
CREATE TABLE `Costo` (
  `tipologia` varchar(50) NOT NULL,
  PRIMARY KEY (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Materiale`;
CREATE TABLE `Materiale` (
  `nome` varchar(50) NOT NULL,
  `codiceLotto` int NOT NULL,
  `nomeFornitore` varchar(50) DEFAULT NULL,
  `dataAcquisto` date DEFAULT NULL,
  `prezzo` int DEFAULT NULL,
	CHECK (`prezzo` > 0),
  `tipologiaCosto` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nome`,`codiceLotto`),
  CONSTRAINT `Materiale - Costo` FOREIGN KEY (`tipologiaCosto`) REFERENCES `Costo` (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Utilizzo`;
CREATE TABLE `Utilizzo` (
  `tipologiaLavoro` varchar(50) NOT NULL,
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  PRIMARY KEY (`tipologiaLavoro`,`nomeMateriale`,`codiceLottoMateriale`),
  KEY `Utilizzo - Materiale_idx` (`nomeMateriale`,`codiceLottoMateriale`),
  CONSTRAINT `Utilizzo - Lavoro` FOREIGN KEY (`tipologiaLavoro`) REFERENCES `Lavoro` (`tipologia`),
  CONSTRAINT `Utilizzo - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Intonaco`;
CREATE TABLE `Intonaco` (
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  `tipologia` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nomeMateriale`,`codiceLottoMateriale`),
  CONSTRAINT `Intonaco - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Strato`;
CREATE TABLE `Strato` (
  `Spessore` int NOT NULL,
	CHECK (`spessore` > 0),
  PRIMARY KEY (`Spessore`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Suddivisione`;
CREATE TABLE `Suddivisione` (
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  `spessoreStrato` int NOT NULL,
	CHECK (`spessoreStrato` > 0),
  PRIMARY KEY (`nomeMateriale`,`spessoreStrato`,`codiceLottoMateriale`),
  KEY `Suddivisione - Materiale_idx` (`nomeMateriale`,`codiceLottoMateriale`),
  KEY `Suddivisione - Strato_idx` (`spessoreStrato`),
  CONSTRAINT `Suddivisione - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`),
  CONSTRAINT `Suddivisione - Strato` FOREIGN KEY (`spessoreStrato`) REFERENCES `Strato` (`Spessore`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Alveolatura`;
CREATE TABLE `Alveolatura` (
  `tipologia` varchar(50) NOT NULL,
  PRIMARY KEY (`tipologia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Mattoni`;
CREATE TABLE `Mattoni` (
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  `materiale` varchar(50) DEFAULT NULL,
  `dimensione` varchar(50) DEFAULT NULL,
  `tipologiaAlveolatura` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nomeMateriale`,`codiceLottoMateriale`),
  KEY `Mattoni - Alveolatura_idx` (`tipologiaAlveolatura`),
  CONSTRAINT `Mattoni - Alveolatura` FOREIGN KEY (`tipologiaAlveolatura`) REFERENCES `Alveolatura` (`tipologia`),
  CONSTRAINT `Mattoni - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Piastrelle`;
CREATE TABLE `Piastrelle` (
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  `materiale` varchar(50) DEFAULT NULL,
  `dimensione` varchar(50) DEFAULT NULL,
  `disegno` varchar(50) DEFAULT NULL,
  `forma` varchar(50) DEFAULT NULL,
  `fuga` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nomeMateriale`,`codiceLottoMateriale`),
  CONSTRAINT `Piastrelle - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Pietra`;
CREATE TABLE `Pietra` (
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  `tipologia` varchar(50) DEFAULT NULL,
  `pesoMedio` int DEFAULT NULL,
	CHECK (`pesoMedio` > 0),
  `superficieMedia` int DEFAULT NULL,
	CHECK (`superficieMedia` > 0),
  `disposizione` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`nomeMateriale`,`codiceLottoMateriale`),
  CONSTRAINT `Pietra - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Altro`;
CREATE TABLE `Altro` (
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  `costituzione` varchar(50) DEFAULT NULL,
  `lunghezza` int DEFAULT NULL,
	CHECK (`lunghezza` > 0),
  `spessore` int DEFAULT NULL,
	CHECK (`spessore` > 0),
  `larghezza` int DEFAULT NULL,
	CHECK (`larghezza` > 0),
  PRIMARY KEY (`nomeMateriale`,`codiceLottoMateriale`),
  CONSTRAINT `Altro - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Misure`;
CREATE TABLE `Misure` (
  `lunghezza` int NOT NULL,
	CHECK (`lunghezza` > 0),
  `spessore` int NOT NULL,
	CHECK (`spessore` > 0),
  `larghezza` int NOT NULL,
	CHECK (`larghezza` > 0),
  PRIMARY KEY (`lunghezza`,`spessore`,`larghezza`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Stadio`;
CREATE TABLE `Stadio` (
  `dataInizio` date NOT NULL,
  `dataFineStimata` date NOT NULL,
  `codiceProgettoEdilizio` int NOT NULL,
  PRIMARY KEY (`dataInizio`,`dataFineStimata`,`codiceProgettoEdilizio`),
  KEY `Stadio - ProgettoEdilizio_idx` (`codiceProgettoEdilizio`),
  CONSTRAINT `Stadio - ProgettoEdilizio` FOREIGN KEY (`codiceProgettoEdilizio`) REFERENCES `ProgettoEdilizio` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Svolgimento`;
CREATE TABLE `Svolgimento` (
  `dataInizioStadio` date NOT NULL,
  `dataFineStimataStadio` date NOT NULL,
  `codiceProgettoEdilizio` int NOT NULL,
  `tipologiaLavoro` varchar(50) NOT NULL,
  PRIMARY KEY (`dataInizioStadio`,`dataFineStimataStadio`,`codiceProgettoEdilizio`,`tipologiaLavoro`),
  KEY `Svolgimento - ProgettoEdilizio_idx` (`codiceProgettoEdilizio`),
  KEY `Svolgimento - Lavoro_idx` (`tipologiaLavoro`),
  CONSTRAINT `Svolgimento - Lavoro` FOREIGN KEY (`tipologiaLavoro`) REFERENCES `Lavoro` (`tipologia`),
  CONSTRAINT `Svolgimento - ProgettoEdilizio` FOREIGN KEY (`codiceProgettoEdilizio`) REFERENCES `ProgettoEdilizio` (`codice`),
  CONSTRAINT `Svolgimento - Stadio` FOREIGN KEY (`dataInizioStadio`, `dataFineStimataStadio`) REFERENCES `Stadio` (`dataInizio`, `dataFineStimata`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Turno`;
CREATE TABLE `Turno` (
  `numeroMaxLavoratori` int NOT NULL,
	CHECK (`numeroMaxLavoratori` > 0),
  `giorniSettimana` varchar(100) NOT NULL,
  `orarioLavoro` varchar(50) NOT NULL,
  `dataInizioStadio` date NOT NULL,
  `dataFineStimataStadio` date NOT NULL,
  `codiceProgettoEdilizio` int NOT NULL,
  PRIMARY KEY (`numeroMaxLavoratori`,`giorniSettimana`,`orarioLavoro`,`dataInizioStadio`,`dataFineStimataStadio`,`codiceProgettoEdilizio`),
  KEY `Turno - Stadio_idx` (`dataInizioStadio`,`dataFineStimataStadio`),
  KEY `Turno - ProgettoEdilizio_idx` (`codiceProgettoEdilizio`),
  CONSTRAINT `Turno - ProgettoEdilizio` FOREIGN KEY (`codiceProgettoEdilizio`) REFERENCES `ProgettoEdilizio` (`codice`),
  CONSTRAINT `Turno - Stadio` FOREIGN KEY (`dataInizioStadio`, `dataFineStimataStadio`) REFERENCES `Stadio` (`dataInizio`, `dataFineStimata`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `CapoCantiere`;
CREATE TABLE `Capocantiere` (
  `codice` int NOT NULL,
  `numeroMaxLavoratori` int DEFAULT NULL,
	CHECK (`numeroMaxLavoratori` > 0),
  PRIMARY KEY (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Supervisione`;
CREATE TABLE `Supervisione` (
  `codiceCapoCantiere` int NOT NULL,
  `numeroMaxLavoratori` int NOT NULL,
	CHECK (`numeroMaxLavoratori` > 0),
  `giorniSettimana` varchar(100) NOT NULL,
  `orarioLavoro` varchar(50) NOT NULL,
  `dataInizioStadio` date NOT NULL,
  `dataFineStimataStadio` date NOT NULL,
  `codiceProgettoEdilizio` int NOT NULL,
  PRIMARY KEY (`codiceCapoCantiere`,`codiceProgettoEdilizio`,`dataFineStimataStadio`,`dataInizioStadio`,`orarioLavoro`,`giorniSettimana`,`numeroMaxLavoratori`),
  KEY `Supervisione - Stadio_idx` (`dataInizioStadio`,`dataFineStimataStadio`),
  KEY `Supervisione - ProgettoEdilizio_idx` (`codiceProgettoEdilizio`),
  CONSTRAINT `Supervisione - Capocantiere` FOREIGN KEY (`codiceCapoCantiere`) REFERENCES `Capocantiere` (`codice`),
  CONSTRAINT `Supervisione - ProgettoEdilizio` FOREIGN KEY (`codiceProgettoEdilizio`) REFERENCES `ProgettoEdilizio` (`codice`),
  CONSTRAINT `Supervisione - Stadio` FOREIGN KEY (`dataInizioStadio`, `dataFineStimataStadio`) REFERENCES `Stadio` (`dataInizio`, `dataFineStimata`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Lavoratore`;
CREATE TABLE `Lavoratore` (
  `codice` int NOT NULL,
  PRIMARY KEY (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `ImpiegoLavoratore`;
CREATE TABLE `ImpiegoLavoratore` (
  `codiceLavoratore` int NOT NULL,
  `tipologiaLavoro` varchar(50) NOT NULL,
  `numeroMaxLavoratoriTurno` int NOT NULL,
	CHECK (`numeroMaxLavoratoriTurno` > 0),
  `giorniSettimanaTurno` varchar(100) NOT NULL,
  `orarioLavoroTurno` varchar(50) NOT NULL,
  `dataInizioStadio` date NOT NULL,
  `dataFineStimataStadio` date NOT NULL,
  `codiceProgettoEdilizio` int NOT NULL,
  `durata` int DEFAULT NULL,
	CHECK (`durata` > 0),
  PRIMARY KEY (`codiceLavoratore`,`codiceProgettoEdilizio`,`dataFineStimataStadio`,`dataInizioStadio`,`orarioLavoroTurno`,`giorniSettimanaTurno`,`numeroMaxLavoratoriTurno`,`tipologiaLavoro`),
  KEY `Impiego - Lavoro_idx` (`tipologiaLavoro`),
  KEY `Impiego - Turno_idx` (`numeroMaxLavoratoriTurno`,`giorniSettimanaTurno`,`orarioLavoroTurno`),
  KEY `Impiego - Stadio_idx` (`dataInizioStadio`,`dataFineStimataStadio`),
  KEY `Impiego - ProgettoEdilizio_idx` (`codiceProgettoEdilizio`),
  CONSTRAINT `Impiego - Lavoratore` FOREIGN KEY (`codiceLavoratore`) REFERENCES `Lavoratore` (`codice`),
  CONSTRAINT `Impiego - Lavoro` FOREIGN KEY (`tipologiaLavoro`) REFERENCES `Lavoro` (`tipologia`),
  CONSTRAINT `Impiego - ProgettoEdilizio` FOREIGN KEY (`codiceProgettoEdilizio`) REFERENCES `ProgettoEdilizio` (`codice`),
  CONSTRAINT `Impiego - Stadio` FOREIGN KEY (`dataInizioStadio`, `dataFineStimataStadio`) REFERENCES `Stadio` (`dataInizio`, `dataFineStimata`),
  CONSTRAINT `Impiego - Turno` FOREIGN KEY (`numeroMaxLavoratoriTurno`, `giorniSettimanaTurno`, `orarioLavoroTurno`) REFERENCES `Turno` (`numeroMaxLavoratori`, `giorniSettimana`, `orarioLavoro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Direzione`;
CREATE TABLE `Direzione` (
  `codiceLavoratore` int NOT NULL,
  `codiceCapoCantiere` int NOT NULL,
  PRIMARY KEY (`codiceLavoratore`,`codiceCapoCantiere`),
  KEY `Direzione - Capocantiere_idx` (`codiceCapoCantiere`),
  CONSTRAINT `Direzione - Capocantiere` FOREIGN KEY (`codiceCapoCantiere`) REFERENCES `Capocantiere` (`codice`),
  CONSTRAINT `Direzione - Lavoratore` FOREIGN KEY (`codiceLavoratore`) REFERENCES `Lavoratore` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Costruzione`;
CREATE TABLE `Costruzione` (
  `codiceElemento` int NOT NULL,
  `nomeMateriale` varchar(50) NOT NULL,
  `codiceLottoMateriale` int NOT NULL,
  PRIMARY KEY (`codiceElemento`,`nomeMateriale`,`codiceLottoMateriale`),
  KEY `Costruzione - Materiale_idx` (`nomeMateriale`,`codiceLottoMateriale`),
  CONSTRAINT `Costruzione - Elemento` FOREIGN KEY (`codiceElemento`) REFERENCES `Elemento` (`codice`),
  CONSTRAINT `Costruzione - Materiale` FOREIGN KEY (`nomeMateriale`, `codiceLottoMateriale`) REFERENCES `Materiale` (`nome`, `codiceLotto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Alert`;
CREATE TABLE `Alert` (
  `timestamp` bigint NOT NULL,
	CHECK (`timestamp` >= 0),
  PRIMARY KEY (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Sensore`;
CREATE TABLE `Sensore` (
  `grandezza` varchar(50) NOT NULL,
  `valoreMisurato` double NOT NULL,
  PRIMARY KEY (`grandezza`,`valoreMisurato`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Locazione`;
CREATE TABLE `Locazione` (
  `codiceElemento` int NOT NULL,
  `grandezzaSensore` varchar(50) NOT NULL,
  `timestampAlert` bigint NOT NULL,
	CHECK (`timestampAlert` >= 0),
  `valoreMisurato` double NOT NULL,
  `sogliaSicurezza` double DEFAULT NULL,
  PRIMARY KEY (`codiceElemento`,`timestampAlert`,`grandezzaSensore`,`valoreMisurato`),
  KEY `Locazione - Sensore_idx` (`grandezzaSensore`),
  KEY `Locazione - Alert_idx` (`timestampAlert`),
  CONSTRAINT `Locazione - Alert` FOREIGN KEY (`timestampAlert`) REFERENCES `Alert` (`timestamp`),
  CONSTRAINT `Locazione - Elemento` FOREIGN KEY (`codiceElemento`) REFERENCES `Elemento` (`codice`),
  CONSTRAINT `Locazione - Sensore` FOREIGN KEY (`grandezzaSensore`,`valoreMisurato`) REFERENCES `Sensore` (`grandezza`,`valoreMisurato`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Registrazione`;
CREATE TABLE `Registrazione` (
  `tipologia` varchar(50) NOT NULL,
  `timestamp` bigint NOT NULL,
	CHECK (`timestamp` > 0),
  `diagnosi` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`tipologia`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Memorizzazione` (
  `timestampRegistrazione` bigint NOT NULL,
	CHECK (`timestampRegistrazione` > 0),
  `tipologiaRegistrazione` varchar(50) NOT NULL,
  `grandezzaSensore` varchar(50) NOT NULL,
  `valoreMisurato` double NOT NULL,
  PRIMARY KEY (`timestampRegistrazione`,`grandezzaSensore`,`tipologiaRegistrazione`,`valoreMisurato`),
  KEY `Memorizzazione - Sensore_idx` (`grandezzaSensore`),
  KEY `Memorizzazione - registrazione_idx` (`tipologiaRegistrazione`,`timestampRegistrazione`),
  CONSTRAINT `Memorizzazione - Registrazione` FOREIGN KEY (`tipologiaRegistrazione`, `timestampRegistrazione`) REFERENCES `Registrazione` (`tipologia`, `timestamp`),
  CONSTRAINT `Memorizzazione - Sensore` FOREIGN KEY (`grandezzaSensore`,`valoreMisurato`) REFERENCES `Sensore` (`grandezza`,`valoreMisurato`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



DROP TABLE IF EXISTS `Calamita`;
CREATE TABLE `Calamita` (
  `tipo` varchar(50) NOT NULL,
  `dataAccadimento` date NOT NULL,
  PRIMARY KEY (`tipo`,`dataAccadimento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Danno`;
CREATE TABLE `Danno` (
  `tipo` varchar(50) NOT NULL,
  `entitaDanno` int NOT NULL,
  PRIMARY KEY (`tipo`,`entitaDanno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Manifestazione`;
CREATE TABLE `Manifestazione` (
  `nomeAreaGeografica` varchar(50) NOT NULL,
  `tipoCalamita` varchar(50) NOT NULL,
  `dataAccadimento` date NOT NULL,
  `livelloGravita` int DEFAULT NULL,
  PRIMARY KEY (`nomeAreaGeografica`,`tipoCalamita`,`dataAccadimento`),
  KEY `Manifestazione - Calamita_idx` (`tipoCalamita`),
  CONSTRAINT `Manifestazione - AreaGeografica` FOREIGN KEY (`nomeAreaGeografica`) REFERENCES `AreaGeografica` (`nome`),
  CONSTRAINT `Manifestazione - Calamita` FOREIGN KEY (`tipoCalamita`,`dataAccadimento`) REFERENCES `Calamita` (`tipo`,`dataAccadimento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Subire`;
CREATE TABLE `Subire` (
  `tipoDanno` varchar(50) NOT NULL,
  `codiceElemento` int NOT NULL,
  `entitaDanno` int NOT NULL,
  PRIMARY KEY (`tipoDanno`,`codiceElemento`),
  KEY `Subire - Elemento_idx` (`codiceElemento`),
  CONSTRAINT `Subire - Danno` FOREIGN KEY (`tipoDanno`,`entitaDanno`) REFERENCES `Danno` (`tipo`,`entitaDanno`),
  CONSTRAINT `Subire - Elemento` FOREIGN KEY (`codiceElemento`) REFERENCES `Elemento` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `Installazione`;
CREATE TABLE `Installazione` (
  `tipoDanno` varchar(50) NOT NULL,
  `entitaDanno` int NOT NULL,
  `grandezzaSensore` varchar(50) NOT NULL,
  `valoreMisurato` double NOT NULL,
  `codiceElemento` int NOT NULL,
  `condizioneDannoIniziale` varchar(50) DEFAULT NULL,
  `dataInstallazione` date DEFAULT NULL,
  PRIMARY KEY (`tipoDanno`,`entitaDanno`,`grandezzaSensore`,`valoreMisurato`,`codiceElemento`),
  KEY `Installazione - Sensore_idx` (`grandezzaSensore`),
  CONSTRAINT `Installazione - Danno` FOREIGN KEY (`tipoDanno`,`entitaDanno`) REFERENCES `Danno` (`tipo`,`entitaDanno`),
  CONSTRAINT `Installazione - Sensore` FOREIGN KEY (`grandezzaSensore`,`valoreMisurato`) REFERENCES `Sensore` (`grandezza`,`valoreMisurato`),
  CONSTRAINT `Installazione - Elemento` FOREIGN KEY (`codiceElemento`) REFERENCES `Elemento` (`codice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;