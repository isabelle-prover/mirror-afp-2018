(* Author: Alexander Maletzky *)

theory Module_Type_Class
  imports Main
begin

section \<open>Left-Modules over Rings\<close>

text \<open>In contrast to theory "Module" in "HOL-Algebra", we develop (the very basics of) the theory of
  modules over @{emph \<open>type classes\<close>}.\<close>

locale module_struct =
  fixes smult :: "'r::ring_1 \<Rightarrow> 'm::ab_group_add \<Rightarrow> 'm" (infixl "\<odot>" 75)
  assumes smult_one [simp]: "1 \<odot> v = v"
  assumes smult_assoc [ac_simps]: "(r * s) \<odot> v = r \<odot> (s \<odot> v)"
  assumes smult_distrib_right [algebra_simps]: "(r + s) \<odot> v = r \<odot> v + s \<odot> v"
  assumes smult_distrib_left [algebra_simps]: "r \<odot> (v + u) = r \<odot> v + r \<odot> u"
begin

lemma smult_zero_left [simp]: "0 \<odot> v = 0"
proof -
  have "0 \<odot> v = (0 + 0) \<odot> v" by simp
  also have "... = 0 \<odot> v + 0 \<odot> v" by (rule smult_distrib_right)
  finally show ?thesis by simp
qed

lemma smult_zero_right [simp]: "r \<odot> 0 = 0"
proof -
  have "r \<odot> 0 = r \<odot> (0 + 0)" by simp
  also have "... = r \<odot> 0 + r \<odot> 0" by (rule smult_distrib_left)
  finally show ?thesis by simp
qed

lemma smult_minus_mult_left [simp]: "(- r) \<odot> v = - (r \<odot> v)"
  by (rule sym, rule minus_unique, simp add: smult_distrib_right[symmetric])

lemma smult_minus_mult_right [simp]: "r \<odot> (- v) = - (r \<odot> v)"
  by (rule sym, rule minus_unique, simp add: smult_distrib_left [symmetric])

lemma minus_smult_minus [simp]: "(- r) \<odot> (- v) = r \<odot> v"
  by simp

lemma minus_smult_commute: "(- r) \<odot> v = r \<odot> (- v)"
  by simp

lemma smult_right_diff_distrib [algebra_simps]: "r \<odot> (v - u) = r \<odot> v - r \<odot> u"
  using smult_distrib_left [of r v "- u"] by simp

lemma smult_left_diff_distrib [algebra_simps]: "(r - s) \<odot> v = r \<odot> v - s \<odot> v"
  using smult_distrib_right [of r "- s" v] by simp

lemma sum_smult_distrib_left: "r \<odot> (sum f A) = (\<Sum>a\<in>A. r \<odot> f a)"
  by (induct A rule: infinite_finite_induct, simp_all add: algebra_simps)

lemma sum_smult_distrib_right: "(sum f A) \<odot> v = (\<Sum>a\<in>A. f a \<odot> v)"
  by (induct A rule: infinite_finite_induct, simp_all add: algebra_simps)

subsection \<open>Submodules Generated by Sets of Module-Elements\<close>

inductive_set module :: "'m set \<Rightarrow> 'm set" for B :: "'m set" where
  module_0: "0 \<in> module B"|
  module_plus: "a \<in> module B \<Longrightarrow> b \<in> B \<Longrightarrow> a + q \<odot> b \<in> module B"

lemma smult_in_module:
  assumes "b \<in> B"
  shows "q \<odot> b \<in> module B"
proof -
  have "0 + q \<odot> b \<in> module B" by (rule module_plus, rule module_0, fact+)
  thus ?thesis by simp
qed

lemma generator_subset_module: "B \<subseteq> module B"
proof
  fix b
  assume b_in: "b \<in> B"
  have "0 + 1 \<odot> b \<in> module B" by (rule module_plus, fact module_0, fact+)
  thus "b \<in> module B" by simp
qed

lemma module_closed_plus:
  assumes p_in: "p \<in> module B" and r_in: "r \<in> module B"
  shows "p + r \<in> module B"
  using p_in
proof (induct p)
  case module_0
  from r_in show "0 + r \<in> module B" by simp
