# 10: Dati Thread-Safe

---

## Dati Thread-safe


Per condividere dati fra Thread diversi, è necessario utilizzare alcuni strumenti specifici.

Ma è meglio evitarlo, quando possibile.

---

## Problema


Qual è il problema che incontriamo ponendoci nel quadrante (lezione 08) dati mutabili/stato condiviso?


`it.unipd.app2020.safe.AdderTest`

```java
public class Adder {

int target = 0;

public void add() {
    ...
    t1.start();
    t2.start();
    t3.start();
  }
}
```


I 3 thread avviati sono uguali e così definiti:

```java
var t1 = new Thread(() -> {
  for (int i = 0; i < 100000; i++) { target +=1; } 
}); 
var t2=... 
var t3=... 
```

Si noti che allo scopo di questo test è più semplice ripetere la definizione per ciascun thread perché l'obiettivo è riferire alla stessa variabile condivisa. Le tre lambda scritte in questo modo sono _closures_ (cioè, si _chiudono_) sulla variabile `target` lessicalmente identica. 


Test: 

```java 
@Test void test() throws InterruptedException { 
  var adder=new Adder(); 
  adder.add();
  Thread.sleep(1000); 
  assertEquals(300000, adder.target); 
} 
```


Ci si aspetta che il risultato sia 300000. Il test fallisce perché più thread cercano di incrementare uno stesso dato contemporaneamente e scrivono nella variabile `target` lo stesso valore.


![Adder](imgs/l10/adder.png) <!-- .element: style="width: 70%" -->


La concorrenza ci porta al _non determinismo_.

Il problema di condividere l'accesso a dati non è quindi solo quello del deadlock, ma anche quello della correttezza del risultato.

Va notato come già i passaggi di compilazione, interpretazione e JITting introducono indeterminatezza sul reale ordine di esecuzione delle istruzioni, anche nel caso del singolo thread. Inoltre, lo stesso hardware spesso riordina l'esecuzione delle istruzioni per ottimizzare l'uso delle risorse. In linea generale non ci si può basare sul codice sorgente per interpretare alcuni dettagli del comportamento di un programma, tantomeno in ambiente concorrente.


Una struttura dati non thread-safe non consente a più thread di operare contemporaneamente:
  * nel migliore dei casi lancia una `java.util.ConcurrentModificationException`;
  * nel caso intermedio lo stato diventa inconsistente;
  * nel peggiore dei casi ottengo un'altra eccezione. Ad esempio in determinati (rari) casi `HashMap#put` può lanciare un `IndexOutOfBound`(!).



Definiamo in questo modo un `Runnable` che percorre una lista.




`it.unipd.app2020.safe.ListTraverser`

```java
list.iterator().forEachRemaining(el -> {
  out.println(el);
  try {
    Thread.sleep(250);
  } catch (InterruptedException e) {
    e.printStackTrace();
  }
});
```

In questo modo invece definiamo un `Runnable` che aggiunge un elemento ad una lista.

`it.unipd.app2020.safe.ListUpdater`

```java
try {
  Thread.sleep(300);
} catch (InterruptedException e) {
  e.printStackTrace();
}
list.add("d");
```


Creiamo una lista `list`con 3 elementi, invochiamo `ListTraverser(list)` e `ListUpdater(list)`. Ci aspettiamo che a questo punto `list` abbia 4 elementi.

```java
List< String > list = new ArrayList< String >();
list.add("a");
list.add("b");
list.add("c");
var t1 = new Thread(new ListTraverser(list));
var t2 = new Thread(new ListUpdater(list));
t1.start();
t2.start();
Thread.sleep(1000);
assertEquals(4, list.size());
```

Ma `ArrayList`non è thread-safe e dichiara ([nella documentazione](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/util/ArrayList.html)) che il suo iteratore lancia una `java.util.concurrentModificationException` se la collezione viene modificata durante l'attraversamento. A lezione è stato eseguito una volta il codice ed è stato superato con successo il test, ma è stata anche lanciata un'eccezione. Questo insegna che alcuni strumenti di testing non sono adatti a testare ambiente concorrente.


Video di approfondimento consigliati:

