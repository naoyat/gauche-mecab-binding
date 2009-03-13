;;;
;;; mecab.scm
;;;
;;;  2009.3.13 by naoya_t
;;;

(define-module mecab
  (export <mecab> <mecab-node> <mecab-dictionary-info>
		  mecab? mecab-node? mecab-dictionary-info?
		  mecab-destroyed?
		  write-object

		  mecab-tagger ; message passing
		  <mecab-tagger> mecab-make-tagger ; class

		  mecab-do
		  mecab-new mecab-new2
		  mecab-version
		  mecab-strerror
		  mecab-destroy

		  mecab-get-partial mecab-set-partial
		  mecab-get-theta mecab-set-theta
		  mecab-get-lattice-level mecab-set-lattice-level
		  mecab-get-all-morphs mecab-set-all-morphs

		  mecab-sparse-tostr mecab-sparse-tostr2 ;; mecab-sparse-tostr3
		  mecab-sparse-tonode mecab-sparse-tonode2
		  mecab-nbest-sparse-tostr mecab-nbest-sparse-tostr2 ;; mecab-nbest-sparse-tostr3
		  mecab-nbest-init mecab-nbest-init2
		  mecab-nbest-next-tostr ;; mecab-nbest-next-tostr2
		  mecab-nbest-next-tonode
		  mecab-format-node
		  mecab-dictionary-info
		  mecab-dict-index mecab-dict-gen
		  mecab-cost-train mecab-system-eval mecab-test-gen

		  mecab-node-prev mecab-node-next mecab-node-enext mecab-node-bnext
		  mecab-node-surface mecab-node-feature
		  mecab-node-length mecab-node-rlength
		  mecab-node-id mecab-node-rc-attr mecab-node-lc-attr
		  mecab-node-posid mecab-node-char-type
		  mecab-node-stat mecab-node-best?
		  mecab-node-alpha mecab-node-beta mecab-node-prob
		  mecab-node-wcost mecab-node-cost

		  mecab-dictionary-info-filename mecab-dictionary-info-charset
		  mecab-dictionary-info-size mecab-dictionary-info-type
		  mecab-dictionary-info-lsize mecab-dictionary-info-rsize
		  mecab-dictionary-info-version mecab-dictionary-info-next
          )
  )

(select-module mecab)

;; Loads extension
(dynamic-load "mecab")

;;
;; Put your Scheme definitions here
;;
(define-macro (mecab? obj) `(is-a? ,obj <mecab>))
(define-macro (mecab-node? obj) `(is-a? ,obj <mecab-node>))
(define-macro (mecab-dictionary-info? obj) `(is-a? ,obj <mecab-dictionary-info>))

(define-method write-object ((m <mecab>) out)
  (format out "#<mecab>")); (mecab-version)))
(define-method write-object ((m <mecab-node>) out)
  (format out "#<mecab-node>"))
(define-method write-object ((m <mecab-dictionary-info>) out)
  (format out "#<mecab-dictionary-info>"))

(define-reader-ctor '<mecab>
  (lambda args (apply mecab-new args)))

(define (mecab-tagger paramstr)
  (let1 mecabobj (mecab-new paramstr)
	;; str を解析して文字列として結果を得ます. len は str の長さ(省略可能)
	(define (parse-to-string str)
	  (mecab-sparse-tostr mecabobj str))
	
	;; str を解析して MeCab::Node 型の形態素を返します. 
	;; この形態素は文頭を示すもので, next を順に辿ることで全形態素にアクセスできます
	(define (parse-to-node str)
	  (mecab-sparse-tonode mecabobj str))

	;; parse の Nbest 版です. N に nbest の個数を指定します.
	;; この機能を使う場合は, 起動時オプションとして -l 1 を指定する必要があります
	(define (parse-nbest n str)
	  (mecab-nbest-sparse-tostr mecabobj n str))
	;; 解析結果を, 確からしいものから順番に取得する場合にこの関数で初期化を行います.
	(define (parse-nbest-init str)
	  (mecab-nbest-init mecabobj str))

	;; parse-nbest-init の後, この関数を順次呼ぶことで,
	;; 確からしい解析結果を, 順番に取得できます. (string)
	(define (next)
	  (mecab-nbest-next-tostr mecabobj))
	;; next() と同じですが, MeCab::Node を返します.
	(define (next-node)
	  (mecab-nbest-next-tonode mecabobj))
	;;
	(define (format-node node)
	  (mecab-format-node mecabobj node))

	(lambda (m)
	  (case m
		[(parse parse-to-string) parse-to-string]
		[(parse-to-node) parse-to-node]
		[(parse-nbest) parse-nbest]
		[(parse-nbest-init) parse-nbest-init]
		[(next) next]
		[(next-node) next-node]
		[(format-node) format-node]
		))))

;;; class
(define-class <mecab-tagger> () (mecab #f))
(define (mecab-make-tagger paramstr)
  (make <mecab-tagger> :mecab (mecab-new2 paramstr)))
(define (tagger-mecab tagger) (slot-ref tagger 'mecab))
(define-method parse ((tagger <mecab-tagger>) (str <string>))
  (mecab-sparse-tostr (tagger-mecab tagger) str))
(define-method parse ((tagger <mecab-tagger>) (str <string>) (len <integer>))
  (mecab-sparse-tostr2 (tagger-mecab tagger) str len))
(define-method parse-to-string ((tagger <mecab-tagger>) (str <string>))
  (mecab-sparse-tostr (tagger-mecab tagger) str))
(define-method parse-to-string ((tagger <mecab-tagger>) (str <string>) (len <integer>))
  (mecab-sparse-tostr (tagger-mecab tagger) str len))
(define-method parse-to-node ((tagger <mecab-tagger>) (str <string>))
  (mecab-sparse-tonode (tagger-mecab tagger) str))
(define-method parse-to-node ((tagger <mecab-tagger>) (str <string>) (len <integer>))
  (mecab-sparse-tonode2 (tagger-mecab tagger) str len))
(define-method parse-nbest ((tagger <mecab-tagger>) (n <integer>) (str <string>))
  (mecab-nbest-sparse-tostr (tagger-mecab tagger) str))
(define-method parse-nbest ((tagger <mecab-tagger>) (n <integer>) (str <string>) (len <integer>))
  (mecab-nbest-sparse-tostr (tagger-mecab tagger) str len))
(define-method parse-nbest-init ((tagger <mecab-tagger>) (str <string>))
  (mecab-nbest-init (tagger-mecab tagger) str))
(define-method parse-nbest-init ((tagger <mecab-tagger>) (str <string>) (len <integer>))
  (mecab-nbest-init (tagger-mecab tagger) str len))
(define-method next ((tagger <mecab-tagger>))
  (mecab-nbest-next-tostr (tagger-mecab tagger)))
(define-method next-node ((tagger <mecab-tagger>))
  (mecab-nbest-next-tonode (tagger-mecab tagger)))
(define-method format-node ((tagger <mecab-tagger>) (node <mecab-node>))
  (mecab-format-node (tagger-mecab tagger) node))

;; Epilogue
(provide "mecab")
