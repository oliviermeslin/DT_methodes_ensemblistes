# DT: Introduction aux méthodes ensemblistes
Ce document méthodologique comporterait environ 60 pages, figures et annexes comprises.

# Introduction
Cette section comporterait environ 1 page.

# 1. Aperçu des méthodes ensemblistes

Introduction intuitive aux méthodes ensemblistes, accessible sans prérequis.
Cette section comporterait une dizaine de pages, figures comprises.

## 1.1 Que sont les méthodes ensemblistes ?

Définition des méthodes ensemblistes, leur principe de combinaison de modèles simples ("apprenants faibles") pour créer un modèle plus performant ("apprenant fort"). Focus sur les méthodes basées sur les arbres de décision.

## 1.2 Pourquoi utiliser des méthodes ensemblistes ?

Avantages des méthodes ensemblistes par rapport aux méthodes économétriques traditionnelles (régression linéaire et logistique) : puissance prédictive supérieure, moins de préparation des données, robustesse aux valeurs extrêmes et à l'hétéroscédasticité. 

Limites : interprétabilité moindre et complexité accrue de l'entraînement et de l'optimisation des hyperparamètres. Comparaison avec le deep learning.

## 1.3 Comment fonctionnent les méthodes ensemblistes ?

Présentation du modèle de base (arbre CART) et des deux grandes familles de méthodes ensemblistes : bagging (dont forêts aléatoires) et gradient boosting.

### 1.3.1 Le modèle de base : l'arbre de classification et de régression (CART)

Explication intuitive du fonctionnement d'un arbre CART : partitionnement de l'espace des variables explicatives, règles de décision, prédictions. Avantages et limites des arbres CART (faible pouvoir prédictif et instabilité).

#### 1.3.1.1 Qu'est-ce qu'un arbre CART ?

Définition formelle d'un arbre CART. Caractéristiques essentielles: partitionnement de l'espace des variables explicatives en régions homogènes, règles de décision, prédiction pour chaque région.

#### 1.3.1.2 Avantages et limites des arbres CART

Points forts: simplicité, interprétabilité. 
Faiblesses: faible pouvoir prédictif, instabilité, variance élevée.

### 1.3.2 Le bagging (Bootstrap Aggregating) et les forêts aléatoires

Introduction au bagging : principe du bootstrap, entraînement parallèle, agrégation des prédictions. 
Avantages du bagging : meilleure capacité prédictive et stabilité. 
Limites : corrélation entre les arbres.

#### 1.3.2.1 Le bagging

Détail du processus de bagging : création de sous-échantillons aléatoires avec remise, entraînement parallèle des modèles de base, agrégation des prédictions (moyenne ou vote majoritaire). Illustration graphique.

#### 1.3.2.2 Les random forests

Amélioration du bagging : ajout de la sélection aléatoire des variables. Réduction de la corrélation entre les arbres, amélioration de l'efficacité de l'agrégation. Illustration graphique.

### 1.3.3 Le gradient boosting

Présentation du gradient boosting : entraînement séquentiel des arbres, correction des erreurs des arbres précédents. 
Avantages : performances élevées.
Limites : complexité, sensibilité aux hyper-paramètres, risque de surapprentissage. 
Illustration graphique.


# 2. Présentation formelle des méthodes ensemblistes

Objectif : Présentation formelle des méthodes ensemblistes, pour une compréhension approfondie des algorithmes.
Cette section comporterait environ 25 pages.

## 2.1 La brique élémentaire : l'arbre de décision

Présentation formelle des arbres de décision : principe du partitionnement pour prédire, défis du partitionnement optimal. Solution apportée par les arbres de décision (simplification du partitionnement et optimisation gloutonne). Terminologie et structure d'un arbre de décision.
Cette section comporterait environ 5 pages.

### 2.1.1 Le principe fondamental : partitionner pour prédire

Explication du principe de base des arbres de décision : partitionner l'espace des caractéristiques en zones plus homogènes.

### 2.1.2 Les défis du partitionnement optimal

Difficultés liées à la recherche du partitionnement optimal.

### 2.1.3 Les solutions apportées par les arbres de décision

Approche de simplification du partitionnement de l'espace et optimisation gloutonne.

### 2.1.4 Terminologie et structure d'un arbre de décision

Définition des termes clé: Noeud racine, noeuds internes, branches, feuilles.

### 2.1.5 L'algorithme CART : un partitionnement binaire récursif

Détail de l'algorithme CART : fonction d'impureté (indice de Gini, entropie, somme des erreurs quadratiques), choix de la meilleure division binaire, critère d'arrêt, élagage, prédiction.

### 2.1.6 Avantages et limites des arbres de décision

Avantages: interprétabilité, simplicité, flexibilité, gestion des interactions. 
Limites : surapprentissage, optimatimisation locale, instabilité.

## 2.2 Le bagging

Présentation détaillée du bagging : échantillonnage bootstrap, entraînement parallèle, agrégation des prédictions. Explication de son fonctionnement pour la régression (réduction de la variance) et la classification (classificateur presque optimal). Limites du bagging en pratique.
Cette section comporterait environ 5 pages.

### 2.2.1 Principe du bagging

Détail des étapes du bagging.

### 2.2.2 Pourquoi le bagging fonctionne

Explication du fonctionnement du bagging avec la décomposition biais-variance et l'inégalité de Breiman.

