;; -*- coding:euc-jp -*-
;;
;; test for mecab module
;;

(use gauche.test)

(test-start "mecab")
(use text.mecab)
(test-module 'text.mecab)

(test-section "naoya_t")
;;
;; primitive things
;;
(test-section "[gauche] write-object")
(let1 mecab (mecab-new2 "")
  (test* "display" "#<mecab>" (with-output-to-string (lambda () (display mecab)))))

(test-section "[gauche] reader-ctor")
(let1 mecab #,(<mecab> "") ;; with reader-ctor
  (test* "#,(<mecab> \"\")" #t (mecab? mecab))
  (mecab-destroy mecab))
(let1 mecab #,(<mecab> "-Ochasen") ;; with reader-ctor
  (test* "#,(<mecab> \"-Ochasen\")" #t (mecab? mecab))
  (mecab-destroy mecab))

(let* ([m (mecab-new2 "")]
       [node (mecab-sparse-tonode m "")]
       [dinfo (mecab-dictionary-info m)])
  (test-section "[gauche] mecab?")
  (test* "<mecab>" #t (mecab? m))
  (test* "<mecab-node>" #f (mecab? node))
  (test* "<mecab-dictionary-info>" #f (mecab? dinfo))
  (test* "#f" #f (mecab? #f))

  (test-section "[gauche] mecab-node?")
  (test* "<mecab>" #f (mecab-node? m))
  (test* "<mecab-node>" #t (mecab-node? node))
  (test* "<mecab-dictionary-info>" #f (mecab-node? dinfo))
  (test* "#f" #f (mecab-node? #f))

  (test-section "[gauche] mecab-dictionary-info?")
  (test* "<mecab>" #f (mecab-dictionary-info? m))
  (test* "<mecab-node>" #f (mecab-dictionary-info? node))
  (test* "<mecab-dictionary-info>" #t (mecab-dictionary-info? dinfo))
  (test* "#f" #f (mecab-dictionary-info? #f))

  (mecab-destroy m))

(test-section "mecab-new")
(let1 m (mecab-new '())
  (test* "is-a? <mecab>" #t (is-a? m <mecab>))
  (test* "mecab?" #t (mecab? m))

  (test-section "mecab-destroy")
  (test* "mecab-destroyed?" #f (mecab-destroyed? m))
  (mecab-destroy m)
  (test* "mecab-destroyed?" #t (mecab-destroyed? m))
  )

(test-section "mecab-new2")
(let1 m (mecab-new2 "")
  (test* "is-a? <mecab>" #t (is-a? m <mecab>))
  (test* "mecab?" #t (mecab? m))
  (mecab-destroy m))

(test-section "mecab-version")
(test* "mecab-version" "0.98pre1" (mecab-version))

(test-section "mecab-strerror")

(mecab-new2 "")
(test* "at mecab-new2 (ok)" "" (mecab-strerror #f))

(mecab-new2 "-d //")
;; "tagger.cpp(149) [load_dictionary_resource(param)] param.cpp(71) [ifs] no such file or directory:  //dicrc"
(test* "at mecab-new (err)" #f (string=? "" (mecab-strerror #f)))

(let1 m (mecab-new2 "")
  (mecab-sparse-tostr m "空が青い。")
  (test* "noerr" "" (mecab-strerror m))
  (mecab-destroy m))

(let1 m (mecab-new2 "")
  (test-section "mecab-sparse-tostr")
  (test* "空が青い。"
         (string-join '("空\t名詞,一般,*,*,*,*,空,ソラ,ソラ"
                        "が\t助詞,格助詞,一般,*,*,*,が,ガ,ガ"
                        "青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ"
                        "。\t記号,句点,*,*,*,*,。,。,。"
                        "EOS"
                        "") "\n")
         (mecab-sparse-tostr m "空が青い。"))

  (test-section "mecab-sparse-tostr2")
  (test* "\"空が青い。\", len=6"
         (string-join '("空\t名詞,一般,*,*,*,*,空,ソラ,ソラ"
                        "が\t助詞,格助詞,一般,*,*,*,が,ガ,ガ"
                        "EOS"
                        "") "\n")
         (mecab-sparse-tostr2 m "空が青い。" 6))

  (test-section "mecab-sparse-tonode, mecab-node-***")
  (let1 node (mecab-sparse-tonode m "空が青い。")
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "no previous node" #f (mecab-node-prev node))
    (test* "next node" #t (mecab-node? (mecab-node-next node)))
    (test* "enext" #f (mecab-node? (mecab-node-enext node)))
    (test* "bnext" #f (mecab-node? (mecab-node-bnext node)))
    (test* "surface" "" (mecab-node-surface node))
    (test* "feature" "BOS/EOS,*,*,*,*,*,*,*,*" (mecab-node-feature node))
    (test* "length" 0 (mecab-node-length node))
    (test* "rlength" 0 (mecab-node-rlength node))
    (test* "id" 0 (mecab-node-id node))
    (test* "rc-attr" 0 (mecab-node-rc-attr node))
    (test* "lc-attr" 0 (mecab-node-lc-attr node))
    (test* "posid" 0 (mecab-node-posid node))
    (test* "char-type" 0 (mecab-node-char-type node))
    (test* "stat" 'mecab-bos-node (mecab-node-stat node))
    (test* "best?" #t (mecab-node-best? node))
    (test* "alpha" 0.0 (mecab-node-alpha node))
    (test* "beta" 0.0 (mecab-node-beta node))
    (test* "prob" 0.0 (mecab-node-prob node))
    (test* "wcost" 0 (mecab-node-wcost node))
    (test* "cost" 0 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "previous node" #t (mecab-node? (mecab-node-prev node)))
    (test* "next node" #t (mecab-node? (mecab-node-next node)))
    (test* "enext" #t (mecab-node? (mecab-node-enext node)))
    (test* "bnext" #f (mecab-node? (mecab-node-bnext node)))
    (test* "surface" "空" (mecab-node-surface node))
    (test* "feature" "名詞,一般,*,*,*,*,空,ソラ,ソラ" (mecab-node-feature node))
    (test* "length" 3 (mecab-node-length node))
    (test* "rlength" 3 (mecab-node-rlength node))
    (test* "id" 1 (mecab-node-id node))
    (test* "rc-attr" 1285 (mecab-node-rc-attr node))
    (test* "lc-attr" 1285 (mecab-node-lc-attr node))
    (test* "posid" 38 (mecab-node-posid node))
    (test* "char-type" 2 (mecab-node-char-type node))
    (test* "stat" 'mecab-nor-node (mecab-node-stat node))
    (test* "best?" #t (mecab-node-best? node))
    (test* "alpha" 0.0 (mecab-node-alpha node))
    (test* "beta" 0.0 (mecab-node-beta node))
    (test* "prob" 0.0 (mecab-node-prob node))
    (test* "wcost" 7439 (mecab-node-wcost node))
    (test* "cost" 7156 (mecab-node-cost node))
    )

  (test-section "mecab-sparse-tonode2")
  (let1 node (mecab-sparse-tonode2 m "空が青い。" 6)
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "feature" "BOS/EOS,*,*,*,*,*,*,*,*" (mecab-node-feature node))
    (test* "stat" 'mecab-bos-node (mecab-node-stat node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "surface" "空" (mecab-node-surface node))
    (test* "feature" "名詞,一般,*,*,*,*,空,ソラ,ソラ" (mecab-node-feature node))
    (test* "stat" 'mecab-nor-node (mecab-node-stat node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "surface" "が" (mecab-node-surface node))
    (test* "feature" "助詞,格助詞,一般,*,*,*,が,ガ,ガ" (mecab-node-feature node))
    (test* "stat" 'mecab-nor-node (mecab-node-stat node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "feature" "BOS/EOS,*,*,*,*,*,*,*,*" (mecab-node-feature node))
    (test* "stat" 'mecab-eos-node (mecab-node-stat node))
    (test* "no next node" #f (mecab-node-next node))
    )
;  (test-section "mecab-format-node")
;  (let1 node (mecab-sparse-tonode m "空が青い。")
;   (test* "BOS" "" (mecab-format-node mecab node)))
  (mecab-destroy m))

(let ([m (mecab-new2 "-l 1")] ;;
      [input "空が青い。"])
  (test-section "mecab-nbest-sparse-tostr")
  (test* #`",|input|, N=1"
         "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-sparse-tostr m 1 input))
  (test* #`",|input|, N=2"
         (string-append
          "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
          "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
          )
         (mecab-nbest-sparse-tostr m 2 input))
  (test* #`",|input|, N=3"
         (string-append
          "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
          "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
          "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
          )
         (mecab-nbest-sparse-tostr m 3 input))

  (test-section "mecab-nbest-sparse-tostr2")
  (test* #`",|input|, N=1"
         "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
         (mecab-nbest-sparse-tostr2 m 1 input 6))
  (test* #`",|input|, N=2"
         (string-append
          "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
          "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
          )
         (mecab-nbest-sparse-tostr2 m 2 input 6))
  (test* #`",|input|, N=3"
         (string-append
          "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
          "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
          "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
          )
         (mecab-nbest-sparse-tostr2 m 3 input 6))

  (test-section "mecab-nbest-init")
  (test* "init" 1 (mecab-nbest-init m input))
  (test-section "mecab-nbest-next-tostr")
  (test* "#1"
        "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
        (mecab-nbest-next-tostr m))
  (test* "#2"
        "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
        (mecab-nbest-next-tostr m))
  (test* "#3"
        "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
        (mecab-nbest-next-tostr m))
  (test* "#4"
         "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,接続助詞,*,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (test* "#5"
         "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青\t形容詞,自立,*,*,形容詞・アウオ段,ガル接続,青い,アオ,アオ\nい\t動詞,非自立,*,*,一段,連用形,いる,イ,イ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (test* "#6"
         "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,接続助詞,*,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (test* "#7"
         "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青\t形容詞,自立,*,*,形容詞・アウオ段,ガル接続,青い,アオ,アオ\nい\t動詞,非自立,*,*,一段,連用形,いる,イ,イ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (test* "#8"
         "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t接続詞,*,*,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (test* "#9"
         "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t助詞,接続助詞,*,*,*,*,が,ガ,ガ\n青い\t形容詞,自立,*,*,形容詞・アウオ段,基本形,青い,アオイ,アオイ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (test* "#10"
         "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\n青\t形容詞,自立,*,*,形容詞・アウオ段,ガル接続,青い,アオ,アオ\nい\t動詞,非自立,*,*,一段,連用形,いる,イ,イ\n。\t記号,句点,*,*,*,*,。,。,。\nEOS\n"
         (mecab-nbest-next-tostr m))
  (dotimes (i 733)
    (mecab-nbest-next-tostr m))
  (test* "#744"
         "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t動詞,接尾,*,*,五段・ラ行,体言接続特殊２,がる,ガ,ガ\n青\t名詞,固有名詞,地域,一般,*,*,青,アオ,アオ\nい\t動詞,非自立,*,*,一段,未然形,いる,イ,イ\n。\t名詞,サ変接続,*,*,*,*,*\nEOS\n"
         (mecab-nbest-next-tostr m))
  ;; no more results...
  (test* "#745" #f (mecab-nbest-next-tostr m))
  (test* "mecab-strerror" #f (string=? "" (mecab-strerror m)))
  
  (test-section "mecab-nbest-init2")
  (test* "init2" 1 (mecab-nbest-init2 m input 6))
  (test* "#1"
        "空\t名詞,一般,*,*,*,*,空,ソラ,ソラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
        (mecab-nbest-next-tostr m))
  (test* "#2"
        "空\t名詞,一般,*,*,*,*,空,カラ,カラ\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
        (mecab-nbest-next-tostr m))
  (test* "#3"
        "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t助詞,格助詞,一般,*,*,*,が,ガ,ガ\nEOS\n"
        (mecab-nbest-next-tostr m))
  (dotimes (i 8) (mecab-nbest-next-tostr m))
  (test* "#12"
         "空\t名詞,一般,*,*,*,*,空,クウ,クー\nが\t動詞,接尾,*,*,五段・ラ行,体言接続特殊２,がる,ガ,ガ\nEOS\n"
         (mecab-nbest-next-tostr m))
  ;; no more results...
  (test* "#13" #f (mecab-nbest-next-tostr m))
  (test* "mecab-strerror" #f (string=? "" (mecab-strerror m)))

  (test-section "mecab-nbest-next-tonode")
  (mecab-nbest-init m input)
  (test* "#1" #t (mecab-node? (mecab-nbest-next-tonode m)))
  (dotimes (i 742) (mecab-nbest-next-tonode m))
  (test* "#744" #t (mecab-node? (mecab-nbest-next-tonode m))); EOS
  ;; no more results...
  (test* "#745" #f (mecab-node? (mecab-nbest-next-tonode m)))
  (test* "mecab-strerror" #f (string=? "" (mecab-strerror m)))

  (mecab-destroy m))

;;
;; these values below may differ !!!
(test-section "mecab-dictionary-info, mecab-dictionary-info-***")
(let* ([m (mecab-new2 "")]
       [dinfo (mecab-dictionary-info m)])
  (test* "mecab-dictionary-info?" #t (mecab-dictionary-info? dinfo))
  (test* "mecab-dictionary-info-filename"
         "/usr/local/lib/mecab/dic/ipadic/sys.dic" (mecab-dictionary-info-filename dinfo))
  (test* "mecab-dictionary-info-charset"
         "utf8" (mecab-dictionary-info-charset dinfo))
  (test* "mecab-dictionary-info-size"
         392126 (mecab-dictionary-info-size dinfo))
  (test* "mecab-dictionary-info-type" 'mecab-sys-dic (mecab-dictionary-info-type dinfo))
  (test* "mecab-dictionary-info-lsize"
         1316 (mecab-dictionary-info-lsize dinfo))
  (test* "mecab-dictionary-info-rsize"
         1316 (mecab-dictionary-info-rsize dinfo))
  (test* "mecab-dictionary-info-version"
         102 (mecab-dictionary-info-version dinfo))
;  (let1 next-dinfo (mecab-dictionary-info-next dinfo)
;    (test* "has next?" #t (mecab-dictionary-info? next-dinfo)))
  (mecab-destroy m))

(let1 m (mecab-new2 "")
  (test-section "mecab-get[set]-partial: 部分解析の現在のモード(0/1)")
  (test* "default partial mode" 0 (mecab-get-partial m))
  (mecab-set-partial m 1)
  (test* "set to 1" 1 (mecab-get-partial m))
  (mecab-set-partial m 0)
  (test* "set to 0" 0 (mecab-get-partial m))

  (test-section "mecab-get[set]-theta: ソフト分かち書きの温度パラメータ")
  (test* "default theta" 0.75 (mecab-get-theta m))
  (mecab-set-theta m 1.0)
  (test* "set to 1.0" 1.0 (mecab-get-theta m))
  (mecab-set-theta m 0.5)
  (test* "set to 0.5" 0.5 (mecab-get-theta m))

  (test-section "mecab-get[set]-lattice-level: ラティスレベル (0/1/2)")
  (test* "default lattice level" 0 (mecab-get-lattice-level m))
  (mecab-set-lattice-level m 1)
  (test* "set to 1" 1 (mecab-get-lattice-level m))
  (mecab-set-lattice-level m 2)
  (test* "set to 2" 2 (mecab-get-lattice-level m))
  (mecab-set-lattice-level m 0)
  (test* "set to 0" 0 (mecab-get-lattice-level m))

  (test-section "mecab-get[set]-all-morphs: 出力モード(0/1)")
  (test* "default all-morphs" 0 (mecab-get-all-morphs m))
  (mecab-set-all-morphs m 1)
  (test* "set to 1" 1 (mecab-get-all-morphs m))
  (mecab-set-all-morphs m 0)
  (test* "set to 0" 0 (mecab-get-all-morphs m))
  )

;;;;;;;;;;
;;
;; TO DO
;;
;;(test-section "mecab-do")
;;(test-section "mecab-dict-index")
;;(test-section "mecab-dict-gen")
;;(test-section "mecab-cost-train")
;;(test-section "mecab-system-eval")
;;(test-section "mecab-test-gen")

;;;
;;; tagger (message passing)
;;;
(test-section "tagger")
(let1 tagger (mecab-tagger "")
  (test* "tagger'parse-to-string"
         (string-join '("今日\t名詞,副詞可能,*,*,*,*,今日,キョウ,キョー"
                        "も\t助詞,係助詞,*,*,*,*,も,モ,モ"
                        "し\t動詞,自立,*,*,サ変・スル,未然形,する,シ,シ"
                        "ない\t助動詞,*,*,*,特殊・ナイ,基本形,ない,ナイ,ナイ"
                        "と\t助詞,接続助詞,*,*,*,*,と,ト,ト"
                        "ね\t助詞,終助詞,*,*,*,*,ね,ネ,ネ"
                        "EOS"
                        "") "\n")
         ([tagger'parse-to-string] "今日もしないとね"))

  (let1 node ([tagger'parse-to-node] "今日もしないとね")
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "" (mecab-node-surface node))
    (test* "mecab-node-feature" "BOS/EOS,*,*,*,*,*,*,*,*" (mecab-node-feature node))
    (test* "mecab-node-cost" 0 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "今日" (mecab-node-surface node))
    (test* "mecab-node-feature" "名詞,副詞可能,*,*,*,*,今日,キョウ,キョー" (mecab-node-feature node))
    (test* "mecab-node-cost" 3947 (mecab-node-cost node))
    ;;(test* "format-node" "" ([tagger'format-node] node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "も" (mecab-node-surface node))
    (test* "mecab-node-feature" "助詞,係助詞,*,*,*,*,も,モ,モ" (mecab-node-feature node))
    (test* "mecab-node-cost" 5553 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "し" (mecab-node-surface node))
    (test* "mecab-node-feature" "動詞,自立,*,*,サ変・スル,未然形,する,シ,シ" (mecab-node-feature node))
    (test* "mecab-node-cost" 11566 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "ない" (mecab-node-surface node))
    (test* "mecab-node-feature" "助動詞,*,*,*,特殊・ナイ,基本形,ない,ナイ,ナイ" (mecab-node-feature node))
    (test* "mecab-node-cost" 3601 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "と" (mecab-node-surface node))
    (test* "mecab-node-feature" "助詞,接続助詞,*,*,*,*,と,ト,ト" (mecab-node-feature node))
    (test* "mecab-node-cost" 4716 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "ね" (mecab-node-surface node))
    (test* "mecab-node-feature" "助詞,終助詞,*,*,*,*,ね,ネ,ネ" (mecab-node-feature node))
    (test* "mecab-node-cost" 10676 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #t (mecab-node? node))
    (test* "mecab-node-surface" "" (mecab-node-surface node))
    (test* "mecab-node-feature" "BOS/EOS,*,*,*,*,*,*,*,*" (mecab-node-feature node))
    (test* "mecab-node-cost" 8292 (mecab-node-cost node))

    (set! node (mecab-node-next node))
    (test* "mecab-node?" #f (mecab-node? node))
    ))

(test-end)
