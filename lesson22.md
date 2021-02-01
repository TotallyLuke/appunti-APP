# 22: Attori

---

## Messaggi


Il paradigma reattivo ci ha portato ad esaminare un modello di esecuzione particolare, con lo scopo di ottenere benefici per un insieme di problemi con esigenze specifiche sempre più comuni.

L'implementazione che abbiamo esaminato, `RxJava`, non è tuttavia completamente conforme al _Reactive Manifesto_ perché non è basata sullo scambio di _messaggi_.

Il modello di esecuzione che gli autori del _Manifesto_ avevano in mente è un modello molto precedente che si è rivelato estremamente utile negli ambiti in cui il paradigma reattivo si muoveva.

Quello che andiamo ad esaminare è un altro paradigma, un altro modello di esecuzione, con la caratteristica però di essere in grado di fornire un'ottima implementazione del modello _Reactive_ e di soddisfare appieno i requisiti del _Reactive Manifesto_.

---

## Origini

Il modello ad attori viene formalmente definito da Carl Hewitt nel 1973, in relazione ad esperienze provenienti da Lisp, SIMULA ed i primi sistemi orientati agli oggetti. A partire da quella prima definizione si sviluppa un proficuo filone di ricerca nella modellazione di sistemi concorrenti e distribuiti.

Oggi il termine  "Actor Model"  richiama invece il linguaggio Erlang e la sua piattaforma di runtime OTP (Open Telephon Platform), pensata inizialmente per le reti telefoniche. Oggi l'OTP è usato come ambiente di esecuzione per applicazioni massivamente distribuite (WhatsApp è stato scritto in Erlang).

Sebbene il lessico sia differente (originariamente si parlava di "processi" e non di attori) il modello risultante è praticamente identico ed è un riferimento per ogni implementazione in altri linguaggi.

Oggi il modello degli attori significa concorrenza e distribuzione su larga scala, e affidabilità di lunga durata.

---

## Caratteristiche

Un Attore è un'unità indipendente di elaborazione, dotata di uno stato privato, inaccessibile dall'esterno. L'attore comunica _unicamente_ con messaggi diretti ad altri attori di cui conosce il nome. 

Un Attore, in un determinato momento, ha un comportamento che definisce la sua reazione ad un determinato messaggio.

In alcune implementazioni radicali (come Erlang) anche l'IO è condierato un Attore, dunque non esistono primitive di IO ma un attore può effettuare IO solo inviando messaggi all'attore preposto.

Un sistema di attori presuppone un sistema di tipi (non è obbligatorio ma facilita il funzionamento).

Nel reagire ad un messaggio, un attore può:

* mutare il proprio stato interno;
* creare un _numero finito_  di nuovi attori;
* inviare un _numero finito_ di messaggi ad attori noti;
* cambiare il suo comportamento.

All'interno dell'attore non c'è concorrenza: l'esecuzione è strettamente sequenziale. Ovviamente è preferibile che la risposta sia il più veloce possibile.

Al di fuori dell'attore tutto è concorrente e distribuito: 

* un altro attore può trovarsi dovunque (sullo stesso nodo o su un altro nodo);
* ogni attore è concorrente a tutti gli altri;
* ogni messaggio è concorrente a tutti gli altri.

Il modello di invio dei messaggi è detto "Send and Pray", perché non ci sono garanzie di ricezione. Il fallimento di un attore è una eventualità assolutamente normale, che non ha alcuna conseguenza sulla stabilità del programma in sé. Questo approccio è alla base delle caratteristiche di affidabilità del modello.

Un Attore può supervisionare gli attori che ha creato, ed essere notificato del loro fallimento. La notifica è un messaggio, per il quale il supervisore può predisporre un comportamento. (può, non deve. È discrezionale.)

Le conseguenze di questo approccio sul modello di esecuzione sono profonde, il risultato è un sistema dove:

* l'avvio di nuovi processi/attori è estremamente economico;
* l'affidabilità è molto elevata;
* le performance e l'efficienza sono molto alte;
* la scalabilità è lineare o quasi, e molto stabile;
* la distribuzione e la concorrenza sono caratteristiche primarie.


L'elaborazione di grandi moli di dati asincroni, spesso modellati come eventi, è il tipo di problema in cui questo paradigma si esprime al meglio, abilitando risultati molto difficili da raggiungere in modo differente.

---
## Problematiche


Ovviamente, le caratteristiche del modello ad Attori hanno un costo.

In questo caso, è un costo di natura concettuale.

Modellare un algoritmo come l'interazione di un un insieme di attori concorrenti non è sempre naturale.

Quando lo è, il risultato è estremamente efficace; ma quando non lo è, i problemi rendono questo approccio non percorribile.


Molte delle euristiche e dei modi di pensare tipici della programmazione tradizionale sono in questo modello totalmente inutili, se non addirittura dannosi.

