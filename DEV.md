# Desy - Development notes



## TODO

1. test: convertire i test in rspec e rimuovere la piattaforma di test di Rails
1. Attivare e far funzionare turbolinks
1. Mettere tutto in autoload
1. rspec: definire `set` e `set!` per avere syntactic sugar per i metodi cacheabili. Al pari di `let`, `set` cachea dopo la prima chiamata, mentre `set!` forza l'esecuzione.
1. refattorizzare Parameters
1. Sostituire `expect(subject)` con `is_expected`
1. Passare da Rails 4.0 a 4.1


## Lista di cose da fare lasciata in eredità da Adriano



### PRIORITÀ 1

1-  controlla gender comune in purchase (cerca una comune per)!!! +++ risolvi bug gender per fill_locations.js!!!!!!!
2-  amicocloud aggiorna caption approfondimento popup documento e label grigia sempre nella stess popup
3-  decidi se cambiare la funzionalità di controllo swipe!!! forse sarebbe meglio controllare se è touch, invece del controllo se ipad, iphone, etc
5-  risolvere la doppia chiamata di Chrome al document ready! e controllare che sia OK anche in IE
6-  Spaziare i video nella galleria perché non c'è spazio, il cursore quando arriva in fondo tocca il minutaggio e a volte vi si sovrappone
7-  eventualmente fai una rescue dei numerosi errori che mi manda quando non riesce ad inviare una email, e se rescuo riprova ad inviare la mail altre volte!
9-  aggiorna tutte le selectbox come vuole walter, a uscire invece che a rientrare!! --- e fai una passata a controllare come si vedono tutti
10- controlla ottimizzazione chiamate db di profile + anche eventualmente prelogin, assicurati che se ci sono cose di troppo che siano accettabili
11- cambia traduzione benvenuto emanuela!
12- valida lo scorm nelle piattaforme
13- aggiorna helps e faqs di dashboard seguendo i nuovi testi di walter, e aggiorna amicocloud con molta cautela!!!! --- vedi due faqs (una sostituita e una aggiunta) e un help sostituito, CI SONO DUE EMAILS DI WALTER!!!
14- VIRTUAL CLASSROOM... fai lo stesso che ho fatto per gli elementi didattici... e per la dashboard: organizza lo spazio in orizzontale!!! + centra il paginatore e metti altezza fissa a contenuto + e togli la pezza del margin top -50 px!
15- ESTENDERE BROWSERS NOT SUPPORTED A SAFARI vecchio
16- escapare . e : e altri caratteri dalle tags... o forse è meglio vietarli proprio, insieme con gli altri -- si ricollega a <<<<< non funziona la colorazione se le tags contengono caratteri del tipo '/' nella autocomplete; inoltre, se le tags contengono caratteri balordi tipo ', o <>, non funziona la ricarica della url con una tag già selezionata nel motore di ricerca +++ IN DUE PUNTI: views/video_editor/previews/_text.html.erb:8 ++ views/video_editor/components/thumbs/_text.html.erb:2 c'è un html_safe a rischio, nelle componenti testo nel video editor, però in questo caso non dovrebbe danneggiare nessuno in quanto viene tramutata in immagine
17- sistemare problema audio IE 352 che si sente senza il player ma non si sente con il player



### PRIORITÀ 2

