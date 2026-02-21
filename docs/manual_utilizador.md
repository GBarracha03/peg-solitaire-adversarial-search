# Manual do Utilizador
## Projeto Solitário 2

---

## 1. Objetivos do Programa

Permitir jogar **Solitário 2** nos modos:
- Humano vs Computador;
- Computador vs Computador.

---

## 2. Preparação do Ambiente

Antes de iniciar o programa, é obrigatório posicionar o interpretador Lisp na pasta do projeto:

    (cd "caminho onde esta o projeto")

---

## 3. Iniciar o Programa

Para iniciar o jogo:

    (iniciar-jogo)

---

## 4. Utilização

O utilizador escolhe:
1. Modo de jogo;
2. Quem começa;
3. Tempo limite do computador.

---

## 5. Introdução de Jogadas

Formato das jogadas:

    (b 2 3)

Onde:
- `b` é o operador;
- `2` a linha;
- `3` a coluna.

---

## 6. Informação Produzida

### Ecrã
- Tabuleiro com coordenadas;
- Jogadas efetuadas;
- Estatísticas do computador.

### Ficheiros
- `log.dat` com histórico das jogadas.

---

## 7. Limitações do Programa

- Sem desfazer jogadas;
- Interface textual;
- Dificuldade fixa;
- Entrada rigorosa.

---

## 8. Conclusão

O programa permite uma experiência completa do jogo Solitário 2 com suporte de Inteligência Artificial.