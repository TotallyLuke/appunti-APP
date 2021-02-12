# 17: Fallacies and Frameworks

---

## 8 Fallacies of Distributed Computing


_Fallacia_: (s,f) l'essere fallace, ovvero che può trarre in inganno, insidioso.


1. The network is reliable.
2. Latency is zero.
3. Bandwidth is infinite.
4. The network is secure.
5. Topology doesn’t change.
6. There is one administrator.
7. Transport cost is zero.
8. The network is homogeneous.

Note: https://www.cse.unsw.edu.au/~cs9243/17s1/papers/fallacies.pdf


[1-4]: Bill Joy, Dave Lyon, early 1990

[1-7]: L. Peter Deutsch, 1994

[8]: James Gosling, 1997


## The Network is reliable


Non è necessario un guasto hardware: ci sono moltissimi modi in cui una rete può essere inaffidabile.


Un software distribuito deve tener conto della possibilità che le connessioni si interrompano o vengano negate, o i messaggi vadano persi.

Va bilanciato il rischio/costo di un tale evento con il costo della ridondanza e dell'affidabilità.


## Latency is zero


C'è un limite fisico alla velocità di un messaggio: la velocità della luce.

È impossibile, per es. raggiungere una latenza inferiore ai 30ms fra le due coste dell'Atlantico.


Se il messaggio trasporta delle informazioni che dipendono dal tempo per una risoluzione maggiore di qualche secondo, la latenza dev'essere calcolata come parte della comunicazione.


## Bandwidth is infinite


La banda disponibile è sempre meno un problema, ma i dati da trasferire tendono ad aumentare altrettanto (o più) velocemente.

Inoltre, in molte situazioni i protocolli di rete danno priorità all'affidabilità della comunicazione invece che all'economia di trasmissione.


Se il messaggio da trasferire è particolarmente grande, va gestito come un insieme di parti trasferite singolarmente.

Le performance di un protocollo devono considerare anche la quantità di dati "amministrativi" che trasporta.


## The network is secure


La diffusione delle reti ha portato, ovviamente, a maggiori opportunità per gli attaccanti e a maggiori possibilità di errore per i costruttori di dispositivi.


Se il contenuto del messaggio ha una qualche importanza o trasporta qualche informazione minimamente confidenziale, il protocollo deve essere reso sicuro:
- autenticato
- autorizzato
- integro
- confidenziale


## Topology doesn’t change


L'ubiquità dell'accesso ha come conseguenza che un dispositivo è spesso in movimento da un punto di accesso ad un altro.

Il risultato è che la topologia del grafo che costituisce la rete è in continua evoluzione.


È necessario che la comunicazione sia in grado di usare un metodo di indirizzamento dinamico e che non dipenda dalle caratteristiche fisiche della rete.


## There is one administrator


La diffusione e frammentazione delle reti significa anche frammentazione delle responsabilità nella gestione delle reti stesse.

Sempre più di rado si può imporre requisiti al percorso delle connessioni (porte aperte, feature del trasporto) perché sempre più organizzazioni sono coinvolte nella loro gestione.


Bisogna puntare sempre alla massima semplicità nella struttura e nei requisiti del protocollo di comunicazione.

Requisiti particolari potrebbero non poter essere soddisfatti da uno qualsiasi dei nodi della rete, impedendo il transito dei dati.


## Transport cost is zero


Anche il costo del trasporto sta continuamente calando, ma non è mai zero. Sia in termini monetari, sia anche in termini energetici: la maggior parte dei dispositivi è a batteria.

Nel caso di dispositivi IoT, il bilancio energetico diventa il costo preponderante.


Come per altre voci, efficienza e sintesi devono essere criteri importanti nella costruzione di un protocollo di comunicazione.


## The network is homogeneous


Le reti non sono più costituite da una sola tecnologia, da un solo mezzo di comunicazione; un messaggio attraversa una varietà di mezzi trasmissivi, metodi di comunicazione, e apparati differenti.


Come già detto, il protocollo di comunicazione deve evitare di richiedere caratteristiche di trasporto particolari, ma affidarsi il più possibile alle funzioni più standard.