1-  notifica lampo tipo flash nel momento in cui ricevo una notifica!!!!!
2-  metti paginazione e miniature thumb in lesson viewer
3-  che succede se sforo la dimensione massima della cartella mentre genero un nuovo video o audio con l'element editor??? che reazione ha il sistema? salva o no? e se no, che messaggio manda all'utente??
4-  Fare numero di lezioni dinamiche anche per elementi a striscia!!!!!! però fai attenzione, perché nel motore di ricerca è un casino!!!
5-  migliorare altezza fissa di situazioni di vuoto in media elements e lessons etc etc etc, deve esserci altezza giusta
6-  aggiungi titolino nel footer del form create new lesson
7-  la tooltip di login si trova con uno z-index superiore all'overlay della popup di errore! correggilo! non viene bloccato dall'overlay
8-  la manina openhand??? Che fine ha fatto?
9-  metti label che include tutta la scritta per le checkboxes di registration, sia in DESY che in AMICOCLOUD
10- rendere migliore il flash di risposta alla richiesta di accreditamento? magari non con un flash ma con una pagina a parte?
11- quando mi reincarno in un altro utente, non posso visualizzare le sue lezioni private, perché?
12- come gestire word copia e incolla?
13- iconcina cerca hover ha dei pixelini di imperfezione?? perché? si riproduce anche nelle altre sezioni o solo nella dashboard?
14- metti le delete nelle routes dove serve, al posto delle post??? esempio destroy media elements e destroy lessons
15- inserisci la mappatura dei livelli scolastici negli scorm!!!! riempi l'hash che è contenuto nel file helper etc etc etc
16- arrangia un po' meglio il footer di amicocloud
17- migliorare la funzione asintotica dell'animazione della barra di loading, rendendola più realistica
18- migliorare la queue dei messaggi di alert in lesson editor uploader
19- video lenti a caricarsi in video editor / lesson editor, etc, ci metto un caricatore?
20- tagliare i secondi precisi in video e audio editor... con tutte le problematiche legate, specialmente in fase di preview di ciascuna componente
21- video e audio editor: come gestisco dimensioni troppo grandi in caso di conversione video o audio???? una specie di create fake???? BAAAAHH chiedi a maurizio forse addirittura non si gestisce neanche ++ idem per folder full, come si fa???
22- inserire in un metadata quali utenti erano stati legati all'acquisto vecchio!!!!! e fare in modo che tale informazione resti accessibile dall'esterno +++ cambiare anche il titolo del form EDIT PURCHASE, se sto rinnovandolo oppure no!



### PRIORITÀ 3

