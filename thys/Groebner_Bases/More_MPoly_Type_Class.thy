(* Author: Alexander Maletzky *)

theory More_MPoly_Type_Class
  imports Polynomials.MPoly_Type_Class_Ordered General
begin

text \<open>Some further general properties of (ordered) multivariate polynomials needed for Gr\"obner
  bases. This theory is an extension of @{theory Polynomials.MPoly_Type_Class_Ordered}.\<close>

section \<open>Further Properties of Multivariate Polynomials\<close>

context term_powerprod
begin

subsection \<open>Modules and Linear Hulls\<close>

lemma monomial_1_in_pmdlI:
  assumes "(f::_ \<Rightarrow>\<^sub>0 'b::field) \<in> pmdl F" and "keys f = {t}"
  shows "monomial 1 t \<in> pmdl F"
proof -
  define c where "c \<equiv> lookup f t"
  from assms(2) have f_eq: "f = monomial c t" unfolding c_def
    by (metis (mono_tags, lifting) Diff_insert_absorb cancel_comm_monoid_add_class.add_cancel_right_right
        plus_except insert_absorb insert_not_empty keys_eq_empty_iff keys_except)
  from assms(2) have "c \<noteq> 0" by (simp add: c_def)
  hence "monomial 1 t = monom_mult (1 / c) 0 f" by (simp add: f_eq monom_mult_monomial term_simps)
  also from assms(1) have "... \<in> pmdl F" by (rule pmdl_closed_monom_mult)
  finally show ?thesis .
qed

lemma in_pmdl_listE:
  assumes "p \<in> pmdl (set bs)"
  obtains qs where "length qs = length bs" and "p = (\<Sum>(q, b)\<leftarrow>zip qs bs. q \<odot> b)"
proof -
  have "finite (set bs)" ..
  from this assms obtain q where p: "p = (\<Sum>b\<in>set bs. (q b) \<odot> b)" by (rule pmdl.in_module_finiteE)
  let ?qs = "map_dup q (\<lambda>_. 0) bs"
  show ?thesis
  proof
    show "length ?qs = length bs" by simp
  next
    let ?zs = "zip (map q (remdups bs)) (remdups bs)"
    have *: "distinct ?zs" by (rule distinct_zipI2, rule distinct_remdups)
    have inj: "inj_on (\<lambda>b. (q b, b)) (set bs)" by (rule, simp)
    have "p = (\<Sum>(q, b)\<leftarrow>?zs. q \<odot> b)"
      by (simp add: sum_list_distinct_conv_sum_set[OF *] set_zip_map1 p comm_monoid_add_class.sum.reindex[OF inj])
    also have "... = (\<Sum>(q, b)\<leftarrow>(filter (\<lambda>(q, b). q \<noteq> 0) ?zs). q \<odot> b)"
      by (rule monoid_add_class.sum_list_map_filter[symmetric], auto)
    also have "... = (\<Sum>(q, b)\<leftarrow>(filter (\<lambda>(q, b). q \<noteq> 0) (zip ?qs bs)). q \<odot> b)"
      by (simp only: filter_zip_map_dup_const)
    also have "... = (\<Sum>(q, b)\<leftarrow>zip ?qs bs. q \<odot> b)"
      by (rule monoid_add_class.sum_list_map_filter, auto)
    finally show "p = (\<Sum>(q, b)\<leftarrow>zip ?qs bs. q \<odot> b)" .
  qed
qed

lemma in_pmdl_listI: "(\<Sum>(q, b)\<leftarrow>zip qs bs. q \<odot> b) \<in> pmdl (set bs)"
proof (induct qs arbitrary: bs)
  case Nil
  show ?case by (simp add: pmdl.module_0)
next
  case step: (Cons q qs)
  show ?case
  proof (simp add: zip_Cons1 pmdl.module_0 split: list.split, intro allI impI)
    fix a as
    have "(\<Sum>(x, y)\<leftarrow>zip qs as. x \<odot> y) \<in> pmdl (insert a (set as))" (is "?x \<in> ?A")
      by (rule, fact step, rule pmdl.module_mono, auto)
    show "q \<odot> a + ?x \<in> ?A" by (rule pmdl.module_closed_plus, rule pmdl.smult_in_module, simp, fact)
  qed
qed

lemma in_phull_listE:
  assumes "p \<in> phull (set bs)"
  obtains cs where "length cs = length bs" and "p = (\<Sum>(c, b)\<leftarrow>zip cs bs. monom_mult c 0 b)"
