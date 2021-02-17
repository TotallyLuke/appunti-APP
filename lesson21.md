# 21: Reactive Streams

---

## Oltre le RX


Abbiamo discusso le Reactive Extensions, il Reactive Manifesto e la loro successione temporale.

Il completamento di questa linea tecnologica è la definizione dei Reactive Streams.

---

## Big vs Fast

Negli stessi anni in cui aumentava l'interesse per ReactiveX come piattaforma, il problema del _Big Data_ diventava sempre più importante e mutava in qualcosa più difficile da trattare.

L'approccio usato con i Big Data era quello di prendere un problema molto grande e distribuirlo in un numero grande di dati, permettendo di ottenere una scalabilità quasi lineare nell'esame di una mole di dati.

Il problema stava cambiando: da un lato le moli di dati stavano diventando più grandi di quando si potesse trattare anche con sistemi distribuiti, dall'altro il problema di elaborazione dei dati stava prendendo un carattere tale che l'esecuzione di _batch_ massivamente paralleli, non poteva più funzionare in quanto introduceva latenze superiori al periodo di utilità delle informazioni estratte.

(Per _batch_ si elaborazione non in linea, tipicamente notturna, di dati più grandi di quanto una singola macchina possa trattare.)

Analizzare in un notturna una grande mole di fast data è inutile perché in alcuni domini (analisi di rischio e analisi anti-truffa) sapere l'esito di un evento (è avvenuto una transazione sospetta?) 12-24 ore dopo è inutile; bisogna saperlo in pochi minuti, (o secondi o millisecondi). Esempio simile di _fast data_ sono le transazioni automatiche in Borsa.


Qualche autore comincia a chiamare il problema  **Fast Data**: dati di dimensioni paragonabili ai Big Data, in arrivo continuo.  Persistere ed elaborare questi dati a partire dal supporto di salvataggio è impensabile (mole troppo grande) e inutile (esauriscono la loro utilità dopo pochissimo tempo).

Per il loro volume, per la velocità di arrivo, e la bassa latenza richiesta nel reagire alle informazioni estratte, è necessario trattarli _in diretta_ man mano che si presentano.

Uno dei principali problemi nella costruzione di un sistema parallelo per l'estrazione di informazioni da un flusso di dati _continuo_ è l'armonizzazione delle varie differenze di velocità di elaborazione fra i vari componenti.

Attenzione all'enfasi su "continuo". Mettere da parte qualche secondo di dati e calcolare poi quello alla massima velocità possibile non è la stessa cosa. I risultati sono altalenanti.


Il componente più lento diventerà il collo di bottiglia e stabilirà la velocità massima dell'elaborazione, per poi fallire soverchiato dai dati che arrivano troppo velocemente.

È inutile anche ottimizzare localmente la pipeline di elaborazione: si ottiene solo di accelerare il fallimento (quando si velocizza un componente che era già veloce), o spostarlo al componente più lento successivo (si velocizza il componente più lento, ma il secondo componente più lento diventa il nuovo collo di bottiglia).


Per risolvere questo problema è necessario aggiungere alla semantica delle Reactive Extension la **back-pressure**.


Con **back-pressure** si intende la resistenza che il componente successivo può opporre ai dati provenienti dal componente precedente della catena di elaborazione. Dunque l'idea di base è stata quella di aggiungere alle Reactive Extension una API che permette ad un componente di dichiarare al precedente quanti dati è in grado di elaborare

Questo concetto permette ad ogni nodo della catena di conoscere la quantità di dati che può gestire il nodo successivo. Dunque i nodi possono regolarsi per controllare la gestione dei buffer interni e gli accoppiamenti tra velocità diverse in modo garantire che il consumo di risorse dell'intera catena rimane costante e nessuna area di memoria vada ad esplodere per accumulo di dati. A questo progetto è stato dato il nome di Reactive Strems.

---

## Reactive Streams


"The main goal of Reactive Streams is to govern the exchange of stream data across an asynchronous boundary while ensuring that the receiving side is not forced to buffer arbitrary amounts of data."

http://www.reactive-streams.org/

