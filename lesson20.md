
# 20: Reattività
# Reactive Extensions


Sono astrazioni di livello più alto con cui gestire, in modo coordinato, le problematiche di sistemi concorrenti e distribuiti.

L'astrazione di esecuzione fornita dallo Stream si basa sull'inversione del controllo dell'iterazione: è lo Stream che avanza l'esecuzione, e che decide la sua struttura.

Problemi degli stream:

* manca un protocollo esplicito per gestire la terminazione dello stream
* gli errori sono gestiti come eccezioni

Nel 2009 il gruppo di Erik Mejer [introduce](https://channel9.msdn.com/Blogs/Charles/Erik-Meijer-Rx-in-15-Minutes) in .NET 4.0 le Reactive Extensions.

"ReactiveX is a library for composing asynchronous and event-based programs by using observable sequences."

Le Reactive Extension forniscono una semantica per la definizione di elaborazioni asincrone di sequenze di oggetti.
È molto di più di una API: è un intero modello di esecuzione.

Le basi del modello sono i seguenti concetti:

* Observable
* Scheduler
* Subscriber
* Subject 

Il modello fornisce una implementazione dell'**Observer pattern** _done right_.

Un `Observable` in Rx è un oggetto concettualmente simile ad uno stream, che emette _nel tempo_ una sequenza di valori.

È possibile trasformare, filtrare ed elaborare questi valori in modo esteriormente simile alle analoghe implementazioni su di uno stream.

È possibile _osservare_ i valori emessi da un `Observable` fornendo il comportamento da adottare in caso di:

* valore ricevuto
* eccezione lanciata da un precedente componente
* termine del flusso di dati

L'`Observable` ribalta il funzionamento dell'`Iterable` secondo il paradigma dello Stream e aggiunge inoltre la gestione esplicita di errori e del completamento dello stream.

|evento|Iterable|Observable|
|-|-|-|
|successivo|`T next()`|`onNext(T)`|
|errore|lancia `Exception`|`onError(E)`|
|completamento|`!hasNext()`|`onCompleted()`|

`it.unipd.app2020.rx.RxPerfect`
```java
System.out.println("Defining...");
Observable.range(0, 10000).map(new RxDivisors())
  .filter(new RxPerfectPredicate())
  .subscribe((c) -> {
    System.out.println(c);
  }, (t) -> {
    t.printStackTrace();
  }, () -> {
    System.out.println("Done");
  });
System.out.println("Defined");
```

Il risultato è:
* una semantica più ricca
* maggiore regolarità nella composizione
* indipendenza dal modello di esecuzione (sincrono/asincrono)

La maggior parte degli operatori sugli `Observable` accettano uno `Scheduler` come parametro. Ogni operatore può così essere reso concorrente e il tipo di concorrenza desiderato viene specificato dallo `Scheduler` passato come parametro.


`it.unipd.app2020.rx.Scheduler`
```java
System.out.println("Defining...");
Observable.range(0, 1000000).map(new RxDivisors())
  .filter(new RxPerfectPredicate())
  .subscribeOn(Schedulers.computation())
  .subscribe(
    (c) -> { System.out.println(c); }, 
    (t) -> { t.printStackTrace(); }, 
    () -> { System.out.println("Done"); done[0] = true; });
System.out.println("Defined");
while (!done[0]) Thread.sleep(1000);
System.out.println("End");
```


Un `Subscriber` rappresenta un ascoltatore di un `Observable`: fornisce il codice che reagisce agli eventi per ottenere il risultato finale dalla catena di elaborazione.


Un `Subject` può consumare uno o più `Observable` per poi comportarsi esso stesso da `Observable` e quindi introdurre modifiche sostanziali nel flusso degli eventi.


Lo schema concettuale proposto da Rx è estremamente utile per:
* costruire stream di elaborazione complessi e asincroni
* fornire un'interfaccia semplice e facilmente componibile per trattare successioni di eventi nel tempo
* scrivere algoritmi facili da portare da un linguaggio all'altro
* strutturare una elaborazione concorrente di uno stream di dati su garanzie solide
* gestire gli eventi provenienti da una UI con la stessa semplicità di dati provenienti da un file, da una sequenza di dati, o altra sorgente.

---

# Reactive Manifesto


Le Reactive Extensions avviano presto un nuovo filone di ricerca per studiare come il modello da loro proposto si adatta alle necessità emergenti delle applicazioni di elaborazione di stream di dati, che dagli anni 2010 sono ormai comuni.

Es. i Big Data possono essere elaborati a partire dallo stream in arrivo, senza attraversare un passo di elaborazione

Per dare una definizione a questo nuovo tipo di applicazioni, e stabilire un concetto che potesse catalizzare la ricerca in una direzione ben precisa, alcuni autori definiscono e pubblicano il [Reactive Manifesto](https://www.reactivemanifesto.org/).

Dopo quello dell'Agile del 2001, il "Manifesto" è diventato quasi un sottogenere letterario della scrittura tecnica e del relativo marketing.


Il _Reactive Manifesto_ definisce le caratteristiche dei sistemi _reattivi_:

* Pronti alla risposta (_Responsive_)
* Resilienti (_Resilient_)
* Elastici (_Elastic_)
* Orientati ai messaggi (_Message Driven_)


Un sistema Reattivo deve essere _Pronto alla risposta_ (Responsive) in quanto la bassa latenza di interazione è un principio cardine dell'usabilità.

Un sistema quindi deve privilegiare la possibilità fornire una risposta sempre ed in un tempo prevedibile e costante. Un errore è una risposta come le altre e allo stesso modo deve essere individuato e comunicato con le stesse tempistiche.

Un sistema Reattivo deve essere _Resiliente_ (_Resilient_), ovvero deve gestire i fallimenti continuando a rispondere con la stessa prontezza.

La resistenza agli errori si ottiene con la replicazione di componenti isolati, con la coscienza che ogni parte del sistema può fallire, e la rapida creazione di nuovi componenti in sostituzione di quelli che sono andati in errore.


Un sistema Reattivo deve essere _Elastico_ (_Elastic_), cioè in grado di consumare una quantità variabile di risorse in funzione del carico in ingresso.

Il mantenimento della latenza di risposta prevista si ottiene distribuendo il carico su un maggior numero di risorse nel modo più lineare possibile, senza colli di bottiglia o punti di conflitto, suddividendo gli input in _shard_ distribuite automaticamente. L'obiettivo è una scalabilità efficace ed economica su hardware non specializzato.


Un sistema Reattivo deve essere _Orientato ai messaggi_ (_Message Driven_) perché questa primitiva di comunicazione abilita le altre caratteristiche.

Attraverso lo scambio di messaggi i componenti possono rimanere disaccoppiati, possono essere indirizzati anche su nodi distribuiti, e il carico può essere suddiviso fra copie in esecuzione su nodi differenti. L'asincronia della comunicazione e l'assenza di blocchi permettono di consumare al meglio le risorse disponibili.

Queste caratteristiche impongono una organizzazione architetturale ben precisa: il _Manifesto_ intende dirigere lo sviluppo tecnologico in una direzione vista come quella più adatta a supportare sistemi con le caratteristiche desiderate.


L' _Orientamento ai messaggi_ è il mezzo con cui il sistema si struttura in forma _Elastica_ e _Resiliente_ per ottenere il valore della _Prontezza alla risposta_.

Sottoprodotti di questa architettura sono componenti manutenibili e facili da estendere, per inseguire il rapido cambiamento dei requisiti.

