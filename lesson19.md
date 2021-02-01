# 19: Esempi svolti 4

---

## Reti complesse


Per concludere la panoramica sui metodi "tradizionali" di costruzione di programmi distribuiti, vediamo un ulteriore esempio che coinvolge nodi con caratteristiche diverse che interagiscono fra loro con un paradigma diverso dalla semplice richiesta/risposta.

---

## Contact-Tracing


Uno degli strumenti fondamentali per contrastare la diffusione della pandemia da COVID-19 è l'individuazione precoce dei contatti avuti dalle persone contagiose, in modo da prevenire ulteriori contagi.

Sfruttando l'ubiquità dei dispositivi mobili con capacità bluetooth, si è pensato di sfruttare tale tecnologia per questo scopo.


"Decentralized Privacy-Preserving Proximity Tracing" propone un protocollo, basato sulla tecnologia Bluetooth, in grado di soddisfare i requisiti di tracciamento preservando nel contempo le esigenze di privacy. <!-- .element: style="float: right; width: 60%" -->

![DP-3T](imgs/l19/DP-3T_Logo.jpg) <!-- .element: style="float: left; width: 35%" -->

Note: è un lavoro prevalentemente europeo, dopo che il primo tentativo si era rivelato troppo centralizzato e con caratteristiche di sorveglianza.


Il metodo si basa sull'emissione di messaggi crittografati in modo da rimanere anonimi, ma che possono essere identificati quando una parte pubblica della chiave viene rivelata.

Note: i messaggi non sono geolocalizzati; non è necessario per la loro efficacia.


In questo modo ciascun dispositivo può controllare se una chiave pubblicata ha emesso qualcuno dei messaggi che ha ricevuto, ma non può sapere a chi appartiene né ottenere altre informazioni.

Note: né tantomeno raccogliere informazioni sufficienti a falsificare i messaggi.


La privacy è inoltre garantita dal fatto che non esiste un deposito centrale dei messaggi, ma solo un'autorità che pubblica le chiavi appartenenti a chi è risultato positivo, fornite personalmente da quest'ultimo.


Questo funzionamento decentralizzato e anonimizzato fa si che anche gli attacchi più teorici richiedono risorse considerevoli per essere messi in pratica.

Note: Alcuni attacchi per esempio richiedono che l'agente malevolo distribuisca territorialmente "flotte di dispositivi bluetooth sotto il suo controllo".


È interessante vedere come si può implementare un sistema vagamente simile nel funzionamento per osservare in pratica i comportamenti di un insieme di agenti indipendenti e per sfruttare alcune caratteristiche dei protocolli di rete.

Note: al posto della prossimità fornita dal protocollo Bluetooth, useremo messaggi UDP in broadcast.


Un sistema come il dp-3T è strutturato vagamente in questo modo:

![System](imgs/l19/system.png)<!-- .element: style="width: 75%" -->


Il sistema è composto di uno o più nodi, che rappresentano le singole persone interessate dal tracciamento. Ogni nodo è diviso in componenti funzionali indipendenti e concorrenti.

Un server centralizzato raccoglie e distribuisce le segnalazioni.

Note: il server non riceve dati dai nodi; gestisce solo segnalazioni da propagare.


Il componente _Beacon_ emette dei messaggi broadcast indirizzati a tutti gli indirizzi della rete cui appartiene.

![Beacon](imgs/l19/beacon.png) <!-- .element: style="width: 75%" -->

Note: ovviamente l'interesse per noi è verificare il funzionamento dei Datagram inviati in broadcast. Il generatore di numeri casuali non è strettamente necessario.


Il componente _Receiver_ ascolta sulla porta indicata, e accoda ogni messaggio ricevuto.

![Receiver](imgs/l19/receiver.png) <!-- .element: style="width: 75%" -->

Note: quiz: riceve anche i messaggi inviati dal suo beacon?


Il componente _Store_ conserva i messaggi ricevuti, e permette di controllare se un messaggio segnalato è stato notato in passato.

![Store](imgs/l19/store.png) <!-- .element: style="width: 40%" -->


L'ultimo componente del nodo, il componente _Reader_, a intervalli regolari interroga il servizio centrale e legge i messaggi segnalati.

![Reader](imgs/l19/reader.png) <!-- .element: style="width: 35%" -->


