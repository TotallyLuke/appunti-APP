# 11: Sincronizzazione

---

## Natura del problema


Abbiamo visto i vari metodi con cui gestire l'accesso agli stessi dati da parte di più `Thread`s.


Tuttavia, non tutto è modellabile con una struttura dati: a volte quello di cui abbiamo bisogno è controllare come diversi `Thread`s attraversano una sezione di codice.


`it.unipd.app2020.sync.SimpleCounter`

```
java
/**
* A simple interface to a counter.
*/
interface SimpleCounter {

  public void add();

  public int getState();
}
```


`it.unipd.app2020.sync.UnsyncCounter`

```java
class UnsyncCounter implements SimpleCounter {
  private int state = 0;
  public void add() {
    int current = state;
    try {
      TimeUnit.MILLISECONDS.sleep(
        Math.round(Math.random() * 100));
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    state = current + 1;
  }
}
```


`it.unipd.app2020.sync.Incrementer`

```java
class Incrementer implements Callable< Boolean > {
  private SimpleCounter counter;
  Incrementer(SimpleCounter counter) {
    this.counter = counter;
  }
  @Override
  public Boolean call() {
    IntStream.range(0, 10).forEach((i) -> counter.add());
    return true;
  }
}
```


`it.unipd.app2020.sync.RunCounter`

```java
ExecutorService executor = Executors.newFixedThreadPool(1);

SimpleCounter counter = new UnsyncCounter();
List< Incrementer > incs = List.of(new Incrementer(counter),
  new Incrementer(counter), new Incrementer(counter),
  new Incrementer(counter));

executor.invokeAll(incs);

System.out.println("All done. Final state: " +
  counter.getState() + " (" + (end - time) + ")");
```
Il risultato non è quello atteso. Il problema sorge quando più thread si trovano nella classe `add()` della classe`UnsyncCounter`.

---

## Syncronized


**Definizione**: si dice _sezione critica_ la parte di codice in cui vengono acceduti i dati condivisi.

Permettere a più Thread di trovarsi contemporaneamente nella sezione critica porta ad errori.


La soluzione è impedire a più Thread di trovarsi insieme nella sezione critica.


`syncronized` è una parola chiave che applicata ad un blocco di istruzioni impedisce che sia percorso contemporaneamente da più di un Thread. Non è sufficiente una classe o una libreria, abbiamo bisogno di una parola chiave nel linguaggio: quello che avviene è un cambiamento nelle istruzioni emesse dal compilatore.

Proviamo a sostituire dall'esempio sopra la classe UnsyncCounter con SyncCounter
`it.unipd.app2020.sync.SyncCounter`

```
java
class SyncCounter implements SimpleCounter {
  private int state = 0;
  syncronized public void add() {
    int current = state;
    try {
      TimeUnit.MILLISECONDS.sleep(
        Math.round(Math.random() * 100));
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    state = current + 1;
  }
}
```

Sostituire questa classe alla precedente nel metodo main per verificare come il comportamento diventa ora corretto. La sezione critica, cioè il metodo in cui viene modificato lo stato, è ora protetta. Il programma impiega molto più tempo a terminare.


`syncronized` può decorare due tipi di raggruppamenti di istruzioni:
* un blocco di istruzioni semplice `{ ... }`
* un metodo


Tutti i blocchi sincronizzati di un oggetto condividono lo stesso `monitor lock` o `intrinsic lock`, cioè un oggetto dedicato alla gestione della concorrenza presente in ogni oggetto Java. La presenza di un monitor è motivo della penalità di performance nell'utilizzo delle versioni boxed dei tipi primitivi.

Quanto un Thread rilascia un `monitor` uscendo da un blocco `syncronized`, stabilisce una relazione di `happens-before` fra l'azione di rilascio del lock e ogni successiva acquisizione dello stesso.


Una forma alternativa della parola chiave `syncronized` permette di esplicitare l'oggetto su cui effettuare la sincronizzazione.


