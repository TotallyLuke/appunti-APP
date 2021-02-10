# 4: Istruzioni

---

## Istruzioni ed espressioni


Coerentemente con la sua filosofia OOP, il codice in Java è contenuto all'interno di blocchi delimitati da parentesi graffe `{}` ed è composto da sequenze di istruzioni (_statements_) separate dal carattere `;`.

Un blocco di codice può contenerne altri.

Questa caratteristica classifica Java come un linguaggio "K&R", rispetto ai linguaggi "di Wirth" dove invece i blocchi sono delimitati da parole chiave. Blocchi annidati non sono comuni (se non dove previsti), ma sono sintatticamente possibili.


Come già avviene nei compilatori di altri linguaggi, non c'è nessuna garanzia che l'ordine di esecuzione delle istruzioni sia lo stesso del codice:<br/> il compilatore ha grande libertà nel riorganizzare, riscrivere e in generale modificare il sorgente iniziale usando un insieme di trasformazioni che conservano la semantica esterna del blocco di codice.

Il processo di compilazione è deterministico e non dipende dall'ordine di denominazione: quando il compilatore incontra un nome non ancora definito, sa sempre dove cercare la definizione: nello stesso package/directory se si tratta di una classe non pubblica, nella directory corrispondente al package se si tratta di una classe pubblica. Alla indeterminatezza dell'esecuzione, invece, si aggiunge il già citato metodo JIT, che può portare ad avere, in momenti diversi dell'esecuzione del programma, lo stesso codice eseguito come bytecode JVM interpretato, o codice nativo compilato.

---

## Dichiarazioni


Una istruzione può essere una dichiarazione di un nome e del suo tipo.

Può essere dichiarata una variabile, o una classe, che sono dette _locali_ rispetto al blocco che le contiene.


Una variabile viene dichiarata indicando tipo, nome ed eventualmente un valore con cui inizializzarla.

Usando la parola chiave `var`, si può lasciare al compilatore la determinazione del tipo della variabile. Indicando una lista vuota di parametri di tipo `<>` anche questa sarà dedotta (se possibile) dal compilatore.


```java
int i = 1;
var b = java.util.List.of(1, 2);
Foo a = new Foo("bar");
List<> l = java.util.List.of("A", "B");
int[] r = new int[] { 1, 2, 3 };
```

`b` ha tipo `List<Integer>`, dedotto dalla firma del metodo `List::of` e dai suoi parametri. `l` ha tipo `List<String>` per il medesimo motivo.


```java
class Global {

  class AnotherLocal {
    void bar() {
      class Local {}
      Local l = new Local();
    }
  }

  {
    class Local {}
    Local a = new Local();
  }
}
```

`l` ed `a` non hanno lo stesso tipo, anche se entrambe le classi `Local` sono classi interne a `Global`. Non ho mai visto nella pratica un uso di questa sintassi; non in Java, almeno; può accadere (ed essere molto comodo) in linguaggi funzionali con una sintassi molto più compatta.

---

## Espressioni


Una istruzione può consistere in una _espressione_, cioè una sintassi che produce un valore, anche se questo non viene usato.

Le espressioni seguono abbastanza da vicino le regole di precedenza, struttura e semantica della maggior parte dei linguaggi di programmazione.


### Valori letterali

Le espressioni possono contenere valori letterali per i principali tipi primitivi.


|Tipo|Esempi|
|-|-|
|Interi|12, 45L, 0Xf, 077, 0b1111_0000|
|Decimali|0.0, 3.14f, 1.6e5, -0.5d, 1.0e-9d|
|Booleani|true, false|
|Caratteri|'a', 'b', '€', '\uffff'|
|Stringhe|"abcdef", "知識", "الود"|

Il suffisso `l` indica un intero lungo, mentre `f` indica un decimale corto e `d` uno lungo, anche se è il default. Il carattere `_` viene ignorato, e può essere usato per separare tipograficamente gruppi di cifre.


Non è possibile indicare una costante di larghezza byte o short senza un operatore di cast.

```java
byte b = (byte)0xff;
short s = (short)12800;
```

La sintassi `( < tipo > )` chiede al compilatore di considerare il valore successivo come un valore del tipo richiesto. Non cercate di imbrogliare il compilatore, perché si vendica.


