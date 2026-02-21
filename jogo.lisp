;;;; ====================================================================================
;;;; Ficheiro: jogo.lisp
;;;; Descrição: Interface com o utilizador, gestão de ficheiros e função Main.
;;;; Autores: Gonçalo Barracha 202200187, Rodrigo Cardoso 202200197
;;;; ====================================================================================

(defparameter *caminho-log* "log.dat")

(load "algoritmo.lisp")
(load "puzzle.lisp")

;;; ====================================================================================
;;; UTILITÁRIOS DA INTERFACE
;;; ====================================================================================

(defun linha-separadora ()
  "Imprime uma linha de carateres = para separar secções principais no ecrã"
  (format t "============================================~%"))

(defun linha-traco ()
  "Imprime uma linha de traços - para sub-secções ou organização visual"
  (format t "--------------------------------------------~%"))

(defun titulo (texto)
  "Recebe uma string e imprime-a em destaque, rodeada por linhas separadoras"
  (linha-separadora)
  (format t "~A~%" texto)
  (linha-separadora))

(defun subtitulo (texto)
  "Recebe uma string e imprime-a em destaque, rodeada por linhas de hífens"
  (linha-traco)
  (format t "~A~%" texto)
  (linha-traco))

;;; ====================================================================================
;;; IMPRESSÃO DO TABULEIRO
;;; ====================================================================================

(defun imprimir-cabecalho-colunas (col)
  "Função recursiva que imprime os números das colunas (1 a 7) no topo do tabuleiro"
  (when (<= col 7)
    (format t "~D " col)
    (imprimir-cabecalho-colunas (1+ col))))

(defun imprimir-linha-horizontal ()
  "Desenha a moldura superior ou inferior do tabuleiro"
  (format t "    +---------------+~%"))

(defun imprimir-celulas (linha)
  "Função recursiva que percorre cada elemento de uma linha. Se a casa for nil (inválida), imprime um traço -; caso contrário, imprime o valor da casa (0, 1 ou 2)"
  (cond
    ((null linha) (format t "|~%"))
    (t
     (format t "~A "
             (cond ((null (car linha)) "-")
                   (t (car linha))))
     (imprimir-celulas (cdr linha)))))

(defun imprimir-tabuleiro-rec (tabuleiro linha)
  "Função recursiva que percorre as 7 linhas do tabuleiro, imprimindo o número da linha no início de cada uma"
  (when tabuleiro
    (format t "~D   | " linha)
    (imprimir-celulas (car tabuleiro))
    (imprimir-tabuleiro-rec (cdr tabuleiro) (1+ linha))))

(defun imprimir-tabuleiro (tabuleiro)
  "A função principal desta secção. Coordena as funções anteriores para desenhar o tabuleiro completo com coordenadas e molduras"
  (format t "~%      ")
  (imprimir-cabecalho-colunas 1)
  (format t "~%")
  (imprimir-linha-horizontal)
  (imprimir-tabuleiro-rec tabuleiro 1)
  (imprimir-linha-horizontal))

;;; ====================================================================================
;;; MOTOR DE JOGO (COMPUTADOR)
;;; ====================================================================================

(defun escolher-melhor-jogada (sucessores alfa beta tempo-limite inicio melhor)
  "Esta é uma função de suporte que percorre a lista de jogadas possíveis. Para cada jogada, chama o algoritmo negamax para obter a sua pontuação e mantém o registo daquela que tiver o valor mais alto"
  (cond
    ((null sucessores) melhor)
    (t
     (let* ((item (car sucessores))
            (estado-sucessor (second item))
            (valor (- (negamax estado-sucessor
                               4
                               (- beta)
                               (- alfa)
                               tempo-limite
                               inicio))))
       (if (or (null melhor) (>= valor (second melhor)))
           (escolher-melhor-jogada
            (cdr sucessores)
            (max alfa valor)
            beta
            tempo-limite
            inicio
            (list item valor))
           (escolher-melhor-jogada
            (cdr sucessores)
            alfa
            beta
            tempo-limite
            inicio
            melhor))))))

(defun perguntar-continuar ()
  "Apresenta um menu final após o jogo terminar, perguntando se o utilizador quer iniciar uma nova partida ou sair do programa"
  (linha-traco)
  (format t "Deseja jogar outro jogo?~%")
  (format t "  [1] Sim~%")
  (format t "  [2] Não (sair)~%")
  (linha-traco)
  (format t "Opção: ")
  (read)
)

(defun jogar (estado tempo-ms)
  "Calcula o tempo disponível, chama a procura da melhor jogada, guarda as estatísticas (nós, cortes, tempo) no ficheiro log.dat, imprime as estatísticas no ecrã para o utilizador e devolve uma lista com a jogada escolhida e o estado resultante"
  (limpar-memoria)
  (let* ((inicio (get-internal-run-time))
         (tempo-limite (* (/ tempo-ms 1000.0)
                          internal-time-units-per-second))
         (sucessores (sucessores-estado estado)))
    (when sucessores
      (let* ((resultado (escolher-melhor-jogada
                          sucessores
                          -1000000000
                          1000000000
                          tempo-limite
                          inicio
                          nil))
             (melhor-jogada (first resultado))
             (melhor-valor (second resultado))
             (tempo-gasto-ms
              (* (/ (- (get-internal-run-time) inicio)
                    internal-time-units-per-second)
                 1000.0)))
        (with-open-file (stream *caminho-log*
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream
                  "Jogada: ~A | Valor: ~D | Nos: ~D | Cortes Alfa: ~D | Cortes Beta: ~D | Tempo: ~,2f ms~%"
                  (first melhor-jogada)
                  melhor-valor
                  *nos-analisados*
                  *cortes-alfa*
                  *cortes-beta*
                  tempo-gasto-ms))
        (format t "~%Jogada realizada: ~A~%" (first melhor-jogada))
        (subtitulo "ESTATÍSTICAS DA JOGADA")
        (format t "Valor heurístico : ~D~%" melhor-valor)
        (format t "Nos analisados   : ~D~%" *nos-analisados*)
        (format t "Cortes Alfa      : ~D~%" *cortes-alfa*)
        (format t "Cortes Beta      : ~D~%" *cortes-beta*)
        (format t "Tempo gasto      : ~,2f ms~%" tempo-gasto-ms)

        melhor-jogada))))

