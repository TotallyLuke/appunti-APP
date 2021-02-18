# 14: Programmazione Distribuita

---

## Programmazione Distribuita


La Programmazione Distribuita consiste nella teoria e nelle tecniche per la gestione di più processi su macchine diverse che operano in modo coordinato, per lo svolgimento di un unico compito.


Un insieme di macchine che esegue un algoritmo distribuito è detto un sistema distribuito.


Date le difficoltà di gestire più thread concorrenti all'interno di uno _stesso processo_, perché andare verso difficoltà ancora maggiori e gestire processi coordinati su _più macchine_?

---

## Motivazioni e caratteristiche


Le principali motivazioni che storicamente hanno portato ad ideare la distribuzione di un algoritmo su più nodi di calcolo sono:

* **Affidabilità**: quando alcuni nodi sono fermi o in errore le attività possono proseguire sui nodi che sono (ancora) in linea  (ARPANET nasce per questo preciso scopo).
* **Suddivisione del carico**: una mole di lavoro più grande delle capacità di una sola macchina può essere suddivisa fra più nodi per essere eseguita in modo concorrente.
* **Diffusione**: gli utenti di più macchine possono accedere ai risultati del lavoro da uno qualsiasi dei nodi Ai tempi in cui dell'architettura mainframe/terminale questo era un argomento importante. Oggi questo argomento sta tornando ad essere importante, nella storia l'importanza è cresciuta e diminuita.

Le caratteristiche di un Algoritmo distribuito sono le seguenti:

* **Concorrenza dei componenti**: i vari nodi di esecuzione operano contemporaneamente. Non hanno problemi di condivisione delle risorse perché ciascun nodo è separato dagli altri. Tuttavia tutti i nodi avanzano in contemporanea.
* **Totale asincronia**: l'ordine temporale degli eventi non è strettamente condiviso, e se importante deve essere imposto con opportuni mezzi (non c'è un _global clock_ su cui allinearsi). Imporre la sincronia è costoso, perché richiede l'invio di messaggi, il quale è ordini di grandezza più lento dell'elaborazione interna.
* **Fallimenti imperscrutabili**: i nodi possono guastarsi o fallire indipendentemente uno dall'altro. Un guasto è indistinguibile da un ritardo di consegna o da una lentezza di un nodo. Individuare e caratterizzare un fallimento è un problema a sé stante.


I nodi comunicano fra loro scambiandosi messaggi, in quanto **non condividono altra risorsa che il collegamento alla rete**.

Le principali astrazioni disponibili riguardano quindi l'**invio di un messaggio** e l'**attesa della ricezione di un messaggio**. Con tutte le problematiche del caso: indirizzamento, concorrenza dell'attesa, identificazione della controparte, ecc.

---

## Messaggi e Metodi


Uno dei primi tentativi di rendere più facile la gestione dell'invio e della ricezione dei messaggi in un sistema distribuito è stato quello di riportarlo a qualcosa di simile ad una chiamata locale, mascherando la distinzione fisica fra le due macchine chiamante e chiamato.


Il termine RPC - _Remote Procedure Call_ indica un sistema per rendere trasparente la localizzazione del codice chiamato, rendendolo il più possibile simile ad una chiamata locale. L'adattamento locale/remoto viene implementato da un componente chiamato _stub_.


Una RPC comporta i seguenti passi:

1. il client chiama lo _stub_ locale;
2. lo _stub_ mette i parametri in un messaggio (_marshalling_);
3. lo _stub_ invia il messaggio al nodo remoto.
4. Sul nodo remoto, un _server stub_ attende il messaggio;
5. il _server stub_ estrae i parametri (_unmarshalling_);
6. il _server stub_ chiama la procedura locale

La risposta segue il percorso inverso.


In Java e in altri linguaggi object-oriented questo meccanismo prende il nome di RMI - _Remote Method Invocation_. Come ci suggerisce il nome, l'obiettivo del RMI è quello di rendere lo scambio di messaggi equivalente alla _chiamata del metodo di un oggetto locale_ . Ciò che viene tradotto non è più un insieme di byte, ma un oggetto. Al problema della comunicazione si aggiunge quello dell'indirizzamento dell'oggetto che rappresenta quel serivizio all'interno del nodo destinatario (remoto). Il componente server preposto a semplificare l'indirizzamento da parte di altri nodi è chiamato _Object Broker_.


All'inizio degli anni '90 diventa popolare una tecnologia di RMI detta **CORBA**: _Common Object Request Broker Architecture_ che propone uno standard con cui descrivere le interfacce tra i nodi diversi. CORBA descrive gli oggetti tramite un linguaggio: IDL - _Interface Definition Language_ che gli consente di far interagire tecnologie differenti. Ogni linguaggio che implementa CORBA deve implementare una traduzione da IDL alla propria sintassi e un Object Brocker da installare nel server.


Java, nascendo come linguaggio per sistemi embedded, implementa fin dalle prime versioni un sistema di RMI e molto presto anche la specifica CORBA per poter partecipare a sistemi distribuiti costruiti con questa tecnologia.


