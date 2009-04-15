;; -*- coding:euc-jp -*-
;;
;; test for mecab module
;;

(use gauche.test)

(test-start "mecab")
(use text.mecab)
(test-module 'text.mecab)

(define m (mecab-new2 ""))
(test* "mecab-new2" #t (is-a? m <mecab>))
(test* "mecab-destroy" #f (mecab-destroyed? m))
(mecab-destroy m)
(test* "mecab-destroy" #t (mecab-destroyed? m))

(test* "mecab-sparse-tostr" #f
       (mecab-sparse-tostr m "太郎は次郎が持っている本を花子に渡した。"))
(test* "mecab-strerror" #t (string? (mecab-strerror m)))

(define m (mecab-new2 ""))
(test* "mecab-sparse-tostr"
       "太郎	名詞,人名,*,*,太郎,たろう,*\n\
        は	助詞,副助詞,*,*,は,は,*\n\
        次郎	名詞,人名,*,*,次郎,じろう,*\n\
        が	助詞,格助詞,*,*,が,が,*\n\
        持って	動詞,*,子音動詞タ行,タ系連用テ形,持つ,もって,代表表記:持つ\n\
        いる	接尾辞,動詞性接尾辞,母音動詞,基本形,いる,いる,*\n\
        本	名詞,普通名詞,*,*,本,ほん,漢字読み:音 代表表記:本\n\
        を	助詞,格助詞,*,*,を,を,*\n\
        花子	名詞,人名,*,*,花子,はなこ,*\n\
        に	助詞,格助詞,*,*,に,に,*\n\
        渡した	動詞,*,子音動詞サ行,タ形,渡す,わたした,付属動詞候補（基本） 代表表記:渡す\n\
        。	特殊,句点,*,*,。,。,*\n\
        EOS\n"
       (mecab-sparse-tostr m "太郎は次郎が持っている本を花子に渡した。"))
                            
(mecab-destroy m)

(test-end)