Le costanti di tipo `String` (e la stessa classe, del resto) hanno un trattamento speciale da parte del compilatore:

* sono oggetti `String`, senza bisogno dell'operatore `new`
* possono essere su più righe (da Java 13)
* come tutti gli oggetti `String`, sono immutabili


Una costante stringa può (ora) essere scritta su più righe (viene detto _text block_):

```java
String square = """
  SATOR
  AREPO
  TENET
  OPERA
  ROTAS""";
```

In preview da Java 13, ora sintassi definitiva in Java 15. Definiti nella JEP 355 https://openjdk.java.net/jeps/355 e 368 https://openjdk.java.net/jeps/368.


La parola chiave `null` indica il valore nullo, ovvero il riferimento che non punta a nessun oggetto.

Il valore nullo è l'unico elemento del tipo nullo, che non ha nome, non si può esprimere, e può essere convertito sempre in ogni altro oggetto.

La nullità di un riferimento ad oggetto è il "billion-dollar mistake" di Tony Hoare, che lo introdusse in ALGOL W nel 1965.


### Assegnamento

L'assegnamento `=` è un operatore,  
quindi una assegnazione è una espressione,  
e quindi una istruzione.

Il valore dell'espressione è lo stesso assegnato alla variabile. Il suo tipo dipende dal tipo della variabile assegnata.

Valgono anche le combinazioni prefissate da un operatore: `+=`, `*=`, `|=`, ecc.


```java
int x;
x = (int)4.6;

int k = 1;
int[] a = { 1 };
k += (k = 4) * (k + 2);
a[0] += (a[0] = 4) * (a[0] + 2);
```

`x` vale 4, perché il valore viene troncato per portarlo al tipo giusto; senza il cast viene segnalato errore per perdita di informazione. `k` vale 25 perché il valore da aggiungere viene messo da parte prima del calcolo del valore da assegnare. Lo stesso vale per `a`. Ovviamente espressioni di questo tipo sono sconsigliate nell'uso comune.


### Chiamata di un metodo

L'esecuzione della chiamata di un metodo, se quest'ultimo ritorna un valore, è una espressione come le altre.

Se non ritorna un valore, è una istruzione a sè stante.

```java
System.out.println("k==" + k + " and a[0]==" + a[0]);

int time = System.currentTimeMillis();

System.setProperty("KEY", "VALUE");
```

`println` non ritorna nulla, quindi è una istruzione. `setProperty` ritorna il vecchio valore della proprietà, quindi è una espressione di tipo `String`.


### Creazione di un oggetto

La creazione di un oggetto è, per alcuni versi, la chiamata di un metodo che ritorna il nuovo oggetto. È quindi una espressione.

```java
StringBuffer buf = new StringBuffer("text");

String up = new StringBuffer("more text").toString()
  .toUpperCase();
```


È possibile istanziare direttamente una interfaccia, fornendo l'implementazione al momento della creazione:

```java
Comparator< > reverse = new Comparator< String >() {

    @Override
    public int compare(String o1, String o2) {
      return -o1.compareTo(o2);
    }

  };
```

Prima dell'introduzione delle Lambda Expression, questo era un pattern molto diffuso: una interfaccia semplice e molto generica, che nell'uso più comune viene implementata al momento dell'uso, senza creare il nome di una classe. Si può usare anche una classe, ma è meno comune e spesso meno utile.


### Operatori

Java supporta tutti i più comuni operatori aritmetici e logici, che solitamente si comportano senza sorprese.

L'operatore `+` è usato anche per la concatenazione di stringhe. L'accesso agli array si opera con le parentesi quadre `[]`.


### Operatore Ternario

L'operatore  
`< cond > ? < val1 > : < val2 >`  
consente di assegnare uno di due valori, a seconda di una condizione. Solo l'espressione corrispondente al valore selezionato viene valutata.

La condizione deve essere una espressione di tipo `boolean`. I valori devono essere compatibili con la destinazione del risultato, e quindi fra loro.


### This e Super

Le parole chiave `this` e `super` hanno un significato particolare.

