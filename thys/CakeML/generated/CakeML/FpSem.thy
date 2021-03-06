chapter \<open>Generated by Lem from \<open>semantics/fpSem.lem\<close>.\<close>

theory "FpSem" 

imports
  Main
  "LEM.Lem_pervasives"
  "Lib"
  "IEEE_Floating_Point.FP64"

begin 

(*open import Pervasives*)
(*open import Lib*)

(*open import {hol} `machine_ieeeTheory`*)
(*open import {isabelle} `IEEE_Floating_Point.FP64`*)

(*type rounding*)

datatype fp_cmp_op = FP_Less | FP_LessEqual | FP_Greater | FP_GreaterEqual | FP_Equal
datatype fp_uop_op = FP_Abs | FP_Neg | FP_Sqrt
datatype fp_bop_op = FP_Add | FP_Sub | FP_Mul | FP_Div

(*val fp64_lessThan     : word64 -> word64 -> bool*)
(*val fp64_lessEqual    : word64 -> word64 -> bool*)
(*val fp64_greaterThan  : word64 -> word64 -> bool*)
(*val fp64_greaterEqual : word64 -> word64 -> bool*)
(*val fp64_equal        : word64 -> word64 -> bool*)

(*val fp64_abs    : word64 -> word64*)
(*val fp64_negate : word64 -> word64*)
(*val fp64_sqrt   : rounding -> word64 -> word64*)

(*val fp64_add : rounding -> word64 -> word64 -> word64*)
(*val fp64_sub : rounding -> word64 -> word64 -> word64*)
(*val fp64_mul : rounding -> word64 -> word64 -> word64*)
(*val fp64_div : rounding -> word64 -> word64 -> word64*)

(*val roundTiesToEven : rounding*)

(*val fp_cmp : fp_cmp -> word64 -> word64 -> bool*)
fun fp_cmp  :: " fp_cmp_op \<Rightarrow> 64 word \<Rightarrow> 64 word \<Rightarrow> bool "  where 
     " fp_cmp FP_Less = ( fp64_lessThan )"
|" fp_cmp FP_LessEqual = ( fp64_lessEqual )"
|" fp_cmp FP_Greater = ( fp64_greaterThan )"
|" fp_cmp FP_GreaterEqual = ( fp64_greaterEqual )"
|" fp_cmp FP_Equal = ( fp64_equal )"


(*val fp_uop : fp_uop -> word64 -> word64*)
fun fp_uop  :: " fp_uop_op \<Rightarrow> 64 word \<Rightarrow> 64 word "  where 
     " fp_uop FP_Abs = ( fp64_abs )"
|" fp_uop FP_Neg = ( fp64_negate )"
|" fp_uop FP_Sqrt = ( fp64_sqrt To_nearest )"


(*val fp_bop : fp_bop -> word64 -> word64 -> word64*)
fun fp_bop  :: " fp_bop_op \<Rightarrow> 64 word \<Rightarrow> 64 word \<Rightarrow> 64 word "  where 
     " fp_bop FP_Add = ( fp64_add To_nearest )"
|" fp_bop FP_Sub = ( fp64_sub To_nearest )"
|" fp_bop FP_Mul = ( fp64_mul To_nearest )"
|" fp_bop FP_Div = ( fp64_div To_nearest )"

end
