# 8: Programmazione concorrente

---

## Programmazione Concorrente

Teoria e tecniche per la gestione di più processi sulla stessa macchina che operano contemporaneamente condividendo le risorse disponibili.

L'enfasi è sul fatto che i processi condividono le stesse risorse, sullo stesso hardware. Quando si parla di programmazione concorrente, la **gestione delle risorse comuni è l'argomento principale**, e non può essere nascosto da un'astrazione. Le tecniche di programmazione concorrente sono volte a costruire un modello con cui maneggiare e gestire l'accesso alle risorse in comune.

---

## Motivazioni storiche della Programmazione Concorrente

La macchina di Von Neumann è un modello utile nella ricerca teorica. Dal punto di vista tecnologico essa fornisce un'implementazione tecnicamente efficace della macchina di Turing (che è un fondamentale risultato teorico), ma presto è stata distanziata dalla realizzazione tecnica. Essa esegue una istruzione alla volta, e questo diventa molto rapidamente poco efficiente. Inoltre la singola CPU è chiaramente un collo di bottiglia, che la tecnica ha presto individuato e cercato di rimuovere.

Emergono molto presto opportunità per raggiungere una maggiore efficienza al costo di complessità architetturale e allontanamento dalla teoria. 

![Von Neumann](imgs/l08/VonNeumann.jpg) 

All'inizio degli anni sessanta, l'innovazione dei "channels" nei mainframe IBM permette di avere operazioni di I/O senza occupare la CPU: le periferiche diventano "intelligenti" e possono leggere i nastri o stampare risultati mentre la CPU fa altre operazioni. Meno tempi di attesa di I/O significa maggiore sfruttamento della CPU e in definitiva prestazioni migliori a parità di tempo; in un regime di noleggio questo è un incentivo economico non indifferente.


Il modello economico spinge quindi ad affrontare il problema del coordinamento fra parti attive che lavorano contemporaneamente per ottenere una maggiore efficienza.


I Sistemi Operativi si trovano così nella necessità di gestire più attività contemporanee o in rapida successione. Le risorse disponibili vanno distribuite fra queste attività e utilizzate al meglio.

La concorrenza diventa quindi una funzione di alto livello in carico al sistema operativo, vista anche la necessità di lavorare a strettissimo contatto con la gestione delle risorse. Per esempio: mentre un programma attende un caricamento da nastro alla memoria, un altro può effettuare un calcolo che impegna la CPU. Il risultato finale è che la CPU è efficace per un tempo maggiore, invece di dover attendere l'esecuzione delle operazioni di comunicazione.  Attenzione che portare questo modello all'estremo crea altri problemi come per esempio l'[attacco NetCat](https://www.vusec.net/projects/netcat/).

N.B.: il sistema operativo mantiene la contabilità: la tariffa era oraria (analogamente al costo dei servizi cloud odierni); del ressto le macchine non erano proprietà dell'utente finale.


La legge di Moore (1965) afferma che "Il numero di transistor per chip raddoppia ogni anno". Questo principio fornisce risorse sempre crescenti (ma sempre più asimmetriche). Leggere il paper originale di Moore in `papers/l1`.

Questa legge ha, da qualche anno, raggiunto i limiti fisici del silicio (agli attuali 7nm ci si scontra con la compensazione degli effetti quantistici e con le problematiche energetiche e termiche). Viene ancora rincorsa attraverso la moltiplicazione dei core sullo stesso chip, l'ottimizzazione della concorrenza fra attività in aree diverse del chip, le tecniche di esecuzione predittiva, e così via. 