---

## Web Framework


Abbiamo visto come costruire manualmente un server ed un client di rete.


Normalmente però non si lavora ad un livello così basso, ma si usano delle astrazioni:
- per semplificare la struttura del codice
- per sfruttare implementazioni già testate e corrette


Vediamo che forma prende uno degli esempi delle scorse lezioni implementato con una di queste astrazioni.


Vert.X è la proposta di Eclipse Foundation per la realizzazione di applicazioni web e microservizi scalabili e moderni.  

Le sue principali caratteristiche sono:

- modularità e compattezza delle dipendenze
- event-driven, fortemente asincrono
- poliglotta
- altamente scalabile
- approccio non-standard
- "unopinionated"
- semplice e pragmatico
- open source (Apache 2)
- supportato dalla fondazione Eclipse

Iniziato da Tim Fox nel 2011, acquisito poi (poco amichevolmente) da Red Hat e successivamente donato alla Eclipse Foundation. La storia della sua evoluzione è un interessante caso di gestione della IP nell'open source e di relazione con le comunità. La versione attuale, usata nell'esempio, è la 3.9.4.


Usando i moduli vertx-core e vertx-web possiamo reimplementare il server TicTacToe come applicazione web e valutare le modifiche al protocollo e al codice che ci troviamo a fare.

---

## Esempio - API


Per prima cosa dobbiamo pianificare l'API che il servizio esporrà.

Per rendere l'esempio più concreto, esporremo sia una API Web usabile da browser, sia una JSON usabile da un client automatico. In questo modo si può, per esempio, convertire uno dei client di gioco automatici già creati per giocare con questa API, cambiando il protocollo di comunicazione.


### API Design

Creare una API è un'arte: fatta di stili, di scuole, di preferenze, di gusti personali e richiede esperienza.

L'interfaccia del nostro codice è il modo in cui comunichiamo agli altri sviluppatori cosa il nostro codice fa e come va usato.

Questo vale sia per le API web come quella che stiamo per discutere, sia per le librerie o anche le singole classi. È importante avere chiaro in mente che si tratta di una comunicazione fra persone (il compilatore, una volta soddisfatto, è fuori dal gioco): quindi precisione, evidenza dell'intento e aiuto a scegliere la strada più corretta sono caratteristiche di considerare di grande valore.


### Home page

`GET /`

HTML: Pagina HTML di benvenuto

Con "HTML" intendiamo "risposta se il formato richiesto dal client è `text/html`". Solo il caso d'uso del browser è interessato a questa pagina; l'accesso via API può iniziare direttamente dalla chiamata successiva.


### Ingresso al gioco

`POST /game`

HTML: redirect al form di gioco

JSON: url dove ottenere lo stato del gioco

Con "JSON" intendiamo "risposta se il formato richiesto dal client è `application/json`". Notate come la risposta in questo caso è molto differente nei due casi: questo è dovuto alla differente modalità di interazione fra un umano davanti ad un browser ed una macchina che colloquia direttamente con l'API. Quest'ultima non ha bisogno del documento di benvenuto.


### Mossa in un gioco

`POST /game/{id}`

`move=x`

HTML: form con lo stato di gioco

JSON: stato del gioco

In questo caso il risultato è simmetrico: dopo che abbiamo fatto una mossa otteniamo lo stato risultante del gioco. Dobbiamo attendere l'esecuzione della mossa da parte dell'avversario, quindi dovremo interrogare lo stato per verificare se sia il nostro turno.


### Come chiamare l'API

```shell
$ curl -X POST -H "Accept: application/json" \
  http://localhost:8080/game
{"game":"/game/1134141953"}

$ curl -H "Accept: application/json" \
  http://localhost:8080/game/1134141953
```


### Strumenti utili

cURL - https://curl.haxx.se/

jq - https://stedolan.github.io/jq/

La prima versione di `cURL` è stata rilasciata nel 1997; ad oggi è un tool universale per effettuare da linea di comando richieste a server in una varietà di protocolli. 

jq è un tool estremamente comodo per trattare, filtrare e leggere, a linea di comando, dati in formato JSON.

