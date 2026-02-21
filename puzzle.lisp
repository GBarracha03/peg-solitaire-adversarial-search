;;;; ====================================================================================
;;;; Ficheiro: puzzle.lisp
;;;; Descrição: Definição do domínio do Puzzle Solitário (Estados, Operadores, Heurísticas).
;;;; Autores: Gonçalo Barracha 202200187, Rodrigo Cardoso 202200197
;;;; ====================================================================================

(defparameter *nos-gerados* 0 "Contador global de nós gerados.")

;;; ------------------------------------------------------------------------------------
;;; Operadores e Lógica do Tabuleiro
;;; ------------------------------------------------------------------------------------

(defun operadores ()
  "Devolve uma lista de pares contendo a função lógica e o símbolo associado a cada movimento permitido"
  (list (list 'operador-ce 'ce)
        (list 'operador-cd 'cd)
        (list 'operador-cc 'cc)
        (list 'operador-cb 'cb)
        (list 'operador-e  'e)
        (list 'operador-d  'd)
        (list 'operador-c  'c)
        (list 'operador-b  'b)))

(defun tabuleiro-inicial-p (tabuleiro)
  "Verifica se o tabuleiro está na configuração inicial exata"
  (and (equal (celula 1 3 tabuleiro) 1) (equal (celula 1 4 tabuleiro) 1) (equal (celula 1 5 tabuleiro) 1)
       (equal (celula 2 3 tabuleiro) 1) (equal (celula 2 4 tabuleiro) 1) (equal (celula 2 5 tabuleiro) 1)
       (equal (celula 6 3 tabuleiro) 2) (equal (celula 6 4 tabuleiro) 2) (equal (celula 6 5 tabuleiro) 2)
       (equal (celula 7 3 tabuleiro) 2) (equal (celula 7 4 tabuleiro) 2) (equal (celula 7 5 tabuleiro) 2)
       (equal (celula 3 3 tabuleiro) 0)))

(defun linha (indice tabuleiro)
"Função que recebe um indíce e o tabuleiro e retorna a lista que representa a linha do tabueliro do indíce indicado"
(cond ((or (> indice 7) (< indice 1)) nil)
      ((null tabuleiro) (format T "Tabuleiro inválido!"))
      (T (nth (1- indice) tabuleiro))))

(defun coluna (indice tabuleiro)
"Função que recebe um indíce e o tabuleiro e retorna a lista que representa a coluna do tabuleiro do indíce indicado"
(cond ((or (> indice 7) (< indice 1)) nil)
      ((null tabuleiro) (format T "Tabuleiro inválido!"))
      (T (mapcar (lambda (linha) (nth (1- indice) linha)) tabuleiro))))

(defun celula (indice-horizontal indice-vertical tabuleiro)
  "Retorna o valor da célula (linha, coluna). Nil se inválido."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1)) nil)
      ((null tabuleiro) (format T "Tabuleiro inválido"))
      (T (nth (1- indice-vertical) (nth (1- indice-horizontal) tabuleiro)))))

(defun celula-valida (indice-horizontal indice-vertical tabuleiro)
  "Verifica se uma coordenada corresponde a uma célula válida do tabuleiro."
  (cond ((null (celula indice-horizontal indice-vertical tabuleiro))nil)
      (T T)))

(defun substituir-posicao (indice lista valor)
  "Substitui o valor numa posição específica de uma lista (linha)."
  (cond ((or (> indice 7) (< indice 1)) 
     (format T "Indice ~d inválido, tem de indicar um indíce entre 1-7~%" indice)
     nil)
        ((null lista) 
         (format T "Lista inválida!~%")
         nil)
        ((or (> valor 2) (< valor 0))
         (format T "Valor ~d inválido, valor tem de ser 0, 1 ou 2~%" valor)
         nil)
        ((= indice 1) (cons valor (cdr lista)))
        (T (cons (car lista) (substituir-posicao (1- indice) (cdr lista) valor)))))

(defun substituir (indice-horizontal indice-vertical tabuleiro valor)
  "Substitui o valor numa célula (coluna h, linha v) do tabuleiro."
  (cond ((null tabuleiro) (format T "Tabuleiro inválido!"))
      ((null (celula-valida indice-horizontal indice-vertical tabuleiro)) (format T "Célula inválida!"))
      ((= indice-horizontal 1) (cons (substituir-posicao indice-vertical (linha indice-horizontal tabuleiro) valor) (cdr tabuleiro)))
      (T (cons (car tabuleiro) (substituir (1- indice-horizontal) indice-vertical (cdr tabuleiro) valor)))))

(defun estado-tabuleiro (estado) "Devolve o tabuleiro" (first estado))

(defun estado-jogador (estado) "Devolve o jogador" (second estado))

