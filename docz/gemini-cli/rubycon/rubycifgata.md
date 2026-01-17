## Riccardo 1: Figate di ruby

* Riccardo:  Devo scrivere le pecliarita di ruby a uno che nn conosce ruby. per favore aiutami a scrivere in codice ```ruby blah blah ``` alcune bozze che spieghino le sue peculiarita, magari (se ha senso) in opposizione al codice SENZa quella peculiarita (tipo: return 42 vs 42).

---

Ruby è spesso descritto come il "migliore amico del programmatore" perché è ottimizzato per la felicità di chi scrive, cercando di avvicinarsi il più possibile al linguaggio naturale.

Ecco alcune bozze di codice per spiegare le sue peculiarità a chi non lo conosce.

---

### 1. Implicit Return (L'ultima espressione vince)

In Ruby, non è necessario scrivere esplicitamente `return`. L'ultima riga valutata in un metodo viene restituita automaticamente. Questo rende il codice più pulito.

```ruby
# Senza implicit return (stile Java/C#)
def addizione(a, b)
  return a + b
end

# In Ruby (Idiomatico)
def addizione(a, b)
  a + b
end

```

---

### 2. Metodi con `?` e `!` (Predicati e Metodi Pericolosi)

Ruby permette di usare simboli alla fine dei nomi dei metodi. Questo rende il codice estremamente leggibile (sembrano domande o avvertimenti).

* **`?`**: Restituisce un valore booleano (vero/falso).
* **`!`**: Indica che il metodo è "pericoloso" o che modifica l'oggetto originale (in-place).

```ruby
stringa = "ciao"

# Metodo predicato: molto leggibile
puts "È vuota?" if stringa.empty? 

# Metodo normale vs Metodo !
puts stringa.upcase # => "CIAO" (crea una copia, stringa rimane "ciao")

stringa.upcase!     # => Modifica direttamente la variabile originale
puts stringa        # => "CIAO"

```

---

### 3. Blocchi (Iterazioni eleganti)

Dimentica i cicli `for` classici. Ruby usa i blocchi (`do...end` o `{...}`) che rendono le manipolazioni di liste quasi poetiche.

```ruby
nomi = ["Alice", "Bob", "Charlie"]

# In altri linguaggi useresti un for(i=0; i < len; i++)
# In Ruby usi un blocco:
nomi.each do |nome|
  puts "Ciao #{nome}!"
end

# Versione contratta per operazioni singole
nomi.map! { |n| n.reverse }

```

---

### 4. Rails Magic: Active Support & Syntactic Sugar

Ruby on Rails aggiunge delle estensioni che sembrano quasi "magia" per quanto sono intuitive. Ecco un paio di esempi di come Rails potenzia Ruby.

```ruby
# Gestione del tempo (ActiveSupport)
2.days.ago
1.month.from_now

# Estensioni per la leggibilità (present? vs nil/empty)
# Invece di: if user && user.name != ""
if user.name.present?
  puts "Abbiamo un nome!"
end

# Metodi dinamici (Finder magici)
# Rails capisce il nome della colonna dal database automaticamente
User.find_by_email("test@esempio.it")

```

---

### 5. Tutto è un Oggetto (Pure Object Orientation)

In Ruby, anche i numeri sono oggetti. Puoi chiamare metodi direttamente sui letterali.

```ruby
# Invece di cicli complessi
5.times do
  puts "Ruby è fantastico!"
end

# Chiedere informazioni a un numero
10.even? # => true

```

Ti servono altri esempi specifici sulla metaprogrammazione (tipo `method_missing`) o vuoi approfondire come Rails gestisce le rotte?

## Riccardo 2: La metaprogrammazione

* Riccardo: Si ti prego! Spiega la metaprogrammazione ad esempio fai un piccolo pezzo di codice che implementi una funzionalita tipo `User.find_by_whatever` cosi spieghiamo meglio la find by email di cui sopra


La metaprogrammazione è probabilmente la caratteristica più potente e "magica" di Ruby. In breve: **è codice che scrive altro codice** a runtime.

Il metodo `find_by_...` di Rails che abbiamo visto prima è l'esempio perfetto. Rails non scrive migliaia di metodi (uno per ogni colonna del tuo database); usa la metaprogrammazione per intercettare la tua chiamata e capire cosa vuoi fare.

Ecco come potresti implementare una versione super semplificata di `find_by_whatever` usando il metodo speciale `method_missing`.

### La "Magia" del `method_missing`

In Ruby, se chiami un metodo che non esiste, l'interprete non crasha subito. Prima bussa alla porta di un metodo speciale chiamato `method_missing`. Tu puoi sovrascrivere quel metodo per fargli fare quello che vuoi.

```ruby
class User
  # Similiamo un database
  DATA = [
    { id: 1, name: "Luca", email: "luca@esempio.it" },
    { id: 2, name: "Anna", email: "anna@esempio.it" }
  ]

  # Questo metodo viene chiamato ogni volta che invochi 
  # un metodo che NON è definito nella classe.
  def self.method_missing(method_name, *args)
    # Controlliamo se il nome del metodo inizia con "find_by_"
    if method_name.to_s.start_with?("find_by_")
      
      # Estraiamo il nome dell'attributo (es. "email" o "name")
      attribute = method_name.to_s.sub("find_by_", "")
      value = args.first

      puts "--- Ricerca dinamica per #{attribute} con valore: #{value} ---"
      
      # Cerchiamo nei nostri dati
      return DATA.find { |record| record[attribute.to_sym] == value }
    else
      # Se non inizia con find_by_, lasciamo che Ruby sollevi l'errore standard
      super
    end
  end
end

# --- UTILIZZO ---

# Questo metodo NON esiste fisicamente nel codice sopra...
user1 = User.find_by_email("anna@esempio.it")
puts user1 # => {:id=>2, :name=>"Anna", :email=>"anna@esempio.it"}

# ...e neanche questo esiste, ma Ruby lo "crea" al volo!
user2 = User.find_by_name("Luca")
puts user2 # => {:id=>1, :name=>"Luca", :email=>"luca@esempio.it"}

# Questo invece darà errore perché non inizia con find_by_
# User.saluta("Ciao") # => NoMethodError

```

### Perché questa è una "figata"?

1. **DRY (Don't Repeat Yourself):** Non devi scrivere un metodo per ogni campo del database. Se domani aggiungi la colonna `codice_fiscale`, il metodo `User.find_by_codice_fiscale` funzionerà istantaneamente senza scrivere una riga di codice extra.
2. **Espressività:** Il codice che usa la classe sembra scritto in linguaggio naturale. Leggere `User.find_by_email` è molto più chiaro di `User.find("email", "test@test.it")`.
3. **Flessibilità:** Puoi usare la metaprogrammazione per creare DSL (Domain Specific Languages), ovvero piccoli linguaggi personalizzati dentro Ruby (proprio come fa Rails per le rotte o le migrazioni).

**In opposizione al codice "normale" (Senza Metaprogrammazione):**
Senza questa funzione, in un linguaggio rigido dovresti fare così:

```ruby
def self.find_by_email(val)
  DATA.find { |r| r[:email] == val }
end

def self.find_by_name(val)
  DATA.find { |r| r[:name] == val }
end

# E così via per ogni singola colonna... noioso e prono a errori!

```