proof -
  have "finite (set bs)" ..
  from this assms obtain c where p: "p = (\<Sum>b\<in>set bs. monom_mult (c b) 0 b)"
    by (rule phull.in_module_finiteE)
  let ?cs = "map_dup c (\<lambda>_. 0) bs"
  show ?thesis
  proof
    show "length ?cs = length bs" by simp
  next
    let ?zs = "zip (map c (remdups bs)) (remdups bs)"
    have *: "distinct ?zs" by (rule distinct_zipI2, rule distinct_remdups)
    have inj: "inj_on (\<lambda>x. (c x, x)) (set bs)" by (rule, simp)
    have "p = (\<Sum>(q, b)\<leftarrow>?zs. monom_mult q 0 b)"
      by (simp add: sum_list_distinct_conv_sum_set[OF *] set_zip_map1 p comm_monoid_add_class.sum.reindex[OF inj])
    also have "... = (\<Sum>(q, b)\<leftarrow>(filter (\<lambda>(c, b). c \<noteq> 0) ?zs). monom_mult q 0 b)"
      by (rule monoid_add_class.sum_list_map_filter[symmetric], auto)
    also have "... = (\<Sum>(q, b)\<leftarrow>(filter (\<lambda>(c, b). c \<noteq> 0) (zip ?cs bs)). monom_mult q 0 b)"
      by (simp only: filter_zip_map_dup_const)
    also have "... = (\<Sum>(q, b)\<leftarrow>zip ?cs bs. monom_mult q 0 b)"
      by (rule monoid_add_class.sum_list_map_filter, auto)
    finally show "p = (\<Sum>(q, b)\<leftarrow>zip ?cs bs. monom_mult q 0 b)" .
  qed
qed

lemma in_phull_listI: "(\<Sum>(c, b)\<leftarrow>zip cs bs. monom_mult c 0 b) \<in> phull (set bs)"
proof (induct cs arbitrary: bs)
  case Nil
  show ?case by (simp add: phull.module_0)
next
  case step: (Cons c cs)
  show ?case
  proof (simp add: zip_Cons1 phull.module_0 split: list.split, intro allI impI)
    fix a and as::"('t \<Rightarrow>\<^sub>0 'b) list"
    have "(\<Sum>(x, y)\<leftarrow>zip cs as. monom_mult x 0 y) \<in> phull (insert a (set as))" (is "?x \<in> ?A")
      by (rule, fact step, rule phull.module_mono, auto)
    show "monom_mult c 0 a + ?x \<in> ?A" by (rule phull.module_closed_plus, rule phull.smult_in_module, simp, fact)
  qed
qed

end (* term_powerprod *)
  
section \<open>Further Properties of Ordered Polynomials\<close>
  
context ordered_term
begin

subsection \<open>Sets of Leading Terms and -Coefficients\<close>
  
definition lt_set :: "('t, 'b::zero) poly_mapping set \<Rightarrow> 't set" where
  "lt_set F = lt ` (F - {0})"

definition lc_set :: "('t, 'b::zero) poly_mapping set \<Rightarrow> 'b set" where
  "lc_set F = lc ` (F - {0})"
  
lemma lt_setI:
  assumes "f \<in> F" and "f \<noteq> 0"
  shows "lt f \<in> lt_set F"
  unfolding lt_set_def using assms by simp

lemma lt_setE:
  assumes "t \<in> lt_set F"
  obtains f where "f \<in> F" and "f \<noteq> 0" and "lt f = t"
  using assms unfolding lt_set_def by auto
    
lemma lt_set_iff:
  shows "t \<in> lt_set F \<longleftrightarrow> (\<exists>f\<in>F. f \<noteq> 0 \<and> lt f = t)"
  unfolding lt_set_def by auto

lemma lc_setI:
  assumes "f \<in> F" and "f \<noteq> 0"
  shows "lc f \<in> lc_set F"
  unfolding lc_set_def using assms by simp

lemma lc_setE:
  assumes "c \<in> lc_set F"
  obtains f where "f \<in> F" and "f \<noteq> 0" and "lc f = c"
  using assms unfolding lc_set_def by auto
    
lemma lc_set_iff:
  shows "c \<in> lc_set F \<longleftrightarrow> (\<exists>f\<in>F. f \<noteq> 0 \<and> lc f = c)"
  unfolding lc_set_def by auto

lemma lc_set_nonzero:
  shows "0 \<notin> lc_set F"
proof
  assume "0 \<in> lc_set F"
  then obtain f where "f \<in> F" and "f \<noteq> 0" and "lc f = 0" by (rule lc_setE)
  from \<open>f \<noteq> 0\<close> have "lc f \<noteq> 0" by (rule lc_not_0)
  from this \<open>lc f = 0\<close> show False ..