(defun outro-jogador (j)
  "Troca de jogador"
  (if (= j 1) 2 1))

;;; ------------------------------------------------------------------------------------
;;; Operadores de Movimento
;;; ------------------------------------------------------------------------------------

(defun operador-cd (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para a DIREITA (h, v+2)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida indice-horizontal (+ indice-vertical 2) tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) 
  nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula indice-horizontal (1+ indice-vertical) tabuleiro) (outro-jogador jogador))
       (= (celula indice-horizontal (+ indice-vertical 2) tabuleiro) 0))
  (substituir indice-horizontal (+ indice-vertical 2)
                                    (substituir indice-horizontal (1+ indice-vertical)
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) 0) jogador))
  (T nil)))

(defun operador-d (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para a DIREITA (h, v+1)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida indice-horizontal (+ indice-vertical 1) tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) 
  nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula indice-horizontal (1+ indice-vertical) tabuleiro) 0))
                                    (substituir indice-horizontal (1+ indice-vertical)
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) jogador))
  (T nil)))

(defun operador-ce (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para a ESQUERDA (h, v-2)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida indice-horizontal (- indice-vertical 2) tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) 
   nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula indice-horizontal (1- indice-vertical) tabuleiro) (outro-jogador jogador))
       (= (celula indice-horizontal (- indice-vertical 2) tabuleiro) 0))
  (substituir indice-horizontal (- indice-vertical 2)
                                    (substituir indice-horizontal (1- indice-vertical)
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) 0) jogador))
  (T nil)))

(defun operador-e (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para a ESQUERDA (h, v-1)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida indice-horizontal (- indice-vertical 1) tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) 
   nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula indice-horizontal (1- indice-vertical) tabuleiro) 0))
                                    (substituir indice-horizontal (1- indice-vertical)
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) jogador))
  (T nil)))

(defun operador-cc (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para CIMA (h-2, v)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida (- indice-horizontal 2) indice-vertical tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula (1- indice-horizontal) indice-vertical tabuleiro) (outro-jogador jogador))
       (= (celula (- indice-horizontal 2)  indice-vertical tabuleiro) 0))
  (substituir (- indice-horizontal 2) indice-vertical
                                    (substituir (1- indice-horizontal) indice-vertical
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) 0) jogador))
  (T nil)))

(defun operador-c (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para CIMA (h-1, v)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida (- indice-horizontal 1) indice-vertical tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula (1- indice-horizontal) indice-vertical tabuleiro) 0))
                                    (substituir (1- indice-horizontal) indice-vertical
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) jogador))
  (T nil)))

(defun operador-cb (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para BAIXO (h+2, v)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida (+ indice-horizontal 2) indice-vertical tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) 
  nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula (1+ indice-horizontal) indice-vertical tabuleiro) (outro-jogador jogador))
       (= (celula (+ indice-horizontal 2)  indice-vertical tabuleiro) 0))
  (substituir (+ indice-horizontal 2) indice-vertical
                                    (substituir (1+ indice-horizontal) indice-vertical
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) 0) jogador))
  (T nil)))

(defun operador-b (indice-horizontal indice-vertical tabuleiro jogador)
  "Tenta mover a peça em (h,v) para BAIXO (h+1, v)."
  (cond ((or (> indice-horizontal 7) (< indice-horizontal 1) (> indice-vertical 7) (< indice-vertical 1))
  nil)
 ((or(null(celula-valida (+ indice-horizontal 1) indice-vertical tabuleiro))
     (null(celula-valida indice-horizontal indice-vertical tabuleiro))) 
  nil)
 ((and (= (celula indice-horizontal indice-vertical tabuleiro) jogador)
       (= (celula (1+ indice-horizontal) indice-vertical tabuleiro) 0))
                                    (substituir (1+ indice-horizontal) indice-vertical
                                               (substituir indice-horizontal indice-vertical tabuleiro 0) jogador))
  (T nil)))

;;; ------------------------------------------------------------------------------------
;;; Funções de Geração de Sucessores e Objetivos
;;; ------------------------------------------------------------------------------------

