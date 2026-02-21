# Manual Técnico

## 1. Algoritmo Implementado

O algoritmo implementado neste projeto baseia-se no paradigma de **procura adversarial**, recorrendo ao algoritmo **Negamax com cortes Alfa-Beta**, complementado com **procura quiescente**, **ordenação de sucessores** e **memoização através de tabela de transposição**.

### 1.1 Negamax com Cortes Alfa-Beta

O algoritmo Negamax é uma reformulação simétrica do algoritmo Minimax, adequada a jogos de soma zero com dois jogadores. Assume-se que o jogador atual maximiza sempre o valor heurístico do estado, enquanto o adversário tenta minimizá-lo.

Os cortes Alfa-Beta permitem eliminar ramos do grafo de jogo que não podem influenciar a decisão final, reduzindo significativamente o número de nós analisados.

Fluxo geral do algoritmo:
1. Verificação do limite de tempo;
2. Consulta da tabela de transposição;
3. Deteção de estados terminais;
4. Entrada em procura quiescente quando a profundidade é zero;
5. Geração e ordenação de sucessores;
6. Aplicação de cortes Alfa e Beta.

---

### 1.2 Procura Quiescente

A procura quiescente é utilizada quando a profundidade máxima do Negamax é atingida.  
Em vez de avaliar imediatamente o estado, o algoritmo continua a explorar apenas **jogadas de captura**, evitando o problema do *horizon effect*.

Este mecanismo assegura que a avaliação heurística ocorre apenas em estados estáveis, melhorando a qualidade das decisões tomadas.

---

### 1.3 Ordenação de Sucessores

Antes da expansão dos nós, os sucessores são ordenados de forma a explorar primeiro jogadas de captura.  
Esta estratégia aumenta significativamente a eficácia dos cortes Alfa-Beta, reduzindo o número total de nós analisados.

---

### 1.4 Memoização (Tabela de Transposição)

Foi implementada uma tabela de transposição baseada em `hash-table`, onde são armazenados estados já avaliados juntamente com a profundidade a que foram analisados.

Sempre que um estado é reencontrado com profundidade igual ou inferior, o valor previamente calculado é reutilizado, evitando recomputações desnecessárias.

---

## 2. Tipos Abstratos Utilizados

### 2.1 Estado de Jogo

O estado do jogo é representado como um par abstrato:

- **Tabuleiro**: matriz 7×7 representada por listas de listas;
- **Jogador atual**: identificador numérico (1 ou 2).

Este tipo abstrato permite separar claramente a lógica do jogo da interface e do algoritmo de procura.

---

### 2.2 Jogada

Uma jogada é representada pela estrutura: (movimento linha coluna)


onde:
- `movimento` identifica o operador aplicado;
- `linha` e `coluna` indicam a posição da peça no tabuleiro.

---

### 2.3 Função de Avaliação

A função heurística retorna um valor inteiro que representa a qualidade de um estado, combinando:
- Diferença de material;
- Progresso em direção à zona de vitória;
- Mobilidade relativa dos jogadores.

Valores positivos favorecem o jogador atual, enquanto valores negativos favorecem o adversário.

---

## 3. Opções Técnicas e Limitações

### 3.1 Opções Técnicas

- Profundidade fixa do grafo de jogo;
- Limite temporal por jogada;
- Uso de heurísticas lineares;
- Procura adversarial determinística.

Estas opções garantem previsibilidade, controlo de tempo e facilidade de análise do comportamento do algoritmo.

---

### 3.2 Limitações do Projeto

- A profundidade limitada pode impedir a deteção de sequências vencedoras longas;
- A função heurística não garante decisões ótimas em todas as situações;
- Não existe aprendizagem nem adaptação dinâmica do modelo.


---

## 4. Análise Crítica dos Resultados

A análise das execuções do programa demonstra que o algoritmo toma decisões consistentes e estratégicas na maioria das situações.  
Contudo, em posições onde a função heurística não reflete corretamente o valor real do estado, podem ocorrer decisões subótimas, incluindo jogadas que conduzem a posições desfavoráveis a médio prazo.

Este comportamento evidencia a dependência direta entre a qualidade da função de avaliação e a eficácia global do algoritmo, conforme estudado na teoria de jogos.

---

## 5. Análise Estatística de uma Execução

A análise estatística foi realizada com base nos dados registados no ficheiro `log.dat`, durante uma execução no modo **Humano vs Computador**.

### 5.1 Condições da Execução

- Limite de tempo por jogada: 2000 ms
- Profundidade máxima do grafo de jogo: 4 níveis
- Algoritmo: Negamax com cortes Alfa-Beta e procura quiescente

---

### 5.2 Exemplo de Jogada Analisada

Jogada realizada : (CD 3 3)
Valor heurístico : 106
Nós analisados : 1059
Cortes Alfa : 122
Cortes Beta : 593
Tempo gasto : 2093 ms


---

### 5.3 Interpretação Estatística

- **Valor heurístico** elevado indica uma posição favorável para o computador;
- **Número de nós analisados** confirma a eficácia dos cortes Alfa-Beta;
- **Cortes Beta** predominam, refletindo boa ordenação de sucessores;
- **Tempo gasto** aproxima-se do limite imposto, demonstrando uso eficiente do tempo disponível;
- **profundidade efetiva** é aumentada pontualmente pela procura quiescente.

---

### 5.4 Conclusão da Análise

Os dados estatísticos confirmam que o algoritmo implementado está de acordo com os princípios fundamentais da Teoria de Jogos e da procura adversarial, apresentando um compromisso equilibrado entre desempenho, qualidade das decisões e limitações computacionais.

---

### 6. Notas Finais

* A interface foi melhorada com a ajuda de Inteligência Artifical (ChatGPT) para uma melhor interação e um ciclo de jogo mais "limpo".
* Na função "avaliar" , foi utilizado o ChatGPT para o auxilio da criação de uma heuristica aceitável para o dominio do problema.
* Foi utilizado também a Inteligência Artificial no auxilio do desenvolvimento da procura quiescente e memoização,dado que não foi um tema abordado nos laboratórios.