Il modello mentale in cui il problema va ricondotto è molto differente.


L'interazione non può fare assolutamente nessuna ipotesi né sull'ordine della ricezione dei messaggi, né sulla loro affidabilità.

Questo costringe a dover considerare attentamente il modello del risultato e le varie possibilità di fallimento. La facilità e l'economicità del fallimento mitigano solo in parte il lavoro necessario per prevederlo.

---
## Akka

Sulla JVM, la più diffusa implementazione del modello ad attori è il framework Akka 

![Akka](./imgs/l22/akka.png)


Inventato nel 2009, prende a riferimento il modello di Erlang (OTP) per implementare sulla JVM un sistema ad attori in grado di supportare applicazioni reattive e scalabili.

Le principali caratteristiche del framework sono:

* compatibile con l'ecosistema della JVM, e quindi in grado di usare tutte librerie e le tecnologie disponibili per Java;
* scritto in Scala, ma usabile anche attraverso una API Java;
* il modello di supervisione degli attori è obbligatoriamente da parte del "genitore".


Gli attori comunicano fra loro in modo pilotato dai tipi: questo permette di codificare l'interazione fra gli attori nelle caratteristiche delle classi usate per guidare l'interazione. Quindi si può immergere nella descrizione dei tipi dei messaggi le caratteristiche del protocollo di comunicazione degli attori. È dunque il compilatore stesso ad impedirci di inviare messaggi che non possono essere ricevuti.

Akka supporta una implementazione di Reactive Streams che può sfruttare la scalabilità del sistema per raggiungere prestazioni considerevoli esponendo il modello di esecuzione degli stream (sensibilmente più semplice di quello degli attori).

Riassumendi Akka permette di realizzare un sistema per l'elaborazione reattiva basato su messaggi che soddifa tutti i requisiti del Reactive Manifesto. Akka permette di usare la semantica degli stream implementata in un sistema 

* in grado di crescere linearmente;

* in grado di resistere al fallimento di uno o più nodi (con redistribuzione del carico tra i nodi rimanenti);
* in cui i messaggi che non hanno ricevuto risposta possono essere individuati.

---
## Esempio


Analizziamo un semplice esempio per capire le complessità del modello ad attori.


![Hello](./imgs/l22/hello-world.png)

In questo sistema, un attore manda un saluto, e un altro risponde. Il primo attore ripete per un numero massimo di volte. Un attore supervisore avvia il colloquio.


Definiamo per prima cosa i messaggi: saluto e risposta

```java
public static final class Greet {
  public final String whom;
  public final ActorRef< Greeted > replyTo;
  public Greet(String whom, ActorRef< Greeted > replyTo) {
    this.whom = whom;
    this.replyTo = replyTo;
  }
}
```

Questo è il messaggio di saluto.  Ha due parametri: `whom` è il nome di chi viene salutato e`replyTo` è il mittente, di tipo `ActorRef`. Una `ActorRef` è un riferimento ad un attore, che accetta quel tipo di messaggio.


```java
public static final class Greeted {
  public final String whom;
  public final ActorRef< Greet > from;
  
  public Greeted(String whom, ActorRef< Greet > from) {
    this.whom = whom;
    this.from = from;
  }
}
```

Il messaggio di risposta è diverso nel parametro di `ActorRef`.


Dobbiamo definire come si comporta l'attore che risponde al saluto al momento della creazione:

```java
public class HelloWorld extends 
  AbstractBehavior< HelloWorld.Greet > {

  public static Behavior< Greet > create() {
    return Behaviors.setup(HelloWorld::new);
  }

  private HelloWorld(ActorContext< Greet > context) {
    super(context);
  }
```

`Behavior` è la classe base dei comportamenti degli attori. Indichiamo che l'attore, alla creazione, usa il suo costruttore.


Infine, dobbiamo definire come si comporta l'attore al ricevimento di un messaggio.

```java
@Override
public Receive< Greet > createReceive() {
  return newReceiveBuilder().onMessage(Greet.class, 
    this::onGreet).build();
}

private Behavior< Greet > onGreet(Greet command) {
  getContext().getLog().info("Hello {}!", command.whom);
  command.replyTo.tell(new Greeted(command.whom, 
    getContext().getSelf()));
  return this;
}
```

Per far questo si ridefinisce`createReceive()` è un metodo che fornisce la descrizione dei comportamenti di risposta dell'attore a qualunque tipo di messaggio che riceve. Alla ricezione di un messaggio di tipo `Greet`, il comportamento è il metodo `onGreet(command)`. Il quale individua il mittente, e gli risponde con un altro messaggio. I compilatore ha le informazioni per impedirci di inviare un messaggio di tipo sbagliato.