qed

lemma lt_sum_distinct_eq_Max:
  assumes "finite I" and "sum p I \<noteq> 0"
    and "\<And>i1 i2. i1 \<in> I \<Longrightarrow> i2 \<in> I \<Longrightarrow> p i1 \<noteq> 0 \<Longrightarrow> p i2 \<noteq> 0 \<Longrightarrow> lt (p i1) = lt (p i2) \<Longrightarrow> i1 = i2"
  shows "lt (sum p I) = ord_term_lin.Max (lt_set (p ` I))"
proof -
  have "\<not> p ` I \<subseteq> {0}"
  proof
    assume "p ` I \<subseteq> {0}"
    hence "sum p I = 0" by (rule sum_poly_mapping_eq_zeroI)
    with assms(2) show False ..
  qed
  from assms(1) this assms(3) show ?thesis
  proof (induct I)
    case empty
    from empty(1) show ?case by simp
  next
    case (insert x I)
    show ?case
    proof (cases "p ` I \<subseteq> {0}")
      case True
      hence "p ` I - {0} = {}" by simp
      have "p x \<noteq> 0"
      proof
        assume "p x = 0"
        with True have " p ` insert x I \<subseteq> {0}" by simp
        with insert(4) show False ..
      qed
      hence "insert (p x) (p ` I) - {0} = insert (p x) (p ` I - {0})" by auto
      hence "lt_set (p ` insert x I) = {lt (p x)}" by (simp add: lt_set_def \<open>p ` I - {0} = {}\<close>)
      hence eq1: "ord_term_lin.Max (lt_set (p ` insert x I)) = lt (p x)" by simp
      have eq2: "sum p I = 0"
      proof (rule ccontr)
        assume "sum p I \<noteq> 0"
        then obtain y where "y \<in> I" and "p y \<noteq> 0" by (rule sum.not_neutral_contains_not_neutral)
        with True show False by auto
      qed
      show ?thesis by (simp only: eq1 sum.insert[OF insert(1) insert(2)], simp add: eq2)
    next
      case False
      hence IH: "lt (sum p I) = ord_term_lin.Max (lt_set (p ` I))"
      proof (rule insert(3))
        fix i1 i2
        assume "i1 \<in> I" and "i2 \<in> I"
        hence "i1 \<in> insert x I" and "i2 \<in> insert x I" by simp_all
        moreover assume "p i1 \<noteq> 0" and "p i2 \<noteq> 0" and "lt (p i1) = lt (p i2)"
        ultimately show "i1 = i2" by (rule insert(5))
      qed
      show ?thesis
      proof (cases "p x = 0")
        case True
        hence eq: "lt_set (p ` insert x I) = lt_set (p ` I)" by (simp add: lt_set_def)
        show ?thesis by (simp only: eq, simp add: sum.insert[OF insert(1) insert(2)] True, fact IH)
      next
        case False
        hence eq1: "lt_set (p ` insert x I) = insert (lt (p x)) (lt_set (p ` I))"
          by (auto simp add: lt_set_def)
        from insert(1) have "finite (lt_set (p ` I))" by (simp add: lt_set_def)
        moreover from \<open>\<not> p ` I \<subseteq> {0}\<close> have "lt_set (p ` I) \<noteq> {}" by (simp add: lt_set_def)
        ultimately have eq2: "ord_term_lin.Max (insert (lt (p x)) (lt_set (p ` I))) =
                          ord_term_lin.max (lt (p x)) (ord_term_lin.Max (lt_set (p ` I)))"
          by (rule ord_term_lin.Max_insert)
        show ?thesis
        proof (simp only: eq1, simp add: sum.insert[OF insert(1) insert(2)] eq2 IH[symmetric],
            rule lt_plus_distinct_eq_max, rule)
          assume *: "lt (p x) = lt (sum p I)"
          have "lt (p x) \<in> lt_set (p ` I)" by (simp only: * IH, rule ord_term_lin.Max_in, fact+)
          then obtain f where "f \<in> p ` I" and "f \<noteq> 0" and ltf: "lt f = lt (p x)" by (rule lt_setE)
          from this(1) obtain y where "y \<in> I" and "f = p y" ..
          from this(2) \<open>f \<noteq> 0\<close> ltf have "p y \<noteq> 0" and lt_eq: "lt (p y) = lt (p x)" by simp_all
          from _ _ this(1) \<open>p x \<noteq> 0\<close> this(2) have "y = x"
          proof (rule insert(5))
            from \<open>y \<in> I\<close> show "y \<in> insert x I" by simp
          next
            show "x \<in> insert x I" by simp
          qed
          with \<open>y \<in> I\<close> have "x \<in> I" by simp
          with \<open>x \<notin> I\<close> show False ..
        qed
      qed
    qed
  qed
qed

lemma lt_sum_distinct_in_lt_set:
  assumes "finite I" and "sum p I \<noteq> 0"
    and "\<And>i1 i2. i1 \<in> I \<Longrightarrow> i2 \<in> I \<Longrightarrow> p i1 \<noteq> 0 \<Longrightarrow> p i2 \<noteq> 0 \<Longrightarrow> lt (p i1) = lt (p i2) \<Longrightarrow> i1 = i2"
  shows "lt (sum p I) \<in> lt_set (p ` I)"
proof -
  have "\<not> p ` I \<subseteq> {0}"
  proof
    assume "p ` I \<subseteq> {0}"
    hence "sum p I = 0" by (rule sum_poly_mapping_eq_zeroI)
    with assms(2) show False ..
  qed
  have "lt (sum p I) = ord_term_lin.Max (lt_set (p ` I))"
    by (rule lt_sum_distinct_eq_Max, fact+)
  also have "... \<in> lt_set (p ` I)"
  proof (rule ord_term_lin.Max_in)
    from assms(1) show "finite (lt_set (p ` I))" by (simp add: lt_set_def)
  next
    from \<open>\<not> p ` I \<subseteq> {0}\<close> show "lt_set (p ` I) \<noteq> {}" by (simp add: lt_set_def)
  qed
  finally show ?thesis .
qed

subsection \<open>Monicity\<close>
  
definition monic :: "('t \<Rightarrow>\<^sub>0 'b) \<Rightarrow> ('t \<Rightarrow>\<^sub>0 'b::field)" where
  "monic p = monom_mult (1 / lc p) 0 p"

definition monic_set :: "('t \<Rightarrow>\<^sub>0 'b) set \<Rightarrow> ('t \<Rightarrow>\<^sub>0 'b::field) set" where
  "monic_set = image monic"
  
definition is_monic_set :: "('t \<Rightarrow>\<^sub>0 'b::field) set \<Rightarrow> bool" where
  "is_monic_set B \<equiv> (\<forall>b\<in>B. b \<noteq> 0 \<longrightarrow> lc b = 1)"

lemma lookup_monic: "lookup (monic p) v = (lookup p v) / lc p"
proof -
  have "lookup (monic p) (0 \<oplus> v) = (1 / lc p) * (lookup p v)" unfolding monic_def
    by (rule lookup_monom_mult_plus)
  thus ?thesis by (simp add: term_simps)
qed

lemma lookup_monic_lt:
  assumes "p \<noteq> 0"
  shows "lookup (monic p) (lt p) = 1"
  unfolding monic_def
proof -
  from assms have "lc p \<noteq> 0" by (rule lc_not_0)
  hence "1 / lc p \<noteq> 0" by simp
  let ?q = "monom_mult (1 / lc p) 0 p"
  have "lookup ?q (0 \<oplus> lt p) = (1 / lc p) * (lookup p (lt p))" by (rule lookup_monom_mult_plus)
  also have "... = (1 / lc p) * lc p" unfolding lc_def ..
  also have "... = 1" using \<open>lc p \<noteq> 0\<close> by simp
  finally have "lookup ?q (0 \<oplus> lt p) = 1" .
  thus "lookup ?q (lt p) = 1" by (simp add: term_simps)
qed
  
lemma monic_0 [simp]: "monic 0 = 0"
  unfolding monic_def by (rule monom_mult_zero_right)

lemma monic_0_iff: "(monic p = 0) \<longleftrightarrow> (p = 0)"
proof
  assume "monic p = 0"
  show "p = 0"
  proof (rule ccontr)
    assume "p \<noteq> 0"
    hence "lookup (monic p) (lt p) = 1" by (rule lookup_monic_lt)
    with \<open>monic p = 0\<close> have "lookup 0 (lt p) = (1::'b)" by simp
    thus False by simp
  qed
next
  assume p0: "p = 0"
  show "monic p = 0" unfolding p0 by (fact monic_0)
qed
  
lemma keys_monic [simp]: "keys (monic p) = keys p"
proof (cases "p = 0")
  case True
  show ?thesis unfolding True monic_0 ..
next
  case False
  hence "lc p \<noteq> 0" by (rule lc_not_0)
  thm in_keys_iff
  show ?thesis
    by (rule set_eqI, simp add: in_keys_iff lookup_monic \<open>lc p \<noteq> 0\<close> del: lookup_not_eq_zero_eq_in_keys)
qed

lemma lt_monic [simp]: "lt (monic p) = lt p"
proof (cases "p = 0")
  case True
  show ?thesis unfolding True monic_0 ..
next
  case False
  have "lt (monom_mult (1 / lc p) 0 p) = 0 \<oplus> lt p"
  proof (rule lt_monom_mult)
    from False have "lc p \<noteq> 0" by (rule lc_not_0)
    thus "1 / lc p \<noteq> 0" by simp
  qed fact
  thus ?thesis by (simp add: monic_def term_simps)
qed

lemma lc_monic:
  assumes "p \<noteq> 0"
  shows "lc (monic p) = 1"
  using assms by (simp add: lc_def lookup_monic_lt)

lemma mult_lc_monic:
  assumes "p \<noteq> 0"
  shows "monom_mult (lc p) 0 (monic p) = p" (is "?q = p")
proof (rule poly_mapping_eqI)
  fix v
  from assms have "lc p \<noteq> 0" by (rule lc_not_0)
  have "lookup ?q (0 \<oplus> v) = (lc p) * (lookup (monic p) v)" by (rule lookup_monom_mult_plus)
  also have "... = (lc p) * ((lookup p v) / lc p)" by (simp add: lookup_monic)
  also have "... = lookup p v" using \<open>lc p \<noteq> 0\<close> by simp
  finally show "lookup ?q v = lookup p v" by (simp add: term_simps)
qed

lemma is_monic_setI:
  assumes "\<And>b. b \<in> B \<Longrightarrow> b \<noteq> 0 \<Longrightarrow> lc b = 1"
  shows "is_monic_set B"
  unfolding is_monic_set_def using assms by auto

lemma is_monic_setD:
  assumes "is_monic_set B" and "b \<in> B" and "b \<noteq> 0"
  shows "lc b = 1"
  using assms unfolding is_monic_set_def by auto

lemma Keys_monic_set [simp]: "Keys (monic_set A) = Keys A"
  by (simp add: Keys_def monic_set_def)
    
lemma monic_set_is_monic_set: "is_monic_set (monic_set A)"
proof (rule is_monic_setI)
  fix p
  assume pin: "p \<in> monic_set A" and "p \<noteq> 0"
  from pin obtain p' where p_def: "p = monic p'" and "p' \<in> A" unfolding monic_set_def ..
  from \<open>p \<noteq> 0\<close> have "p' \<noteq> 0" unfolding p_def monic_0_iff .
  thus "lc p = 1" unfolding p_def by (rule lc_monic)
qed
  
lemma monic_set_pmdl [simp]: "pmdl (monic_set B) = pmdl B"
proof
  show "pmdl (monic_set B) \<subseteq> pmdl B"
  proof
    fix p
    assume "p \<in> pmdl (monic_set B)"
    thus "p \<in> pmdl B"
    proof (induct p rule: pmdl_induct)
      case base: module_0
      show ?case by (fact pmdl.module_0)
    next
      case ind: (module_plus a b c t)
      from ind(3) obtain b' where b_def: "b = monic b'" and "b' \<in> B" unfolding monic_set_def ..
      have eq: "b = monom_mult (1 / lc b') 0 b'" by (simp only: b_def monic_def)
      show ?case unfolding eq monom_mult_assoc
        by (rule pmdl.module_closed_plus, fact, rule monom_mult_in_pmdl, fact)
    qed
  qed
next
  show "pmdl B \<subseteq> pmdl (monic_set B)"
  proof
    fix p
    assume "p \<in> pmdl B"
    thus "p \<in> pmdl (monic_set B)"
    proof (induct p rule: pmdl_induct)
      case base: module_0
      show ?case by (fact pmdl.module_0)
    next
      case ind: (module_plus a b c t)
      show ?case
      proof (cases "b = 0")
        case True
        from ind(2) show ?thesis by (simp add: True)
      next
        case False
        let ?b = "monic b"
        from ind(3) have "?b \<in> monic_set B" unfolding monic_set_def by (rule imageI)
        have "a + monom_mult c t (monom_mult (lc b) 0 ?b) \<in> pmdl (monic_set B)"
          unfolding monom_mult_assoc
          by (rule pmdl.module_closed_plus, fact, rule monom_mult_in_pmdl, fact)
        thus ?thesis unfolding mult_lc_monic[OF False] .
      qed
    qed
  qed
qed

end (* ordered_term *)

end (* theory *)