`this` permette di indicare l'istanza corrente durante l'esecuzione di un metodo. Può essere utile per risolvere ambiguità di denominazione o per rendere più esplicito il significato di una espressione.


```java
class Foo {
  public final int idx;
  public final String title;

  public Foo(int idx, String title) {
    this.idx = idx;
    this.title = title;
  }
}
```

Questo idioma è molto comune, e raccomandato dal punto di vista della forma: rende molto chiaro il significato degli argomenti del costruttore.


`super` indica l'oggetto padre nella gerarchia di ereditarietà. Permette (per esempio) di controllare il passaggio degli argomenti al costruttore della classe padre all'interno del costruttore della classe figlio.


```java
class A {
  public final int a;
  public A(int a) { this.a = a; }
}

class B extends A {
  public final int b;
  public B(int a, int b) {
    super(a);
    this.b = b;
  }
}
```

In particolare, in un costruttore figlio è obbligatorio che la chiamata a `super()` sia la prima istruzione che viene eseguita. Il compilatore vi segnalerà quando ciò non viene rispettato.


### Lambda Expression

Una delle maggiori innovazioni di Java 8 è stata la sintassi della __lambda expression__.

Unita alla inclusione del linguaggio della pratica delle interfacce SAM e funzionali, ha reso alcuni casi d'uso molto comuni decisamente più semplici da scrivere.

SAM = Single Abstract Method, cioè una interfaccia in cui va implementato un solo metodo.


La sintassi della __lambda expression__ è la seguente:

```java
( < lista parametri > ) -> istruzione
```

Il compilatore individua il tipo che è atteso nell'espressione in cui la lambda si trova; il risultato è una istanza di un oggetto che implementa tale tipo, con il comportamento dato dall'istruzione.


```java
() -> 42 
() -> { return 42; } 
() -> { System.gc(); }

(int x) -> { return x+1; }
x -> x+1

(int x, int y) -> x+y
(x, y) -> x+y
```

I primi esempi non prendono argomenti. I primi due ritornano `int`, il terzo `void`. Il quarto e quinto esempio accettano un parametro. Gli ultimi due esempi sono equivalenti; in un caso il tipo dei parametri è indicato, nell'altro no. Se c'è un solo parametro le parentesi si possono omettere.


Attenzione: la __lambda expression__ non rende Java un linguaggio funzionale.

La __lambda expression__ non ha un tipo proprio; è solo una sintassi breve per un caso d'uso molto comune. Il compilatore sostituisce il codice necessario per ottenere lo stesso risultato.


```java
import java.util.function.Function;

Function< Integer, String > f = x -> "%d".formatted(x);

Function< > g = new Function< Integer, String > {
  String apply(Integer x) {
    return "%d".formatted(x)
  }
}
```

Le due forme sono equivalenti, anzi: il compilatore in pratica trasforma la prima nella seconda (a parte il diamond operator). Nella prima forma, i parametri generici sono necessari; nella seconda, basta scriverli una volta e usare il diamond nell'altra.


La combinazione di __lambda expression__, inferenza del tipo delle espressioni, `var` e diamond operator permettono di scrivere molti casi d'uso in modo assai più coinciso e comprensibile.

Si può arrivare ad uno stile molto vicino ad alcuni linguaggi funzionali; questa possibilità è stata colta dovunque possibile nella libreria standard e da parte di alcune librerie di cui parleremo.

---

## Condizionali


In Java i costrutti condizionali sono istruzioni, non espressioni.

Questo significa che eseguono blocchi di codice separati a seconda del valore della condizione.


### if-else

L'istruzione  
`if ( < cond > ) < statement >`  
`else < statement >;`  
ha la semplice struttura mutuata dal C.

Anche qui la condizione deve essere un'espressione booleana. Le due istruzioni non ritornano valore.


### switch-case

La selezione fra più valori è anch'essa mutuata dal C, con qualche estensione.


L'espressione di selezione può essere:
* un cosiddetto _tipo scalare_: byte, char, short, int, long
* un corrispettivo _boxed_: Byte, Character, Short, Integer, long
* una costante stringa
* un valore di una Enumerazione

La possibilità di usare una stringa è stata introdotta in Java 7.


