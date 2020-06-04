(*c7c51af0bc940c71755b1a9375a8fab7d247a0b6 *src/util.ml *)
#1 "src/util.ml"
module type Show  =
  sig type t val pp : Format.formatter -> t -> unit val show : t -> string
  end
module type Show1  =
  sig
    type 'a t
    val pp :
      (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit
    val show : (Format.formatter -> 'a -> unit) -> 'a t -> string
  end
module type Show2  =
  sig
    type ('a, 'b) t
    val pp :
      (Format.formatter -> 'a -> unit) ->
        (Format.formatter -> 'b -> unit) ->
          Format.formatter -> ('a, 'b) t -> unit
    val show :
      (Format.formatter -> 'a -> unit) ->
        (Format.formatter -> 'b -> unit) -> ('a, 'b) t -> string
  end
module Map =
  struct
    module type S  =
      sig include Map.S include Show1 with type 'a t :=  'a t end
    module type OrderedType  =
      sig include Map.OrderedType include Show with type  t :=  t end
    module Make(Ord:OrderedType) =
      struct
        include (Map.Make)(Ord)
        let pp f fmt m =
          Format.fprintf fmt "{{ @[<hov 2>";
          iter
            (fun k -> fun v -> Format.fprintf fmt "%a ->@ %a;@ " Ord.pp k f v)
            m;
          Format.fprintf fmt "@] }}"
        let show f m =
          let b = Buffer.create 20 in
          let fmt = Format.formatter_of_buffer b in
          pp f fmt m; Format.fprintf fmt "@?"; Buffer.contents b
      end
  end
module Set =
  struct
    module type S  = sig include Set.S include Show with type  t :=  t end
    module type OrderedType  =
      sig include Set.OrderedType include Show with type  t :=  t end
    module Make(Ord:OrderedType) =
      struct
        include (Set.Make)(Ord)
        let pp fmt m =
          Format.fprintf fmt "{{ @[<hov 2>";
          iter (fun x -> Format.fprintf fmt "%a;@ " Ord.pp x) m;
          Format.fprintf fmt "@] }}"
        let show m =
          let b = Buffer.create 20 in
          let fmt = Format.formatter_of_buffer b in
          pp fmt m; Format.fprintf fmt "@?"; Buffer.contents b
      end
  end
module Int =
  struct
    type t = int[@@deriving show]
    let rec pp :
              Ppx_deriving_runtime_proxy.Format.formatter ->
                t -> Ppx_deriving_runtime_proxy.unit
      =
      ((let open! Ppx_deriving_runtime_proxy in
          fun fmt -> Ppx_deriving_runtime_proxy.Format.fprintf fmt "%d")
      [@ocaml.warning "-A"])
    and show : t -> Ppx_deriving_runtime_proxy.string =
      fun x -> Ppx_deriving_runtime_proxy.Format.asprintf "%a" pp x[@@ocaml.warning
                                                               "-32"]
    let compare x y = x - y
  end
module String =
  struct
    include String
    let pp fmt s = Format.fprintf fmt "%s" s
    let show x = x
  end
module IntMap = (Map.Make)(Int)
module StrMap = (Map.Make)(String)
module IntSet = (Set.Make)(Int)
module StrSet = (Set.Make)(String)
module Fmt = Format
module Digest =
  struct
    include Digest
    let show = Digest.to_hex
    let pp fmt d = Fmt.fprintf fmt "%s" (show d)
  end
module Hashtbl =
  struct
    include Hashtbl
    let pp pa pb fmt h =
      Format.fprintf fmt "{{ @[<hov 2>";
      Hashtbl.iter
        (fun k -> fun v -> Format.fprintf fmt "%a -> %a;@ " pa k pb v) h;
      Format.fprintf fmt "@] }}"
    let show pa pb h =
      let b = Buffer.create 20 in
      let fmt = Format.formatter_of_buffer b in
      pp pa pb fmt h; Format.fprintf fmt "@?"; Buffer.contents b
  end
module Loc =
  struct
    type t =
      {
      source_name: string ;
      source_start: int ;
      source_stop: int ;
      line: int ;
      line_starts_at: int }[@@deriving (eq, ord)]
    let rec equal : t -> t -> Ppx_deriving_runtime_proxy.bool =
      ((let open! Ppx_deriving_runtime_proxy in
          fun lhs ->
            fun rhs ->
              (((((fun (a : string) -> fun b -> a = b) lhs.source_name
                    rhs.source_name)
                   &&
                   ((fun (a : int) -> fun b -> a = b) lhs.source_start
                      rhs.source_start))
                  &&
                  ((fun (a : int) -> fun b -> a = b) lhs.source_stop
                     rhs.source_stop))
                 && ((fun (a : int) -> fun b -> a = b) lhs.line rhs.line))
                &&
                ((fun (a : int) -> fun b -> a = b) lhs.line_starts_at
                   rhs.line_starts_at))
      [@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    let rec compare : t -> t -> Ppx_deriving_runtime_proxy.int =
      let __4 () (a : int) b = Ppx_deriving_runtime_proxy.compare a b
      and __3 () (a : int) b = Ppx_deriving_runtime_proxy.compare a b
      and __2 () (a : int) b = Ppx_deriving_runtime_proxy.compare a b
      and __1 () (a : int) b = Ppx_deriving_runtime_proxy.compare a b
      and __0 () (a : string) b = Ppx_deriving_runtime_proxy.compare a b in
      ((let open! Ppx_deriving_runtime_proxy in
          fun lhs ->
            fun rhs ->
              match (__0 ()) lhs.source_name rhs.source_name with
              | 0 ->
                  (match (__1 ()) lhs.source_start rhs.source_start with
                   | 0 ->
                       (match (__2 ()) lhs.source_stop rhs.source_stop with
                        | 0 ->
                            (match (__3 ()) lhs.line rhs.line with
                             | 0 ->
                                 (__4 ()) lhs.line_starts_at
                                   rhs.line_starts_at
                             | x -> x)
                        | x -> x)
                   | x -> x)
              | x -> x)
        [@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    let to_string
      { source_name; source_start; source_stop; line; line_starts_at } =
      let source = if source_name = "" then "" else source_name ^ ", " in
      let chars = Printf.sprintf "characters %d-%d" source_start source_stop in
      let pos =
        if line = (-1)
        then chars
        else
          Printf.sprintf "%s, line %d, column %d" chars line
            (source_stop - line_starts_at) in
      source ^ pos
    let pp fmt l = Fmt.fprintf fmt "%s" (to_string l)
    let show l = to_string l
    let initial source_name =
      {
        source_name;
        source_start = 0;
        source_stop = 0;
        line = 1;
        line_starts_at = 0
      }
  end
let pplist ?(max= max_int)  ?(boxed= false)  ppelem ?(pplastelem= ppelem) 
  sep f l =
  if l <> []
  then
    (if boxed then Fmt.fprintf f "@[<hov>";
     (let (args, last) =
        match List.rev l with
        | [] -> assert false
        | head::tail -> ((List.rev tail), head) in
      List.iteri
        (fun i ->
           fun x ->
             if i = (max + 1)
             then Fmt.fprintf f "..."
             else if i > max then () else Fmt.fprintf f "%a%s@," ppelem x sep)
        args;
      Fmt.fprintf f "%a" pplastelem last;
      if boxed then Fmt.fprintf f "@]"))
let rec smart_map f =
  function
  | [] -> []
  | hd::tl as l ->
      let hd' = f hd in
      let tl' = smart_map f tl in
      if (hd == hd') && (tl == tl') then l else hd' :: tl'
let rec uniqq =
  function
  | [] -> []
  | x::xs when List.memq x xs -> uniqq xs
  | x::xs -> x :: (uniqq xs)
let rec for_all3b p l1 l2 bl b =
  match (l1, l2, bl) with
  | ([], [], _) -> true
  | (a1::[], a2::[], []) -> p a1 a2 b
  | (a1::[], a2::[], b3::_) -> p a1 a2 b3
  | (a1::l1, a2::l2, []) -> (p a1 a2 b) && (for_all3b p l1 l2 bl b)
  | (a1::l1, a2::l2, b3::bl) -> (p a1 a2 b3) && (for_all3b p l1 l2 bl b)
  | (_, _, _) -> false
let rec for_all2 p l1 l2 =
  match (l1, l2) with
  | ([], []) -> true
  | (a1::[], a2::[]) -> p a1 a2
  | (a1::l1, a2::l2) -> (p a1 a2) && (for_all2 p l1 l2)
  | (_, _) -> false
let pp_loc_opt = function | None -> "" | Some loc -> (Loc.show loc) ^ ": "
let default_warn ?loc  s =
  Printf.eprintf "Warning: %s%s\n%!" (pp_loc_opt loc) s
let default_error ?loc  s =
  Printf.eprintf "Fatal error: %s%s\n%!" (pp_loc_opt loc) s; exit 1
let default_anomaly ?loc  s =
  let trace =
    match let open Printexc in (get_callstack max_int) |> backtrace_slots
    with
    | None -> ""
    | Some slots ->
        let lines = Array.mapi Printexc.Slot.format slots in
        let (_, lines_repetitions) =
          List.fold_left
            (fun (pos, acc) ->
               fun l ->
                 match l with
                 | None -> ((pos + 1), acc)
                 | Some _ when pos = 0 -> ((pos + 1), acc)
                 | Some l ->
                     (match acc with
                      | (l1, q)::acc when l = l1 ->
                          ((pos + 1), ((l1, (q + 1)) :: acc))
                      | _ -> ((pos + 1), ((l, 1) :: acc)))) (0, [])
            (Array.to_list lines) in
        let lines =
          lines_repetitions |>
            (List.map
               (function
                | (l, 1) -> l
                | (l, n) -> l ^ (Printf.sprintf " [%d times]" n))) in
        String.concat "\n" lines in
  Printf.eprintf "%s\nAnomaly: %s%s\n%!" trace (pp_loc_opt loc) s; exit 2
let default_type_error ?loc  s = default_error ?loc s
let default_printf = Printf.printf
let default_eprintf = Printf.eprintf
let warn_f = ref (Obj.repr default_warn)
let error_f = ref (Obj.repr default_error)
let anomaly_f = ref (Obj.repr default_anomaly)
let type_error_f = ref (Obj.repr default_type_error)
let std_fmt = ref Format.std_formatter
let err_fmt = ref Format.err_formatter
let set_formatters_maxcols i =
  Format.pp_set_margin (!std_fmt) i; Format.pp_set_margin (!err_fmt) i
let set_formatters_maxbox i =
  Format.pp_set_max_boxes (!std_fmt) i; Format.pp_set_max_boxes (!err_fmt) i
let set_warn f = warn_f := (Obj.repr f)
let set_error f = error_f := (Obj.repr f)
let set_anomaly f = anomaly_f := (Obj.repr f)
let set_type_error f = type_error_f := (Obj.repr f)
let set_std_formatter f = std_fmt := f
let set_err_formatter f = err_fmt := f
let warn ?loc  s = Obj.obj (!warn_f) ?loc s
let error ?loc  s = Obj.obj (!error_f) ?loc s
let anomaly ?loc  s = Obj.obj (!anomaly_f) ?loc s
let type_error ?loc  s = Obj.obj (!type_error_f) ?loc s
let printf x = Format.fprintf (!std_fmt) x
let eprintf x = Format.fprintf (!err_fmt) x
let option_get ?err  =
  function
  | Some x -> x
  | None -> (match err with | None -> assert false | Some msg -> anomaly msg)
let option_map f = function | Some x -> Some (f x) | None -> None
let option_mapacc f acc =
  function
  | Some x -> let (acc, y) = f acc x in (acc, (Some y))
  | None -> (acc, None)
let option_iter f = function | None -> () | Some x -> f x
module Option =
  struct
    type 'a t = 'a option =
      | None 
      | Some of 'a [@@deriving show]
    let rec pp :
              'a .
                (Ppx_deriving_runtime_proxy.Format.formatter ->
                   'a -> Ppx_deriving_runtime_proxy.unit)
                  ->
                  Ppx_deriving_runtime_proxy.Format.formatter ->
                    'a t -> Ppx_deriving_runtime_proxy.unit
      =
      ((let open! Ppx_deriving_runtime_proxy in
          fun poly_a ->
            fun fmt ->
              function
              | None ->
                  Ppx_deriving_runtime_proxy.Format.pp_print_string fmt "None"
              | Some a0 ->
                  (Ppx_deriving_runtime_proxy.Format.fprintf fmt "(@[<2>Some@ ";
                   (poly_a fmt) a0;
                   Ppx_deriving_runtime_proxy.Format.fprintf fmt "@])"))
      [@ocaml.warning "-A"])
    and show :
      'a .
        (Ppx_deriving_runtime_proxy.Format.formatter ->
           'a -> Ppx_deriving_runtime_proxy.unit)
          -> 'a t -> Ppx_deriving_runtime_proxy.string
      =
      fun poly_a ->
        fun x -> Ppx_deriving_runtime_proxy.Format.asprintf "%a" (pp poly_a) x
    [@@ocaml.warning "-32"]
  end
module Pair =
  struct
    type ('a, 'b) t = ('a * 'b)[@@deriving show]
    let rec pp :
              'a 'b .
                (Ppx_deriving_runtime_proxy.Format.formatter ->
                   'a -> Ppx_deriving_runtime_proxy.unit)
                  ->
                  (Ppx_deriving_runtime_proxy.Format.formatter ->
                     'b -> Ppx_deriving_runtime_proxy.unit)
                    ->
                    Ppx_deriving_runtime_proxy.Format.formatter ->
                      ('a, 'b) t -> Ppx_deriving_runtime_proxy.unit
      =
      ((let open! Ppx_deriving_runtime_proxy in
          fun poly_a ->
            fun poly_b ->
              fun fmt ->
                fun (a0, a1) ->
                  Ppx_deriving_runtime_proxy.Format.fprintf fmt "(@[";
                  ((poly_a fmt) a0;
                   Ppx_deriving_runtime_proxy.Format.fprintf fmt ",@ ";
                   (poly_b fmt) a1);
                  Ppx_deriving_runtime_proxy.Format.fprintf fmt "@])")
      [@ocaml.warning "-A"])
    and show :
      'a 'b .
        (Ppx_deriving_runtime_proxy.Format.formatter ->
           'a -> Ppx_deriving_runtime_proxy.unit)
          ->
          (Ppx_deriving_runtime_proxy.Format.formatter ->
             'b -> Ppx_deriving_runtime_proxy.unit)
            -> ('a, 'b) t -> Ppx_deriving_runtime_proxy.string
      =
      fun poly_a ->
        fun poly_b ->
          fun x ->
            Ppx_deriving_runtime_proxy.Format.asprintf "%a" ((pp poly_a) poly_b) x
    [@@ocaml.warning "-32"]
  end
let pp_option f fmt = function | None -> () | Some x -> f fmt x
let pp_int = Int.pp
let pp_string = String.pp
let pp_pair = Pair.pp
let remove_from_list x =
  let rec aux acc =
    function
    | [] -> anomaly "Element to be removed not in the list"
    | y::tl when x == y -> (List.rev acc) @ tl
    | y::tl -> aux (y :: acc) tl in
  aux []
let rec map_exists f =
  function
  | [] -> None
  | hd::tl -> (match f hd with | None -> map_exists f tl | res -> res)
let rec map_filter f =
  function
  | [] -> []
  | hd::tl ->
      (match f hd with
       | None -> map_filter f tl
       | Some res -> res :: (map_filter f tl))
let map_acc f acc l =
  let (a, l) =
    List.fold_left
      (fun (a, xs) -> fun x -> let (a, x) = f a x in (a, (x :: xs)))
      (acc, []) l in
  (a, (List.rev l))
let map_acc2 f acc l1 l2 =
  let (a, l) =
    List.fold_left2
      (fun (a, xs) ->
         fun x -> fun y -> let (a, x) = f a x y in (a, (x :: xs))) (acc, [])
      l1 l2 in
  (a, (List.rev l))
let map_acc3 f acc l1 l2 l3 =
  let rec aux a l l1 l2 l3 =
    match (l1, l2, l3) with
    | ([], [], []) -> (a, (List.rev l))
    | (x::xs, y::ys, z::zs) ->
        let (a, v) = f a x y z in aux a (v :: l) xs ys zs
    | _ -> invalid_arg "map_acc3" in
  aux acc [] l1 l2 l3
let partition_i f l =
  let rec aux n a1 a2 =
    function
    | [] -> ((List.rev a1), (List.rev a2))
    | x::xs ->
        if f n x
        then aux (n + 1) (x :: a1) a2 xs
        else aux (n + 1) a1 (x :: a2) xs in
  aux 0 [] [] l
let fold_left2i f acc l1 l2 =
  let rec aux n acc l1 l2 =
    match (l1, l2) with
    | ([], []) -> acc
    | (x::xs, y::ys) -> aux (n + 1) (f n acc x y) xs ys
    | _ -> anomaly "fold_left2i" in
  aux 0 acc l1 l2
let rec uniq =
  function
  | [] -> []
  | _::[] as x -> x
  | x::(y::_ as tl) -> if x = y then uniq tl else x :: (uniq tl)
module Global :
  sig
    type backup
    val new_local : 'a -> 'a ref
    val backup : unit -> backup
    val restore : backup -> unit
    val initial_backup : unit -> backup
    val set_value : 'a ref -> 'a -> backup -> backup
    val get_value : 'a ref -> backup -> 'a
  end =
  struct
    type backup = (Obj.t ref * Obj.t) list
    let all_globals : backup ref = ref []
    let new_local (t : 'a) =
      (let res = ref t in
       all_globals := ((Obj.magic (res, t)) :: (!all_globals)); res : 
      'a ref)
    let set_value (g : 'a ref) (v : 'a) (l : (Obj.t ref * Obj.t) list) =
      let v = Obj.repr v in
      let g : Obj.t ref = Obj.magic g in
      List.map (fun ((g', _) as orig) -> if g == g' then (g, v) else orig) l
    let get_value (p : 'a ref) (l : (Obj.t ref * Obj.t) list) =
      (Obj.magic (List.assq (Obj.magic p) l) : 'a)
    let backup () =
      (List.map (fun (o, _) -> (o, (!o))) (!all_globals) : (Obj.t ref *
                                                             Obj.t) list)
    let restore l = List.iter (fun (r, v) -> r := v) l
    let initial_backup () = !all_globals
  end 
module Fork =
  struct
    type 'a local_ref = 'a ref
    type process =
      {
      exec: 'a 'b . ('a -> 'b) -> 'a -> 'b ;
      get: 'a . 'a local_ref -> 'a ;
      set: 'a . 'a local_ref -> 'a -> unit }
    let new_local = Global.new_local
    let fork () =
      let saved_globals = Global.backup () in
      let my_globals = ref (Global.initial_backup ()) in
      let ensure_runtime f x =
        Global.restore (!my_globals);
        (try
           let rc = f x in
           my_globals := (Global.backup ()); Global.restore saved_globals; rc
         with
         | e ->
             (my_globals := (Global.backup ());
              Global.restore saved_globals;
              raise e)) in
      {
        exec = ensure_runtime;
        get = (fun p -> Global.get_value p (!my_globals));
        set =
          (fun p ->
             fun v -> my_globals := (Global.set_value p v (!my_globals)))
      }
  end
module UUID =
  struct
    module Self =
      struct
        type t = int[@@deriving (show, eq, ord)]
        let rec pp :
                  Ppx_deriving_runtime_proxy.Format.formatter ->
                    t -> Ppx_deriving_runtime_proxy.unit
          =
          ((let open! Ppx_deriving_runtime_proxy in
              fun fmt -> Ppx_deriving_runtime_proxy.Format.fprintf fmt "%d")
          [@ocaml.warning "-A"])
        and show : t -> Ppx_deriving_runtime_proxy.string =
          fun x -> Ppx_deriving_runtime_proxy.Format.asprintf "%a" pp x[@@ocaml.warning
                                                                   "-32"]
        let rec equal : t -> t -> Ppx_deriving_runtime_proxy.bool =
          ((let open! Ppx_deriving_runtime_proxy in fun (a : int) -> fun b -> a = b)
          [@ocaml.warning "-A"])[@@ocaml.warning "-39"]
        let rec compare : t -> t -> Ppx_deriving_runtime_proxy.int =
          let __0 () (a : int) b = Ppx_deriving_runtime_proxy.compare a b in
          ((let open! Ppx_deriving_runtime_proxy in __0 ())[@ocaml.warning "-A"])
          [@@ocaml.warning "-39"]
        let hash x = x
      end
    let counter = ref 0
    let make () = incr counter; !counter
    module Htbl = (Hashtbl.Make)(Self)
    include Self
  end
type 'a spaghetti_printer = (Format.formatter -> 'a -> unit) ref
let mk_spaghetti_printer () =
  ref (fun fmt -> fun _ -> Fmt.fprintf fmt "please extend this printer")
let set_spaghetti_printer r f = r := f
let pp_spaghetti r fmt x = (!r) fmt x
let show_spaghetti r x =
  let b = Buffer.create 20 in
  let fmt = Format.formatter_of_buffer b in
  Format.fprintf fmt "%a%!" (!r) x; Buffer.contents b
let pp_spaghetti_any r ~id  fmt x = (!r) fmt (id, (Obj.repr x))
module CData =
  struct
    type t = {
      t: Obj.t ;
      ty: int }
    type tt = t
    type 'a data_declaration =
      {
      data_name: string ;
      data_pp: Format.formatter -> 'a -> unit ;
      data_compare: 'a -> 'a -> int ;
      data_hash: 'a -> int ;
      data_hconsed: bool }
    type 'a cdata =
      {
      cin: 'a -> t ;
      isc: t -> bool ;
      cout: t -> 'a ;
      name: string }
    type cdata_declaration =
      {
      cdata_name: string ;
      cdata_pp: Format.formatter -> t -> unit ;
      cdata_compare: t -> t -> int ;
      cdata_hash: t -> int ;
      cdata_canon: t -> t }
    let m : cdata_declaration IntMap.t ref = ref IntMap.empty
    let cget x = Obj.obj x.t
    let pp f x = (IntMap.find x.ty (!m)).cdata_pp f x
    let equal x y =
      (x.ty = y.ty) && (((IntMap.find x.ty (!m)).cdata_compare x y) == 0)
    let compare x y =
      if x.ty = y.ty
      then (IntMap.find x.ty (!m)).cdata_compare x y
      else type_error "cdata of different type compared"
    let hash x = (IntMap.find x.ty (!m)).cdata_hash x
    let name x = (IntMap.find x.ty (!m)).cdata_name
    let hcons x = (IntMap.find x.ty (!m)).cdata_canon x
    let ty2 { isc } ({ ty = t1 } as x) { ty = t2 } = (isc x) && (t1 = t2)
    let show x =
      let b = Buffer.create 22 in
      Format.fprintf (Format.formatter_of_buffer b) "@[%a@]" pp x;
      Buffer.contents b
    let fresh_tid = let tid = ref 0 in fun () -> incr tid; !tid
    let declare { data_compare; data_pp; data_hash; data_name; data_hconsed }
      =
      let tid = fresh_tid () in
      let cdata_compare x y = data_compare (cget x) (cget y) in
      let cdata_hash x = data_hash (cget x) in
      let cdata_canon =
        if data_hconsed
        then
          let module CD =
            (struct
               type t = tt
               let hash = cdata_hash
               let equal x y = (cdata_compare x y) == 0
             end : Hashtbl.HashedType with type  t =  tt) in
            let module HS = ((Weak.Make)(CD) : Weak.S with type  data =  tt)
              in
              let h = HS.create 17 in
              fun x -> try HS.find h x with | Not_found -> (HS.add h x; x)
        else (fun x -> x) in
      let cdata_compare_hconsed =
        if data_hconsed
        then fun x -> fun y -> (if x == y then 0 else cdata_compare x y)
        else cdata_compare in
      m :=
        (IntMap.add tid
           {
             cdata_name = data_name;
             cdata_pp = (fun f -> fun x -> data_pp f (cget x));
             cdata_compare = cdata_compare_hconsed;
             cdata_hash;
             cdata_canon
           } (!m));
      {
        cin = ((fun v -> cdata_canon { t = (Obj.repr v); ty = tid }));
        isc = ((fun c -> c.ty = tid));
        cout = ((fun c -> assert (c.ty = tid); cget c));
        name = data_name
      }
    let morph1 { cin; cout } f x = cin (f (cout x))
    let morph2 { cin; cout } f x y = cin (f (cout x) (cout y))
    let map { cout } { cin } f x = cin (f (cout x))
  end
module PtrMap =
  struct
    type 'a t =
      {
      mutable cache: (Obj.t * 'a) IntMap.t ;
      authoritative: (Obj.t * ('a * int ref)) list }
    let empty () = { cache = IntMap.empty; authoritative = [] }
    let is_empty { authoritative } = authoritative = []
    let address_of =
      match Sys.backend_type with
      | Sys.Bytecode|Sys.Native ->
          (fun (ro : Obj.t) ->
             (assert (Obj.is_block ro); (let a : int = Obj.magic ro in - a) : 
             int))
      | Sys.Other _ -> (fun _ -> 46)
    let add o v { cache; authoritative } =
      let ro = Obj.repr o in
      let address = address_of ro in
      {
        cache = (IntMap.add address (ro, v) cache);
        authoritative = ((ro, (v, (ref address))) :: authoritative)
      }
    let linear_search_and_cache ro address cache authoritative orig =
      let (v, old_address) = List.assq ro authoritative in
      orig.cache <-
        (IntMap.add address (ro, v) (IntMap.remove (!old_address) cache));
      old_address := address;
      v
    let linear_scan_attempted = ref false
    let find o ({ cache; authoritative } as orig) =
      linear_scan_attempted := false;
      (let ro = Obj.repr o in
       let address = address_of ro in
       try
         let (ro', v) = IntMap.find address cache in
         if ro' == ro
         then v
         else
           (let cache = IntMap.remove address cache in
            linear_scan_attempted := true;
            linear_search_and_cache ro address cache authoritative orig)
       with
       | Not_found when not (!linear_scan_attempted) ->
           linear_search_and_cache ro address cache authoritative orig)
    let remove o { cache; authoritative } =
      let ro = Obj.repr o in
      let address = address_of ro in
      let (_, old_address) = List.assq ro authoritative in
      let authoritative = List.remove_assq ro authoritative in
      let cache = IntMap.remove address cache in
      let cache =
        if (!old_address) != address
        then IntMap.remove (!old_address) cache
        else cache in
      { cache; authoritative }
    let filter f { cache; authoritative } =
      let cache = ref cache in
      let authoritative =
        authoritative |>
          (List.filter
             (fun (o, (v, old_address)) ->
                let keep = f (Obj.obj o) v in
                if not keep
                then
                  (let address = address_of o in
                   cache := (IntMap.remove address (!cache));
                   if (!old_address) != address
                   then cache := (IntMap.remove (!old_address) (!cache)));
                keep)) in
      { cache = (!cache); authoritative }
    let pp f fmt { authoritative } =
      pplist (fun fmt -> fun (_, (x, _)) -> f fmt x) ";" fmt authoritative
    let show f m = Format.asprintf "%a" (pp f) m
  end
