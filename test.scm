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
       (mecab-sparse-tostr m "��Ϻ�ϼ�Ϻ�����äƤ����ܤ�ֻҤ��Ϥ�����"))
(test* "mecab-strerror" #t (string? (mecab-strerror m)))

(define m (mecab-new2 ""))
(test* "mecab-sparse-tostr"
       "��Ϻ	̾��,��̾,*,*,��Ϻ,����,*\n\
        ��	����,������,*,*,��,��,*\n\
        ��Ϻ	̾��,��̾,*,*,��Ϻ,����,*\n\
        ��	����,�ʽ���,*,*,��,��,*\n\
        ���ä�	ư��,*,�Ҳ�ư�쥿��,����Ϣ�ѥƷ�,����,��ä�,��ɽɽ��:����\n\
        ����	������,ư����������,�첻ư��,���ܷ�,����,����,*\n\
        ��	̾��,����̾��,*,*,��,�ۤ�,�����ɤ�:�� ��ɽɽ��:��\n\
        ��	����,�ʽ���,*,*,��,��,*\n\
        �ֻ�	̾��,��̾,*,*,�ֻ�,�Ϥʤ�,*\n\
        ��	����,�ʽ���,*,*,��,��,*\n\
        �Ϥ���	ư��,*,�Ҳ�ư�쥵��,����,�Ϥ�,�錄����,��°ư�����ʴ��ܡ� ��ɽɽ��:�Ϥ�\n\
        ��	�ü�,����,*,*,��,��,*\n\
        EOS\n"
       (mecab-sparse-tostr m "��Ϻ�ϼ�Ϻ�����äƤ����ܤ�ֻҤ��Ϥ�����"))
                            
(mecab-destroy m)

(test-end)