next
  case step: (module_plus a b q)
  have "(a + r) + q \<odot> b \<in> module B" by (rule module_plus, fact+)
  thus "(a + q \<odot> b) + r \<in> module B"
    by (metis ab_semigroup_add_class.add.commute semigroup_add_class.add.assoc)
qed

lemma module_closed_uminus:
  assumes "p \<in> module B"
  shows "- p \<in> module B"
  using assms
proof (induct p)
  case base: module_0
  show "- 0 \<in> module B" by (simp add: module_0)
next
  case step: (module_plus a b q)
  have eq: "- (a + q \<odot> b) = (-a) + ((-q) \<odot> b)" by simp
  have "0 + (-q) \<odot> b \<in> module B" by (rule module_plus, fact module_0, fact+)
  hence "(-q) \<odot> b \<in> module B" by simp
  with step(2) show "- (a + q \<odot> b) \<in> module B" unfolding eq by (rule module_closed_plus)
qed

lemma module_closed_minus:
  assumes "p \<in> module B" and "r \<in> module B"
  shows "p - r \<in> module B"
  using assms(1, 2) module_closed_plus module_closed_uminus by fastforce

lemma module_closed_smult:
  assumes "p \<in> module B"
  shows "r \<odot> p \<in> module B"
  using assms
proof (induct p)
  case base: module_0
  show "r \<odot> 0 \<in> module B" by (simp add: module_0)
next
  case step: (module_plus a b q)
  have *: "r \<odot> (a + q \<odot> b) = r \<odot> a + (r * q) \<odot> b" by (simp add: smult_distrib_left smult_assoc)
  show "r \<odot> (a + q \<odot> b) \<in> module B" unfolding * by (rule module_plus, fact, fact)
qed

lemma module_mono:
  assumes "A \<subseteq> B"
  shows "module A \<subseteq> module B"
proof
  fix p
  assume "p \<in> module A"
  thus "p \<in> module B"
  proof (induct p rule: module.induct)
    case module_0
    show ?case ..
  next
    case step: (module_plus a b q)
    show ?case by (rule module_plus, fact, rule, fact+)
  qed
qed

lemma in_module_insertI:
  assumes "p \<in> module B"
  shows "p \<in> module (insert r B)"
  using assms
proof (induct p)
  case module_0
  show "0 \<in> module (insert r B)" ..
next
  case step: (module_plus a b q)
  show "a + q \<odot> b \<in> module (insert r B)"
  proof (rule, fact)
    from step(3) show "b \<in> insert r B" by simp
  qed
qed

lemma in_module_insertD:
  assumes p_in: "p \<in> module (insert r B)" and r_in: "r \<in> module B"
  shows "p \<in> module B"
  using p_in
proof (induct p)
  case module_0
  show "0 \<in> module B" ..
next
  case step: (module_plus a b q)
  from step(3) have "b = r \<or> b \<in> B" by simp
  thus "a + q \<odot> b \<in> module B"
  proof
    assume eq: "b = r"
    show ?thesis unfolding eq by (rule module_closed_plus, fact, rule module_closed_smult, rule r_in)
  next
    assume "b \<in> B"
    show ?thesis by (rule, fact+)
  qed
qed

lemma module_insert:
  assumes "r \<in> module B"
  shows "module (insert r B) = module B"
proof (rule, rule)
  fix p
  assume "p \<in> module (insert r B)"
  from this assms show "p \<in> module B" by (rule in_module_insertD)
next
  show "module B \<subseteq> module (insert r B)"
  proof
    fix p
    assume "p \<in> module B"
    thus "p \<in> module (insert r B)" by (rule in_module_insertI)
  qed
qed

lemma module_insert_zero: "module (insert 0 B) = module B"
proof (rule, rule)
  fix p
  assume "p \<in> module (insert 0 B)"
  thus "p \<in> module B"
  proof (induct p)
    case module_0
    show "0 \<in> module B" ..
  next
    case step: (module_plus a b q)
    from step(3) have "b = 0 \<or> b \<in> B" by simp
    thus "a + q \<odot> b \<in> module B"
    proof
      assume "b = 0"
      thus ?thesis using step(2) by simp
    next
      assume "b \<in> B"
      show ?thesis by (rule, fact+)
    qed
  qed