(defparameter *zona-vitoria-j1*
  '((6 3) (6 4) (6 5) (7 3) (7 4) (7 5)))

(defparameter *zona-vitoria-j2*
  '((1 3) (1 4) (1 5) (2 3) (2 4) (2 5)))

(defun jogador-venceu-p (tabuleiro jogador)
  "Verifica se o jogador venceu o jogo ao atingir a zona alvo."
  (let ((zona (cond ((= jogador 1) *zona-vitoria-j1*)
                    (T *zona-vitoria-j2*))))
    (some (lambda (pos)
            (= (celula (first pos) (second pos) tabuleiro) jogador))
          zona)))

(defun estado-terminal-p (estado)
  "Verifica se o jogo terminou"
  (or (jogador-venceu-p (estado-tabuleiro estado) 1)
      (jogador-venceu-p (estado-tabuleiro estado) 2)))

(defun gerar-sucessores-op (operadores linha coluna tabuleiro jogador)
  "Função recursiva que percorre o tabuleiro e gera os sucessores"
  (cond ((null operadores) nil)
        (T (let* ((operador (car operadores))
            (funcao (first operador))
            (simbolo (second operador))
            (novo-tabuleiro (funcall funcao linha coluna tabuleiro jogador)))
       (if novo-tabuleiro
           (cons (list (list simbolo linha coluna)
                       (list novo-tabuleiro (outro-jogador jogador)))
                 (gerar-sucessores-op (cdr operadores) linha coluna tabuleiro jogador))
           (gerar-sucessores-op (cdr operadores) linha coluna tabuleiro jogador))))))

(defun gerar-sucessores-coluna (linha coluna tabuleiro jogador operadores)
  "Percorre as colunas para verificar onde pode jogar"
  (cond ((> coluna 7) nil)
    ((eql (celula linha coluna tabuleiro) jogador)
     (append
      (gerar-sucessores-op operadores linha coluna tabuleiro jogador)
      (gerar-sucessores-coluna linha (1+ coluna) tabuleiro jogador operadores)))
    (T (gerar-sucessores-coluna linha (1+ coluna) tabuleiro jogador operadores))))

(defun gerar-sucessores-linha (linha tabuleiro jogador operadores)
  "Percorre as linhas para avaliar onde pode jogar"
  (cond ((> linha 7) nil)
    (T (append
      (gerar-sucessores-coluna linha 1 tabuleiro jogador operadores)
      (gerar-sucessores-linha (1+ linha) tabuleiro jogador operadores)))))

(defun sucessores-estado (estado)
  "Função principal de expansão de nós. Implementa a regra especial da primeira jogada: o Jogador 1 só pode mover para baixo (b) e o Jogador 2 só pode mover para cima (c)"
  (let* ((tabuleiro (estado-tabuleiro estado))
         (jogador (estado-jogador estado))
         (operadores (operadores))
         (expansao-inicial (tabuleiro-inicial-p tabuleiro))
         (operadores-validos
          (cond ((and expansao-inicial (= jogador 1))
             (list (list 'operador-b 'b)))
            ((and expansao-inicial (= jogador 2))
             (list (list 'operador-c 'c)))
            (T operadores))))
    (gerar-sucessores-linha 1 tabuleiro jogador operadores-validos)))

;;; ------------------------------------------------------------------------------------
;;; Heurísticas
;;; ------------------------------------------------------------------------------------

(defun contar-pecas-linha (linha jogador)
  "Conta quantas peças o jogador tem numa linha"
  (cond ((null linha) 0)
        ((and (numberp (car linha)) (= (car linha) jogador))
         (+ 1 (contar-pecas-linha (cdr linha) jogador)))
        (T (contar-pecas-linha (cdr linha) jogador))))

(defun contar-pecas (tabuleiro jogador)
  "Conta quantas peças o jogador tem no tabuleiro."
  (cond ((null tabuleiro) 0)
        (T (+ (contar-pecas-linha (car tabuleiro) jogador)
              (contar-pecas (cdr tabuleiro) jogador)))))

(defun progresso (tabuleiro jogador)
  "Mede quantas peças o jogador já tem na sua zona de vitória[cite: 9, 252]."
  (let ((zona (cond ((= jogador 1) *zona-vitoria-j1*)
                    (T *zona-vitoria-j2*))))
    (count-if (lambda (pos)
                (let ((valor (celula (first pos) (second pos) tabuleiro)))
                  (and (numberp valor) (= valor jogador))))
              zona)))

(defun mobilidade (estado)
  "Número de jogadas possíveis para o jogador atual."
  (length (sucessores-estado estado)))

(defun avaliar (estado)
  "A função heurística final. Atribui um valor muito alto para vitórias e combina a diferença de material, progresso e mobilidade entre os dois jogadores para decidir qual a melhor jogada"
  (let* ((tabuleiro (estado-tabuleiro estado))
         (jogador (estado-jogador estado))
         (outro (outro-jogador jogador)))
    (cond ((jogador-venceu-p tabuleiro jogador) 100000)
      ((jogador-venceu-p tabuleiro outro) -100000)
      (T (+ (* 100 (- (contar-pecas tabuleiro jogador)(contar-pecas tabuleiro outro))) (* 50 (- (progresso tabuleiro jogador) (progresso tabuleiro outro))) (- (mobilidade (list tabuleiro jogador)) (mobilidade (list tabuleiro outro))))))))
