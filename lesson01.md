# 1: Introduzione

---

### Chi sono io

Michele Mauro - Passionate Developer

@michelemauro

https://dev.to/michelemauro


### Reperibilità

michele.mauro@unipd.it

subject: [app2020]

---

## Paradigma


Dal greco _paradigma_: esempio, esemplare.

Modello di riferimento, termine di paragone.


In filosofia della scienza: "visione globale del mondo da parte degli scienziati di una certa disciplina"

### Paradigma di Programmazione

Insieme delle tecniche e dei metodi considerati adeguati ad affrontare una classe determinata, anche se ampia, di problemi.


### Esempio: Modello di Von Neumann

Architettura composta da CPU, Memoria centrale, organi di I/O

Singola linea di esecuzione, sincrona, su risorse completamente sotto controllo.

---

## Altri paradigmi


### Concorrenza

Più linee di esecuzione contemporanee, asincrone, che condividono l'uso di un insieme di risorse in modo (possibilmente) coordinato.


### Parallelismo

Più linee di esecuzione contemporanee, asincrone, che eseguono in modo coordinato lo stesso calcolo su di una partizione dei dati di ingresso.

Può essere considerato un sottoinsieme del caso concorrente; usa una parte degli stessi metodi.


### In rete

Collaborazione con altri sistemi attraverso la comunicazione asincrona su di una interfaccia di rete.

Le altre linee di esecuzione non condividono più le stesse risorse (indipendentemente dal fatto che siano o meno sullo stesso nodo di esecuzione) e l'unico strumento è la comunicazione attraverso la rete. L'asincronicità è una necessità. In un certo senso è un'estensione della concorrenza.


### Distribuzione

Un sistema è costituito da nodi indipendenti che, attraverso una rete non affidabile, devono coordinare l'esecuzione dello stesso lavoro, condividendo il consenso sullo stato complessivo del sistema.

Di questo paradigma vedremo solo alcuni risultati teorici: affrontarlo dal punto di vista pratico richiederebbe un intero corso partendo da una base di nozioni maggiore di quella richiesta qui. Ancora, è un'estensione della concorrenza e della comunicazione in rete.


### Reattività

Un sistema distribuito costruito sulle basi della comunicazione asincrona tramite messaggi da cui ottiene caratteristiche di flessibilità, resilienza, scalabilità, reattività.

