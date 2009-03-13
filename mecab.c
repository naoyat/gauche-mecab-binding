/*
 * mecab.c
 *
 *  2009.3.13 by naoya_t
 *
 */

#include <gauche.h>
#include <gauche/extend.h>

#include <mecab.h>
#include "mecab.h"

//ScmClass *Scm_MeCabClass;
// mecab_t
mecab_t* unwrap_mecab_t(ScmObj obj)
{
  return SCM_MECAB(obj)->m;
}
ScmObj wrap_mecab_t(mecab_t *m)
{
  ScmMeCab *obj = SCM_NEW(ScmMeCab);
  SCM_SET_CLASS(obj, SCM_CLASS_MECAB);
  obj->m = m;
  return SCM_OBJ(obj);
}

// mecab_node_t
const mecab_node_t* unwrap_mecab_node_t(ScmObj obj)
{
  return SCM_MECAB_NODE(obj)->mn;
}
ScmObj wrap_mecab_node_t(const mecab_node_t *mn)
{
  ScmMeCabNode *obj = SCM_NEW(ScmMeCabNode);
  SCM_SET_CLASS(obj, SCM_CLASS_MECAB_NODE);
  obj->mn = mn;
  return SCM_OBJ(obj);
}

// mecab_dictionary_info_t
const mecab_dictionary_info_t* unwrap_mecab_dictionary_info_t(ScmObj obj)
{
  return SCM_MECAB_DICTIONARY_INFO(obj)->mdi;
}
ScmObj wrap_mecab_dictionary_info_t(const mecab_dictionary_info_t *mdi)
{
  ScmMeCabDictionaryInfo *obj = SCM_NEW(ScmMeCabDictionaryInfo);
  SCM_SET_CLASS(obj, SCM_CLASS_MECAB_DICTIONARY_INFO);
  obj->mdi = mdi;
  return SCM_OBJ(obj);
}

/* APIs with (int argc, char **argv) */
#define mecab_call_func(result_type,fn,args) do{  \
  result_type result;         \
  if (SCM_NULLP(args)) {      \
    char *argv[] = {""};      \
    result = (fn)(1,argv);    \
  } else {                    \
    int argc, i=0;              \
    ScmObj argl;                \
    char **argv = NULL;         \
    if (SCM_INTEGERP(Scm_Car(args))) {                              \
      argc = SCM_INT_VALUE(Scm_Car(args)); argl = Scm_Cadr(args);   \
    } else {                                                        \
      argc = 1 + Scm_Length(args); i++; argl = args;                \
    }                                                               \
    argv = (char**)malloc(sizeof(char*) * argc);                    \
    if (i) argv[0] = "";                                                \
    if (argv) {                                                         \
      if (SCM_VECTORP(argl)) {                                          \
        for (;i<argc;i++)                                        \
          argv[i] = (char *)Scm_GetStringConst((ScmString *)SCM_VECTOR_ELEMENT(argl,i)); \
      } else {                                                          \
        for (;i<argc && !SCM_NULLP(argl); argl=Scm_Cdr(argl),i++) \
          argv[i] = (char *)Scm_GetStringConst((ScmString *)Scm_Car(argl)); \
      }                                                                 \
      result = (fn)(argc,argv);                                         \
    }                                                                   \
    free((void *)argv);                                                 \
  }                                                                     \
  return result;                                                        \
} while(0)

mecab_t *mecab_call_mecab_func(mecab_func_with_args fn, ScmObj args)
{
  mecab_call_func(mecab_t*,fn,args);
}
int mecab_call_int_func(int_func_with_args fn, ScmObj args)
{
  mecab_call_func(int,fn,args);
}

/*
static void MeCab_print(ScmObj obj, ScmPort *out, ScmWriteContext *ctx)
{
  ScmMeCab *m = SCM_MECAB(obj);//SCM_MECAB_UNBOX(obj);
  //  const char *queue_name = q->getName().c_str();
  Scm_Printf(out, "#<<mecab> 0x%x>", m->m);
}

static void MeCab_cleanup(ScmObj obj)
{
  ScmMeCab *m = SCM_MECAB(obj);
  if (m->m) {
    mecab_destroy(m->m);
    m->m = NULL;
  }
}
*/

/*
 * Module initialization function.
 */
extern void Scm_Init_mecablib(ScmModule*);

void Scm_Init_mecab(void)
{
    ScmModule *mod;

    /* Register this DSO to Gauche */
    SCM_INIT_EXTENSION(mecab);

    /* Create the module if it doesn't exist yet. */
    mod = SCM_MODULE(SCM_FIND_MODULE("mecab", TRUE));
    /*
    Scm_MeCabClass =
        Scm_MakeForeignPointerClass(mod, "<mecab>",
                                    MeCab_print,
                                    MeCab_cleanup,
                                    SCM_FOREIGN_POINTER_KEEP_IDENTITY|SCM_FOREIGN_POINTER_MAP_NULL);
    */
    /* Register stub-generated procedures */
    Scm_Init_mecablib(mod);
}