next
  show "module B \<subseteq> module (insert 0 B)" by (rule module_mono, auto)
qed

lemma module_minus_singleton_zero: "module (B - {0}) = module B"
  by (metis module_insert_zero insert_Diff_single)

lemma module_empty: "module {} = {0}"
proof (rule, rule)
  fix p::'m
  assume "p \<in> module {}"
  thus "p \<in> {0}" by (induct p, simp_all)
next
  show "{0} \<subseteq> module {}" by (rule, simp add: module_0)
qed
  
lemma generator_in_module:
  assumes "b \<in> B"
  shows "b \<in> module B"
  by (rule, fact assms, rule generator_subset_module)

lemma module_insert_subset:
  assumes "module A \<subseteq> module B" and "r \<in> module B"
  shows "module (insert r A) \<subseteq> module B"
proof
  fix p
  assume "p \<in> module (insert r A)"
  thus "p \<in> module B"
  proof (induct p rule: module.induct)
    case module_0
    show ?case ..
  next
    case step: (module_plus a b q)
    show ?case
    proof (rule module_closed_plus)
      show "q \<odot> b \<in> module B"
      proof (rule module_closed_smult)
        from \<open>b \<in> insert r A\<close> show "b \<in> module B"
        proof
          assume "b = r"
          thus "b \<in> module B" using \<open>r \<in> module B\<close> by simp
        next
          assume "b \<in> A"
          hence "b \<in> module A" using generator_subset_module[of A] ..
          thus "b \<in> module B" using \<open>module A \<subseteq> module B\<close> ..
        qed
      qed
    qed fact
  qed
qed

lemma replace_module:
  assumes "q \<in> module B"
  shows "module (insert q (B - {p})) \<subseteq> module B"
  by (rule module_insert_subset, rule module_mono, fact Diff_subset, fact)

lemma in_module_finite_subset:
  assumes "p \<in> module B"
  obtains A where "finite A" and "A \<subseteq> B" and "p \<in> module A"
  using assms
proof (induct p arbitrary: thesis)
  case module_0
  show ?case
  proof (rule module_0(1))
    show "finite {}" ..
  next
    show "{} \<subseteq> B" ..
  qed (simp add: module_empty)
next
  case step: (module_plus p b q)
  obtain A where 1: "finite A" and 2: "A \<subseteq> B" and 3: "p \<in> module A" by (rule step(2))
  let ?A = "insert b A"
  show ?case
  proof (rule step(4))
    from 1 show "finite ?A" ..
  next
    from step(3) 2 show "insert b A \<subseteq> B" by simp
  next
    show "p + q \<odot> b \<in> module (insert b A)"
      by (rule module_plus, rule, fact 3, rule module_mono, auto intro: step(4))
  qed
qed

lemma in_module_finiteE:
  assumes fin: "finite B" and p_in: "p \<in> module B"
  obtains q where "p = (\<Sum>b\<in>B. (q b) \<odot> b)"
  using p_in
proof (induct p arbitrary: thesis)
  case base: module_0
  let ?q = "\<lambda>_. (0::'r)"
  show ?case
  proof (rule base(1))
    show "0 = (\<Sum>b\<in>B. ?q b \<odot> b)" by simp
  qed
next
  case step: (module_plus p b r)
  obtain q where *: "p = (\<Sum>b\<in>B. (q b) \<odot> b)" by (rule step(2), auto)
  let ?q = "q(b := (q b + r))"
  show ?case
  proof (rule step(4))
    have "p = q b \<odot> b + (\<Sum>b\<in>B - {b}. q b \<odot> b)"
      by (simp only: *, simp add: comm_monoid_add_class.sum.remove[OF assms(1) step(3)])
    thus "p + r \<odot> b = (\<Sum>b\<in>B. ?q b \<odot> b)"
      by (simp add: comm_monoid_add_class.sum.remove[OF assms(1) step(3)] algebra_simps)
  qed
qed

lemma in_moduleE:
  assumes "p \<in> module B"
  obtains A q where "finite A" and "A \<subseteq> B" and "p = (\<Sum>b\<in>A. (q b) \<odot> b)"