Reactive Streams aumenta le interfacce e le garanzie fornite da ReactiveX introducendo l'esplicita gestione della _back-pressure_ per impedire che un nodo possa essere soverchiato dai dati inviati dal nodo precedente o sovraccaricare quello successivo.

Parte dal concetto di Observable ma è esplicitata la quantità di dati che un nodo può elaborare.


Inoltre viene inclusa nella considerazione dello standard anche la casistica in cui i diversi componenti di uno Stream non solo si trovino nello stesso nodo e siano concorrenti, ma siano anche distribuiti.  Tutte le API tengono conto sia dell'asincronia, sia dei protocolli di comunicazione (questi ultimi perché la _back-pressure_ è necessaria non solo fra thread, ma anche fra nodi di calcolo distribuito).


Anche Reactive Streams parte da una modello semantico (propone delle interfacce e delle regole che devono seguire in aggiunta a quelle imposte strutturalmente dal linguaggio); oltre a questo ha a disposizione un sistema di verifica detto Technology Compatibility Kit (TCK) per verificare il funzionamento di un'implementazione candidata.

Mentre ReactiveX è poliglotta, Reactive Streams è multi-implementazione ma concentrato su JVM e JavaScript.

Esistono molteplici implementazioni che soddisfano il TCK:

* Akka Streams
* MongoDB java Driver
* RxJava
* Vertx Reactive Streams
* Java 9 java.util.concurrent.Flow

Alcune di queste implementazioni fanno riferimento alle stesse interfacce in modo da poter interoperare fra loro.


Il modello concettuale di Reactive Streams è compatto tanto quanto quello di ReactiveX:

* Publisher
* Subscriber
* Subscription
* Processor

Un `Publisher` fornisce un numero potenzialmente infinito di elementi in sequenza, _rispettando le richieste dei suoi `Subscriber`_ (che, oltre a osservare gli elementi che il Publisher emette, lo informano della quantità di dati che possono osservare).

```java
public interface Publisher< T > {
  public void subscribe(Subscriber< ? super T > s);
}
```


Un `Subscriber` consuma gli elementi forniti da un `Publisher` ed è in grado di controllare il flusso degli elementi in arrivo (ovvero di informare il Publisher attraverso una `Subscription`, vedi dopo).

```java
public interface Subscriber< T > {
  public void onSubscribe(Subscription s);
  public void onNext(T t);
  public void onError(Throwable t);
  public void onComplete();
}
```


Una `Subscription` rappresenta il legame fra un `Subscriber` ed un `Publisher` e permette di controllarlo o interromperlo.

```java
public interface Subscription {
  public void request(long n);
  public void cancel();
}
```


Un `Processor` è sia un `Subscriber` che un `Publisher`, quindi deve sottostare ad entrambi i contratti. Rappresenta uno snodo di elaborazione intermedio in grado di alterare il flusso di elementi aggregando più `Publisher` o controllando più `Subscriber`.

```java
public interface Processor< T, R > 
  extends Subscriber< T >, Publisher< R > {
}
```


L'API dei Reactive Streams è stata inclusa nella libreria standard (a partire da Java 9), usando come base la classe `java.util.concurrent.Flow`, con lo scopo di promuoverne la standardizzazione ed è possibile adattare la struttura delle interfacce tra questa ed altre implementazioni perché sottostanno alle stesse regole semantiche imposte dal TCK.

---

## Operatori


Vediamo alcuni esempi di operatori per avere un'idea di come si può lavorare con un Reactive Stream.

Faremo riferimento alla documentazione delle Reactive Extensions perché gli operatori di base sono i medesimi; a seconda della classe usata (`Observable` oppure `Publisher`) si comportano in modo appropriato.


### Map

Trasforma gli elementi di uno stream, ottenendo uno stream di elementi trasformati. Quindi per ogni elemento dello stream iniziale viene inserito un elemento trasformato nello stream risultante.

![Map](imgs/l21/map.png)<!-- .element: style="width: 50%" -->


### FlatMap

Trasforma gli elementi di uno stream, concatenando i risultati in un solo stream. Dunque a differenza della Map per ogni elemento nello stream iniziale può immettere più di un elemento nello stream risultante. Attenzione: la concatenazione non avviene sempre in ordine.