### 2.2.3 L'échantillonnage par bootstrap peut détériorer les performances théoriques du modèle agrégé

Présentation des limites de l'échantillonnage bootstrap : taille effective réduite, dépendance entre échantillons, couverture incomplète.


## 2.3 La forêt aléatoire

Présentation détaillée des forêts aléatoires : principe, construction (échantillonnage bootstrap, sélection aléatoire de variables, agrégation des prédictions). Explication de leur performance (réduction de la variance, convergence, facteurs influençant l'erreur de généralisation). Hyperparamètres clés, erreur OOB.
Cette section comporterait environ 5 pages.

### 2.3.1 Principe de la forêt aléatoire

Détail des éléments constitutifs d'une forêt aléatoire (arbres CART, bootstrapping, sélection aléatoire de variables, agrégation).

### 2.3.2 Comment construit-on une forêt aléatoire ?

Description des étapes de la construction d'une forêt aléatoire.

### 2.3.3 Pourquoi les forêts aléatoires sont-elles performantes ?

Explication des mécanismes de réduction de variance et des limites théoriques du surapprentissage.

### 2.3.4 Les hyperparamètres clés des forêts aléatoires

Détail des principaux hyperparamètres, leur rôle et leur influence sur les performances. Tableau récapitulatif.

### 2.3.5 Evaluation des performances par l'erreur Out-of-Bag (OOB)

Détail de la procédure d'estimation OOB, ses avantages et ses limites.

### 2.3.6 Interprétation et importance des variables

Discussion des méthodes d'importance des variables (MDI, MDA, valeurs de Shapley, CIF, Sobol-MDA), leurs biais et leurs avantages.

## 2.4 Le boosting

Introduction au boosting, ses principes fondamentaux (approximation d'une fonction inconnue, somme pondérée de modèles simples, modélisation additive par étapes). Présentation des premières approches (AdaBoost, Gradient Boosting Machine). Détail de la mécanique du gradient boosting (fonction objectif, gradient, hessienne, construction de l'arbre). Moyens de lutter contre le surapprentissage. Hyperparamètres et préparation des données.
Cette section comporterait environ 10 pages.

### 2.4.1 Introduction

Présentation générale du boosting.

### 2.4.2 Les premières approches du boosting

Présentation d'AdaBoost et de la Gradient Boosting Machine.

### 2.4.3 La mécanique du gradient boosting

Détail de la mécanique du gradient boosting. Fonction objectif, calcul des poids optimaux, construction de l'arbre, choix des splits.

### 2.4.4 Les hyperparamètres
Présentation des hyperparamètres.

### 2.4.5 Les fonctions de perte
Présentation des fonctions de perte usuelles.

### 2.4.5 Les moyens de lutter contre l'overfitting

Techniques pour éviter le surapprentissage dans les modèles _boosting_ (_shrinkage_, _subsampling_, régularisation).



# 3. Mise en pratique

Objectif : Guide pratique pour l'utilisation des forêts aléatoires et du _gradient boosting_.
Cette section comporterait environ 15 pages.


## 3.1 Préparation des données

Recommandations pour la préparation des données : gestion des valeurs manquantes, encodage des variables catégorielles, utilisation de pipelines.
Pipeline Scikit-learn. Division des données en échantillons _train_ et _test_.

## 3.2 Evaluation des performances du modèle et optimisation des hyperparamètres

Méthodes d'évaluation : validation croisée, estimation OOB. Stratégies d'optimisation des hyperparamètres : recherche exhaustive (grid search, random search), optimisation basée sur modèle séquentiel (SMBO).

## 3.3 Guide d'entraînement des forêts aléatoires

Recommandations pratiques pour l'entraînement des forêts aléatoires : implémentations à privilégier, hyperparamètres clés, procédures d'entraînement.
Cette section comporterait environ 5 pages.

### 3.3.1 Quelles implémentations utiliser ?

Recommandations sur les implémentations (ranger en R, scikit-learn en Python).

### 3.3.2 Les hyperparamètres clés des forêts aléatoires

Détail des hyperparamètres et valeurs par défaus dans les implémentations usuelles.

### 3.3.3 Comment entraîner une forêt aléatoire ?

Procédure d'entraînement étape par étape.
Recommandations pour l'optimisation des hyper-paramètres: approche exploratoire (grid search et random search) et approches avancées (SMBO).

### 3.3.4 Mesurer l'importance des variables

Recommandations sur les méthodes d'importance des variables. Privilégier celles tenant compte des biais potentiels (algorithme CIF, Sobol-MDA et SHAFF).

## 3.4 Guide d'entraînement des algorithmes de _gradient boosting_

Recommandations pratiques pour l'entraînement des algorithmes de _gradient boosting_ : implémentations à privilégier, hyperparamètres clés, procédures d'entraînement.
Cette section comporterait environ 5 pages.

# 4. Cas d’usage des méthodes ensemblistes dans la statistique publique
Objectif: présenter des travaux du SSP qui mobilisent, ou qui pourraient mobiliser, des méthodes ensemblistes.
Liste non exhaustive. Résumés de ces travaux et liens vers les publications de référence.
Cette section comporterait environ 2 pages.

## 4.1. Les travaux déjà publiés mobilisant des méthodes ensemblistes

## 4.2. Les travaux et processus actuels qui pourraient mobiliser des méthodes ensemblistes