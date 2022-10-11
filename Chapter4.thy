theory Chapter4
imports "HOL-IMP.ASM"
begin

inductive star :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> bool"  for r where
refl:  "star r x x" |
step:  "r x y \<Longrightarrow> star r y z \<Longrightarrow> star r x z"

lemma star_trans: "star r x y \<Longrightarrow> star r y z \<Longrightarrow> star r x z"
  apply(induction rule: star.induct)
   apply(assumption)
  apply(metis step)
done

text{*
\section*{Chapter 4}

\exercise
Start from the data type of binary trees defined earlier:
*}

(* Proof Automation *)
lemma "\<forall>x. \<exists>y. x=y"
  by auto

lemma "A \<subseteq> B \<inter> C \<Longrightarrow> A \<subseteq> B \<union> C"
  by auto

lemma "\<lbrakk>\<forall>xs \<in> A. \<exists>ys. xs = ys @ ys; us \<in> A\<rbrakk> \<Longrightarrow> \<exists>n. length us = n + n"
  by fastforce

lemma "\<lbrakk> \<forall> x y. T x y \<or> T y x; 
        \<forall> x y. A x y \<and> A y x \<longrightarrow> x = y;
        \<forall> x y. T x y \<longrightarrow> A x y \<rbrakk>
        \<Longrightarrow> \<forall> x y. A x y \<longrightarrow> T x y"
  by blast

lemma "\<lbrakk> xs @ ys = ys @ xs; length xs = length ys \<rbrakk> \<Longrightarrow> xs = ys"
  (* sledgehammer *)
  by (metis append_eq_conv_conj)

lemma "\<lbrakk> (a::nat) \<le> x + b; 2*x < c \<rbrakk> \<Longrightarrow> 2*a + 1 \<le> 2*b + c"
  by arith

lemma "\<lbrakk> (a::nat) \<le> b; b \<le> c; c \<le> d; d \<le> e \<rbrakk> \<Longrightarrow> a \<le> e"
  by(blast intro: le_trans)

thm conjI[OF refl[of "a"] refl[of "b"]]

(*Forward Reasoning with Suc_leD: Suc m \<le> n \<Longrightarrow> m \<le> n*)
lemma "Suc(Suc(Suc a)) \<le> b \<Longrightarrow> a \<le> b"
  by(blast dest: Suc_leD)

inductive ev :: "nat \<Rightarrow> bool" where
ev0: "ev 0" |
evSS: "ev n \<Longrightarrow> ev (Suc (Suc n))"

fun evn :: "nat \<Rightarrow> bool" where
"evn 0 = True" |
"evn (Suc 0) = False" |
"evn (Suc(Suc n)) = evn n"

(* Proof of lemma in forward direction *)
thm evSS[OF evSS[OF ev0]]
(* Proof of lemma in backward direction  *)
lemma "ev(Suc(Suc(Suc(Suc 0))))"
  apply(rule evSS)
  apply(rule evSS)
  apply(rule ev0)
  done

(* Rule induction *)
lemma "ev m \<Longrightarrow> evn m"
  apply(induction rule: ev.induct)
   apply(simp_all)
  done

(* evn.induct sets up three subgoals corresponding to the 3 equations of evn *)
lemma "evn n \<Longrightarrow> ev n"
  apply(induction n rule: evn.induct)
    apply(simp_all add: ev0 evSS)
  done

declare ev.intros[simp,intro]

datatype 'a tree = Tip | Node "'a tree" 'a "'a tree"

text{*
An @{typ "int tree"} is ordered if for every @{term "Node l i r"} in the tree,
@{text l} and @{text r} are ordered
and all values in @{text l} are @{text "< i"}
and all values in @{text r} are @{text "> i"}.
Define a function that returns the elements in a tree and one
the tests if a tree is ordered:
*}

fun set :: "'a tree \<Rightarrow> 'a set"  where
"set Tip = {}" |
"set (Node l v r) = (set l) \<union> {v} \<union> (set r)"

fun ord :: "int tree \<Rightarrow> bool"  where
"ord Tip = True" |
"ord (Node l v r) = ((\<forall>x \<in> set l. x \<le> v) \<and> (\<forall>x \<in> set r. v \<le> x) \<and> ord l \<and> ord r)"

text{* Hint: use quantifiers.

Define a function @{text ins} that inserts an element into an ordered @{typ "int tree"}
while maintaining the order of the tree. If the element is already in the tree, the
same tree should be returned.
*}

fun ins :: "int \<Rightarrow> int tree \<Rightarrow> int tree"  where
"ins x Tip = (Node Tip x Tip)" |
"ins x (Node l v r) = (if x = v then Node l v r
                       else if x < v then Node (ins x l) v r 
                       else Node l v (ins x r))"

text{* Prove correctness of @{const ins}: *}

lemma set_ins [simp]: "set(ins x t) = {x} \<union> set t"
  apply(induction t)
  apply(auto)
  done

theorem ord_ins: "ord t \<Longrightarrow> ord(ins i t)"
  apply(induction t arbitrary: i)
  apply(auto)
  done

text{*
\endexercise

\exercise
Formalize the following definition of palindromes
\begin{itemize}
\item The empty list and a singleton list are palindromes.
\item If @{text xs} is a palindrome, so is @{term "a # xs @ [a]"}.
\end{itemize}
as an inductive predicate
*}

