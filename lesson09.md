# 9: Threads

---

## Threads


Approfondiamo la struttura del modello dei Thread in Java e quali operazioni si possono fare su di essi. La descrizione delle varie classi, funzioni, metodi è presente nei commenti del codice. Dunque leggere con attenzione i commenti.

---

## Avvio e ispezione


```java
/**
* Allocates a new Thread object so that it has target as
* its run object, has the specified name as its name, and
* belongs to the thread group referred to by group, and
* has the specified stack size.
*
*/
public Thread(ThreadGroup group,
  Runnable target,
  String name,
  long stackSize)
```

La volta scorsa è stato mostrato come creare un Thread con un parametro. Questo è la forma più completa del costruttore di un Thread. Il parametro `group` può essere soggetto a
restrizioni di sicurezza, perché è usato da alcuni meccanismi di abilitazione di capabilities. Il supporto del parametro
`stackSize` è a discrezione della specifica implementazione della JVM.


```java
/**
* Causes this thread to begin execution; the Java Virtual
* Machine calls the run method of this thread.
*
*/
void start()
```

Come abbiamo già visto, questo metodo ritorna immediatamente al chiamante, e contemporaneamente il metodo `run()` dell'oggetto (o il `Runnable` passato alla costruzione) viene avviato su di una linea di esecuzione separata.


```java
/**
* Returns this thread's name.
*/
public String getName()
```

Per gestire una popolazione di thread, e per rendere più facili da leggere i log, ogni thread ha un nome, che
viene impostato o dal costruttore o automaticamente.


```java
/**
* Tests if this thread is alive.
*/
public boolean isAlive()
```

Un thread può trovarsi in diversi stati a seconda del momento in cui si trova la sua esecuzione, "alive" non è l'unico stato possibile.


```java
/**
* If this thread was constructed using a separate Runnable
* run object, then that Runnable object's run method is
* called; otherwise, this method does nothing and returns.
*/
public void run()
```

Al contrario di `start()`, questo metodo non ritorna: esegue il contenuto dell'oggetto thread all'interno del chiamante. Di solito il metodo non fa altro che richiamare il costruttore del runnable, e non è questo quello che si desidera.

`start()` chiama `run()`, si può ridefinire `run()` e fargli stampare stringhe a video per fini di tracciamento.

```java
/**
* Returns a reference to the currently executing thread
* object.
*
*/
public static Thread currentThread()
```

Questo metodo consente di ottenere il riferimento al thread correntemente di esecuzione per effettuare operazioni introspettive.


```java
/**
* Causes the currently executing thread to sleep
* (temporarily cease execution) for the specified number of
* milliseconds, subject to the precision and accuracy of
* system timers and schedulers
*
* @param millis the length of time to sleep in milliseconds
*
*/
public static void sleep(long millis)
  throws InterruptedException
```

Negli esempi, è un modo molto comodo per rendere più visibili (non istantanee) le interazioni fra i thread.

---

## Esempi


`it.unipd.app2020.threads.ThreadObserver`

```java
final Thread observer = new Thread(() -> {
  out.println("(Start) Target live: " + tgt.isAlive());
  for (int i = 0; i < 10; i++) { 
    try { 
      Thread.sleep(100L); 
      out.println("Target live: " + tgt.isAlive());
    } catch (InterruptedException e) {
      out.println(" Observer Interrupted"); 
      e.printStackTrace(); 
    } 
  } 
  out.println("(End) Target live: " + tgt.isAlive());
});
```

Costruiamo un thread `observer` che osserva lo stato di un altro thread. Passiamo una lambda a `observer`. Viene verificato subito che il thread osservato sia vivo. Lo stato viene controllato per 10 volte, ogni 100ms.


```java
public static void main(String[] args) {
  final Thread tgt = new ThreadSupplier(800L).get();

  // ...observer...

  observer.start();
  tgt.start();
}
```

Il thread osservato `tgt` attende 800ms prima di uscire, quindi dovremmo notare il cambio di stato. 

Ancora osserviamo che la JVM non termina dopo l'avvio dei Thread.

---

## Stato del Thread


![Thread States](imgs/l09/ThreadStates.png)
java.lang.Thread.State


### NEW

Il Thread è stato creato.

![Thread States-F1](imgs/l09/ThreadStates-f1.png)


### RUNNABLE