```java
enum Days { LUN, MAR, MER, GIO, VEN, SAT, DOM }
Days day = ...;

switch (day) {
  case LUN:
    System.out.println("Inizio settimana");
    break;
  case SAT, DOM:
    System.out.println("Weekend!");
    break;
  default:
    System.out.println("Nel mezzo...");
    break;
}
```

Non si può utilizzare più di una volta lo stesso valore. Il funzionamento di break è lo stesso che in C.


```java
String day = ...;

switch (day) {
  case "Lun":
    System.out.println("Inizio settimana");
    break;
  case "Sab": case "Dom":
    System.out.println("Weekend!");
    break;
  default:
    System.out.println("Nel mezzo...");
  break;
}
```

La corrisponenza dev'essere esatta. Eventuali problemi di casing, per esempio, vanno gestiti nella costruzione dell'espressione da confrontare.


### Espressione Switch

A partire da Java 14 è parte integrante del linguaggio la sintassi di switch _come espressione_, cioè in grado di ritornare un valore. La forma esteriore è molto simile, ma ci sono alcune fondamentali differenze.

Sono disponibili due sintassi:


```java
enum Days { LUN, MAR, MER, GIO, VEN, SAT, DOM }
Days day = ...;

String weekPart= switch (day) {
  case LUN:
    System.out.println("Inizio");
    yield "Inizio settimana";
  case SAT, DOM: {
    System.out.println("Fine");
    yield "Weekend!";
  }
  default:
    yield "Nel mezzo...";
}
```


La parola chiave `yield` è stata scelta per assonanza con altri linguaggi e per distinguersi meglio dall'uso come istruzione.

`yield` può essere preceduto da alcune istruzioni, o incluso in un blocco, o isolato.

Non c'è _fall-through_. L'elenco dei casi deve essere _esaustivo_.

Il compilatore sarà felice di farvi notare tutti i dettagli riguardanti la compatibilità fra i tipi dei risultati ritornati da ciascun caso.


```java
enum Days { LUN, MAR, MER, GIO, VEN, SAT, DOM }
Days day = ...;

String weekPart= switch (day) {
  case LUN      -> "Inizio settimana";
  case SAT, DOM -> {
    System.out.println("Fine");
    yield "Weekend!";
  }
  default       -> "Nel mezzo...";
}
```

Questa sintassi può essere più compatta in taluni casi. Per il resto è equivalente alla precedente.

---

## Iterazioni


Anche le istruzioni di iterazione sono decisamente ispirate alla lezione del C, con qualche peculiare modifica.


### While

L'istruzione `while` si comporta come da aspettative: finché la condizione valutata è vera, l'istruzione seguente viene eseguita.

```java
int i = 0, sum = 0;
while ( i < 100 )
  sum += i++;
```


### Do

Analogamente, l'istruzione `do`: l'istruzione viene eseguita, e ripetuta finché la condizione valutata è vera.

```java
public static String toHexString(int i) {
    StringBuffer buf = new StringBuffer(8);
    do {
        buf.append(Character.forDigit(i & 0xF, 16));
        i >>>= 4;
    } while (i != 0);
    return buf.reverse().toString();
}
```

Cfr: https://docs.oracle.com/javase/specs/jls/se14/html/jls-14.html#jls-14.13. L'operatore `>>>` effettua lo shift includendo anche il bit del segno.


### For

Anche l'istruzione `for` mantiene la forma originaria: una espressione di inizializzazione, un test ed una di modifica, ed una istruzione da eseguire.

```java
int[] vals = new int[] { 5, 4, 3, 2, 1 };
for ( int i = 0; i < vals.length; i++ ) 
  System.out.println(vals[i]); 
```


L'istruzione `for` può anche essere usata per un ciclo su di un oggetto che implementa `Iterable` o un array:

```java
int[] vals = new int[] { 5, 4, 3, 2, 1 };
for ( int i: vals ) System.out.println(i);

for ( String s: List.of("foo", "bar", "baz") )
  System.out.println(s);
```

Questa sintassi indirizza a pensare in modo astratto l'iterazione; essendo più esplicita l'intenzione, il compilatore può trovare opportunità di ottimizzazione.


### break - continue