1-  SISTEMARE BUGGINO LAZIO RESTA IN B IN ADMIN SOLAMENTE!!!
2-  ottimizzare anche la procedura di check conversion in media_elements_controller????? fa una chiamata al DB per ogni valore inserito nella key!!!!!! è potenzialmente pericolosa oppure no?? --- DIREI CHE NON è PERICOLOSA a livello di uso normale NON VA OTTIMIZZATA... del resto se qualcuno sta convertendo quintali di video si può certamente aspettare che DESY rallenti minimamente... PIUTTOSTO È PERICOLOSISSIMO NON METTERE UN LIMITE AGLI ELEMENTI DIDATTICI"!!!!! DEVO CHOPPARE O QUALCOSA DEL GENERE!!! altrimenti rischio che me la sfondano
3-  finire di risolvere il problema dei fonts nunito!!!! walter e maurizio
4-  metti un hover sopra le lezioni draggabili in virtual classroom (??)
5-  perché in virtual classroom quando lascio la lezione che torna al suo posto si attacca dall'alto nella sua posizione invece che farlo normalmente?
6-  assicurarsi che non ci sia rischio di conflitto nel video e audio editor nei controller che lanciano le chiamate al server delayed_job!!! deve essere bloccato assolutamente se ce n'è un altro in funzione! per entrambi gli editors!!!
7-  controlla validazione regexp email, se (1) è la stessa in profilo e send link, (2) è corretta o esclude mails del tipo .co.uk
8-  perso il bordino bianco in alto nella prima lezione in playlist in VC, mi sono dimenticato di calcolarlo nell'altezza della playslit, COME FACCIO??
9-  problema tiny entrando nel campo testo con un tab invece che con il click: non si lancia il BLUR!!!
10- riorganizzare gli stili dei media element editors che sono una caciara incredibile, specialmente l'image editor
11- idea, rendere parametrizzabile il fatto che dopo aver copiato una lezione invece di chiederti che cosa fare ti manda direttamente nell'editor??? cosî si riduce l'incidenza degli stati copiata non modificata --- boh boh boh cmq sarebbe configurabile, e pertanto devo aggiornare entrambi i settings.yml.example in master e amico cloud
12- VideoEditor: metti minutaggio direttamente in thumbnail, invece che due passi deve essere solo uno
13- VideoEditor: modalità preview, togli bottone in basso a dx e metti tutto dentro un bottone preview, che deve funzionare anche durante la preview e non solo in pausa
14- VideoEditor: in generale, togli slider disabler durante il play, (anche fuori dall'editor) +++ metti volume ?? 
15- VideoEditor: dare la possibilità di selezionare aree sulle quali non applicare audio di sottofondo
16- ottimizzazione e indicizzazione: devo mergiare indicizzazione_controllers_da_sporcare con indicizzazione modelli, e creare un nuovo documento compatto da sporcare a sua volta, che contiene il riassunto di tutte le ripetizioni delle queryes!!! quest'ultimo documento va a sua volta inserito nel red2!!!! poi, quando passerò a studiare gli indici, non basarti solamente sul documento, scrivi proprio le queries, non solamente le queries active record in codice, ma proprio lo SQL!!!! dunque verranno fuori automaticamente le queries modificate con le nuove select introdotte per ottimizzare il codice
17- pagina "i nostri server sono in manutenzione"
18- metti link a lesson viewer da lesson editor?
19- ridurre di poco forse la altezza di popup video in galleria??? controllala in tutte le sezioni in cui viene usata, potrebbe darsi che si è alzata per errore, c'è troppo spazio
20- troppe lezioni potenzialmente da caricare nella dashboard? Possibilità di sovraccaricamento, troppo lenta?? Pensaci, e pensaci anche per gli elementi didattici
21- spostare la struttura html delle notifiche dal file di traduzioni all'interno di un template acconcio, per ottimizzarne l'utilizzo anche dal nuovo metodo che manda notifiche già strutturate
22- Ottimizzare anche il metodo center this etc e metterlo in mezzo ogni volta che c'è un resize non ufficiale.
23- In mailing list, quando creo una nuova mail, dovrebbe svuotare quella che c'è dentro e ripristinare la funzionalità di placeholder
24- Controlla ottimizzazione in tutte le azioni di lesson_export_controller
25- metti form_error anche in upgrade trial purchase code interno??? dovrebbe avercelo allineato con tutti gli altri dello stesso tipo (profilo)



### PRIORITÀ 4

1-  Organizzazione delle cartelle di elementi (cartella accesa se il suo contenuto è caricato in lesson editor + crea nuova cartella, elimina cartella, filtra per cartella)
2-  mettere filtro non mostrare privati elementi in admin
3-  captcha in tutte le aree non loggate o pubbliche
4-  METTI INDICIZZAZIONE PER GOOGLE + google analytics
5-  doccare seeds.rb che NON È ANCORA DOCUMENTATO!!!
6-  congelare il codice di acquisto per alcuni minuti mentre l'utente compila il campo di registrazione
7-  fai uno script automatico per scaricare i comuni dal sito dell'istat, che ha sempre lo stesso formato
8-  validare w3c quando c'è tempo, lesson editor + lesson viewer metti alt img e src con # quando devo caricare immagine in lesson viewer + togli tag <layer> in lesson editor e sostituiscila con molta attenzione e controllo con un div con classe layer ++ in video editor e audio editor anche!!!
9-  il tuo account scadrà tra 1 giorni, metti il plurale in trial disclaimer
10- caricamento icone in altri browsers, potrebbe essere lento +++ idem per i video, esempio del lumacone
11- metti in altri punti la bustina per spedire link
12- stilare situazione di vuoto in load lessons in virtual classroom
13- accorpa alignment, caption e inscribed di media_elements_slide in un metadata apposito
14- bug con il draggable in lesson editor alignment image se mi sposto troppo lontano dallo spazio apposito per l'immagine, l'img resta attaccata anche se droppo, e devo cliccare per scollarmela dal mouse -- è solo in image1, con image orizzontale, se droppo sull'area testo tinymce
15- usare distance opzione in draggable sort slides
16- implementare il caricamento multiplo???
17- aggiungi due autori se la lezione è stata copiata, solo nella copertina (e solo il primo e l'ultimo autore)
18- ottimizzare le tags in admin, che per il fatto di essere chiamate in ordine (per sicurezza) al momento hanno perso l'ottimizzazione che avevo dato loro
19- dubbio esistenziale: MA NON C'È IL RISCHO CHE CON LOCATIONS SINGOLE SENZA ANNIDAMENTI TUTTO SI ROMPA??? forse vale la pena di provare almeno una volta che cosa succede? +++ rifare una passata per controllare tutti i locations in admin, che funzionino correttamente anche nel caso in cui non ci sono locations figlie, etc, etc, etc
20- che succede se mi perdo il link di conferma??? devo rifare tutto d'accapo?? idem per altri tre tokens, pensaci
21- Importazione PPT: (a) ispeziona template e vedi come è stato fatto, (b) OK, è necessario usare esattamente il template prodotto dal programma conaito; mantengo le frecce a dx e sx con la stessa funzionalità, (c) unico problema può essere nella playlist, quando LASCIO volontariamente una lezione tarocca a metà per iniziarne un'altra; come posso farlo senza mettermi a rompere tutto il javascript?
22- Importazione PPT: (d) risolvere il problema delle scritte senza spazio tra le parole, bug di conaito; (e) risolvere anche il problema dello swipe accidentale, sempre conaito... ma probabilmente posso disattivarlo senza problemi incapsulando il suo javascript, (f) devo supporre delle funzioni da usare nel template: <%= lesson_ppt.content %> o cose di questo tipo
23- Importazione PPT: (g) lezione inseribile in playlist, unico vincolo non copiabile; il link matitina apre una finestra scarica carica (h) caricabile solo da admin; thumb, un'immagine automatica eventualmente personalizzabile dall'admin; NON È PSSIBILE COPIARLO (i) preparare ambiente conversione mentre si aspetta che l'aplicazione finisca... scegli placeholders... (j) prossima cosa da fare: trovare una maniera di simulare il funzionamento JS del convertitore in HTML5 -- semplicemente, ficca dentro desy attuale delle slides colorate di colori diversi ma vuote, e prova a lanciare il javascript per passare da una all'altra
24- esplicitare la chiamata al layout lesson viewer dal controller, che è fatta in modo implicito leggendo il nome del controller, e quindi attualmente è rischioso



### PRIORITÀ 5

1-  Quando qualcuno vede delle lezioni interessanti nelle statistiche, come le aggiunge???? O vede???
2-  Inserire buffering nei players?
3-  Sistemare ordine location composite in admin, adesso fa per codici ancestry, devo mettere un indice e ordinare per nomi concatenati (sto parlando di utenti)
4-  Maggiori suggerimenti su come inserire tags lunghezza massima titolo etc in admin update / publish elements?
5-  Manda email a utenti bannati
6-  Paginazione upload e publish elements da admin (2 sezioni, non è pericoloso perché dipende dall'admin)
7-  Migliorare la sistemazione degli ultimi reports nella dashboard admin! Ci deve essere scritto da qualche parte che sono solo gli ultimi, e ci deve essere un link alla sezione principale
8-  Inserire il massimo nella traduzione di file troppo grande (come variabile magari??)
9-  Admin: allineare in modo più gradevole gli strumenti di ricerca delle tags in settings ++ stilare meglio le due links per reportare un oggetto oppure no!!! +++ capire a che serviva anchor ++++ admin documenti: aggiungi ordini per formato e dimensione, previa leggera migrazione del database (al momento queste informazioni si trovano nel metadata) ++ aggiungi anche ricerca per formato!! + ordina graficamente tutta la pagina, ed eventualmente controllane il funzionamento della ricerca +++ anche conseguenza grafico a torta per i documenti admin spazio occupato + anche locations e purchase, rendili più gradevoli
10- Sort istantaneo nella playlist quando ci trascino dentro una lezione: questa opzione contiene delle decisioni grafiche difficili (come visualizzare la lezione?)
11- full text search per la ricerca di documenti va rimandata a DOPO, ma non dimenticata!
12- migliorie del send notifications massivo in admin: (1) migliora la grafica, (2) migliora le traduzioni, (3) migliora il funzionamento del controller che è caotico, (4) fai funzionare anche una preview così si controlla la notifica che si sta per mandare
13- uploader, per il futuro: metti un disclaimer nella popup di upload che ti dice che se vuoi continuare a lavorare ti conviene aprire una nuova scheda. Se la apro, mi segno qualcosa nella prima finestra che fa sì che si chiuda quando l'azione risponde. Inoltre, nella nuova finestra attivo un sensore del tipo check_conversion