inductive palindrome :: "'a list \<Rightarrow> bool" where
(* your definition/proof here *)

text {* and prove *}

lemma "palindrome xs \<Longrightarrow> rev xs = xs"
(* your definition/proof here *)

text{*
\endexercise

\exercise
We could also have defined @{const star} as follows:
*}

inductive star' :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> bool" for r where
refl': "star' r x x" |
step': "star' r x y \<Longrightarrow> r y z \<Longrightarrow> star' r x z"

text{*
The single @{text r} step is performer after rather than before the @{text star'}
steps. Prove
*}

lemma "star' r x y \<Longrightarrow> star r x y"
(* your definition/proof here *)



lemma "star r x y \<Longrightarrow> star' r x y"
(* your definition/proof here *)

text{*
You may need lemmas. Note that rule induction fails
if the assumption about the inductive predicate
is not the first assumption.
\endexercise

\exercise\label{exe:iter}
Analogous to @{const star}, give an inductive definition of the @{text n}-fold iteration
of a relation @{text r}: @{term "iter r n x y"} should hold if there are @{text x\<^sub>0}, \dots, @{text x\<^sub>n}
such that @{prop"x = x\<^sub>0"}, @{prop"x\<^sub>n = y"} and @{text"r x\<^bsub>i\<^esub> x\<^bsub>i+1\<^esub>"} for
all @{prop"i < n"}:
*}

inductive iter :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> bool" for r where
(* your definition/proof here *)

text{*
Correct and prove the following claim:
*}

lemma "star r x y \<Longrightarrow> iter r n x y"
(* your definition/proof here *)

text{*
\endexercise

\exercise\label{exe:cfg}
A context-free grammar can be seen as an inductive definition where each
nonterminal $A$ is an inductively defined predicate on lists of terminal
symbols: $A(w)$ mans that $w$ is in the language generated by $A$.
For example, the production $S \to aSb$ can be viewed as the implication
@{prop"S w \<Longrightarrow> S (a # w @ [b])"} where @{text a} and @{text b} are terminal symbols,
i.e., elements of some alphabet. The alphabet can be defined as a datatype:
*}

datatype alpha = a | b

text{*
If you think of @{const a} and @{const b} as ``@{text "("}'' and  ``@{text ")"}'',
the following two grammars both generate strings of balanced parentheses
(where $\varepsilon$ is the empty word):
\[
\begin{array}{r@ {\quad}c@ {\quad}l}
S &\to& \varepsilon \quad\mid\quad aSb \quad\mid\quad SS \\
T &\to& \varepsilon \quad\mid\quad TaTb
\end{array}
\]
Define them as inductive predicates and prove their equivalence:
*}

inductive S :: "alpha list \<Rightarrow> bool" where
(* your definition/proof here *)

inductive T :: "alpha list \<Rightarrow> bool" where
(* your definition/proof here *)

lemma TS: "T w \<Longrightarrow> S w"
(* your definition/proof here *)



lemma ST: "S w \<Longrightarrow> T w"
(* your definition/proof here *)

corollary SeqT: "S w \<longleftrightarrow> T w"
(* your definition/proof here *)

text{*
\endexercise
*}
(* your definition/proof here *)
text{*
\exercise
In Chapter 3 we defined a recursive evaluation function
@{text "aval ::"} @{typ "aexp \<Rightarrow> state \<Rightarrow> val"}.
Define an inductive evaluation predicate and prove that it agrees with
the recursive function:
*}

inductive aval_rel :: "aexp \<Rightarrow> state \<Rightarrow> val \<Rightarrow> bool" where
(* your definition/proof here *)

lemma aval_rel_aval: "aval_rel a s v \<Longrightarrow> aval a s = v"
(* your definition/proof here *)

lemma aval_aval_rel: "aval a s = v \<Longrightarrow> aval_rel a s v"
(* your definition/proof here *)

corollary "aval_rel a s v \<longleftrightarrow> aval a s = v"
(* your definition/proof here *)

text{*
\endexercise

\exercise
Consider the stack machine from Chapter~3
and recall the concept of \concept{stack underflow}
from Exercise~\ref{exe:stack-underflow}.
Define an inductive predicate
*}

inductive ok :: "nat \<Rightarrow> instr list \<Rightarrow> nat \<Rightarrow> bool" where
(* your definition/proof here *)

text{*
such that @{text "ok n is n'"} means that with any initial stack of length
@{text n} the instructions @{text "is"} can be executed
without stack underflow and that the final stack has length @{text n'}.

Using the introduction rules for @{const ok},
prove the following special cases: *}

lemma "ok 0 [LOAD x] (Suc 0)"
(* your definition/proof here *)

lemma "ok 0 [LOAD x, LOADI v, ADD] (Suc 0)"
(* your definition/proof here *)

lemma "ok (Suc (Suc 0)) [LOAD x, ADD, ADD, LOAD y] (Suc (Suc 0))"
(* your definition/proof here *)

text {* Prove that @{text ok} correctly computes the final stack size: *}

lemma "\<lbrakk>ok n is n'; length stk = n\<rbrakk> \<Longrightarrow> length (exec is s stk) = n'"
(* your definition/proof here *)

text {*
Lemma @{thm [source] length_Suc_conv} may come in handy.

Prove that instruction sequences generated by @{text comp}
cannot cause stack underflow: \ @{text "ok n (comp a) ?"} \ for
some suitable value of @{text "?"}.
\endexercise
*}


end