La parola chiave `break` permette di interrompere immediatamente il ciclo di iterazione più interno in corso, qualsiasi sia il suo tipo.

La parola chiave `continue` permette di interrompere l'esecuzione dell'iterazione corrente, per proseguire immediatamente con la successiva (se applicabile).


### Etichette

Ogni istruzione può essere preceduta da una etichetta; le istruzioni `break` e `continue` possono indirizzare una etichetta per riportare l'esecuzione alla istruzione indicata.

Se vi trovate ad usare questa sintassi, fermatevi a ripensare la vostra implementazione.

---

## Return


L'istruzione `return` conclude la chiamata al metodo attuale, ritornando il controllo al codice chiamante.


Se il metodo ritorna un valore, è obbligatorio indicare il valore da ritornare; ogni percorso di codice all'interno del metodo **deve** terminare in una istruzione `return`.

Se il metodo è `void`, **non può** essere indicato un valore, e l'istruzione è opzionale.

---

## Eccezioni


### Try-Catch

Se un metodo dichiara la possibilità di lanciare un certo tipo di eccezione, il codice chiamante è obbligato dal compilatore a dichiarare la stessa eccezione oppure a gestirla all'interno di un blocco `try-catch`.


```java
class FooException extends Exception {}

class Foo {
  void a() throws FooException, BarException { return; }
  void b() throws BarException {
    try {
      a();
    } catch (FooException e) {
      e.printStackTrace();
    } finally {
      System.out.println("Always");
    }
  }
}
```

Il compilatore controlla che l'elenco delle eccezioni sia completo. 


Il blocco di codice introdotto dall'istruzione `try` viene eseguito; se viene lanciata una eccezione, il primo blocco `catch` adatto viene eseguito; infine, il blocco `finally` viene eseguito in qualsiasi caso.

Con "adatto" si intende che dichiara un'eccezione pari a quella lanciata, da cui quest'ultima eredita.


### Try-with-resources

Un'altra forma dell'istruzione `try`, detta  
`try-with-resources` permette di dichiarare delle variabili: queste devono implementare l'interfaccia `AutoClosable`, e verranno automaticamente , e con certezza, "chiuse".

In questa forma le clausole `catch` e `finally` sono entrambe opzionali. 

Si tratta di una situazione talmente comune nella pratica che è stata aggiunta questa trasformazione sintattica per ridurre il codice da scrivere.


```java
static String readFirstLine(String path) 
    throws IOException {
  try (BufferedReader br = 
      new BufferedReader(new FileReader(path))) {
    return br.readLine();
  }
}
```

Notate come la chiusura della risorsa `br` avviene sintatticamente **dopo** che il metodo ha ritornato il controllo al chiamante. In realtà viene completata prima.


### Throw

Per lanciare eccezioni destinate ad essere catturate da una istruzione `try`, è disponibile l'istruzione `throw`. Richiede un oggetto discendente da `Exception` che viene lanciato come se fosse avvenuto un errore.



```java
class FooException extends Exception {}

class Foo {
  void a() throws FooException, BarException { 
    throw new FooException(); 
  }
  void b() throws BarException {
    try {
      a();
    } catch (FooException e) { 
      e.printStackTrace();
    } finally {
      System.out.println("Always");
    }
  }
}
```

Il metodo contenente l'istruzione `throw` deve dichiarare l'eccezione che ne risulta, se non la gestisce immediatamente ovvero se l'eccezione non discende da `RuntimeException`.

---

## Altre istruzioni


L'istruzione vuota, costituita da un solo `;`, è valida, anche se alcuni IDE la segnalano con un avviso.

Analogamente per un blocco vuoto `{}`; nel caso sia il blocco di un `catch`, l'avviso è più invadente.


La parola chiave `assert` consente di verificare delle condizioni al momento dell'esecuzione del programma. Se l'espressione da verificare ritorna `false`, viene lanciato un errore:

```java
assert !importantList.isEmpty();
```
  
Questa parola chiave può essere abilitata o disabilitata a livello globale tramite opzioni di avvio della JVM.


La parola chiave `syncronized` davanti ad un blocco o ad un metodo cambia il suo comportamento rispetto alla concorrenza. Ne parleremo diffusamente a tempo debito.

