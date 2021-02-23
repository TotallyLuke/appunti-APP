# 18: Stato Distribuito

---

## Stato Distribuito


Abbiamo giustificato la necessità di realizzare un sistema distribuito con la ricerca di:

* affidabilità;
* suddivisione del carico;
* distribuzione dei risultati.


Le stesse caratteristiche possono essere desiderabili per un insieme di dati:

* disponibili continuamente, anche in presenza di guasti;
* in quantità superiore a quella gestibile da una sola macchina;
* accessibili da parte di più posizioni geografiche.


Un insieme di dati gestito da un sistema distribuito è disponibile, accessibile e coerente solo nella misura in cui i singoli nodi riescono a rimanere  allineati, coordinati e concordi fra loro.

---

## RFC 1034-1035

La  [RFC-952, RFC-953] spiega quale fosse l'unico sistema di risoluzione dei nomi nel 1987:

> "Host name to address mappings were maintained by the Network
> Information Center (NIC) in a single file (HOSTS.TXT) which
> was FTPed by all hosts."

Ma la stessa RFC ammoniva:

> "Explosive growth in the number of hosts didn't bode well for
> the future."

Nonostante all'epoca l'ingresso di nodi nella rete fosse estremamente controllato. Inoltre:

> "The network population was also changing in character."

> "Local organizations were administering their own names and
> addresses, but had to wait for the NIC to change HOSTS.TXT to
> make changes visible to the Internet at large.  Organizations
> also wanted some local structure on the name space."

A tal proposito l'RFC-882 di Novembre 1983 riporta:

> "A design using a distributed database and generalized resources
> was described in [RFC-882, RFC-883].  Based on experience with several
> implementations, the system evolved into the scheme described in this
> memo."


```
                             |
       +---------------------+------------------+
       |                     |                  |
      MIL                   EDU                ARPA
       |                     |                  |
 +-----+-----+               |     +------+-----+---+
 |     |     |               |     |      |         |
BRL  NOSC  DARPA             |  IN-ADDR  SRI-NIC   ACC
                             |
 +--------+------------------+---------------+------+
 |        |                  |               |      |
UCI      MIT                ISI              UDEL   YALE
```


Nel _Domain Name System_ ogni nodo è responsabile (autorevole) di un ramo di un albero degli indirizzi.

Un client che deve risolvere un nome non ha più bisogno di consultare il file in locale, ma chiede la risoluzione di un nome al DNS cui appartiene o più vicino. Questo eventualmente propaga la richiesta se non possiede la risposta.


Il requisito principale del Domain Name System è la suddivisione delle responsabilità.

Quindi, la distribuzione dello stato è effettivamente implementata attraverso la suddivisione gerarchica dello stato stesso, senza condivisione fra i nodi. Ogni nodo è responsabile di una parte dell'albero.



Questa modalità di gestione dello stato (detta _sharping_) non è sempre applicabile.  Di seguito è spiegato perché.

---

## Consenso


Se il requisito principale è la resistenza ai fallimenti o le prestazioni particolarmente elevate (in spazio o velocità) non abbiamo altra scelta che replicare lo stato in più di un nodo, in modo da avere che:

* un guasto non porti a perdita di dati
* aggiungendo nodi aumenti la capacità di risposta del sistema (scalabilità orizzontale)


Ma avendo più nodi che contengono lo stesso dato, nasce il problema del **consenso**, ovvero di garantire che tutti i nodi del sistema contengano la stessa versione di un dato.


Il problema è stato denominato da Leslie Lamport come il problema dei _Generali Bizantini_ (il termine "bizantino" è stato scelto per non offendere nessuna nazione esistente).


Diversi generali di un esercito Bizantino assediano una città. Devono raggiungere un consenso unanime su di una decisione: attaccare o ritirarsi. Un attacco parziale è molto più svantaggioso di un attacco coordinato o di una ritirata completa.


Possono comunicare solo scambiandosi messaggi l'uno con l'altro.

Tuttavia, non si sono garanzie sulla loro lealtà: alcuni generali possono tradire, inviando messaggi contraddittori o non rispondendo ai messaggi ricevuti.


Il problema modella il caso in cui un nodo di un sistema distribuito si comporta in modo diverso ad ogni risposta. Di fatto, non è conoscibile dall'esterno se il suo comportamento è corretto o se il nodo è guasto. Essendo ogni risposta casualmente errata o corretta, questa inconsistenza rende difficile dichiarare il nodo funzionante, guasto o "traditore".


Lo strumento per affrontare la soluzione di tale problema è un *algoritmo di consenso*.


### PAXOS

L'algoritmo PAXOS è basato su di un protocollo a tre fasi che garantisce il l'assenza di blocchi nel caso di un guasto singolo. Il nome deriva dalla fittizia isola greca usata nel paper come esempio ironico.

I possibili comportamenti dei nodi sono modellati con delle macchine a stati per garantire la copertura di tutti i casi.


La correttezza dell'algoritmo è dimostrata formalmente, rendendolo al momento della pubblicazione (1989) uno dei primi algoritmi del genere dotato di una prova di funzionamento.


