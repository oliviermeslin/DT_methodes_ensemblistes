# Questions pour les participants de la réunion de cadrage

## Le document méthodologique

### Démarche

- Que pensez-vous de l'approche à trois niveaux de lecture : aperçu intuitif (Section 1), présentation formalisée (Section 2), guide d'entraînement pratique (Section 3) ? 
Cette structure est-elle suffisamment claire ?
- Est-il préférable de séparer complètement la présentation des méthodes (Section 2) de leur guide d'utilisation pratique (Section 3) ? 
Ou une approche plus intégrée serait-elle plus efficace ?
Par exemple, un plan alternatif pourrait être: aperçu intuitif (Section 1), forêts aléatoires (fonctionnement et guide pratique, Section 2), gradient boosting (fonctionnement et guide pratique, Section 3).


### Contenu des parties rédigées
Les sections 3.3 et 4.3 présentant les forêts aléatoires sont déjà en partie rédigéee:
- Sont-elles suffisamment claires ? Y a-t-il des points à éclaircir ? 
- Le niveau de détail est-il approprié ? 
- Les choix méthodologiques (implémentations recommandées, etc.) sont-ils justifiés et bien expliqués ? 
- Le niveau de détail sur l'optimisation des hyperparamètres est-il suffisant ? 
- Les recommandations sur les méthodes d'interprétation sont-elles adaptées? Comment gérer le fait que certaines sont implémentées en Python mais pas en R ?

### Présentation des algorithmes

-  Est-il pertinent d'inclure des présentations des algorithmes en pseudocode ?

### Interprétabilité

- Faut-il dédier une section à part entière à l'interprétabilité des modèles ensemblistes ?
- Les approches d'interprétation doivent-elles être incluses dans les sections déjà dédiées à chaque algorithme? 
=> proposition: faire une section à part, éventuellement en insistant sur les spécificités liées aux RF ou au GB si besoin.

### Recommandations

- Probst et al 2019, et S. Da Veiga recommande d'utiliser l'erreur _out-of-bag_ (plutôt que la validation croisée) pour optimiser les hyperparamètres des forêts aléatoires, car c'est plus rapide. Toutefois, cette approche ne peut pas être implémentée de façon standard en Python avec `scikit-learn` (qui ne propose que la validation croisée). Il est possible de trouver un moyen de contournement ([ici](https://stackoverflow.com/questions/34624978/is-there-easy-way-to-grid-search-without-cross-validation-in-python) par exemple), mais ce n'est pas standard. Que voulons-nous recommander: OOB ou CV?

## Les notebooks:
- Faut-il proposer des notebooks qui utilisent les pipelines scikit-learn afin de sensibiliser/former à leur usage ? Cela ajoute-t-il une couche d'abstraction qui peut nuire à la bonne compréhension des étapes de construction d'un modèle ? => proposition: utiliser les pipelines.

- Y a-t-il des cas d'usages majeurs qui ne seraient pas couverts par la liste des notebooks proposés?