![Moore](imgs/l08/Transistor_Count_and_Moore's_Law_-_2011.svg)


Tutto questo però richiede sempre una sempre migliore gestione della concorrenza e dell'accesso contemporaneo alle stesse risorse. Inoltre alcune di queste tecniche (l'esecuzione predittiva e la gestione speculativa delle cache) si sono rivelate problematiche dal punto di vista della sicurezza (cfr. Spectre, [Meltdown]( https://meltdownattack.com/) e tutti i lavori successivi).

La legge di Amhdal (1967) individua i limiti matematici della possibile efficienza che si può ottenere dalla parallelizzazione. Essa ci insegna che "Lo speedup dipende dalla parte parallelizzabile del programma da eseguire". Un riassunto dell'intervento di Amdhal in cui viene enunciata la legge è presente in `papers/l1`.

![Amdhal](imgs/l08/AmdahlsLaw.svg)

**Parallelism is using more resources to get the answer faster**

*Corollary:* Only useful if it really does get  the answer faster

@BrianGoetz


Parallelizzare un'attività non è sempre possibile o semplice: il lavoro dedicato a rendere un'attività parallela dev'essere valutato in funzione di quale grado di parallelizzazione si può ottenere e quindi qual è l'accelerazione che se ne ricava. Non sempre l'investimento può avere un ritorno positivo, molto dipende dal contesto del problema e dell'ambiente di esecuzione.

## Processi e thread

Nei sistemi UNIX e derivati il principale concetto di gestione delle attività è il Processo. Esso è strutturato come nella figura sottostante (presa da http://www.programering.com/a/MzNwUjMwATM.html)

![Process Memory](imgs/l08/MemoryMap.jpg) 


Un Processo descrive per il sistema operativo un programma in esecuzione e tutte le risorse che gli sono dedicate:

* memoria;
* canali di I/O (file, pipe, socket);
* interrupt e segnali;
* stato della CPU.

Il sistema operativo maneggia la suddivisione delle risorse fra le varie attività in corso attraverso la metafora del processo. Diventa necessario il supporto di una gerarchia di operazioni: alcune possibili solo dal sistema operativo, altre disponibili anche ai processi. Solo in questo modo si può garantire la corretta collaborazione fra le varie attività e impedire che una si appropri di tutte le risorse a scapito delle altre (cfr. Problema di 5 filosofi).


I processi normalmente **non** condividono risorse: possono comunicare fra loro, ma solo interagendo come entità separate.

L'obiettivo del sistema operativo è garantire l'utilizzo efficace e paritario delle risorse, non favorirne l'uso contemporaneo. Ci sono poche eccezioni: più processi possono aprire in lettura lo stesso file, o alcuni metodi di comunicazione sono implementati tramite la condivisione della memoria.


Creare, mettere da parte e portare in esecuzione un Processo sono operazione relativamente costose, poiché il contesto di esecuzione deve essere salvato e messo da parte per poter essere recuperato quando è nuovamente il turno di utilizzare la CPU.

![CPU Cycles](imgs/l08/part101_infographics_v08.png) 

Notare che la scala del grafico (preso da http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/ ) è logaritmica: ogni colonna corrisponde ad un ordine di grandezza. Le operazioni di cambio di contesto fra thread sono costose, quelle di cambio di contesto fra processi possono esserlo ancora di più perché possono includere spostamenti di ampie porzioni della RAM, molteplici chiamate al kernel e altro.

Per gestire più linee di esecuzione all'interno dello stesso processo è stato ideato il concetto di thread.
I **thread** condividono le risorse di uno stesso processo, rendendo più economico il costo di passaggio da un ramo di esecuzione all'altro.


Questo riporta però in carico all'applicazione il problema della gestione dell'accesso contemporaneo alle risorse, e della loro condivisione efficace fra i thread. Ci troviamo nuovamente sul problema dei 5 filosofi. Non solo, ora è esplicitamente responsabilità dell'applicazione gestire le risorse fra i suoi diversi thread ed evitare conflitti.


Per confrontare diversi paradigmi di programmazione, può essere utile usare come assi di riferimento l'approccio ai dati locali e la condivisione dello stato del calcolo:

| Dati | Stato |
| --- | --- |
| Mutabili | Condiviso |
| Immutabili | Non condiviso |

Intendiamo come "approccio ai dati" l'uso di variabili locali mutabili o immutabili: come vedremo, questa caratteristica è importante perché rimuove alcune problematiche, impedendo però comportamenti che potrebbero essere interessanti. La condivisione o meno dello stato invece è il semplice fatto di accedere contemporaneamente, da parte di più linee di esecuzione, agli stessi dati.


![Gestione dello Stato](imgs/l08/GestioneStato.png) <!-- .element: style="width: 90%" -->


La **programmazione distribuita** implica la comunicazione fra entità che non possono avere stato condiviso. Come questo stato venga gestito è ininfluente. La comunicazione fra diversi processi anche nella stessa macchina può essere considerato un problema di programmazione distribuita, in quanto non è detto che i processi sappiano che stanno condividendo lo stesso ambiente di esecuzione.


La **programmazione funzionale** tratta preferibilmente dati immutabili, con qualche concessione alla mutabilità per lo stretto necessario. Lo stato può essere distinto o (specie se immutabile) condiviso.


La **programmazione concorrente** si pone nel quadrante più difficile, dove lo stato è mutabile e condiviso, e quindi l'accesso e l'intervento su di esso va coordinato e gestito.

Un quesito interessante è il seguente: dove si colloca la **programmazione ad oggetti** in questo diagramma?

---

## Problemi della concorrenza


### Non determinismo

Un'esecuzione concorrente è inerentemente non deterministica. 

Si consegna ad altri il controllo della sequenza di esecuzione, e questa sequenza dipende da eventi esterni e contingenti (carico istantaneo, azioni dell'utente, segnali dall'esterno).


### Starvation

Un thread che non riceve abbastanza risorse non può fare il suo lavoro. 

Quando ciò avviene, se il thread fa parte di una sequenza di attività, le attività successive che dipendono dal suo lavoro rimarranno non svolte o saranno in ritardo.


### Race Conditions

Se più thread competono per le stesse risorse, il loro ordine di esecuzione può essere rilevante per il risultato. 

È inoltre assai difficile da verificare tale ordine di esecuzione, perché può dipendere dagli stessi fattori indicati in precedenza, oltre che altri: situazione contingente, scelte del sistema operativo, configurazione del compilatore, ecc. In generale, l'ispezione del codice sorgente è poco utile, perché la relazione fra cosa c'è scritto nel codice sorgente e cosa viene effettivamente eseguito è molto labile. Per esempio, l'ordine di esecuzione non è garantito, a meno di (costose) richieste esplicite.


### Deadlock

Se due thread attendono ciascuno la risorsa che ha già preso l'altro, nessuno dei due può proseguire. 

È definita anche una condizione "dinamica", detta "Livelock", in cui due thread si scambiano il possesso reciproco di due risorse, senza mai riuscire ad averle entrambe per proseguire: dall'esterno, si può osservare attività (i due thread si scambiano continuamente il possesso delle risorse) ma in realtà non viene svolto nessun lavoro. Esiste un risultato teorico che indica quando può avvenire un deadlock.


#### Coffman's conditions

(da "System Deadlocks", ACM Computing Surveys Giugno 1971)

Le condizioni di Coffman sono condizioni necessarie perché un Deadlock *possa* avvenire, e sono:

* Mutual exclusion
* Hold and wait or resource holding
* No preemption
* Circular wait

Tradotto dal punto di vista delle risorse, questo significa che un Deadlock *può* avvenire solo quando:

* la risorsa non deve essere condivisibile;
* il processo deve cercare risorse usate da altri;
* non ci dev'essere modo di sottrarre una risorsa ad un processo che l'ha ottenuta;
* la catena delle attese fra i processi è circolare ( cioè P1 attende una risorsa che ha P2, che attende una risorsa che ha P3, che attende anche lui una risorsa che ha P1)

Sfortunatamente, sono condizioni molto comuni in quanto semplificano la realizzazione dell'ambiente di esecuzione.


Rimuovere anche una sola delle condizioni rende impossibile entrare in un Deadlock. Purtroppo, lavorare per escluderle è costoso e a volte poco praticabile:


Rimuovere la _mutua esclusione_ può non essere fattibile per certe risorse. Richiede algoritmi specifici detti _lock-free_ o _wait-free_. Alcune tecniche di programmazione sono molto interessanti per introdurre alcune tipologie di mutua esclusione; per esempio alcune tecniche di programmazione funzionale come la modellazione degli effetti collaterali tramite monadi.


Rimuovere _l'attesa_ può portare a situazioni di starvation o attesa indefinita. Richiede un qualche sistema transazionale per ottenere più risorse contemporaneamente. Programmare tutte le possibili casistiche di attesa e prenotazione di multiple risorse, e le varie modalità di fallimento, può diventare più complesso del compito che si sta cercando di parallelizzare, e molto più difficile da dimostrare corretto.

Introdurre _la pre-emption_ può essere estremamente costoso o impossibile. Oltre agli algoritmi lock- e wait-free una soluzione può essere l'uso di una forma di _optimistic concurrency control_.
Il costo computazionale e di comunicazione per realizzare un sistema transazionale di questo tipo lo rende economico non a livello di sistema operativo, ma a livello applicativo specializzato: un esempio classico sono i database relazionali, dove vari tipi di controllo della concorrenza permettono di scegliere con continuità fra performance e correttezza. Si tratta comunque di costi in termini di performance; cospicui, all'interno di una singola macchina, enormi in un sistema distribuito.


Rimuovere _la circolarità_ richiede imporre un'ordinamento fra le risorse e la sequenza di acquisizione	. Non sempre è facile da individuare o creare (Dijkstra propone un algoritmo). Ma questo significa anche che il sistema ed i threads devono essere coscienti gli uni degli altri, e delle rispettive caratteristiche: questo non sempre è possibile a priori, e può essere molto complesso da risolvere nel caso generale.

---

## Tipologie di Concorrenza


| Tipo | Strutture |
| -- | -- |
| Collaborativa | Co-Routines |
| Pre-Emptive | Processi, Threads |
| Real-Time | Processi, Threads |
| Event Driven/Async | Future, Events, Streams |

Una possibile classificazione delle tipologie di concorrenza si può ottenere incrociando le strutture a disposizione del programmatore per realizzare le applicazioni concorrenti, ed il grado di collaborazione che il sistema operativo esige in cambio.


### Collaborativa

I programmi devono esplicitamente cedere il controllo ad intervalli regolari.

È un modello ancora rilevante in alcuni ambiti (embedded, very high performance)

Le coroutines hanno una applicabilità ed una vita indipendente dalla pura concorrenza: in alcune implementazioni consentono, per esempio, di ottenere sistemi di runtime privi di stack, e quindi con consumo di memoria fisso.


### Pre-Emptive

Il sistema operativo è in grado di interrompere l'esecuzione di un programma e sottrargli il controllo delle risorse per affidarle al programma seguente.

È il modello più comune nei sistemi operativi moderni

Ogni risorsa o quasi può essere sottratta al controllo di un processo senza che questo se ne accorga o possa farci nulla.


### Real-Time

Il sistema operativo garantisce prestazioni precise e prefissate nella suddivisione delle risorse fra i programmi.

È molto complesso da implementare; solitamente è riservato ad applicazioni molto particolari.

Ad esempio per strumenti di misura o controllo industriale, aereonautico o aereospaziale, come il sistema operativo "Luminary099" per il modulo lunare della missione Apollo 11 (https://github.com/chrislgarry/Apollo-11).


### Event Driven/Async

I programmi dichiarano le operazioni che vanno eseguite e lasciano all'ambiente di esecuzione la decisione di quando eseguirle e come assegnare le risposte.

Non è comune a livello di sistema operativo, ma sta diventando rapidamente popolare nell'organizzazione delle applicazioni.

Note: per es. applicazioni scritte secondo il Reactive Manifesto; applicazioni per smartphone; piattaforme di data streaming o fast data.

---

## Java Threads


Nel linguaggio Java un Thread è rappresentato da una istanza dell'omonima classe.


```java
/**
* Allocates a new Thread object.
*
* @param target the object whose run method
* is invoked when this thread is started.
* If null, this classes run method does nothing.
*/
public Thread(Runnable target)
```


Il principale metodo è `start()`, che avvia un nuovo percorso di esecuzione (similmente ad una _fork_) che lavora all'interno della stessa JVM, condividendo lo stesso heap e quindi lo stesso stato complessivo.

Vale a dire che chiamando quel metodo il percorso di esecuzione non è più univoco: da un lato, il metodo ritorna ed il programma chiamante prosegue, dall'altro il metodo chiamato viene eseguito contemporaneamente in una nuova linea di esecuzione.


```java
/**
* Causes this thread to begin execution; the Java Virtual
* Machine calls the run method of this thread.
*
*/
void start()
```


Un metodo che useremo spesso negli esempi è `sleep()`, che mette in pausa il thread corrente per un determinato (approssimativamente) lasso di tempo.


```java
/**
* Causes the currently executing thread to sleep
* (temporarily cease execution) for the specified
* number of milliseconds, subject to the precision
* and accuracy of system timers and schedulers.
*
*/
static void sleep(long millis)
```


```java
/**
* The Runnable interface should be implemented by any
* class whose instances are intended to be executed
* by a thread.
*/
@FunctionalInterface
public interface Runnable {

  /**
  * The general contract of the method run is that
  * it may take any action whatsoever.
  */
  void run();
}
```


Esempio: `ThreadSupplier`, fornitore di thread che aspettano del tempo

```java
@Override
public Thread get() {
  return new Thread(() -> {
    String name = Thread.currentThread().getName();
    long time = waitTime.get();
    try {
      Thread.sleep(time);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  });
  }
```

Punti notevoli:
- la lambda che viene riconosciuta come implementazione di `Runnable`
- l'uso di metodi statici di `Thread` per controllare il comportamento del thread corrente
- l'uso di una lambda come strategia (nel senso del pattern Strategy) di generazione dei tempi di attesa.


`it.unipd.app2020.threads.SingleThread`:

lancia un singolo thread

```java
public static void main(String[] args) {
  Thread a = new ThreadSupplier().get();

  out.println("Starting Single Thread");
  a.start();
  out.println("Done starting.");
}
```

Punti di attenzione:
- il programma non termina dopo la conclusione di main(), ma attende che il thread completi la sua esecuzione.
- un semplice import static java.lang.System.out; ci permette di accorciare le istruzioni di stampa.


`it.unipd.app2020.threads.ManyThreads`:

lancia diversi thread in successione

```java
public static void main(String[] args) {
  var threads = Stream.generate(new ThreadSupplier());

  out.println("Starting Threads");
  threads.limit(10).forEach((Thread a) -> a.start());
  out.println("Done starting.");
}
```

Ecco il motivo per implementare il `ThreadSupplier` in questo modo: possiamo usarlo come generatore di uno Stream,
ottenere tutti i `Thread` che ci servono e trattarli in successione.

---

## Risorse utili


5 things you didn't know about...

* Java 10: https://www.ibm.com/developerworks/java/library/j-5things17/index.html
* Multithreaded Java programming: https://www.ibm.com/developerworks/java/library/j-5things15/index.html
* `java.util.concurrent`, [pt1](https://www.ibm.com/developerworks/java/library/j-5things4/index.html) e [pt2](https://www.ibm.com/developerworks/java/library/j-5things5/index.html)


Introducing Junit 5, [pt1](https://www.ibm.com/developerworks/java/library/j-introducing-junit5-part1-jupiter-api/index.html) e [pt2](https://www.ibm.com/developerworks/java/library/j-introducing-junit5-part2-vintage-jupiter-extension-model/index.html) 

[Java 8 Idioms](https://www.ibm.com/developerworks/java/library/j-java8idioms1/index.html)

---

## Link interessanti

Per unire l'utile al dilettevole:

* [Advent of Code](https://adventofcode.com/)
* [Coding Gym](https://coding-gym.org)