Una chiamata RMI comporta i seguenti passi:


1. Il client chiama lo _stub_ locale
2. Lo _stub_ prepara i parametri in un messaggio (chiama un metodo)
3. Lo _stub_ invia il messaggio. **Il client è bloccato**.
4. Il server riceve il messaggio
5. Il server controlla il messaggio e cerca l'oggetto chiamato (il brocker esamina l'indirizzo di destinazione per trovare il servizio che espone quel metodo)
6. Il server recupera i parametri e chiama il metodo destinatario
7. L'oggetto esegue il metodo e ritorna il risultato
8. Il server prepara il risultato in un messaggio
9. Il server invia il messaggio allo _stub_
10. Lo _stub_ riceve il messaggio di ritorno
11. Lo _stub_ recupera il risultato dal messaggio
12. Lo _stub_ ritorna al client il risultato

Quante cose possono andare male in questo (lungo) processo?

* cosa succede se uno dei messaggi non viene recapitato?
* cosa succede se il client ed il server hanno versioni diverse degli oggetti scambiati (succede quando due server sono stati aggiornati in momenti diversi)?
* cosa succede se il client ed il server sono su reti che non permettono l'uno di indirizzare l'altro?
* cosa succede se durante la chiamata il client o il server falliscono o diventano non più disponibili?
* **come è possibile nascondere tutta questa complessità e renderla indistinguibile da una chiamata locale?**

Morale: nascondere la complessità non evita le problematiche.


Nelle reti e negli ambienti di esecuzione moderni tutte queste problematiche sono comuni:

* le reti possono essere inaffidabili (per es. wireless);
* può essere difficile per sistemi di decine o centinaia di nodi essere tutti aggiornati allo stessa versione del software;
* firewall, reti temporanee e wireless rendono impossibile indirizzare liberamente un singolo terminale;
* i nodi entrano ed escono dalla rete con grande facilità. Inoltre, più sono numerosi più è facile che qualcuno di essi fallisca.


