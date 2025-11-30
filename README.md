# 🧩 Sudoku Solver – MIPS32 Assembly

## 🇫🇷 À propos
Ce projet est un **solveur de Sudoku en assembleur MIPS32**.  
Le programme charge une grille depuis un fichier texte, applique une méthode de **backtracking**, et affiche toutes les solutions valides.  
But : se familiariser avec la **programmation bas-niveau**, la manipulation des **registres**, de la **pile**, et de la **mémoire**.

### Fonctionnalités principales
- Lecture d’une grille de Sudoku depuis un fichier externe  
- Résolution complète via **backtracking**  
- Vérification des contraintes sur les lignes, colonnes et blocs 3x3  
- Affichage formaté de toutes les solutions dans la console  

### Environnement et technologies
- Langage : **MIPS32 assembly**  
- Simulateur recommandé : **MARS**, **QtSPIM** ou **SPIM**  
- Entrée : fichier texte simple (`sudoku.txt`)  
- Concepts ciblés : registres, stack, syscalls, mémoire  

---

## 🇬🇧 About
This is a **MIPS32 assembly Sudoku solver**.  
It reads a grid from a text file, uses a **backtracking algorithm**, and prints all possible valid solutions.  
Goal: practice **low-level programming** and gain experience with **register and memory management**.

### Main Features
- Read Sudoku grids from an external file  
- Solve grids using **backtracking**  
- Validate row, column, and 3x3 block constraints  
- Console output showing all possible solutions  

### Environment & Technologies
- Language: **MIPS32 assembly**  
- Recommended simulators: **MARS**, **QtSPIM**, **SPIM**  
- Input: simple text file (`sudoku.txt`)  
- Key concepts: registers, stack, syscalls, memory management  

---

## 🟢 Démarrage rapide / Getting Started

### 🇫🇷 Prérequis
- Simulateur MIPS compatible (MARS ou SPIM)

### 🇫🇷 Installation
1. Cloner le projet :

```bash
git clone https://github.com/Igrekop/Sudoku---ASM-MIPS32.git
````

2. Ouvrir le fichier `.asm` dans votre simulateur MIPS.
3. Placer la grille Sudoku dans le dossier du projet (ex. `sudoku.txt`).
4. Assembler et exécuter le programme.

### 🇫🇷 Utilisation

* Le programme lit le fichier de grille, valide les entrées, puis affiche **toutes les solutions**.

Exemple de fichier (`sudoku.txt`) :

```
5 3 0 0 7 0 0 0 0
6 0 0 1 9 5 0 0 0
0 9 8 0 0 0 0 6 0
8 0 0 0 6 0 0 0 3
4 0 0 8 0 3 0 0 1
7 0 0 0 2 0 0 0 6
0 6 0 0 0 0 2 8 0
0 0 0 4 1 9 0 0 5
0 0 0 0 8 0 0 7 9
```

* Dans MARS :

  1. Ouvrir le fichier `.asm`
  2. Exécuter le programme (**Run > Go**)

---

### 🇬🇧 Getting Started

#### Prerequisites

* MIPS simulator (MARS, QtSPIM, or SPIM)

#### Installation

1. Clone the repository:

```bash
git clone https://github.com/salmaneyanis/Sudoku-ASM-MIPS32
```

2. Open the `.asm` file in your simulator.
3. Put your Sudoku grid file (e.g., `sudoku.txt`) in the project folder.
4. Assemble and run the program.

#### Usage

* The program reads the grid, validates it, and prints **all valid solutions**.

Example input file (`sudoku.txt`):

```
5 3 0 0 7 0 0 0 0
6 0 0 1 9 5 0 0 0
0 9 8 0 0 0 0 6 0
8 0 0 0 6 0 0 0 3
4 0 0 8 0 3 0 0 1
7 0 0 0 2 0 0 0 6
0 6 0 0 0 0 2 8 0
0 0 0 4 1 9 0 0 5
0 0 0 0 8 0 0 7 9
```

* In MARS:

  1. Open the `.asm` file
  2. Run (**Run > Go**)

---

## 📄 Licence / License

Distribué sous licence MIT.