È stato richiamato `start()`. Il metodo `run()` del Thread o del Runnable contenuto può essere messo in esecuzione.

N.B. non confondere un thread in stato Runnable con un oggetto della classe Runnable!

![Thread States-F1](imgs/l09/ThreadStates-f2.png)


### RUNNING

Il Thread è effettivamente in esecuzione, ha a disposizione la CPU. Può uscire da questo stato quando gli viene sottratta la CPU o quando passa ad altro stato (se si mette in attesa di un'altra risorsa o se chiama un'operazione di IO bloccante).

![Thread States-F1](imgs/l09/ThreadStates-f3.png)


### BLOCKED

Il Thread ha richiesto accesso ad una risorsa monitorata (per es. un canale di I/O) e sta aspettando la disponibilità di dati. Il thread può tornare Runnable quando ha ottenuto la risorsa o è terminata l'operazione di IO.

![Thread States-F1](imgs/l09/ThreadStates-f3.png)


### WAITING

Il Thread si è posto in attesa di una risorsa protetta da un _lock_ (vedremo cos'è...) chiamando `wait(object)` e sta aspettando il suo turno. Il thread può tornare Runnable quando viene chiamato `notify(object)`

![Thread States-F1](imgs/l09/ThreadStates-f3.png) 


### TIMED_WAITING

Il Thread si è posto in attesa di un determinato periodo di tempo (per es. con `sleep(millis)`) scaduto il quale ritornerà Runnable. Una struttura della JVM si occupa di controllare il tempo rimanente alla scadenza per ciascun thread in timed_waiting.
Il thread lancia timed_exception quando viene interrotto prima di aver atteso il tempo specificato.

![Thread States-F1](imgs/l09/ThreadStates-f3.png)


### TERMINATED

Il metodo run() è completato (correttamente o meno) ed il Thread ha concluso il lavoro. Se non c'è più alcun riferimento al thread terminato, tutte le sue strutture possono essere raccolte dalla Garbage Collection.

![Thread States-F1](imgs/l09/ThreadStates-f4.png)

---

## Interruzioni ed eccezioni


```java
/**
 * Interrupts this thread.
 *
 */
public void interrupt()
```

Come abbiamo appena detto, un thread può concludere la sua esecuzione correttamente o meno. Fra i modi non corretti abbiamo il lancio di una eccezione all'interno della sua esecuzione, oppure il metodo interrupt che può essere invocato anche da un altro thread.


`it.unipd.app2020.threads.ThreadInterrupter`

```java
@Override public void run() {
  out.println("Target Thread alive: " + tgt.isAlive());
  for (int i = 0; i < 4; i++) { 
    try { 
      Thread.sleep(1000L); 
      tgt.interrupt(); 
      out.println("Target interrupted."); 
    } catch (InterruptedException e) { 
      out.println("Interrupter Interrupted"); 
      e.printStackTrace(); 
    } 
  }
  out.println("Target Thread alive: " + tgt.isAlive());
}
```

Creiamo una classe `Interrupter` che implementa `Runnable` in questo modo.


```java
public static void main(String[] args) {
  final Thread tgt = new ThreadSupplier(2000L).get();
  final Thread interrupter = new Thread(new Interrupter(tgt));

  interrupter.start();
  tgt.start();
}
```

Osserviamo che interrompere un thread che non è vivo non porta a nessun risultato.


```java
/**
 * Set the handler invoked when this thread abruptly
 * terminates due to an uncaught exception.
 */
public void setUncaughtExceptionHandler(
    Thread.UncaughtExceptionHandler eh)
```

Possiamo impostare, per uno specifico thread, un gestore delle eccezioni che riceve le eccezioni non intercettate e può quindi modificare il modo in cui un thread termina in modo non previsto.


`it.unipd.app2020.threads.RethrowingThread`

```java
@Override
public Thread get() {
  return new Thread(() -> {
    String s = Thread.currentThread().getName();
    long t = waitTime.get();
    out.println(s + " will wait for " + t + " ms."); 
    try { 
      Thread.sleep(t); 
      out.println(s + " is done wating for " + t + " ms." ); 
    } catch (InterruptedException e) { 
      throw new RuntimeException(e); 
    } 
  }); 
}
```

Creiamo uno specifico supplier per farci fornire dei threads che rilanciano l'eccezione di interruzione invece di gestirla. A tutti gli effetti, se interrotti questi thread lanciano una eccezione non gestita. 


```java
final Thread tgt=new RethrowingThreadBuilder(2000L).get(); 
tgt.setUncaughtExceptionHandler((Thread t, Throwable e) -> {
  out.println("Thread " + t.getName() +
    " has thrown:\n" + e.getClass() + ": " + e.getMessage());
  });

final Thread interrupter = new Thread(new Interrupter(tgt));
interrupter.start();
tgt.start();
```

Impostiamo l'exception handler sul thread bersaglio: vedremo che l'handler viene richiamato e gestisce l'eccezione.

---

## Executors


Creare un nuovo Thread per ogni operazione da fare può velocemente diventare costoso.

L'amministrazione dei Thread impegnati, allo stesso modo, si complica al crescere del numero degli oggetti.


La soluzione è cedere parte del controllo al sistema, in cambio di maggiore semplicità ed efficienza.


```java
/**
 * An object that executes submitted Runnable tasks.
 * This interface provides a way of decoupling task submission
 * from the mechanics of how each task will be run, including
 * details of thread use, scheduling, etc.
 *
 */
public interface Executor
```


```java
/**
 * Executes the given command at some time in the future.
 * The command may execute in a new thread, in a pooled
 * thread, or in the calling thread, at the discretion
 * of the Executor implementation.
 *
 * @param command the runnable task
 *
 */
void execute(Runnable command)
```


`it.unipd.app2020.threads.FixedThreadPool`

```java
Executor executor = Executors.newFixedThreadPool(4);

var threads = Stream.generate(new ThreadSupplier());
out.println("Scheduling runnables");
threads.limit(10).forEach((r) -> executor.execute(r));
out.println("Done scheduling.");
```

Notate come in questo caso la JVM sia rimasta attiva: l'ExecutorService rimane in attesa di nuovi compiti da eseguire, anche se il metodo `main` è concluso.


`it.unipd.app2020.threads.SingleThreadPool`

```java
Executor executor = Executors.newSingleThreadExecutor();

var threads = Stream.generate(new ThreadSupplier());
out.println("Scheduling runnables");
threads.limit(10).forEach((r) -> executor.execute(r));
out.println("Done scheduling.");
```

Dal nome e dal comportamento possiamo osservare come i compiti accodati siano eseguiti da un solo thread.


Esempi di esecutori:

| Tipo | Funzionamento |
| -- | -- |
| CachedThreadPool | Riusa thread già creati, ne crea nuovi se necessario |
| FixedThreadPool | Riusa un insieme di thread di dimensione fissa|


Esempi di esecutori:

| Tipo | Funzionamento |
| -- | -- |
| ScheduledThreadPool | Esegue i compiti con una temporizzazione |
| SingleThreadExecutor | Usa un solo thread per tutti i compiti |


Esempi di esecutori:

| Tipo | Funzionamento |
| -- | -- |
| ForkJoinPool | Punta ad usare tutti i processori disponibili. Specializzato per il framework di fork/join |

Usa un algoritmo detto di _work stealing_ per gestire il caso in cui le attività eseguite avviino ulteriori sotto-attività. Interessante l'annotazione: `This implementation restricts the maximum number of running threads to 32767`

---

## Callables


Finora abbiamo usato come lavoro da eseguire dei `Runnable`, cioè dei blocchi privi di risultato.


L'interfaccia `Callable` ci permette di definire dei compiti che producono un risultato.


```java
/**
 * A task that returns a result and may throw an exception.
 */
@FunctionalInterface
public interface Callable < V > {
  /**
   * Computes a result, or throws an exception if unable
   * to do so.
   *
   * @return computed result
   * @throws Exception - if unable to compute a result
   */
  V call() throws Exception;
}
```


Un semplice `Executor` non esegue `Callable`: è necessario scegliere un `ExecutorService`, che espone i metodi necessari.


```java
/**
 * An Executor that provides methods to manage termination
 * and methods that can produce a Future for tracking
 * progress of one or more asynchronous tasks.
 *
 */
public interface ExecutorService
  extends Executor
```

Diversi `Executor` comunque implementano anche questa interfaccia.


```java
/**
 * Submits a value-returning task for execution and
 * returns a Future representing the pending results
 * of the task.
 *
 * @param T - the type of the task's result
 * @param task - the task to submit
 * @return a Future representing pending completion
 * of the task
 *
 */
 < T > Future< T > submit(Callable< T > task)
```


Un `Future` è rappresenta un calcolo che prima o poi ritornerà un valore. È possibile verificare se il calcolo è stato completato, ottenere il valore risultante, o controllare se sia ancora in corso.


```java
/**
* A Future represents the result of an asynchronous
* computation. Methods are provided to check if the
* computation is complete, to wait for its completion,
* and to retrieve the result of the computation.
*
*/
public interface Future< V >
```


```java
/**
 * Waits if necessary for the computation to complete,
 * and then retrieves its result.
 *
*/
T get()
```


```java
/**
 * Returns true if this task completed.
 *
 */
boolean isDone()
```


`it.unipd.app2020.ScheduledFuture`

```java
ThreadPoolExecutor executor =
  (ThreadPoolExecutor) Executors.newFixedThreadPool(4);
Supplier< Callable< Integer > > supplier =
  new FactorialBuilder();
List< Future< Integer > > futures =
  new ArrayList< Future< Integer > >();
```


```java
for (int i = 0; i < 10; i++) 
  futures.add(executor.submit(supplier.get())); 
while (executor.getCompletedTaskCount() < futures.size()) { 
  out.printf("Completed Tasks: %d: %s\n", 
    executor.getCompletedTaskCount(), 
    format(futures)); 
  TimeUnit.MILLISECONDS.sleep(50); 
}
```


Con a disposizione una lista di `Callables`, un `ExecutorService` ci permette di: 
* ottenere un risultato di un `Future` che ha terminato (non necessariamente il primo, ma probabilmente uno dei primi) 
* ottenere una lista di `Future` nel momento in cui sono tutti completati 


```java 
/** 
 * Executes the given tasks, returning the 
 * result of one that has completed successfully 
 * (i.e. without throwing an exception), if any do. 
 * 
 */ 
< T > T invokeAny(
  Collection < ? extends Callable< T > > tasks)
```

Quando questa chiamata ritorna, non tutti i `Callable` hanno completato l'esecuzione.


```java
/**
 * Executes the given tasks, returning a list of Futures
 * holding their status and results when all complete.
 * Future.isDone() is true for each element of the
 * returned list.
 */
< T > List< Future< T > >
  invokeAll(Collection< ? extends Callable< T > > tasks)
```

Questa chiamata ritorna solo dopo che almeno uno dei `Future` ha completato.


`it.unipd.app2020.AllFutures`

```java
ThreadPoolExecutor executor =
  (ThreadPoolExecutor) Executors.newFixedThreadPool(4);
var supplier = new FactorialBuilder();
var callables = new ArrayList< Callable< Integer > >();
for (int i = 0; i < 10; i++)
  callables.add(supplier.get());

out.println("Scheduling computations");
var futures = executor.invokeAll(callables);
out.println("Done scheduling.");
```


`it.unipd.app2020.AnyFutures`

```java
ThreadPoolExecutor executor =
  (ThreadPoolExecutor) Executors.newFixedThreadPool(4);
var supplier = new FactorialBuilder();
var callables = new ArrayList< Callable< Integer > >();
for (int i = 0; i < 10; i++)
  callables.add(supplier.get());

out.println("Scheduling computations");
var result = executor.invokeAny(callables);
out.println("Done invoking: " + result);
```


Un `ExecutorService` rimane sempre in attesa di nuovi compiti da eseguire, impedendo alla JVM di terminare.

Per permettere alla JVM di fermarsi bisogna esplicitamente fermare il servizio.


```java
/**
 * Initiates an orderly shutdown in which previously
 * submitted tasks are executed, but no new tasks will
 * be accepted.
 *
 */
void shutdown()
```


```java
/**
 * Blocks until all tasks have completed execution after a
 * shutdown request, or the timeout occurs, or the current
 * thread is interrupted, whichever happens first.
 *
 */
boolean awaitTermination(long timeout, TimeUnit unit)
```


```java
/**
 * Returns true if all tasks have completed following
 * shut down.
 *
 */
boolean isTerminated()
```


```java
/**
 * Attempts to stop all actively executing tasks, halts
 * the processing of waiting tasks, and returns a list
 * of the tasks that were awaiting execution.
 *
 */
List< Runnable > shutdownNow()
```