---

## Esempio - Implementazione


L'astrazione che il modulo vertx-web ci mette a disposizione è un `router` che ci consente di associare ad una URL una lambda.  Questa può modificare la risposta impostando esito e contenuto.

Il modo in cui il nostro codice interagisce con il framework è definito da questa astrazione.

Altri framework strutturano questa comunicazione con altri metodi, per esempio con annotazioni (Spring Boot) o con tipi particolari (JEE) che il nostro codice deve implementare o produrre.


`it.unipd.app2020.web.NetGame`
```java
class NetGame {
  String[] playerId = new String[2];
  private Optional< Game > game =
    Optional.empty();
```

Questa classe mantiene lo stato di un singolo gioco, in partenza o già avviato. L'uso di `Optional` consente di gestire esplicitamente questa condizione.


`it.unipd.app2020.web.GameServer`
```java
class GameServer {
  // active and completed games
  ConcurrentMap< String, NetGame > games =
    new ConcurrentHashMap<>();
  // awaiting players
  BlockingQueue< NetGame > openings =
    new LinkedBlockingQueue<>(16);
```

Questa classe gestisce l'insieme dei giochi. È una generalizzazione della classe di uno degli esempi precedenti, adattata a gestire il caso (che qui è esplicito) di giocatori in attesa di un gioco in partenza.


```java
public Optional< GameIndex >
  status(String playerId) {
  var res = Optional.empty();
  if (games.containsKey(playerId) &&
    games.get(playerId).started()) {
    int idx = games.get(playerId).playerId[0]
      .equals(playerId) ? 0 : 1;
    res = Optional.of(new GameIndex(
      idx, games.get(playerId).status()));
  }
  return res;
}
```

Questo metodo ritorna la coppia formata dall'indice del giocatore nel gioco e dallo stato del gioco stesso se il giocatore c'è ed il gioco in cui partecipa è iniziato; altrimenti ritorna un'opzione vuota.


`it.unipd.app2020.web.Server`
```java
public static void main(String[] args) {

  // The Game Server
  GameServer gameServer = new GameServer();

  // The infrastructure parts
  Vertx vertx = Vertx.vertx();
  HttpServerOptions options = new HttpServerOptions()
    .setLogActivity(true);
  HttpServer server = vertx.createHttpServer(options);
  Router router = Router.router(vertx);
  // setup body handling for all routes
  router.route().handler(BodyHandler.create());
```

Il framework Vertx richiede la costruzione dell'omonimo oggetto per inizializzare tutte le sue strutture di supporto. A questo oggetto principale chiediamo la creazione di un server Http, ed iniziamo la costruzione dell'oggetto `router`, la cui responsabilità è conoscere l'associazione fra le URL riconosciute ed il codice da richiamare per calcolare la relativa risposta.


```java
// Browser entry point
router.get("/").produces("text/html").handler(ctx -> {
  ctx.response().end(JOIN_FORM);
});
```

Per la root dell'API HTML, rispondiamo con un documento fisso che permette ad un utente tramite browser di accedere al gioco.


```java
// POST /game - want to play
router.post("/game").produces("text/html").handler(ctx -> {
  GameLocation loc = new GameLocation(gameServer.create());
  ctx.response().setStatusCode(302)
    .putHeader("Location", loc.game).end();
});

router.post("/game").produces("application/json")
  .handler(ctx -> {
    GameLocation loc = new GameLocation(
      gameServer.create());
    ctx.response().putHeader("content-type", 
      "application/json").end(location.toJson(mapper));
});
```

Per l'API di richiesta di partecipazione, dobbiamo strutturare le due risposte in modo molto differente. La risposta ad un browser dovrà reindirizzarlo alla pagina di richiesta dello stato, da cui il giocatore potrà utilizzare il resto del gioco. La risposta ad un client automatico invece si limita a fornire l'url relativa dove ottenere lo stato; nella pratica, spesso non si può supporre che client automatici siano in grado di seguire le direttive HTTP più complesse come i redirect; bisogna perciò puntare alla massima semplicità.
Il fatto che la risposta contenga l'indirizzo del prossimo passo del processo può essere visto come una realizzazione del paradigma HATEOAS: Hypertext As The Engine Of Application State; il client cioè non ha bisogno di conoscere la struttura dell'API, perché in ciascuna risposta trova l'indirizzo per il prossimo passo.