Abbiamo bisogno anche di un server centrale, in grado di pubblicare una lista di messaggi segnalati.

![Server](imgs/l19/server.png)<!-- .element: style="width: 25%" -->

---

## Implementazione


### Beacon

Il componente Beacon deve, ad intervalli regolari, emettere messaggi a tutti i nodi in ascolto sulla stessa rete.


Fra le primitive che abbiamo a disposizione, l'unica con queste caratteristiche è il Datagram.

Il Beacon dovrà essere un Thread indipendente, con un ciclo che prepara, emette il messaggio e poi aspetta un tempo stabilito.

Note: aggiungeremo anche un flag controllato dall'esterno per segnalare la chiusura interrompendo il ciclo.


### Receiver

Il componente Receiver deve creare e rimanere in ascolto del DatagramSocket. Quando riceve un messaggio, lo pone sulla coda per la sua elaborazione.


Anche in questo caso servirà un Thread concorrente, che in un loop controllato da un flag di chiusura, attende l'arrivo di un messaggio e ne estrae il contenuto.

Note: Ne aprofittiamo per vedere una opzione particolare di `DatagramSocket`. Quiz: perché mettere il messaggio in coda e non memorizzarlo direttamente?


### Store

Il componente Store deve mantenere un insieme di messaggi già visti in modo che possano essere consultati per identificare un contatto.


Per non interferire con la ricezione dei messaggi, questo componente li preleva dalla coda e li aggiunge all'insieme del messaggi ricevuti.

La struttura dati utilizzata è thread-safe in modo che il test di appartenenza per il controllo se un messaggio è stato ricevuto può essere fatto da un altro thread.

Note: qualsiasi struttura dati scegliamo, possiamo aspettarci prestazioni che peggiorano all'aumentare del numero di messaggi ricevuti. Non possiamo quindi tenere questa elaborazione nel ciclo di ricezione perché diventerebbe via via più lungo il tempo in cui il socket non è presidiato.


### Reader

Il componente Reader deve collegarsi al sistema centrale, scaricare la lista dei messaggi segnalati e controllare se uno o più di essi sono stai ricevuti.


Un timer controlla il recupero periodico della lista da una url configurata all'avvio. Ottenuto l'elenco, ogni messaggio viene cercato nella struttura dati dello Store per verificare l'eventuale ricezione.

La lista è pubblicata come testo semplice, un messaggio per riga. È quindi semplice da leggere ed interpretare.


### Server

Il server centrale deve fornire la lista dei messaggi segnalati, e permettere di aggiungere nuovi messaggi a tale lista.


Per semplicità, è realizzato come un servizio web che ad una richiesta GET fornisce i messaggi segnalati come righe di un testo semplice, e con un POST accetta nuovi messaggi da considerare segnalati.

È implementato come un semplice server VertX, con una struttura dati thread-safe per permettere le operazioni di lettura e scrittura in modo asicrono.

---

## Networking


Per verificare il funzionamento della trasmissione dei messaggi in broadcast, abbiamo bisogno di strutturare la rete in modo da mettere alcuni nodi in una rete dove il messaggio broadcast può circolare, ed altri in una rete separata.


Per raggiungere questo risultato con risorse limitate, il progetto del singolo nodo è in grado di produrre una immagine Docker.

Usando le opzioni di networking di questo strumento, possiamo realizzare i nostri scopi.


![Network](imgs/l19/network.png) <!-- .element: style="width: 55%" -->


I nodi 1 e 2 si trovano sulla stessa sottorete: ciascuno di essi riceverà i messaggi broadcast dell'altro.

Il nodo 3 è in un'altra sottorete, e non riceverà i messaggi degli altri 2.

Tutti e tre raggiungono il server allo stesso indirizzo, sull'host.

Note: Il componente di networking di Docker permette di realizzare diversi scenari. Approfondirlo tuttavia non è argomento del corso.


Repository ct-node  
https://hg.sr.ht/~michelemauro/app2020-ctnode

Repository ct-server  
https://hg.sr.ht/~michelemauro/app2020-ctserver

---

## Link Utili


COVID-19: le App di tracciamento nella fase due in Italia e in Europa - Avv. Manuela Soccol

https://bit.ly/2VwdWVz