![FlatMap](imgs/l21/flatmap.png)<!-- .element: style="width: 50%" -->


### Filter

Emette uno stream contenente solo gli elementi che soddisfano un predicato. Per alcuni elementi dello stream iniziale non immette elementi nello stream risultante.

![Filter](imgs/l21/filter.png)<!-- .element: style="width: 50%" -->


### Skip

Emette uno stream saltando i primi N elementi della sorgente.

![Skip](imgs/l21/skip.png)<!-- .element: style="width: 50%" -->


### Zip

Emette uno stream _combinando_ a coppie elementi di due stream in ingresso. Si noti che questo operatore deve gestire la back pression qualora uno stream sia più veloce dell'altro.

![Zip](imgs/l21/zip.png)<!-- .element: style="width: 50%" -->


### Debounce

Emette un elemento solo se è passato un lasso di tempo sufficiente dall'ultimo elemento della sorgente. (Es. il pallino giallo on viene inserito perché troppo vicino temporalmente )

![Debounce](imgs/l21/debounce.png)<!-- .element: style="width: 50%" -->


### Window

Emette uno stream di partizioni dello stream sorgente. I criteri di partizionamento possono essere i più vari: tempo, intervalli fra gli elementi, segnali esterni, conteggio, ecc.

![Debounce](imgs/l21/window.png)<!-- .element: style="width: 50%" -->



---

## Parallelismo

Reactive Stream ed Extension hanno l'obiettivo di gestire più elementi concorrenti, viene spontaneo chiedersi come gestire come più elementi non in verticale (lunghezza della pipeline) ma in orizzontale, per avere distribuire la trasformazione su più thread 
L'asincronia nell'esecuzione dei vari operatori è definita dallo Schedulatore usato per osservare un `Observable` o definire un operatore di uno stream.


Ciascuna implementazione fornisce degli schedulatori in relazione alla piattaforma in cui opera. `RxJava` permette di ottenerli a partire da metodi statici dell'oggetto `Schedulers`


|Metodo|Schedulatore|
|-|-|
|.io()| Per stream legati alle operazioni di IO (con un blocking factor di un certo tipo) |
|.single()| Usa un singolo thread|
|.computation()| Per operatori legati al calcolo |
|.from(ex)| Usa l'`Executor` fornito (permette scegliere una politica di esecuzione) |


In `RxJava`, l'operatore `parallel()` permette di indicare che uno stream, da un certo punto in poi, va costruito come parallelo e dunque gli operatori distribuiti vanno intesi come paralleli.


In questa modalità solo alcuni operatori sono consentiti ed è necessario specificare lo schedulatore da usare con il metodo `.runOn(scheduler)`.

Una funzionalità molto interessante è il metodo `sequential()`, il quale indica che da quel punto in poi la pipeline di elaborazione va nuovamente intesa come sequenziale. 

Si ricorda che con gli `Stream` nella libreria standard è l'ultimo operatore a decidere se l'esecuzione è parallela o sequenziale.

A differenza degli `Stream`, è possibile indicare una precisa sezione della pipeline che viene configurata parallelamente.


`it.unipd.app2020.rx.Parallel`
```java
System.out.println("Defining...");
Flowable.range(0, 1000000).parallel(4)
  .runOn(Schedulers.computation()).map(new RxDivisors())
  .filter(new RxPerfectPredicate())
  .sequential().subscribe((c) -> {
      System.out.println(c);
    }, (t) -> {
      t.printStackTrace();
    }, () -> {
      System.out.println("Done");
      done[0] = true;
    });
System.out.println("Defined");
while (!done[0]) Thread.sleep(1000);
```

Stesso esempio della lezione 19. Con la chiamata `parallel(4)` si sceglie l'esecuzione parallela, con `runOn(Schedulers.computation())` si sceglie lo schedulatore, `map(new RxDivisors()).filter(new RxPerfectPredicate())` rappresentano la pipeline della lezione 19. Dopodiché si ritorna alla modalità sequenziale `sequential()`per osservare sequenzialemente lo stream risultante al quale ci iscriviamo con `subscribe((c)`. Attendiamo con `while (!done[0]) Thread.sleep(1000);` poiché l'esecuzione si interrompe quando si esce dallo `main`