```java
// POST /game/{id} move=x - play move x
router.post("/game/:playerId").produces("text/html")
  .handler(ctx -> {
    String playerId = ctx.request().getParam("playerId");
    boolean open = gameServer.open(playerId);
    if (!open)
      ctx.response().setStatusCode(404).end(GAME_NOT_FOUND);
```

Questo è uno dei metodi più complessi, la gestione della risposta ad una mossa. Analizziamo per primo il caso HTML. Otteniamo dal parametro dell'url `:playerId` l'identificativo del giocatore. Se non lo troviamo nel `GameServer`, rispondiamo HTTP 404.


```java
String result = gameServer.status(playerId)
  .map((res) -> {
    int idx = res.idx; GameResult status = res.status;
    int move = Integer
      .valueOf(ctx.request().getParam("move"));
    if (idx == status.next && status.valid && !status.end)
      status = gameServer.player(playerId, move)
        .orElse(status);
      return render(playerId, idx, status);
    }).orElse(String.format(WAIT_FOR_ANOTHER, playerId));

    ctx.response().end(result);
});
```

Nel caso in cui il gioco sia invece presente, possiamo ottenerne lo status e, se ci viene dato, trasformarlo nella pagina informativa che mostra all'utente la situazione del gioco e, se si tratta del suo turno, i controlli per effettuare la mossa seguente. Altrimenti, diciamo all'utente di aspettare il secondo giocatore formattando un template.
Notate come al contrario del caso precedente non ci sia la necessità di un if: la trasformazione di `GameIndex` in `String` avviene solo se l'`Optional` contiene un valore; se è arrivato vuoto il risultato è dato dall'argomento del metodo `orElse`. Scritto in questo modo, questo codice ha una complessità ciclomatica inferiore, mantiene una efficienza paragonabile (con le giuste attenzioni: il parametro di `orElse` viene sempre valutato), ed è più semplice da testare perché il corpo del caso positivo si può facilmente estrarre in un metodo separato ed isolato.


```java
router.post("/game/:playerId").produces("application/json")
  .handler(ctx -> {
    // ...
      return renderJson(playerId, idx, status);
    }).orElse(new GameStatus("wait for another")
      .toJson(mapper));

  ctx.response().end(result);
});
```

