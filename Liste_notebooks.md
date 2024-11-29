# Liste des notebooks envisagés

## Objectifs généraux des notebooks

Les notebooks devront être conçus pour être indépendants, reproductibles et pédagogiques, en offrant une transition progressive des bases aux approches plus avancées.

- **Illustration des méthodes**: Illustrer concrètement les méthodes ensemblistes présentées dans le document méthodologique, en mettant en lumière les étapes clés, de la préparation des données à l'entraînement des modèles, en passant par l'optimisation des performance et l’interprétation des résultats.

- **Reproductibilité et accessibilité**: Fournir un accompagnement pas-à-pas complet, en utilisant des données publiques et des librairies maintenues activement pour une reproductibilité optimale. Les utilisateurs doivent pouvoir exécuter les notebooks sans difficulté.

- **Diffusion des bonnes pratiques**: Promouvoir les bonnes pratiques en data science : utilisation de pipelines scikit-learn, choix de librairies performantes et robustes (ranger, scikit-learn), gestion rigoureuse de l'environnement, des données.

- **Applications concrètes**: Illustrer l'application des méthodes sur des cas d'usage simples basés sur les données individuelles du recensement de la population diffusées au format parquet (prédiction de l'âge et du niveau de diplôme).
Un exemple avec une tâche de régression (prédire l’âge) et une tâche de classification (prédire le niveau de diplôme).


## Liste des notebooks

2 applications très simples sont envisagées: prédire l'âge (régression) et prédire le niveau de diplôme (classification) à partir des données individuelles du recensement de la population.

- 2 notebooks en R : 
    - régression et classification par **forêt aléatoire** avec la librairie `Ranger`
- 4 notebooks en Python : 
    - régression et classification par **forêt aléatoire** avec la librairie `Scikit-learn`
    - régression et classification par **gradient boosting** avec la librairie `Scikit-learn`