Nonostante alcuni lavori precedenti molti simili, è considerato il primo algoritmo di consenso distribuito pubblicato per l'eleganza del modello proposto.


Nell'algoritmo PAXOS i nodi assumono dei precisi ruoli:

* leader
* votanti
* ascoltatori
* proponente
* client


Il Proponente inoltra la richiesta del Client ai Votanti per raggiungere un Quorum. Una volta che un sufficiente numero di votanti appartiene ad un Quorum, la richiesta è stata accolta.


Gli Ascoltatori, ricevendo messaggi dai Votanti, forniscono ridondanza addizionale in caso di guasti.

Il Leader coordina il protocollo ed è in grado di fermarlo in caso di eccessivi fallimenti in attesa che possa essere ripresa la normale attività.

Una variante dell'algoritmo è in grado di fornire garanzie di correttezza anche in presenza di Guasti Bizantini (nodi che si comportano in maniera malevola).

È oltre lo scopo di questo corso addentrarci nei dettagli dell'algoritmo.


### RAFT

Raft (https://raft.github.io/) è un algoritmo di consenso scritto con l'obiettivo di essere più comprensibile di PAXOS. È stato scritto nel 2013.


RAFT suddivide il problema del consenso in sottoproblemi per rendere il modello più semplice e l'implementazione più agevole.


Il concetto principale è la replicazione di una macchina a stati. Il ruolo del leader e la sua elezione sono concetti più enfatizzati che in PAXOS, e garantiscono la correttezza dell'algoritmo.


Sono disponibili (ed utilizzate in produzione in alcuni database distribuiti) implementazioni in Java, Scala, e altri linguaggi.

Nella directory `papers/` trovate il paper originale di Ongaro e Ousterhout che presenta l'algoritmo, e la dissertazione di Ongaro che lo descrive nel dettaglio.

---

## CAP THEOREM


Tramite il consenso, possiamo ottenere che il sistema distribuito abbia uno stato coerente, e che quindi ogni nodo possa rispondere allo stesso modo alla richiesta di un dato.


Ma quali sono i limiti ed i compromessi che dobbiamo prevedere di dover fare in caso di guasti?

Il teorema **CAP** definisce tre caratteristiche di un database distribuito:

|      | Nome | Descrizione |
| -- | ---- | ----------- |
| C | Consistenza | Ogni lettura riceve o il valore più recente o un errore |
| A | Disponibilità (_Availability_)| Ogni richiesta riceve una risposta valida (ma non necessariamente l'ultimo valore) |
| P | Tolleranza alla separazione  (_Partition tolerance_) | Il sistema funziona anche se la rete fallisce per un insieme di nodi, cioè viene _partizionata_ |


Il teorema afferma che solo *due* delle proprietà CAP possono essere garantite contemporaneamente.

Siccome ogni rete può fallire, in pratica il teorema afferma che:

> _in caso di partizione di rete un sistema può essere o consistente o disponibile, ma non entrambe le cose_.


Vale a dire che un database distribuito può essere costruito in due modi. In caso di partizione di rete:

* la consistenza viene garantita ma alcune richieste non possono essere soddisfatte e vanno in errore;
* tutte le richieste ritornano un valore, ma alcune potrebbero non ritornare l'ultimo valore scritto.


Il teorema è stato enunciato da Eric Brewer nel 1998 prima come principio, poi come congettura, ed infine dimostrato nel 2002.

Attenzione: la C di CAP non è la C di ACID. (cfr: https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed). A tal proposito è stato coniato l'acronimo _BASE_:

* ACID: Atomic Consistent Isolated Durable 
* BASE: Basically Available, Soft state, Eventually consistent

Il CAP theorem si concentra sui casi di _guasto_, in assenza dei guasti il sistema può essere consistente _e_ disponibile. 

Una estensione del teorema, *PACELC*, considera anche il caso dell'operatività normale:

* in caso di [P] Partizione (o guasto), si deve scegliere fra [A] disponibilità e [C] consistenza (fin qui come il CAP)
* [E] altrimenti, fra [L] latenza e [C] consistenza


La maggior parte dei sistemi NoSQL si orienta verso PA/EL. PA/EL favorisce disponibilità in caso di partizione, e minore latenza nel caso normale, a scapito della consistenza.

I database relazionali tipicamente sono invece PC/EC. In PC/EC la consistenza è sempre garantita, a scapito di disponibilità in caso di partizione e latenza più alta nel funzionamento normale.

---

## OT e CRDT


Finora abbiamo lavorato nell'ipotesi che il sistema distribuito conservi dati che vengono scritti da una sola fonte, o che solo occasionalmente arrivino da più di una direzione.


In alcuni sistemi distribuiti invece è normale che ogni nodo abbia nuove informazioni da fornire e che queste vadano riconciliate e riunite con quelle prodotte indipendentemente da un altro nodo:

* sistemi di telepresenza/chat
* editor collaborativi
* eventi in real-time con molti partecipanti


In questi sistemi l'esigenza non è quella di raggiungere un consenso su di un dato. Al contrario, ogni nodo produce nuove versioni dello stesso dato che ogni altro nodo deve riunire a quelle prodotte localmente.


Ci sono in letteratura due soluzioni a questo problema, approfondite di seguito:

* Operational Transformation
* *Conflict-Free Replicated Data-Type*


### Operational Transformation

L'approccio delle OT è il seguente:

* ogni nodo produce delle modifiche al documento in corso di elaborazione;
* le modifiche sono propagate agli altri nodi;
* ogni nodo trasforma le modifiche ricevute in modo da applicarle al suo stato del documento.


Sebbene abbia alcune implementazioni di successo (*Google Wave*, *Google Docs*), le OT non hanno preso piede: l'approccio sembra mancare di generalità e si rivela molto complesso da implementare.

### Conflict-Free Replicated Data-Type

Una più recente soluzione a questo tipo di problema è una classe di strutture dati dette *Conflict-Free Replicated Data-Type*. La C a volte viene anche detta "Commutative" o "Convergent". Il paper nel repository è del 2011.


Una CRDT può essere replicata su più nodi di un sistema, modificata indipendentemente, ma fornisce la garanzia che esiste un modo di riconciliare tutte le possibili modifiche risolvendo ogni possibile conflitto.


Ad esempio un flag booleano che possa solo passare da `false` a `true` è una banale CRDT. Anche se più nodi effettuano la modifica, il risultato può essere tranquillamente replicato senza che vi siano problemi a riunire le differenti versioni.


Diverse strutture dati con queste caratteristiche sono note ed implementate:

* Grow-only Counter
* Positive-Negative Counter
* Grow-only Set
* 2-Phase Set
* Last-Write-Wins Set


Progetti che implementano CRDT:

* Akka (modulo Akka Data)
* Riak
* Redis Enterprise
* Facebook Apollo

---

## CALM Theorem

[La sezione non è materia d'esame nell'a.a. 2020/21]


Un risultato molto recente permette di affrontare il problema del consenso distribuito in modo positivo, in contrasto con l'affermazione negativa del teorema CAP.


Nel paper "_Keeping CALM: When Distributed Consistency is Easy_", pubblicato a gennaio 2019, Joseph M. Hellerstein e Peter Alvaro propongono un risultato che caratterizza i programmi che possono mantenere la consistenza anche in presenza di partizionamento della rete.


CALM sta per "Consistency As Logical Monotonicity"

Gli autori affermano che i programmi che mantengono le proprietà CP nel teorema CAP sono esattamente i programmi che possono essere espressi termini di "_logica monotona_"


Un programma è "_logicamente monotono_" se all'aumentare della dimensione del problema il risultato non cambia.


Esempio: un sistema distribuito che individua un deadlock al suo interno è _logicamente monotono_.

Una volta individuato il deadlock, anche con più nodi la soluzione non cambia.


Esempio: un sistema distribuito di Garbage Collection non è _logicamente monotono_.

Aggiungendo nodi al sistema, è possibile che all'interno di uno di essi ci sia un riferimento ad un oggetto che era stato classificato come non più in uso. Il risultato del sistema quindi **cambia** con l'aggiunta di nodi.


Il CALM Theorem è così un risultato costruttivo: individua una classe precisa di programmi che forniscono una garanzia. Non solo, individua anche uno strumento, la _logica monotona_, che può essere usato per costruire tali programmi.


Il problema è che tale classe di programmi non è molto popolata, e molti problemi interessanti non sono esprimibili con tali strumenti.


Non a caso, i CRDT svolgono un ruolo importante nel CALM Theorem, arrivando addirittura a caratterizzare le diverse garanzie di consistenza che si possono ottenere da un sistema.

Note: nel senso che la consistenza si ottiene in termini e in contesti differenti al seconda del CRDT utilizzato.

---

## Approfondimenti


* Perspectives on the CAP Theorem (Gilbert, Lynch 2012)
`papers/l18/Brewer2.pdf`
* The Byzantine Generals Problem (Lamport, Shostak, Pease 1982)
`papers/l18/byz.pdf`
* The Part-Time Parliament (Lamport 1998)
`papers/l18/lamport-paxos.pdf`
* Paxos Made Simple (Lamport 2001)
`papers/l18/paxos-simple.pdf`
* In Search of an Understandable Consensus Algorithm (Ext. Ver.) (Ongaro, Ousterhout 2014)
`papers/l18/raft.pdf`
* A comprehensive study of Convergent and Commutative Replicated Data Types (Shapiro, Preguiça, Baquero, Zawirski 2011)
`papers/l18/techreport.pdf`

### What happened to DPLs?

Heather Miller è professore ordinario di Computer Science alla Carnegie Mellon University. Il suo lavoro riguarda sopratutto i sistemi distribuiti. In passato è stata fondatrice ed Executive Director dello Scala Center * École Polytechnique Fédérale de Lausanne.

In questo talk (https://pwlconf.org/2017/heather-miller/) ripercorre una breve storia dei linguaggi per la programmazione distribuita, cercando il motivo del successo di Java e C++.


Il testo di riferimento del suo corso di programmazione distribuita è su GitHub: https://github.com/heathermiller/dist-prog-book