Il caso che risponde al client JSON è assolutamente simile al precedente. Quello che cambia è solo il modo in cui viene emesso il risultato, che deve ovviamente essere formattato opportunamente. Questo evidenzia anche quanta parte del codice è legata al framework (estrazione delle variabili, richiamo delle strutture interne) e quanta invece è legata alla logica (l'if che controlla le condizioni su `status`).


```java
router.get("/game/:playerId").produces("text/html")
  .handler(ctx -> {
    String playerId = ctx.request().getParam("playerId");
    boolean open = gameServer.open(playerId);
    if (!open)
      ctx.response().setStatusCode(404).end(GAME_NOT_FOUND);

    String result = gameServer.status(playerId).map(
      (res) -> render(playerId, res.idx, res.status))
      .orElse(String.format(WAIT_FOR_ANOTHER, playerId));
  ctx.response().end(result);
});
```

La lettura dello stato di un gioco è più semplice. Dopo il classico controllo sulla presenza del gioco, lo stato viene richiesto al `GameServer` e trasformato opportunamente. La versione per l'API JSON è identica a meno della chiamata `renderJson` e dell'argomento di `orElse`, come nel caso precedente.


```java
public static void main(String[] args) {
  // ...
  server.requestHandler(router).listen(8080);
}
```

Dopo aver programmato nell'oggetto `router` tutte le risposte che intendiamo supportare con la nostra API, possiamo finalmente consegnarlo al server e dirgli di porsi in ascolto della porta 8080. Questa chiamata è asincrona, e `main` termina lasciando il server attivo.

---

## Esempio - Osservazioni


L'approccio del framework Vert.X è tipico dei framework asincroni: ci viene fornito un ambiente all'interno del quale possiamo specificare gli handler che verranno richiamati in seguito a eventi definiti dal framework.


Le conseguenze sono:

* con un po' di disciplina, possiamo mantenere il codice che interagisce con il framework all'interno dell'handler
* gli handler compiono effetti collaterali, non sono quindi funzioni pure
* la struttura dichiarativa costringe ad esternalizzare l'organizzazione del codice
* è in carico a noi la gestione coerente dello stato condiviso

Rispetto ad altri approcci, abbiamo qualche aiuto in più a mantenere il nostro codice isolato dai tipi del framework, e quindi più riutilizzabile.
Ovviamente, essendo gli handler asincroni, non sappiamo da quale thread saranno chiamati.

---

## Perché usare un framework


Un framework fornisce un ambiente all'interno del quale un insieme di casi d'uso fondamentali è reso facile, efficiente e sicuro da implementare.


Un framework per applicazioni web, per esempio, rende facile:

* specificare le rotte a cui rispondere
* costruire le risposte


Lo stesso framework web, cercherà di rendere trasparente, ed eventualmente configurabile:

* la gestione dei dettagli del protocollo
* la sicurezza nel trattamento della comunicazione
* la suddivisione delle risorse fra le varie parti del sistema


Gli autori del framework scelgono le loro priorità fra semplicità d'uso, sicurezza ed efficienza.

Come utenti, noi otteniamo automaticamente ogni incremento su ciascuna di queste dimensioni.

---

## Perché non usare un framework


Un caso d'uso che non è fra quelli prescelti come importanti dagli autori del framework, può essere molto, molto complesso da implementare.


Un framework per applicazioni web, per esempio, può rendere difficile:

* rispondere a richieste "esotiche"
* controllare finemente l'erogazione della risposta

Con "esotiche" si può intendere, per esempio, un protocollo innovativo o una funzione poco usata ma di valore per il vostro caso d'uso; se il framework non lo prevede, può diventare difficile ottenere il controllo necessario. Allo stesso modo, se il framework ha il controllo sulla risposta, potrebbe essere difficile implementare soluzioni particolari come lo streaming di parti di risposta che vengono generate man mano.


Lo stesso framework web, potrebbe rendere oscuro, oppure inaspettatamente:

* fallire l'esecuzione di una richiesta a causa di un baco nella sua implementazione
* aprire una falla di sicurezza a causa di un default errato
* permettere il sovraccarico del sistema a causa di una mancata limitazione delle risorse

Il primo caso è, ovviamente, ineliminabile: un baco di implementazione può capitare a chiunque. Il secondo caso è simile al primo, ma gli impatti sono molto più gravi: il 2017 è stato l'annus horribilis per il framework Apache Struts per la scoperta di due bachi molto gravi, che aprivano la possibilità di una Remote Code Execution sul server. Uno di questi è stato utilizzato per il breach di Equifax, in cui sono stati rubati dati personali di 150 milioni di persone. Il terzo caso può comportare comunque danni per mancato servizio o per costi aggiuntivi.


Gli autori del framework scelgono le loro priorità fra semplicità d'uso, sicurezza ed efficienza.

Come utenti, dipendiamo completamente da loro per l'ordine con cui queste caratteristiche sono implementate, e dobbiamo sopportare i costi di aggiornamento se l'interfaccia fra il framework ed il nostro codice cambia.

Se il framework prende una direzione che non si allinea alle nostre esigenze, oppure cambia radicalmente interfacce esposte richiedendo manutenzione del nostro codice, o ancora peggio se viene abbandonato, possiamo incorrere in problemi anche gravi. La scelta del framework richiede quindi una conoscenza non solo della tecnica, ma anche del mercato e dell'ecosistema che lo circonda.

---

## Pubblicità

### Humble Bundle Java Books

https://www.humblebundle.com/books/java-programming-more-oreilly-books


### 97 things every programmer should know

https://97-things-every-x-should-know.gitbooks.io/97-things-every-programmer-should-know/en/