`  command.replyTo.tell(new Greeted(command.whom, getContext().getSelf()));`  serve a rispondere e impostare il mittente (noi). Infine `onGreet` ritorna this perché il comportamento non cambia.




Ora, l'attore che invia il saluto. Il comportamento alla creazione:

```java
public class HelloWorldBot 
  extends AbstractBehavior< HelloWorld.Greeted > {

  public static Behavior< HelloWorld.Greeted > 
    create(int max) {
    return Behaviors.setup(c -> new HelloWorldBot(c, max));
  }
  private final int max;
  private int greetingCounter;

  private HelloWorldBot(ActorContext< HelloWorld.Greeted > 
    ctx, int max) {
    super(ctx); this.max = max;
  }
```

La sua creazione con `create(int max)` richiede un parametro.

Questo attore a differenza dell'altro ha uno stato privato. Lo stato è una variabile semplice: non abbiamo problemi di concorrenza.

Il costruttore `HelloWorldBot(ActorContext< HelloWorld.Greeted > ctx, int max) ` ha bisogno del contesto e del massimo di volte che verrà ripetuto l'invio.




```java
@Override
public Receive< HelloWorld.Greeted > createReceive() {
  return newReceiveBuilder().onMessage(
    HelloWorld.Greeted.class, this::onGreeted).build();
}
```
Nella funzione `createReceive()` se abbiamo raggiunto il massimo, interrompiamo le risposte terminando l'esecuzione dell'attore. Altrimenti, rispondiamo a chi ci ha inviato il saluto.



```java
private Behavior< HelloWorld.Greeted > 
  onGreeted(HelloWorld.Greeted message) {
    greetingCounter++;
    getContext().getLog().info("Greeting {} for {}", 
      greetingCounter, message.whom);
    if (greetingCounter == max) { 
      return Behaviors.stopped(); 
    } else {
      message.from.tell(
        new HelloWorld.Greet(message.whom, 
          getContext().getSelf()));
    return this;
  }
}
```
`onGreteed` si funziona in questo modo: quando il ricevente riceve la risposta al saluto incrementa il contatore senza preoccuparsi della concorrenza (qui dentro non c'è concorrenza), scrive qualcosa, se ha raggiunto il massimo si ferma, altrimenti risponde inviando a sua volta un nuovo saluto al mittente.
Il ricevente viene attivato solo dalla risposta a un messaggio e può solo inviare altri messaggi e alla fine decidere quale è il comportamento alla fine.
N.B. non ci sono cicli, ma l'iterazione è implicita nel ripetuto passaggio di messaggi.

L'attore che coreografa l'interazione deve rispondere ad un messaggio diverso:

```java
public class HelloWorldMain
  extends AbstractBehavior< HelloWorldMain.SayHello> {

  public static class SayHello {
    public final String name;
  
    public SayHello(String name) {
      this.name = name;
    }
  }
```

Il suo stato è il riferimento all'attore che risponde ai saluti, che crea al momento della sua costruzione.

```javacontinuo passagg
private final ActorRef< HelloWorld.Greet > greeter;

public static Behavior< SayHello > create() {
  return Behaviors.setup(HelloWorldMain::new);
}

private HelloWorldMain(ActorContext< SayHello > context) {
  super(context);
  greeter = context.spawn(HelloWorld.create(), "greeter");
}
```


Al ricevimento del messaggio d'avvio, crea l'attore di risposta, e invia il primo saluto per avviare la conversazione.

```java
@Override
public Receive< SayHello > createReceive() {
  return newReceiveBuilder().onMessage(SayHello.class, 
    this::onSayHello).build();
}

private Behavior< SayHello > onSayHello(SayHello command) {
  ActorRef< HelloWorld.Greeted > replyTo = getContext()
    .spawn(HelloWorldBot.create(3), command.name);
  greeter.tell(new HelloWorld.Greet(command.name, replyTo));
  return this;
}
```

Il coreografo si aspetta un messaggio `SayHello` contenente il nome da far usare agli altri due attori nella loro interazione e la risposta al messaggio è il comportamento con cui crea il secondo tipo di attore passandogli il parametro di quante volte deve inviare saluti e quale nome usare nei saluti. 

Questa struttura in cui una categoria di attori ne supervisiona un'altra è tipico del modello ad attori è tipica dell'organizzazione ad attori.
Il `main` riportato sotto costruisce il sistema di attori, e avvia il coreografo.

```java
public static void main(String[] args) {
  
  final ActorSystem< HelloWorldMain.SayHello > greeterMain =
    ActorSystem.create(HelloWorldMain.create(), "helloakka");
  greeterMain.tell(new HelloWorldMain.SayHello("Charles"));
  
  try {
    System.in.read(); 
  } catch (IOException ignored) { 
  } finally {
      greeterMain.terminate(); 
  } 
}
```