Definito dal [Reactive Manifesto](https://www.reactivemanifesto.org/).

Con "reattività" si intende una bassa latenza alla risposta; vale a dire, il sistema risponde sempre molto velocemente, anche in condizioni di utilizzo elevato delle risorse disponibili. Nasce dalla necessità di identificare, e rendere facili da realizzare, le condizioni in cui un sistema distribuito lavora in modo corretto ed efficiente.

---

## Linguaggio


Per studiare questi paradigmi di programmazione useremo il linguaggio Java.


### Java

Java è un linguaggio **Object-Oriented**, a **memoria gestita**, con **controllo statico dei tipi**, basato su **Classi ad ereditarietà singola**, con una sintassi simile a C e C++. 



Viene compilato in un linguaggio intermedio, detto _bytecode_, interpretato da una piattaforma, la Java Virtual Machine a sua volta implementata per più sistemi operativi.


L'obiettivo della piattaforma è WORA: **W**rite **O**nce **R**un **A**nywhere.

La portabilità della piattaforma garantisce la portabilità del codice.


### Java Design goals

* Simple, Object Oriented, and Familiar
* Robust and Secure
* Architecture Neutral and Portable
* High Performance
* Interpreted, Threaded, Dynamic

https://www.oracle.com/java/technologies/introduction-to-Java.html


Java ben si presta come supporto per lavorare nei paradigmi di nostro interesse perché:

* la programmazione concorrente e parallela è uno dei suoi scopi di design
* l'impiego in sistemi distribuiti è stato un caso d'uso fin dall'inizio
* nella sua evoluzione la JVM è diventata una piattaforma di ricerca molto apprezzata

Sulla JVM è quindi molto facile trovare implementazioni a supporto delle tecnologie e dei paradigmi di programmazione più avanzati.

---

## La piattaforma


La prima peculiarità di Java è in realtà la sua piattaforma di esecuzione, la JVM.

Ad oggi è una specifica aperta e standardizzata, disponibile per tutti i sistemi operativi.

La specifica di Java 15 è: https://jcp.org/en/jsr/detail?id=390


Nella seconda metà della decade 2000 la JVM diventa uno degli ambienti in cui è più semplice sperimentare e fare ricerca sui linguaggi di programmazione.

Alcune di queste ricerche diventano poi feature della piattaforma (per es. l'istruzione _invokedynamic_) o del linguaggio Java (Generics, Lambda).


Molti altri linguaggi di successo oltre a Java hanno come ambiente di esecuzione la JVM.

Alcuni dei più rilevanti sono:Scala, Groovy, Clojure,JRuby, Jython


Inizialmente la JVM interpretava il _bytecode_ direttamente, con forti penalità di performance.

Nei primi anni 2000 entra in produzione la tecnica detta Compilazione Just-In-Time (_JIT_) che progressivamente porta Java ad avere prestazioni oggi comparabili con linguaggi di più basso livello.

Note: cfr: http://www.techempower.com/benchmarks/


Oggi la JVM implementa alcune delle tecniche più avanzate di compilazione e gestione del codice:

* Gestione del mix fra codice nativo e interpretato a seconda della statistica di esecuzione
* Compilazione in anticipo in eseguibile nativo
* Implementazioni specifiche per applicazioni particolari
* Esecuzione su silicio (in passato) e su GPU/FPGA e architetture eterogenee

Note: Per es. Azul Zulu, orientata alla concorrenza massiva ed alla bassa latenza. Esecuzione su GPU/FPGA: https://github.com/beehive-lab/TornadoVM, https://www.infoq.com/articles/tornadovm-java-gpu-fpga/ bridge fra Java e le API OpenCL


Fino al 2017, fra una versione e l'altra di Java (e della JVM) passavano diversi anni.

Da Java 9, uscito il 21/9/2017, viene pubblicata una major release ogni 6 mesi.  
L'ultima è Java 15, uscito il 15/9/2020.

Java 11 è l'ultima LTS; la prossima sarà Java 17, che uscirà a Settembre 2021.

Note: la cadenza più veloce permette di sperimentare feature ed introdurle gradatamente nel linguaggio. Java 1.0 23/1/1996.

---

## Installazione


## JDK

Principali distribuzioni

https://jdk.java.net/15/
https://adoptopenjdk.net/
https://www.azul.com/downloads/zulu-community/
https://aws.amazon.com/corretto/


Metodi di installazione

Windows: (`chocolatey`)

```bash
choco install adoptopenjdk15
```

MacOs: (`homebrew`)

```bash
$ brew tap AdoptOpenJDK/openjdk
$ brew cask install adoptopenjdk
```

Note: https://chocolatey.org/packages/AdoptOpenJDK15 https://github.com/AdoptOpenJDK/homebrew-openjdk


Ubuntu/Debian (`apt-get`):

```bash
sudo apt-get install openjdk-15-jdk
```

Alpine (`apk`):

```bash
apk add openjdk14
```

Note: al momento della scrittura non è ancora stato pubblicato il pacchetto di Java 15.

---

## Esecuzione


La JVM è predisposta per il linking dinamico del codice: i nomi di classi e metodi vengono controllati al momento del caricamento

Note: contrariamente a C e in generale ai linguaggi che compilano in eseguibili nativi.


Il compilatore Java produce un file con estensione `.class` per ogni classe ottenuta dal codice.

Secondo la convenzione seguita dalla JVM, le classi sono organizzate in package che corrispondono a directory nel filesystem.

Note: con "per ogni classe" si intende un concetto molto molto ampio, che sarà chiaro in seguito.


Il codice può essere caricato in modo generico da molte fonti; in pratica, per questioni di sicurezza si usa solo il filesystem locale.

Un parametro molto importante per la JVM è il `CLASSPATH`, ovvero l'elenco dei posti dove cercare una classe.

Note: Ma anche questo può voler dire molte cose: per esempio, sistemi operativi diversi hanno idee diverse sul comportamento del filesystem.


Il caricamento del codice è demandato ad una gerarchia di `ClassLoader`. Questo consente:

* dividere chiaramente il caricamento delle classi di libreria da quelle delle classi "di estensione" (globali per una installazione) e da quello delle classi dell'applicazione
* separare la visibilità di classi particolari in modo che solo codice di un certo tipo o di una certa provenienza possa raggiungerlo.
* caricare il codice da origini differenti, per es. da una URL, da un archivio, da una classe sul filesystem.


Il fatto che una classe venga caricata solo quando viene richiesta ha profonde implicazioni e conseguenze.

* rende possibili alcune tecnologie che sono diventate peculiari dell'ecosistema Java
* può essere (è stato) un problema di sicurezza profondamente dibattuto
* può provocare comportamenti inaspettati nel codice (se lo si dimentica)


### Compilatore

Il compilatore Java è il comando `javac`, ed è scritto anch'esso in Java.

Il suo compito è trasformare un file sorgente (`.java`) in un file bytecode (`.class`).


I file sorgenti _devono_ essere organizzati in questo modo:

* Ogni file deve chiamarsi come l'oggetto che contiene: `NomeClasse.java`
* Il percorso delle directory deve corrispondere al package in cui l'oggetto si trova
* Nei sorgenti, o nel CLASSPATH devono esserci tutti i tipi nominati dai sorgenti


L'ordine di compilazione non è importante: il compilatore deduce ed organizza le dipendenze fra le classi.

Come in altre piattaforme, comunque, difficilmente il compilatore viene usato direttamente. Di solito viene pilotato da uno strumento di livello più elevato.


### Esecutore

Il comando `java` avvia la JVM ed esegue il bytecode contenuto nel CLASSPATH.

Il bytecode può trovarsi in file `.class` o in altre forme.


Il codice della classe principale viene caricato e la JVM inizia ad eseguire a partire dal punto di ingresso.

La JVM può essere ispezionata durante l'esecuzione per fornire statistiche, informazioni diagnostiche, o interfacce di gestione.

Note: vedremo in seguito che questo "punto di ingresso" ha una forma molto familiare.


### Archiviazione

Il comando `jar` gestisce archivi di codice java che possono essere utilizzati all'interno del CLASSPATH.

Il formato `.jar` è il più comune formato di distribuzione del codice nella piattaforma Java.


Si tratta di un archivio compresso zip contenente alcuni file specifici che descrivono il suo contenuto e come usarlo.

Alcune varianti sono legate a specifiche tecnologie:

* `war` - Web Archive (applicazione web con codice e risorse statiche)
* `ear` - Enterprise Archive (codice organizzato secondo lo standard JakartaEE)

Note: questi formati sono fatti per essere eseguiti all'interno di Application Servers: contengono i metadati che permettono ad un AS standard di configurare ed esporre i servizi che il codice implementa secondo le prescrizioni della specifica


Un file `jar` può essere firmato digitalmente per garantirne l'integrità e l'autenticità.

Una parte importante del successo della piattaforma JVM è la facilità con cui una libreria può essere individuata, reperita e procurata come file `jar` a partire da un repository pubblico o privato.


### Altri comandi

* `javadoc`: Java Documentation Compiler
* `javap`: Java disassembler
* `jdb`: Java debugger
* `jps`: Java Processes
* `jstat`: JVM statistics monitor
* `jaotc`: Java Ahead Of Time Compiler (Java 14)

---

## Ecosistema


Attorno alla JVM è cresciuta una intera industria ed un vero ecosistema in cui l'OpenSource è forza quasi predominante.


Lo sviluppo del linguaggio è finanziato da Oracle, che nel 2009 ha acquisito Sun Microsystem, ideatore originale di Java.

Tuttavia, il modo in cui il software OpenSource ha fornito soluzioni di alta qualità alla piattaforma è stato un fattore di successo cruciale.

Note: La Oracle è la stessa che ha rilevato le attività di TikTok negli Stati Uniti. In Java 15 è stato ufficialmente rimosso il supporto per SunOS, cioè per il sistema operativo in cui Java è stato originariamente realizzato.


Ad oggi, le principali entità che producono software OpenSource in Java sono:

* Apache Foundation
* Eclipse Foundation

Note: più astratto e generale è il problema che avete, più è probabile che vi sia una libreria o un progetto gestito da Apache o Eclipse che lo risolvono. La Eclipse Foundation ha anche di recente acquisito i diritti dello standard Java Enterprise Edition, che ora si chiama JakartaEE


Ci sono anche entità commerciali che vivono vendendo formazione e supporto per il software OpenSource che producono:

* Spring
* Red Hat (ora di IBM)

Note: Per necessità, anche Google supporta (o realizza) molte delle sue tecnologie sulla piattaforma Java.


### Costruire, meglio

Il compilatore java, come abbiamo detto, non è molto pratico da usare direttamente.

Molto presto (fine 1990) il nascere dei primi progetti di una certa dimensione fa emergere la necessità di strumenti che gestiscano la fase di costruzione e preparazione del software.


Il primo di questi strumenti è **Apache Ant**: attraverso una specifica in XML vengono dettagliati i passi necessari alla costruzione del software.

Ant rende questo processo ripetibile, facile da comunicare, semplice da estendere.

Note: Ant: 19/7/2000, dal progetto Sun Tomcat (poi Apache Tomcat). Maven 13/07/2004.


Il grosso passo avanti avviene nel 2004, con il primo rilascio di **Apache Maven**.

L'approccio di Maven è __opinionated__: lo strumento ha un'idea molto precisa di come un progetto deve essere organizzato.

Adeguarsi a tale idea porta moltissimi vantaggi; deviarne è possibile, ma complesso e nella maggior parte dei casi inutile.


Per Maven il progetto è descritto da un `POM` 
Project Object Model

Dichiarativamente, vengono elencati:

* nome e metadati del progetto
* dipendenze
* plugin e loro configurazioni


La grande maggioranza dei progetti può essere correttamente costruita semplicemente seguendo le convenzioni e configurando pochi plugin di base.

La ricca libreria di plugin forma un effetto rete per cui ogni nuova tecnologia ha come requisito, per la sua diffusione, essere correttamente integrata con Maven in modo da essere facilmente adottabile.


Il modello di gestione delle dipendenze proposto da Maven è probabilmente uno dei fattori di successo dell'ecosistema Java.

Ogni libreria o componente può essere aggiunto ad un progetto indicandolo secondo delle coordinate:

`gruppo:artefatto:versione`

Note: per es. `org.junit.jupiter:junit-jupiter-api:5.6.2`


Attraverso le coordinate, Maven è in grado di contattare un repository remoto (privato o pubblico), procurarsi il `jar` del componente, e gestire tutte le configurazioni degli strumenti della JVM per renderlo disponibile durante la programmazione.

Questo metodo di distribuzione rende semplicissimo collaborare o mettere a disposizione di altri (o del pubblico) una libreria di software.

Note: pochi altri ecosistemi avevano al tempo un sistema di distribuzione del software così semplice e potente; e l'influenza che questo modello ha avuto su ogni altro ecosistema uscito in seguito è enorme.


![Maven repository](./imgs/l01/mvnrepo.png) <!-- .element: style="float: right; width: 45%" -->

Oggi con questo sistema si possono raggiungere oltre 18 milioni di artefatti open source; la pubblicazione del software in Java è diventato sinonimo di pubblicazione in un repository Maven.

E lo stesso procedimento è ormai standard (e sottointeso come indispensabile) per qualsiasi nuovo ambiente di programmazione.


Nel 2007 viene rilasciata la prima versione di **Gradle** una alternativa a Maven che punta a migliorare alcuni suoi limiti.

In particolare:

* non più XML, ma un linguaggio di programmazione (Groovy) per definire il progetto
* non più una struttura fissa, ma task che dipendono l'uno dall'altro a formare un DAG

Note: Directed Acyclic Graph - in contrasto con la struttura lineare e fissa di Maven.


Una parte della motivazione di Gradle è, sicuramente, il fatto che XML sia passato di moda e che invece i linguaggi con un sistema di tipi dinamico vadano invece per la maggiore.

Ma anche l'esperienza che non tutti i progetti possano incastrarsi nella rigida struttura del `POM` di Maven.

Note: sono gli anni in cui Ruby On Rails sta cominciando ad essere molto popolare, tanto da essere incluso di default in OsX.


Gradle non ha soppiantato Maven: i due strumenti si spartiscono il mercato.

Maven è in molti progetti la soluzione "classica". Gradle ha come punti di forza l'essere il sistema di build ufficiale per le applicazioni Android e la capacità di innovare, per esempio, aggiungendo Kotlin come linguaggio di descrizione della build.

Note: Anche Kotlin in realtà è una mossa dettata dal mercato Android, in quanto è stato dichiarato linguaggio preferenziale per lo sviluppo mobile da parte di Google.


Il fatto che nel corso sarà adottato Gradle è, in realtà, ininfluente: la scrittura di una build non è argomento del corso.


## IDE


Un Integrated Development Environment è un programma che mette a disposizione degli strumenti specifici per rendere più efficace l'attività dello sviluppo software:

* editor specializzati per linguaggio
* integrazione con strumenti di build
* integrazione con debugger ed esecutori di test


Nell'ecosistema Java i più popolari sono:

* Eclipse
* IntelliJ Idea
* Microsoft VSCode

È consigliato sceglierne uno, ma utile provare gli altri.


---

## Link Interessanti


### I contenuti di Java 15

https://www.infoq.com/news/2020/09/java15-released/

### I 25 anni di Java

https://www.infoq.com/news/2020/05/java-at-25/

Da segnalare: Olga Makhasoeva, The Art of Asking Questions