`syncronized (that) {...}` permette di rendere il blocco di codice sincronizzato sul `monitor` dell'oggetto ritornato dall'espressione `that`.

`syncronized {...}` è equivalente a `syncronized (this) {...}`


Tutti i `monitor` sono `reentrant`: un Thread può acquisire lo stesso `monitor lock` più volte senza temere di entrare in un _deadlock_ con sè stesso. Una volta entrato in metodi `syncronized` può chiamare altri metodi `syncronized` senza bloccarsi con sè stesso.

Segue un esempio che modella due attori che si salutano con un inchino. Per evitare che due attori si salutino contemporaneamente (sbattendo la testa), rendiamo `syncronized` i metodi di saluto, così un attore può essere salutato (metodo `bow()` da un solo thread alla volta.:
`it.unipd.app2020.sync.SimpleFriend`

```
java
class SimpleFriend {
  private final String name;

  public synchronized void bow(SimpleFriend bower) {
    System.out.format("%s: %s" + " has bowed to me!%n",
      this.name, bower.getName());
    bower.bowBack(this);
  }

  public synchronized void bowBack(SimpleFriend bower) {
    System.out.format("%s: %s" + " has bowed back to me!%n",
      this.name, bower.getName());
  }
}
```

Syncronized non è la soluzione a tutti i mali.


`it.unipd.app2020.sync.SimpleFriend`

```
java
public class SimpleFriends {

  public static void main(String[] args) {
    final SimpleFriend alphonse = new SimpleFriend("Alphonse");
    final SimpleFriend gaston = new SimpleFriend("Gaston");
    new Thread(() -> alphonse.bow(gaston)).start();
    new Thread(() -> gaston.bow(alphonse)).start();
  }
}
```
In realtà due attori si bloccano l'uno con l'altro in un deadlock assolutamente classico. Cfr: https://docs.oracle.com/javase/tutorial/essential/concurrency/deadlock.html Quello che succede è che Alphonse ottiene il lock su Gaston chiamando il suo `gason.bow()`. Ma quando cercha di chiamare il metodo `bowBack()` su sè stesso, non può farlo perché Gaston a sua volta ha ottenuto il lock su di lui chiamando `alphonse.bow()`. Gaston è nella stessa situazione, e quindi i tue thread sono in deadlock.


![Deadlock solutions](imgs/l11/Deadlock.png)

---

## Wait


Un'alternativa a `syncronized` è la gestione esplicita del monitor di un oggetto.
Invece di dire _sintatticamente_ che un pezzo di codice acquisisce il monitor, ci si mette in attesa del monitor di un oggetto. 

```java
/**
* Causes the current thread to wait until another
* thread invokes the notify() method or the notifyAll()
* method for this object.
*/
void wait() throws InterruptedException;
```
Chiamando il metodo `wait()` (definito in `Object`) ci si nello stato di _waiting_ (lezione 09). Si è in attesa che un altro Thread chiami `notify` o `notifyAll`

Per operare sul monitor dell'oggetto il Thread deve "averlo a disposizione", cioè poter asserire la "proprietà" dell'oggetto.


Un Thread può farlo:
* eseguendo un metodo `synchronized` dell'oggetto
* eseguendo un blocco `synchronized` all'interno dell'oggetto
* se l'oggetto una `Class`, eseguendone un metodo `synchronized static`

È il compilatore può controllare che sia valida una di queste tre condizioni.

Il vantaggio rispetto all'uso di Syncronized è quello di ridurre la porzione di codice a mutua esclusione e la possibilità di controllare come la concorrenza avviene e come diversi Thread interagiscono per ottenere il lock.


```java
/**
* Wakes up a single thread that is waiting on this
* object's monitor.
*/
void notify();
```


```java
/**
* Wakes up all threads that are waiting on this
* object's monitor.
*/
void notifyAll();
```


`it.unipd.app2020.sync.Named`

``` java
class Named {
  public final String name;
  private boolean red = false;

  Named(String name) {
    this.name = name;
  }

synchronized void perform() throws InterruptedException {
  if (!red) {
    red = true;
    this.wait();
  } else {
    red = false;
    this.notify();
  }
}
``` 

Un solo thread alla volta può entrare in questo metodo. Se il flag è falso, viene posto a vero ed il thread si mette in attesa su questo oggetto (liberando il monitor). Se il flag è vero, viene posto a falso e un thread in attesa viene notificato che può proseguire.


`it.unipd.app2020.sync.Waiter`

```
java
class Waiter implements Runnable {
  private final Named first, second;

  Waiter(Named first, Named second) {
    this.first = first;
    this.second = second;
  }
```

Il `Runnable` `Waiter` usa due risorse.


```java
var thread = Thread.currentThread().getName();
System.out.println(thread + " waiting on " + first.name);
String doing = first.name;
try {
  first.perform();
  System.out.println(thread + " signalled on " + first.name);
  System.out.println(thread + " waiting on " + second.name);
  doing = second.name;
  second.perform();
} catch (InterruptedException e) {
  System.out.println(thread + " interrupted on " + doing);
}
System.out.println(thread + " signalled on " + second.name);
```

Note: Il suo obiettivo è eseguire `perform()` prima su una risorsa, poi sulla seconda.



```java
Named a = new Named("a"), b = new Named("b"),
c = new Named("c"), d = new Named("d");
new Thread(new Waiter(a, d), "Waiter 1").start();
new Thread(new Waiter(b, d), "Waiter 2").start();
new Thread(new Waiter(c, d), "Waiter 3").start();
try {
  a.perform();
  b.perform();
  c.perform();
  d.performAll();
} catch (InterruptedException e) { e.printStackTrace(); }

```

Il main crea quattro risorse e tre threads, che condividono la quarta risorsa. Esegue `perform()` sulle risorse una dopo l'altra, andando a liberare i thread che erano in attesa di sincronizzazione. Infine, richiama `performAll()` sull'ultima risorsa, liberando i thread che erano là bloccati.


![NamedWaiter](imgs/l11/NamedWaiter.png)

L'ordine delle operazioni, quando non mediato dai `syncronize`, è assolutamente casuale. I Waiter si appropriano della prima risorsa, ma devono aspettare Main che li fa avanzare. A questo punto, uno di loro ottiene la seconda risorsa mentre


Attenzione: [la documentazione avvisa esplicitamente](https://docs.oracle.com/en/java/javase/15/docs/api/java.base/java/lang/Object.html#wait%28long,int%29) che un thread può essere svegliato da un `wait()` senza nessun `notify()`. Viene detto "Spurious wakeup".

---

## Locks

`syncronized` crea un blocco implicito, mentre `wait()` ci costringe a gestire lo stato del blocco.

A volte abbiamo bisogno di controllare esplicitamente le condizioni di blocco e sblocco della sezione critica.


```java
/**
* Lock implementations provide more extensive locking
* operations than can be obtained using synchronized
* methods and statements.
*/
public interface Lock;
```

L'uso di un `Lock` ci permette di slegare l'acquisizione ed il rilascio di una risorsa dalla struttura lessicale in cui questo avviene. Questo perché non è legato all'esecuzione di un blocco di codice come sono invece `syncronize` e `wait()`.


```java
/**
* Acquires the lock.
*/
void lock();
```
Questa chiamata ovviamente blocca se il lock non è disponibile.


```java
/**
* Releases the lock.
*
*/
void unlock();
```

Questa chiamata ha l'effetto di sbloccare un thread (tipicamente, uno a caso) fra quelli che attendevano di acquisire il lock.


```java
/**
* Acquires the lock only if it is free at the time
* of invocation.
*
*/
boolean tryLock();
```

Questa chiamata prova ad aquisire il lock, ma non si blocca se non lo trova disponibile

`it.unipd.app2020.sync.LockedFriend`

```java
class LockedFriend {
  private final String name;
  private final Lock lock = new ReentrantLock();

  public LockedFriend(String name) {
    this.name = name;
  }

  public String getName() {
    return this.name;
  } 
``` 
Risolviamo il problema dei due attori che si salutano. Si noti che il metodo si chiama `impendingBow`, (_accenna_ all'inchino). Il metodo prova averificare la disponibilità di ambo i lock. Se uno dei due non è libero l'attore rilascia il proprio lock.


```java
public boolean impendingBow(LockedFriend bower) {
  boolean myLock = false, yourLock = false;
  try {
    myLock = lock.tryLock();
    yourLock = bower.lock.tryLock();
  } finally {
    if (!(myLock && yourLock)) {
      if (myLock) { lock.unlock();}
      if (yourLock) { bower.lock.unlock(); }
    }
  }
  return myLock && yourLock;
}
```

Proviamo ad acquisire entrambi i lock; siamo ora in grado di rilasciarli in caso di acquisizione parziale.


```java
public void bow(LockedFriend bower) {
  if (impendingBow(bower)) {
    try {
      out.format("%s: %s has" + " bowed to me!%n",
        this.name, bower.getName());
      bower.bowBack(this);
    } finally { lock.unlock(); bower.lock.unlock(); }
  } else {
    out.format("%s: %s started to bow to me, but saw that"
      + " I was already bowing to him.\n",
      this.name, bower.getName());
  }
}
```

Se `impendingBow()` ritorna `true`, abbiamo entrambi i lock (e quindi dobbiamo rilasciarli). Notate come non siamo legati ai monitor impliciti o a lavorare all'interno di un solo blocco di codice. Se `impendingBow()` ha ritornato falso, abbiamo evitato un deadlock: avendo rilasciato l'acquisizione parziale, abbiamo probabilmente permesso all'altro thread di completare la sua.


```java
public static void main(String[] args) {
  final LockedFriend alphonse = new LockedFriend("Alphonse");
  final LockedFriend gaston = new LockedFriend("Gaston");
  new Thread(new BowLoop(alphonse, gaston)).start();
  new Thread(new BowLoop(gaston, alphonse)).start();
}
```

Questo esempio proviene [dal tutorial sui lock](https://docs.oracle.com/javase/tutorial/essential/concurrency/newlocks.html) (dalla documentazione Java Oracle).

---

## Producer and Consumer

_Producer/Consumer_: pattern architetturale che modella un insieme di thread divisi in due gruppi:

* _Producers_: threads che producono dati da elaborare;
* _Consumers_: threads che elaborano i dati prodotti.

Gestiamo con un `Lock` la sezione critica in cui avviene al consegna dei dati da elaborare da un thread al consumatore. Il Consumatore ammette un solo `Thread` alla volta nella sezione critica.


Il `Lock`, implicitamente, gestisce la coda dei Produttori in attesa. Si sceglie di usare un `ReentrantLock` per gestire tale coda.


```java
/**
* Creates an instance of ReentrantLock with the given
* fairness policy.
*
*/
public ReentrantLock(boolean fair)
```


Un `ReentrantLock` ha caratteristiche equivalenti ad un `implicit lock`, ma può essere controllato manualmente (con le responsabilità che ne derivano).


Se viene costruito come `fair` il `Thread` che riceve il lock è sempre quello che ha aspettato di più. Si riduce il rischio di `starvation` a prezzo di una prestazione inferiore (dovuta al maggior costo di mantenere una gestire una lista ordinata).


```java
public class PrintQueue implements Printer {
  private final Lock queueLock = new ReentrantLock();

  public void printJob(Object document) {
    queueLock.lock();
    try {
      Long duration = (long) (Math.random() * 10000);
      Thread.sleep(duration);
    } catch (InterruptedException e) { 
      e.printStackTrace();
    } finally { queueLock.unlock(); }
  }
}
```

Rispetto all'esempio con la `BlockingQueue`, gestiamo direttamente l'accesso alla sezione critica.


```java
public static void main(String args[]) {
  PrintQueue printQueue = new PrintQueue();
  Thread thread[] = new Thread[10];
  for (int i = 0; i < 10; i++) { 
    thread[i] = new Thread(new Job(printQueue), 
      "Thread " + i); } 
  for (int i=0; i < 10; i++) { 
    thread[i].start(); } 
  } 
```

Il metodo `main()` non è cambiato di molto. 

---

## Conditions 


A volte, non tutti i Thread che cercano di acquisire un lock sono uguali: possono avere semantiche diverse e possono necessitare di essere segnalati in condizioni differenti. 


Una `Condition` permette di separare l'accodamento in attesa dal possesso del lock che controlla l'attesa. Lo scopo è da poter gestire, su di un solo lock, di più condizioni di attesa distinte. 


```java 
/** 
 * Returns a new Condition instance that is bound to this 
 * Lock instance. 
 * 
 */ 
public Condition newCondition() 
```

Una Condition ci viene fornita dal lock su cui deve sussistere. Ciascuna `Condition` di uno stesso lock consente di gestire un insieme distinto di Thread in attesa. 


```java 
/** 
 * Causes the current thread to wait until it is signalled 
 * or interrupted. 
 * 
 */ 
public void await() 
```


```java 
/** 
 * Wakes up one waiting thread. 
 * 
 */ 
public void signal() 
```


```java 
/** 
* Wakes up all waiting threads. 
* 
*/ 
public void signalAll() 
```

Questa è una sorgente di linee di testo.

`it.unipd.app2020.sync.CharSource` 

```java 
/** 
 * Bounded, non thread-safe random source of characters
 */ 
 class CharSource { 
  public boolean hasMoreLines() 
  public Optional< String > getLine()
```

Questo è un Buffer. Crea un lock per bloccare l'accesso alle zone critiche, e ne ottiene due `Condition`: una sarà usata per attendere la presenza di nuove linee, l'altra per mettere in attesa i thread che non trovano dati da consumare. Usando un lock il buffer garantisce la mutua esclusione, ma usando due Condition il buffer distingue produttori e consumatori.

`it.unipd.app2020.sync.Buffer`

```java
class Buffer {
private LinkedList< String > buffer;
  private int maxSize;
  private ReentrantLock lock;
  private Condition lines, space;
  private boolean pendingLines;

  public Buffer(int maxSize) {
    this.maxSize = maxSize; pendingLines = true;
    buffer = new LinkedList<>();
    lock = new ReentrantLock();
    lines = lock.newCondition();
    space = lock.newCondition();
  }
```

Per inserire una linea, prima di tutto acquisiamo il lock per la sezione critica; se non c'è spazio, ci mettiamo in attesa anche sul lock dello spazio. Infine, aggiungiamo la riga al buffer e segnaliamo chi attendeva linee che ce ne sono di disponibili.


```java
public void insert(String line) {
  lock.lock();
  try {
    while (buffer.size() == maxSize) { 
      space.await(); 
    }
    buffer.offer(line);
    out.printf("%s: Inserted Line: %d\n",
    Thread.currentThread().getName(), buffer.size());
    lines.signalAll();
  } catch (InterruptedException e) { 
    e.printStackTrace(); 
  } finally { lock.unlock(); }
}
```

Per ottenere una riga, prima di tutto acquisiamo il lock per la sezione critica; se non ci sono linee, attendiamo sulla condizione che ci siano righe a disposizione. Se ce ne sono, ne otteniamo una; potrebbe però essere vuota, perché un altro thread l'ha presa prima di noi. Infine, segnaliamo disponibilità di spazio e rilasciamo il lock critico.


```java
public Optional< String > get() {
  Optional< String > line = Optional.empty();
  lock.lock();
  try {
    while ((buffer.size() == 0) && (hasPendingLines())) {
      lines.await(); 
    }
    if (hasPendingLines()) {
      line = Optional.ofNullable(buffer.poll());
    space.signalAll(); }
  } catch (InterruptedException e) { e.printStackTrace(); }
  } finally { lock.unlock(); }
  return line;
}
```
Questi due metodi ci permettono di controllare se ci sono linee pendenti, o di impostare la loro disponibilità.

```java
public boolean hasPendingLines() {
  return pendingLines || buffer.size() > 0;
}

public void setPendingLines(boolean pendingLines) {
  this.pendingLines = pendingLines;
}
```
Il producer è un `Runnable` che prende una riga dalla sorgente, e la mette nel buffer, segnalando la presenza di nuove righe, e la loro assenza quando la sorgente è consumata. Il flag `pendingLines` del `Buffer` permette al produttore di segnalare la propria presenza ai consumatori, in modo che siano rassicurati dell'arrivo di nuove linee.

`it.unipd.app2020.sync.Producer`

```java
class Producer implements Runnable {
  private CharSource source;
  private Buffer buffer;

  @Override
  public void run() {
    buffer.setPendingLines(true);
    while (source.hasMoreLines())
      source.getLine().ifPresent((line) -> {
        buffer.insert(line); randomWait(50);
      });
    buffer.setPendingLines(false);
  }
}
```

Il consumer è un altro `Runnable` che prende una riga dal buffer finché c'è speranza che ce ne siano, e ci spende sopra un breve lasso di tempo. Quando non trova più la segnalazione di nuove righe (che include sia linee presenti nel buffer, sia la presenza di un produttore che ne aggiunga) chiude l'esecuzione.


`it.unipd.app2020.sync.Consumer`

```java
class Consumer implements Runnable {
  private Buffer buffer;

  @Override
  public void run() {
    while (buffer.hasPendingLines())
    buffer.get().ifPresent((line) -> process(line));
  }

  private void process(String line) {
    LockedBuffer.randomWait(250);
  }
}
```
Infine, il main fa partire tutti i thread. Poiché non usiamo `Executor`, l'algoritmo viene eseguito e la JVM termina quando tutti i thread terminano, perché il produttore era in grado di segnalare con il flag `pendingLines` se ci sarebbero state nuove righe o meno.

`it.unipd.app2020.sync.LockedBuffer`

```java
public static void main(String[] args) {
  CharSource source = new CharSource(100, 100);
  Buffer buffer = new Buffer(20);
  Thread producer = new Thread(new Producer(source, buffer),
    "producer");
  Thread[] consumers = new Thread[] {
    new Thread(new Consumer(buffer)),
    new Thread(new Consumer(buffer)),
    new Thread(new Consumer(buffer)) };
  producer.start();
  for (Thread t : consumers) t.start();
}
```

Come sempre succede, da grandi poteri derivano grandi responsabilità. Maneggiando direttamente i `Lock` si chiede al sistema di delegarci un notevole potere, ed insieme ne riceviamo una corrispondente responsabilità.

* quando si salta una chiamata `signal()` si rischia deadlock, perché qualcuno rimane in attesa di una risposta
* quando è presente un `await()` di troppo, si rischia il deadlock, perché qualcuno può conservare il lock;
* quando è presente un'eccezione non gestita, si rischia il deadlock, perché si potrebbe saltare un `unlock()`

---

## Semaphores


Per controllare l'accesso ad un insieme omogeneo di risorse, si usa un *semaforo*.

Un semaforo è simile ad un lock, ma tiene un conteggio invece di un semplice stato libero/occupato.


```java
/**
* Creates a Semaphore with the given number of permits and
* the given fairness setting.
*
*/
public Semaphore(int permits, boolean fair)
```


Se inizializzato come `fair`, l'ordinamento dei Thread in attesa è garantito FIFO. Altrimenti non è garantito.
Il costo è giustificato quando il semaforo regola l'accesso ad un insieme di risorse. In caso di un uso diverso, un semaforo non `fair` è molto più efficiente.

Ad ogni acquisizione il numero di "permessi" disponibili diminuisce. Ad ogni "rilascio" il numero viene aumentato.


```java
/**
* Acquires a permit from this semaphore, blocking until one
* is available, or the thread is interrupted.
*
*/
public void acquire()
```


```java
/**
* Acquires the given number of permits from this semaphore,
* blocking until all are available, or the thread is
* interrupted.
*
* @param the number of permits to acquire
*/
public void acquire(int permits)
```


```java
/**
* Releases a permit, returning it to the semaphore.
*
*/
public void release()
```


```java
/**
* Releases the given number of permits, returning them to
* the semaphore.
*
* @param the number of permits to release
*/
public void release(int permits)
```


Il valore iniziale del semaforo non è un limite: può essere superato, e può essere anche negativo inizialmente. Mantenere la coerenza semantica sta all'utilizzatore.


A differenza di un lock, un `semaphore` può essere rilasciato da un Thread diverso da quello che lo ha acquisito (ad esempio, un Thread differente può aumentare i permessi).


```java
/**
* Shrinks the number of available permits by the
* indicated reduction.
*
*/
protected void reducePermits(int reduction)
```


La maggior parte dei metodi di `Semaphore`
* può lanciare `InterruptedException` se il thread viene interrotto durante l'attesa;
* lancia `IllegalArgumentException` se il parametro è negativo (non si può acquisire un numero negativo di permessi).


```java
/**
* Acquires a permit from this semaphore, only if one is
* available at the time of invocation.
*
*/
public boolean tryAcquire()
```


```java
/**
* Acquires the given number of permits from this semaphore,
* if all become available within the given waiting time and
* the current thread has not been interrupted.
*
*/
public boolean tryAcquire(int permits, long timeout, 
                          TimeUnit unit)
```


`tryAcquire` ritorna immediatamente, con risultato falso se non ha ottenuto un permesso.

**È in grado di violare la _fairness_ del semaforo**


`it.unipd.app2020.sync.MultiPrintQueue`

```java
class MultiPrintQueue implements Printer {
  private Semaphore semaphore;
  private boolean[] freePrinters;
  private ReentrantLock lockPrinters;

  public MultiPrintQueue() {
    semaphore = new Semaphore(3);
    freePrinters = new boolean[] { true, true, true };
    lockPrinters = new ReentrantLock();
  }
```

Questa implementazione di `Printer` si basa su di un semaforo per contare le stampanti libere ed un array di boolean per mantenere lo stato delle singole stampanti.


```java
public void printJob(Object document) {
  try {
    semaphore.acquire();
    int assignedPrinter = getPrinter();
    Long duration = (long) (Math.random() * 10000);
    TimeUnit.MILLISECONDS.sleep(duration);
    freePrinters[assignedPrinter] = true;
  } catch (InterruptedException e) { e.printStackTrace(); }
  } finally { semaphore.release(); }
}
```

L'esecuzione di una stampa richiede di acquisire il semaforo (che attende una stampante libera se non ce n'è), ottenere la stampante da assegnare, effettuare il lavoro, liberare la stampante e quindi il semaforo.


```java
int getPrinter() {
  int res = -1;l
  try {
    lockPrinters.lock();
    for (int i = 0; i < freePrinters.length; i++) { 
      if (freePrinters[i]) { 
        res=i; freePrinters[i]=false;
        break; 
      } 
    } 
  } catch (Exception e) { e.printStackTrace(); 
  } finally { lockPrinters.unlock(); }
  return res;
} 
```

La selezione di una stampante libera richiede, all'interno di una sezione critica, di cercare un valore `true` nell'array dello stato delle stampanti. Abbiamo la garanzia che ce ne sia almeno uno perché siamo protetti dal semaforo. Trovata la stampante libera, la segnamo occupata e ritorniamo il suo indice al chiamante uscendo dalla sezione critica.