;;; ====================================================================================
;;; INTERAÇÃO HUMANA
;;; ====================================================================================

(defun ler-jogada-humano (estado)
  "Pede ao utilizador para introduzir uma jogada no teclado e valida se o input é um movimento legal comparando-o com a lista de sucessores gerada pelo motor do jogo"
  (let ((sucessores (sucessores-estado estado)))
    (if (null sucessores)
        nil
        (progn
          (format t "~%Introduza a sua jogada~%")
          (format t "Formato: (movimento linha coluna)~%")
          (format t "Exemplo: (b 2 3)~%> ")
          (let* ((linha (read-line))
                 (input (ignore-errors (read-from-string linha)))
                 (jogada (and input
                              (find-if (lambda (item)
                                         (equal input (first item)))
                                       sucessores))))
            (if jogada
                jogada
                (progn
                  (format t "Jogada inválida!~%")
                  (ler-jogada-humano estado))))))))

;;; ====================================================================================
;;; CICLO PRINCIPAL
;;; ====================================================================================

(defun ciclo-jogo (estado tipo-j1 tipo-j2 tempo-limite)
  "Imprime o tabuleiro, verifica se o jogo terminou e anuncia o vencedor, alterna as jogadas entre Humanos e Computador conforme os tipos definidos e atualiza o estado do jogo com a nova jogada"
  (loop
    (titulo "TABULEIRO ATUAL")
    (imprimir-tabuleiro (estado-tabuleiro estado))

    (subtitulo
     (format nil "TURNO DO JOGADOR ~D (~A)"
             (estado-jogador estado)
             (if (= (estado-jogador estado) 1) tipo-j1 tipo-j2)))

    (when (estado-terminal-p estado)
      (titulo "FIM DE JOGO")
      (format t "Vencedor: Jogador ~D~%" (outro-jogador (estado-jogador estado)))
      (format t "~%Resultado guardado em log.dat~%")
      (return))

    (let ((resultado
           (if (or (and (= (estado-jogador estado) 1) (eq tipo-j1 'humano))
                   (and (= (estado-jogador estado) 2) (eq tipo-j2 'humano)))
               (ler-jogada-humano estado)
               (progn
                 (format t "O computador está a pensar...~%")
                 (jogar estado tempo-limite)))))

      (unless resultado (return))
      (setf estado (second resultado)))))

;;; ====================================================================================
;;; MENU PRINCIPAL
;;; ====================================================================================

(defun iniciar-jogo ()
 "É a função Main. Gere o menu inicial onde o utilizador escolhe o modo de jogo (Humano vs Computador ou Computador vs Computador) e define o tempo limite de resposta do Computador. Define também o tabuleiro inicial com as 6 peças de cada jogador nas posições corretas"
  (loop
    (titulo "SOLITÁRIO 2 – IA 2025/2026")

    (format t "[1] Humano vs Computador~%")
    (format t "[2] Computador vs Computador~%")
    (linha-traco)
    (format t "Opção: ")

    (let ((opcao (read)))
      (cond
        ((= opcao 1)
         (format t "Quem começa? [1] Humano  [2] Computador~%> ")
         (let ((quem (read)))
           (format t "Tempo limite (ms):~%> ")
           (let ((tempo (read)))
             (let ((tabuleiro-inicial
                    '((nil nil 1 1 1 nil nil)
                      (nil nil 1 1 1 nil nil)
                      (0 0 0 0 0 0 0)
                      (0 0 0 0 0 0 0)
                      (0 0 0 0 0 0 0)
                      (nil nil 2 2 2 nil nil)
                      (nil nil 2 2 2 nil nil))))
               (if (= quem 1)
                   (ciclo-jogo (list tabuleiro-inicial 1)
                               'humano 'computador tempo)
                   (ciclo-jogo (list tabuleiro-inicial 1)
                               'computador 'humano tempo))))))

        ((= opcao 2)
         (format t "Tempo limite para os PCs (ms):~%> ")
         (let ((tempo (read))
               (tabuleiro-inicial
                '((nil nil 1 1 1 nil nil)
                  (nil nil 1 1 1 nil nil)
                  (0 0 0 0 0 0 0)
                  (0 0 0 0 0 0 0)
                  (0 0 0 0 0 0 0)
                  (nil nil 2 2 2 nil nil)
                  (nil nil 2 2 2 nil nil))))
           (ciclo-jogo (list tabuleiro-inicial 1)
                       'computador 'computador tempo)))

        (t
         (format t "Opção inválida.~%"))))
    (when (= (perguntar-continuar) 2)
      (format t "~%A terminar programa... Até à próxima!~%")
      (return))))