L'evoluzione del panorama delle reti ha reso poco pratico l'uso di tecnologie RMI, che sopravvivono solo in ambiti controllati (server/server, all'interno dei datacenter, dove si cercano prestazioni elevate), ed in forme molto diverse da quelle originarie (). Alcuni esempi sono [Google gRPC](http://www.grpc.io/), [Apache Thrift](https://thrift.apache.org/), [Apache Avro](https://avro.apache.org/) .


Non si cerca più di nascondere la complessità della chiamata remota, ma si cerca di rendere meno impegnativo partecipare ad un servizio distribuito. Si cerca di _rendere semplice_ l'indirizzamento, la trasformazione del messaggio, l'attesa della risposta, ma senza _nascondere_ la complessità,

In Java 9, il modulo `java.corba` è stato ufficialmente deprecato, e rimosso in Java 11. Non è più presente nel classpath di default, e deve essere esplicitamente installato ed attivato.

RMI invece è ancora presente ma poco usato nella sua forma più base. I vari strumenti che lo compongono sono in corso di rimozione già da diverse versioni di Java.

---

## Serializzazione


Un passo fondamentale evidenziato dai sistemi di RMI, ma che è necessario in generale, è la cosiddetta _serializzazione_, ovvero il metodo con cui un oggetto viene predisposto per la trasmissione in un messaggio.


Si dice _serializzare_ usare un meccanismo di codifica che prende direttamente l'oggetto e lo traduce in messaggio per eseguire il passo di _marshalling_. Al contrario, _deserializzare_ corrisponde al passo di _unmarshalling_. L'enfasi è sul prendere l'oggetto come un tutt'uno e comportarsi in modo il più automatico possibile, in contrasto per es. a collocare i campi dell'oggetto in una struttura predefinita e non dipendente da quest'ultimo.


![Serialization](imgs/l14/serialization.png)


Si tratta di un problema ingannevolmente semplice: in realtà è molto complesso e ricco di implicazioni, dalla storia, all'efficienza, alla sicurezza.

Note: confrontare con la Legge di Postel: "Be conservative in what you do, be liberal in what you accept from others" https://tools.ietf.org/html/rfc761#section-2.10


Java ha fin dalla versione 1.1 un meccanismo di serializzazione nativo, tramite l'interfaccia `java.io.Serializable`. Si tratta di un'interfaccia senza metodi. È una cosiddetta "Marker interface", ovvero un'interfaccia senza metodi che indica che un oggetto deve essere trattato in un certo modo (in Java 1.1 non esistevano le annotazioni). Tuttavia la sua natura di "marker interface" e le cautele necessarie ad usarla fanno capire quanto il suo uso non sia semplice: sono imposte una serie di condizioni (presenza di un UUID con determinate caratteristiche per riconoscere le versioni di un oggetti, restrizioni sui tipi dei campi ecc.) unicamente come "convenzioni", non controllabili dal compilatore, che possono portare a errori runtime.


Le problematiche che la serializzazione deve affrontare sono:

* gestire il cambiamento strutturale (versioni) delle classi;
* serializzare grafi di oggetti;
* indicare oggetti che non possono/non devono essere serializzati;
* assicurare l'integrità e l'affidabilità dei dati serializzati;
* rendere _marshalling_/_unmarshalling_ efficienti in tempo e spazio.


Per tutte queste motivazioni l'uso della serializzazione nativa di Java è sconsigliato nella pratica normale.

Non solo, è particolarmente sconsigliato per problematiche di sicurezza.

Esistono alternative che risolvono molte delle problematiche illustrate.


Inoltre, per il modo in cui funzionano reti e sistemi distribuiti oggi, sono diventati praticabili e preferibili in molte situazioni _protocolli_ testuali trasportati da HTTP e umanamente leggibili (es. JSON).

I protocolli binari sono riservati ad ambienti controllati e dove ci sono particolari esigenze di efficienza.

La differenza è alla base della distinzione fra Marshalling e Parsing: una serializzazione usa la prima, un protocollo usa il secondo.


Per questo motivo, non parleremo di serializzazione e useremo nei nostri esempi protocolli testuali semplici.

---

## The Good Parts


In seguito sono elencate le parti più importanti della libreria standard da usare per far comunicare fra loro nodi distribuiti.


Innanzitutto ci sono le classiche primitive del modello TCP/IP, oggetto della lezione 15:
* **Socket**s (Connessioni TCP)
* **Datagram**s (Pacchetti UDP)

Di recente (Java 14-15) l'implementazione di queste primitive è stata aggiornata per allinearla a standard più moderni e per prepararla ad interagire con il risultato di [Project Loom](https://openjdk.java.net/projects/loom/), ovvero con il modello di concorrrenza delle _fiber_. Le fiber sono uno dei principali ambiti di applicazione della concorrenza a granularità più bassa del livello dei thread. Uno dei filoni di ricerca più attivi nel campo delle fiber è quello relativo all'efficienza dell'IO, vale a dire la gestione dell'attesa e dellala ricezione di molte connessioni o molti datagram con la minore latenza e consumendo meno risorse possibili.


L'astrazione `Channel` verrà trattata nella lezione 16, e serve ad unificare le operazioni di I/O su _canali differenti_ (file, rete, hardware). Funziona in maniera _asincrona_, quindi la dichiarazione del channel svincola il programmatore dalla scrittura del codice che attende una connessione o un datagram.

`java.nio` introduce un insieme di implementazioni asincrone (non solo nella modellazione, ma nel modo in cui si interfacciano con l'OS ospite). Queste implementazioni permettono un'esecuzione più efficiente sfruttando a fondo le funzionalità fornite dal Sistema Operativo ospite.


La classe `URL` ha un modello molto semplificato, e permette di fare semplici richieste HTTP.

L'ecosistema Java mette a disposizione una grande scelta di robuste ed efficaci librerie per la realizzazione di topologie anche molto complesse:

- **OkHttp**: semplice gestione di chiamate HTTP
- **Jackson**: un/marshalling di dati JSON

- **Netty**: I/O asincrono ad eventi

- **Thrift**: RPC scalabile, efficiente, sicuro (viene da una donazione di Facebook)
- **gRPC**: Serializzazione e RPC efficace (progetto Google, usato in modo molto diffuso)

Oltre a tutto questo c'è lo standard JEE, che introduce un framework per lo sviluppo di applicazioni client/server e web basato su astrazioni di livello più alto, dove il nostro codice non deve preoccuparsi della connettività. 

JEE definisce in modo molto accurato un ecosistema di interfaccie per comunicare tramite messaggi, per realizzare architetture server/client, per realizzare server web che comunicano con protocolli binari e per realizzare interfacce per demandare a terzi la gestione dell'applicazione. Lo scopo di queste interfacce è permettere a diversi gruppi o diversi venditori di implementarle per fornire servizi definiti da questo standard. Questo permette agli sviluppatori di scegliere un application server e scrivere il codice che utilizza servizi già implementati.  L'application server fornisce inoltre caratteristiche di osservabilità e monitoraggio che disaccoppiano scrittura di applicazione e gestione dell'esecuzione.

JEE era una distribuzione aggiuntiva orientata all'Enterprise, dopodiché è stato donato alla Eclipse Foundation e ha cambiato nome in JEE.


Java ricopre una posizione di primo piano nell'attuale mercato dello sviluppo di applicazioni di rete e web, con un ricchissimo panorama di soluzioni disponibili. Questo per tutte le soluzioni mostrate sopra, perché costa poco dotarsi di un'infrastruttura che usa Java per servire applicazioni, perché è semplice trovare sviluppatori che conoscono Java e  perché la JVM permette di raggiungere prestazioni simili a quelle di linguaggi a più basso livello, nascondendone la complessità.  Praticamente ogni innovazione nel campo viene quasi immediatamente portata in Java, se non è sviluppata direttamente sulla JVM.


Un interessante punto di partenza per esplorare questo panorama sono i [benchmark TechEnpower](https://www.techempower.com/benchmarks/)