proof -
  from assms obtain A where 1: "finite A" and 2: "A \<subseteq> B" and 3: "p \<in> module A"
    by (rule in_module_finite_subset)
  from 1 3 obtain q where "p = (\<Sum>b\<in>A. (q b) \<odot> b)"
    by (rule in_module_finiteE, auto)
  with 1 2 show ?thesis ..
qed

lemma sum_in_moduleI: "(\<Sum>b\<in>B. q b \<odot> b) \<in> module B"
proof (cases "finite B")
  case True
  thus ?thesis
  proof (induct B, simp add: module_0)
    case ind: (insert b B)
    have "(\<Sum>b\<in>B. q b \<odot> b) \<in> module (insert b B)"
      by (rule, rule ind(3), rule module_mono, auto)
    moreover have "b \<in> insert b B" by simp
    ultimately have "(\<Sum>b\<in>B. q b \<odot> b) + q b \<odot> b \<in> module (insert b B)" by (rule module_plus)
    thus ?case unfolding sum.insert[OF ind(1) ind(2)] by (simp add: ac_simps)
  qed
next
  case False
  thus ?thesis by (simp add: module_0)
qed

lemma module_subset_moduleI:
  assumes "A \<subseteq> module B"
  shows "module A \<subseteq> module B"
proof
  fix p
  assume "p \<in> module A"
  thus "p \<in> module B"
  proof (induct p)
    case base: module_0
    show ?case by (fact module_0)
  next
    case step: (module_plus a b q)
    from step(3) assms have "b \<in> module B" ..
    hence "q \<odot> b \<in> module B" by (rule module_closed_smult)
    with step(2) show ?case by (rule module_closed_plus)
  qed
qed

lemma module_insert_cong:
  assumes "module A = module B"
  shows "module (insert p A) = module (insert p B)" (is "?l = ?r")
proof
  show "?l \<subseteq> ?r"
  proof (rule module_subset_moduleI)
    show "insert p A \<subseteq> ?r"
    proof (rule insert_subsetI)
      show "p \<in> ?r" by (rule generator_in_module, simp)
    next
      have "A \<subseteq> module A" by (rule generator_subset_module)
      also from assms have "... = module B" .
      also have "... \<subseteq> ?r" by (rule module_mono, blast)
      finally show "A \<subseteq> ?r" .
    qed
  qed
next
  show "?r \<subseteq> ?l"
  proof (rule module_subset_moduleI)
    show "insert p B \<subseteq> ?l"
    proof (rule insert_subsetI)
      show "p \<in> ?l" by (rule generator_in_module, simp)
    next
      have "B \<subseteq> module B" by (rule generator_subset_module)
      also from assms have "... = module A" by simp
      also have "... \<subseteq> ?l" by (rule module_mono, blast)
      finally show "B \<subseteq> ?l" .
    qed
  qed
qed

lemma module_idI:
  assumes "0 \<in> B" and "\<And>b1 b2. b1 \<in> B \<Longrightarrow> b2 \<in> B \<Longrightarrow> b1 + b2 \<in> B"
    and "\<And>c b. b \<in> B \<Longrightarrow> c \<odot> b \<in> B"
  shows "module B = B"
proof
  show "module B \<subseteq> B"
  proof
    fix p
    assume "p \<in> module B"
    thus "p \<in> B"
    proof (induct p)
      case module_0
      show ?case by (fact assms(1))
    next
      case step: (module_plus a b q)
      from step(2) show ?case
      proof (rule assms(2))
        from step(3) show "q \<odot> b \<in> B" by (rule assms(3))
      qed
    qed
  qed
qed (fact generator_subset_module)

lemma module_idem [simp]: "module (module B) = module B"
proof (rule module_idI)
  show "0 \<in> module B" by (fact module_0)
next
  fix b1 b2
  assume "b1 \<in> module B" and "b2 \<in> module B"
  thus "b1 + b2 \<in> module B" by (rule module_closed_plus)
next
  fix c b
  assume "b \<in> module B"
  thus "c \<odot> b \<in> module B" by (rule module_closed_smult)
qed

lemma module_closed_sum:
  assumes "\<And>a. a \<in> A \<Longrightarrow> f a \<in> module B"
  shows "(\<Sum>a\<in>A. f a) \<in> module B"
