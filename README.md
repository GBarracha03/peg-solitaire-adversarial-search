# Peg Solitaire 2 - Adversarial Search

Project developed for the **Artificial Intelligence** course at Escola Superior de Tecnologia de Setúbal (Academic Year 2025/2026).


## About the Project
This program is a Lisp-based implementation of **Peg Solitaire 2**, a two-player competitive version of the classic puzzle. Played on a cross-shaped 7x7 board, the objective for each player is to be the first to move one of their pegs into the opponent's starting area.

The game supports two modes:
* **Human vs Computer**
* **Computer vs Computer**

Players alternate turns using 8 possible operators: simple moves (Up, Down, Left, Right) and capture moves (jumping over an opponent's peg).

## Project Structure & Algorithms
The project follows a modular structure separated into three main files:
* **`algoritmo.lisp`**: Contains the domain-independent adversarial search implementation.
* **`puzzle.lisp`**: Contains the game domain logic, board representation, and the 8 movement operators.
* **`jogo.lisp`**: Manages the game loop, file reading/writing, and user interaction.

### Artificial Intelligence Techniques
To ensure the computer makes highly competitive and efficient decisions, the following algorithms and techniques were implemented:
* **Negamax with Alpha-Beta Pruning**: The core adversarial search algorithm used to evaluate game trees and eliminate branches that don't influence the final decision.
* **Quiescent Search**: Triggered when the maximum depth is reached, continuing the search for capture moves to prevent the "horizon effect" and ensure evaluations occur in stable states.
* **Successor Ordering**: Prioritizes capture moves during node expansion to maximize the efficiency of Alpha-Beta cuts.
* **Memoization (Transposition Table)**: Uses hash tables to store previously evaluated states and their depths, avoiding redundant calculations.

## How to Run

To run the project, you need a configured Lisp environment. Follow these steps:

1. Set the working directory to the project folder:
   ```lisp
   (cd "path/to/project")
2. Compile the project:
   ```lisp
   (compile-file "jogo.lisp")
3. Load the project:
   ```lisp
   (load "jogo")
4. Start the program:
   ```lisp
   (iniciar-jogo)
Follow the interactive menu instructions to choose the board, algorithm, and heuristic.

## Documentation
For more detailed information about the code architecture or step-by-step instructions, check our manuals (currently available in Portuguese):

* manual_tecnico

* manual_utilizador

## Authors
* **Gonçalo Barracha** - 202200187
* **Rodrigo Cardoso** - 202200197


Note: Artificial Intelligence (ChatGPT) was used to assist in specific parts of the development process:

* Improving the textual interface and ensuring a cleaner game loop.

* Assisting in the formulation of an acceptable heuristic function for the domain.
* Aiding in the implementation of Quiescent Search and Memoization (Transposition Tables), as these were advanced topics not fully covered in laboratory sessions.