* (A Crash Course in Modern Hardware by Cliff Click)[https://www.youtube.com/watch?v=OFgxAFdxYAQ]
* (Adventures with concurrent programming in Java)[https://www.youtube.com/watch?v=929OrIvbW18]


In conclusione se abbiamo la necessità di condividere dati fra più thread, abbiamo bisogno di **strutture dati thread-safe**.

---

## Atomic variables


Se il nostro caso d'uso riguarda semplicemente l'incremento di un contatore, una possibile soluzione sono le classi del package `java.concurrent.atomic`


|tipo|singolo|array|
|--|----|----|
|Integer|`AtomicInteger`|`AtomicIntegerArray`|
|Long|`AtomicLong`|`AtomicLongArray`|
|Object|`AtomicReference`|`AtomicReferenceArray`|


Queste classi garantiscono:

* che la modifica del valore che contengono sia "atomica" e thread-safe
* che la modifica (quasi sempre) non blocchi il thread che la sta eseguendo


Abbiamo scritto _quasi sempre_ perché la funzionalità richiede la disponibilità del supporto dell'hardware attraverso istruzioni *CAS* (Compare-and-swap), e in mancanza di queste l'implementazione ripiega su metodi più convenzionali (meno efficienti, che bloccano il thread).

Vediamo come si implementa la classe `Adder` vista a inizio lezione con un `Atomic Integer`:

`it.unipd.app2020.safe.AtomicAdder`

```java
public class AtomicAdder {

  public AtomicInteger target = new AtomicInteger(0);

  public void add() {
   ...
  }
}
```


```java
var t1 = new Thread(() -> {
for (int i = 0; i < 100000; i++) {
  target.incrementAndGet(); } 
}); 
```




![Adder](imgs/l10/atomicAdder.png) 

Si noti che la terza chiamata di `incrementAndGet` potenzialmente potrebbe rimanere bloccata, ma nella pratica la risposta è talmente veloce che è estremamente difficile che le due `incrementeAndGet` si accavallino. Qualora avvenisse, a livello hardware il costo di sincronizzazione sarebbe molto basso. Si confronti con il diagramma della prima lezione.


```java
/**
* Atomically sets the value to the given updated
* value if the current value == the expected value.
*
* @param expect the expected value
* @param update the new value
* @return true if successful. False return indicates
* that the actual value was not equal to the expected value.
*/
public final boolean compareAndSet(long expect, long update)
```


```java
/**
* An AtomicMarkableReference maintains an object
* reference along with a mark bit, that can be
* updated atomically.
*
* Implementation note : This implementation maintains
* markable references by creating internal objects
* representing "boxed" [reference, boolean] pairs.
*/
public class AtomicMarkableReference< V >;
```


```java
/**
 * An AtomicStampedReference maintains an object
 * reference along with an integer "stamp", that
 * can be updated atomically.
 *
 * Implementation note : This implementation maintains
 * stamped references by creating internal objects
 * representing "boxed" [reference, integer] pairs.
 */
public class AtomicStampedReference< V >;
```

---

## volatile


La parola chiave `volatile` indica che una variabile deve sempre essere letta "dalla memoria principale" e non da cache intermedie.

Note: Dobbiamo parlare di questa parola chiave, anche se il suo uso è molto particolare e delicato. Ne parliamo perché è necessario saperne l'esistenza, ma va usata con cautela.


In un'architettura hardware ormai comune, più CPU colloquiano con la stessa memoria principale. Ognuna, ha una cache locale per velocizzare l'esecuzione del codice e l'interazione con i dati. <!-- .element: style="float: left; width: 50%" -->

![Volatile-1](imgs/l10/java-volatile-1.png) <!-- .element: style="width: 45%" -->


Questo significa però che thread diversi che sono stati smistati su CPU diverse vedono valori differenti, provenienti dalla cache, della stessa variabile. È il problema della "visibilità del valore scritto". <!-- .element: style="float: right; width: 50%" -->

![Volatile-2](imgs/l10/java-volatile-2.png) <!-- .element: style="width: 45%" -->

Note: e ha origine nelle ottimizzazioni e nei compromessi necessari per usare un'architettura multiprocessore e multithread.


Una variabile dichiarata "volatile" viene sempre letta dalla memoria principale in modo da garantire la visibilità dell'ultima scrittura. <!-- .element: style="float: left; width: 50%" -->

![Volatile-3](imgs/l10/java-volatile-3.png) <!-- .element: style="width: 45%" -->


Secondo la specifica della JVM, `volatile` stabilisce una relazione di `happens-before` in determinati casi di accesso alla variabile.


Una _relazione di `happens-before`_ è una garanzia forte fornita dal compilatore riguardo l'ordinamento dell'esecuzione delle istruzioni espresse dal codice.

Note: A causa della grande differenza di prestazioni fra il canale della memoria e la CPU, per motivi di efficienza il compilatore riordina aggressivamente l'ordine di esecuzione


Per approfondire _happens-before_

What Came First: The Ordering of Events in Systems  
https://www.infoq.com/presentations/events-riak-go

Cliff Click's Blog  
http://cliffc.org/blog/  
https://itunes.apple.com/us/podcast/id1286422919


Stabilire una relazione di `happens-before` è, ovviamente, costoso: richiede il supporto dell'hardware e limita la capacità del compilatore di ottimizzare il codice riordinandone le istruzioni.


La Java Language Specification 8 al capitolo 17.4.5 "Happens-before Order" definisce che:

> A write to a volatile field (§8.3.1.4) happens-before every subsequent read of that field.

Note: Si tratta quindi di una primitiva di sincronizzazione a tutti gli effetti https://docs.oracle.com/javase/specs/jls/se15/jls15.pdf https://docs.oracle.com/javase/specs/jls/se15/html/jls-17.html#jls-17.4.5


Tuttavia...


`it.unipd.app2020.safe.VolatileTest`

```java
class VolatileHolder {
  volatile int counter = 0;
}
```


```java
@Test
public void volatileCounter() {
  VolatileHolder holder = new VolatileHolder();

  ExecutorService executor = Executors.newFixedThreadPool(4);
  IntStream.range(0, 10000).forEach(i ->
executor.submit(() -> holder.counter++));
  awaitDone(executor);

  assertEquals(10000, holder.counter);
}
```

Note: `awaitDone(ExecutorService)` attende che il servizio abbia esaurito tutti i task accodati.


La garanzia fornita da `volatile` è utile alla correttezza del programma solo se

*nessun thread scrive nella variabile volatile un valore dipendente dal valore che ha appena letto dalla stessa variabile*


In un certo senso le classi `atomic` sono una generalizzazione e semplificazione di alcuni usi di `volatile`.

Usate con cautela questo costrutto.


Trovate le immagini ed un approfondimento in questo articolo:

http://tutorials.jenkov.com/java-concurrency/volatile.html

---

## Concurrent Data Structures


Nel package `java.util.concurrent` si trovano le versioni ottimizzate per la concorrenza di molte delle
collezioni più comuni.

In generale, sono pensate per essere più efficienti della versione sincronizzata delle loro controparti, per
esempio rispetto a `Collections.syncronizedMap(new HashMap())`

Si noti che rispetto alla sincronizzazione della completa struttura dati, queste classi limitano la
sincronizzazione alle sole sezioni critiche, in modo da ottenere complessivamente una maggiore efficienza.


### ConcurrentMap

L'interfaccia `ConcurrentMap` aggiunge a `Map` garanzie di atomicità ed ordinamento delle operazioni.


```java
/**
* A Map providing thread safety and atomicity
* guarantees.
*/
public interface ConcurrentMap< K,V >
  extends Map< K,V >
```


```java
/**
* If the specified key is not already associated with a
* value, associate it with the given value.
* The action is performed atomically.
*/
V putIfAbsent(K key, V Value)
```


```java
/**
* Replaces the entry for a key only if currently mapped
* to some value.
* The action is performed atomically.
*/
V replace(K key, V Value)
```


```java
/**
* Replaces the entry for a key only if currently mapped
* to a given value.
* The action is performed atomically.
*/
V replace(K key, V oldValue, V newValue)
```


Analogamente `ConcurrentNavigableMap` è la versione concorrente di `NavigableMap`.

Alcune implementazioni, come `ConcurrentHashMap`, offrono metodi come `reduce`, `search` e `foreach` che
possono operare su tutte le chiavi suddividendo autonomamente il lavoro in più thread.


```java
/**
* Returns the result of accumulating the given
* transformation of all (key, value) pairs using the
* given reducer to combine values, or null if none.
*
* @param the elements needed to switch to parallel
* @param the transformation for an element
* @param a commutative associative combining function
*/
public < U > U reduce(long parallelismThreshold,
  BiFunction< ? super K,? super V,? extends U> transformer,
  BiFunction< ? super U,? super U,? extends U> reducer)
```

Possiamo invocare `reduce` su una `ConcurrentHashMap`, al fine di ridurre la mappa ad un risultato unico. Vanno fornite due funzioni: una per trasformare le coppie chiave-valore nel tipo del risultato, e l'altra per sommare i risultati parziali. Il tipo del risultato deve quindi essere dotato di un'operazione di somma con le consuete proprietà commutativa e associativa.

Per provare il funzionamento di queste istruzioni, costruiamo una mappa di long casuali.

`it.unipd.app2020.safe.ReducePerf`

```java
Random rnd = new Random();
ConcurrentHashMap< String, Long > map =
  new ConcurrentHashMap< String, Long>();
IntStream.range(0, 10000)
  .forEach(i -> map.put("k" + i, 
    new Long(rnd.nextInt(1000))));
```

Impostiamo un parallelism threshold molto basso per suggerire un'esecuzione parallela.

```java
long start = System.currentTimeMillis();
Long parres = map.reduceEntries(500,
  entry -> entry.getValue(), (a, b) -> a + b);
long partime = System.currentTimeMillis() - start;
```

Per fare un confronto, verifichiamo il tempo usato se suggeriamo di non usare il parallelismo.

```java
long start = System.currentTimeMillis();
Long parres = map.reduceEntries(10000001,
  entry -> entry.getValue(), (a, b) -> a + b);
long partime = System.currentTimeMillis() - start;
```
Questa operazione ha una complessità così bassa che l'esecuzione parallela non è conveniente.

*Quiz*: costruire un esempio in cui è l'implementazione parallela la più efficace.

*Suggerimento*: il lavoro di riduzione deve essere superiore all'overhead introdotto dal parallelismo...


```java
/**
 * Returns a non-null result from applying the given
 * search function on each (key, value), or null if none.
 * Upon success, further element processing is suppressed.
 *
 * @param the elements needed to switch to parallel
 * @param a search function, that returns non-null on
 *success
 */
public < U > U search(long parallelismThreshold,
  BiFunction< ? super K,​? super V,​? extends U> searchFunction)
```

La funzione `search` permette di applicare una ricerca parallela nella mappa. Il risultato è il primo non nullo ritornato dalla funzione di chiave e valore. La ricerca è parallela, ma trovato il risultato tutti i thread di ricerca vengono fermati. Un'esecuzione parallela di search non garantisce di trovare il _primo_ risultato.


```java
/**
 * Performs the given action for each (key, value).
 *
 * @param the elements needed to switch to parallel
 * @param the action (can have side-effects)
 */
public void forEach(long parallelismThreshold,
  BiConsumer< ? super K,? super V> action)
```

Infine la funzione `forEach` permette di eseguire un _effetto collaterale_ (side-effects) per ciascuna coppia chiave-valore.


Le funzioni usate nei metodi di trasformazione delle mappe devono:

* non dipendere dall'ordinamento
* non dipendere da uno stato condiviso durante il calcolo

Inoltre, i metodi diversi da `forEach` _non devono avere effetti collaterali_.

Ovviamente, in `forEach` l'effetto collaterale è lo scopo della funzione. Le prime due condizioni sono invece indispensabili per garantire, in termini generali, la corretta esecuzione dell'operazione parallela.


Per ogni algoritmo vi sono varie versioni:

* con una trasformazione opzionale prima dell'uso del valore
* iterazione solo sulle chiavi o solo sui valori
* con risultati primitivi (`int`, `double` ecc.)


Le operazioni di riduzione, ricerca ed esecuzione di effetti non sono atomiche nel loro complesso, ma ogni coppia chiave-valore non nulla ha una garanzia di  `happens-before` con il suo uso nell'iterazione (nel senso che prima viene trasformata, poi viene utilizzata nel calcolo).


### BlockingQueue

L'interfaccia `BlockingQueue` aggiunge alla classica `Queue` metodi con cui è possibile scegliere la semantica dell'operazione di accodamento e prelievo.

Diventa così possibile richiedere il comportamento desiderato all'interno di una esecuzione concorrente.


#### Accodamento

|metodo|risultato negativo|
|--|----|
|`add(e)`|eccezione|
|`offer(e)`|`false`|
|`put(e)`|attesa (finché non c'è spazio)|
|`offer(e, time, unit)`|attesa limitata|

Si intende "risultato negativo" quando un elemento non è disponibile per l'accodamento o il prelievo


#### Prelievo

|metodo|risultato negativo|
|--|----|
|`remove()`|eccezione|
|`poll()`|`null`|
|`take()`|attesa|
|`poll(time, unit)`|attesa limitata|

Come sopra il primo metodo ritorna immediatamente con un'eccezione se non ci sono elementi da rimuovere. Il secondo ritorna immediatamente con un valore speciale. Il terzo ed il quarto attendono, per un periodo indefinito o specificato.


#### Lettura

|metodo|risultato negativo|
|--|----|
|`element()`|eccezione|
|`peek()`|`null`|


```java
/**
 * Removes all available elements from this
 * queue and adds them to the given collection.
 * This operation may be more efficient than
 * repeatedly polling this queue.
 *
 * @param c the collection to transfer elements into
 * @return the number of elements transferred
 */
int drainTo(Collection< ? super E > c)
```

Il metodo drainTo "scarica" la coda in una collezione.  Questa operazione è più efficiente che un ciclo di `poll` fino ad esaurimento, ma non è atomica. Attenzione che il risultato non è definito (non interviene un'eccezione) se la coda viene modificata durante l'operazione: gli elementi accodati potrebbero essere riportati nella collezione, oppure ignorati.


Le varie implementazioni di `BlockingQueue`, ciascuna con le sue specifiche caratteristiche, sono la scelta naturale per implementare sistemi Produttore-Consumatore.


![Producer Consumer](imgs/l10/ProdCons.svg) <!-- .element: style="background: white; width:80%" -->
Implementiamo per esempio un sistema costruito in questo modo: la Main class carica comandi nella classe Printer; la classe Printer mantiene una coda dei lavori da effettuare, ed istanzia un numero di Driver che pescano dalla coda ed eseguono i lavori.


`it.unipd.app2020.safe.PrinterOperator`

```java
Printer concurrent = new ConcurrentPrinter(8);
Thread thread[] = new Thread[10];
out.println("Preparing...");
IntStream.range(0, 10).forEach((i) -> thread[i] =
  new Thread(() -> {
    out.println("Queueing job " + i);
    concurrent.printJob(new Object());
    out.println("Job " + i + " queued");
  }));
out.println("Starting.");
for (int i = 0; i < 10; i++) { thread[i].start(); }
```

La classe main crea la stampante, e una decina di thread che accodano un job sulla stampante stessa.


`it.unipd.app2020.safe.ConcurrentPrinter`

```java
ConcurrentPrinter(int printers) {
  // limit printers to effective cores
  size = printers < cores ? printers : cores;
  // size and build the queue
  queue = new LinkedBlockingQueue< PrintJob >(QUEUE_SIZE);
  // start the executor
  executor = Executors.newFixedThreadPool(size);
  // start drivers
  IntStream.range(0, size).forEach((a) ->
    executor.execute(new PrinterDriver(queue)));
}
```

La stampante inizializza nel costruttore la coda, l'Executor e avvia i driver.


`it.unipd.app2020.safe.ConcurrentPrinter`

```java
@Override
public void printJob(Object document) {
  try {
    queue.put(new PrintJob(document));
  } catch (InterruptedException e) {
    e.printStackTrace();
  }
}
```

Un `PrintJob` è una semplice value class che tiene il tempo di quando è stata creata per poter misurare il tempo di attesa in coda.


`it.unipd.app2020.safe.PrinterDriver`
```java
public void run() {
  try {
    while (true) {
      PrintJob job = queue.take();
      out.printf(...);
      int duration = rnd.nextInt(2500);
      Thread.sleep(duration);
      out.printf(...);
    }
  } catch (InterruptedException ex) {
    out.println("Printer shutting down.");
  }
}
```

Il driver si mette in attesa di un elemento dalla coda, e simula la sua esecuzione in stampa. I messaggi danno conto del tempo d'attesa del job in coda.


*Quiz*: usare `TimeUnit.X.wait` al posto di `Thread.sleep()` nella classe precedente genera un'eccezione: quale e perché?

La soluzione richiede il materiale della prossima lezione.


*Esercizio 1*: implementare un `SerialPrinter` che crea un solo driver ed usa un solo thread.


*Esercizio 2*: Casualmente, il numero di job che vengono accodati è pari a `ConcurrentPrinter.QUEUE_SIZE`.

È facile immaginare cosa succede se sono di meno. Cosa avviene se sono di più?


*Esercizio 3*: La classe `PrinterOperator` accoda i job tramite threads separati.

Cosa succede, nelle condizioni dell'esercizio 2, se invece la classe accodasse direttamente i job?


*Esercizio 4*: La classe `PrinterOperator` così come è scritta non termina: la JVM non si chiude perché l'`Executor` del `ConcurrentPrinter` non viene chiuso.

Come si può fare per permettergli di chiudere correttamente, *dopo* aver eseguito tutti i job?

Nota: questo è un esercizio di design; non è detto che sia risolvibile nel design attuale.


Altre varianti:

* `TransferQueue`: interfaccia per una coda in cui i produttori aspettano i consumatori;
* `BlockingDeque`: interfaccia che permette di prendere un elemento dalla coda o dalla testa.  Deque è una interfaccia di java.util.collection, Transfer no;
* `ArrayBlockingQueue`: implementazione basata su array, con possibilità di _fairness_;
* `LinkedBlockingDeque`, `LinkedBlockingQueue`, `LinkedTransferQueue`: implementazioni basate su liste collegate. N.B. cercare la dimensione su di una lista collegata non è un'operazione nè O(1) nè tantomeno precisa;
* `PriorityBlockingQueue`: coda ordinata per priorità;
* `DelayQueue`: un elemento non può essere preso prima di un ritardo impostato;
* `SynchronousQueue`: ogni produttore deve attendere un consumatore (capacità nulla).


Altre strutture dati interessanti:

Disruptor http://lmax-exchange.github.io/disruptor/ (buffer circolare estremamente efficiente)


Altri Esempi:

http://winterbe.com/posts/2015/05/22/java8-concurrency-tutorial-atomic-concurrent-map-examples/

---

## Thread local variables


Finora abbiamo visto come condividere la stessa variabile fra più thread.

Un'approccio alternativo è invece garantire che la stessa variabile abbia un valore indipendente e separato per ciascun Thread.


```java
/**
 * These variables differ from their normal counterparts
 * in that each thread that accesses one (via its get
 * or set method) has its own, independently initialized
 * copy of the variable.
 */
public class ThreadLocal< T >
```


Una variabile `ThreadLocal` esiste in una copia differente ed indipendente per ciascun Thread che attraversa la sua dichiarazione. Dunque sintatticamente abbiamo un campo solo di un oggetto, ma ogni Thread vede un valore diverso.


```java
/**
 * Creates a thread local variable. The initial value of
 * the variable is determined by invoking the get method
 * on the Supplier.
 *
 */
static < S > ThreadLocal< S >
  withInitial(Supplier< ? extends S > supplier)
```

Il `Supplier` permette l'inizializzazione a partire da una strategia esterna.


```java
/**
 * Returns the value in the current thread's copy of this
 * thread-local variable. If the variable has no value
 * for the current thread, it is first initialized to the
 * value returned by an invocation of the initialValue()
 * method.
 */
public T get()
```

Questa chiamata, sulla stessa variabile lessicale, avrà un risultato differente per ogni thread.


```java
/**
 * Removes the current thread's value for this thread-local
 * variable.
 */
public void remove()
```


```java
/**
 * Sets the current thread's copy of this thread-local
 * variable to the specified value.
 */
public void set(T value)
```


```java
/**
 * Returns the current thread's "initial value" for
 * this thread-local variable.
 *
 */
protected T initialValue()
```


`it.unipd.app2020.safe.LocalVar`

```java
class LocalVar {
  private static final var nextId = new AtomicInteger(0);

  ThreadLocal< Integer > counter;

  LocalVar() {
    counter = ThreadLocal.withInitial(() ->
      nextId.incrementAndGet());
  }

  Integer get() { return counter.get(); }
}
```

Il valore `nextId` è globale; ogni thread accede sempre allo stesso. Il contatore `counter` invece è privato di ciascun thread.


`it.unipd.app2020.safe.LocalReader`

```java
class LocalReader implements Runnable {
  private final LocalVar var;
  private final int item;

  @Override
  public void run() {
    out.println(Thread.currentThread().getName() +
      ", item " + item + ": read " + var.get());
  }
}
```

Questo `Runnable` legge e stampa il valore della variabile ThreadLocal.


`it.unipd.app2020.safe.LocalMain`
```java
ExecutorService executor = Executors.newFixedThreadPool(4);
LocalVar var = new LocalVar();
IntStream.range(0, 20).forEach((a) ->
  executor.execute(new LocalReader(var, a)));
executor.shutdown();
```

Questo main lancia diversi `Runnable` che condividono la medesima istanza di `LocalVar`. Eppure, ciascuno di loro vi legge un valore diverso da un oggetto che, sintatticamente, dovrebbe essere lo stesso per tutti. È invece, tramite la classe `ThreadLocal`, garantito come separato per ciascun thread.


Le variabili `ThreadLocal` hanno il difetto di assomigliare molto a delle variabili globali. Usare con cautela.

