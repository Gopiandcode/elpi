(* External data: partial instantiate declare with a print and equality function
 * to get a factory for a type *)
module C : sig
  type data
  val declare : ('a -> string) -> ('a -> 'a -> bool) -> 'a -> data
  val print : data -> string
  val equal : data -> data -> bool
end

(* Immutable arrays with fast sub and append TODO *)
module IA : sig
  include BIA.S

  (* TODO: evaluate rope like structure with compression on get *)
  val append : 'a t -> 'a t -> 'a t
  val cons : 'a -> 'a t -> 'a t
end

module LP : sig
  type var = int
  type level = int
  type name = string
  type data

  type kind_of_data = private
    | Uv of var * level
    | Con of name * level
    | DB of int
    | Bin of int * data
    | Tup of data IA.t
    | Ext of C.data

  val look : data -> kind_of_data
  val kool : kind_of_data -> data
  
  val mkUv : var -> level -> data
  val mkCon : name -> level -> data
  val mkDB : int -> data
  val mkBin : int -> data -> data
  val mkTup : data IA.t -> data
  val mkExt : C.data -> data

  val mkApp : data -> data IA.t -> int -> int -> data
  val fixTup : data IA.t -> data

  val equal : data -> data -> bool
  
  val fold : (data -> 'a -> 'a) -> data -> 'a -> 'a
  val map : (data -> data) -> data -> data
  val fold_map : (data -> 'a -> data * 'a) -> data -> 'a -> data * 'a
  
  val max_uv : data -> var -> var

  type program = clause list
  and clause = int * head * premise list
  and head = data
  and premise =
      Atom of data
    | Impl of data * premise
    | Pi of name * premise
    | Sigma of var * premise
  and goal = premise

  val map_premise : (data -> data) -> premise -> premise
  val fold_premise : (data -> 'a -> 'a) -> premise -> 'a -> 'a
  val fold_map_premise :
    (data -> 'a -> data * 'a) -> premise -> 'a -> premise * 'a

  val parse_program : string -> program
  val parse_goal : string -> goal
  val parse_data : string -> data

  val prf_data : name list -> Format.formatter -> data -> unit
  val prf_premise : name list -> Format.formatter -> premise -> unit
  val prf_goal : Format.formatter -> goal -> unit
  val prf_clause : Format.formatter -> clause -> unit
  val prf_program : Format.formatter -> program -> unit
  
  val string_of_data : ?ctx:string list -> data -> string
  val string_of_premise : premise -> string
  val string_of_goal : premise -> string
  val string_of_head : ?ctx:string list -> data -> name
  val string_of_clause : clause -> string
  val string_of_program : program -> string
end

module Subst : sig
  type subst

  (* takes the highest Uv in the goal *)
  val empty : int -> subst
  val apply_subst : subst -> LP.data -> LP.data
  val apply_subst_goal : subst -> LP.goal -> LP.goal
  val fresh_uv : LP.level -> subst -> LP.data * subst
  val set_sub : int -> LP.data -> subst -> subst
  val top : subst -> int
  val set_top : int -> subst -> subst
  
  val prf_subst : Format.formatter -> subst -> unit
  val string_of_subst : subst -> string
end

module Red : sig
  val lift : ?from:int -> int -> LP.data -> LP.data
  val beta : int -> LP.data -> int -> int -> LP.data IA.t -> LP.data
  val whd : Subst.subst -> LP.data -> LP.data * Subst.subst
  val nf : Subst.subst -> LP.data -> LP.data
end

