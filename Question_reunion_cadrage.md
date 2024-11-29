# Questions pour les participants de la réunion de cadrage

## Le document méthodologique

### Démarche

- Que pensez-vous l'approche à trois niveaux de lecture : aperçu intuitif (Section 1), puis présentation plus formalisée (Section 2), puis guide d'entraînement pratique (Section 3) ?
- Que pensez-vous de séparer la présentation des méthodes elles-mêmes, et leur usage?
- Un autre plan possible: aperçu intuitif (Section 1) puis présentation des random forests (fonctionnement et guide pratique, Section 2), puis présentation du gradient boosting  (fonctionnement et guide pratique, Section 3)

### Présentation des algorithmes

- Veut-on mettre une présentation des algorithmes en pseudocode?

### Interprétabilité

- Les approches d'interprétation doivent-elles être abordées pour chaque algorithme, ou dans une partie à part? => proposition: faire une partie à part, éventuellement avec des éléments spécifiques aux RF ou au GB s'il y en a.

### Recommandations

- Probst et al 2019, et S. Da Veiga recommande d'utiliser l'erreur _out-of-bag_ (plutôt que la validation croisée) pour optimiser les hyperparamètres des forêts aléatoires, car c'est plus rapide. Toutefois, cette approche ne peut pas être implémentée de façon standard en Python avec `scikit-learn` (qui ne propose que la validation croisée). Il est possible de trouver un moyen de contournement ([ici](https://stackoverflow.com/questions/34624978/is-there-easy-way-to-grid-search-without-cross-validation-in-python) par exemple), mais ce n'est pas standard. Que voulons-nous recommander: OOB ou CV?

## Les notebooks:
- Faut-il proposer des notebooks qui utilisent les pipelines scikit-learn afin de sensibiliser/former à leur usage ? Cela ajoute-t-il une couche d'abstraction qui peut nuire à la bonne compréhension des étapes de construction d'un modèle ? => proposition: utiliser les pipelines.

- Y a-t-il des cas d'usages majeurs qui ne seraient pas couverts par la liste des notebooks proposés?


