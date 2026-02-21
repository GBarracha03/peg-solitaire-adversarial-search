;;;; ====================================================================================
;;;; Ficheiro: algoritmo.lisp
;;;; Descrição: Negamax com Cortes Alfa-Beta, Memoização, Ordenação e Procura Quiescente.
;;;; Autores: Gonçalo Barracha 202200187, Rodrigo Cardoso 202200197
;;;; ====================================================================================

;;; ------------------------------------------------------------------------------------
;;; MEMOIZAÇÃO
;;; ------------------------------------------------------------------------------------

(defparameter *tabela-transposicao* (make-hash-table :test 'equal))
(defparameter *nos-analisados* 0)
(defparameter *cortes-alfa* 0)
(defparameter *cortes-beta* 0)

(defun limpar-memoria ()
  "Função que reinicia a tabela de hash e os contadores de estatísticas antes de cada nova jogada do computador"
  (clrhash *tabela-transposicao*)
  (setf *nos-analisados* 0
        *cortes-alfa* 0
        *cortes-beta* 0))

(defun guardar-estado (estado profundidade valor)
  "Guarda o valor de um estado na tabela de hash."
  (setf (gethash estado *tabela-transposicao*) (cons profundidade valor)))

(defun recuperar-estado (estado profundidade)
  "Recupera o valor se existir e se a profundidade guardada for suficiente"
  (let ((dados (gethash estado *tabela-transposicao*)))
    (cond ((and dados (>= (car dados) profundidade)) (cdr dados))
          (T nil))))

;;; ------------------------------------------------------------------------------------
;;; ORDENAÇÃO DE NÓS
;;; ------------------------------------------------------------------------------------

(defun e-captura-p (movimento)
  "Verifica se o movimento é uma captura (cd, ce, cc, cb)"
  (member (first movimento) '(cd ce cc cb)))

(defun ordenar-sucessores (lista-sucessores)
  "Reorganiza a lista de jogadas possíveis, colocando as capturas no início da lista."
  (cond ((null lista-sucessores) nil)
        (T (let* ((pivo (car lista-sucessores))
                  (resto (cdr lista-sucessores))
                  (antes (remove-if-not
                          (lambda (x)
                            (and (e-captura-p (first x))
                                 (not (e-captura-p (first pivo)))))
                          resto))
                  (depois (remove-if
                           (lambda (x)
                             (and (e-captura-p (first x))
                                  (not (e-captura-p (first pivo)))))
                           resto)))
             (append (ordenar-sucessores antes)
                     (list pivo)
                     (ordenar-sucessores depois))))))

;;; ------------------------------------------------------------------------------------
;;; PROCURA QUIESCENTE
;;; ------------------------------------------------------------------------------------

(defun filtrar-capturas (sucessores)
  "Seleciona apenas os movimentos de captura de uma lista de sucessores"
  (cond ((null sucessores) nil)
        ((e-captura-p (first (car sucessores)))
         (cons (car sucessores) (filtrar-capturas (cdr sucessores))))
        (T (filtrar-capturas (cdr sucessores)))))

(defun procura-quiescente (estado alfa beta tempo-limite tempo-inicio)
  "Procura por estabilidade após profundidade zero, focando apenas em capturas."
  (let ((val-estatico (avaliar estado)))
    (cond ((> (- (get-internal-run-time) tempo-inicio) tempo-limite) val-estatico)
          ((>= val-estatico beta)
           (setf *cortes-beta* (1+ *cortes-beta*))
       beta)
      (T (let* ((novo-alfa (max alfa val-estatico))
                (capturas (filtrar-capturas (sucessores-estado estado))))
           (cond ((null capturas) novo-alfa)
                 (T (procura-quiescente-lista capturas novo-alfa beta tempo-limite tempo-inicio))))))))

(defun procura-quiescente-lista (lista alfa beta tempo-limite tempo-inicio)
  "Percorre a lista de capturas na procura quiescente."
  (cond ((null lista) alfa)
        (T (let* ((estado-sucessor (second (car lista)))
                  (valor (- (procura-quiescente estado-sucessor (- beta) (- alfa) tempo-limite tempo-inicio))))
             (cond ((>= valor beta)
                (setf *cortes-beta* (1+ *cortes-beta*))
                beta)
                   (T (let ((melhor-alfa (max alfa valor)))
                    (cond ((> melhor-alfa alfa) (setf *cortes-alfa* (1+ *cortes-alfa*))))
                    (procura-quiescente-lista (cdr lista) melhor-alfa beta tempo-limite tempo-inicio))))))))

;;; ------------------------------------------------------------------------------------
;;; ALGORITMO NEGAMAX PRINCIPAL
;;; ------------------------------------------------------------------------------------

(defun negamax (estado profundidade alfa beta tempo-limite tempo-inicio)
  "Negamax com Memoização e estrutura condicional."
  (setf *nos-analisados* (1+ *nos-analisados*))
  (let ((valor-memo (recuperar-estado estado profundidade)))
    (cond ((> (- (get-internal-run-time) tempo-inicio) tempo-limite) (avaliar estado))
          (valor-memo valor-memo)
          ((estado-terminal-p estado)
       (let ((val (avaliar estado)))
         (guardar-estado estado profundidade val)
         val))
      ((= profundidade 0)
       (let ((val (procura-quiescente estado alfa beta tempo-limite tempo-inicio)))
         (guardar-estado estado profundidade val)
         val))
      (T (let ((sucessores (ordenar-sucessores (sucessores-estado estado))))
           (cond ((null sucessores) (avaliar estado))
             (T (let ((resultado (negamax-lista sucessores profundidade alfa beta tempo-limite tempo-inicio)))
                  (guardar-estado estado profundidade resultado)
                  resultado))))))))

(defun negamax-lista (lista profundidade alfa beta tempo-limite tempo-inicio)
  "Itera sobre os sucessores no algoritmo Negamax principal."
  (cond ((null lista) alfa)
        (T (let* ((estado-sucessor (second (car lista)))
                  (valor (- (negamax estado-sucessor (1- profundidade) (- beta) (- alfa) tempo-limite tempo-inicio))))
             (cond ((>= valor beta)
                (setf *cortes-beta* (1+ *cortes-beta*))
                beta)
               (T (let ((novo-alfa (max alfa valor)))
                    (cond ((> novo-alfa alfa) (setf *cortes-alfa* (1+ *cortes-alfa*))))
                    (negamax-lista (cdr lista) profundidade novo-alfa beta tempo-limite tempo-inicio))))))))