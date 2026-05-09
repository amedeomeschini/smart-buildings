# Smart Buildings Database Project

Progetto per l'esame di Basi di Dati (A.A. 2021/22) presso l'Università di Pisa. 
Il sistema è progettato per la gestione integrata del monitoraggio strutturale, della costruzione e dell'analisi dei rischi di edifici "smart".

## Partecipanti
* Bandecchi Dario
* Meschini Amedeo
* Massara Rocco

---

## Descrizione del Progetto
Il database è strutturato per gestire il ciclo di vita di un edificio attraverso tre aree tematiche principali:

1.  **Area Generale (Struttura):** Gestione della gerarchia fisica degli edifici, suddivisi in piani, vani (incluse mansarde) ed elementi strutturali come pareti, soffitti e pavimenti.
2.  **Area Costruzione:** Monitoraggio dei progetti edilizi, dei materiali utilizzati (mattoni, piastrelle, pietre, ecc.) e della gestione del personale di cantiere organizzato in turni e stadi di avanzamento.
3.  **Area Monitoraggio e Rischio:** Gestione dei sensori IoT installati sugli elementi per misurare grandezze fisiche, gestione dei segnali di alert e analisi dei danni causati da eventi calamitosi (sismi, esondazioni, ecc.).

---

## Caratteristiche Tecniche

### Progettazione Concettuale e Logica
* **Diagramma E-R:** Sviluppato e ristrutturato per eliminare attributi composti e multivalore, ottimizzando il modello per la traduzione relazionale.
* **Normalizzazione:** Tutte le relazioni sono state portate in **Forma Normale di Boyce-Codd (BCNF)** per garantire l'assenza di anomalie e ridondanze non controllate.
* **Integrità:** Implementazione di vincoli referenziali completi e business rules tramite trigger SQL (es. controlli su coefficienti di rischio e gravità dei danni).

### Analisi delle Prestazioni
Il progetto include una tavola dei volumi basata su una stima di **50.000 edifici** e **3.900.000 elementi strutturali**. È stata effettuata un'analisi dei costi per le operazioni più significative (es. calcolo costi di progetto o numero vani) per valutare l'opportunità di mantenere attributi ridondanti.

---

## Funzionalità di Analytics
Il sistema include tre procedure avanzate per l'analisi dei dati:

* **Consigli di Intervento:** Analizza lo stato dell'edificio e i distacchi dalle soglie di sicurezza dei sensori per suggerire manutenzioni prioritarie su pareti, soffitti o pavimenti.
* **Stima dei Danni:** Prevede la probabilità di crolli o crepe in caso di sisma, incrociando lo stato attuale con lo storico dei danni subiti.
* **Idoneità Edificatoria (Custom Analytics):** Valuta se sia possibile costruire in un'area geografica basandosi sulla media dei livelli di gravità delle calamità passate.

---

## Struttura del Database (Modello Logico Principale)
Alcune delle tabelle principali includono:
* `Edificio(codice, tipologia, topologia, stato, numeroVani, nomeAreaGeografica)`
* `Sensore(grandezza, valoreMisurato)`
* `Materiale(nome, codiceLotto, nomeFornitore, prezzo, ...)`
* `ProgettoEdilizio(codice, dataPresentazione, tipologia, ...)`