proof (cases "finite A")
  case True
  from this assms show ?thesis
  proof induct
    case empty
    thus ?case by (simp add: module_0)
  next
    case (insert a A)
    show ?case
    proof (simp only: sum.insert[OF insert(1, 2)], rule module_closed_plus)
      have "a \<in> insert a A" by simp
      thus "f a \<in> module B" by (rule insert.prems)
    next
      show "sum f A \<in> module B"
      proof (rule insert(3))
        fix b
        assume "b \<in> A"
        hence "b \<in> insert a A" by simp
        thus "f b \<in> module B" by (rule insert.prems)
      qed
    qed
  qed
next
  case False
  thus ?thesis by (simp add: module_0)
qed

lemma module_induct [consumes 1, case_names module_0 module_plus]:
  assumes "p \<in> module B" and "P 0"
    and "\<And>a q p. a \<in> module B \<Longrightarrow> P a \<Longrightarrow> p \<in> B \<Longrightarrow> q \<noteq> 0 \<Longrightarrow> P (a + q \<odot> p)"
  shows "P p"
  using assms(1)
proof (induct p)
  case module_0
  from assms(2) show ?case .
next
  case ind: (module_plus a b q)
  from ind(1) have "a \<in> module B" by (simp only: module_def)
  show ?case
  proof (cases "q = 0")
    case True
    from ind(2) show ?thesis by (simp add: True)
  next
    case False
    with \<open>a \<in> module B\<close> ind(2, 3) show ?thesis by (rule assms(3))
  qed
qed

lemma module_INT_subset: "module (\<Inter>a\<in>A. f a) \<subseteq> (\<Inter>a\<in>A. module (f a))" (is "?l \<subseteq> ?r")
proof
  fix p
  assume "p \<in> ?l"
  show "p \<in> ?r"
  proof
    fix a
    assume "a \<in> A"
    from \<open>p \<in> ?l\<close> show "p \<in> module (f a)"
    proof induct
      case base: module_0
      show ?case by (fact module_0)
    next
      case step: (module_plus p b q)
      note step(2)
      moreover from step(3) \<open>a \<in> A\<close> have "b \<in> f a" ..
      ultimately show ?case by (rule module_plus)
    qed
  qed
qed

lemma module_INT: "module (\<Inter>a\<in>A. module (f a)) = (\<Inter>a\<in>A. module (f a))" (is "?l = ?r")
proof
  have "?l \<subseteq> (\<Inter>a\<in>A. module (module (f a)))" by (rule module_INT_subset)
  also have "... = ?r" by simp
  finally show "?l \<subseteq> ?r" .
next
  show "?r \<subseteq> ?l" by (rule generator_subset_module)
qed

lemma module_Int_subset: "module (A \<inter> B) \<subseteq> module A \<inter> module B"
proof -
  have "module (A \<inter> B) = module (\<Inter>x\<in>{A, B}. x)" by simp
  also have "... \<subseteq> (\<Inter>x\<in>{A, B}. module x)" by (fact module_INT_subset)
  also have "... = module A \<inter> module B" by simp
  finally show ?thesis .
qed

lemma module_Int: "module (module A \<inter> module B) = module A \<inter> module B"
proof -
  have "module (module A \<inter> module B) = module (\<Inter>x\<in>{A, B}. module x)" by simp
  also have "... = (\<Inter>x\<in>{A, B}. module x)" by (fact module_INT)
  also have "... = module A \<inter> module B" by simp
  finally show ?thesis .
qed

end (* module_struct *)

section \<open>Left-Ideals over Rings\<close>

lemma module_struct_times: "module_struct ( * )"
  by (standard, simp_all add: algebra_simps)

interpretation ideal: module_struct times
  by (fact module_struct_times)

abbreviation "quasi_ideal \<equiv> ideal.module"

abbreviation "ideal \<equiv> ideal.module"

lemma ideal_eq_UNIV_iff_contains_one: "ideal B = UNIV \<longleftrightarrow> 1 \<in> ideal B"
proof
  assume *: "1 \<in> ideal B"
  show "ideal B = UNIV"
  proof
    show "UNIV \<subseteq> ideal B"
    proof
      fix x
      from * have "x * 1 \<in> ideal B" by (rule ideal.module_closed_smult)
      thus "x \<in> ideal B" by simp
    qed
  qed simp
qed simp

end (* theory *)
