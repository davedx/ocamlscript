[@@@warning "-a"]
include
  struct
    module Js_op =
      struct
        [@@@ocaml.text " Define some basic types used in JS IR "]
        type binop =
          | Eq
          | Or
          | And
          | EqEqEq
          | NotEqEq
          | Lt
          | Le
          | Gt
          | Ge
          | Bor
          | Bxor
          | Band
          | Lsl
          | Lsr
          | Asr
          | Plus
          | Minus
          | Mul
          | Div
          | Mod
        type int_op =
          | Bor
          | Bxor
          | Band
          | Lsl
          | Lsr
          | Asr
          | Plus
          | Minus
          | Mul
          | Div
          | Mod
        type level =
          | Log
          | Info
          | Warn
          | Error
        type kind =
          | Ml
          | Runtime
          | External of string
        type property =
          | Mutable
          | Immutable
        type int_or_char = {
          i: int;
          c: char option;}
        type number =
          | Float of float
          | Int of int_or_char
        type mutable_flag =
          | Mutable
          | Immutable
          | NA
        type recursive_info =
          | SingleRecursive
          | NonRecursie
          | NA
        type used_stats =
          | Dead_pure
          | Dead_non_pure
          | Exported
          | Used
          | Scanning_pure
          | Scanning_non_pure
          | NA
        type ident_info = {
          mutable used_stats: used_stats;}
        type exports = Ident.t list
        type required_modules = (Ident.t* string) list[@@ocaml.doc
                                                        " TODO: define constant - for better constant folding  "]
      end
    module Ext_format :
      sig
        [@@@ocaml.text
          " Simplified wrapper module for the standard library [Format] module. \n  "]
        type t = private Format.formatter
        val string : t -> string -> unit
        val break : t -> unit
        val break1 : t -> unit
        val space : t -> unit
        val group : t -> int -> (unit -> 'a) -> 'a[@@ocaml.doc
                                                    " [group] will record current indentation \n    and indent futher\n "]
        val vgroup : t -> int -> (unit -> 'a) -> 'a
        val paren : t -> (unit -> 'a) -> 'a
        val paren_group : t -> int -> (unit -> 'a) -> 'a
        val brace_group : t -> int -> (unit -> 'a) -> 'a
        val brace_vgroup : t -> int -> (unit -> 'a) -> 'a
        val bracket_group : t -> int -> (unit -> 'a) -> 'a
        val newline : t -> unit
        val to_out_channel : out_channel -> t
        val flush : t -> unit -> unit
      end =
      struct
        open Format
        type t = formatter
        let string = pp_print_string
        let break fmt = pp_print_break fmt 0 0
        let break1 fmt = pp_print_break fmt 0 1
        let space fmt = pp_print_break fmt 1 0
        let vgroup fmt indent u =
          pp_open_vbox fmt indent; (let v = u () in pp_close_box fmt (); v)
        let group fmt indent u =
          pp_open_hovbox fmt indent; (let v = u () in pp_close_box fmt (); v)
        let paren fmt u = string fmt "("; (let v = u () in string fmt ")"; v)
        let brace fmt u = string fmt "{"; (let v = u () in string fmt "}"; v)
        let bracket fmt u =
          string fmt "["; (let v = u () in string fmt "]"; v)
        let paren_group st n action = group st n (fun _  -> paren st action)
        let brace_group st n action = group st n (fun _  -> brace st action)
        let brace_vgroup st n action =
          vgroup st n
            (fun _  ->
               string st "{";
               pp_print_break st 0 2;
               (let v = vgroup st 0 action in
                pp_print_break st 0 0; string st "}"; v))
        let bracket_group st n action =
          group st n (fun _  -> bracket st action)
        let newline fmt = pp_print_newline fmt ()
        let to_out_channel = formatter_of_out_channel
        let flush = pp_print_flush
        let list = pp_print_list
      end 
    module Ident_set :
      sig
        [@@@ocaml.text " Set with key specialized as [Ident.t] type\n "]
        [@@@ocaml.text
          " Original set module enhanced with some utilities, \n    note that it's incompatible with [Lambda.IdentSet] \n "]
        include (Set.S with type  elt =  Ident.t)
        val print : Ext_format.t -> t -> unit
      end =
      struct
        include
          Set.Make(struct
                     type t = Ident.t
                     let compare = Pervasives.compare
                   end)
        let print ppf v =
          let open Ext_format in
            brace_vgroup ppf 0
              (fun _  ->
                 iter
                   (fun v  ->
                      string ppf
                        (Printf.sprintf "%s/%d" v.Ident.name v.stamp);
                      Ext_format.space ppf) v)
      end 
    module Ext_list :
      sig
        [@@@ocaml.text " Extension to the standard library [List] module "]
        [@@@ocaml.text
          " TODO some function are no efficiently implemented. "]
        val filter_map : ('a -> 'b option) -> 'a list -> 'b list
        val same_length : 'a list -> 'b list -> bool
        val init : int -> (int -> 'a) -> 'a list
        val take : int -> 'a list -> ('a list* 'a list)
        val exclude_tail : 'a list -> 'a list
        val filter_map2 :
          ('a -> 'b -> 'c option) -> 'a list -> 'b list -> 'c list
        val filter_map2i :
          (int -> 'a -> 'b -> 'c option) -> 'a list -> 'b list -> 'c list
        val filter_mapi : (int -> 'a -> 'b option) -> 'a list -> 'b list
        val flat_map2 :
          ('a -> 'b -> 'c list) -> 'a list -> 'b list -> 'c list
        val flat_map : ('a -> 'b list) -> 'a list -> 'b list
        val flat_map2_last :
          (bool -> 'a -> 'b -> 'c list) -> 'a list -> 'b list -> 'c list
        val map_last : (bool -> 'a -> 'b) -> 'a list -> 'b list
        val stable_group : ('a -> 'a -> bool) -> 'a list -> 'a list list
        val drop : int -> 'a list -> 'a list
        val for_all_ret : ('a -> bool) -> 'a list -> 'a option
        val for_all_opt : ('a -> 'b option) -> 'a list -> 'b option[@@ocaml.doc
                                                                    " [for_all_opt f l] returns [None] if all return [None],  \n    otherwise returns the first one. \n "]
        val fold : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b[@@ocaml.doc
                                                            " same as [List.fold_left]. \n    Provide an api so that list can be easily swapped by other containers  \n "]
        val rev_map_append : ('a -> 'b) -> 'a list -> 'b list -> 'b list
        val rev_map_acc : 'a list -> ('b -> 'a) -> 'b list -> 'a list
      end =
      struct
        let rec filter_map (f : 'a -> 'b option) xs =
          match xs with
          | [] -> []
          | y::ys ->
              (match f y with
               | None  -> filter_map f ys
               | Some z -> z :: (filter_map f ys))
        let rec same_length xs ys =
          match (xs, ys) with
          | ([],[]) -> true
          | (_::xs,_::ys) -> same_length xs ys
          | (_,_) -> false
        let filter_mapi (f : int -> 'a -> 'b option) xs =
          let rec aux i xs =
            match xs with
            | [] -> []
            | y::ys ->
                (match f i y with
                 | None  -> aux (i + 1) ys
                 | Some z -> z :: (aux (i + 1) ys)) in
          aux 0 xs
        let rec filter_map2 (f : 'a -> 'b -> 'c option) xs ys =
          match (xs, ys) with
          | ([],[]) -> []
          | (u::us,v::vs) ->
              (match f u v with
               | None  -> filter_map2 f us vs
               | Some z -> z :: (filter_map2 f us vs))
          | _ -> invalid_arg "Ext_list.filter_map2"
        let filter_map2i (f : int -> 'a -> 'b -> 'c option) xs ys =
          let rec aux i xs ys =
            match (xs, ys) with
            | ([],[]) -> []
            | (u::us,v::vs) ->
                (match f i u v with
                 | None  -> aux (i + 1) us vs
                 | Some z -> z :: (aux (i + 1) us vs))
            | _ -> invalid_arg "Ext_list.filter_map2i" in
          aux 0 xs ys
        let rec rev_map_append f l1 l2 =
          match l1 with | [] -> l2 | a::l -> rev_map_append f l ((f a) :: l2)
        let flat_map2 f lx ly =
          let rec aux acc lx ly =
            match (lx, ly) with
            | ([],[]) -> List.rev acc
            | (x::xs,y::ys) -> aux (List.rev_append (f x y) acc) xs ys
            | (_,_) -> invalid_arg "Ext_list.flat_map2" in
          aux [] lx ly
        let flat_map f lx =
          let rec aux acc lx =
            match lx with
            | [] -> List.rev acc
            | y::ys -> aux (List.rev_append (f y) acc) ys in
          aux [] lx
        let rec map2_last f l1 l2 =
          match (l1, l2) with
          | ([],[]) -> []
          | (u::[],v::[]) -> [f true u v]
          | (a1::l1,a2::l2) ->
              let r = f false a1 a2 in r :: (map2_last f l1 l2)
          | (_,_) -> invalid_arg "List.map2_last"
        let rec map_last f l1 =
          match l1 with
          | [] -> []
          | u::[] -> [f true u]
          | a1::l1 -> let r = f false a1 in r :: (map_last f l1)
        let flat_map2_last f lx ly = List.concat @@ (map2_last f lx ly)
        let init n f = Array.to_list (Array.init n f)
        let take n l =
          let arr = Array.of_list l in
          let arr_length = Array.length arr in
          if arr_length < n
          then invalid_arg "Ext_list.take"
          else
            ((Array.to_list (Array.sub arr 0 n)),
              (Array.to_list (Array.sub arr n (arr_length - n))))
        let exclude_tail (x : 'a list) =
          (let rec aux acc x =
             match x with
             | [] -> invalid_arg "Ext_list.exclude_tail"
             | _::[] -> List.rev acc
             | y0::ys -> aux (y0 :: acc) ys in
           aux [] x : 'a list)
        let rec group (cmp : 'a -> 'a -> bool) (lst : 'a list) =
          (match lst with | [] -> [] | x::xs -> aux cmp x (group cmp xs) : 
          'a list list)
        and aux cmp (x : 'a) (xss : 'a list list) =
          (match xss with
           | [] -> [[x]]
           | y::ys ->
               if cmp x (List.hd y)
               then (x :: y) :: ys
               else y :: (aux cmp x ys) : 'a list list)
        let stable_group cmp lst = (group cmp lst) |> List.rev
        let rec drop n h =
          if n < 0
          then invalid_arg "Ext_list.drop"
          else
            if n = 0
            then h
            else
              if h = []
              then invalid_arg "Ext_list.drop"
              else drop (n - 1) (List.tl h)
        let rec for_all_ret p =
          function
          | [] -> None
          | a::l -> if p a then for_all_ret p l else Some a
        let rec for_all_opt p =
          function
          | [] -> None
          | a::l -> (match p a with | None  -> for_all_opt p l | v -> v)
        let fold f l init =
          List.fold_left (fun acc  -> fun i  -> f i init) init l
        let rev_map_acc acc f l =
          let rec rmap_f accu =
            function | [] -> accu | a::l -> rmap_f ((f a) :: accu) l in
          rmap_f acc l
      end 
    module Js_fun_env :
      sig
        [@@@ocaml.text
          " Define type t used in JS IR to collect some meta data for a function, like its closures, etc \n  "]
        type t
        val empty : ?immutable_mask:bool array -> int -> t
        val is_tailcalled : t -> bool
        val is_empty : t -> bool
        val set_bound : t -> Ident_set.t -> unit
        val get_bound : t -> Ident_set.t
        val set_lexical_scope : t -> Ident_set.t -> unit
        val get_lexical_scope : t -> Ident_set.t
        val to_string : t -> string
        val mark_unused : t -> int -> unit
        val get_unused : t -> int -> bool
        val get_mutable_params : Ident.t list -> t -> Ident.t list
        val get_bound : t -> Ident_set.t
        val get_length : t -> int
      end =
      struct
        type immutable_mask =
          |
          All_immutable_and_no_tail_call[@ocaml.doc
                                          " iff not tailcalled \n         if tailcalled, in theory, it does not need change params, \n         for example\n         {[\n         let rec f  (n : int ref) = \n            if !n > 0 then decr n; print_endline \"hi\"\n            else  f n\n         ]}\n         in this case, we still create [Immutable_mask], \n         since the inline behavior is slightly different\n      "]
          | Immutable_mask of bool array
        type t =
          {
          mutable bound: Ident_set.t;
          mutable bound_loop_mutable_values: Ident_set.t;
          used_mask: bool array;
          immutable_mask: immutable_mask;}[@@ocaml.doc
                                            " Invariant: unused param has to be immutable "]
        let empty ?immutable_mask  n =
          {
            bound = Ident_set.empty;
            used_mask = (Array.make n false);
            immutable_mask =
              (match immutable_mask with
               | Some x -> Immutable_mask x
               | None  -> All_immutable_and_no_tail_call);
            bound_loop_mutable_values = Ident_set.empty
          }
        let is_tailcalled x =
          x.immutable_mask != All_immutable_and_no_tail_call
        let mark_unused t i = (t.used_mask).(i) <- true
        let get_unused t i = (t.used_mask).(i)
        let get_length t = Array.length t.used_mask
        let to_string env =
          String.concat ","
            (List.map
               (fun (id : Ident.t)  ->
                  Printf.sprintf "%s/%d" id.name id.stamp)
               (Ident_set.elements env.bound))
        let get_mutable_params (params : Ident.t list) (x : t) =
          match x.immutable_mask with
          | All_immutable_and_no_tail_call  -> []
          | Immutable_mask xs ->
              Ext_list.filter_mapi
                (fun i  -> fun p  -> if not (xs.(i)) then Some p else None)
                params
        let get_bound t = t.bound
        let set_bound env v = env.bound <- v
        let set_lexical_scope env bound_loop_mutable_values =
          env.bound_loop_mutable_values <- bound_loop_mutable_values
        let get_lexical_scope env = env.bound_loop_mutable_values
        let is_empty t = Ident_set.is_empty t.bound
      end 
    module Js_closure :
      sig
        [@@@ocaml.text
          " Define a type used in JS IR to help convert lexical scope to JS [var] \n    based scope convention\n "]
        type t = {
          mutable outer_loop_mutable_values: Ident_set.t;}
        val empty : unit -> t
        val get_lexical_scope : t -> Ident_set.t
        val set_lexical_scope : t -> Ident_set.t -> unit
      end =
      struct
        type t = {
          mutable outer_loop_mutable_values: Ident_set.t;}
        let empty () = { outer_loop_mutable_values = Ident_set.empty }
        let set_lexical_scope t v = t.outer_loop_mutable_values <- v
        let get_lexical_scope t = t.outer_loop_mutable_values
      end 
    module Js_call_info :
      sig
        [@@@ocaml.text
          " Type for collecting call site information, used in JS IR "]
        type arity =
          | Full
          | NA
        type t = {
          arity: arity;}
        val dummy : t
      end =
      struct
        type arity =
          | Full
          | NA
        type t = {
          arity: arity;}
        let dummy = { arity = NA }
      end 
    module J =
      struct
        [@@@ocaml.text
          " Javascript IR\n  \n    It's a subset of Javascript AST specialized for OCaml lambda backend\n\n    Note it's not exactly the same as Javascript, the AST itself follows lexical\n    convention and [Block] is just a sequence of statements, which means it does \n    not introduce new scope\n"]
        type label = string
        and binop = Js_op.binop
        and int_op = Js_op.int_op
        and kind = Js_op.kind
        and property = Js_op.property
        and number = Js_op.number
        and mutable_flag = Js_op.mutable_flag
        and ident_info = Js_op.ident_info
        and exports = Js_op.exports
        and required_modules = Js_op.required_modules
        and property_name = string[@@ocaml.doc
                                    " object literal, if key is ident, in this case, it might be renamed by \n    Google Closure  optimizer,\n    currently we always use quote\n "]
        and ident = Ident.t
        and vident =
          | Id of ident
          | Qualified of ident* kind* string option
        and exception_ident = ident
        and for_ident = ident
        and for_direction = Asttypes.direction_flag
        and property_map = (property_name* expression) list
        and expression_desc =
          | Math of string* expression list
          | Array_length of expression
          | String_length of expression
          | Bytes_length of expression
          | Function_length of expression
          | Char_of_int of expression
          | Char_to_int of expression
          | Array_of_size of expression
          | Array_append of expression* expression list
          | Tag_ml_obj of expression
          | String_append of expression* expression
          | Int_of_boolean of expression
          | Is_type_number of expression
          | Not of expression
          | String_of_small_int_array of expression
          | Dump of Js_op.level* expression list
          | Seq of expression* expression
          | Cond of expression* expression* expression
          | Bin of binop* expression* expression
          | FlatCall of expression* expression
          | Call of expression* expression list* Js_call_info.t
          | String_access of expression* expression
          | Access of expression* expression
          | Dot of expression* string* bool
          | New of expression* expression list option
          | Var of vident
          | Fun of ident list* block* Js_fun_env.t
          | Str of bool* string
          | Array of expression list* mutable_flag
          | Number of number
          | Object of property_map
        and for_ident_expression = expression
        and finish_ident_expression = expression
        and statement_desc =
          | Block of block
          | Variable of variable_declaration
          | Exp of expression
          | If of expression* block* block option
          | While of label option* expression* block* Js_closure.t
          | ForRange of for_ident_expression option* finish_ident_expression*
          for_ident* for_direction* block* Js_closure.t
          | Continue of label
          | Break
          | Return of return_expression
          | Int_switch of expression* int case_clause list* block option
          | String_switch of expression* string case_clause list* block
          option
          | Throw of expression
          | Try of block* (exception_ident* block) option* block option
        and return_expression = {
          return_value: expression;}
        and expression =
          {
          expression_desc: expression_desc;
          comment: string option;}
        and statement =
          {
          statement_desc: statement_desc;
          comment: string option;}
        and variable_declaration =
          {
          ident: ident;
          value: expression option;
          property: property;
          ident_info: ident_info;}
        and 'a case_clause = {
          case: 'a;
          body: (block* bool);}
        and block = statement list
        and program =
          {
          name: string;
          modules: required_modules;
          block: block;
          exports: exports;
          export_set: Ident_set.t;
          side_effect: string option;}
      end
    module Lam_module_ident :
      sig
        [@@@ocaml.text " A type for qualified identifiers in Lambda IR \n "]
        type t = private {
          id: Ident.t;
          kind: Js_op.kind;}
        val id : t -> Ident.t
        val name : t -> string
        val mk : J.kind -> Ident.t -> t
        val of_ml : Ident.t -> t
        val of_external : Ident.t -> string -> t
        val of_runtime : Ident.t -> t
      end =
      struct
        type t = {
          id: Ident.t;
          kind: Js_op.kind;}
        let id x = x.id
        let of_ml id = { id; kind = Ml }
        let of_external id name = { id; kind = (External name) }
        let of_runtime id = { id; kind = Runtime }
        let mk kind id = { id; kind }
        let name x =
          (match (x.kind : J.kind) with
           | Ml |Runtime  -> (x.id).name
           | External v -> v : string)
        type module_property = bool
      end 
    module Hash_set :
      sig
        [@@@ocaml.text
          " A naive hashset implementation on top of [hashtbl], the value is [unit]"]
        type 'a hashset
        val create : ?random:bool -> int -> 'a hashset
        val clear : 'a hashset -> unit
        val reset : 'a hashset -> unit
        val copy : 'a hashset -> 'a hashset
        val add : 'a hashset -> 'a -> unit
        val mem : 'a hashset -> 'a -> bool
        val iter : ('a -> unit) -> 'a hashset -> unit
        val elements : 'a hashset -> 'a list
      end =
      struct
        include Hashtbl
        type 'a hashset = ('a,unit) Hashtbl.t
        let add tbl k = replace tbl k ()
        let iter f = iter (fun k  -> fun _  -> f k)
        let elements set =
          fold (fun k  -> fun _  -> fun acc  -> k :: acc) set []
      end 
    module Lam_stats :
      sig
        [@@@ocaml.text " Types defined for lambda analysis "]
        type function_arities =
          | Determin of bool* (int* Ident.t list) list*
          bool[@ocaml.doc
                " when the first argument is true, it is for sure \n      approximation sound but not complete \n      \n      the last one means it can take any params later, \n      for an exception: it is (Determin (true,[], true))\n   "]
          | NA
        type alias_tbl = (Ident.t,Ident.t) Hashtbl.t[@@ocaml.doc
                                                      " Keep track of which identifiers are aliased\n  "]
        type state =
          | Live[@ocaml.doc " Globals are always live "]
          | Dead[@ocaml.doc " removed after elimination "]
          | NA
        type function_kind =
          | Functor
          | Function
          | NA
        type function_id =
          {
          kind: function_kind;
          mutable arity: function_arities;
          lambda: Lambda.lambda;}
        type element =
          | NA
          | SimpleForm of Lambda.lambda
        type kind =
          | ImmutableBlock of element array
          | MutableBlock of element array
          | Constant of Lambda.structured_constant
          | Module of
          Ident.t[@ocaml.doc " TODO: static module vs first class module "]
          | Function of function_id
          | Exception
          |
          Parameter[@ocaml.doc
                     " For this case, it can help us determine whether it should be inlined or not "]
          |
          NA[@ocaml.doc
              " Not such information is associated with an identifier, it is immutable, \n           if you only associate a property to an identifier \n           we should consider [Lassign]\n        "]
        type ident_tbl = (Ident.t,kind) Hashtbl.t
        type ident_info = {
          kind: kind;
          state: state;}
        type meta =
          {
          env: Env.t;
          filename: string;
          mutable export_idents: Ident.t list;
          alias_tbl: alias_tbl;
          exit_codes: int Hash_set.hashset;
          mutable unused_exit_code: int;
          ident_tbl:
            ident_tbl[@ocaml.doc
                       " we don't need count arities for all identifiers, for identifiers\n      for sure it's not a function, there is no need to count them\n   "];
          exports: Ident.t list;
          mutable required_modules: Lam_module_ident.t list;}
      end =
      struct
        type function_arities =
          | Determin of bool* (int* Ident.t list) list* bool
          | NA
        type alias_tbl = (Ident.t,Ident.t) Hashtbl.t
        type function_kind =
          | Functor
          | Function
          | NA
        type function_id =
          {
          kind: function_kind;
          mutable arity: function_arities;
          lambda: Lambda.lambda;}
        type element =
          | NA
          | SimpleForm of Lambda.lambda
        type kind =
          | ImmutableBlock of element array
          | MutableBlock of element array
          | Constant of Lambda.structured_constant
          | Module of
          Ident.t[@ocaml.doc
                   " Global module, local module is treated as an array\n         "]
          | Function of function_id[@ocaml.doc " True then functor "]
          | Exception
          |
          Parameter[@ocaml.doc
                     " For this case, it can help us determine whether it should be inlined or not "]
          | NA
        type ident_tbl = (Ident.t,kind) Hashtbl.t
        type state =
          | Live[@ocaml.doc " Globals are always live "]
          | Dead[@ocaml.doc " removed after elimination "]
          | NA
        type ident_info = {
          kind: kind;
          state: state;}
        type meta =
          {
          env: Env.t;
          filename: string;
          mutable export_idents: Ident.t list;
          alias_tbl: alias_tbl;
          exit_codes: int Hash_set.hashset;
          mutable unused_exit_code: int;
          ident_tbl:
            ident_tbl[@ocaml.doc
                       " we don't need count arities for all identifiers, for identifiers\n      for sure it's not a function, there is no need to count them\n  "];
          exports:
            Ident.t list[@ocaml.doc
                          " required modules completed by [alias_pass] "];
          mutable required_modules: Lam_module_ident.t list;}
      end 
    module Js_fold =
      struct
        open J[@@ocaml.doc
                " GENERATED CODE for fold visitor patten of JS IR  "]
        class virtual fold =
          object (o : 'self_type)
            method string : string -> 'self_type= o#unknown
            method option :
              'a .
                ('self_type -> 'a -> 'self_type) -> 'a option -> 'self_type=
              fun _f_a  ->
                function | None  -> o | Some _x -> let o = _f_a o _x in o
            method list :
              'a . ('self_type -> 'a -> 'self_type) -> 'a list -> 'self_type=
              fun _f_a  ->
                function
                | [] -> o
                | _x::_x_i1 ->
                    let o = _f_a o _x in let o = o#list _f_a _x_i1 in o
            method int : int -> 'self_type= o#unknown
            method bool : bool -> 'self_type=
              function | false  -> o | true  -> o
            method vident : vident -> 'self_type=
              function
              | Id _x -> let o = o#ident _x in o
              | Qualified (_x,_x_i1,_x_i2) ->
                  let o = o#ident _x in
                  let o = o#kind _x_i1 in
                  let o = o#option (fun o  -> o#string) _x_i2 in o
            method variable_declaration : variable_declaration -> 'self_type=
              fun
                { ident = _x; value = _x_i1; property = _x_i2;
                  ident_info = _x_i3 }
                 ->
                let o = o#ident _x in
                let o = o#option (fun o  -> o#expression) _x_i1 in
                let o = o#property _x_i2 in let o = o#ident_info _x_i3 in o
            method statement_desc : statement_desc -> 'self_type=
              function
              | Block _x -> let o = o#block _x in o
              | Variable _x -> let o = o#variable_declaration _x in o
              | Exp _x -> let o = o#expression _x in o
              | If (_x,_x_i1,_x_i2) ->
                  let o = o#expression _x in
                  let o = o#block _x_i1 in
                  let o = o#option (fun o  -> o#block) _x_i2 in o
              | While (_x,_x_i1,_x_i2,_x_i3) ->
                  let o = o#option (fun o  -> o#label) _x in
                  let o = o#expression _x_i1 in
                  let o = o#block _x_i2 in let o = o#unknown _x_i3 in o
              | ForRange (_x,_x_i1,_x_i2,_x_i3,_x_i4,_x_i5) ->
                  let o = o#option (fun o  -> o#for_ident_expression) _x in
                  let o = o#finish_ident_expression _x_i1 in
                  let o = o#for_ident _x_i2 in
                  let o = o#for_direction _x_i3 in
                  let o = o#block _x_i4 in let o = o#unknown _x_i5 in o
              | Continue _x -> let o = o#label _x in o
              | Break  -> o
              | Return _x -> let o = o#return_expression _x in o
              | Int_switch (_x,_x_i1,_x_i2) ->
                  let o = o#expression _x in
                  let o =
                    o#list (fun o  -> o#case_clause (fun o  -> o#int)) _x_i1 in
                  let o = o#option (fun o  -> o#block) _x_i2 in o
              | String_switch (_x,_x_i1,_x_i2) ->
                  let o = o#expression _x in
                  let o =
                    o#list (fun o  -> o#case_clause (fun o  -> o#string))
                      _x_i1 in
                  let o = o#option (fun o  -> o#block) _x_i2 in o
              | Throw _x -> let o = o#expression _x in o
              | Try (_x,_x_i1,_x_i2) ->
                  let o = o#block _x in
                  let o =
                    o#option
                      (fun o  ->
                         fun (_x,_x_i1)  ->
                           let o = o#exception_ident _x in
                           let o = o#block _x_i1 in o) _x_i1 in
                  let o = o#option (fun o  -> o#block) _x_i2 in o
            method statement : statement -> 'self_type=
              fun { statement_desc = _x; comment = _x_i1 }  ->
                let o = o#statement_desc _x in
                let o = o#option (fun o  -> o#string) _x_i1 in o
            method return_expression : return_expression -> 'self_type=
              fun { return_value = _x }  -> let o = o#expression _x in o
            method required_modules : required_modules -> 'self_type=
              o#unknown
            method property_name : property_name -> 'self_type= o#string
            method property_map : property_map -> 'self_type=
              o#list
                (fun o  ->
                   fun (_x,_x_i1)  ->
                     let o = o#property_name _x in
                     let o = o#expression _x_i1 in o)
            method property : property -> 'self_type= o#unknown
            method program : program -> 'self_type=
              fun
                { name = _x; modules = _x_i1; block = _x_i2; exports = _x_i3;
                  export_set = _x_i4; side_effect = _x_i5 }
                 ->
                let o = o#string _x in
                let o = o#required_modules _x_i1 in
                let o = o#block _x_i2 in
                let o = o#exports _x_i3 in
                let o = o#unknown _x_i4 in
                let o = o#option (fun o  -> o#string) _x_i5 in o
            method number : number -> 'self_type= o#unknown
            method mutable_flag : mutable_flag -> 'self_type= o#unknown
            method label : label -> 'self_type= o#string
            method kind : kind -> 'self_type= o#unknown
            method int_op : int_op -> 'self_type= o#unknown
            method ident_info : ident_info -> 'self_type= o#unknown
            method ident : ident -> 'self_type= o#unknown
            method for_ident_expression : for_ident_expression -> 'self_type=
              o#expression
            method for_ident : for_ident -> 'self_type= o#ident
            method for_direction : for_direction -> 'self_type= o#unknown
            method finish_ident_expression :
              finish_ident_expression -> 'self_type= o#expression
            method expression_desc : expression_desc -> 'self_type=
              function
              | Math (_x,_x_i1) ->
                  let o = o#string _x in
                  let o = o#list (fun o  -> o#expression) _x_i1 in o
              | Array_length _x -> let o = o#expression _x in o
              | String_length _x -> let o = o#expression _x in o
              | Bytes_length _x -> let o = o#expression _x in o
              | Function_length _x -> let o = o#expression _x in o
              | Char_of_int _x -> let o = o#expression _x in o
              | Char_to_int _x -> let o = o#expression _x in o
              | Array_of_size _x -> let o = o#expression _x in o
              | Array_append (_x,_x_i1) ->
                  let o = o#expression _x in
                  let o = o#list (fun o  -> o#expression) _x_i1 in o
              | Tag_ml_obj _x -> let o = o#expression _x in o
              | String_append (_x,_x_i1) ->
                  let o = o#expression _x in let o = o#expression _x_i1 in o
              | Int_of_boolean _x -> let o = o#expression _x in o
              | Is_type_number _x -> let o = o#expression _x in o
              | Not _x -> let o = o#expression _x in o
              | String_of_small_int_array _x -> let o = o#expression _x in o
              | Dump (_x,_x_i1) ->
                  let o = o#unknown _x in
                  let o = o#list (fun o  -> o#expression) _x_i1 in o
              | Seq (_x,_x_i1) ->
                  let o = o#expression _x in let o = o#expression _x_i1 in o
              | Cond (_x,_x_i1,_x_i2) ->
                  let o = o#expression _x in
                  let o = o#expression _x_i1 in
                  let o = o#expression _x_i2 in o
              | Bin (_x,_x_i1,_x_i2) ->
                  let o = o#binop _x in
                  let o = o#expression _x_i1 in
                  let o = o#expression _x_i2 in o
              | FlatCall (_x,_x_i1) ->
                  let o = o#expression _x in let o = o#expression _x_i1 in o
              | Call (_x,_x_i1,_x_i2) ->
                  let o = o#expression _x in
                  let o = o#list (fun o  -> o#expression) _x_i1 in
                  let o = o#unknown _x_i2 in o
              | String_access (_x,_x_i1) ->
                  let o = o#expression _x in let o = o#expression _x_i1 in o
              | Access (_x,_x_i1) ->
                  let o = o#expression _x in let o = o#expression _x_i1 in o
              | Dot (_x,_x_i1,_x_i2) ->
                  let o = o#expression _x in
                  let o = o#string _x_i1 in let o = o#bool _x_i2 in o
              | New (_x,_x_i1) ->
                  let o = o#expression _x in
                  let o =
                    o#option (fun o  -> o#list (fun o  -> o#expression))
                      _x_i1 in
                  o
              | Var _x -> let o = o#vident _x in o
              | Fun (_x,_x_i1,_x_i2) ->
                  let o = o#list (fun o  -> o#ident) _x in
                  let o = o#block _x_i1 in let o = o#unknown _x_i2 in o
              | Str (_x,_x_i1) ->
                  let o = o#bool _x in let o = o#string _x_i1 in o
              | Array (_x,_x_i1) ->
                  let o = o#list (fun o  -> o#expression) _x in
                  let o = o#mutable_flag _x_i1 in o
              | Number _x -> let o = o#number _x in o
              | Object _x -> let o = o#property_map _x in o
            method expression : expression -> 'self_type=
              fun { expression_desc = _x; comment = _x_i1 }  ->
                let o = o#expression_desc _x in
                let o = o#option (fun o  -> o#string) _x_i1 in o
            method exports : exports -> 'self_type= o#unknown
            method exception_ident : exception_ident -> 'self_type= o#ident
            method case_clause :
              'a .
                ('self_type -> 'a -> 'self_type) ->
                  'a case_clause -> 'self_type=
              fun _f_a  ->
                fun { case = _x; body = _x_i1 }  ->
                  let o = _f_a o _x in
                  let o =
                    (fun (_x,_x_i1)  ->
                       let o = o#block _x in let o = o#bool _x_i1 in o) _x_i1 in
                  o
            method block : block -> 'self_type=
              o#list (fun o  -> o#statement)
            method binop : binop -> 'self_type= o#unknown
            method unknown : 'a . 'a -> 'self_type= fun _  -> o
          end
      end
    module Js_fold_basic :
      sig
        [@@@ocaml.text
          " A module to calculate hard dependency based on JS IR in module [J] "]
        val depends_j : J.expression -> Ident_set.t -> Ident_set.t
        val calculate_hard_dependencies :
          J.block -> Lam_module_ident.t Hash_set.hashset
      end =
      struct
        class count_deps (add : Ident.t -> unit) =
          object (self)
            inherit  Js_fold.fold as super
            method! expression lam =
              match lam.expression_desc with
              | Fun (_,block,_) -> self#block block
              | _ -> super#expression lam
            method! ident x = add x; self
          end
        class count_hard_dependencies =
          object (self)
            inherit  Js_fold.fold as super
            val hard_dependencies = Hash_set.create 17
            method! vident vid =
              match vid with
              | Qualified (id,kind,_) ->
                  (Hash_set.add hard_dependencies
                     (Lam_module_ident.mk kind id);
                   self)
              | Id id -> self
            method get_hard_dependencies = hard_dependencies
          end
        let calculate_hard_dependencies block =
          ((new count_hard_dependencies)#block block)#get_hard_dependencies
        let depends_j (lam : J.expression) (variables : Ident_set.t) =
          let v = ref Ident_set.empty in
          let add id =
            if Ident_set.mem id variables then v := (Ident_set.add id (!v)) in
          ignore @@ (((new count_deps) add)#expression lam); !v
      end 
    module Ident_map =
      struct
        [@@@ocaml.text
          " Map with key specialized as [Ident] type, enhanced with some utilities "]
        include
          Map.Make(struct
                     type t = Ident.t
                     let compare = Pervasives.compare[@@ocaml.doc
                                                       "TODO: fix me"]
                   end)
        let of_list lst =
          List.fold_left (fun acc  -> fun (k,v)  -> add k v acc) empty lst
        let keys map = fold (fun k  -> fun _  -> fun acc  -> k :: acc) map []
        let add_if_not_exist key v m = if mem key m then m else add key v m
        let merge_disjoint m1 m2 =
          merge
            (fun k  ->
               fun x0  ->
                 fun y0  ->
                   match (x0, y0) with
                   | (None ,None ) -> None
                   | (None ,Some v)|(Some v,None ) -> Some v
                   | (_,_) ->
                       invalid_arg "merge_disjoint: maps are not disjoint")
            m1 m2
      end
    module Lam_util :
      sig
        val string_of_lambda : Lambda.lambda -> string
        val string_of_primitive : Lambda.primitive -> string
        val kind_of_lambda_block : Lambda.lambda list -> Lam_stats.kind
        val get :
          Lambda.lambda ->
            Ident.t -> int -> Lam_stats.ident_tbl -> Lambda.lambda
        val add_required_module : Ident.t -> Lam_stats.meta -> unit
        val add_required_modules : Ident.t list -> Lam_stats.meta -> unit
        val alias :
          Lam_stats.meta ->
            Ident.t -> Ident.t -> Lam_stats.kind -> Lambda.let_kind -> unit
        val no_side_effects : Lambda.lambda -> bool[@@ocaml.doc
                                                     " No side effect, but it might depend on data store "]
        val size : Lambda.lambda -> int
        val eq_lambda : Lambda.lambda -> Lambda.lambda -> bool[@@ocaml.doc
                                                                " a conservative version of comparing two lambdas, mostly \n    for looking for similar cases in switch\n "]
        val beta_reduce :
          Ident.t list ->
            Lambda.lambda -> Lambda.lambda list -> Lambda.lambda
        val refine_let :
          ?kind:Lambda.let_kind ->
            Ident.t -> Lambda.lambda -> Lambda.lambda -> Lambda.lambda
        type group =
          | Single of Lambda.let_kind* Ident.t* Lambda.lambda
          | Recursive of (Ident.t* Lambda.lambda) list
          | Nop of Lambda.lambda
        val flatten :
          group list -> Lambda.lambda -> (Lambda.lambda* group list)
        val lambda_of_groups : Lambda.lambda -> group list -> Lambda.lambda
        val deep_flatten : Lambda.lambda -> Lambda.lambda[@@ocaml.doc
                                                           " Tricky to be complete "]
        val pp_group : Env.t -> Format.formatter -> group -> unit
        val generate_label : ?name:string -> unit -> J.label
        val sort_dag_args : J.expression Ident_map.t -> Ident.t list option
        [@@ocaml.doc
          " if [a] depends on [b] a is ahead of [b] as [a::b]\n\n    TODO: make it a stable sort \n "]
        val dump : Env.t -> string -> bool -> Lambda.lambda -> Lambda.lambda
      end =
      struct
        let string_of_lambda = Format.asprintf "%a" Printlambda.lambda
        let string_of_primitive = Format.asprintf "%a" Printlambda.primitive
        let rec no_side_effects (lam : Lambda.lambda) =
          (match lam with
           | Lvar _|Lconst _|Lfunction _ -> true
           | Lprim (primitive,args) ->
               (List.for_all no_side_effects args) &&
                 ((match primitive with
                   | Pccall { prim_name;_} ->
                       (match (prim_name, args) with
                        | (("caml_register_named_value"|"caml_set_oo_id"
                            |"caml_is_js"|"caml_int64_float_of_bits"
                            |"caml_sys_get_config"|"caml_sys_get_argv"
                            |"caml_create_string"|"caml_make_vect"
                            |"caml_obj_dup"|"caml_obj_block"),_) -> true
                        | ("caml_ml_open_descriptor_in",(Lconst (Const_base
                           (Const_int 0)))::[]) -> true
                        | ("caml_ml_open_descriptor_out",(Lconst (Const_base
                           (Const_int (1|2))))::[]) -> true
                        | (_,_) -> false)
                   | Pidentity |Pbytes_to_string |Pbytes_of_string 
                     |Pchar_to_int |Pchar_of_int |Pignore |Prevapply _
                     |Pdirapply _|Ploc _|Pgetglobal _|Pmakeblock _|Pfield _
                     |Pfloatfield _|Pduprecord _|Psequand |Psequor |Pnot 
                     |Pnegint |Paddint |Psubint |Pmulint |Pdivint |Pmodint 
                     |Pandint |Porint |Pxorint |Plslint |Plsrint |Pasrint 
                     |Pintcomp _|Pintoffloat |Pfloatofint |Pnegfloat 
                     |Pabsfloat |Paddfloat |Psubfloat |Pmulfloat |Pdivfloat 
                     |Pfloatcomp _|Pstringlength |Pstringrefu |Pstringrefs 
                     |Pbyteslength |Pbytesrefu |Pbytesrefs |Pmakearray _
                     |Parraylength _|Parrayrefu _|Parrayrefs _|Pisint |Pisout 
                     |Pbintofint _|Pintofbint _|Pcvtbint _|Pnegbint _
                     |Paddbint _|Psubbint _|Pmulbint _|Pdivbint _|Pmodbint _
                     |Pandbint _|Porbint _|Pxorbint _|Plslbint _|Plsrbint _
                     |Pasrbint _|Pbintcomp _|Pbigarrayref _|Pctconst _
                     |Pint_as_pointer |Poffsetint _ -> true
                   | Pstringsetu |Pstringsets |Pbytessetu |Pbytessets 
                     |Pbittest |Parraysets _|Pbigarrayset _|Pbigarraydim _
                     |Pstring_load_16 _|Pstring_load_32 _|Pstring_load_64 _
                     |Pstring_set_16 _|Pstring_set_32 _|Pstring_set_64 _
                     |Pbigstring_load_16 _|Pbigstring_load_32 _
                     |Pbigstring_load_64 _|Pbigstring_set_16 _
                     |Pbigstring_set_32 _|Pbigstring_set_64 _|Pbswap16 
                     |Pbbswap _|Parraysetu _|Poffsetref _|Praise _|Plazyforce 
                     |Pmark_ocaml_object |Psetfield _|Psetfloatfield _
                     |Psetglobal _ -> false))
           | Llet (_,_,arg,body) ->
               (no_side_effects arg) && (no_side_effects body)
           | Lswitch (_,_) -> false
           | Lstringswitch (_,_,_) -> false
           | Lstaticraise _ -> false
           | Lstaticcatch _ -> false
           | Ltrywith
               (Lprim
                (Pccall { prim_name = "caml_sys_getenv" },(Lconst _)::[]),exn,Lifthenelse
                (Lprim
                 (_,(Lvar exn1)::(Lprim
                  (Pgetglobal { name = "Not_found" },[]))::[]),then_,_))
               when Ident.same exn1 exn -> no_side_effects then_
           | Ltrywith (body,exn,handler) ->
               (no_side_effects body) && (no_side_effects handler)
           | Lifthenelse (a,b,c) ->
               (no_side_effects a) &&
                 ((no_side_effects b) && (no_side_effects c))
           | Lsequence (e0,e1) ->
               (no_side_effects e0) && (no_side_effects e1)
           | Lwhile (a,b) -> (no_side_effects a) && (no_side_effects b)
           | Lfor _ -> false
           | Lassign _ -> false
           | Lsend _ -> false
           | Levent (e,_) -> no_side_effects e
           | Lifused _ -> false
           | Lapply _ -> false
           | Lletrec (bindings,body) ->
               (List.for_all (fun (_,b)  -> no_side_effects b) bindings) &&
                 (no_side_effects body) : bool)
        exception Cyclic
        let toplogical (get_deps : Ident.t -> Ident_set.t)
          (libs : Ident.t list) =
          (let rec aux acc later todo round_progress =
             match (todo, later) with
             | ([],[]) -> acc
             | ([],_) ->
                 if round_progress
                 then aux acc todo later false
                 else raise Cyclic
             | (x::xs,_) ->
                 if
                   Ident_set.for_all
                     (fun dep  -> (x == dep) || (List.mem dep acc))
                     (get_deps x)
                 then aux (x :: acc) later xs true
                 else aux acc (x :: later) xs round_progress in
           let (starts,todo) =
             List.partition
               (fun lib  -> Ident_set.is_empty @@ (get_deps lib)) libs in
           aux starts [] todo false : Ident.t list)
        let sort_dag_args param_args =
          let todos = Ident_map.keys param_args in
          let idents = Ident_set.of_list todos in
          let dependencies: Ident_set.t Ident_map.t =
            Ident_map.mapi
              (fun param  -> fun arg  -> Js_fold_basic.depends_j arg idents)
              param_args in
          try
            Some (toplogical (fun k  -> Ident_map.find k dependencies) todos)
          with | Cyclic  -> None
        exception Too_big_to_inline
        let really_big () = raise Too_big_to_inline
        let big_lambda = 1000
        let rec size (lam : Lambda.lambda) =
          try
            match lam with
            | Lvar _ -> 1
            | Lconst _ -> 1
            | Llet (_,_,l1,l2) -> (1 + (size l1)) + (size l2)
            | Lletrec _ -> really_big ()
            | Lprim (_,ll) -> size_lams 1 ll
            | Lapply (f,args,_) -> size_lams (size f) args
            | Lfunction (_,params,l) -> really_big ()
            | Lswitch (_,_) -> really_big ()
            | Lstringswitch (_,_,_) -> really_big ()
            | Lstaticraise (i,ls) ->
                List.fold_left (fun acc  -> fun x  -> (size x) + acc) 1 ls
            | Lstaticcatch (l1,(i,x),l2) -> really_big ()
            | Ltrywith (l1,v,l2) -> really_big ()
            | Lifthenelse (l1,l2,l3) ->
                ((1 + (size l1)) + (size l2)) + (size l3)
            | Lsequence (l1,l2) -> (size l1) + (size l2)
            | Lwhile (l1,l2) -> really_big ()
            | Lfor (flag,l1,l2,dir,l3) -> really_big ()
            | Lassign (_,v) -> 1 + (size v)
            | Lsend _ -> really_big ()
            | Levent (l,_) -> size l
            | Lifused (v,l) -> size l
          with | Too_big_to_inline  -> 1000
        and size_lams acc (lams : Lambda.lambda list) =
          List.fold_left (fun acc  -> fun l  -> acc + (size l)) acc lams
        let rec eq_lambda (l1 : Lambda.lambda) (l2 : Lambda.lambda) =
          match (l1, l2) with
          | (Lvar i1,Lvar i2) -> Ident.same i1 i2
          | (Lconst c1,Lconst c2) -> c1 = c2
          | (Lapply (l1,args1,_),Lapply (l2,args2,_)) ->
              (eq_lambda l1 l2) && (List.for_all2 eq_lambda args1 args2)
          | (Lfunction _,Lfunction _) -> false
          | (Lassign (v0,l0),Lassign (v1,l1)) ->
              (Ident.same v0 v1) && (eq_lambda l0 l1)
          | (Lstaticraise (id,ls),Lstaticraise (id1,ls1)) ->
              (id = id1) && (List.for_all2 eq_lambda ls ls1)
          | (Llet (_,_,_,_),Llet (_,_,_,_)) -> false
          | (Lletrec _,Lletrec _) -> false
          | (Lprim (p,ls),Lprim (p1,ls1)) ->
              (eq_primitive p p1) && (List.for_all2 eq_lambda ls ls1)
          | (Lswitch _,Lswitch _) -> false
          | (Lstringswitch _,Lstringswitch _) -> false
          | (Lstaticcatch _,Lstaticcatch _) -> false
          | (Ltrywith _,Ltrywith _) -> false
          | (Lifthenelse (a,b,c),Lifthenelse (a0,b0,c0)) ->
              (eq_lambda a a0) && ((eq_lambda b b0) && (eq_lambda c c0))
          | (Lsequence (a,b),Lsequence (a0,b0)) ->
              (eq_lambda a a0) && (eq_lambda b b0)
          | (Lwhile (p,b),Lwhile (p0,b0)) ->
              (eq_lambda p p0) && (eq_lambda b b0)
          | (Lfor (_,_,_,_,_),Lfor (_,_,_,_,_)) -> false
          | (Lsend _,Lsend _) -> false
          | (Levent (v,_),Levent (v0,_)) -> eq_lambda v v0
          | (Lifused _,Lifused _) -> false
          | (_,_) -> false
        and eq_primitive (p : Lambda.primitive) (p1 : Lambda.primitive) =
          match (p, p1) with
          | (Pccall { prim_name = n0 },Pccall { prim_name = n1 }) -> n0 = n1
          | (_,_) -> (try p = p1 with | _ -> false)
        let add_required_module (x : Ident.t) (meta : Lam_stats.meta) =
          meta.required_modules <- (Lam_module_ident.of_ml x) ::
            (meta.required_modules)
        let add_required_modules (x : Ident.t list) (meta : Lam_stats.meta) =
          meta.required_modules <-
            (List.map (fun x  -> Lam_module_ident.of_ml x) x) @
              meta.required_modules
        let subst_lambda s lam =
          let rec subst (x : Lambda.lambda) =
            match x with
            | Lvar id as l ->
                (try Ident_map.find id s with | Not_found  -> l)
            | Lconst sc as l -> l
            | Lapply (fn,args,loc) ->
                Lapply ((subst fn), (List.map subst args), loc)
            | Lfunction (kind,params,body) ->
                Lfunction (kind, params, (subst body))
            | Llet (str,id,arg,body) ->
                Llet (str, id, (subst arg), (subst body))
            | Lletrec (decl,body) ->
                Lletrec ((List.map subst_decl decl), (subst body))
            | Lprim (p,args) -> Lprim (p, (List.map subst args))
            | Lswitch (arg,sw) ->
                Lswitch
                  ((subst arg),
                    {
                      sw with
                      sw_consts = (List.map subst_case sw.sw_consts);
                      sw_blocks = (List.map subst_case sw.sw_blocks);
                      sw_failaction = (subst_opt sw.sw_failaction)
                    })
            | Lstringswitch (arg,cases,default) ->
                Lstringswitch
                  ((subst arg), (List.map subst_strcase cases),
                    (subst_opt default))
            | Lstaticraise (i,args) ->
                Lstaticraise (i, (List.map subst args))
            | Lstaticcatch (e1,io,e2) ->
                Lstaticcatch ((subst e1), io, (subst e2))
            | Ltrywith (e1,exn,e2) -> Ltrywith ((subst e1), exn, (subst e2))
            | Lifthenelse (e1,e2,e3) ->
                Lifthenelse ((subst e1), (subst e2), (subst e3))
            | Lsequence (e1,e2) -> Lsequence ((subst e1), (subst e2))
            | Lwhile (e1,e2) -> Lwhile ((subst e1), (subst e2))
            | Lfor (v,e1,e2,dir,e3) ->
                Lfor (v, (subst e1), (subst e2), dir, (subst e3))
            | Lassign (id,e) -> Lassign (id, (subst e))
            | Lsend (k,met,obj,args,loc) ->
                Lsend
                  (k, (subst met), (subst obj), (List.map subst args), loc)
            | Levent (lam,evt) -> Levent ((subst lam), evt)
            | Lifused (v,e) -> Lifused (v, (subst e))
          and subst_decl (id,exp) = (id, (subst exp))
          and subst_case (key,case) = (key, (subst case))
          and subst_strcase (key,case) = (key, (subst case))
          and subst_opt = function | None  -> None | Some e -> Some (subst e) in
          subst lam
        let refine_let ?kind  param (arg : Lambda.lambda) (l : Lambda.lambda)
          =
          (match ((kind : Lambda.let_kind option), arg, l) with
           | (_,_,Lvar w) when Ident.same w param -> arg
           | (_,_,Lprim (fn,(Lvar w)::[])) when
               (Ident.same w param) &&
                 ((function | Lambda.Pmakeblock _ -> false | _ -> true) fn)
               -> Lprim (fn, [arg])
           | (_,_,Lapply (fn,(Lvar w)::[],info)) when Ident.same w param ->
               Lapply (fn, [arg], info)
           | ((Some (Strict |StrictOpt )|None ),(Lvar _|Lconst _|Lprim
                                                 (Pfield _,(Lprim
                                                  (Pgetglobal _,[]))::[])),_)
               -> Llet (Alias, param, arg, l)
           | ((Some (Strict |StrictOpt )|None ),Lfunction _,_) ->
               Llet (StrictOpt, param, arg, l)
           | (Some (Strict ),_,_) when no_side_effects arg ->
               Llet (StrictOpt, param, arg, l)
           | (Some (Variable ),_,_) -> Llet (Variable, param, arg, l)
           | (Some kind,_,_) -> Llet (kind, param, arg, l)
           | (None ,_,_) -> Llet (Strict, param, arg, l) : Lambda.lambda)
        let alias (meta : Lam_stats.meta) (k : Ident.t) (v : Ident.t)
          (v_kind : Lam_stats.kind) (let_kind : Lambda.let_kind) =
          (match v_kind with
           | NA  ->
               (match Hashtbl.find meta.ident_tbl v with
                | exception Not_found  -> ()
                | ident_info -> Hashtbl.add meta.ident_tbl k ident_info)
           | ident_info -> Hashtbl.add meta.ident_tbl k ident_info);
          (match let_kind with
           | Alias  ->
               if not @@ (List.mem k meta.export_idents)
               then Hashtbl.add meta.alias_tbl k v
           | Strict |StrictOpt |Variable  -> ())
        let beta_reduce params body args =
          List.fold_left2
            (fun l  -> fun param  -> fun arg  -> refine_let param arg l) body
            params args
        type group =
          | Single of Lambda.let_kind* Ident.t* Lambda.lambda
          | Recursive of (Ident.t* Lambda.lambda) list
          | Nop of Lambda.lambda
        let pp = Format.fprintf
        let str_of_kind (kind : Lambda.let_kind) =
          match kind with
          | Alias  -> "a"
          | Strict  -> ""
          | StrictOpt  -> "o"
          | Variable  -> "v"
        let pp_group env fmt (x : group) =
          match x with
          | Single (kind,id,lam) ->
              Format.fprintf fmt "@[let@ %a@ =%s@ @[<hv>%a@]@ @]" Ident.print
                id (str_of_kind kind) (Printlambda.env_lambda env) lam
          | Recursive lst ->
              List.iter
                (fun (id,lam)  ->
                   Format.fprintf fmt "@[let %a@ =r@ %a@ @]" Ident.print id
                     (Printlambda.env_lambda env) lam) lst
          | Nop lam -> Printlambda.env_lambda env fmt lam
        let element_of_lambda (lam : Lambda.lambda) =
          (match lam with
           | Lvar _|Lconst _|Lprim (Pfield _,(Lprim (Pgetglobal _,[]))::[])
               -> SimpleForm lam
           | _ -> NA : Lam_stats.element)
        let kind_of_lambda_block (xs : Lambda.lambda list) =
          ((xs |> (List.map element_of_lambda)) |>
             (fun ls  -> Lam_stats.ImmutableBlock (Array.of_list ls)) : 
          Lam_stats.kind)
        let get lam v i tbl =
          (match (Hashtbl.find tbl v : Lam_stats.kind) with
           | Module g -> Lprim ((Pfield i), [Lprim ((Pgetglobal g), [])])
           | ImmutableBlock arr ->
               (match arr.(i) with | NA  -> lam | SimpleForm l -> l)
           | Constant (Const_block (_,_,ls)) -> Lconst (List.nth ls i)
           | _ -> lam
           | exception Not_found  -> lam : Lambda.lambda)
        let rec flatten (acc : group list) (lam : Lambda.lambda) =
          (match lam with
           | Levent (e,_) -> flatten acc e
           | Llet (str,id,arg,body) ->
               let (res,l) = flatten acc arg in
               flatten ((Single (str, id, res)) :: l) body
           | Lletrec (bind_args,body) ->
               flatten
                 ((Recursive
                     (List.map (fun (id,arg)  -> (id, arg)) bind_args)) ::
                 acc) body
           | Lsequence (l,r) ->
               let (res,l) = flatten acc l in flatten ((Nop res) :: l) r
           | x -> (x, acc) : (Lambda.lambda* group list))
        let lambda_of_groups result groups =
          List.fold_left
            (fun acc  ->
               fun x  ->
                 match x with
                 | Nop l -> Lambda.Lsequence (l, acc)
                 | Single (kind,ident,lam) -> refine_let ~kind ident lam acc
                 | Recursive bindings -> Lletrec (bindings, acc)) result
            groups
        let deep_flatten (lam : Lambda.lambda) =
          (let rec flatten (acc : group list) (lam : Lambda.lambda) =
             (match lam with
              | Levent (e,_) -> flatten acc e
              | Llet (str,id,arg,body) ->
                  let (res,l) = flatten acc arg in
                  flatten ((Single (str, id, res)) :: l) body
              | Lletrec (bind_args,body) ->
                  flatten
                    ((Recursive
                        (List.map (fun (id,arg)  -> (id, (aux arg)))
                           bind_args)) :: acc) body
              | Lsequence (l,r) ->
                  let (res,l) = flatten acc l in flatten ((Nop res) :: l) r
              | x -> ((aux x), acc) : (Lambda.lambda* group list))
           and aux (lam : Lambda.lambda) =
             (match lam with
              | Levent (e,_) -> aux e
              | Llet _ ->
                  let (res,groups) = flatten [] lam in
                  lambda_of_groups res groups
              | Lletrec (bind_args,body) ->
                  let module Ident_set = Lambda.IdentSet in
                    let rec iter bind_args acc =
                      match bind_args with
                      | [] -> acc
                      | (id,arg)::rest ->
                          let (groups,set) = acc in
                          let (res,groups) = flatten groups (aux arg) in
                          iter rest
                            (((Recursive [(id, res)]) :: groups),
                              (Ident_set.add id set)) in
                    let (groups,collections) =
                      iter bind_args ([], Ident_set.empty) in
                    let (result,_,wrap) =
                      List.fold_left
                        (fun (acc,set,wrap)  ->
                           fun g  ->
                             match g with
                             | Recursive ((id,Lconst _)::[])|Single
                               (Alias ,id,Lconst _)|Single
                               ((Alias |Strict |StrictOpt ),id,Lfunction _)
                                 -> (acc, set, (g :: wrap))
                             | Single (_,id,Lvar bid) ->
                                 (acc,
                                   (if Ident_set.mem bid set
                                    then Ident_set.add id set
                                    else set), (g :: wrap))
                             | Single (_,id,lam) ->
                                 let variables = Lambda.free_variables lam in
                                 if
                                   let open Ident_set in
                                     is_empty (inter variables collections)
                                 then (acc, set, (g :: wrap))
                                 else
                                   (((id, lam) :: acc),
                                     (Ident_set.add id set), wrap)
                             | Recursive us ->
                                 ((us @ acc),
                                   (List.fold_left
                                      (fun acc  ->
                                         fun (id,_)  -> Ident_set.add id acc)
                                      set us), wrap)
                             | Nop _ -> assert false) ([], collections, [])
                        groups in
                    lambda_of_groups (Lletrec (result, (aux body)))
                      (List.rev wrap)
              | Lsequence (l,r) -> Lsequence ((aux l), (aux r))
              | Lconst _ -> lam
              | Lvar _ -> lam
              | Lapply (l1,ll,info) ->
                  Lapply ((aux l1), (List.map aux ll), info)
              | Lprim (Pidentity ,l::[]) -> l
              | Lprim (prim,ll) -> Lprim (prim, (List.map aux ll))
              | Lfunction (kind,params,l) ->
                  Lfunction (kind, params, (aux l))
              | Lswitch
                  (l,{ sw_failaction; sw_consts; sw_blocks; sw_numblocks;
                       sw_numconsts })
                  ->
                  Lswitch
                    ((aux l),
                      {
                        sw_consts =
                          (List.map (fun (v,l)  -> (v, (aux l))) sw_consts);
                        sw_blocks =
                          (List.map (fun (v,l)  -> (v, (aux l))) sw_blocks);
                        sw_numconsts;
                        sw_numblocks;
                        sw_failaction =
                          ((match sw_failaction with
                            | None  -> None
                            | Some x -> Some (aux x)))
                      })
              | Lstringswitch (l,sw,d) ->
                  Lstringswitch
                    ((aux l), (List.map (fun (i,l)  -> (i, (aux l))) sw),
                      ((match d with | Some d -> Some (aux d) | None  -> None)))
              | Lstaticraise (i,ls) -> Lstaticraise (i, (List.map aux ls))
              | Lstaticcatch (l1,(i,x),l2) ->
                  Lstaticcatch ((aux l1), (i, x), (aux l2))
              | Ltrywith (l1,v,l2) -> Ltrywith ((aux l1), v, (aux l2))
              | Lifthenelse (l1,l2,l3) ->
                  Lifthenelse ((aux l1), (aux l2), (aux l3))
              | Lwhile (l1,l2) -> Lwhile ((aux l1), (aux l2))
              | Lfor (flag,l1,l2,dir,l3) ->
                  Lfor (flag, (aux l1), (aux l2), dir, (aux l3))
              | Lassign (v,l) -> Lassign (v, (aux l))
              | Lsend (u,m,o,ll,v) ->
                  Lsend (u, (aux m), (aux o), (List.map aux ll), v)
              | Lifused (v,l) -> Lifused (v, (aux l)) : Lambda.lambda) in
           aux lam : Lambda.lambda)
        let count = ref 0
        let generate_label ?(name= "")  () =
          incr count; Printf.sprintf "%s_tailcall_%04d" name (!count)
        let log_counter = ref 0
        let dump env filename pred lam =
          incr log_counter;
          if pred
          then
            Printlambda.seriaize env
              ((Filename.chop_extension filename) ^
                 (Printf.sprintf ".%02d.lam" (!log_counter))) lam;
          lam
      end 
    module Idents_analysis :
      sig
        [@@@ocaml.text
          " A simple algorithm to calcuate [used] idents given its dependencies and \n    initial list.\n\n    TODO needs improvement\n "]
        val calculate_used_idents :
          (Ident.t,Lambda.IdentSet.t) Hashtbl.t ->
            Ident.t list -> Lambda.IdentSet.t
      end =
      struct
        module Ident_set = Lambda.IdentSet
        let calculate_used_idents
          (ident_free_vars : (Ident.t,Ident_set.t) Hashtbl.t)
          (initial_idents : Ident.t list) =
          let s = Ident_set.of_list initial_idents in
          let current_ident_sets = ref s in
          let delta = ref s in
          while
            let open Ident_set in
              (delta :=
                 (diff
                    (fold
                       (fun id  ->
                          fun acc  ->
                            union acc (Hashtbl.find ident_free_vars id))
                       (!delta) empty) (!current_ident_sets));
               not (is_empty (!delta)))
            do
            current_ident_sets :=
              (let open Ident_set in union (!current_ident_sets) (!delta))
            done;
          !current_ident_sets
      end 
    module Lam_dce :
      sig
        [@@@ocaml.text " Dead code eliminatiion on the lambda layer \n"]
        val remove :
          Ident.t list -> Lam_util.group list -> Lam_util.group list
      end =
      struct
        module I = Lambda.IdentSet
        let remove export_idents (rest : Lam_util.group list) =
          (let ident_free_vars = Hashtbl.create 17 in
           let initial_idents =
             (Ext_list.flat_map
                (fun (x : Lam_util.group)  ->
                   match x with
                   | Single (kind,id,lam) ->
                       (Hashtbl.add ident_free_vars id
                          (Lambda.free_variables lam);
                        (match kind with
                         | Alias |StrictOpt  -> []
                         | Strict |Variable  -> [id]))
                   | Recursive bindings ->
                       bindings |>
                         (Ext_list.flat_map
                            (fun (id,lam)  ->
                               Hashtbl.add ident_free_vars id
                                 (Lambda.free_variables lam);
                               (match (lam : Lambda.lambda) with
                                | Lfunction _ -> []
                                | _ -> [id])))
                   | Nop lam ->
                       if Lam_util.no_side_effects lam
                       then []
                       else I.elements (Lambda.free_variables lam)) rest)
               @ export_idents in
           let current_ident_sets =
             Idents_analysis.calculate_used_idents ident_free_vars
               initial_idents in
           rest |>
             (Ext_list.filter_map
                (fun (x : Lam_util.group)  ->
                   match x with
                   | Single (_,id,_) ->
                       if I.mem id current_ident_sets then Some x else None
                   | Nop _ -> Some x
                   | Recursive bindings ->
                       let b =
                         bindings |>
                           (Ext_list.filter_map
                              (fun ((id,_) as v)  ->
                                 if I.mem id current_ident_sets
                                 then Some v
                                 else None)) in
                       (match b with | [] -> None | _ -> Some (Recursive b)))) : 
          Lam_util.group list)
      end 
    module Ext_log :
      sig
        [@@@ocaml.text
          " A Poor man's logging utility\n    \n    Example:\n    {[ \n    err __LOC__ \"xx\"\n    ]}\n "]
        type position = (string* int* int* int)[@@ocaml.doc
                                                 " TODO is this even used ? "]
        val err :
          string ->
            ('a -> 'b,Format.formatter,unit,unit,unit,unit) format6 ->
              'a -> 'b
        val warn :
          string ->
            ('a -> 'b,Format.formatter,unit,unit,unit,unit) format6 ->
              'a -> 'b
        val info :
          string ->
            ('a -> 'b,Format.formatter,unit,unit,unit,unit) format6 ->
              'a -> 'b
        val ierr :
          string ->
            ('a -> 'b,Format.formatter,unit,unit,unit,unit) format6 ->
              'a -> 'b
      end =
      struct
        type position = (string* int* int* int)
        let err str f v =
          Format.fprintf Format.err_formatter ("%s " ^^ f) str v
        let warn str f v =
          Format.fprintf Format.err_formatter ("WARN: %s " ^^ f) str v
        let info str f v =
          Format.fprintf Format.err_formatter ("INFO: %s " ^^ f) str v
        let ierr str f v =
          Format.ifprintf Format.err_formatter ("%s " ^^ f) str v
      end 
    module Type_util :
      sig
        [@@@ocaml.text
          " Utilities for quering typing inforaation from {!Env.t}, this part relies\n    on compiler API\n"]
        val query : Path.t -> Env.t -> Types.signature option
        val name_of_signature_item : Types.signature_item -> Ident.t
        val get_name : Types.signature -> int -> string
        val filter_serializable_signatures :
          Types.signature -> Types.signature
        val find_serializable_signatures_by_path :
          Path.t -> Env.t -> Types.signature option
        val list_of_arrow :
          Types.type_expr ->
            (Types.type_desc* (string* Types.type_expr) list)
        val label_name :
          string -> [ `Label of string  | `Optional of string ]
      end =
      struct
        let rec query (v : Path.t) (env : Env.t) =
          (match Env.find_modtype_expansion v env with
           | Mty_alias v1|Mty_ident v1 -> query v1 env
           | Mty_functor _ -> assert false
           | Mty_signature s -> Some s
           | exception _ -> None : Types.signature option)
        let name_of_signature_item (x : Types.signature_item) =
          match x with
          | Sig_value (i,_)|Sig_module (i,_,_) -> i
          | Sig_typext (i,_,_) -> i
          | Sig_modtype (i,_) -> i
          | Sig_class (i,_,_) -> i
          | Sig_class_type (i,_,_) -> i
          | Sig_type (i,_,_) -> i
        let get_name (serializable_sigs : Types.signature) (pos : int) =
          let ident =
            name_of_signature_item @@ (List.nth serializable_sigs pos) in
          ident.name[@@ocaml.doc " Used in [Pgetglobal] "]
        let string_of_value_description id =
          Format.asprintf "%a" (Printtyp.value_description id)
        [@@@ocaml.text
          " It should be safe to replace Pervasives[], \n    we should test cases  like module Pervasives = List "]
        let filter_serializable_signatures (signature : Types.signature) =
          (List.filter
             (fun x  ->
                match (x : Types.signature_item) with
                | Sig_value (_,{ val_kind = Val_prim _ }) -> false
                | Sig_typext _|Sig_module _|Sig_class _|Sig_value _ -> true
                | _ -> false) signature : Types.signature)[@@ocaml.text
                                                            " It should be safe to replace Pervasives[], \n    we should test cases  like module Pervasives = List "]
        let find_serializable_signatures_by_path (v : Path.t) (env : Env.t) =
          (match Env.find_module v env with
           | exception Not_found  -> None
           | { md_type = Mty_signature signature;_} ->
               Some (filter_serializable_signatures signature)
           | _ ->
               (Ext_log.err __LOC__ "@[impossible path %s@]@." (Path.name v);
                assert false) : Types.signature option)
        let rec dump_summary fmt (x : Env.summary) =
          match x with
          | Env_empty  -> ()
          | Env_value (s,id,value_description) ->
              (dump_summary fmt s;
               Printtyp.value_description id fmt value_description)
          | _ -> ()
        let query_type (id : Ident.t) (env : Env.t) =
          match Env.find_value (Pident id) env with
          | exception Not_found  -> ""
          | { val_type } ->
              Format.asprintf "%a" (!Oprint.out_type)
                (Printtyp.tree_of_type_scheme val_type)
        let list_of_arrow ty =
          let rec aux (ty : Types.type_expr) acc =
            match (Ctype.repr ty).desc with
            | Tarrow (label,t1,t2,_) -> aux t2 ((label, t1) :: acc)
            | return_type -> (return_type, (List.rev acc)) in
          aux ty []
        let is_optional l = ((String.length l) > 0) && ((l.[0]) = '?')
        let label_name l =
          if is_optional l
          then `Optional (String.sub l 1 ((String.length l) - 1))
          else `Label l
      end 
    module String_map : sig include (Map.S with type  key =  string) end =
      struct include Map.Make(String) end 
    module Lam_compile_defs :
      sig
        [@@@ocaml.text
          " Type defintion to keep track of compilation state \n  "]
        [@@@ocaml.text
          " Some types are defined in this module to help avoiding generating unnecessary symbols \n    (generating too many symbols will make the output code unreadable)\n"]
        type jbl_label = int
        module HandlerMap : (Map.S with type  key =  jbl_label)
        type value = {
          exit_id: Ident.t;
          args: Ident.t list;}
        type let_kind = Lambda.let_kind
        type st =
          | EffectCall
          | Declare of let_kind* J.ident
          | NeedValue
          | Assign of
          J.ident[@ocaml.doc
                   " when use [Assign], var is not needed, since it's already declared \n      make sure all [Assign] are declared first, otherwise you are creating global variables\n   "]
        type return_label =
          {
          id: Ident.t;
          label: J.label;
          params: Ident.t list;
          immutable_mask: bool array;
          mutable new_params: Ident.t Ident_map.t;
          mutable triggered: bool;}
        type return_type =
          | False
          | True of return_label option
        type cxt =
          {
          st: st;
          should_return: return_type;
          jmp_table: value HandlerMap.t;
          meta: Lam_stats.meta;}
        val empty_handler_map : value HandlerMap.t
      end =
      struct
        type jbl_label = int
        module HandlerMap =
          Map.Make(struct
                     type t = jbl_label
                     let compare x y = compare (x : t) y
                   end)
        type value = {
          exit_id: Ident.t;
          args: Ident.t list;}
        type return_label =
          {
          id: Ident.t;
          label: J.label;
          params: Ident.t list;
          immutable_mask: bool array;
          mutable new_params: Ident.t Ident_map.t;
          mutable triggered: bool;}
        type return_type =
          | False
          | True of return_label option
        type let_kind = Lambda.let_kind
        type st =
          | EffectCall
          | Declare of let_kind* J.ident
          | NeedValue
          | Assign of J.ident
        type cxt =
          {
          st: st;
          should_return: return_type;
          jmp_table: value HandlerMap.t;
          meta: Lam_stats.meta;}
        let empty_handler_map = HandlerMap.empty
      end 
    module Lam_compile_util :
      sig
        [@@@ocaml.text " Some utilities for lambda compilation"]
        val jsop_of_comp : Lambda.comparison -> Js_op.binop
        val comment_of_tag_info : Lambda.tag_info -> string option
        val comment_of_pointer_info : Lambda.pointer_info -> string option
      end =
      struct
        let jsop_of_comp (cmp : Lambda.comparison) =
          (match cmp with
           | Ceq  -> EqEqEq
           | Cneq  -> NotEqEq
           | Clt  -> Lt
           | Cgt  -> Gt
           | Cle  -> Le
           | Cge  -> Ge : Js_op.binop)
        let comment_of_tag_info (x : Lambda.tag_info) =
          match x with
          | Constructor n -> Some n
          | Tuple  -> Some "tuple"
          | Variant x -> Some ("`" ^ x)
          | Record  -> Some "record"
          | Array  -> Some "array"
          | NA  -> None
        let comment_of_pointer_info (x : Lambda.pointer_info) =
          match x with
          | NullConstructor x -> Some x
          | NullVariant x -> Some x
          | NAPointer  -> None
      end 
    module Js_analyzer :
      sig
        [@@@ocaml.text " Analyzing utilities for [J] module "]
        [@@@ocaml.text " for example, whether it has side effect or not.\n "]
        val free_variables_of_statement :
          Ident_set.t -> Ident_set.t -> J.statement -> Ident_set.t
        val free_variables_of_expression :
          Ident_set.t ->
            Ident_set.t -> J.finish_ident_expression -> Ident_set.t
        val no_side_effect_expression : J.expression -> bool[@@ocaml.doc
                                                              " [no_side_effect] means this expression has no side effect, \n    but it might *depend on value store*, so you can not just move it around,\n\n    for example,\n    when you want to do a deep copy, the expression passed to you is pure\n    but you still have to call the function to make a copy, \n    since it maybe changed later\n "]
        val no_side_effect_statement : J.statement -> bool[@@ocaml.doc
                                                            " \n    here we say \n    {[ var x = no_side_effect_expression ]}\n    is [no side effect], but it is actually side effect, \n    since  we are defining a variable, however, if it is not exported or used, \n    then it's fine, so we delay this check later\n "]
        val eq_expression : J.expression -> J.expression -> bool
        val eq_statement : J.statement -> J.statement -> bool
        val rev_flatten_seq : J.expression -> J.block
        val rev_toplevel_flatten : J.block -> J.block[@@ocaml.doc
                                                       " return the block in reverse order "]
      end =
      struct
        let free_variables used_idents defined_idents =
          object (self)
            inherit  Js_fold.fold as super
            val defined_idents = defined_idents
            val used_idents = used_idents
            method! variable_declaration st =
              match st with
              | { ident; value = None  } ->
                  {<defined_idents = Ident_set.add ident defined_idents>}
              | { ident; value = Some v } ->
                  ({<defined_idents = Ident_set.add ident defined_idents>})#expression
                    v
            method! ident id =
              if Ident_set.mem id defined_idents
              then self
              else {<used_idents = Ident_set.add id used_idents>}
            method! expression exp =
              match exp.expression_desc with
              | Fun (_,_,env) ->
                  {<used_idents =
                      Ident_set.union (Js_fun_env.get_bound env) used_idents>}
              | _ -> super#expression exp
            method get_depenencies =
              Ident_set.diff used_idents defined_idents
            method get_used_idents = used_idents
            method get_defined_idents = defined_idents
          end
        let free_variables_of_statement used_idents defined_idents st =
          ((free_variables used_idents defined_idents)#statement st)#get_depenencies
        let free_variables_of_expression used_idents defined_idents st =
          ((free_variables used_idents defined_idents)#expression st)#get_depenencies
        let rec no_side_effect (x : J.expression) =
          match x.expression_desc with
          | Var _ -> true
          | Access (a,b) -> (no_side_effect a) && (no_side_effect b)
          | Str (b,_) -> b
          | Fun _ -> true
          | Number _ -> true
          | Array (xs,_mutable_flag) -> List.for_all no_side_effect xs
          | Seq (a,b) -> (no_side_effect a) && (no_side_effect b)
          | _ -> false
        let no_side_effect_expression (x : J.expression) = no_side_effect x
        let no_side_effect init =
          object (self)
            inherit  Js_fold.fold as super
            val no_side_effect = init
            method get_no_side_effect = no_side_effect
            method! statement s =
              if not no_side_effect
              then self
              else
                (match s.statement_desc with
                 | Throw _ -> {<no_side_effect = false>}
                 | _ -> super#statement s)
            method! list f x =
              if not self#get_no_side_effect then self else super#list f x
            method! expression s =
              if not no_side_effect
              then self
              else {<no_side_effect = no_side_effect_expression s>}
            [@@@ocaml.text " only expression would cause side effec "]
          end
        let no_side_effect_statement st =
          ((no_side_effect true)#statement st)#get_no_side_effect
        let rec eq_expression (x : J.expression) (y : J.expression) =
          match ((x.expression_desc), (y.expression_desc)) with
          | (Number (Int i),Number (Int j)) -> i = j
          | (Number (Float i),Number (Float j)) -> false
          | (Math (name00,args00),Math (name10,args10)) ->
              (name00 = name10) && (eq_expression_list args00 args10)
          | (Access (a0,a1),Access (b0,b1)) ->
              (eq_expression a0 b0) && (eq_expression a1 b1)
          | (Call (a0,args00,_),Call (b0,args10,_)) ->
              (eq_expression a0 b0) && (eq_expression_list args00 args10)
          | (Var (Id i),Var (Id j)) -> Ident.same i j
          | (Bin (op0,a0,b0),Bin (op1,a1,b1)) ->
              (op0 = op1) && ((eq_expression a0 a1) && (eq_expression b0 b1))
          | (_,_) -> false
        and eq_expression_list xs ys =
          let rec aux xs ys =
            match (xs, ys) with
            | ([],[]) -> true
            | ([],_) -> false
            | (_,[]) -> false
            | (x::xs,y::ys) -> (eq_expression x y) && (aux xs ys) in
          aux xs ys
        and eq_statement (x : J.statement) (y : J.statement) =
          match ((x.statement_desc), (y.statement_desc)) with
          | (Exp a,Exp b)
            |(Return { return_value = a;_},Return { return_value = b;_}) ->
              eq_expression a b
          | (_,_) -> false
        let rev_flatten_seq (x : J.expression) =
          let rec aux acc (x : J.expression) =
            (match x.expression_desc with
             | Seq (a,b) -> aux (aux acc a) b
             | _ -> { statement_desc = (Exp x); comment = None } :: acc : 
            J.block) in
          aux [] x
        let rev_toplevel_flatten block =
          let rec aux acc (xs : J.block) =
            (match xs with
             | [] -> acc
             | {
                 statement_desc = Variable
                   ({ ident_info = { used_stats = Dead_pure  };_}
                    |{ ident_info = { used_stats = Dead_non_pure  };
                       value = None  })
                 }::xs -> aux acc xs
             | { statement_desc = Block b;_}::xs -> aux (aux acc b) xs
             | x::xs -> aux (x :: acc) xs : J.block) in
          aux [] block
      end 
    module Ext_bytes :
      sig
        [@@@ocaml.text
          " Port the {!Bytes.escaped} to make it not locale sensitive "]
        val escaped : bytes -> bytes
      end =
      struct
        external char_code : char -> int = "%identity"
        external char_chr : int -> char = "%identity"
        let escaped s =
          let n = ref 0 in
          for i = 0 to (Bytes.length s) - 1 do
            n :=
              ((!n) +
                 ((match Bytes.unsafe_get s i with
                   | '"'|'\\'|'\n'|'\t'|'\r'|'\b' -> 2
                   | ' '..'~' -> 1
                   | _ -> 4)))
          done;
          if (!n) = (Bytes.length s)
          then Bytes.copy s
          else
            (let s' = Bytes.create (!n) in
             n := 0;
             for i = 0 to (Bytes.length s) - 1 do
               ((match Bytes.unsafe_get s i with
                 | '"'|'\\' as c ->
                     (Bytes.unsafe_set s' (!n) '\\';
                      incr n;
                      Bytes.unsafe_set s' (!n) c)
                 | '\n' ->
                     (Bytes.unsafe_set s' (!n) '\\';
                      incr n;
                      Bytes.unsafe_set s' (!n) 'n')
                 | '\t' ->
                     (Bytes.unsafe_set s' (!n) '\\';
                      incr n;
                      Bytes.unsafe_set s' (!n) 't')
                 | '\r' ->
                     (Bytes.unsafe_set s' (!n) '\\';
                      incr n;
                      Bytes.unsafe_set s' (!n) 'r')
                 | '\b' ->
                     (Bytes.unsafe_set s' (!n) '\\';
                      incr n;
                      Bytes.unsafe_set s' (!n) 'b')
                 | ' '..'~' as c -> Bytes.unsafe_set s' (!n) c
                 | c ->
                     let a = char_code c in
                     (Bytes.unsafe_set s' (!n) '\\';
                      incr n;
                      Bytes.unsafe_set s' (!n) (char_chr (48 + (a / 100)));
                      incr n;
                      Bytes.unsafe_set s' (!n)
                        (char_chr (48 + ((a / 10) mod 10)));
                      incr n;
                      Bytes.unsafe_set s' (!n) (char_chr (48 + (a mod 10)))));
                incr n)
             done;
             s')
      end 
    module Ext_string :
      sig
        [@@@ocaml.text
          " Extension to the standard library [String] module. "]
        val split_by :
          ?keep_empty:bool -> (char -> bool) -> string -> string list
        [@@ocaml.doc " default is false "]
        val split : ?keep_empty:bool -> string -> char -> string list
        [@@ocaml.doc " default is false "]
        val starts_with : string -> string -> bool
        val ends_with : string -> string -> bool
        val escaped : string -> string
      end =
      struct
        let split_by ?(keep_empty= false)  is_delim str =
          let len = String.length str in
          let rec loop acc last_pos pos =
            if pos = (-1)
            then (String.sub str 0 last_pos) :: acc
            else
              if is_delim (str.[pos])
              then
                (let new_len = (last_pos - pos) - 1 in
                 if (new_len != 0) || keep_empty
                 then
                   let v = String.sub str (pos + 1) new_len in
                   loop (v :: acc) pos (pos - 1)
                 else loop acc pos (pos - 1))
              else loop acc last_pos (pos - 1) in
          loop [] len (len - 1)
        let split ?keep_empty  str on =
          split_by ?keep_empty (fun x  -> (x : char) = on) str
        let starts_with s beg =
          let beg_len = String.length beg in
          let s_len = String.length s in
          (beg_len <= s_len) &&
            (let i = ref 0 in
             while ((!i) < beg_len) && ((s.[!i]) = (beg.[!i])) do incr i done;
             (!i) = beg_len)
        let ends_with s beg =
          let s_finish = (String.length s) - 1 in
          let s_beg = (String.length beg) - 1 in
          if s_beg > s_finish
          then false
          else
            (let rec aux j k =
               if k < 0
               then true
               else
                 if (String.unsafe_get s j) = (String.unsafe_get beg k)
                 then aux (j - 1) (k - 1)
                 else false in
             aux s_finish s_beg)
        let escaped s =
          let rec needs_escape i =
            if i >= (String.length s)
            then false
            else
              (match String.unsafe_get s i with
               | '"'|'\\'|'\n'|'\t'|'\r'|'\b' -> true
               | ' '..'~' -> needs_escape (i + 1)
               | _ -> true) in
          if needs_escape 0
          then
            Bytes.unsafe_to_string
              (Ext_bytes.escaped (Bytes.unsafe_of_string s))
          else s[@@ocaml.doc
                  "  In OCaml 4.02.3, {!String.escaped} is locale senstive, \n     this version try to make it not locale senstive, this bug is fixed\n     in the compiler trunk     \n"]
      end 
    module String_set : sig include (Set.S with type  elt =  string) end =
      struct include Set.Make(String) end 
    module Ext_ident :
      sig
        [@@@ocaml.text " A wrapper around [Ident] module in compiler-libs"]
        val is_js : Ident.t -> bool
        val is_js_object : Ident.t -> bool
        val create_js : string -> Ident.t
        val create : string -> Ident.t
        val create_js_module : string -> Ident.t
        val make_js_object : Ident.t -> unit
        val reset : unit -> unit
        val gen_js : ?name:string -> unit -> Ident.t
        val make_unused : unit -> Ident.t
        val is_unused_ident : Ident.t -> bool
        val convert : string -> string
      end =
      struct
        let js_flag = 8
        let js_module_flag = 16
        let js_object_flag = 32
        let is_js (i : Ident.t) = (i.flags land js_flag) <> 0
        let is_js_module (i : Ident.t) = (i.flags land js_module_flag) <> 0
        let is_js_object (i : Ident.t) = (i.flags land js_object_flag) <> 0
        let make_js_object (i : Ident.t) =
          i.flags <- i.flags lor js_object_flag
        let create_js (name : string) =
          ({ name; flags = js_flag; stamp = 0 } : Ident.t)
        let js_module_table = Hashtbl.create 31
        let create_js_module (name : string) =
          (let name =
             (String.concat "") @@
               ((List.map String.capitalize) @@ (Ext_string.split name '-')) in
           match Hashtbl.find js_module_table name with
           | exception Not_found  ->
               let v = Ident.create name in
               let ans = { v with flags = js_module_flag } in
               (Hashtbl.add js_module_table name ans; ans)
           | v -> v : Ident.t)
        let create = Ident.create
        let gen_js ?(name= "$js")  () = create name
        let reserved_words =
          ["break";
          "case";
          "catch";
          "continue";
          "debugger";
          "default";
          "delete";
          "do";
          "else";
          "finally";
          "for";
          "function";
          "if";
          "in";
          "instanceof";
          "new";
          "return";
          "switch";
          "this";
          "throw";
          "try";
          "typeof";
          "var";
          "void";
          "while";
          "with";
          "class";
          "enum";
          "export";
          "extends";
          "import";
          "super";
          "implements";
          "interface";
          "let";
          "package";
          "private";
          "protected";
          "public";
          "static";
          "yield";
          "null";
          "true";
          "false";
          "NaN";
          "undefined";
          "this";
          "abstract";
          "boolean";
          "byte";
          "char";
          "const";
          "double";
          "final";
          "float";
          "goto";
          "int";
          "long";
          "native";
          "short";
          "synchronized";
          "throws";
          "transient";
          "volatile";
          "await";
          "event";
          "location";
          "window";
          "document";
          "eval";
          "navigator";
          "Array";
          "Date";
          "Math";
          "JSON";
          "Object";
          "RegExp";
          "String";
          "Boolean";
          "Number";
          "Map";
          "Set";
          "Infinity";
          "isFinite";
          "ActiveXObject";
          "XMLHttpRequest";
          "XDomainRequest";
          "DOMException";
          "Error";
          "SyntaxError";
          "arguments";
          "decodeURI";
          "decodeURIComponent";
          "encodeURI";
          "encodeURIComponent";
          "escape";
          "unescape";
          "isNaN";
          "parseFloat";
          "parseInt";
          "require";
          "exports";
          "module"]
        let reserved_map =
          List.fold_left (fun acc  -> fun x  -> String_set.add x acc)
            String_set.empty reserved_words
        let convert (name : string) =
          let module E = struct exception Not_normal_letter of int end in
            let len = String.length name in
            if String_set.mem name reserved_map
            then "$$" ^ name
            else
              (try
                 for i = 0 to len - 1 do
                   (let c = String.unsafe_get name i in
                    if
                      not
                        (((c >= 'a') && (c <= 'z')) ||
                           (((c >= 'A') && (c <= 'Z')) ||
                              ((c = '_') || (c = '$'))))
                    then raise (E.Not_normal_letter i)
                    else ())
                 done;
                 name
               with
               | E.Not_normal_letter i ->
                   (String.sub name 0 i) ^
                     (let buffer = Buffer.create len in
                      (for j = i to len - 1 do
                         (let c = String.unsafe_get name j in
                          match c with
                          | '*' -> Buffer.add_string buffer "$star"
                          | '\'' -> Buffer.add_string buffer "$prime"
                          | '!' -> Buffer.add_string buffer "$bang"
                          | '>' -> Buffer.add_string buffer "$great"
                          | '<' -> Buffer.add_string buffer "$less"
                          | '=' -> Buffer.add_string buffer "$eq"
                          | '+' -> Buffer.add_string buffer "$plus"
                          | '-' -> Buffer.add_string buffer "$neg"
                          | '@' -> Buffer.add_string buffer "$at"
                          | '^' -> Buffer.add_string buffer "$caret"
                          | '/' -> Buffer.add_string buffer "$slash"
                          | '.' -> Buffer.add_string buffer "$dot"
                          | 'a'..'z'|'A'..'Z'|'_'|'$'|'0'..'9' ->
                              Buffer.add_char buffer c
                          | _ -> Buffer.add_string buffer "$unknown")
                       done;
                       Buffer.contents buffer)))
        let make_unused () = create "_"
        let is_unused_ident i = (Ident.name i) = "_"
        let reset () = Hashtbl.clear js_module_table
      end 
    module J_helper :
      sig
        [@@@ocaml.text " Creator utilities for the [J] module "]
        val prim : string
        val exceptions : string
        val io : string
        val oo : string
        val sys : string
        val lex_parse : string
        val obj_runtime : string
        val array : string
        val format : string
        val string : string
        val float : string
        val no_side_effect : J.expression -> bool
        val is_constant : J.expression -> bool[@@ocaml.doc
                                                " check if a javascript ast is constant \n    \n    The better signature might be \n    {[\n    J.expresssion -> Js_output.t\n    ]}\n    for exmaple\n    {[\n    e ?print_int(3) :  0\n    --->\n    if(e){print_int(3)}\n    ]}\n"]
        val extract_non_pure : J.expression -> J.expression option
        module Exp :
        sig
          type t = J.expression
          val mk : ?comment:string -> J.expression_desc -> t
          val access : ?comment:string -> t -> t -> t
          val string_access : ?comment:string -> t -> t -> t
          val var : ?comment:string -> J.ident -> t
          val runtime_var_dot : ?comment:string -> string -> string -> t
          val runtime_var_vid : string -> string -> J.vident
          val ml_var_dot : ?comment:string -> Ident.t -> string -> t
          val external_var_dot :
            ?comment:string -> Ident.t -> string -> string -> t
          val ml_var : ?comment:string -> Ident.t -> t
          val runtime_call : string -> string -> t list -> t
          val runtime_ref : string -> string -> t
          val str : ?pure:bool -> ?comment:string -> string -> t
          val efun :
            ?comment:string ->
              ?immutable_mask:bool array -> J.ident list -> J.block -> t
          val econd : ?comment:string -> t -> t -> t -> t
          val int : ?comment:string -> ?c:char -> int -> t
          val float : ?comment:string -> float -> t
          val dot : ?comment:string -> t -> string -> t
          val array_length : ?comment:string -> t -> t
          val string_length : ?comment:string -> t -> t
          val string_of_small_int_array : ?comment:string -> t -> t
          val bytes_length : ?comment:string -> t -> t
          val function_length : ?comment:string -> t -> t
          val char_of_int : ?comment:string -> t -> t
          val char_to_int : ?comment:string -> t -> t
          val array_append : ?comment:string -> t -> t list -> t
          val string_append : ?comment:string -> t -> t -> t[@@ocaml.doc
                                                              "\n     When in ES6 mode, we can use Symbol to guarantee its uniquess,\n     we can not tag [js] object, since it can be frozen \n   "]
          val tag_ml_obj : ?comment:string -> t -> t
          val var_dot : ?comment:string -> Ident.t -> string -> t
          val js_global_dot : ?comment:string -> string -> string -> t
          val index : ?comment:string -> t -> int -> t
          val assign : ?comment:string -> t -> t -> t
          val triple_equal : ?comment:string -> t -> t -> t
          val is_type_number : ?comment:string -> t -> t
          val bin : ?comment:string -> Js_op.binop -> t -> t -> t
          val int_plus : ?comment:string -> t -> t -> t
          val int_minus : ?comment:string -> t -> t -> t
          val float_plus : ?comment:string -> t -> t -> t
          val float_minus : ?comment:string -> t -> t -> t
          val not : t -> t
          val call :
            ?comment:string -> ?info:Js_call_info.t -> t -> t list -> t
          val flat_call : ?comment:string -> t -> t -> t
          val dump : ?comment:string -> Js_op.level -> t list -> t
          val new_ :
            ?comment:string -> J.expression -> J.expression list -> t
          val arr :
            ?comment:string -> J.mutable_flag -> J.expression list -> t
          val uninitialized_array : ?comment:string -> t -> t
          val seq : ?comment:string -> t -> t -> t
          val obj : ?comment:string -> J.property_map -> t
          val true_ : t
          val false_ : t
          val bool : bool -> t
          val unknown_lambda : ?comment:string -> Lambda.lambda -> t
          val unknown_primitive : ?comment:string -> Lambda.primitive -> t
          val unit : unit -> t[@@ocaml.doc
                                " [unit] in ocaml will be compiled into [0]  in js "]
          val js_var : ?comment:string -> string -> t
          val js_global : ?comment:string -> string -> t
          val undefined : ?comment:string -> unit -> t
          val math : ?comment:string -> string -> t list -> t[@@ocaml.doc
                                                               " [math \"abs\"] --> Math[\"abs\"] "]
          val inc : ?comment:string -> t -> t
          val dec : ?comment:string -> t -> t
          val prefix_inc : ?comment:string -> J.vident -> t
          val prefix_dec : ?comment:string -> J.vident -> t
          val null : ?comment:string -> unit -> t
          val tag : ?comment:string -> J.expression -> t
          val to_ocaml_boolean : ?comment:string -> t -> t
          val and_ : ?comment:string -> t -> t -> t
          val or_ : ?comment:string -> t -> t -> t
          val lt : ?comment:string -> t -> t -> t
          val le : ?comment:string -> t -> t -> t
          val gt : ?comment:string -> t -> t -> t
          val ge : ?comment:string -> t -> t -> t
          val intcomp : ?comment:string -> Lambda.comparison -> t -> t -> t
          val stringcomp : ?comment:string -> Js_op.binop -> t -> t -> t
          val add : ?comment:string -> t -> t -> t
          val minus : ?comment:string -> t -> t -> t
          val mul : ?comment:string -> t -> t -> t
          val div : ?comment:string -> t -> t -> t
          val of_block :
            ?comment:string -> J.statement list -> J.expression -> t
        end
        module Stmt :
        sig
          type t = J.statement
          val mk : ?comment:string -> J.statement_desc -> t
          val empty : ?comment:string -> unit -> t
          val throw : ?comment:string -> J.expression -> t
          val if_ :
            ?comment:string ->
              ?declaration:(Lambda.let_kind* Ident.t) ->
                ?else_:J.block -> J.expression -> J.block -> t
          val block : ?comment:string -> J.block -> t
          val int_switch :
            ?comment:string ->
              ?declaration:(Lambda.let_kind* Ident.t) ->
                ?default:J.block ->
                  J.expression -> int J.case_clause list -> t
          val string_switch :
            ?comment:string ->
              ?declaration:(Lambda.let_kind* Ident.t) ->
                ?default:J.block ->
                  J.expression -> string J.case_clause list -> t
          val declare_variable :
            ?comment:string ->
              ?ident_info:J.ident_info ->
                kind:Lambda.let_kind -> Ident.t -> t
          val define :
            ?comment:string ->
              ?ident_info:J.ident_info ->
                kind:Lambda.let_kind -> Ident.t -> J.expression -> t
          val const_variable :
            ?comment:string -> ?exp:J.expression -> Ident.t -> t
          val assign : ?comment:string -> J.ident -> J.expression -> t
          val assign_unit : ?comment:string -> J.ident -> t
          val declare_unit : ?comment:string -> J.ident -> t
          val while_ :
            ?comment:string ->
              ?label:J.label -> ?env:Js_closure.t -> Exp.t -> J.block -> t
          val for_ :
            ?comment:string ->
              ?env:Js_closure.t ->
                J.for_ident_expression option ->
                  J.finish_ident_expression ->
                    J.for_ident -> J.for_direction -> J.block -> t
          val try_ :
            ?comment:string ->
              ?with_:(J.ident* J.block) -> ?finally:J.block -> J.block -> t
          val exp : ?comment:string -> J.expression -> t
          val return : ?comment:string -> J.expression -> t
          val unknown_lambda : ?comment:string -> Lambda.lambda -> t
          val return_unit : ?comment:string -> unit -> t[@@ocaml.doc
                                                          " for ocaml function which returns unit \n      it will be compiled into [return 0] in js "]
          val break : ?comment:string -> unit -> t
          val continue : ?comment:string -> J.label -> t
        end
      end =
      struct
        let prim = "Caml_primitive"
        let exceptions = "Caml_exceptions"
        let io = "Caml_io"
        let sys = "Caml_sys"
        let lex_parse = "Caml_lexer"
        let obj_runtime = "Caml_obj_runtime"
        let array = "Caml_array"
        let format = "Caml_format"
        let string = "Caml_string"
        let float = "Caml_float"
        let oo = "Caml_oo"
        let no_side_effect = Js_analyzer.no_side_effect_expression
        let rec extract_non_pure (x : J.expression) =
          match x.expression_desc with
          | Var _|Str _|Number _ -> None
          | Access (a,b) ->
              (match ((extract_non_pure a), (extract_non_pure b)) with
               | (None ,None ) -> None
               | (_,_) -> Some x)
          | Array (xs,_mutable_flag) ->
              if List.for_all (fun x  -> (extract_non_pure x) = None) xs
              then None
              else Some x
          | Seq (a,b) ->
              (match ((extract_non_pure a), (extract_non_pure b)) with
               | (None ,None ) -> None
               | (Some u,Some v) ->
                   Some { x with expression_desc = (Seq (u, v)) }
               | (None ,(Some _ as v)) -> v
               | ((Some _ as u),None ) -> u)
          | _ -> Some x
        let rec is_constant (x : J.expression) =
          match x.expression_desc with
          | Access (a,b) -> (is_constant a) && (is_constant b)
          | Str (b,_) -> b
          | Number _ -> true
          | Array (xs,_mutable_flag) -> List.for_all is_constant xs
          | _ -> false
        module Exp =
          struct
            type t = J.expression
            let mk ?comment  exp = ({ expression_desc = exp; comment } : t)
            let var ?comment  id =
              ({ expression_desc = (Var (Id id)); comment } : t)
            let runtime_var_dot ?comment  (x : string) (e1 : string) =
              ({
                 expression_desc =
                   (Var
                      (Qualified
                         ((Ext_ident.create_js x), Runtime, (Some e1))));
                 comment
               } : J.expression)
            let runtime_var_vid x e1 =
              (Qualified ((Ext_ident.create_js x), Runtime, (Some e1)) : 
              J.vident)
            let ml_var_dot ?comment  (id : Ident.t) e =
              ({
                 expression_desc = (Var (Qualified (id, Ml, (Some e))));
                 comment
               } : J.expression)
            let external_var_dot ?comment  (id : Ident.t) name fn =
              ({
                 expression_desc =
                   (Var (Qualified (id, (External name), (Some fn))));
                 comment
               } : t)
            let ml_var ?comment  (id : Ident.t) =
              ({ expression_desc = (Var (Qualified (id, Ml, None))); comment
               } : t)
            let str ?(pure= true)  ?comment  s =
              ({ expression_desc = (Str (pure, s)); comment } : t)
            let efun ?comment  ?immutable_mask  params block =
              (let len = List.length params in
               {
                 expression_desc =
                   (Fun
                      (params, block, (Js_fun_env.empty ?immutable_mask len)));
                 comment
               } : t)
            let rec seq ?comment  (e0 : t) (e1 : t) =
              (match ((e0.expression_desc), (e1.expression_desc)) with
               | ((Seq (a,{ expression_desc = Number _ })|Seq
                   ({ expression_desc = Number _ },a)),_) ->
                   seq ?comment a e1
               | (_,Seq ({ expression_desc = Number _ },a)) ->
                   seq ?comment e0 a
               | (_,Seq (a,({ expression_desc = Number _ } as v))) ->
                   seq ?comment (seq e0 a) v
               | _ -> { expression_desc = (Seq (e0, e1)); comment } : 
              t)
            let rec econd ?comment  (b : t) (t : t) (f : t) =
              (match ((b.expression_desc), (t.expression_desc),
                       (f.expression_desc))
               with
               | (Number (Int { i = 0;_}|Float 0.),_,_) -> f
               | ((Number _|Array _),_,_) -> t
               | ((Bin
                   (EqEqEq ,{ expression_desc = Number (Int { i = 0;_});_},x)
                   |Bin
                   (EqEqEq ,x,{ expression_desc = Number (Int { i = 0;_});_})),_,_)
                   -> econd ?comment x f t
               | (Bin
                  (Ge
                   ,{
                      expression_desc =
                        (String_length _|Array_length _|Bytes_length _
                         |Function_length _);_},{
                                                  expression_desc = Number
                                                    (Int { i = 0;_})
                                                  }),_,_)
                   -> f
               | (Bin
                  (Gt
                   ,({
                       expression_desc =
                         (String_length _|Array_length _|Bytes_length _
                          |Function_length _);_}
                       as pred),{ expression_desc = Number (Int { i = 0 }) }),_,_)
                   -> econd ?comment pred t f
               | (Int_of_boolean b,_,_) -> econd ?comment b t f
               | _ ->
                   if Js_analyzer.eq_expression t f
                   then (if no_side_effect b then t else seq ?comment b t)
                   else { expression_desc = (Cond (b, t, f)); comment } : 
              t)
            let int ?comment  ?c  i =
              ({ expression_desc = (Number (Int { i; c })); comment } : 
              t)
            let access ?comment  (e0 : t) (e1 : t) =
              (match ((e0.expression_desc), (e1.expression_desc)) with
               | (Array (l,_mutable_flag),Number (Int { i;_})) when
                   no_side_effect e0 -> List.nth l i
               | _ -> { expression_desc = (Access (e0, e1)); comment } : 
              t)
            let string_access ?comment  (e0 : t) (e1 : t) =
              (match ((e0.expression_desc), (e1.expression_desc)) with
               | (Str (_,s),Number (Int { i;_})) when
                   (i >= 0) && (i < (String.length s)) ->
                   str (String.make 1 (s.[i]))
               | _ -> { expression_desc = (String_access (e0, e1)); comment } : 
              t)
            let index ?comment  (e0 : t) (e1 : int) =
              (match e0.expression_desc with
               | Array (l,_mutable_flag) when no_side_effect e0 ->
                   List.nth l e1
               | _ -> { expression_desc = (Access (e0, (int e1))); comment } : 
              t)
            let call ?comment  ?info  e0 args =
              (let info =
                 match info with | None  -> Js_call_info.dummy | Some x -> x in
               { expression_desc = (Call (e0, args, info)); comment } : 
              t)
            let flat_call ?comment  e0 es =
              ({ expression_desc = (FlatCall (e0, es)); comment } : t)
            let runtime_call module_name fn_name args =
              call ~info:{ arity = Full }
                (runtime_var_dot module_name fn_name) args
            let runtime_ref module_name fn_name =
              runtime_var_dot module_name fn_name
            let js_var ?comment  (v : string) =
              var ?comment (Ext_ident.create_js v)
            let js_global ?comment  (v : string) =
              var ?comment (Ext_ident.create_js v)
            let dot ?comment  (e0 : t) (e1 : string) =
              ({ expression_desc = (Dot (e0, e1, true)); comment } : 
              t)[@@ocaml.doc
                  " used in normal property\n      like [e.length], no dependency introduced\n   "]
            let array_length ?comment  (e : t) =
              (match e.expression_desc with
               | Array (l,_) -> int ?comment (List.length l)
               | _ -> { expression_desc = (Array_length e); comment } : 
              t)
            let string_length ?comment  (e : t) =
              (match e.expression_desc with
               | Str (_,v) -> int ?comment (String.length v)
               | _ -> { expression_desc = (String_length e); comment } : 
              t)
            let bytes_length ?comment  (e : t) =
              (match e.expression_desc with
               | Array (l,_) -> int ?comment (List.length l)
               | Str (_,v) -> int ?comment (String.length v)
               | _ -> { expression_desc = (Bytes_length e); comment } : 
              t)
            let function_length ?comment  (e : t) =
              (match e.expression_desc with
               | Fun (params,_,_) -> int ?comment (List.length params)
               | _ -> { expression_desc = (Function_length e); comment } : 
              t)
            let js_global_dot ?comment  (x : string) (e1 : string) =
              ({ expression_desc = (Dot ((js_var x), e1, true)); comment } : 
              t)[@@ocaml.doc " no dependency introduced "]
            let char_of_int ?comment  (v : t) =
              (match v.expression_desc with
               | Number (Int { i;_}) -> str (String.make 1 (Char.chr i))
               | Char_to_int v -> v
               | _ -> { comment; expression_desc = (Char_of_int v) } : 
              t)
            let char_to_int ?comment  (v : t) =
              (match v.expression_desc with
               | Str (_,x) ->
                   (assert ((String.length x) = 1);
                    int ~comment:("\"" ^ ((Ext_string.escaped x) ^ "\""))
                      (Char.code (x.[0])))
               | Char_of_int v -> v
               | _ -> { comment; expression_desc = (Char_to_int v) } : 
              t)
            let array_append ?comment  e el =
              ({ comment; expression_desc = (Array_append (e, el)) } : 
              t)
            let dump ?comment  level el =
              ({ comment; expression_desc = (Dump (level, el)) } : t)
            let rec string_append ?comment  (e : t) (el : t) =
              (match ((e.expression_desc), (el.expression_desc)) with
               | (Str (_,a),String_append
                  ({ expression_desc = Str (_,b) },c)) ->
                   string_append ?comment (str (a ^ b)) c
               | (String_append (c,{ expression_desc = Str (_,b) }),Str
                  (_,a)) -> string_append ?comment c (str (b ^ a))
               | (String_append
                  (a,{ expression_desc = Str (_,b) }),String_append
                  ({ expression_desc = Str (_,c) },d)) ->
                   string_append ?comment (string_append a (str (b ^ c))) d
               | (Str (_,a),Str (_,b)) -> str ?comment (a ^ b)
               | (_,_) ->
                   { comment; expression_desc = (String_append (e, el)) } : 
              t)
            let int_plus ?comment  (e0 : t) (e1 : t) =
              (match ((e0.expression_desc), (e1.expression_desc)) with
               | (Number (Int { i = a;_}),Number (Int { i = b;_})) ->
                   int (a + b)
               | (_,_) -> { comment; expression_desc = (Bin (Plus, e0, e1)) } : 
              t)
            let int_minus ?comment  (e0 : t) (e1 : t) =
              (match ((e0.expression_desc), (e1.expression_desc)) with
               | (Number (Int { i = a;_}),Number (Int { i = b;_})) ->
                   int (a - b)
               | (_,_) ->
                   { comment; expression_desc = (Bin (Minus, e0, e1)) } : 
              t)
            let float_plus ?comment  (e0 : t) (e1 : t) =
              ({ comment; expression_desc = (Bin (Plus, e0, e1)) } : 
              t)
            let float_minus ?comment  (e0 : t) (e1 : t) =
              ({ comment; expression_desc = (Bin (Minus, e0, e1)) } : 
              t)
            let obj ?comment  properties =
              ({ expression_desc = (Object properties); comment } : t)
            let tag_ml_obj ?comment  e =
              ({ comment; expression_desc = (Tag_ml_obj e) } : t)
            let var_dot ?comment  (x : Ident.t) (e1 : string) =
              ({ expression_desc = (Dot ((var x), e1, true)); comment } : 
              t)
            let float ?comment  i =
              ({ expression_desc = (Number (Float i)); comment } : t)
            let assign ?comment  e0 e1 =
              ({ expression_desc = (Bin (Eq, e0, e1)); comment } : t)
            let to_ocaml_boolean ?comment  (e : t) =
              (match e.expression_desc with
               | Int_of_boolean _ -> e
               | _ -> { comment; expression_desc = (Int_of_boolean e) } : 
              t)[@@ocaml.doc
                  " Convert a javascript boolean to ocaml boolean\n      It's necessary for return value\n       this should be optmized away for [if] ,[cond] to produce \n      more readable code\n   "]
            let true_ = int ~comment:"true" 1
            let false_ = int ~comment:"false" 0
            let bool v = if v then true_ else false_
            let rec triple_equal ?comment  (e0 : t) (e1 : t) =
              (match ((e0.expression_desc), (e1.expression_desc)) with
               | (Str (_,x),Str (_,y)) ->
                   if (String.compare x y) = 0
                   then int ?comment 1
                   else int ?comment 0
               | (Char_to_int a,Char_to_int b) -> triple_equal ?comment a b
               | (Char_to_int a,Number (Int { i; c = Some v }))
                 |(Number (Int { i; c = Some v }),Char_to_int a) ->
                   triple_equal ?comment a (str (String.make 1 v))
               | (Char_of_int a,Char_of_int b) -> triple_equal ?comment a b
               | _ ->
                   to_ocaml_boolean @@
                     { expression_desc = (Bin (EqEqEq, e0, e1)); comment } : 
              t)
            let bin ?comment  (op : J.binop) e0 e1 =
              (match op with
               | EqEqEq  -> triple_equal ?comment e0 e1
               | _ -> { expression_desc = (Bin (op, e0, e1)); comment } : 
              t)
            let arr ?comment  mt es =
              ({ expression_desc = (Array (es, mt)); comment } : t)
            let uninitialized_array ?comment  (e : t) =
              (match e.expression_desc with
               | Number (Int { i = 0;_}) -> arr ?comment NA []
               | _ -> { comment; expression_desc = (Array_of_size e) } : 
              t)
            let stringcomp ?comment  cmp e0 e1 =
              to_ocaml_boolean @@ (bin ?comment cmp e0 e1)[@@ocaml.doc
                                                            " TODO: remove : ?? "]
            let intcomp ?comment  cmp e0 e1 =
              to_ocaml_boolean @@
                (bin ?comment (Lam_compile_util.jsop_of_comp cmp) e0 e1)
            let is_type_number ?comment  (e : t) =
              (match e.expression_desc with
               | Number _|Array_length _|String_length _ -> true_
               | Str _|Array _ -> false_
               | _ ->
                   to_ocaml_boolean @@
                     { expression_desc = (Is_type_number e); comment } : 
              t)
            let rec not (({ expression_desc; comment } as e) : t) =
              (match expression_desc with
               | Bin (EqEqEq ,e0,e1) ->
                   { expression_desc = (Bin (NotEqEq, e0, e1)); comment }
               | Bin (NotEqEq ,e0,e1) ->
                   { expression_desc = (Bin (EqEqEq, e0, e1)); comment }
               | Number (Int { i;_}) -> if i != 0 then false_ else true_
               | Int_of_boolean e -> not e
               | x -> { expression_desc = (Not e); comment = None } : 
              t)
            let new_ ?comment  e0 args =
              ({ expression_desc = (New (e0, (Some args))); comment } : 
              t)
            let unknown_lambda ?(comment= "unknown")  (lam : Lambda.lambda) =
              (str ~pure:false ~comment (Lam_util.string_of_lambda lam) : 
              t)[@@ocaml.doc " cannot use [boolean] in js   "]
            let unknown_primitive ?(comment= "unknown") 
              (p : Lambda.primitive) =
              (str ~pure:false ~comment (Lam_util.string_of_primitive p) : 
              t)
            let unit () = int ~comment:"()" 0
            let undefined ?comment  () = js_global ?comment "undefined"
            let math ?comment  v args =
              ({ comment; expression_desc = (Math (v, args)) } : t)
            let inc ?comment  (e : t) =
              match e with
              | { expression_desc = Number (Int ({ i;_} as v));_} ->
                  {
                    e with
                    expression_desc = (Number (Int { v with i = (i + 1) }))
                  }
              | _ -> bin ?comment Plus e (int 1)
            let rec and_ ?comment  (e1 : t) (e2 : t) =
              match (e1, e2) with
              | ({ expression_desc = Int_of_boolean e1;_},{
                                                            expression_desc =
                                                              Int_of_boolean
                                                              e2;_})
                  -> and_ ?comment e1 e2
              | ({ expression_desc = Int_of_boolean e1;_},e2) ->
                  and_ ?comment e1 e2
              | (e1,{ expression_desc = Int_of_boolean e2;_}) ->
                  and_ ?comment e1 e2
              | (e1,e2) -> to_ocaml_boolean @@ (bin ?comment And e1 e2)
            let rec or_ ?comment  (e1 : t) (e2 : t) =
              match (e1, e2) with
              | ({ expression_desc = Int_of_boolean e1;_},{
                                                            expression_desc =
                                                              Int_of_boolean
                                                              e2;_})
                  -> or_ ?comment e1 e2
              | ({ expression_desc = Int_of_boolean e1;_},e2) ->
                  or_ ?comment e1 e2
              | (e1,{ expression_desc = Int_of_boolean e2;_}) ->
                  or_ ?comment e1 e2
              | (e1,e2) -> to_ocaml_boolean @@ (bin ?comment Or e1 e2)
            let string_of_small_int_array ?comment  xs =
              ({ expression_desc = (String_of_small_int_array xs); comment } : 
              t)
            let lt ?comment  e0 e1 =
              to_ocaml_boolean @@ (bin ?comment Lt e0 e1)
            let le ?comment  e0 e1 =
              to_ocaml_boolean @@ (bin ?comment Le e0 e1)
            let gt ?comment  e0 e1 =
              to_ocaml_boolean @@ (bin ?comment Gt e0 e1)
            let ge ?comment  e0 e1 =
              to_ocaml_boolean @@ (bin ?comment Ge e0 e1)
            let dec ?comment  (e : t) =
              match e with
              | { expression_desc = Number (Int ({ i;_} as v));_} ->
                  {
                    e with
                    expression_desc = (Number (Int { v with i = (i - 1) }))
                  }
              | _ -> bin ?comment Minus e (int 1)
            let prefix_inc ?comment  (i : J.vident) =
              let v: t = { expression_desc = (Var i); comment = None } in
              assign ?comment v (int_plus v (int 1))
            let prefix_dec ?comment  i =
              let v: t = { expression_desc = (Var i); comment = None } in
              assign ?comment v (int_minus v (int 1))
            let null ?comment  () = js_global ?comment "null"
            let tag ?comment  e = index ?comment e 0
            let rec add ?comment  (e1 : t) (e2 : t) =
              match ((e1.expression_desc), (e2.expression_desc)) with
              | (Number (Int { i;_}),Number (Int { i = j;_})) ->
                  int ?comment (i + j)
              | (Bin
                 (Plus ,a1,{ expression_desc = Number (Int { i = k;_}) }),Number
                 (Int { i = j;_})) -> bin ?comment Plus a1 (int (k + j))
              | _ -> bin ?comment Plus e1 e2
            and minus ?comment  e1 e2 = bin ?comment Minus e1 e2
            and mul ?comment  e1 e2 = bin ?comment Mul e1 e2
            and div ?comment  e1 e2 = bin ?comment Div e1 e2
            let of_block ?comment  block e =
              (call ~info:{ arity = Full }
                 {
                   comment;
                   expression_desc =
                     (Fun
                        ([],
                          (block @
                             [{
                                J.statement_desc =
                                  (Return { return_value = e });
                                comment
                              }]), (Js_fun_env.empty 0)))
                 } [] : t)
          end
        module Stmt =
          struct
            type t = J.statement
            let return ?comment  e =
              ({ statement_desc = (Return { return_value = e }); comment } : 
              t)
            let return_unit ?comment  () =
              (return ?comment (Exp.unit ()) : t)
            let break ?comment  () =
              ({ comment; statement_desc = Break } : t)
            let mk ?comment  statement_desc =
              ({ statement_desc; comment } : t)
            let empty ?comment  () =
              ({ statement_desc = (Block []); comment } : t)
            let throw ?comment  v =
              ({ statement_desc = (J.Throw v); comment } : t)
            let rec block ?comment  (b : J.block) =
              (match b with
               | { statement_desc = Block bs }::[] -> block bs
               | b::[] -> b
               | [] -> empty ?comment ()
               | _ -> { statement_desc = (Block b); comment } : t)
            let rec exp ?comment  (e : Exp.t) =
              (match e.expression_desc with
               | Seq ({ expression_desc = Number _ },b)|Seq
                 (b,{ expression_desc = Number _ }) -> exp ?comment b
               | Number _ -> block []
               | _ -> { statement_desc = (Exp e); comment } : t)
            let declare_variable ?comment  ?ident_info  ~kind  (v : Ident.t)
              =
              (let property: J.property =
                 match (kind : Lambda.let_kind) with
                 | Alias |Strict |StrictOpt  -> Immutable
                 | Variable  -> Mutable in
               let ident_info: J.ident_info =
                 match ident_info with
                 | None  -> { used_stats = NA }
                 | Some x -> x in
               {
                 statement_desc =
                   (Variable
                      { ident = v; value = None; property; ident_info });
                 comment
               } : t)
            let define ?comment  ?ident_info  ~kind  (v : Ident.t) exp =
              (let property: J.property =
                 match (kind : Lambda.let_kind) with
                 | Alias |Strict |StrictOpt  -> Immutable
                 | Variable  -> Mutable in
               let ident_info: J.ident_info =
                 match ident_info with
                 | None  -> { used_stats = NA }
                 | Some x -> x in
               {
                 statement_desc =
                   (Variable
                      { ident = v; value = (Some exp); property; ident_info });
                 comment
               } : t)
            let int_switch ?comment  ?declaration  ?default 
              (e : J.expression) clauses =
              (match e.expression_desc with
               | Number (Int { i;_}) ->
                   let continuation =
                     match List.find
                             (fun (x : int J.case_clause)  -> x.case = i)
                             clauses
                     with
                     | case -> fst case.body
                     | exception Not_found  ->
                         (match default with
                          | Some x -> x
                          | None  -> assert false) in
                   (match (declaration, continuation) with
                    | (Some
                       (kind,did),{
                                    statement_desc = Exp
                                      {
                                        expression_desc = Bin
                                          (Eq
                                           ,{
                                              expression_desc = Var (Id id);_},e0);_};_}::[])
                        when Ident.same did id -> define ?comment ~kind id e0
                    | (Some (kind,did),_) ->
                        block ((declare_variable ?comment ~kind did) ::
                          continuation)
                    | (None ,_) -> block continuation)
               | _ ->
                   (match declaration with
                    | Some (kind,did) ->
                        block
                          [declare_variable ?comment ~kind did;
                          {
                            statement_desc =
                              (J.Int_switch (e, clauses, default));
                            comment
                          }]
                    | None  ->
                        {
                          statement_desc =
                            (J.Int_switch (e, clauses, default));
                          comment
                        }) : t)
            let string_switch ?comment  ?declaration  ?default 
              (e : J.expression) clauses =
              (match e.expression_desc with
               | Str (_,s) ->
                   let continuation =
                     match List.find
                             (fun (x : string J.case_clause)  -> x.case = s)
                             clauses
                     with
                     | case -> fst case.body
                     | exception Not_found  ->
                         (match default with
                          | Some x -> x
                          | None  -> assert false) in
                   (match (declaration, continuation) with
                    | (Some
                       (kind,did),{
                                    statement_desc = Exp
                                      {
                                        expression_desc = Bin
                                          (Eq
                                           ,{
                                              expression_desc = Var (Id id);_},e0);_};_}::[])
                        when Ident.same did id -> define ?comment ~kind id e0
                    | (Some (kind,did),_) ->
                        block @@ ((declare_variable ?comment ~kind did) ::
                          continuation)
                    | (None ,_) -> block continuation)
               | _ ->
                   (match declaration with
                    | Some (kind,did) ->
                        block
                          [declare_variable ?comment ~kind did;
                          {
                            statement_desc =
                              (String_switch (e, clauses, default));
                            comment
                          }]
                    | None  ->
                        {
                          statement_desc =
                            (String_switch (e, clauses, default));
                          comment
                        }) : t)
            let rec if_ ?comment  ?declaration  ?else_  (e : J.expression)
              (then_ : J.block) =
              (let declared = ref false in
               let rec aux ?comment  (e : J.expression) (then_ : J.block)
                 (else_ : J.block) acc =
                 match ((e.expression_desc), then_, (else_ : J.block)) with
                 | (_,{ statement_desc = Return { return_value = b;_};_}::[],
                    { statement_desc = Return { return_value = a;_};_}::[])
                     -> (return (Exp.econd e b a)) :: acc
                 | (_,{
                        statement_desc = Exp
                          {
                            expression_desc = Bin
                              (Eq
                               ,({ expression_desc = Var (Id id0);_} as l0),a0);_};_}::[],
                    {
                      statement_desc = Exp
                        {
                          expression_desc = Bin
                            (Eq ,{ expression_desc = Var (Id id1);_},b0);_};_}::[])
                     when Ident.same id0 id1 ->
                     (match declaration with
                      | Some (kind,did) when Ident.same did id0 ->
                          (declared := true;
                           (define ~kind id0 (Exp.econd e a0 b0))
                           ::
                           acc)
                      | _ -> (exp (Exp.assign l0 (Exp.econd e a0 b0))) :: acc)
                 | (_,_,{
                          statement_desc = Exp { expression_desc = Number _ };_}::[])
                     -> aux ?comment e then_ [] acc
                 | (_,{
                        statement_desc = Exp { expression_desc = Number _ };_}::[],_)
                     -> aux ?comment e [] else_ acc
                 | (_,{ statement_desc = Exp b;_}::[],{
                                                        statement_desc = Exp
                                                          a;_}::[])
                     -> (exp (Exp.econd e b a)) :: acc
                 | (_,[],[]) -> (exp e) :: acc
                 | (_,[],_) -> aux ?comment (Exp.not e) else_ [] acc
                 | (_,y::ys,x::xs) when
                     let open Js_analyzer in
                       (eq_statement x y) && (no_side_effect e)
                     -> aux ?comment e ys xs (y :: acc)
                 | (Number (Float 0.|Int { i = 0;_}),_,_) ->
                     (match else_ with
                      | [] -> acc
                      | _ -> (block else_) :: acc)
                 | (Number _,_,_)
                   |(Bin
                     (Ge
                      ,{
                         expression_desc =
                           (String_length _|Array_length _|Bytes_length _
                            |Function_length _);_},{
                                                     expression_desc = Number
                                                       (Int { i = 0;_})
                                                     }),_,_)
                     -> (block then_) :: acc
                 | ((Bin
                     (EqEqEq
                      ,{ expression_desc = Number (Int { i = 0;_});_},e)|Bin
                     (EqEqEq
                      ,e,{ expression_desc = Number (Int { i = 0;_});_})),_,else_)
                     -> aux ?comment e else_ then_ acc
                 | ((Bin
                     (Gt
                      ,({
                          expression_desc =
                            (String_length _|Array_length _|Bytes_length _
                             |Function_length _);_}
                          as e),{ expression_desc = Number (Int { i = 0;_}) })
                     |Int_of_boolean e),_,_) ->
                     aux ?comment e then_ else_ acc
                 | _ ->
                     {
                       statement_desc =
                         (If
                            (e, then_,
                              ((match else_ with | [] -> None | v -> Some v))));
                       comment
                     } :: acc in
               let if_block =
                 aux ?comment e then_
                   (match else_ with | None  -> [] | Some v -> v) [] in
               match ((!declared), declaration) with
               | (true ,_)|(_,None ) -> block (List.rev if_block)
               | (false ,Some (kind,did)) ->
                   block ((declare_variable ~kind did) ::
                     (List.rev if_block)) : t)
            let const_variable ?comment  ?exp  (v : Ident.t) =
              ({
                 statement_desc =
                   (Variable
                      {
                        ident = v;
                        value = exp;
                        property = Immutable;
                        ident_info = { used_stats = NA }
                      });
                 comment
               } : t)
            let assign ?comment  id e =
              ({
                 statement_desc = (J.Exp (Exp.bin Eq (Exp.var id) e));
                 comment
               } : t)
            let assign_unit ?comment  id =
              ({
                 statement_desc =
                   (J.Exp (Exp.bin Eq (Exp.var id) (Exp.float 0.)));
                 comment
               } : t)
            let declare_unit ?comment  id =
              ({
                 statement_desc =
                   (J.Variable
                      {
                        ident = id;
                        value = (Some (Exp.float 0.));
                        property = Mutable;
                        ident_info = { used_stats = NA }
                      });
                 comment
               } : t)
            let rec while_ ?comment  ?label  ?env  (e : Exp.t) (st : J.block)
              =
              (match e with
               | { expression_desc = Int_of_boolean e;_} ->
                   while_ ?comment ?label e st
               | _ ->
                   let env =
                     match env with
                     | None  -> Js_closure.empty ()
                     | Some x -> x in
                   { statement_desc = (While (label, e, st, env)); comment } : 
              t)
            let for_ ?comment  ?env  for_ident_expression
              finish_ident_expression id direction (b : J.block) =
              (let env =
                 match env with | None  -> Js_closure.empty () | Some x -> x in
               {
                 statement_desc =
                   (ForRange
                      (for_ident_expression, finish_ident_expression, id,
                        direction, b, env));
                 comment
               } : t)
            let try_ ?comment  ?with_  ?finally  body =
              ({ statement_desc = (Try (body, with_, finally)); comment } : 
              t)
            let unknown_lambda ?(comment= "unknown")  (lam : Lambda.lambda) =
              (exp @@
                 (Exp.str ~comment ~pure:false
                    (Lam_util.string_of_lambda lam)) : t)
            let continue ?comment  label =
              ({ statement_desc = (J.Continue label); comment } : t)
          end
      end 
    module Js_output :
      sig
        [@@@ocaml.text
          " The intemediate output when compiling lambda into JS IR "]
        type st = Lam_compile_defs.st
        type finished =
          | True
          | False
          | Dummy
        type t =
          {
          block: J.block;
          value: J.expression option;
          finished: finished;}
        val make : ?value:J.expression -> ?finished:finished -> J.block -> t
        val of_stmt :
          ?value:J.expression -> ?finished:finished -> J.statement -> t
        val of_block :
          ?value:J.expression -> ?finished:finished -> J.block -> t
        val to_block : t -> J.block
        val to_break_block : t -> (J.block* bool)
        module Ops : sig val (++) : t -> t -> t end
        val dummy : t
        val handle_name_tail :
          Lam_compile_defs.st ->
            Lam_compile_defs.return_type ->
              Lambda.lambda -> J.expression -> t
        val handle_block_return :
          Lam_compile_defs.st ->
            Lam_compile_defs.return_type ->
              Lambda.lambda -> J.block -> J.expression -> t
        val concat : t list -> t
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        type finished =
          | True
          | False
          | Dummy
        type t =
          {
          block: J.block;
          value: J.expression option;
          finished:
            finished[@ocaml.doc
                      " When [finished] is true the block is already terminated, value does not make sense\n        default is false, false is  an conservative approach \n     "];}
        type st = Lam_compile_defs.st
        let make ?value  ?(finished= False)  block =
          { block; value; finished }
        let of_stmt ?value  ?(finished= False)  stmt =
          { block = [stmt]; value; finished }
        let of_block ?value  ?(finished= False)  block =
          { block; value; finished }
        let dummy = { value = None; block = []; finished = Dummy }
        let handle_name_tail (name : st)
          (should_return : Lam_compile_defs.return_type) lam
          (exp : J.expression) =
          (match (name, should_return) with
           | (EffectCall ,False ) ->
               if Lam_util.no_side_effects lam
               then dummy
               else { block = []; value = (Some exp); finished = False }
           | (EffectCall ,True _) -> make [S.return exp] ~finished:True
           | (Declare (kind,n),False ) -> make [S.define ~kind n exp]
           | (Assign n,False ) -> make [S.assign n exp]
           | ((Declare _|Assign _),True _) ->
               make [S.unknown_lambda lam] ~finished:True
           | (NeedValue ,_) ->
               { block = []; value = (Some exp); finished = False } : 
          t)
        let handle_block_return (st : st)
          (should_return : Lam_compile_defs.return_type)
          (lam : Lambda.lambda) (block : J.block) exp =
          (match (st, should_return) with
           | (Declare (kind,n),False ) ->
               make (block @ [S.define ~kind n exp])
           | (Assign n,False ) -> make (block @ [S.assign n exp])
           | ((Declare _|Assign _),True _) ->
               make [S.unknown_lambda lam] ~finished:True
           | (EffectCall ,False ) -> make block ~value:exp
           | (EffectCall ,True _) ->
               make (block @ [S.return exp]) ~finished:True
           | (NeedValue ,_) -> make block ~value:exp : t)
        let statement_of_opt_expr (x : J.expression option) =
          (match x with
           | None  -> S.empty ()
           | Some x when J_helper.no_side_effect x -> S.empty ()
           | Some x -> S.exp x : J.statement)
        let rec unroll_block (block : J.block) =
          match block with
          | { statement_desc = Block block }::[] -> unroll_block block
          | _ -> block
        let to_block (x : t) =
          (match x with
           | { block; value = opt; finished } ->
               let block = unroll_block block in
               if finished = True
               then block
               else
                 (match opt with
                  | None  -> block
                  | Some x when J_helper.no_side_effect x -> block
                  | Some x -> block @ [S.exp x]) : J.block)
        let to_break_block (x : t) =
          (match x with
           | { finished = True ; block;_} -> ((unroll_block block), false)
           | { block; value = None ; finished } ->
               let block = unroll_block block in
               (block,
                 ((match finished with
                   | True  -> false
                   | False |Dummy  -> true)))
           | { block; value = opt;_} ->
               let block = unroll_block block in
               ((block @ [statement_of_opt_expr opt]), true) : (J.block*
                                                                 bool))
        let rec append (x : t) (y : t) =
          (match (x, y) with
           | ({ finished = True ;_},_) -> x
           | (_,{ block = []; value = None ; finished = Dummy  }) -> x
           | ({ block = []; value = None ;_},y) -> y
           | ({ block = []; value = Some _;_},{ block = []; value = None ;_})
               -> x
           | ({ block = []; value = Some e1;_},({ block = [];
                                                  value = Some e2; finished }
                                                  as z))
               ->
               if J_helper.no_side_effect e1
               then z
               else { block = []; value = (Some (E.seq e1 e2)); finished }
           | ({ block = block1; value = opt_e1;_},{ block = block2;
                                                    value = opt_e2; finished
                                                    })
               ->
               let block1 = unroll_block block1 in
               make
                 (block1 @ ((statement_of_opt_expr opt_e1) ::
                    (unroll_block block2))) ?value:opt_e2 ~finished : 
          t)
        module Ops = struct let (++) (x : t) (y : t) = (append x y : t) end
        let concat (xs : t list) =
          (List.fold_right (fun x  -> fun acc  -> append x acc) xs dummy : 
          t)
      end 
    module Js_cmj_format :
      sig
        [@@@ocaml.text
          " Define intemediate format to be serialized for cross module optimization\n "]
        [@@@ocaml.text
          " In this module, \n    currently only arity information is  exported, \n\n    Short term: constant literals are also exported \n\n    Long term:\n    Benefit? since Google Closure Compiler already did such huge amount of work\n    TODO: simple expression, literal small function  can be stored, \n    but what would happen if small function captures other environment\n    for example \n\n    {[\n      let f  = fun x -> g x \n    ]}\n\n    {[\n      let f = g \n    ]}\n"]
        type cmj_value =
          {
          arity: Lam_stats.function_arities;
          closed_lambda: Lambda.lambda option;}
        type effect = string option
        type cmj_table = {
          values: cmj_value String_map.t;
          pure: effect;}
        val dummy : ?pure:string option -> unit -> cmj_table
      end =
      struct
        type cmj_value =
          {
          arity: Lam_stats.function_arities;
          closed_lambda:
            Lambda.lambda option[@ocaml.doc
                                  " Either constant or closed functor "];}
        type effect = string option
        type cmj_table = {
          values: cmj_value String_map.t;
          pure: effect;}
        let dummy ?(pure= Some "dummy")  () =
          { values = String_map.empty; pure }
      end 
    module Ext_marshal :
      sig
        [@@@ocaml.text
          " Extension to the standard library [Marshall] module \n "]
        val to_file : string -> 'a -> unit
        val from_file : string -> 'a
      end =
      struct
        let to_file filename v =
          let chan = open_out_bin filename in
          Marshal.to_channel chan v []; close_out chan
        let from_file filename =
          let chan = open_in_bin filename in
          let v = Marshal.from_channel chan in close_in chan; v[@@ocaml.doc
                                                                 " [bin] mode for WIN support "]
      end 
    module Config_util :
      sig
        [@@@ocaml.text
          " A simple wrapper around [Config] module in compiler-libs, so that the search path\n    is the same\n"]
        val find : string -> string[@@ocaml.doc
                                     " [find filename] Input is a file name, output is absolute path "]
      end =
      struct let find x = Misc.find_in_path_uncap (!Config.load_path) x end 
    module Lam_compile_env :
      sig
        [@@@ocaml.text
          " Helper for global Ocaml module index into meaningful names  "]
        type primitive_description =
          Types.type_expr option Primitive.description
        type key =
          | GetGlobal of Ident.t* int* Env.t
          | QueryGlobal of Ident.t* Env.t*
          bool[@ocaml.doc
                " the boolean is expand or not\n      when it's passed as module, it should be expanded, \n      otherwise for alias, [include Array], it's okay to return an identifier\n      TODO: be more clear about its concept\n  "]
          | CamlRuntimePrimitive of primitive_description* J.expression list
        type ident_info =
          {
          id: Ident.t;
          name: string;
          signatures: Types.signature;
          arity: Lam_stats.function_arities;
          closed_lambda: Lambda.lambda option;}
        type module_info = {
          signature: Types.signature;
          pure: bool;}
        val find_and_add_if_not_exist :
          (Ident.t* int) ->
            Env.t ->
              not_found:(Ident.t -> 'a) -> found:(ident_info -> 'a) -> 'a
        val query_and_add_if_not_exist :
          Lam_module_ident.t ->
            Env.t ->
              not_found:(unit -> 'a) -> found:(module_info -> 'a) -> 'a
        val add_js_module : ?id:Ident.t -> string -> Ident.t[@@ocaml.doc
                                                              " add third party dependency "]
        val reset : unit -> unit
        val is_pure : Lam_module_ident.t -> Env.t -> bool
        val get_requried_modules :
          Env.t ->
            Lam_module_ident.t list ->
              Lam_module_ident.t Hash_set.hashset -> Lam_module_ident.t list
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        type module_id = Lam_module_ident.t
        type ml_module_info =
          {
          signatures: Types.signature;
          cmj_table: Js_cmj_format.cmj_table;}
        type env_value =
          | Visit of ml_module_info
          | Runtime of
          bool[@ocaml.doc
                " A built in module probably from our runtime primitives, \n                         so it does not have any [signature]\n                      "]
          |
          External[@ocaml.doc
                    " Also a js file, but this belong to third party \n                      "]
        type module_info = {
          signature: Types.signature;
          pure: bool;}
        type primitive_description =
          Types.type_expr option Primitive.description
        type key =
          | GetGlobal of Ident.t* int* Env.t
          | QueryGlobal of Ident.t* Env.t*
          bool[@ocaml.doc
                " we need register which global variable is an dependency "]
          | CamlRuntimePrimitive of primitive_description* J.expression list
        type ident_info =
          {
          id: Ident.t;
          name: string;
          signatures: Types.signature;
          arity: Lam_stats.function_arities;
          closed_lambda: Lambda.lambda option;}
        open Js_output.Ops
        let cached_tbl: (module_id,env_value) Hashtbl.t = Hashtbl.create 31
        let reset () = Hashtbl.clear cached_tbl
        let add_js_module ?id  module_name =
          let id =
            match id with
            | None  -> Ext_ident.create_js_module module_name
            | Some id -> id in
          Hashtbl.replace cached_tbl
            (Lam_module_ident.of_external id module_name) External;
          id
        let find_cached_tbl = Hashtbl.find cached_tbl
        let add_cached_tbl = Hashtbl.add cached_tbl
        let find_and_add_if_not_exist (id,pos) env ~not_found  ~found  =
          let oid = Lam_module_ident.of_ml id in
          match find_cached_tbl oid with
          | exception Not_found  ->
              let cmj_table =
                let file = id.name ^ ".cmj" in
                match Misc.find_in_path_uncap (!Config.load_path) file with
                | exception Not_found  ->
                    (Ext_log.warn __LOC__ "@[%s not found @]@." file;
                     Js_cmj_format.dummy ())
                | f -> Ext_marshal.from_file f in
              (match Type_util.find_serializable_signatures_by_path
                       (Pident id) env
               with
               | None  -> not_found id
               | Some signature ->
                   (add_cached_tbl oid
                      (Visit { signatures = signature; cmj_table });
                    (let name = Type_util.get_name signature pos in
                     let (arity,closed_lambda) =
                       match String_map.find name cmj_table.values with
                       | exception Not_found  -> (NA, None)
                       | { arity; closed_lambda } -> (arity, closed_lambda) in
                     found
                       {
                         id;
                         name;
                         signatures = signature;
                         arity;
                         closed_lambda
                       })))
          | Visit { signatures = serializable_sigs; cmj_table = { values;_} }
              ->
              let name = Type_util.get_name serializable_sigs pos in
              let (arity,closed_lambda) =
                match String_map.find name values with
                | exception Not_found  -> (NA, None)
                | { arity; closed_lambda;_} -> (arity, closed_lambda) in
              found
                {
                  id;
                  name;
                  signatures = serializable_sigs;
                  arity;
                  closed_lambda
                }
          | Runtime _ -> assert false
          | External  -> assert false
        let query_and_add_if_not_exist (oid : Lam_module_ident.t) env
          ~not_found  ~found  =
          match find_cached_tbl oid with
          | exception Not_found  ->
              (match oid.kind with
               | Runtime  ->
                   (add_cached_tbl oid (Runtime true);
                    found { signature = []; pure = true })
               | External _ ->
                   (add_cached_tbl oid External;
                    found { signature = []; pure = false })
               | Ml  ->
                   let cmj_table =
                     let file = (Lam_module_ident.name oid) ^ ".cmj" in
                     match Config_util.find file with
                     | exception Not_found  ->
                         (Ext_log.warn __LOC__ "@[%s not found@]@." file;
                          Js_cmj_format.dummy ())
                     | f -> Ext_marshal.from_file f in
                   (match Type_util.find_serializable_signatures_by_path
                            (Pident (oid.id)) env
                    with
                    | None  -> not_found ()
                    | Some signature ->
                        (add_cached_tbl oid
                           (Visit { signatures = signature; cmj_table });
                         found { signature; pure = (cmj_table.pure = None) })))
          | Visit { signatures; cmj_table = { pure;_};_} ->
              found { signature = signatures; pure = (pure = None) }
          | Runtime pure -> found { signature = []; pure }
          | External  -> found { signature = []; pure = false }
        let is_pure id env =
          query_and_add_if_not_exist id env ~not_found:(fun _  -> false)
            ~found:(fun x  -> x.pure)
        let get_requried_modules env (extras : module_id list)
          (hard_dependencies : _ Hash_set.hashset) =
          (let mem (x : Lam_module_ident.t) =
             (not (is_pure x env)) || (Hash_set.mem hard_dependencies x) in
           Hashtbl.iter
             (fun (id : module_id)  ->
                fun _  -> if mem id then Hash_set.add hard_dependencies id)
             cached_tbl;
           List.iter
             (fun id  -> if mem id then Hash_set.add hard_dependencies id)
             extras;
           Hash_set.elements hard_dependencies : module_id list)
      end 
    module Js_of_lam_tuple :
      sig
        [@@@ocaml.text " Utilities for compiling lambda tuple into JS IR "]
        val make : J.expression list -> J.expression
      end =
      struct
        module E = J_helper.Exp
        let make (args : J.expression list) =
          E.arr Immutable ((E.int 0) :: args)
      end 
    module Js_of_lam_array :
      sig
        [@@@ocaml.text " Utilities for creating Array of JS IR "]
        val make_array :
          J.mutable_flag ->
            Lambda.array_kind -> J.expression list -> J.expression[@@ocaml.doc
                                                                    " create an array "]
        val set_array :
          J.expression -> J.expression -> J.expression -> J.expression
        [@@ocaml.doc
          " Here we don't care about [array_kind],  \n    In the future, we might used TypedArray for FloatArray\n "]
        val ref_array : J.expression -> J.expression -> J.expression
      end =
      struct
        module E = J_helper.Exp
        let make_array mt (kind : Lambda.array_kind) args =
          match kind with
          | Pgenarray |Paddrarray |Pintarray |Pfloatarray  ->
              E.arr ~comment:"array" mt args
        let set_array e e0 e1 = E.assign (E.access e e0) e1
        let ref_array e e0 = E.access e e0
      end 
    module Lam_dispatch_primitive :
      sig
        [@@@ocaml.text
          " Compile lambda primitives (note this is different external c calls) "]
        val query :
          Lam_compile_env.primitive_description ->
            J.expression list -> J.expression[@@ocaml.doc
                                               " \n    @return None when the primitives are not handled in  pre-processing\n "]
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        let query (prim : Lam_compile_env.primitive_description)
          (args : J.expression list) =
          (let module X = struct exception NA end in
             try
               let v =
                 match prim.prim_name with
                 | "caml_gc_stat"|"caml_gc_quick_stat" ->
                     E.arr NA ~comment:(prim.prim_name)
                       [E.int ~comment:"stat-record" 0;
                       E.float ~comment:"minor_words" 0.;
                       E.float ~comment:"promoted_words" 0.;
                       E.float ~comment:"major_words" 0.;
                       E.int ~comment:"minor_collections" 0;
                       E.int ~comment:"major_collections" 0;
                       E.int ~comment:"heap_words" 0;
                       E.int ~comment:"heap_chunks" 0;
                       E.int ~comment:"live_words" 0;
                       E.int ~comment:"live_blocks" 0;
                       E.int ~comment:"free_words" 0;
                       E.int ~comment:"free_blocks" 0;
                       E.int ~comment:"larget_blocks" 0;
                       E.int ~comment:"fragments" 0;
                       E.int ~comment:"compactions" 0;
                       E.int ~comment:"top_heap_words" 0;
                       E.int ~comment:"stack_size" 0]
                 | "caml_abs_float" -> E.math "abs" args
                 | "caml_acos_float" -> E.math "acos" args
                 | "caml_add_float" ->
                     (match args with
                      | e0::e1::[] -> E.float_plus e0 e1
                      | _ -> assert false)
                 | "caml_div_float" ->
                     (match args with
                      | e0::e1::[] -> E.bin Div e0 e1
                      | _ -> assert false)
                 | "caml_sub_float" ->
                     (match args with
                      | e0::e1::[] -> E.float_minus e0 e1
                      | _ -> assert false)
                 | "caml_eq_float" ->
                     (match args with
                      | e0::e1::[] -> E.triple_equal e0 e1
                      | _ -> assert false)
                 | "caml_ge_float" ->
                     (match args with
                      | e0::e1::[] -> E.ge e0 e1
                      | _ -> assert false)
                 | "caml_gt_float" ->
                     (match args with
                      | e0::e1::[] -> E.gt e0 e1
                      | _ -> assert false)
                 | "caml_tan_float" -> E.math "tan" args
                 | "caml_tanh_float" -> E.math "tanh" args
                 | "caml_asin_float" -> E.math "asin" args
                 | "caml_atan2_float" -> E.math "atan2" args
                 | "caml_atan_float" -> E.math "atan" args
                 | "caml_ceil_float" -> E.math "ceil" args
                 | "caml_cos_float" -> E.math "cos" args
                 | "caml_cosh_float" -> E.math "cosh" args
                 | "caml_exp_float" -> E.math "exp" args
                 | "caml_sin_float" -> E.math "sin" args
                 | "caml_sinh_float" -> E.math "sinh" args
                 | "caml_sqrt_float" -> E.math "sqrt" args
                 | "caml_float_of_int" ->
                     (match args with | e::[] -> e | _ -> assert false)
                 | "caml_floor_float" -> E.math "floor" args
                 | "caml_log_float" -> E.math "log" args
                 | "caml_log10_float" -> E.math "log10" args
                 | "caml_log1p_float" -> E.math "log1p" args
                 | "caml_power_float" -> E.math "pow" args
                 | "caml_make_float_vect" ->
                     E.new_ (E.js_global "Array") args
                 | "caml_array_append" ->
                     (match args with
                      | e0::e1::[] -> E.array_append e0 [e1]
                      | _ -> assert false)
                 | "caml_array_get"|"caml_array_get_addr"
                   |"caml_array_get_float"|"caml_array_unsafe_get"
                   |"caml_array_unsafe_get_float" ->
                     (match args with
                      | e0::e1::[] -> Js_of_lam_array.ref_array e0 e1
                      | _ -> assert false)
                 | "caml_array_set"|"caml_array_set_addr"
                   |"caml_array_set_float"|"caml_array_unsafe_set"
                   |"caml_array_unsafe_set_addr"
                   |"caml_array_unsafe_set_float" ->
                     (match args with
                      | e0::e1::e2::[] -> Js_of_lam_array.set_array e0 e1 e2
                      | _ -> assert false)
                 | "caml_int32_add"|"caml_nativeint_add" ->
                     (match args with
                      | e0::e1::[] -> E.int_plus e0 e1
                      | _ -> assert false)
                 | "caml_int32_div"|"caml_nativeint_div" ->
                     (match args with
                      | e0::e1::[] -> E.bin Bor (E.bin Div e0 e1) (E.int 0)
                      | _ -> assert false)
                 | "caml_int32_mul"|"caml_nativeint_mul" ->
                     (match args with
                      | e0::e1::[] -> E.bin Mul e0 e1
                      | _ -> assert false)
                 | "caml_int32_of_int"|"caml_nativeint_of_int"
                   |"caml_nativeint_of_int32" ->
                     (match args with | e::[] -> e | _ -> assert false)
                 | "caml_int32_of_float"|"caml_int_of_float"
                   |"caml_nativeint_of_float" ->
                     (match args with
                      | e::[] -> E.bin Bor e (E.int 0)
                      | _ -> assert false)
                 | "caml_int32_to_float"|"caml_int32_to_int"
                   |"caml_nativeint_to_int"|"caml_nativeint_to_float"
                   |"caml_nativeint_to_int32" ->
                     (match args with | e::[] -> e | _ -> assert false)
                 | "caml_int32_sub"|"caml_nativeint_sub" ->
                     (match args with
                      | e0::e1::[] -> E.int_minus e0 e1
                      | _ -> assert false)
                 | "caml_int32_xor"|"caml_nativeint_xor" ->
                     (match args with
                      | e0::e1::[] -> E.bin Bxor e0 e1
                      | _ -> assert false)
                 | "caml_int32_and"|"caml_nativeint_and" ->
                     (match args with
                      | e0::e1::[] -> E.bin Band e0 e1
                      | _ -> assert false)
                 | "caml_int32_or"|"caml_nativeint_or" ->
                     (match args with
                      | e0::e1::[] -> E.bin Bor e0 e1
                      | _ -> assert false)
                 | "caml_le_float" ->
                     (match args with
                      | e0::e1::[] -> E.le e0 e1
                      | _ -> assert false)
                 | "caml_lt_float" ->
                     (match args with
                      | e0::e1::[] -> E.lt e0 e1
                      | _ -> assert false)
                 | "caml_neg_float" ->
                     (match args with
                      | e::[] -> E.int_minus (E.int 0) e
                      | _ -> assert false)
                 | "caml_neq_float" ->
                     (match args with
                      | e0::e1::[] -> E.bin NotEqEq e0 e1
                      | _ -> assert false)
                 | "caml_mul_float" ->
                     (match args with
                      | e0::e1::[] -> E.bin Mul e0 e1
                      | _ -> assert false)
                 | "caml_int64_bits_of_float"|"caml_int64_float_of_bits"
                   |"caml_classify_float"|"caml_modf_float"
                   |"caml_ldexp_float"|"caml_frexp_float"
                   |"caml_float_compare"|"caml_copysign_float"
                   |"caml_expm1_float"|"caml_hypot_float" ->
                     E.runtime_call J_helper.float prim.prim_name args
                 | "caml_string_equal" ->
                     (match args with
                      | e0::e1::[] -> E.triple_equal e0 e1
                      | _ -> assert false)
                 | "caml_string_notequal" ->
                     (match args with
                      | e0::e1::[] -> E.stringcomp NotEqEq e0 e1
                      | _ -> assert false)
                 | "caml_string_lessequal" ->
                     (match args with
                      | e0::e1::[] -> E.stringcomp Le e0 e1
                      | _ -> assert false)
                 | "caml_string_lessthan" ->
                     (match args with
                      | e0::e1::[] -> E.stringcomp Lt e0 e1
                      | _ -> assert false)
                 | "caml_string_greaterequal" ->
                     (match args with
                      | e0::e1::[] -> E.stringcomp Ge e0 e1
                      | _ -> assert false)
                 | "caml_string_greaterthan" ->
                     (match args with
                      | e0::e1::[] -> E.stringcomp Gt e0 e1
                      | _ -> assert false)
                 | "caml_create_string" ->
                     (match args with
                      | ({ expression_desc = Number (Int { i;_});_} as v)::[]
                          when i >= 0 -> E.uninitialized_array v
                      | _ ->
                          E.runtime_call J_helper.string prim.prim_name args)
                 | "caml_string_get"|"caml_string_compare"|"string_of_bytes"
                   |"bytes_of_string"|"caml_is_printable"
                   |"caml_string_of_char_array"|"caml_fill_string"
                   |"caml_blit_string"|"caml_blit_bytes" ->
                     E.runtime_call J_helper.string prim.prim_name args
                 | "caml_register_named_value" -> E.unit ()
                 | "caml_gc_compaction"|"caml_gc_full_major"|"caml_gc_major"
                   |"caml_gc_major_slice"|"caml_gc_minor"|"caml_gc_set"
                   |"caml_final_register"|"caml_final_release"
                   |"caml_backtrace_status"|"caml_get_exception_backtrace"
                   |"caml_get_exception_raw_backtrace"
                   |"caml_record_backtrace"|"caml_convert_raw_backtrace"
                   |"caml_get_current_callstack" -> E.unit ()
                 | "caml_gc_counters" ->
                     E.arr NA [E.int 0; E.float 0.; E.float 0.; E.float 0.]
                 | "caml_gc_get" ->
                     E.arr NA
                       [E.int 0;
                       E.int ~comment:"minor_heap_size" 0;
                       E.int ~comment:"major_heap_increment" 0;
                       E.int ~comment:"space_overhead" 0;
                       E.int ~comment:"verbose" 0;
                       E.int ~comment:"max_overhead" 0;
                       E.int ~comment:"stack_limit" 0;
                       E.int ~comment:"allocation_policy" 0]
                 | "caml_set_oo_id" ->
                     (match args with
                      | ({
                           expression_desc = Array
                             (tag::str::{
                                          expression_desc = J.Number (Int
                                            { i = 0;_});_}::[],flag);_}
                           as v)::[]
                          ->
                          {
                            v with
                            expression_desc =
                              (J.Array
                                 ([tag;
                                  str;
                                  E.prefix_inc
                                    (E.runtime_var_vid J_helper.exceptions
                                       "caml_oo_last_id")], flag))
                          }
                      | _ ->
                          E.runtime_call J_helper.exceptions prim.prim_name
                            args)
                 | "caml_sys_const_big_endian" -> E.bool Sys.big_endian
                 | "caml_sys_const_word_size" -> E.int Sys.word_size
                 | "caml_sys_const_ostype_cygwin" -> E.false_
                 | "caml_sys_const_ostype_win32" -> E.false_
                 | "caml_sys_const_ostype_unix" -> E.true_
                 | "caml_is_js" -> E.true_
                 | "caml_sys_get_config" ->
                     Js_of_lam_tuple.make
                       [E.str Sys.os_type;
                       E.int Sys.word_size;
                       E.bool Sys.big_endian]
                 | "caml_sys_get_argv" ->
                     Js_of_lam_tuple.make [E.str "cmd"; E.arr NA []]
                 | "caml_sys_time"|"caml_sys_random_seed"|"caml_sys_getenv"
                   |"caml_sys_system_command" ->
                     E.runtime_call J_helper.sys prim.prim_name args
                 | "caml_lex_engine"|"caml_new_lex_engine"
                   |"caml_parse_engine"|"caml_set_parser_trace" ->
                     E.runtime_call J_helper.lex_parse prim.prim_name args
                 | "caml_array_sub"|"caml_array_concat"|"caml_array_blit"
                   |"caml_make_vect" ->
                     E.runtime_call J_helper.array prim.prim_name args
                 | "caml_ml_open_descriptor_in"|"caml_ml_open_descriptor_out"
                   |"caml_ml_output_char"|"caml_ml_output"
                   |"caml_ml_input_char" ->
                     E.runtime_call J_helper.io prim.prim_name args
                 | "caml_obj_dup" ->
                     (match args with
                      | a::[] when J_helper.is_constant a -> a
                      | _ ->
                          E.runtime_call J_helper.obj_runtime prim.prim_name
                            args)
                 | "caml_obj_block" ->
                     (match args with
                      | { expression_desc = Number (Int { i = tag;_});_}::
                          { expression_desc = Number (Int { i = 0;_});_}::[]
                          -> E.arr Immutable [E.int tag]
                      | _ ->
                          E.runtime_call J_helper.obj_runtime prim.prim_name
                            args)
                 | "caml_obj_is_block"|"caml_obj_tag"|"caml_obj_set_tag"
                   |"caml_obj_truncate"|"caml_lazy_make_forward" ->
                     E.runtime_call J_helper.obj_runtime prim.prim_name args
                 | "caml_format_float"|"caml_format_int"
                   |"caml_nativeint_format"|"caml_int32_format"
                   |"caml_float_of_string"|"caml_int_of_string"
                   |"caml_int32_of_string"|"caml_nativeint_of_string" ->
                     E.runtime_call J_helper.format prim.prim_name args
                 | "caml_update_dummy"|"caml_compare"|"caml_int_compare"
                   |"caml_int32_compare"|"caml_nativeint_compare"
                   |"caml_equal"|"caml_notequal"|"caml_greaterequal"
                   |"caml_greaterthan"|"caml_lessequal"|"caml_lessthan"
                   |"caml_convert_raw_backtrace_slot"|"caml_bswap16"
                   |"caml_int32_bswap"|"caml_nativeint_bswap"
                   |"caml_int64_bswap" ->
                     E.runtime_call J_helper.prim prim.prim_name args
                 | "caml_get_public_method" ->
                     E.runtime_call J_helper.oo prim.prim_name args
                 | "caml_install_signal_handler"
                   |"caml_output_value_to_buffer"|"caml_marshal_data_size"
                   |"caml_input_value_from_string"|"caml_output_value"
                   |"caml_input_value"|"caml_output_value_to_string"
                   |"caml_int64_format"|"caml_int64_compare"
                   |"caml_md5_string"|"caml_md5_chan"|"caml_hash"
                   |"caml_hash_univ_param"|"caml_weak_set"|"caml_weak_create"
                   |"caml_weak_get"|"caml_weak_check"|"caml_weak_blit"
                   |"caml_weak_get_copy"|"caml_sys_close"
                   |"caml_int64_of_string"|"caml_sys_open"|"caml_ml_flush"
                   |"caml_ml_input"|"caml_ml_input_scan_line"
                   |"caml_ml_input_int"|"caml_ml_close_channel"
                   |"caml_ml_output_int"|"caml_sys_exit"
                   |"caml_ml_out_channels_list"|"caml_ml_channel_size_64"
                   |"caml_ml_channel_size"|"caml_ml_pos_in_64"
                   |"caml_ml_pos_in"|"caml_ml_seek_in"|"caml_ml_seek_in_64"
                   |"caml_ml_pos_out"|"caml_ml_pos_out_64"|"caml_ml_seek_out"
                   |"caml_ml_seek_out_64"|"caml_ml_set_binary_mode" ->
                     E.runtime_call J_helper.prim prim.prim_name args
                 | "js_function_length" ->
                     (match args with
                      | f::[] -> E.function_length f
                      | _ -> assert false)
                 | "js_create_array" ->
                     (match args with
                      | e::[] -> E.uninitialized_array e
                      | _ -> assert false)
                 | "js_array_append" ->
                     (match args with
                      | a::b::[] -> E.array_append a [b]
                      | _ -> assert false)
                 | "js_string_append" ->
                     (match args with
                      | a::b::[] -> E.string_append a b
                      | _ -> assert false)
                 | "js_apply" ->
                     (match args with
                      | f::args::[] -> E.flat_call f args
                      | _ -> assert false)
                 | "js_string_of_small_int_array" ->
                     (match args with
                      | e::[] -> E.string_of_small_int_array e
                      | _ -> assert false)
                 | "js_apply1"|"js_apply2"|"js_apply3"|"js_apply4"
                   |"js_apply5"|"js_apply6"|"js_apply7"|"js_apply8" ->
                     (match args with
                      | fn::rest -> E.call ~info:{ arity = Full } fn rest
                      | _ -> assert false)
                 | _ ->
                     E.str ~comment:"Missing primitve" ~pure:false
                       prim.prim_name in
               v
             with | X.NA  -> E.runtime_call J_helper.prim prim.prim_name args : 
          J.expression)[@@ocaml.doc
                         " \nThere are two things we need consider:\n1.  For some primitives we can replace caml-primitive with js primitives directly\n2.  For some standard library functions, we prefer to replace with javascript primitives\n    For example [Pervasives[\"^\"] -> ^]\n    We can collect all mli files in OCaml and replace it with an efficient javascript runtime\n"]
      end 
    module Lam_compile_global :
      sig
        [@@@ocaml.text
          " Compile ocaml external module call , e.g [List.length] to  JS IR "]
        val get_exp : Lam_compile_env.key -> J.expression
        val get_exp_with_args :
          Ident.t -> int -> Env.t -> J.expression list -> J.expression
        val query_lambda : Ident.t -> Env.t -> Lambda.lambda
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        open Js_output.Ops
        let query_lambda id env =
          Lam_compile_env.query_and_add_if_not_exist
            (Lam_module_ident.of_ml id) env
            ~not_found:(fun id  -> assert false)
            ~found:(fun { signature = sigs;_}  ->
                      Lambda.Lprim
                        ((Pmakeblock (0, NA, Immutable)),
                          ((List.mapi
                              (fun i  ->
                                 fun _  ->
                                   Lambda.Lprim
                                     ((Pfield i),
                                       [Lprim ((Pgetglobal id), [])]))) sigs)))
        let get_exp (key : Lam_compile_env.key) =
          (match key with
           | GetGlobal ((id : Ident.t),(pos : int),env) ->
               Lam_compile_env.find_and_add_if_not_exist (id, pos) env
                 ~not_found:(fun id  ->
                               E.str ~pure:false
                                 (Printf.sprintf "Err %s %d %d" id.name
                                    id.flags pos))
                 ~found:(fun { id; name;_}  ->
                           match (id, name) with
                           | ({ name = "Sys";_},"os_type") ->
                               E.str Sys.os_type
                           | _ -> E.ml_var_dot id name)
           | QueryGlobal (id,env,expand) ->
               if Ident.is_predef_exn id
               then E.runtime_ref J_helper.exceptions id.name
               else
                 Lam_compile_env.query_and_add_if_not_exist
                   (Lam_module_ident.of_ml id) env
                   ~not_found:(fun id  -> assert false)
                   ~found:(fun { signature = sigs;_}  ->
                             if expand
                             then
                               let len = List.length sigs in
                               E.arr Immutable ((E.int ~comment:(id.name) 0)
                                 ::
                                 (Ext_list.init len
                                    (fun i  ->
                                       E.ml_var_dot id
                                         (Type_util.get_name sigs i))))
                             else E.ml_var id)
           | CamlRuntimePrimitive (prim,args) ->
               Lam_dispatch_primitive.query prim args : J.expression)
        let get_exp_with_args (id : Ident.t) (pos : int) env
          (args : J.expression list) =
          (Lam_compile_env.find_and_add_if_not_exist (id, pos) env
             ~not_found:(fun id  ->
                           E.str ~pure:false
                             (Printf.sprintf "Err %s %d %d" id.name id.flags
                                pos))
             ~found:(fun { id; name; arity;_}  ->
                       match (id, name, args) with
                       | ({ name = "Pervasives";_},"^",e0::e1::[]) ->
                           E.string_append e0 e1
                       | ({ name = "Pervasives";_},"print_endline",(_::[] as
                                                                    args))
                           -> E.seq (E.dump Log args) (E.unit ())
                       | ({ name = "Pervasives";_},"prerr_endline",(_::[] as
                                                                    args))
                           -> E.seq (E.dump Error args) (E.unit ())
                       | _ ->
                           let rec aux (acc : J.expression)
                             (arity : Lam_stats.function_arities) args
                             (len : int) =
                             match (arity, len) with
                             | (_,0) -> acc
                             | (Determin (a,(x,_)::rest,b),len) ->
                                 let x = if x = 0 then 1 else x in
                                 if len >= x
                                 then
                                   let (first_part,continue) =
                                     Ext_list.take x args in
                                   aux
                                     (E.call ~info:{ arity = Full } acc
                                        first_part) (Determin (a, rest, b))
                                     continue (len - x)
                                 else acc
                             | (Determin (a,[],b),_) -> E.call acc args
                             | (NA ,_) -> E.call acc args in
                           aux (E.ml_var_dot id name) arity args
                             (List.length args)) : J.expression)
      end 
    module Parsetree_util :
      sig
        val is_single_string : Parsetree.payload -> string option
        val is_string_or_strings :
          Parsetree.payload ->
            [ `None  | `Single of string  | `Some of string list ]
      end =
      struct
        let is_single_string (x : Parsetree.payload) =
          match x with
          | Parsetree.PStr
              ({
                 pstr_desc = Pstr_eval
                   ({ pexp_desc = Pexp_constant (Const_string (name,_));_},_);_}::[])
              -> Some name
          | _ -> None
        let is_string_or_strings (x : Parsetree.payload) =
          (let module M = struct exception Not_str end in
             match x with
             | PStr
                 ({
                    pstr_desc = Pstr_eval
                      ({
                         pexp_desc = Pexp_apply
                           ({
                              pexp_desc = Pexp_constant (Const_string
                                (name,_));_},args);_},_);_}::[])
                 ->
                 (try
                    `Some (name ::
                      (args |>
                         (List.map
                            (fun (_label,e)  ->
                               match (e : Parsetree.expression) with
                               | {
                                   pexp_desc = Pexp_constant (Const_string
                                     (name,_));_}
                                   -> name
                               | _ -> raise M.Not_str))))
                  with | M.Not_str  -> `None)
             | Parsetree.PStr
                 ({
                    pstr_desc = Pstr_eval
                      ({ pexp_desc = Pexp_constant (Const_string (name,_));_},_);_}::[])
                 -> `Single name
             | _ -> `None : [ `None  | `Single of string 
                            | `Some of string list ])
      end 
    module Lam_compile_external_call :
      sig
        [@@@ocaml.text " Compile ocaml external function call to JS IR. "]
        [@@@ocaml.text
          " \n    This module define how the FFI (via `external`) works with attributes. \n    Note it will route to {!Lam_compile_global} \n    for compiling normal functions without attributes.\n "]
        [@@@ocaml.text
          " TODO: document supported attributes\n    Attributes starting with `js` are reserved\n    examples: \"js.splice\"\n "]
        val translate :
          Lam_compile_defs.cxt ->
            Types.type_expr option Primitive.description ->
              J.expression list -> J.expression
      end =
      struct
        module E = J_helper.Exp
        open Parsetree_util
        type external_module_name =
          | Single of string
          | Bind of string* string
        type 'a external_module =
          {
          txt: 'a;
          external_module_name: external_module_name option;}
        let handle_external module_name =
          match module_name with
          | Some module_name ->
              let id =
                match module_name with
                | Single module_name ->
                    ((Lam_compile_env.add_js_module module_name),
                      module_name)
                | Bind (module_name,name) ->
                    ((Lam_compile_env.add_js_module
                        ~id:(Ext_ident.create_js_module name) module_name),
                      module_name) in
              Some id
          | None  -> None
        type js_call = {
          splice: bool;
          qualifiers: string list;
          name: string;}
        type js_send = {
          splice: bool;
          name: string;}
        type js_global =
          {
          name: string;
          external_module_name: external_module_name option;}
        type js_new = {
          name: string;}
        type ffi =
          | Obj_create
          | Js_global of js_global
          | Js_call of js_call external_module
          | Js_send of js_send
          | Js_new of js_new external_module
          | Normal
        let handle_attributes (prim_attributes : Parsetree.attributes) =
          (let qualifiers = ref [] in
           let call_name = ref None in
           let external_module_name = ref None in
           let is_obj = ref false in
           let js_global = ref `None in
           let js_send = ref `None in
           let js_splice = ref false in
           let start_loc: Location.t option ref = ref None in
           let finish_loc = ref None in
           let js_new = ref None in
           let () =
             prim_attributes |>
               (List.iter
                  (fun
                     (((x : string Asttypes.loc),pay_load) :
                       Parsetree.attribute)
                      ->
                     if (!start_loc) = None then start_loc := (Some (x.loc));
                     finish_loc := (Some (x.loc));
                     (match x.txt with
                      | "js.global" ->
                          (match is_single_string pay_load with
                           | Some name -> js_global := (`Value name)
                           | None  -> ())
                      | "js.splice" -> js_splice := true
                      | "js.send" ->
                          (match is_single_string pay_load with
                           | Some name -> js_send := (`Value name)
                           | None  -> ())
                      | "js.call" ->
                          (match is_single_string pay_load with
                           | Some name -> call_name := (Some ((x.loc), name))
                           | None  -> ())
                      | "js.module" ->
                          (match is_string_or_strings pay_load with
                           | `Single name ->
                               external_module_name := (Some (Single name))
                           | `Some (a::b::[]) ->
                               external_module_name := (Some (Bind (a, b)))
                           | `Some _ -> ()
                           | `None -> ())
                      | "js.scope" ->
                          (match is_string_or_strings pay_load with
                           | `None -> ()
                           | `Single name -> qualifiers := [name]
                           | `Some vs -> qualifiers := (List.rev vs))
                      | "js.new" ->
                          (match is_single_string pay_load with
                           | None  -> ()
                           | Some x -> js_new := (Some x))
                      | "js.obj" -> is_obj := true
                      | _ -> ()))) in
           let loc: Location.t option =
             match ((!start_loc), (!finish_loc)) with
             | (None ,None ) -> None
             | (Some { loc_start;_},Some { loc_end;_}) ->
                 Some { loc_start; loc_end; loc_ghost = false }
             | _ -> assert false in
           if !is_obj
           then Obj_create
           else
             (match ((!call_name), (!js_global), (!js_send), (!js_new)) with
              | (Some (_,fn),`None,`None,_) ->
                  Js_call
                    {
                      txt =
                        {
                          splice = (!js_splice);
                          qualifiers = (!qualifiers);
                          name = fn
                        };
                      external_module_name = (!external_module_name)
                    }
              | (None ,`Value name,`None,_) ->
                  Js_global
                    { name; external_module_name = (!external_module_name) }
              | (None ,`None,`Value name,_) ->
                  Js_send { splice = (!js_splice); name }
              | (None ,`None,`None,Some name) ->
                  Js_new
                    {
                      txt = { name };
                      external_module_name = (!external_module_name)
                    }
              | (None ,`None,`None,None ) -> Normal
              | _ -> Location.raise_errorf ?loc "Ill defined attribute") : 
          ffi)
        let ocaml_to_js last (js_splice : bool)
          ((label : string),(ty : Types.type_expr)) (arg : J.expression) =
          (if last && js_splice
           then
             match ty with
             | { desc = Tconstr (p,_,_) } when Path.same p Predef.path_array
                 ->
                 (match arg with
                  | { expression_desc = Array (ls,_mutable_flag) } -> ls
                  | _ -> assert false)
             | _ -> assert false
           else
             (match (ty, (Type_util.label_name label)) with
              | ({ desc = Tconstr (p,_,_) },_) when
                  Path.same p Predef.path_unit -> []
              | ({ desc = Tconstr (p,_,_) },_) when
                  Path.same p Predef.path_bool ->
                  (match arg.expression_desc with
                   | Number (Int { i = 0;_}|Float 0.) -> [E.false_]
                   | Number _ -> [E.true_]
                   | _ -> [E.econd arg E.true_ E.false_])
              | (_,`Optional label) ->
                  (match arg.expression_desc with
                   | Array (x::y::[],_mutable_flag) -> [y]
                   | Number _ -> [E.null ()]
                   | _ -> [E.econd arg (E.undefined ()) (E.index arg 1)])
              | _ -> [arg]) : E.t list)
        let translate (cxt : Lam_compile_defs.cxt)
          (({ prim_attributes; prim_ty } as prim) :
            Types.type_expr option Primitive.description)
          (args : J.expression list) =
          match handle_attributes prim_attributes with
          | Obj_create  ->
              (match prim_ty with
               | Some ty ->
                   let (_return_type,arg_types) = Type_util.list_of_arrow ty in
                   let kvs =
                     Ext_list.filter_map2
                       (fun (label,(ty : Types.type_expr))  ->
                          fun (arg : J.expression)  ->
                            match ((ty.desc), (Type_util.label_name label))
                            with
                            | (Tconstr (p,_,_),_) when
                                Path.same p Predef.path_unit -> None
                            | (Tconstr (p,_,_),`Label label) when
                                Path.same p Predef.path_bool ->
                                (match arg.expression_desc with
                                 | Number (Float 0.|Int { i = 0;_}) ->
                                     Some (label, E.false_)
                                 | Number _ -> Some (label, E.true_)
                                 | _ ->
                                     Some
                                       (label,
                                         (E.econd arg E.true_ E.false_)))
                            | (_,`Label label) -> Some (label, arg)
                            | (_,`Optional label) ->
                                (match arg.expression_desc with
                                 | Array (x::y::[],_mutable_flag) ->
                                     Some (label, y)
                                 | Number _ -> None
                                 | _ ->
                                     Some
                                       (label,
                                         (E.econd arg (E.undefined ())
                                            (E.index arg 1))))) arg_types
                       args in
                   E.obj kvs
               | None  -> assert false)
          | Js_call
              { external_module_name = module_name;
                txt = { name = fn; splice = js_splice; qualifiers } }
              ->
              (match prim_ty with
               | Some ty ->
                   let (_return_type,arg_types) = Type_util.list_of_arrow ty in
                   let args =
                     Ext_list.flat_map2_last (ocaml_to_js js_splice)
                       arg_types args in
                   let qualifiers = List.rev qualifiers in
                   let fn =
                     match handle_external module_name with
                     | Some (id,_) ->
                         List.fold_left E.dot (E.var id) (qualifiers @ [fn])
                     | None  ->
                         (match qualifiers @ [fn] with
                          | y::ys -> List.fold_left E.dot (E.js_var y) ys
                          | _ -> assert false) in
                   E.call fn args
               | None  -> assert false)
          | Js_new
              { external_module_name = module_name; txt = { name = fn } } ->
              (match prim_ty with
               | Some ty ->
                   let (_return_type,arg_types) = Type_util.list_of_arrow ty in
                   let args =
                     Ext_list.flat_map2_last (ocaml_to_js false) arg_types
                       args in
                   let fn =
                     match handle_external module_name with
                     | Some (id,name) -> E.external_var_dot id name fn
                     | None  -> E.js_var fn in
                   ((match cxt.st with
                     | Declare (_,id)|Assign id ->
                         Ext_ident.make_js_object id
                     | EffectCall |NeedValue  -> ());
                    E.new_ fn args)
               | None  -> assert false)
          | Js_global { name } -> E.var (Ext_ident.create_js name)
          | Js_send { splice = js_splice; name } ->
              (match (args, prim_ty) with
               | (self::args,Some ty) ->
                   ((let (_return_type,self_type::arg_types) =
                       Type_util.list_of_arrow ty in
                     let args =
                       Ext_list.flat_map2_last (ocaml_to_js js_splice)
                         arg_types args in
                     E.call (E.dot self name) args)[@warning "-8"])
               | _ -> assert false)
          | Normal  ->
              Lam_compile_global.get_exp (CamlRuntimePrimitive (prim, args))
      end 
    module Js_of_lam_string :
      sig
        [@@@ocaml.text
          " Utilities to wrap [string] and [bytes] compilation, \n\n   this is isolated, so that we can swap different representation in the future.\n   [string] is Immutable, so there is not [set_string] method\n"]
        val ref_string : J.expression -> J.expression -> J.expression
        val ref_byte : J.expression -> J.expression -> J.expression
        val set_byte :
          J.expression -> J.expression -> J.expression -> J.expression
        val caml_char_of_int :
          ?comment:string -> J.expression -> J.expression
        val caml_char_to_int :
          ?comment:string -> J.expression -> J.expression
        val const_char : char -> J.expression
        val bytes_to_string : J.expression -> J.expression
        val bytes_of_string : J.expression -> J.expression
      end =
      struct
        module E = J_helper.Exp
        module A =
          struct
            let const_char (i : char) = E.str (String.make 1 i)
            let caml_char_of_int ?comment  (v : J.expression) =
              E.char_of_int ?comment v
            let caml_char_to_int ?comment  v = E.char_to_int ?comment v
            let ref_string e e1 = E.string_access e e1
            let ref_byte e e0 = E.char_of_int (E.access e e0)
            let set_byte e e0 e1 =
              E.assign (E.access e e0) (E.char_to_int e1)
            let bytes_to_string e =
              E.runtime_call J_helper.string "bytes_to_string" [e]
            let bytes_of_string s =
              E.runtime_call J_helper.string "bytes_of_string" [s]
          end
        module B =
          struct
            let const_char (i : char) =
              E.int
                ~comment:("\"" ^
                            ((Ext_string.escaped (String.make 1 i)) ^ "\""))
                ~c:i (Char.code i)
            let caml_char_of_int ?comment  (v : J.expression) = v
            let caml_char_to_int ?comment  v = v
            let ref_string e e1 = E.char_to_int (E.string_access e e1)
            let ref_byte e e0 = E.access e e0
            let set_byte e e0 e1 = E.assign (E.access e e0) e1
            [@@@ocaml.text
              "\n   Note that [String.fromCharCode] also works, but it only \n   work for small arrays, however, for {bytes_to_string} it is likely the bytes \n   will become big\n   {[\n   String.fromCharCode.apply(null,[87,97])\n   \"Wa\"\n   String.fromCharCode(87,97)\n   \"Wa\" \n   ]}\n   This does not work for large arrays\n   {[\n   String.fromCharCode.apply(null, prim = Array[1048576]) \n   Maxiume call stack size exceeded\n   ]}\n "]
            let bytes_to_string e =
              E.runtime_call J_helper.string "bytes_to_string" [e][@@ocaml.text
                                                                    "\n   Note that [String.fromCharCode] also works, but it only \n   work for small arrays, however, for {bytes_to_string} it is likely the bytes \n   will become big\n   {[\n   String.fromCharCode.apply(null,[87,97])\n   \"Wa\"\n   String.fromCharCode(87,97)\n   \"Wa\" \n   ]}\n   This does not work for large arrays\n   {[\n   String.fromCharCode.apply(null, prim = Array[1048576]) \n   Maxiume call stack size exceeded\n   ]}\n "]
            let bytes_of_string s =
              E.runtime_call J_helper.string "bytes_of_string" [s]
          end
        include B
      end 
    module Js_of_lam_block :
      sig
        [@@@ocaml.text
          " Utilities for creating block of lambda expression in JS IR "]
        val make_block :
          Js_op.mutable_flag ->
            Lambda.tag_info -> int -> J.expression list -> J.expression
        val field : J.expression -> int -> J.expression
        val set_field : J.expression -> int -> J.expression -> J.expression
        val set_double_field :
          J.expression -> int -> J.expression -> J.expression
        val get_double_feild : J.expression -> int -> J.expression
      end =
      struct
        module E = J_helper.Exp
        let make_block mutable_flag (tag_info : Lambda.tag_info) tag args =
          match (mutable_flag, tag_info) with
          | (_,Array ) ->
              Js_of_lam_array.make_array mutable_flag Pgenarray args
          | (_,(Tuple |Variant _)) ->
              E.arr Immutable
                ((E.int
                    ?comment:(Lam_compile_util.comment_of_tag_info tag_info)
                    tag) :: args)
          | (_,_) ->
              E.arr mutable_flag
                ((E.int
                    ?comment:(Lam_compile_util.comment_of_tag_info tag_info)
                    tag) :: args)
        let field e i = E.index e (i + 1)
        let set_field e i e0 = E.assign (E.index e (i + 1)) e0
        let set_double_field e i e0 = E.assign (E.index e (i + 1)) e0
        let get_double_feild e i = E.index e (i + 1)
      end 
    module Lam_compile_primitive :
      sig
        [@@@ocaml.text " Primitive compilation  "]
        val translate :
          Lam_compile_defs.cxt ->
            Lambda.primitive -> J.expression list -> J.expression
      end =
      struct
        module E = J_helper.Exp
        let decorate_side_effect
          ({ st; should_return;_} : Lam_compile_defs.cxt) e =
          (match (st, should_return) with
           | (_,True _)|((Assign _|Declare _|NeedValue ),_) ->
               E.seq e (E.unit ())
           | (EffectCall ,False ) -> e : E.t)
        let translate (({ meta = { env;_};_} as cxt) : Lam_compile_defs.cxt)
          (prim : Lambda.primitive) (args : J.expression list) =
          (match prim with
           | Pmakeblock (tag,tag_info,mutable_flag) ->
               (match mutable_flag with
                | Immutable  ->
                    Js_of_lam_block.make_block Immutable tag_info tag args
                | Mutable  ->
                    Js_of_lam_block.make_block Mutable tag_info tag args)
           | Pfield i ->
               (match args with
                | e::[] -> Js_of_lam_block.field e i
                | _ -> E.unknown_primitive prim)
           | Pnegint |Pnegbint _|Pnegfloat  ->
               (match args with
                | e::[] -> E.int_minus (E.int 0) e
                | _ -> E.unknown_primitive prim)
           | Pnot  ->
               (match args with
                | e::[] -> E.not e
                | _ -> E.unknown_primitive prim)
           | Poffsetint n ->
               (match args with
                | e::[] -> E.int_plus (E.int n) e
                | _ -> E.unknown_primitive prim)
           | Poffsetref n ->
               (match args with
                | e::[] ->
                    let v = Js_of_lam_block.field e 0 in
                    E.assign v (E.int_plus v (E.int n))
                | _ -> E.unknown_primitive prim)
           | Paddint |Paddbint _|Paddfloat  ->
               (match args with
                | e1::e2::[] -> E.add e1 e2
                | _ -> E.unknown_primitive prim)
           | Psubint |Psubbint _|Psubfloat  ->
               (match args with
                | e1::e2::[] -> E.minus e1 e2
                | _ -> E.unknown_primitive prim)
           | Pmulint |Pmulbint _|Pmulfloat  ->
               (match args with
                | e1::e2::[] -> E.mul e1 e2
                | _ -> E.unknown_primitive prim)
           | Pdivfloat  ->
               (match args with
                | e1::e2::[] -> E.div e1 e2
                | _ -> E.unknown_primitive prim)
           | Pdivint |Pdivbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Bor (E.div e1 e2) (E.int 0)
                | _ -> E.unknown_primitive prim)
           | Pmodint |Pmodbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Mod e1 e2
                | _ -> E.unknown_primitive prim)
           | Plslint |Plslbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Lsl e1 e2
                | _ -> E.unknown_primitive prim)
           | Plsrint |Plsrbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Lsr e1 e2
                | _ -> E.unknown_primitive prim)
           | Pasrint |Pasrbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Asr e1 e2
                | _ -> E.unknown_primitive prim)
           | Pandint |Pandbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Band e1 e2
                | _ -> E.unknown_primitive prim)
           | Porint |Porbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Bor e1 e2
                | _ -> E.unknown_primitive prim)
           | Pxorint |Pxorbint _ ->
               (match args with
                | e1::e2::[] -> E.bin Bxor e1 e2
                | _ -> E.unknown_primitive prim)
           | Psequand  ->
               (match args with
                | e1::e2::[] -> E.and_ e1 e2
                | _ -> E.unknown_primitive prim)
           | Psequor  ->
               (match args with
                | e1::e2::[] -> E.or_ e1 e2
                | _ -> E.unknown_primitive prim)
           | Pisout  ->
               (match args with
                | range::e::[] -> E.lt range (E.bin Lsr e (E.int 0))
                | _ -> E.unknown_primitive prim)
           | Pidentity  ->
               (match args with | e::[] -> e | _ -> E.unknown_primitive prim)
           | Pmark_ocaml_object  ->
               (match args with
                | e::[] -> E.tag_ml_obj e
                | _ -> E.unknown_primitive prim)
           | Pchar_of_int  ->
               (match args with
                | e::[] -> Js_of_lam_string.caml_char_of_int e
                | _ -> E.unknown_primitive prim)
           | Pchar_to_int  ->
               (match args with
                | e::[] -> Js_of_lam_string.caml_char_to_int e
                | _ -> E.unknown_primitive prim)
           | Pbytes_of_string  ->
               (match args with
                | e::[] -> Js_of_lam_string.bytes_of_string e
                | _ -> E.unknown_primitive prim)
           | Pbytes_to_string  ->
               (match args with
                | e::[] -> Js_of_lam_string.bytes_to_string e
                | _ -> E.unknown_primitive prim)
           | Pstringlength  ->
               (match args with
                | e::[] -> E.string_length e
                | _ -> E.unknown_primitive prim)
           | Pbyteslength  ->
               (match args with
                | e::[] -> E.bytes_length e
                | _ -> E.unknown_primitive prim)
           | Pbytessetu |Pbytessets  ->
               (match args with
                | e::e0::e1::[] ->
                    decorate_side_effect cxt
                      (Js_of_lam_string.set_byte e e0 e1)
                | _ -> E.unknown_primitive prim)
           | Pstringsetu |Pstringsets  -> E.unknown_primitive prim
           | Pbytesrefu |Pbytesrefs  ->
               (match args with
                | e::e1::[] -> Js_of_lam_string.ref_byte e e1
                | _ -> E.unknown_primitive prim)
           | Pstringrefu |Pstringrefs  ->
               (match args with
                | e::e1::[] -> Js_of_lam_string.ref_string e e1
                | _ -> E.unknown_primitive prim)
           | Pignore  ->
               (match args with | e::[] -> e | _ -> E.unknown_primitive prim)
           | Pbintcomp (_,cmp)|Pfloatcomp cmp|Pintcomp cmp ->
               (match args with
                | e1::e2::[] -> E.intcomp cmp e1 e2
                | _ -> E.unknown_primitive prim)
           | Pgetglobal i ->
               Lam_compile_global.get_exp (QueryGlobal (i, env, false))
           | Praise _raise_kind -> E.unknown_primitive prim
           | Prevapply _ ->
               (match args with
                | arg::f::[] -> E.call f [arg]
                | _ -> assert false)
           | Pdirapply _ ->
               (match args with
                | f::arg::[] -> E.call f [arg]
                | _ -> E.unknown_primitive prim)
           | Ploc kind -> E.unknown_primitive prim
           | Pintoffloat  ->
               (match args with | e::[] -> e | _ -> E.unknown_primitive prim)
           | Parraylength _ ->
               (match args with
                | e::[] -> E.array_length e
                | _ -> E.unknown_primitive prim)
           | Psetfield (i,_) ->
               (match args with
                | e0::e1::[] ->
                    decorate_side_effect cxt
                      (Js_of_lam_block.set_field e0 i e1)
                | _ -> E.unknown_primitive prim)
           | Psetfloatfield i ->
               (match args with
                | e::e0::[] ->
                    decorate_side_effect cxt
                      (Js_of_lam_block.set_double_field e i e0)
                | _ -> E.unknown_primitive prim)
           | Pfloatfield i ->
               (match args with
                | e::[] -> Js_of_lam_block.get_double_feild e i
                | _ -> E.unknown_primitive prim)
           | Parrayrefu _kind|Parrayrefs _kind ->
               (match args with
                | e::e1::[] -> Js_of_lam_array.ref_array e e1
                | _ -> E.unknown_primitive prim)
           | Pmakearray kind -> Js_of_lam_array.make_array Mutable kind args
           | Parraysetu _kind|Parraysets _kind ->
               (match args with
                | e::e0::e1::[] ->
                    (decorate_side_effect cxt) @@
                      (Js_of_lam_array.set_array e e0 e1)
                | _ -> E.unknown_primitive prim)
           | Pbintofint _|Pintofbint _|Pfloatofint  ->
               (match args with | e::[] -> e | _ -> E.unknown_primitive prim)
           | Pabsfloat  ->
               (match args with
                | e::[] -> E.math "abs" [e]
                | _ -> E.unknown_primitive prim)
           | Pccall ({ prim_attributes; prim_ty } as prim) ->
               Lam_compile_external_call.translate cxt prim args
           | Pisint  ->
               (match args with
                | e::[] -> E.is_type_number e
                | _ -> E.unknown_primitive prim)
           | Pctconst ct ->
               (match ct with
                | Big_endian  -> if Sys.big_endian then E.true_ else E.false_
                | Word_size  -> E.int Sys.word_size
                | Ostype_unix  -> if Sys.unix then E.true_ else E.false_
                | Ostype_win32  -> if Sys.win32 then E.true_ else E.false_
                | Ostype_cygwin  -> if Sys.cygwin then E.true_ else E.false_)
           | Pcvtbint (_boxed_integer_source,_boxed_integer_dest) ->
               (match args with
                | e0::[] -> e0
                | _ -> E.unknown_primitive prim)
           | Psetglobal _ -> E.unknown_primitive prim
           | Pduprecord (_,_)|Plazyforce |Pbittest |Pbigarrayref (_,_,_,_)
             |Pbigarrayset (_,_,_,_)|Pbigarraydim _|Pstring_load_16 _
             |Pstring_load_32 _|Pstring_load_64 _|Pstring_set_16 _
             |Pstring_set_32 _|Pstring_set_64 _|Pbigstring_load_16 _
             |Pbigstring_load_32 _|Pbigstring_load_64 _|Pbigstring_set_16 _
             |Pbigstring_set_32 _|Pbigstring_set_64 _|Pbswap16 |Pbbswap _
             |Pint_as_pointer  -> E.unknown_primitive prim : J.expression)
      end 
    module Lam_compile_const :
      sig
        [@@@ocaml.text " Compile lambda constant to JS "]
        val translate : Lambda.structured_constant -> J.expression
      end =
      struct
        module E = J_helper.Exp
        let rec translate (x : Lambda.structured_constant) =
          (match x with
           | Const_base c ->
               (match c with
                | Const_int i -> E.int i
                | Const_char i -> Js_of_lam_string.const_char i
                | Const_int32 i -> E.float (Int32.to_float i)
                | Const_int64 i -> E.float (Int64.to_float i)
                | Const_nativeint i -> E.float (Nativeint.to_float i)
                | Const_float f -> E.float (float_of_string f)
                | Const_string (i,_) -> E.str i)
           | Const_pointer (c,pointer_info) ->
               E.int
                 ?comment:(Lam_compile_util.comment_of_pointer_info
                             pointer_info) c
           | Const_block (tag,tag_info,xs) ->
               Js_of_lam_block.make_block NA tag_info tag
                 (List.map translate xs)
           | Const_float_array ars ->
               E.arr Mutable ~comment:"float array"
                 (List.map (fun x  -> E.float (float_of_string x)) ars)
           | Const_immstring s -> E.str s : J.expression)
      end 
    module Lam_compile :
      sig
        [@@@ocaml.text " Compile single lambda IR to JS IR  "]
        val compile_let :
          Lambda.let_kind ->
            Lam_compile_defs.cxt -> J.ident -> Lambda.lambda -> Js_output.t
        val compile_recursive_lets :
          Lam_compile_defs.cxt ->
            (Ident.t* Lambda.lambda) list -> Js_output.t
        val compile_lambda :
          Lam_compile_defs.cxt -> Lambda.lambda -> Js_output.t
      end =
      struct
        open Js_output.Ops
        module E = J_helper.Exp
        module S = J_helper.Stmt
        let method_cache_id = ref 1
        let add_jmps
          (ls : (Lam_compile_defs.jbl_label* Lam_compile_defs.value) list)
          (m : Lam_compile_defs.value Lam_compile_defs.HandlerMap.t) =
          (List.fold_left
             (fun acc  ->
                fun (l,s)  -> Lam_compile_defs.HandlerMap.add l s acc) m ls : 
          Lam_compile_defs.value Lam_compile_defs.HandlerMap.t)
        let rec flat_catches acc (x : Lambda.lambda) =
          (match x with
           | Lstaticcatch (l,(code,bindings),handler) ->
               flat_catches ((code, handler, bindings) :: acc) l
           | _ -> (acc, x) : ((int* Lambda.lambda* Ident.t list) list*
                               Lambda.lambda))
        let translate_dispatch = ref (fun _  -> assert false)
        type default_case =
          | Default of Lambda.lambda
          | Complete
          | NonComplete
        let rec compile_let flag (cxt : Lam_compile_defs.cxt) id
          (arg : Lambda.lambda) =
          (match (flag, arg) with
           | (let_kind,_) ->
               compile_lambda
                 {
                   cxt with
                   st = (Declare (let_kind, id));
                   should_return = False
                 } arg : Js_output.t)
        and compile_recursive_let (cxt : Lam_compile_defs.cxt) (id : Ident.t)
          (arg : Lambda.lambda) =
          match arg with
          | Lfunction (kind,params,body) ->
              let continue_label = Lam_util.generate_label ~name:(id.name) () in
              ((Js_output.handle_name_tail (Declare (Alias, id)) False arg
                  (let ret: Lam_compile_defs.return_label =
                     {
                       id;
                       label = continue_label;
                       params;
                       immutable_mask =
                         (Array.make (List.length params) true);
                       new_params = Ident_map.empty;
                       triggered = false
                     } in
                   let output =
                     compile_lambda
                       {
                         cxt with
                         st = EffectCall;
                         should_return = (True (Some ret));
                         jmp_table = Lam_compile_defs.empty_handler_map
                       } body in
                   if ret.triggered
                   then
                     let body_block = Js_output.to_block output in
                     E.efun ~immutable_mask:(ret.immutable_mask)
                       (List.map
                          (fun x  ->
                             try Ident_map.find x ret.new_params
                             with | Not_found  -> x) params)
                       [S.while_ E.true_
                          (Ident_map.fold
                             (fun old  ->
                                fun new_param  ->
                                  fun acc  ->
                                    (S.define ~kind:Alias old
                                       (E.var new_param))
                                    :: acc) ret.new_params body_block)]
                   else E.efun params (Js_output.to_block output))), [])
          | Lprim (Pmakeblock _,_) ->
              (match compile_lambda
                       { cxt with st = NeedValue; should_return = False } arg
               with
               | { block = b; value = Some v } ->
                   ((Js_output.of_block
                       (b @
                          [S.exp
                             (E.runtime_call J_helper.prim
                                "caml_update_dummy" [E.var id; v])])), 
                     [id])
               | _ -> assert false)
          | Lvar _ ->
              ((compile_lambda
                  {
                    cxt with
                    st = (Declare (Alias, id));
                    should_return = False
                  } arg), [])
          | _ ->
              ((compile_lambda
                  {
                    cxt with
                    st = (Declare (Alias, id));
                    should_return = False
                  } arg), [])
        and compile_recursive_lets cxt id_args =
          (let (output_code,ids) =
             List.fold_right
               (fun (ident,arg)  ->
                  fun (acc,ids)  ->
                    let (code,declare_ids) =
                      compile_recursive_let cxt ident arg in
                    ((code ++ acc), (declare_ids @ ids))) id_args
               (Js_output.dummy, []) in
           match ids with
           | [] -> output_code
           | _ ->
               (Js_output.of_block @@
                  (List.map
                     (fun id  ->
                        S.define ~kind:Variable id (E.arr Mutable [])) ids))
                 ++ output_code : Js_output.t)
        and compile_general_cases :
          'a .
            ('a -> J.expression) ->
              Lam_compile_defs.cxt ->
                (?default:J.block ->
                   ?declaration:(Lambda.let_kind* Ident.t) ->
                     _ -> 'a J.case_clause list -> J.statement)
                  -> _ -> ('a* Lambda.lambda) list -> default_case -> J.block=
          fun f  ->
            fun cxt  ->
              fun switch  ->
                fun v  ->
                  fun table  ->
                    fun default  ->
                      let wrap (cxt : Lam_compile_defs.cxt) k =
                        let (cxt,define) =
                          match cxt.st with
                          | Declare (kind,did) ->
                              ({ cxt with st = (Assign did) },
                                (Some (kind, did)))
                          | _ -> (cxt, None) in
                        k cxt define in
                      match (table, default) with
                      | ([],Default lam) ->
                          Js_output.to_block (compile_lambda cxt lam)
                      | ([],(Complete |NonComplete )) -> []
                      | ((id,lam)::[],Complete ) ->
                          Js_output.to_block @@ (compile_lambda cxt lam)
                      | ((id,lam)::[],NonComplete ) ->
                          (wrap cxt) @@
                            ((fun cxt  ->
                                fun define  ->
                                  [S.if_ ?declaration:define
                                     (E.triple_equal v (f id))
                                     (Js_output.to_block @@
                                        (compile_lambda cxt lam))]))
                      | ((id,lam)::[],Default x)
                        |((id,lam)::(_,x)::[],Complete ) ->
                          (wrap cxt) @@
                            ((fun cxt  ->
                                fun define  ->
                                  let else_block =
                                    Js_output.to_block (compile_lambda cxt x) in
                                  let then_block =
                                    Js_output.to_block
                                      (compile_lambda cxt lam) in
                                  [S.if_ ?declaration:define
                                     (E.triple_equal v (f id)) then_block
                                     ~else_:else_block]))
                      | (_,_) ->
                          (wrap cxt) @@
                            ((fun cxt  ->
                                fun declaration  ->
                                  let default =
                                    match default with
                                    | Complete  -> None
                                    | NonComplete  -> None
                                    | Default lam ->
                                        Some
                                          (Js_output.to_block
                                             (compile_lambda cxt lam)) in
                                  let body =
                                    (table |>
                                       (Ext_list.stable_group
                                          (fun (_,lam)  ->
                                             fun (_,lam1)  ->
                                               Lam_util.eq_lambda lam lam1)))
                                      |>
                                      (Ext_list.flat_map
                                         (fun group  ->
                                            group |>
                                              (Ext_list.map_last
                                                 (fun last  ->
                                                    fun (x,lam)  ->
                                                      if last
                                                      then
                                                        {
                                                          J.case = x;
                                                          body =
                                                            (Js_output.to_break_block
                                                               (compile_lambda
                                                                  cxt lam))
                                                        }
                                                      else
                                                        {
                                                          case = x;
                                                          body = ([], false)
                                                        })))) in
                                  [switch ?default ?declaration v body]))
        and compile_cases cxt =
          compile_general_cases E.int cxt
            (fun ?default  ->
               fun ?declaration  ->
                 fun e  ->
                   fun clauses  ->
                     S.int_switch ?default ?declaration e clauses)
        and compile_string_cases cxt =
          compile_general_cases E.str cxt
            (fun ?default  ->
               fun ?declaration  ->
                 fun e  ->
                   fun clauses  ->
                     S.string_switch ?default ?declaration e clauses)
        and compile_lambda
          (({ st; should_return; jmp_table; meta = { env;_} } as cxt) :
            Lam_compile_defs.cxt)
          (lam : Lambda.lambda) =
          (match lam with
           | Lfunction (kind,params,body) ->
               Js_output.handle_name_tail st should_return lam
                 (E.efun params
                    (Js_output.to_block
                       (compile_lambda
                          {
                            cxt with
                            st = EffectCall;
                            should_return = (True None);
                            jmp_table = Lam_compile_defs.empty_handler_map
                          } body)))
           | Lapply
               (Lprim
                (Pfield n,(Lprim (Pgetglobal id,[]))::[]),args_lambda,_info)
               ->
               ((let (args_code,args) =
                   (args_lambda |>
                      (List.map
                         (fun (x : Lambda.lambda)  ->
                            match x with
                            | Lprim (Pgetglobal i,[]) ->
                                ([],
                                  (Lam_compile_global.get_exp
                                     (QueryGlobal (i, env, true))))
                            | _ ->
                                (match compile_lambda
                                         {
                                           cxt with
                                           st = NeedValue;
                                           should_return = False
                                         } x
                                 with
                                 | { block = a; value = Some b } -> (a, b)
                                 | _ -> assert false))))
                     |> List.split in
                 Js_output.handle_block_return st should_return lam
                   (List.concat args_code)
                   (Lam_compile_global.get_exp_with_args id n env args))
               [@warning "-8"])
           | Lapply (fn,args_lambda,info) ->
               ((let (args_code,fn_code::args) =
                   ((fn :: args_lambda) |>
                      (List.map
                         (fun (x : Lambda.lambda)  ->
                            match x with
                            | Lprim (Pgetglobal ident,[]) ->
                                ([],
                                  (Lam_compile_global.get_exp
                                     (QueryGlobal (ident, env, true))))
                            | _ ->
                                (match compile_lambda
                                         {
                                           cxt with
                                           st = NeedValue;
                                           should_return = False
                                         } x
                                 with
                                 | { block = a; value = Some b } -> (a, b)
                                 | _ -> assert false))))
                     |> List.split in
                 (match (fn, should_return) with
                  | (Lvar id',True (Some ({ id; label; params;_} as ret)))
                      when Ident.same id id' ->
                      (ret.triggered <- true;
                       Js_output.of_block
                         ((List.concat args_code) @
                            (let (_,assigned_params,new_params) =
                               List.fold_left2
                                 (fun (i,assigns,new_params)  ->
                                    fun param  ->
                                      fun (arg : J.expression)  ->
                                        match arg with
                                        | { expression_desc = Var (Id x);_}
                                            when Ident.same x param ->
                                            ((i + 1), assigns, new_params)
                                        | _ ->
                                            let (new_param,m) =
                                              match Ident_map.find param
                                                      ret.new_params
                                              with
                                              | exception Not_found  ->
                                                  ((ret.immutable_mask).(i)
                                                   <- false;
                                                   (let v =
                                                      Ext_ident.create
                                                        ("_" ^
                                                           param.Ident.name) in
                                                    (v,
                                                      (Ident_map.add param v
                                                         new_params))))
                                              | v -> (v, new_params) in
                                            ((i + 1), ((new_param, arg) ::
                                              assigns), m))
                                 (0, [], Ident_map.empty) params args in
                             let () =
                               ret.new_params <-
                                 let open Ident_map in
                                   merge_disjoint new_params ret.new_params in
                             assigned_params |>
                               (List.map
                                  (fun (param,arg)  -> S.assign param arg)))))
                  | _ ->
                      Js_output.handle_block_return st should_return lam
                        (List.concat args_code)
                        (E.call
                           ~info:(match info with
                                  | { apply_status = Full  } ->
                                      { arity = Full }
                                  | { apply_status = NA  } -> { arity = NA })
                           fn_code args)))[@warning "-8"])
           | Llet (let_kind,id,arg,body) ->
               let args_code = compile_let let_kind cxt id arg in
               args_code ++ (compile_lambda cxt body)
           | Lletrec (id_args,body) ->
               let v = compile_recursive_lets cxt id_args in
               v ++ (compile_lambda cxt body)
           | Lvar id ->
               Js_output.handle_name_tail st should_return lam (E.var id)
           | Lconst c ->
               Js_output.handle_name_tail st should_return lam
                 (Lam_compile_const.translate c)
           | Lprim (Pfield n,(Lprim (Pgetglobal id,[]))::[]) ->
               Js_output.handle_name_tail st should_return lam
                 (Lam_compile_global.get_exp (GetGlobal (id, n, env)))
           | Lprim (Praise _raise_kind,e::[]) ->
               (match compile_lambda
                        { cxt with should_return = False; st = NeedValue } e
                with
                | { block = b; value = Some v } ->
                    Js_output.make (b @ [S.throw v]) ~value:(E.undefined ())
                      ~finished:True
                | { value = None ;_} -> assert false)
           | Lprim (prim,args_lambda) ->
               let (args_block,args_expr) =
                 (args_lambda |>
                    (List.map
                       (fun (x : Lambda.lambda)  ->
                          match compile_lambda
                                  {
                                    cxt with
                                    st = NeedValue;
                                    should_return = False
                                  } x
                          with
                          | { block = a; value = Some b } -> (a, b)
                          | _ -> assert false)))
                   |> List.split in
               let args_code = List.concat args_block in
               let exp = Lam_compile_primitive.translate cxt prim args_expr in
               Js_output.handle_block_return st should_return lam args_code
                 exp
           | Lsequence (l1,l2) ->
               let output_l1 =
                 compile_lambda
                   { cxt with st = EffectCall; should_return = False } l1 in
               let output_l2 = compile_lambda cxt l2 in
               output_l1 ++ output_l2
           | Lifthenelse (p,t_br,f_br) ->
               (match compile_lambda
                        { cxt with st = NeedValue; should_return = False } p
                with
                | { block = b; value = Some e } ->
                    (match (st, should_return,
                             (compile_lambda { cxt with st = NeedValue } t_br),
                             (compile_lambda { cxt with st = NeedValue } f_br))
                     with
                     | (NeedValue
                        ,_,{ block = []; value = Some out1 },{ block = [];
                                                               value = Some
                                                                 out2
                                                               })
                         -> Js_output.make b ~value:(E.econd e out1 out2)
                     | (NeedValue ,_,_,_) ->
                         let id = Ext_ident.gen_js () in
                         (match ((compile_lambda
                                    { cxt with st = (Assign id) } t_br),
                                  (compile_lambda
                                     { cxt with st = (Assign id) } f_br))
                          with
                          | (out1,out2) ->
                              Js_output.make
                                (((S.declare_variable ~kind:Variable id) ::
                                   b) @
                                   [S.if_ e (Js_output.to_block out1)
                                      ~else_:(Js_output.to_block out2)])
                                ~value:(E.var id))
                     | (Declare
                        (kind,id),_,{ block = []; value = Some out1 },
                        { block = []; value = Some out2 }) ->
                         Js_output.make
                           [S.define ~kind id (E.econd e out1 out2)]
                     | (Declare (kind,id),_,_,_) ->
                         Js_output.make
                           (b @
                              [S.if_ ~declaration:(kind, id) e
                                 (Js_output.to_block @@
                                    (compile_lambda
                                       { cxt with st = (Assign id) } t_br))
                                 ~else_:(Js_output.to_block @@
                                           (compile_lambda
                                              { cxt with st = (Assign id) }
                                              f_br))])
                     | (Assign
                        id,_,{ block = []; value = Some out1 },{ block = [];
                                                                 value = Some
                                                                   out2
                                                                 })
                         ->
                         Js_output.make [S.assign id (E.econd e out1 out2)]
                     | (EffectCall ,True
                        _,{ block = []; value = Some out1 },{ block = [];
                                                              value = Some
                                                                out2
                                                              })
                         ->
                         Js_output.make [S.return (E.econd e out1 out2)]
                           ~finished:True
                     | (EffectCall ,False
                        ,{ block = []; value = Some out1 },{ block = [];
                                                             value = Some
                                                               out2
                                                             })
                         ->
                         (match ((J_helper.extract_non_pure out1),
                                  (J_helper.extract_non_pure out2))
                          with
                          | (None ,None ) -> Js_output.make b
                          | (Some out1,Some out2) ->
                              Js_output.make b ~value:(E.econd e out1 out2)
                          | (Some out1,None ) ->
                              Js_output.make (b @ [S.if_ e [S.exp out1]])
                          | (None ,Some out2) ->
                              Js_output.make @@
                                (b @ [S.if_ (E.not e) [S.exp out2]]))
                     | (EffectCall ,False
                        ,{ block = []; value = Some out1 },_) ->
                         if J_helper.no_side_effect out1
                         then
                           Js_output.make
                             (b @
                                [S.if_ (E.not e)
                                   (Js_output.to_block @@
                                      (compile_lambda cxt f_br))])
                         else
                           Js_output.make
                             (b @
                                [S.if_ e
                                   (Js_output.to_block @@
                                      (compile_lambda cxt t_br))
                                   ~else_:(Js_output.to_block @@
                                             (compile_lambda cxt f_br))])
                     | (EffectCall ,False
                        ,_,{ block = []; value = Some out2 }) ->
                         let else_ =
                           if J_helper.no_side_effect out2
                           then None
                           else
                             Some
                               (Js_output.to_block @@
                                  (compile_lambda cxt f_br)) in
                         Js_output.make
                           (b @
                              [S.if_ e
                                 (Js_output.to_block @@
                                    (compile_lambda cxt t_br)) ?else_])
                     | ((Assign _|EffectCall ),_,_,_) ->
                         let then_output =
                           Js_output.to_block @@ (compile_lambda cxt t_br) in
                         let else_output =
                           Js_output.to_block @@ (compile_lambda cxt f_br) in
                         Js_output.make
                           (b @ [S.if_ e then_output ~else_:else_output]))
                | _ -> assert false)
           | Lstringswitch (l,cases,default) ->
               (match compile_lambda
                        { cxt with should_return = False; st = NeedValue } l
                with
                | { block; value = Some e } ->
                    let default =
                      match default with
                      | Some x -> Default x
                      | None  -> Complete in
                    (match st with
                     | NeedValue  ->
                         let v = Ext_ident.gen_js () in
                         Js_output.make
                           (block @
                              (compile_string_cases
                                 { cxt with st = (Declare (Variable, v)) } e
                                 cases default)) ~value:(E.var v)
                     | _ ->
                         Js_output.make
                           (block @
                              (compile_string_cases cxt e cases default)))
                | _ -> assert false)
           | Lswitch
               (lam,{ sw_numconsts; sw_consts; sw_numblocks; sw_blocks;
                      sw_failaction = default })
               ->
               let default: default_case =
                 match default with | None  -> Complete | Some x -> Default x in
               let compile_whole (({ st;_} as cxt) : Lam_compile_defs.cxt) =
                 match (sw_numconsts, sw_numblocks,
                         (compile_lambda
                            { cxt with should_return = False; st = NeedValue
                            } lam))
                 with
                 | (0,_,{ block; value = Some e }) ->
                     compile_cases cxt (E.tag e) sw_blocks default
                 | (_,0,{ block; value = Some e }) ->
                     compile_cases cxt e sw_consts default
                 | (_,_,{ block; value = Some e }) ->
                     let dispatch e =
                       [S.if_ (E.is_type_number e)
                          (compile_cases cxt e sw_consts default)
                          ~else_:(compile_cases cxt (E.tag e) sw_blocks
                                    default)] in
                     (match e.expression_desc with
                      | J.Var _ -> dispatch e
                      | _ ->
                          let v = Ext_ident.gen_js () in
                          (S.define ~kind:Variable v e) ::
                            (dispatch (E.var v)))
                 | (_,_,{ value = None ;_}) -> assert false in
               (match st with
                | NeedValue  ->
                    let v = Ext_ident.gen_js () in
                    Js_output.make ((S.declare_variable ~kind:Variable v) ::
                      (compile_whole { cxt with st = (Assign v) }))
                      ~value:(E.var v)
                | Declare (kind,id) ->
                    Js_output.make ((S.declare_variable ~kind id) ::
                      (compile_whole { cxt with st = (Assign id) }))
                | EffectCall |Assign _ -> Js_output.make (compile_whole cxt))
           | Lstaticraise (i,largs) ->
               (match Lam_compile_defs.HandlerMap.find i cxt.jmp_table with
                | { exit_id; args } ->
                    let args_code =
                      Js_output.concat @@
                        (List.map2
                           (fun (x : Lambda.lambda)  ->
                              fun (arg : Ident.t)  ->
                                match x with
                                | Lvar id ->
                                    Js_output.make [S.assign arg (E.var id)]
                                | _ ->
                                    compile_lambda
                                      {
                                        cxt with
                                        st = (Assign arg);
                                        should_return = False
                                      } x) largs (args : Ident.t list)) in
                    args_code ++
                      (Js_output.make [S.assign exit_id (E.int i)]
                         ~value:(E.undefined ()))
                | exception Not_found  ->
                    Js_output.make [S.unknown_lambda ~comment:"error" lam])
           | Lstaticcatch _ ->
               let (code_table,body) = flat_catches [] lam in
               let exit_id = Ext_ident.gen_js ~name:"exit" () in
               let exit_expr = E.var exit_id in
               let code_jmps =
                 List.map
                   (fun (i,_,bindings)  ->
                      (i,
                        ({ exit_id; args = bindings } : Lam_compile_defs.value)))
                   code_table in
               let bindings =
                 Ext_list.flat_map (fun (_,_,bindings)  -> bindings)
                   code_table in
               let handlers =
                 List.map (fun (i,lam,_)  -> (i, lam)) code_table in
               let jmp_table = add_jmps code_jmps jmp_table in
               let declares =
                 (S.define ~kind:Variable exit_id ~comment:"initialize"
                    (E.int (cxt.meta).unused_exit_code))
                 ::
                 (List.map (fun x  -> S.declare_variable ~kind:Variable x)
                    bindings) in
               (match st with
                | NeedValue  ->
                    let v = Ext_ident.gen_js () in
                    let lbody =
                      compile_lambda { cxt with jmp_table; st = (Assign v) }
                        body in
                    ((Js_output.make ((S.declare_variable ~kind:Variable v)
                        :: declares))
                       ++ lbody)
                      ++
                      (Js_output.make
                         (compile_cases
                            { cxt with st = (Assign v); jmp_table } exit_expr
                            handlers NonComplete) ~value:(E.var v))
                | Declare (kind,id) ->
                    let declares = (S.declare_variable ~kind id) :: declares in
                    let lbody =
                      compile_lambda { cxt with jmp_table; st = (Assign id) }
                        body in
                    ((Js_output.make declares) ++ lbody) ++
                      (Js_output.make
                         (compile_cases
                            { cxt with jmp_table; st = (Assign id) }
                            exit_expr handlers NonComplete))
                | EffectCall |Assign _ ->
                    let lbody = compile_lambda { cxt with jmp_table } body in
                    ((Js_output.make declares) ++ lbody) ++
                      (Js_output.make
                         (compile_cases { cxt with jmp_table } exit_expr
                            handlers NonComplete)))
           | Lwhile (p,body) ->
               (match compile_lambda
                        { cxt with st = NeedValue; should_return = False } p
                with
                | { block; value = Some e } ->
                    let e =
                      match block with | [] -> e | _ -> E.of_block block e in
                    let block =
                      [S.while_ e
                         (Js_output.to_block @@
                            (compile_lambda
                               {
                                 cxt with
                                 st = EffectCall;
                                 should_return = False
                               } body))] in
                    (match (st, should_return) with
                     | (Declare (_kind,x),_) ->
                         Js_output.make (block @ [S.declare_unit x])
                     | (Assign x,_) ->
                         Js_output.make (block @ [S.assign_unit x])
                     | (EffectCall ,True _) ->
                         Js_output.make (block @ [S.return_unit ()])
                           ~finished:True
                     | (EffectCall ,_) -> Js_output.make block
                     | (NeedValue ,_) ->
                         Js_output.make block ~value:(E.unit ()))
                | _ -> assert false)
           | Lfor (id,start,finish,direction,body) ->
               let block =
                 match ((compile_lambda
                           { cxt with st = NeedValue; should_return = False }
                           start),
                         (compile_lambda
                            { cxt with st = NeedValue; should_return = False
                            } finish))
                 with
                 | ({ block = b1; value = Some e1 },{ block = b2;
                                                      value = Some e2 })
                     ->
                     (match (b1, b2) with
                      | (_,[]) ->
                          b1 @
                            [S.for_ (Some e1) e2 id direction
                               (Js_output.to_block @@
                                  (compile_lambda
                                     {
                                       cxt with
                                       should_return = False;
                                       st = EffectCall
                                     } body))]
                      | (_,_) when J_helper.no_side_effect e1 ->
                          b1 @
                            (b2 @
                               [S.for_ (Some e1) e2 id direction
                                  (Js_output.to_block @@
                                     (compile_lambda
                                        {
                                          cxt with
                                          should_return = False;
                                          st = EffectCall
                                        } body))])
                      | (_,_) ->
                          b1 @
                            (((S.define ~kind:Variable id e1) :: b2) @
                               [S.for_ None e2 id direction
                                  (Js_output.to_block @@
                                     (compile_lambda
                                        {
                                          cxt with
                                          should_return = False;
                                          st = EffectCall
                                        } body))]))
                 | _ -> assert false in
               (match (st, should_return) with
                | (EffectCall ,False ) -> Js_output.make block
                | (EffectCall ,True _) ->
                    Js_output.make (block @ [S.return_unit ()])
                      ~finished:True
                | ((Declare _|Assign _),True _) ->
                    Js_output.make [S.unknown_lambda lam]
                | (Declare (_kind,x),False ) ->
                    Js_output.make (block @ [S.declare_unit x])
                | (Assign x,False ) ->
                    Js_output.make (block @ [S.assign_unit x])
                | (NeedValue ,_) -> Js_output.make block ~value:(E.unit ()))
           | Lassign (id,lambda) ->
               let block =
                 match lambda with
                 | Lprim (Poffsetint v,(Lvar id')::[]) when Ident.same id id'
                     ->
                     [S.exp
                        (E.assign (E.var id)
                           (E.int_plus (E.var id) (E.int v)))]
                 | _ ->
                     (match compile_lambda
                              {
                                cxt with
                                st = NeedValue;
                                should_return = False
                              } lambda
                      with
                      | { block = b; value = Some v } -> b @ [S.assign id v]
                      | _ -> assert false) in
               (match (st, should_return) with
                | (EffectCall ,False ) -> Js_output.make block
                | (EffectCall ,True _) ->
                    Js_output.make (block @ [S.return_unit ()])
                      ~finished:True
                | ((Declare _|Assign _),True _) ->
                    Js_output.make [S.unknown_lambda lam]
                | (Declare (_kind,x),False ) ->
                    Js_output.make (block @ [S.declare_unit x])
                | (Assign x,False ) ->
                    Js_output.make (block @ [S.assign_unit x])
                | (NeedValue ,_) -> Js_output.make block ~value:(E.unit ()))
           | Ltrywith (lam,id,catch) ->
               let aux st =
                 [S.try_
                    (Js_output.to_block (compile_lambda { cxt with st } lam))
                    ~with_:(id,
                             (Js_output.to_block @@
                                (compile_lambda { cxt with st } catch)))] in
               (match st with
                | NeedValue  ->
                    let v = Ext_ident.gen_js () in
                    Js_output.make ((S.declare_variable ~kind:Variable v) ::
                      (aux (Assign v))) ~value:(E.var v)
                | Declare (kind,id) ->
                    Js_output.make ((S.declare_variable ~kind id) ::
                      (aux (Assign id)))
                | Assign _|EffectCall  -> Js_output.make (aux st))
           | Lsend (meth_kind,met,obj,args,loc) ->
               ((let (args_code,label::obj'::args) =
                   ((met :: obj :: args) |>
                      (List.map
                         (fun (x : Lambda.lambda)  ->
                            match x with
                            | Lprim (Pgetglobal i,[]) ->
                                ([],
                                  (Lam_compile_global.get_exp
                                     (QueryGlobal (i, env, true))))
                            | _ ->
                                (match compile_lambda
                                         {
                                           cxt with
                                           st = NeedValue;
                                           should_return = False
                                         } x
                                 with
                                 | { block = a; value = Some b } -> (a, b)
                                 | _ -> assert false))))
                     |> List.split in
                 (match meth_kind with
                  | Self  ->
                      Js_output.handle_block_return st should_return lam
                        (List.concat args_code)
                        (E.call
                           (Js_of_lam_array.ref_array (E.index obj' 1) label)
                           (obj' :: args))
                  | Cached |Public (None ) ->
                      let get =
                        E.runtime_ref J_helper.oo "caml_get_public_method" in
                      let cache = !method_cache_id in
                      let () = incr method_cache_id in
                      Js_output.handle_block_return st should_return lam
                        (List.concat args_code)
                        (E.call (E.call get [obj'; label; E.int cache]) (obj'
                           :: args))
                  | Public (Some name) ->
                      let set_prefix = "_set_" in
                      let get_prefix = "_get_" in
                      let set_prefix_len = String.length "_set_" in
                      let get_prefix_len = String.length "_get_" in
                      let is_getter s =
                        if Ext_string.starts_with s get_prefix
                        then
                          Some
                            (String.sub s get_prefix_len
                               ((String.length s) - get_prefix_len))
                        else None in
                      let is_setter s =
                        if Ext_string.starts_with s set_prefix
                        then
                          Some
                            (String.sub s set_prefix_len
                               ((String.length s) - set_prefix_len))
                        else None in
                      let js_call obj =
                        match args with
                        | [] ->
                            (E.var_dot obj) @@
                              ((match is_getter name with
                                | Some v -> v
                                | None  -> name))
                        | y::ys ->
                            (match is_setter name with
                             | Some v -> E.assign (E.var_dot obj v) y
                             | None  -> E.call (E.var_dot obj name) args) in
                      (match obj with
                       | Lprim (Pccall { prim_name;_},[]) ->
                           (Js_output.handle_block_return st should_return
                              lam (List.concat args_code))
                             @@ (js_call (Ext_ident.create_js prim_name))
                       | Lvar id when Ext_ident.is_js_object id ->
                           (Js_output.handle_block_return st should_return
                              lam (List.concat args_code))
                             @@ (js_call id)
                       | _ ->
                           let cache = !method_cache_id in
                           let () = incr method_cache_id in
                           Js_output.handle_block_return st should_return lam
                             (List.concat args_code)
                             (E.call
                                (E.runtime_call J_helper.oo
                                   "caml_get_public_method"
                                   [obj'; label; E.int cache]) (obj' :: args)))))
               [@warning "-8"])
           | Levent (lam,_lam_event) -> compile_lambda cxt lam
           | Lifused (_,lam) -> compile_lambda cxt lam : Js_output.t)
      end 
    module Lam_inline_util :
      sig
        [@@@ocaml.text " Utilities for lambda inlining "]
        val maybe_functor : string -> bool
      end =
      struct
        let maybe_functor (name : string) =
          ((name.[0]) >= 'A') && ((name.[0]) <= 'Z')
        let app_definitely_inlined (body : Lambda.lambda) =
          match body with
          | Lvar _|Lconst _|Lprim _|Lapply _ -> true
          | Llet _|Lletrec _|Lstringswitch _|Lswitch _|Lstaticraise _
            |Lfunction _|Lstaticcatch _|Ltrywith _|Lifthenelse _|Lsequence _
            |Lwhile _|Lfor _|Lassign _|Lsend _|Levent _|Lifused _ -> false
      end 
    module Ext_option :
      sig
        [@@@ocaml.text " Utilities for [option] type "]
        val bind : 'a option -> ('a -> 'b) -> 'b option
      end =
      struct
        let bind v f = match v with | None  -> None | Some x -> Some (f x)
      end 
    module Lam_stats_util :
      sig
        [@@@ocaml.text " Utilities for lambda analysis "]
        val pp_alias_tbl : Format.formatter -> Lam_stats.alias_tbl -> unit
        val get_arity :
          Lam_stats.meta -> Lambda.lambda -> Lam_stats.function_arities
        val export_to_cmj :
          Lam_stats.meta ->
            string option ->
              Lam_module_ident.t list ->
                Lambda.lambda list -> Js_cmj_format.cmj_table
        val find_unused_exit_code : int Hash_set.hashset -> int
      end =
      struct
        let pp = Format.fprintf
        let pp_arities (fmt : Format.formatter)
          (x : Lam_stats.function_arities) =
          match x with
          | NA  -> pp fmt "?"
          | Determin (b,ls,tail) ->
              (pp fmt "@[";
               if not b then pp fmt "~";
               pp fmt "[";
               Format.pp_print_list
                 ~pp_sep:(fun fmt  -> fun ()  -> pp fmt ",")
                 (fun fmt  -> fun (x,_)  -> Format.pp_print_int fmt x) fmt ls;
               if tail then pp fmt "@ *";
               pp fmt "]@]")
        let pp_arities_tbl (fmt : Format.formatter)
          (arities_tbl : (Ident.t,Lam_stats.function_arities ref) Hashtbl.t)
          =
          Hashtbl.fold
            (fun (i : Ident.t)  ->
               fun (v : Lam_stats.function_arities ref)  ->
                 fun _  ->
                   pp Format.err_formatter "@[%s -> %a@]@." i.name pp_arities
                     (!v)) arities_tbl ()
        let pp_alias_tbl fmt (tbl : Lam_stats.alias_tbl) =
          Hashtbl.iter
            (fun k  ->
               fun v  -> pp fmt "@[%a -> %a@]@." Ident.print k Ident.print v)
            tbl
        let merge (((n : int),params) as y) (x : Lam_stats.function_arities)
          =
          (match x with
           | NA  -> Determin (false, [y], false)
           | Determin (b,xs,tail) -> Determin (b, (y :: xs), tail) : 
          Lam_stats.function_arities)
        let rec get_arity (meta : Lam_stats.meta) (lam : Lambda.lambda) =
          (match lam with
           | Lconst _ -> Determin (true, [], false)
           | Lvar v ->
               (match Hashtbl.find meta.ident_tbl v with
                | exception Not_found  -> (NA : Lam_stats.function_arities)
                | Function { arity;_} -> arity
                | _ -> (NA : Lam_stats.function_arities))
           | Llet (_,_,_,l) -> get_arity meta l
           | Lprim (Pfield n,(Lprim (Pgetglobal id,[]))::[]) ->
               Lam_compile_env.find_and_add_if_not_exist (id, n) meta.env
                 ~not_found:(fun _  -> assert false)
                 ~found:(fun x  -> x.arity)
           | Lprim (Pfield _,_) -> NA
           | Lprim (Praise _,_) -> Determin (true, [], true)
           | Lprim (Pccall _,_) -> Determin (false, [], false)
           | Lprim _ -> Determin (true, [], false)
           | Lletrec (_,body) -> get_arity meta body
           | Lapply (app,args,_info) ->
               let fn = get_arity meta app in
               (match fn with
                | NA  -> NA
                | Determin (b,xs,tail) ->
                    let rec take (xs : _ list) arg_length =
                      match xs with
                      | (x,y)::xs ->
                          if arg_length = x
                          then Lam_stats.Determin (b, xs, tail)
                          else
                            if arg_length > x
                            then take xs (arg_length - x)
                            else
                              Determin
                                (b,
                                  (((x - arg_length),
                                     (Ext_list.drop arg_length y)) :: xs),
                                  tail)
                      | [] ->
                          if tail
                          then Determin (b, [], tail)
                          else
                            if not b
                            then NA
                            else failwith (Lam_util.string_of_lambda lam) in
                    take xs (List.length args))
           | Lfunction (kind,params,l) ->
               let n = List.length params in
               merge (n, params) (get_arity meta l)
           | Lswitch
               (l,{ sw_failaction; sw_consts; sw_blocks; sw_numblocks = _;
                    sw_numconsts = _ })
               ->
               all_lambdas meta
                 (let rest =
                    (sw_consts |> (List.map snd)) @
                      (sw_blocks |> (List.map snd)) in
                  match sw_failaction with
                  | None  -> rest
                  | Some x -> x :: rest)
           | Lstringswitch (l,sw,d) ->
               (match d with
                | None  -> all_lambdas meta (List.map snd sw)
                | Some v -> all_lambdas meta (v :: (List.map snd sw)))
           | Lstaticraise _ -> NA
           | Lstaticcatch (_,_,handler) -> get_arity meta handler
           | Ltrywith (l1,_,l2) -> all_lambdas meta [l1; l2]
           | Lifthenelse (l1,l2,l3) -> all_lambdas meta [l2; l3]
           | Lsequence (_,l2) -> get_arity meta l2
           | Lsend (u,m,o,ll,v) -> NA
           | Levent (l,event) -> NA
           | Lifused (v,l) -> NA
           | Lwhile _|Lfor _|Lassign _ -> Determin (true, [], false) : 
          Lam_stats.function_arities)
        and all_lambdas meta (xs : Lambda.lambda list) =
          match xs with
          | y::ys ->
              let arity = get_arity meta y in
              List.fold_left
                (fun exist  ->
                   fun (v : Lambda.lambda)  ->
                     match (exist : Lam_stats.function_arities) with
                     | NA  -> NA
                     | Determin (b,xs,tail) ->
                         (match get_arity meta v with
                          | NA  -> NA
                          | Determin (u,ys,tail2) ->
                              let rec aux (b,acc) xs ys =
                                match (xs, ys) with
                                | ([],[]) ->
                                    (b, (List.rev acc), (tail && tail2))
                                | ([],y::ys) when tail ->
                                    aux (b, (y :: acc)) [] ys
                                | (x::xs,[]) when tail2 ->
                                    aux (b, (x :: acc)) [] xs
                                | (x::xs,y::ys) when x = y ->
                                    aux (b, (y :: acc)) xs ys
                                | (_,_) -> (false, (List.rev acc), false) in
                              let (b,acc,tail3) = aux ((u && b), []) xs ys in
                              Determin (b, acc, tail3))) arity ys
          | _ -> assert false
        let pp = Format.fprintf
        let meaningless_names = ["*opt*"; "param"]
        let rec dump_ident fmt (id : Ident.t)
          (arity : Lam_stats.function_arities) =
          pp fmt "@[<2>export var %s:@ %a@ ;@]" (Ext_ident.convert id.name)
            dump_arity arity
        and dump_arity fmt (arity : Lam_stats.function_arities) =
          match arity with
          | NA  -> pp fmt "any"
          | Determin (_,[],_) -> pp fmt "any"
          | Determin (_,(_,args)::xs,_) ->
              pp fmt "@[(%a)@ =>@ any@]"
                (Format.pp_print_list
                   ~pp_sep:(fun fmt  ->
                              fun _  ->
                                Format.pp_print_string fmt ",";
                                Format.pp_print_space fmt ())
                   (fun fmt  ->
                      fun ident  ->
                        pp fmt "@[%s@ :@ any@]"
                          (Ext_ident.convert @@ (Ident.name ident)))) args
        let export_to_cmj (meta : Lam_stats.meta) maybe_pure external_ids
          lambda_exports =
          (let values =
             List.fold_left2
               (fun acc  ->
                  fun (x : Ident.t)  ->
                    fun (lambda : Lambda.lambda)  ->
                      let arity = get_arity meta (Lvar x) in
                      let closed_lambda =
                        if Lam_inline_util.maybe_functor x.name
                        then
                          (if
                             Lambda.IdentSet.is_empty @@
                               (Lambda.free_variables lambda)
                           then Some lambda
                           else None)
                        else None in
                      String_map.add x.name
                        (let open Js_cmj_format in { arity; closed_lambda })
                        acc) String_map.empty meta.exports lambda_exports in
           let tds_chan =
             open_out ((Filename.chop_extension meta.filename) ^ ".d.ts") in
           let fmt = Format.formatter_of_out_channel tds_chan in
           let rec dump fmt ids =
             match ids with
             | [] -> ()
             | x::xs ->
                 (dump_ident fmt x (get_arity meta (Lvar x));
                  Format.pp_print_space fmt ();
                  dump fmt xs) in
           let () = pp fmt "@[<v>%a@]@." dump meta.exports in
           let pure =
             match maybe_pure with
             | None  ->
                 Ext_option.bind
                   (Ext_list.for_all_ret
                      (fun (id : Lam_module_ident.t)  ->
                         Lam_compile_env.query_and_add_if_not_exist id
                           meta.env ~not_found:(fun _  -> false)
                           ~found:(fun i  -> i.pure)) external_ids)
                   (fun x  -> Lam_module_ident.name x)
             | Some _ -> maybe_pure in
           { values; pure } : Js_cmj_format.cmj_table)
        let find_unused_exit_code hash_set =
          let rec aux i =
            if not @@ (Hash_set.mem hash_set i)
            then i
            else
              if not @@ (Hash_set.mem hash_set (- i))
              then - i
              else aux (i + 1) in
          aux 0
      end 
    module Lam_pass_alpha_with_arity :
      sig
        [@@@ocaml.text " Beta reduction of lambda IR "]
        val propogate_beta_reduce :
          Lam_stats.meta ->
            Ident.t list ->
              Lambda.lambda -> Lambda.lambda list -> Lambda.lambda
      end =
      struct
        let rename (map : (Ident.t,Ident.t) Hashtbl.t) (lam : Lambda.lambda)
          =
          (let rebind i = let i' = Ident.rename i in Hashtbl.add map i i'; i' in
           let rec aux (lam : Lambda.lambda) =
             (match lam with
              | Lvar v ->
                  (try Lvar (Hashtbl.find map v) with | Not_found  -> lam)
              | Lconst _ -> lam
              | Llet (str,v,l1,l2) ->
                  let v = rebind v in Llet (str, v, (aux l1), (aux l2))
              | Lletrec (bindings,body) ->
                  let bindings =
                    List.map (fun (k,l)  -> let k = rebind k in (k, (aux l)))
                      bindings in
                  Lletrec (bindings, (aux body))
              | Lprim (prim,ll) -> Lprim (prim, (List.map aux ll))
              | Lapply (l1,ll,info) ->
                  Lapply ((aux l1), (List.map aux ll), info)
              | Lfunction (kind,params,l) ->
                  let params = List.map rebind params in
                  Lfunction (kind, params, (aux l))
              | Lswitch
                  (l,{ sw_failaction; sw_consts; sw_blocks; sw_numblocks;
                       sw_numconsts })
                  ->
                  let l = aux l in
                  Lswitch
                    (l,
                      {
                        sw_consts =
                          (List.map (fun (v,l)  -> (v, (aux l))) sw_consts);
                        sw_blocks =
                          (List.map (fun (v,l)  -> (v, (aux l))) sw_blocks);
                        sw_numconsts;
                        sw_numblocks;
                        sw_failaction =
                          ((match sw_failaction with
                            | None  -> None
                            | Some x -> Some (aux x)))
                      })
              | Lstringswitch (l,sw,d) ->
                  let l = aux l in
                  Lstringswitch
                    (l, (List.map (fun (i,l)  -> (i, (aux l))) sw),
                      ((match d with | Some d -> Some (aux d) | None  -> None)))
              | Lstaticraise (i,ls) -> Lstaticraise (i, (List.map aux ls))
              | Lstaticcatch (l1,(i,xs),l2) ->
                  let l1 = aux l1 in
                  let xs = List.map rebind xs in
                  let l2 = aux l2 in Lstaticcatch (l1, (i, xs), l2)
              | Ltrywith (l1,v,l2) ->
                  let l1 = aux l1 in
                  let v = rebind v in let l2 = aux l2 in Ltrywith (l1, v, l2)
              | Lifthenelse (l1,l2,l3) ->
                  let l1 = aux l1 in
                  let l2 = aux l2 in
                  let l3 = aux l3 in Lifthenelse (l1, l2, l3)
              | Lsequence (l1,l2) ->
                  let l1 = aux l1 in let l2 = aux l2 in Lsequence (l1, l2)
              | Lwhile (l1,l2) ->
                  let l1 = aux l1 in let l2 = aux l2 in Lwhile (l1, l2)
              | Lfor (ident,l1,l2,dir,l3) ->
                  let ident = rebind ident in
                  let l1 = aux l1 in
                  let l2 = aux l2 in
                  let l3 = aux l3 in Lfor (ident, (aux l1), l2, dir, l3)
              | Lassign (v,l) -> Lassign (v, (aux l))
              | Lsend (u,m,o,ll,v) ->
                  let m = aux m in
                  let o = aux o in
                  let ll = List.map aux ll in Lsend (u, m, o, ll, v)
              | Levent (l,event) -> let l = aux l in Levent (l, event)
              | Lifused (v,l) -> let l = aux l in Lifused (v, l) : Lambda.lambda) in
           aux lam : Lambda.lambda)
        let rec bounded_idents tbl lam =
          let rebind i = Hashtbl.add tbl i (Ident.rename i) in
          let rec collect_introduced_idents (lam : Lambda.lambda) =
            match lam with
            | Lvar _|Lconst _ -> ()
            | Lapply (f,ls,_) ->
                (collect_introduced_idents f;
                 List.iter collect_introduced_idents ls)
            | Lfunction (_,args,lam) ->
                (List.iter (fun a  -> rebind a) args;
                 collect_introduced_idents lam)
            | Llet (_,id,arg,body) ->
                (rebind id;
                 collect_introduced_idents arg;
                 collect_introduced_idents body)
            | Lletrec (bindings,body) ->
                (List.iter
                   (fun (i,arg)  -> rebind i; collect_introduced_idents arg)
                   bindings;
                 collect_introduced_idents body)
            | Lprim (_,lams) -> List.iter collect_introduced_idents lams
            | Lswitch (lam,switch) ->
                (collect_introduced_idents lam; assert false)
            | Lstringswitch _ -> assert false
            | Lstaticraise (_,ls) -> List.iter collect_introduced_idents ls
            | Lstaticcatch (lam,(_i,is),body) ->
                (List.iter rebind is;
                 collect_introduced_idents lam;
                 collect_introduced_idents body)
            | Ltrywith (a,i,b) ->
                (rebind i;
                 collect_introduced_idents a;
                 collect_introduced_idents b)
            | Lifthenelse (a,b,c) ->
                (collect_introduced_idents a;
                 collect_introduced_idents b;
                 collect_introduced_idents c)
            | Lsequence (a,b) ->
                (collect_introduced_idents a; collect_introduced_idents b)
            | Lwhile (a,b) ->
                (collect_introduced_idents a; collect_introduced_idents b)
            | Lfor (i,a,b,_direction,l) ->
                (rebind i;
                 collect_introduced_idents a;
                 collect_introduced_idents b;
                 collect_introduced_idents l)
            | Lassign (_v,a) -> collect_introduced_idents a
            | Lsend (_,a,b,ls,_location) ->
                (collect_introduced_idents a;
                 collect_introduced_idents b;
                 List.iter collect_introduced_idents ls)
            | Levent (a,_event) -> collect_introduced_idents a
            | Lifused (_id,a) -> collect_introduced_idents a in
          collect_introduced_idents lam
        let refresh_lambda (lam : Lambda.lambda) =
          (let map = Hashtbl.create 57 in
           bounded_idents map lam; rename map lam : Lambda.lambda)
        let propogate_beta_reduce (meta : Lam_stats.meta) params body args =
          let new_params = List.map Ident.rename params in
          let map = Hashtbl.create 51 in
          let () =
            List.iter2 (fun k  -> fun v  -> Hashtbl.add map k v) params
              new_params in
          let new_body = rename map body in
          let lam =
            List.fold_left2
              (fun l  ->
                 fun param  ->
                   fun (arg : Lambda.lambda)  ->
                     let arg =
                       match arg with
                       | Lvar v ->
                           ((match Hashtbl.find meta.ident_tbl v with
                             | exception Not_found  -> ()
                             | ident_info ->
                                 Hashtbl.add meta.ident_tbl param ident_info);
                            arg)
                       | Lprim (Pgetglobal ident,[]) ->
                           Lam_compile_global.query_lambda ident meta.env
                       | Lprim (Pmakeblock (_,_,Immutable ),ls) ->
                           (Hashtbl.replace meta.ident_tbl param
                              (Lam_util.kind_of_lambda_block ls);
                            arg)
                       | _ -> arg in
                     Lam_util.refine_let param arg l) new_body new_params
              args in
          lam
      end 
    module Lam_pass_remove_alias :
      sig
        [@@@ocaml.text " Keep track of the global module Aliases "]
        [@@@ocaml.text
          "\n    One way:  guarantee that all global aliases *would be removed* ,\n    it will not be aliased \n    \n    So the only remaining place for globals is either \n    just  Pgetglobal in functor application or \n    `Lprim (Pfield( i ), [Pgetglobal])`\n\n    This pass does not change meta  data\n"]
        val simplify_alias : Lam_stats.meta -> Lambda.lambda -> Lambda.lambda
      end =
      struct
        let simplify_alias (meta : Lam_stats.meta) (lam : Lambda.lambda) =
          (let rec simpl (lam : Lambda.lambda) =
             (match lam with
              | Lvar v ->
                  (try Lvar (Hashtbl.find meta.alias_tbl v)
                   with | Not_found  -> lam)
              | Llet (kind,k,(Lprim (Pgetglobal i,[]) as g),l) ->
                  let v = simpl l in
                  if List.mem k meta.export_idents
                  then Llet (kind, k, g, v)
                  else v
              | Lprim (Pfield i,(Lvar v)::[]) ->
                  Lam_util.get lam v i meta.ident_tbl
              | Lconst _ -> lam
              | Llet (str,v,l1,l2) -> Llet (str, v, (simpl l1), (simpl l2))
              | Lletrec (bindings,body) ->
                  let bindings =
                    List.map (fun (k,l)  -> (k, (simpl l))) bindings in
                  Lletrec (bindings, (simpl body))
              | Lprim (prim,ll) -> Lprim (prim, (List.map simpl ll))
              | Lapply
                  ((Lprim (Pfield index,(Lprim (Pgetglobal ident,[]))::[]) as
                      l1),args,info)
                  ->
                  Lam_compile_env.find_and_add_if_not_exist (ident, index)
                    meta.env ~not_found:(fun _  -> assert false)
                    ~found:(fun i  ->
                              match i with
                              | {
                                  closed_lambda = Some (Lfunction
                                    (Curried ,params,body))
                                  } when
                                  List.for_all
                                    (fun (arg : Lambda.lambda)  ->
                                       match arg with
                                       | Lvar p ->
                                           (try
                                              (Hashtbl.find meta.ident_tbl p)
                                                != Parameter
                                            with | Not_found  -> true)
                                       | _ -> true) args
                                  ->
                                  simpl @@
                                    (Lam_pass_alpha_with_arity.propogate_beta_reduce
                                       meta params body args)
                              | _ ->
                                  Lapply
                                    ((simpl l1), (List.map simpl args), info))
              | Lapply ((Lvar v as l1),args,info) ->
                  (match Hashtbl.find meta.ident_tbl v with
                   | Function
                       { lambda = Lfunction (Curried ,params,body);
                         arity = Determin (_,(n,_)::_,_);_}
                       when
                       ((List.length args) = n) &&
                         (Lam_inline_util.maybe_functor v.name)
                       ->
                       simpl @@
                         (Lam_pass_alpha_with_arity.propogate_beta_reduce
                            meta params body args)
                   | exception Not_found  ->
                       Lapply ((simpl l1), (List.map simpl args), info)
                   | _ -> Lapply ((simpl l1), (List.map simpl args), info))
              | Lapply (Lfunction (Curried ,params,body),args,_) when
                  (List.length params) = (List.length args) ->
                  simpl
                    (Lam_pass_alpha_with_arity.propogate_beta_reduce meta
                       params body args)
              | Lapply
                  (Lfunction (Tupled ,params,body),(Lprim
                   (Pmakeblock _,args))::[],_)
                  when (List.length params) = (List.length args) ->
                  simpl
                    (Lam_pass_alpha_with_arity.propogate_beta_reduce meta
                       params body args)
              | Lapply (l1,ll,info) ->
                  Lapply ((simpl l1), (List.map simpl ll), info)
              | Lfunction (kind,params,l) ->
                  Lfunction (kind, params, (simpl l))
              | Lswitch
                  (l,{ sw_failaction; sw_consts; sw_blocks; sw_numblocks;
                       sw_numconsts })
                  ->
                  Lswitch
                    ((simpl l),
                      {
                        sw_consts =
                          (List.map (fun (v,l)  -> (v, (simpl l))) sw_consts);
                        sw_blocks =
                          (List.map (fun (v,l)  -> (v, (simpl l))) sw_blocks);
                        sw_numconsts;
                        sw_numblocks;
                        sw_failaction =
                          ((match sw_failaction with
                            | None  -> None
                            | Some x -> Some (simpl x)))
                      })
              | Lstringswitch (l,sw,d) ->
                  Lstringswitch
                    ((simpl l), (List.map (fun (i,l)  -> (i, (simpl l))) sw),
                      ((match d with
                        | Some d -> Some (simpl d)
                        | None  -> None)))
              | Lstaticraise (i,ls) -> Lstaticraise (i, (List.map simpl ls))
              | Lstaticcatch (l1,(i,x),l2) ->
                  Lstaticcatch ((simpl l1), (i, x), (simpl l2))
              | Ltrywith (l1,v,l2) -> Ltrywith ((simpl l1), v, (simpl l2))
              | Lifthenelse (l1,l2,l3) ->
                  Lifthenelse ((simpl l1), (simpl l2), (simpl l3))
              | Lsequence (Lprim (Pgetglobal id,[]),l2) when
                  Lam_compile_env.is_pure (Lam_module_ident.of_ml id)
                    meta.env
                  -> simpl l2
              | Lsequence (l1,l2) -> Lsequence ((simpl l1), (simpl l2))
              | Lwhile (l1,l2) -> Lwhile ((simpl l1), (simpl l2))
              | Lfor (flag,l1,l2,dir,l3) ->
                  Lfor (flag, (simpl l1), (simpl l2), dir, (simpl l3))
              | Lassign (v,l) -> Lassign (v, (simpl l))
              | Lsend (u,m,o,ll,v) ->
                  Lsend (u, (simpl m), (simpl o), (List.map simpl ll), v)
              | Levent (l,event) -> Levent ((simpl l), event)
              | Lifused (v,l) -> Lifused (v, (simpl l)) : Lambda.lambda) in
           simpl lam : Lambda.lambda)
      end 
    module Lam_pass_lets_dce :
      sig
        val simplify_lets : Lambda.lambda -> Lambda.lambda[@@ocaml.doc
                                                            "\n   This pass would do beta reduction, and dead code elimination (adapted from compiler's built-in [Simplif] module )\n\n   1. beta reduction -> Llet (Strict )\n  \n   2. The global table [occ] associates to each let-bound identifier\n   the number of its uses (as a reference):\n     - 0 if never used\n     - 1 if used exactly once in and *not under a lambda or within a loop\n     - > 1 if used several times or under a lambda or within a loop.\n\n   The local table [bv] associates to each locally-let-bound variable\n   its reference count, as above.  [bv] is enriched at let bindings\n   but emptied when crossing lambdas and loops. \n\n   For this pass, when it' used under a lambda or within a loop, we don't do anything,\n   in theory, we can still do something if it's pure but we are conservative here.\n\n   [bv] is used to help caculate [occ] it is not useful outside\n\n "]
      end =
      struct
        open Asttypes
        exception Real_reference
        let rec eliminate_ref id (lam : Lambda.lambda) =
          match lam with
          | Lvar v -> if Ident.same v id then raise Real_reference else lam
          | Lprim (Pfield 0,(Lvar v)::[]) when Ident.same v id -> Lvar id
          | Lfunction (kind,params,body) as lam ->
              if Lambda.IdentSet.mem id (Lambda.free_variables lam)
              then raise Real_reference
              else lam
          | Lprim (Psetfield (0,_),(Lvar v)::e::[]) when Ident.same v id ->
              Lassign (id, (eliminate_ref id e))
          | Lprim (Poffsetref delta,(Lvar v)::[]) when Ident.same v id ->
              Lassign (id, (Lprim ((Poffsetint delta), [Lvar id])))
          | Lconst _ -> lam
          | Lapply (e1,el,loc) ->
              Lapply
                ((eliminate_ref id e1), (List.map (eliminate_ref id) el),
                  loc)
          | Llet (str,v,e1,e2) ->
              Llet (str, v, (eliminate_ref id e1), (eliminate_ref id e2))
          | Lletrec (idel,e2) ->
              Lletrec
                ((List.map (fun (v,e)  -> (v, (eliminate_ref id e))) idel),
                  (eliminate_ref id e2))
          | Lprim (p,el) -> Lprim (p, (List.map (eliminate_ref id) el))
          | Lswitch (e,sw) ->
              Lswitch
                ((eliminate_ref id e),
                  {
                    sw_numconsts = (sw.sw_numconsts);
                    sw_consts =
                      (List.map (fun (n,e)  -> (n, (eliminate_ref id e)))
                         sw.sw_consts);
                    sw_numblocks = (sw.sw_numblocks);
                    sw_blocks =
                      (List.map (fun (n,e)  -> (n, (eliminate_ref id e)))
                         sw.sw_blocks);
                    sw_failaction =
                      (Misc.may_map (eliminate_ref id) sw.sw_failaction)
                  })
          | Lstringswitch (e,sw,default) ->
              Lstringswitch
                ((eliminate_ref id e),
                  (List.map (fun (s,e)  -> (s, (eliminate_ref id e))) sw),
                  (Misc.may_map (eliminate_ref id) default))
          | Lstaticraise (i,args) ->
              Lstaticraise (i, (List.map (eliminate_ref id) args))
          | Lstaticcatch (e1,i,e2) ->
              Lstaticcatch ((eliminate_ref id e1), i, (eliminate_ref id e2))
          | Ltrywith (e1,v,e2) ->
              Ltrywith ((eliminate_ref id e1), v, (eliminate_ref id e2))
          | Lifthenelse (e1,e2,e3) ->
              Lifthenelse
                ((eliminate_ref id e1), (eliminate_ref id e2),
                  (eliminate_ref id e3))
          | Lsequence (e1,e2) ->
              Lsequence ((eliminate_ref id e1), (eliminate_ref id e2))
          | Lwhile (e1,e2) ->
              Lwhile ((eliminate_ref id e1), (eliminate_ref id e2))
          | Lfor (v,e1,e2,dir,e3) ->
              Lfor
                (v, (eliminate_ref id e1), (eliminate_ref id e2), dir,
                  (eliminate_ref id e3))
          | Lassign (v,e) -> Lassign (v, (eliminate_ref id e))
          | Lsend (k,m,o,el,loc) ->
              Lsend
                (k, (eliminate_ref id m), (eliminate_ref id o),
                  (List.map (eliminate_ref id) el), loc)
          | Levent (l,ev) -> Levent ((eliminate_ref id l), ev)
          | Lifused (v,e) -> Lifused (v, (eliminate_ref id e))
        type used_info = {
          mutable times: int;
          mutable captured: bool;}
        type occ_tbl = (Ident.t,used_info) Hashtbl.t
        type local_tbl = used_info Ident_map.t
        let dummy_info () = { times = 0; captured = false }
        let absorb_info (x : used_info) (y : used_info) =
          match (x, y) with
          | ({ times = x0 },{ times = y0; captured }) ->
              (x.times <- x0 + y0; if captured then x.captured <- true)
        let lets_helper (count_var : Ident.t -> used_info) lam =
          let subst = Hashtbl.create 31 in
          let used v = (count_var v).times > 0 in
          let rec simplif (lam : Lambda.lambda) =
            match lam with
            | Lvar v -> (try Hashtbl.find subst v with | Not_found  -> lam)
            | Llet ((Strict |Alias |StrictOpt ),v,Lvar w,l2) ->
                (Hashtbl.add subst v (simplif (Lvar w)); simplif l2)
            | Llet
                ((Strict |StrictOpt  as kind),v,Lprim
                 ((Pmakeblock (0,tag_info,Mutable ) as prim),linit::[]),lbody)
                ->
                let slinit = simplif linit in
                let slbody = simplif lbody in
                (try
                   Lam_util.refine_let ~kind:Variable v slinit
                     (eliminate_ref v slbody)
                 with
                 | Real_reference  ->
                     Lam_util.refine_let ~kind v (Lprim (prim, [slinit]))
                       slbody)
            | Llet (Alias ,v,l1,l2) ->
                (match ((count_var v), l1) with
                 | ({ times = 0;_},_) -> simplif l2
                 | ({ times = 1; captured = false  },_)
                   |({ times = 1; captured = true  },(Lconst _|Lvar _)) ->
                     (Hashtbl.add subst v (simplif l1); simplif l2)
                 | _ -> Llet (Alias, v, (simplif l1), (simplif l2)))
            | Llet ((StrictOpt  as kind),v,l1,l2) ->
                if not @@ (used v)
                then simplif l2
                else Lam_util.refine_let ~kind v (simplif l1) (simplif l2)
            | Llet ((Strict |Variable  as kind),v,l1,l2) ->
                if not @@ (used v)
                then
                  let l1 = simplif l1 in
                  let l2 = simplif l2 in
                  (if Lam_util.no_side_effects l1
                   then l2
                   else Lsequence (l1, l2))
                else Lam_util.refine_let ~kind v (simplif l1) (simplif l2)
            | Lifused (v,l) ->
                if used v then simplif l else Lambda.lambda_unit
            | Lsequence (Lifused (v,l1),l2) ->
                if used v
                then Lsequence ((simplif l1), (simplif l2))
                else simplif l2
            | Lsequence (l1,l2) -> Lsequence ((simplif l1), (simplif l2))
            | Lapply (Lfunction (Curried ,params,body),args,_) when
                Ext_list.same_length params args ->
                simplif (Lam_util.beta_reduce params body args)
            | Lapply
                (Lfunction (Tupled ,params,body),(Lprim
                 (Pmakeblock _,args))::[],_)
                when Ext_list.same_length params args ->
                simplif (Lam_util.beta_reduce params body args)
            | Lapply (l1,ll,loc) ->
                Lapply ((simplif l1), (List.map simplif ll), loc)
            | Lfunction (kind,params,l) ->
                Lfunction (kind, params, (simplif l))
            | Lconst _ -> lam
            | Lletrec (bindings,body) ->
                Lletrec
                  ((List.map (fun (v,l)  -> (v, (simplif l))) bindings),
                    (simplif body))
            | Lprim (p,ll) -> Lprim (p, (List.map simplif ll))
            | Lswitch (l,sw) ->
                let new_l = simplif l
                and new_consts =
                  List.map (fun (n,e)  -> (n, (simplif e))) sw.sw_consts
                and new_blocks =
                  List.map (fun (n,e)  -> (n, (simplif e))) sw.sw_blocks
                and new_fail = Misc.may_map simplif sw.sw_failaction in
                Lswitch
                  (new_l,
                    {
                      sw with
                      sw_consts = new_consts;
                      sw_blocks = new_blocks;
                      sw_failaction = new_fail
                    })
            | Lstringswitch (l,sw,d) ->
                Lstringswitch
                  ((simplif l),
                    (List.map (fun (s,l)  -> (s, (simplif l))) sw),
                    (Misc.may_map simplif d))
            | Lstaticraise (i,ls) -> Lstaticraise (i, (List.map simplif ls))
            | Lstaticcatch (l1,(i,args),l2) ->
                Lstaticcatch ((simplif l1), (i, args), (simplif l2))
            | Ltrywith (l1,v,l2) -> Ltrywith ((simplif l1), v, (simplif l2))
            | Lifthenelse (l1,l2,l3) ->
                Lifthenelse ((simplif l1), (simplif l2), (simplif l3))
            | Lwhile (l1,l2) -> Lwhile ((simplif l1), (simplif l2))
            | Lfor (v,l1,l2,dir,l3) ->
                Lfor (v, (simplif l1), (simplif l2), dir, (simplif l3))
            | Lassign (v,l) -> Lassign (v, (simplif l))
            | Lsend (k,m,o,ll,loc) ->
                Lsend
                  (k, (simplif m), (simplif o), (List.map simplif ll), loc)
            | Levent (l,ev) -> Levent ((simplif l), ev) in
          simplif lam
        let apply_lets occ lambda =
          let count_var v =
            try Hashtbl.find occ v with | Not_found  -> dummy_info () in
          lets_helper count_var lambda
        let collect_occurs lam =
          (let occ: occ_tbl = Hashtbl.create 83 in
           let used v =
             match Hashtbl.find occ v with
             | exception Not_found  -> false
             | { times;_} -> times > 0 in
           let bind_var bv ident =
             let r = dummy_info () in
             Hashtbl.add occ ident r; Ident_map.add ident r bv in
           let add_one_use bv ident =
             match Ident_map.find ident bv with
             | r -> r.times <- r.times + 1
             | exception Not_found  ->
                 (match Hashtbl.find occ ident with
                  | r -> absorb_info r { times = 1; captured = true }
                  | exception Not_found  -> ()) in
           let inherit_use bv ident bid =
             let n =
               try Hashtbl.find occ bid with | Not_found  -> dummy_info () in
             match Ident_map.find ident bv with
             | r -> absorb_info r n
             | exception Not_found  ->
                 (match Hashtbl.find occ ident with
                  | r -> absorb_info r { n with captured = true }
                  | exception Not_found  -> ()) in
           let rec count (bv : local_tbl) (lam : Lambda.lambda) =
             match lam with
             | Lfunction (kind,params,l) -> count Ident_map.empty l
             | Lvar v -> add_one_use bv v
             | Llet (_,v,Lvar w,l2) ->
                 (count (bind_var bv v) l2; inherit_use bv w v)
             | Llet (kind,v,l1,l2) ->
                 (count (bind_var bv v) l2;
                  if (kind = Strict) || (used v) then count bv l1)
             | Lprim (_,ll) -> List.iter (count bv) ll
             | Lletrec (bindings,body) ->
                 (List.iter (fun (v,l)  -> count bv l) bindings;
                  count bv body)
             | Lapply (Lfunction (Curried ,params,body),args,_) when
                 Ext_list.same_length params args ->
                 count bv (Lam_util.beta_reduce params body args)
             | Lapply
                 (Lfunction (Tupled ,params,body),(Lprim
                  (Pmakeblock _,args))::[],_)
                 when Ext_list.same_length params args ->
                 count bv (Lam_util.beta_reduce params body args)
             | Lapply (l1,ll,_) -> (count bv l1; List.iter (count bv) ll)
             | Lassign (_,l) -> count bv l
             | Lconst cst -> ()
             | Lswitch (l,sw) ->
                 (count_default bv sw;
                  count bv l;
                  List.iter (fun (_,l)  -> count bv l) sw.sw_consts;
                  List.iter (fun (_,l)  -> count bv l) sw.sw_blocks)
             | Lstringswitch (l,sw,d) ->
                 (count bv l;
                  List.iter (fun (_,l)  -> count bv l) sw;
                  (match d with | Some d -> count bv d | None  -> ()))
             | Lstaticraise (i,ls) -> List.iter (count bv) ls
             | Lstaticcatch (l1,(i,_),l2) -> (count bv l1; count bv l2)
             | Ltrywith (l1,v,l2) -> (count bv l1; count bv l2)
             | Lifthenelse (l1,l2,l3) ->
                 (count bv l1; count bv l2; count bv l3)
             | Lsequence (l1,l2) -> (count bv l1; count bv l2)
             | Lwhile (l1,l2) ->
                 (count Ident_map.empty l1; count Ident_map.empty l2)
             | Lfor (_,l1,l2,dir,l3) ->
                 (count bv l1; count bv l2; count Ident_map.empty l3)
             | Lsend (_,m,o,ll,_) -> List.iter (count bv) (m :: o :: ll)
             | Levent (l,_) -> count bv l
             | Lifused (v,l) -> if used v then count bv l
           and count_default bv sw =
             match sw.sw_failaction with
             | None  -> ()
             | Some al ->
                 let nconsts = List.length sw.sw_consts
                 and nblocks = List.length sw.sw_blocks in
                 if
                   (nconsts < sw.sw_numconsts) && (nblocks < sw.sw_numblocks)
                 then (count bv al; count bv al)
                 else
                   (assert
                      ((nconsts < sw.sw_numconsts) ||
                         (nblocks < sw.sw_numblocks));
                    count bv al) in
           count Ident_map.empty lam; occ : occ_tbl)
        let simplify_lets (lam : Lambda.lambda) =
          let occ = collect_occurs lam in apply_lets occ lam
      end 
    module Lam_pass_exits :
      sig
        [@@@ocaml.text
          " A pass used to optimize the exit code compilation, adaped from the compiler's\n    [simplif] module\n "]
        val count_helper : Lambda.lambda -> (int,int ref) Hashtbl.t
        type subst_tbl = (int,(Ident.t list* Lambda.lambda)) Hashtbl.t
        val subst_helper :
          subst_tbl -> (int -> int) -> Lambda.lambda -> Lambda.lambda
        val simplify_exits : Lambda.lambda -> Lambda.lambda
      end =
      struct
        let count_exit exits i =
          try !(Hashtbl.find exits i) with | Not_found  -> 0
        and incr_exit exits i =
          try incr (Hashtbl.find exits i)
          with | Not_found  -> Hashtbl.add exits i (ref 1)
        let count_helper (lam : Lambda.lambda) =
          (let exits = Hashtbl.create 17 in
           let rec count (lam : Lambda.lambda) =
             match lam with
             | Lstaticraise (i,ls) -> (incr_exit exits i; List.iter count ls)
             | Lstaticcatch (l1,(i,[]),Lstaticraise (j,[])) ->
                 (count l1;
                  (let ic = count_exit exits i in
                   try let r = Hashtbl.find exits j in r := ((!r) + ic)
                   with | Not_found  -> Hashtbl.add exits j (ref ic)))
             | Lstaticcatch (l1,(i,_),l2) ->
                 (count l1; if (count_exit exits i) > 0 then count l2)
             | Lstringswitch (l,sw,d) ->
                 (count l;
                  List.iter (fun (_,l)  -> count l) sw;
                  (match d with | None  -> () | Some d -> count d))
             | Lvar _|Lconst _ -> ()
             | Lapply (l1,ll,_) -> (count l1; List.iter count ll)
             | Lfunction (_,_,l) -> count l
             | Llet (_,_,l1,l2) -> (count l2; count l1)
             | Lletrec (bindings,body) ->
                 (List.iter (fun (_,l)  -> count l) bindings; count body)
             | Lprim (_,ll) -> List.iter count ll
             | Lswitch (l,sw) ->
                 (count_default sw;
                  count l;
                  List.iter (fun (_,l)  -> count l) sw.sw_consts;
                  List.iter (fun (_,l)  -> count l) sw.sw_blocks)
             | Ltrywith (l1,v,l2) -> (count l1; count l2)
             | Lifthenelse (l1,l2,l3) -> (count l1; count l2; count l3)
             | Lsequence (l1,l2) -> (count l1; count l2)
             | Lwhile (l1,l2) -> (count l1; count l2)
             | Lfor (_,l1,l2,dir,l3) -> (count l1; count l2; count l3)
             | Lassign (_,l) -> count l
             | Lsend (_,m,o,ll,_) -> (count m; count o; List.iter count ll)
             | Levent (l,_) -> count l
             | Lifused (_,l) -> count l
           and count_default sw =
             match sw.sw_failaction with
             | None  -> ()
             | Some al ->
                 let nconsts = List.length sw.sw_consts
                 and nblocks = List.length sw.sw_blocks in
                 if
                   (nconsts < sw.sw_numconsts) && (nblocks < sw.sw_numblocks)
                 then (count al; count al)
                 else
                   (assert
                      ((nconsts < sw.sw_numconsts) ||
                         (nblocks < sw.sw_numblocks));
                    count al) in
           count lam; exits : (int,int ref) Hashtbl.t)
        type subst_tbl = (int,(Ident.t list* Lambda.lambda)) Hashtbl.t
        let subst_helper (subst : subst_tbl) query lam =
          let rec simplif (lam : Lambda.lambda) =
            match lam with
            | Lstaticraise (i,[]) ->
                (match Hashtbl.find subst i with
                 | (_,handler) -> handler
                 | exception Not_found  -> lam)
            | Lstaticraise (i,ls) ->
                let ls = List.map simplif ls in
                (match Hashtbl.find subst i with
                 | (xs,handler) ->
                     let ys = List.map Ident.rename xs in
                     let env =
                       List.fold_right2
                         (fun x  ->
                            fun y  -> fun t  -> Ident.add x (Lambda.Lvar y) t)
                         xs ys Ident.empty in
                     List.fold_right2
                       (fun y  ->
                          fun l  -> fun r  -> Lambda.Llet (Alias, y, l, r))
                       ys ls (Lambda.subst_lambda env handler)
                 | exception Not_found  -> Lstaticraise (i, ls))
            | Lstaticcatch (l1,(i,[]),(Lstaticraise (j,[]) as l2)) ->
                (Hashtbl.add subst i ([], (simplif l2)); simplif l1)
            | Lstaticcatch (l1,(i,xs),l2) ->
                (match ((query i), l2) with
                 | (0,_) -> simplif l1
                 | (_,Lvar _)|(_,Lconst _) ->
                     (Hashtbl.add subst i (xs, (simplif l2)); simplif l1)
                 | (1,_) when i >= 0 ->
                     (Hashtbl.add subst i (xs, (simplif l2)); simplif l1)
                 | (j,_) ->
                     let ok_to_inline =
                       ((Lam_util.size l2) < 5) && ((i >= 0) && (j <= 2)) in
                     if ok_to_inline
                     then
                       (Hashtbl.add subst i (xs, (simplif l2)); simplif l1)
                     else Lstaticcatch ((simplif l1), (i, xs), (simplif l2)))
            | Lvar _|Lconst _ -> lam
            | Lapply (l1,ll,loc) ->
                Lapply ((simplif l1), (List.map simplif ll), loc)
            | Lfunction (kind,params,l) ->
                Lfunction (kind, params, (simplif l))
            | Llet (kind,v,l1,l2) ->
                Llet (kind, v, (simplif l1), (simplif l2))
            | Lletrec (bindings,body) ->
                Lletrec
                  ((List.map (fun (v,l)  -> (v, (simplif l))) bindings),
                    (simplif body))
            | Lprim (p,ll) ->
                let ll = List.map simplif ll in
                (match (p, ll) with
                 | (Prevapply loc,x::(Lapply (f,args,_))::[])
                   |(Prevapply loc,x::(Levent (Lapply (f,args,_),_))::[]) ->
                     Lapply
                       (f, (args @ [x]), (Lambda.default_apply_info ~loc ()))
                 | (Prevapply loc,x::f::[]) ->
                     Lapply (f, [x], (Lambda.default_apply_info ~loc ()))
                 | (Pdirapply loc,(Lapply (f,args,_))::x::[])
                   |(Pdirapply loc,(Levent (Lapply (f,args,_),_))::x::[]) ->
                     Lapply
                       (f, (args @ [x]), (Lambda.default_apply_info ~loc ()))
                 | (Pdirapply loc,f::x::[]) ->
                     Lapply (f, [x], (Lambda.default_apply_info ~loc ()))
                 | _ -> Lprim (p, ll))
            | Lswitch (l,sw) ->
                let new_l = simplif l
                and new_consts =
                  List.map (fun (n,e)  -> (n, (simplif e))) sw.sw_consts
                and new_blocks =
                  List.map (fun (n,e)  -> (n, (simplif e))) sw.sw_blocks
                and new_fail = Misc.may_map simplif sw.sw_failaction in
                Lswitch
                  (new_l,
                    {
                      sw with
                      sw_consts = new_consts;
                      sw_blocks = new_blocks;
                      sw_failaction = new_fail
                    })
            | Lstringswitch (l,sw,d) ->
                Lstringswitch
                  ((simplif l),
                    (List.map (fun (s,l)  -> (s, (simplif l))) sw),
                    (Misc.may_map simplif d))
            | Ltrywith (l1,v,l2) -> Ltrywith ((simplif l1), v, (simplif l2))
            | Lifthenelse (l1,l2,l3) ->
                Lifthenelse ((simplif l1), (simplif l2), (simplif l3))
            | Lsequence (l1,l2) -> Lsequence ((simplif l1), (simplif l2))
            | Lwhile (l1,l2) -> Lwhile ((simplif l1), (simplif l2))
            | Lfor (v,l1,l2,dir,l3) ->
                Lfor (v, (simplif l1), (simplif l2), dir, (simplif l3))
            | Lassign (v,l) -> Lassign (v, (simplif l))
            | Lsend (k,m,o,ll,loc) ->
                Lsend
                  (k, (simplif m), (simplif o), (List.map simplif ll), loc)
            | Levent (l,ev) -> Levent ((simplif l), ev)
            | Lifused (v,l) -> Lifused (v, (simplif l)) in
          simplif lam
        let simplify_exits (lam : Lambda.lambda) =
          let exits = count_helper lam in
          subst_helper (Hashtbl.create 17) (count_exit exits) lam
      end 
    module Lam_pass_collect :
      sig
        [@@@ocaml.text
          " This pass is used to collect meta data information.\n\n    It includes:\n    alias table, arity for identifiers and might more information,\n    \n    ATTENTION:\n    For later pass to keep its information complete and up to date,\n    we  need update its table accordingly\n\n    - Alias inference is not for substitution, it is for analyze which module is \n      actually a global module or an exception, so it can be relaxed a bit\n      (without relying on strict analysis)\n\n    - Js object (local) analysis \n\n    Design choice:\n\n    Side effectful operations:\n       - Lassign \n       - Psetfield\n\n    1. What information should be collected:\n\n    2. What's the key\n       If it's identifier, \n       \n    Information that is always sound, not subject to change \n\n    - shall we collect that if an identifier is passed as a parameter, (useful for escape analysis), \n    however, since it's going to change after inlning (for local function)\n\n    - function arity, subject to change when you make it a mutable ref and change it later\n    \n    - Immutable blocks of identifiers\n     \n      if identifier itself is function/non block then the access can be inlined \n      if identifier itself is immutable block can be inlined\n      if identifier is mutable block can be inlined (without Lassign) since\n\n    - When collect some information, shall we propogate this information to \n      all alias table immeidately\n\n      - annotation identifiers (at first time)\n      -\n "]
        val collect_helper : Lam_stats.meta -> Lambda.lambda -> unit
        val count_alias_globals :
          Env.t -> string -> Ident.t list -> Lambda.lambda -> Lam_stats.meta
      end =
      struct
        let annotate (meta : Lam_stats.meta) (k : Ident.t)
          (v : Lam_stats.function_arities) lambda =
          match Hashtbl.find meta.ident_tbl k with
          | exception Not_found  ->
              Hashtbl.add meta.ident_tbl k
                (Function { kind = NA; arity = v; lambda })
          | Function old -> old.arity <- v
          | _ -> assert false
        let collect_helper (meta : Lam_stats.meta) (lam : Lambda.lambda) =
          let rec collect_bind (kind : Lambda.let_kind) (ident : Ident.t)
            (lam : Lambda.lambda) =
            match lam with
            | Lconst v -> Hashtbl.replace meta.ident_tbl ident (Constant v)
            | Lprim (Pmakeblock (_,_,Immutable ),ls) ->
                Hashtbl.replace meta.ident_tbl ident
                  (Lam_util.kind_of_lambda_block ls)
            | Lprim (Pgetglobal v,[]) ->
                (Lam_util.alias meta ident v (Module v) kind;
                 (match kind with
                  | Alias  -> ()
                  | Strict |StrictOpt |Variable  ->
                      Lam_util.add_required_module v meta))
            | Lvar v -> Lam_util.alias meta ident v NA kind
            | Lfunction (_,params,l) ->
                (List.iter (fun p  -> Hashtbl.add meta.ident_tbl p Parameter)
                   params;
                 annotate meta ident (Lam_stats_util.get_arity meta lam) lam;
                 collect l)
            | x ->
                (collect x;
                 if List.mem ident meta.export_idents
                 then
                   annotate meta ident (Lam_stats_util.get_arity meta x) lam)
          and collect (lam : Lambda.lambda) =
            match lam with
            | Lconst _ -> ()
            | Lvar _ -> ()
            | Lapply (l1,ll,_) -> (collect l1; List.iter collect ll)
            | Lfunction (_kind,params,l) ->
                (List.iter (fun p  -> Hashtbl.add meta.ident_tbl p Parameter)
                   params;
                 collect l)
            | Llet (kind,ident,arg,body) ->
                (collect_bind kind ident arg; collect body)
            | Lletrec (bindings,body) ->
                (List.iter
                   (fun (ident,arg)  -> collect_bind Strict ident arg)
                   bindings;
                 collect body)
            | Lprim (_p,ll) -> List.iter collect ll
            | Lswitch (l,{ sw_failaction; sw_consts; sw_blocks }) ->
                (collect l;
                 List.iter (fun (_,l)  -> collect l) sw_consts;
                 List.iter (fun (_,l)  -> collect l) sw_blocks;
                 (match sw_failaction with
                  | None  -> ()
                  | Some x -> collect x))
            | Lstringswitch (l,sw,d) ->
                (collect l;
                 List.iter (fun (_,l)  -> collect l) sw;
                 (match d with | Some d -> collect d | None  -> ()))
            | Lstaticraise (code,ls) ->
                (Hash_set.add meta.exit_codes code; List.iter collect ls)
            | Lstaticcatch (l1,(_,_),l2) -> (collect l1; collect l2)
            | Ltrywith (l1,_,l2) -> (collect l1; collect l2)
            | Lifthenelse (l1,l2,l3) -> (collect l1; collect l2; collect l3)
            | Lsequence (l1,l2) -> (collect l1; collect l2)
            | Lwhile (l1,l2) -> (collect l1; collect l2)
            | Lfor (_,l1,l2,dir,l3) -> (collect l1; collect l2; collect l3)
            | Lassign (v,l) -> collect l
            | Lsend (_,m,o,ll,_) -> List.iter collect (m :: o :: ll)
            | Levent (l,_) -> collect l
            | Lifused (_,l) -> collect l in
          collect lam[@@ocaml.doc
                       " it only make senses recording arities for \n    function definition,\n    alias propgation - and toplevel identifiers, this needs to be exported\n "]
        let count_alias_globals env filename export_idents
          (lam : Lambda.lambda) =
          (let meta: Lam_stats.meta =
             {
               alias_tbl = (Hashtbl.create 31);
               ident_tbl = (Hashtbl.create 31);
               exit_codes = (Hash_set.create 31);
               unused_exit_code = 0;
               exports = export_idents;
               required_modules = [];
               filename;
               env;
               export_idents
             } in
           collect_helper meta lam;
           meta.unused_exit_code <-
             Lam_stats_util.find_unused_exit_code meta.exit_codes;
           meta : Lam_stats.meta)
      end 
    module Lam_pass_alpha_conversion :
      sig
        [@@@ocaml.text " alpha conversion based on arity "]
        val alpha_conversion :
          Lam_stats.meta -> Lambda.lambda -> Lambda.lambda
      end =
      struct
        let alpha_conversion (meta : Lam_stats.meta) (lam : Lambda.lambda) =
          (let rec simpl (lam : Lambda.lambda) =
             match lam with
             | Lconst _ -> lam
             | Lvar _ -> lam
             | Lapply (l1,ll,info) ->
                 (match Lam_stats_util.get_arity meta l1 with
                  | NA  -> Lapply ((simpl l1), (List.map simpl ll), info)
                  | Determin (b,args,tail) ->
                      let len = List.length ll in
                      let rec take args =
                        match args with
                        | (x,_)::xs ->
                            if x = len
                            then
                              Lambda.Lapply
                                ((simpl l1), (List.map simpl ll),
                                  { info with apply_status = Full })
                            else
                              if x > len
                              then
                                (let extra_args =
                                   Ext_list.init (x - len)
                                     (fun _  -> Ident.create "param") in
                                 Lfunction
                                   (Curried, extra_args,
                                     (Lapply
                                        ((simpl l1),
                                          ((List.map simpl ll) @
                                             (List.map
                                                (fun x  -> Lambda.Lvar x)
                                                extra_args)),
                                          { info with apply_status = Full }))))
                              else
                                (let (first,rest) = Ext_list.take x ll in
                                 Lapply
                                   ((Lapply
                                       ((simpl l1), (List.map simpl first),
                                         { info with apply_status = Full })),
                                     (List.map simpl rest), info))
                        | _ -> Lapply ((simpl l1), (List.map simpl ll), info) in
                      take args)
             | Llet (str,v,l1,l2) -> Llet (str, v, (simpl l1), (simpl l2))
             | Lletrec (bindings,body) ->
                 let bindings =
                   List.map (fun (k,l)  -> (k, (simpl l))) bindings in
                 Lletrec (bindings, (simpl body))
             | Lprim (prim,ll) -> Lprim (prim, (List.map simpl ll))
             | Lfunction (kind,params,l) ->
                 Lfunction (kind, params, (simpl l))
             | Lswitch
                 (l,{ sw_failaction; sw_consts; sw_blocks; sw_numblocks;
                      sw_numconsts })
                 ->
                 Lswitch
                   ((simpl l),
                     {
                       sw_consts =
                         (List.map (fun (v,l)  -> (v, (simpl l))) sw_consts);
                       sw_blocks =
                         (List.map (fun (v,l)  -> (v, (simpl l))) sw_blocks);
                       sw_numconsts;
                       sw_numblocks;
                       sw_failaction =
                         ((match sw_failaction with
                           | None  -> None
                           | Some x -> Some (simpl x)))
                     })
             | Lstringswitch (l,sw,d) ->
                 Lstringswitch
                   ((simpl l), (List.map (fun (i,l)  -> (i, (simpl l))) sw),
                     ((match d with
                       | Some d -> Some (simpl d)
                       | None  -> None)))
             | Lstaticraise (i,ls) -> Lstaticraise (i, (List.map simpl ls))
             | Lstaticcatch (l1,(i,x),l2) ->
                 Lstaticcatch ((simpl l1), (i, x), (simpl l2))
             | Ltrywith (l1,v,l2) -> Ltrywith ((simpl l1), v, (simpl l2))
             | Lifthenelse (l1,l2,l3) ->
                 Lifthenelse ((simpl l1), (simpl l2), (simpl l3))
             | Lsequence (l1,l2) -> Lsequence ((simpl l1), (simpl l2))
             | Lwhile (l1,l2) -> Lwhile ((simpl l1), (simpl l2))
             | Lfor (flag,l1,l2,dir,l3) ->
                 Lfor (flag, (simpl l1), (simpl l2), dir, (simpl l3))
             | Lassign (v,l) -> Lassign (v, (simpl l))
             | Lsend (u,m,o,ll,v) ->
                 Lsend (u, (simpl m), (simpl o), (List.map simpl ll), v)
             | Levent (l,event) -> Levent ((simpl l), event)
             | Lifused (v,l) -> Lifused (v, (simpl l)) in
           simpl lam : Lambda.lambda)
      end 
    module Js_shake :
      sig
        [@@@ocaml.text
          " A module to shake JS IR\n   \n    Tree shaking is not going to change the closure \n "]
        val shake_program : J.program -> J.program
      end =
      struct
        let get_initial_exports count_non_variable_declaration_statement
          (export_set : Ident_set.t) (block : J.block) =
          let result =
            List.fold_left
              (fun acc  ->
                 fun (st : J.statement)  ->
                   match st.statement_desc with
                   | Variable { ident; value;_} ->
                       if Ident_set.mem ident acc
                       then
                         (match value with
                          | None  -> acc
                          | Some x ->
                              let open Ident_set in
                                union
                                  (Js_analyzer.free_variables_of_expression
                                     empty empty x) acc)
                       else
                         (match value with
                          | None  -> acc
                          | Some x ->
                              if Js_analyzer.no_side_effect_expression x
                              then acc
                              else
                                let open Ident_set in
                                  union
                                    (Js_analyzer.free_variables_of_expression
                                       empty empty x) (add ident acc))
                   | _ ->
                       if
                         (Js_analyzer.no_side_effect_statement st) ||
                           (not count_non_variable_declaration_statement)
                       then acc
                       else
                         let open Ident_set in
                           union
                             (Js_analyzer.free_variables_of_statement empty
                                empty st) acc) export_set block in
          (result, (let open Ident_set in diff result export_set))[@@ocaml.doc
                                                                    " we also need make it complete \n "]
        let shake_program (program : J.program) =
          let debug_file = "pervasives.ml" in
          let _d () =
            if Ext_string.ends_with program.name debug_file
            then Ext_log.err __LOC__ "@[%s@]@." program.name in
          let shake_block block export_set =
            let block = List.rev @@ (Js_analyzer.rev_toplevel_flatten block) in
            let loop block export_set =
              (let rec aux acc block =
                 let (result,diff) = get_initial_exports false acc block in
                 if Ident_set.is_empty diff then result else aux result block in
               let (first_iteration,delta) =
                 get_initial_exports true export_set block in
               if not @@ (Ident_set.is_empty delta)
               then aux first_iteration block
               else first_iteration : Ident_set.t) in
            let really_set = loop block export_set in
            List.fold_right
              (fun (st : J.statement)  ->
                 fun acc  ->
                   match st.statement_desc with
                   | Variable { ident; value;_} ->
                       if Ident_set.mem ident really_set
                       then st :: acc
                       else
                         (match value with
                          | None  -> acc
                          | Some x ->
                              if Js_analyzer.no_side_effect_expression x
                              then acc
                              else st :: acc)
                   | _ ->
                       if Js_analyzer.no_side_effect_statement st
                       then acc
                       else st :: acc) block [] in
          {
            program with
            block = (shake_block program.block program.export_set)
          }
      end 
    module Ext_filename :
      sig
        [@@@ocaml.text
          " An extension module to calculate relative path follow node/npm style. \n    TODO : this short name will have to change upon renaming the file.\n "]
        [@@@ocaml.text
          " Js_output is node style, which means \n    separator is only '/'\n    TODO: handle [node_modules]\n "]
        val node_relative_path : string -> string -> string[@@ocaml.doc
                                                             " TODO Change the module name, this code is not really an extension of the standard \n    library but rather specific to JS Module name convention. \n  "]
      end =
      struct
        let node_sep = "/"[@@ocaml.doc
                            " Used when produce node compatible paths "]
        let node_parent = ".."
        let node_current = "."
        let absolute_path s =
          let s =
            if Filename.is_relative s
            then Filename.concat (Sys.getcwd ()) s
            else s in
          let rec aux s =
            let base = Filename.basename s in
            let dir = Filename.dirname s in
            if dir = s
            then dir
            else
              if base = Filename.current_dir_name
              then aux dir
              else
                if base = Filename.parent_dir_name
                then Filename.dirname (aux dir)
                else Filename.concat (aux dir) base in
          aux s
        let try_chop_extension s =
          try Filename.chop_extension s with | _ -> s
        let relative_path file1 file2 =
          let dir1 =
            Ext_string.split (Filename.dirname file1) (Filename.dir_sep.[0]) in
          let dir2 =
            Ext_string.split (Filename.dirname file2) (Filename.dir_sep.[0]) in
          let rec go (dir1 : string list) (dir2 : string list) =
            match (dir1, dir2) with
            | (x::xs,y::ys) when x = y -> go xs ys
            | (_,_) -> (List.map (fun _  -> node_parent) dir2) @ dir1 in
          match go dir1 dir2 with
          | x::_ as ys when x = node_parent -> String.concat node_sep ys
          | ys -> (String.concat node_sep) @@ (node_current :: ys)[@@ocaml.doc
                                                                    " example\n    {[\n    \"/bb/mbigc/mbig2899/bgit/ocamlscript/jscomp/stdlib/external/pervasives.cmj\"\n    \"/bb/mbigc/mbig2899/bgit/ocamlscript/jscomp/stdlib/ocaml_array.ml\"\n    ]}\n\n    The other way\n    {[\n    \n    \"/bb/mbigc/mbig2899/bgit/ocamlscript/jscomp/stdlib/ocaml_array.ml\"\n    \"/bb/mbigc/mbig2899/bgit/ocamlscript/jscomp/stdlib/external/pervasives.cmj\"\n    ]}\n    {[\n    \"/bb/mbigc/mbig2899/bgit/ocamlscript/jscomp/stdlib//ocaml_array.ml\"\n    ]}\n    {[\n    /a/b\n    /c/d\n    ]}\n "]
        let node_relative_path path1 path2 =
          (relative_path (try_chop_extension (absolute_path path2))
             (try_chop_extension (absolute_path path1)))
            ^ (node_sep ^ (try_chop_extension (Filename.basename path2)))
          [@@ocaml.doc
            " path2: a/b \n    path1: a \n    result:  ./b \n    TODO: [Filename.concat] with care\n "]
      end 
    module Js_program_loader :
      sig
        [@@@ocaml.text
          " A module to create the whole JS program IR with [requires] and [exports] "]
        val make_program :
          string ->
            string option ->
              Ident.t list -> Lam_module_ident.t list -> J.block -> J.program
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        type module_id = Lam_module_ident.t
        open Js_output.Ops
        let string_of_module_id (x : module_id) =
          (match x.kind with
           | Runtime |Ml  ->
               let id = x.id in
               let file = Printf.sprintf "%s.js" id.name in
               if Ext_string.starts_with id.name "Caml_"
               then
                 let path =
                   match Sys.getenv "OCAML_JS_RUNTIME_PATH" with
                   | exception Not_found  ->
                       Filename.concat
                         (Filename.dirname
                            (Filename.dirname Sys.executable_name)) "runtime"
                   | f -> f in
                 Ext_filename.node_relative_path (!Location.input_name)
                   (Filename.concat path (String.uncapitalize id.name))
               else
                 (match Config_util.find file with
                  | exception Not_found  ->
                      (Ext_log.warn __LOC__
                         "@[%s not found in search path - while compiling %s @] @."
                         file (!Location.input_name);
                       Printf.sprintf "%s" (String.uncapitalize id.name))
                  | path ->
                      Ext_filename.node_relative_path (!Location.input_name)
                        path)
           | External name -> name : string)
        let make_program name side_effect export_idents external_module_ids
          block =
          (let modules =
             List.map
               (fun id  ->
                  ((Lam_module_ident.id id), (string_of_module_id id)))
               external_module_ids in
           {
             name;
             modules;
             exports = export_idents;
             export_set = (Ident_set.of_list export_idents);
             block;
             side_effect
           } : J.program)
      end 
    module Js_pass_scope :
      sig
        [@@@ocaml.text " A module to do scope analysis over JS IR "]
        val program : J.program -> Ident_set.t
      end =
      struct
        let _l idents =
          Ext_log.err __LOC__ "hey .. %s@."
            ((String.concat ",") @@
               (List.map (fun i  -> i.Ident.name) idents))
        let scope_pass =
          object (self)
            inherit  Js_fold.fold as super
            val defined_idents = Ident_set.empty
            val used_idents = Ident_set.empty[@@ocaml.doc
                                               " [used_idents] \n        does not contain locally defined idents "]
            [@@ocaml.doc
              " we need collect mutable values and loop defined varaibles "]
            val loop_mutable_values = Ident_set.empty[@@ocaml.doc
                                                       " we need collect mutable values and loop defined varaibles "]
            val mutable_values = Ident_set.empty
            val closured_idents = Ident_set.empty
            val in_loop = false[@@ocaml.doc " check if in loop or not "]
            method get_in_loop = in_loop
            method get_defined_idents = defined_idents
            method get_used_idents = used_idents
            method get_loop_mutable_values = loop_mutable_values
            method get_mutable_values = mutable_values
            method get_closured_idents = closured_idents
            method with_in_loop b =
              if b = self#get_in_loop then self else {<in_loop = b>}
            method with_loop_mutable_values b = {<loop_mutable_values = b>}
            method add_loop_mutable_variable id =
              {<loop_mutable_values = Ident_set.add id loop_mutable_values;
                mutable_values = Ident_set.add id mutable_values>}
            method add_mutable_variable id =
              {<mutable_values = Ident_set.add id mutable_values>}
            method add_defined_ident ident =
              {<defined_idents = Ident_set.add ident defined_idents>}
            method! expression x =
              match x.expression_desc with
              | Fun (params,block,env) ->
                  let param_set = Ident_set.of_list params in
                  let obj =
                    ({<defined_idents = Ident_set.empty;used_idents =
                                                          Ident_set.empty;
                       in_loop = false;loop_mutable_values = Ident_set.empty;
                       mutable_values =
                         Ident_set.of_list
                           (Js_fun_env.get_mutable_params params env);
                       closured_idents = Ident_set.empty>})#block block in
                  let (defined_idents',used_idents') =
                    ((obj#get_defined_idents), (obj#get_used_idents)) in
                  (params |>
                     (List.iteri
                        (fun i  ->
                           fun v  ->
                             if not (Ident_set.mem v used_idents')
                             then Js_fun_env.mark_unused env i));
                   (let closured_idents' =
                      let open Ident_set in
                        diff used_idents' (union defined_idents' param_set) in
                    Js_fun_env.set_bound env closured_idents';
                    (let lexical_scopes =
                       let open Ident_set in
                         inter closured_idents' self#get_loop_mutable_values in
                     Js_fun_env.set_lexical_scope env lexical_scopes;
                     {<used_idents =
                         Ident_set.union used_idents closured_idents';
                       closured_idents =
                         Ident_set.union closured_idents closured_idents'>})))
              | _ -> super#expression x
            method! variable_declaration x =
              match x with
              | { ident; value; property } ->
                  let obj =
                    (match ((self#get_in_loop), property) with
                     | (true ,Mutable ) ->
                         self#add_loop_mutable_variable ident
                     | (true ,Immutable ) ->
                         (match value with
                          | None  -> self#add_loop_mutable_variable ident
                          | Some x ->
                              (match x.expression_desc with
                               | Fun _|Number _|Str _ -> self
                               | _ -> self#add_loop_mutable_variable ident))
                     | (false ,Mutable ) -> self#add_mutable_variable ident
                     | (false ,Immutable ) -> self)#add_defined_ident ident in
                  (match value with
                   | None  -> obj
                   | Some x -> obj#expression x)
            method! statement x =
              match x.statement_desc with
              | ForRange (_,_,loop_id,_,_,a_env) as y ->
                  let obj =
                    ({<in_loop = true;loop_mutable_values =
                                        Ident_set.singleton loop_id;used_idents
                                                                    =
                                                                    Ident_set.empty;
                       defined_idents = Ident_set.singleton loop_id;closured_idents
                                                                    =
                                                                    Ident_set.empty>})#statement_desc
                      y in
                  let (defined_idents',used_idents',closured_idents') =
                    ((obj#get_defined_idents), (obj#get_used_idents),
                      (obj#get_closured_idents)) in
                  let lexical_scope =
                    let open Ident_set in
                      inter (diff closured_idents' defined_idents')
                        self#get_loop_mutable_values in
                  let () = Js_closure.set_lexical_scope a_env lexical_scope in
                  {<used_idents = Ident_set.union used_idents used_idents';
                    defined_idents =
                      Ident_set.union defined_idents defined_idents';
                    closured_idents =
                      Ident_set.union closured_idents lexical_scope>}
              | While (_label,pred,body,_env) ->
                  (((self#expression pred)#with_in_loop true)#block body)#with_in_loop
                    self#get_in_loop
              | _ -> super#statement x
            method! exception_ident x =
              {<used_idents = Ident_set.add x used_idents;defined_idents =
                                                            Ident_set.add x
                                                              defined_idents>}
            method! for_ident x =
              {<loop_mutable_values = Ident_set.add x loop_mutable_values>}
            method! ident x =
              if Ident_set.mem x defined_idents
              then self
              else {<used_idents = Ident_set.add x used_idents>}
          end
        let program js = (scope_pass#program js)#get_loop_mutable_values
      end 
    module Js_op_util :
      sig
        [@@@ocaml.text " Some basic utilties around {!Js_op} module "]
        val op_prec : Js_op.binop -> (int* int* int)
        val op_str : Js_op.binop -> string
        val str_of_used_stats : Js_op.used_stats -> string
        val update_used_stats : J.ident_info -> Js_op.used_stats -> unit
        val same_vident : J.vident -> J.vident -> bool
      end =
      struct
        let op_prec (op : Js_op.binop) =
          match op with
          | Eq  -> (1, 13, 1)
          | Or  -> (3, 3, 3)
          | And  -> (4, 4, 4)
          | EqEqEq |NotEqEq  -> (8, 8, 9)
          | Gt |Ge |Lt |Le  -> (9, 9, 10)
          | Bor  -> (5, 5, 5)
          | Bxor  -> (6, 6, 6)
          | Band  -> (7, 7, 7)
          | Lsl |Lsr |Asr  -> (10, 10, 11)
          | Plus |Minus  -> (11, 11, 12)
          | Mul |Div |Mod  -> (12, 12, 13)
        let op_int_prec (op : Js_op.int_op) =
          match op with
          | Bor  -> (5, 5, 5)
          | Bxor  -> (6, 6, 6)
          | Band  -> (7, 7, 7)
          | Lsl |Lsr |Asr  -> (10, 10, 11)
          | Plus |Minus  -> (11, 11, 12)
          | Mul |Div |Mod  -> (12, 12, 13)
        let op_str (op : Js_op.binop) =
          match op with
          | Eq  -> "="
          | Or  -> "||"
          | And  -> "&&"
          | Bor  -> "|"
          | Bxor  -> "^"
          | Band  -> "&"
          | EqEqEq  -> "==="
          | NotEqEq  -> "!=="
          | Lt  -> "<"
          | Le  -> "<="
          | Gt  -> ">"
          | Ge  -> ">="
          | Lsl  -> "<<"
          | Lsr  -> ">>>"
          | Asr  -> ">>"
          | Plus  -> "+"
          | Minus  -> "-"
          | Mul  -> "*"
          | Div  -> "/"
          | Mod  -> "%"
        let str_of_used_stats =
          function
          | Js_op.Dead_pure  -> "Dead_pure"
          | Dead_non_pure  -> "Dead_non_pure"
          | Exported  -> "Exported"
          | Used  -> "Used"
          | Scanning_pure  -> "Scanning_pure"
          | Scanning_non_pure  -> "Scanning_non_pure"
          | NA  -> "NA"
        let update_used_stats (ident_info : J.ident_info) used_stats =
          match ident_info.used_stats with
          | Dead_pure |Dead_non_pure |Exported  -> ()
          | Scanning_pure |Scanning_non_pure |Used |NA  ->
              ident_info.used_stats <- used_stats
        let same_kind (x : Js_op.kind) (y : Js_op.kind) =
          match (x, y) with
          | (Ml ,Ml )|(Runtime ,Runtime ) -> true
          | (External (u : string),External v) -> u = v
          | (_,_) -> false
        let same_str_opt (x : string option) (y : string option) =
          match (x, y) with
          | (None ,None ) -> true
          | (Some x0,Some y0) -> x0 = y0
          | (None ,Some _)|(Some _,None ) -> false
        let same_vident (x : J.vident) (y : J.vident) =
          match (x, y) with
          | (Id x0,Id y0) -> Ident.same x0 y0
          | (Qualified (x0,k0,str_opt0),Qualified (y0,k1,str_opt1)) ->
              (Ident.same x0 y0) &&
                ((same_kind k0 k1) && (same_str_opt str_opt0 str_opt1))
          | (Id _,Qualified _)|(Qualified _,Id _) -> false
      end 
    module Js_map =
      struct
        open J[@@ocaml.doc " GENERATED CODE, map visitor for JS IR  "]
        class virtual map =
          object (o : 'self_type)
            method string : string -> string= o#unknown
            method option :
              'a 'a_out .
                ('self_type -> 'a -> 'a_out) -> 'a option -> 'a_out option=
              fun _f_a  ->
                function
                | None  -> None
                | Some _x -> let _x = _f_a o _x in Some _x
            method list :
              'a 'a_out .
                ('self_type -> 'a -> 'a_out) -> 'a list -> 'a_out list=
              fun _f_a  ->
                function
                | [] -> []
                | _x::_x_i1 ->
                    let _x = _f_a o _x in
                    let _x_i1 = o#list _f_a _x_i1 in _x :: _x_i1
            method int : int -> int= o#unknown
            method bool : bool -> bool=
              function | false  -> false | true  -> true
            method vident : vident -> vident=
              function
              | Id _x -> let _x = o#ident _x in Id _x
              | Qualified (_x,_x_i1,_x_i2) ->
                  let _x = o#ident _x in
                  let _x_i1 = o#kind _x_i1 in
                  let _x_i2 = o#option (fun o  -> o#string) _x_i2 in
                  Qualified (_x, _x_i1, _x_i2)
            method variable_declaration :
              variable_declaration -> variable_declaration=
              fun
                { ident = _x; value = _x_i1; property = _x_i2;
                  ident_info = _x_i3 }
                 ->
                let _x = o#ident _x in
                let _x_i1 = o#option (fun o  -> o#expression) _x_i1 in
                let _x_i2 = o#property _x_i2 in
                let _x_i3 = o#ident_info _x_i3 in
                {
                  ident = _x;
                  value = _x_i1;
                  property = _x_i2;
                  ident_info = _x_i3
                }
            method statement_desc : statement_desc -> statement_desc=
              function
              | Block _x -> let _x = o#block _x in Block _x
              | Variable _x ->
                  let _x = o#variable_declaration _x in Variable _x
              | Exp _x -> let _x = o#expression _x in Exp _x
              | If (_x,_x_i1,_x_i2) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#block _x_i1 in
                  let _x_i2 = o#option (fun o  -> o#block) _x_i2 in
                  If (_x, _x_i1, _x_i2)
              | While (_x,_x_i1,_x_i2,_x_i3) ->
                  let _x = o#option (fun o  -> o#label) _x in
                  let _x_i1 = o#expression _x_i1 in
                  let _x_i2 = o#block _x_i2 in
                  let _x_i3 = o#unknown _x_i3 in
                  While (_x, _x_i1, _x_i2, _x_i3)
              | ForRange (_x,_x_i1,_x_i2,_x_i3,_x_i4,_x_i5) ->
                  let _x = o#option (fun o  -> o#for_ident_expression) _x in
                  let _x_i1 = o#finish_ident_expression _x_i1 in
                  let _x_i2 = o#for_ident _x_i2 in
                  let _x_i3 = o#for_direction _x_i3 in
                  let _x_i4 = o#block _x_i4 in
                  let _x_i5 = o#unknown _x_i5 in
                  ForRange (_x, _x_i1, _x_i2, _x_i3, _x_i4, _x_i5)
              | Continue _x -> let _x = o#label _x in Continue _x
              | Break  -> Break
              | Return _x -> let _x = o#return_expression _x in Return _x
              | Int_switch (_x,_x_i1,_x_i2) ->
                  let _x = o#expression _x in
                  let _x_i1 =
                    o#list (fun o  -> o#case_clause (fun o  -> o#int)) _x_i1 in
                  let _x_i2 = o#option (fun o  -> o#block) _x_i2 in
                  Int_switch (_x, _x_i1, _x_i2)
              | String_switch (_x,_x_i1,_x_i2) ->
                  let _x = o#expression _x in
                  let _x_i1 =
                    o#list (fun o  -> o#case_clause (fun o  -> o#string))
                      _x_i1 in
                  let _x_i2 = o#option (fun o  -> o#block) _x_i2 in
                  String_switch (_x, _x_i1, _x_i2)
              | Throw _x -> let _x = o#expression _x in Throw _x
              | Try (_x,_x_i1,_x_i2) ->
                  let _x = o#block _x in
                  let _x_i1 =
                    o#option
                      (fun o  ->
                         fun (_x,_x_i1)  ->
                           let _x = o#exception_ident _x in
                           let _x_i1 = o#block _x_i1 in (_x, _x_i1)) _x_i1 in
                  let _x_i2 = o#option (fun o  -> o#block) _x_i2 in
                  Try (_x, _x_i1, _x_i2)
            method statement : statement -> statement=
              fun { statement_desc = _x; comment = _x_i1 }  ->
                let _x = o#statement_desc _x in
                let _x_i1 = o#option (fun o  -> o#string) _x_i1 in
                { statement_desc = _x; comment = _x_i1 }
            method return_expression :
              return_expression -> return_expression=
              fun { return_value = _x }  ->
                let _x = o#expression _x in { return_value = _x }
            method required_modules : required_modules -> required_modules=
              o#unknown
            method property_name : property_name -> property_name= o#string
            method property_map : property_map -> property_map=
              o#list
                (fun o  ->
                   fun (_x,_x_i1)  ->
                     let _x = o#property_name _x in
                     let _x_i1 = o#expression _x_i1 in (_x, _x_i1))
            method property : property -> property= o#unknown
            method program : program -> program=
              fun
                { name = _x; modules = _x_i1; block = _x_i2; exports = _x_i3;
                  export_set = _x_i4; side_effect = _x_i5 }
                 ->
                let _x = o#string _x in
                let _x_i1 = o#required_modules _x_i1 in
                let _x_i2 = o#block _x_i2 in
                let _x_i3 = o#exports _x_i3 in
                let _x_i4 = o#unknown _x_i4 in
                let _x_i5 = o#option (fun o  -> o#string) _x_i5 in
                {
                  name = _x;
                  modules = _x_i1;
                  block = _x_i2;
                  exports = _x_i3;
                  export_set = _x_i4;
                  side_effect = _x_i5
                }
            method number : number -> number= o#unknown
            method mutable_flag : mutable_flag -> mutable_flag= o#unknown
            method label : label -> label= o#string
            method kind : kind -> kind= o#unknown
            method int_op : int_op -> int_op= o#unknown
            method ident_info : ident_info -> ident_info= o#unknown
            method ident : ident -> ident= o#unknown
            method for_ident_expression :
              for_ident_expression -> for_ident_expression= o#expression
            method for_ident : for_ident -> for_ident= o#ident
            method for_direction : for_direction -> for_direction= o#unknown
            method finish_ident_expression :
              finish_ident_expression -> finish_ident_expression=
              o#expression
            method expression_desc : expression_desc -> expression_desc=
              function
              | Math (_x,_x_i1) ->
                  let _x = o#string _x in
                  let _x_i1 = o#list (fun o  -> o#expression) _x_i1 in
                  Math (_x, _x_i1)
              | Array_length _x ->
                  let _x = o#expression _x in Array_length _x
              | String_length _x ->
                  let _x = o#expression _x in String_length _x
              | Bytes_length _x ->
                  let _x = o#expression _x in Bytes_length _x
              | Function_length _x ->
                  let _x = o#expression _x in Function_length _x
              | Char_of_int _x -> let _x = o#expression _x in Char_of_int _x
              | Char_to_int _x -> let _x = o#expression _x in Char_to_int _x
              | Array_of_size _x ->
                  let _x = o#expression _x in Array_of_size _x
              | Array_append (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#list (fun o  -> o#expression) _x_i1 in
                  Array_append (_x, _x_i1)
              | Tag_ml_obj _x -> let _x = o#expression _x in Tag_ml_obj _x
              | String_append (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#expression _x_i1 in String_append (_x, _x_i1)
              | Int_of_boolean _x ->
                  let _x = o#expression _x in Int_of_boolean _x
              | Is_type_number _x ->
                  let _x = o#expression _x in Is_type_number _x
              | Not _x -> let _x = o#expression _x in Not _x
              | String_of_small_int_array _x ->
                  let _x = o#expression _x in String_of_small_int_array _x
              | Dump (_x,_x_i1) ->
                  let _x = o#unknown _x in
                  let _x_i1 = o#list (fun o  -> o#expression) _x_i1 in
                  Dump (_x, _x_i1)
              | Seq (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#expression _x_i1 in Seq (_x, _x_i1)
              | Cond (_x,_x_i1,_x_i2) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#expression _x_i1 in
                  let _x_i2 = o#expression _x_i2 in Cond (_x, _x_i1, _x_i2)
              | Bin (_x,_x_i1,_x_i2) ->
                  let _x = o#binop _x in
                  let _x_i1 = o#expression _x_i1 in
                  let _x_i2 = o#expression _x_i2 in Bin (_x, _x_i1, _x_i2)
              | FlatCall (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#expression _x_i1 in FlatCall (_x, _x_i1)
              | Call (_x,_x_i1,_x_i2) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#list (fun o  -> o#expression) _x_i1 in
                  let _x_i2 = o#unknown _x_i2 in Call (_x, _x_i1, _x_i2)
              | String_access (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#expression _x_i1 in String_access (_x, _x_i1)
              | Access (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#expression _x_i1 in Access (_x, _x_i1)
              | Dot (_x,_x_i1,_x_i2) ->
                  let _x = o#expression _x in
                  let _x_i1 = o#string _x_i1 in
                  let _x_i2 = o#bool _x_i2 in Dot (_x, _x_i1, _x_i2)
              | New (_x,_x_i1) ->
                  let _x = o#expression _x in
                  let _x_i1 =
                    o#option (fun o  -> o#list (fun o  -> o#expression))
                      _x_i1 in
                  New (_x, _x_i1)
              | Var _x -> let _x = o#vident _x in Var _x
              | Fun (_x,_x_i1,_x_i2) ->
                  let _x = o#list (fun o  -> o#ident) _x in
                  let _x_i1 = o#block _x_i1 in
                  let _x_i2 = o#unknown _x_i2 in Fun (_x, _x_i1, _x_i2)
              | Str (_x,_x_i1) ->
                  let _x = o#bool _x in
                  let _x_i1 = o#string _x_i1 in Str (_x, _x_i1)
              | Array (_x,_x_i1) ->
                  let _x = o#list (fun o  -> o#expression) _x in
                  let _x_i1 = o#mutable_flag _x_i1 in Array (_x, _x_i1)
              | Number _x -> let _x = o#number _x in Number _x
              | Object _x -> let _x = o#property_map _x in Object _x
            method expression : expression -> expression=
              fun { expression_desc = _x; comment = _x_i1 }  ->
                let _x = o#expression_desc _x in
                let _x_i1 = o#option (fun o  -> o#string) _x_i1 in
                { expression_desc = _x; comment = _x_i1 }
            method exports : exports -> exports= o#unknown
            method exception_ident : exception_ident -> exception_ident=
              o#ident
            method case_clause :
              'a 'a_out .
                ('self_type -> 'a -> 'a_out) ->
                  'a case_clause -> 'a_out case_clause=
              fun _f_a  ->
                fun { case = _x; body = _x_i1 }  ->
                  let _x = _f_a o _x in
                  let _x_i1 =
                    (fun (_x,_x_i1)  ->
                       let _x = o#block _x in
                       let _x_i1 = o#bool _x_i1 in (_x, _x_i1)) _x_i1 in
                  { case = _x; body = _x_i1 }
            method block : block -> block= o#list (fun o  -> o#statement)
            method binop : binop -> binop= o#unknown
            method unknown : 'a . 'a -> 'a= fun x  -> x
          end
      end
    module Js_pass_flatten_and_mark_dead :
      sig
        [@@@ocaml.text
          " A pass to mark some declarations in JS IR as dead code "]
        val program : J.program -> J.program
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        class count var =
          object (self : 'self)
            val mutable appears = 0
            inherit  Js_fold.fold as super
            method! ident x =
              if Ident.same x var then appears <- appears + 1; self
            method get_appears = appears
          end
        class rewrite_return ?return_value  () =
          let mk_return =
            match return_value with
            | None  -> (fun e  -> S.exp e)
            | Some ident -> (fun e  -> S.define ~kind:Variable ident e)
          in
          object (self : 'self)
            inherit  Js_map.map as super
            method! statement x =
              match x.statement_desc with
              | Return { return_value = e } -> mk_return e
              | _ -> super#statement x
            method! expression x = x
          end
        let mark_dead =
          object (self)
            inherit  Js_fold.fold as super
            val mutable name = ""
            val mutable ident_use_stats =
              (Hashtbl.create 17 : (Ident.t,[ `Info of J.ident_info 
                                            | `Recursive ])
                                     Hashtbl.t)
            val mutable export_set = (Ident_set.empty : Ident_set.t)
            method mark_not_dead ident =
              match Hashtbl.find ident_use_stats ident with
              | exception Not_found  ->
                  Hashtbl.add ident_use_stats ident `Recursive
              | `Recursive -> ()
              | `Info x -> Js_op_util.update_used_stats x Used
            method scan b ident (ident_info : J.ident_info) =
              let is_export = Ident_set.mem ident export_set in
              let () =
                if is_export
                then Js_op_util.update_used_stats ident_info Exported in
              match Hashtbl.find ident_use_stats ident with
              | `Recursive ->
                  (Js_op_util.update_used_stats ident_info Used;
                   Hashtbl.replace ident_use_stats ident (`Info ident_info))
              | `Info _ ->
                  Ext_log.warn __LOC__ "@[%s$%d in %s@]@." ident.name
                    ident.stamp name
              | exception Not_found  ->
                  (Hashtbl.add ident_use_stats ident (`Info ident_info);
                   Js_op_util.update_used_stats ident_info
                     (if b then Scanning_pure else Scanning_non_pure))
            method promote_dead =
              Hashtbl.iter
                (fun _id  ->
                   fun (info : [ `Info of J.ident_info  | `Recursive ])  ->
                     match info with
                     | `Info ({ used_stats = Scanning_pure  } as info) ->
                         Js_op_util.update_used_stats info Dead_pure
                     | `Info ({ used_stats = Scanning_non_pure  } as info) ->
                         Js_op_util.update_used_stats info Dead_non_pure
                     | _ -> ()) ident_use_stats;
              Hashtbl.clear ident_use_stats
            method! program x =
              export_set <- x.export_set; name <- x.name; super#program x
            method! ident x = self#mark_not_dead x; self
            method! variable_declaration vd =
              match vd with
              | { ident_info = { used_stats = Dead_pure  };_}
                |{ ident_info = { used_stats = Dead_non_pure  };
                   value = None  }
                  -> self
              | { ident_info = { used_stats = Dead_non_pure  };
                  value = Some x } -> self#expression x
              | { ident; ident_info; value;_} ->
                  let pure =
                    match value with
                    | None  -> false
                    | Some x ->
                        (ignore (self#expression x);
                         J_helper.no_side_effect x) in
                  (self#scan pure ident ident_info; self)
          end
        let mark_dead_code js =
          let _ = mark_dead#program js in mark_dead#promote_dead; js
        let subst_map =
          object (self)
            inherit  Js_map.map as super
            val mutable substitution = Hashtbl.create 17
            method get_substitution = substitution
            method add_substitue (ident : Ident.t) (e : J.expression) =
              Hashtbl.replace substitution ident e
            method! statement v =
              match v.statement_desc with
              | Variable { ident; ident_info = { used_stats = Dead_pure  };_}
                  -> { v with statement_desc = (Block []) }
              | Variable
                  { ident; ident_info = { used_stats = Dead_non_pure  };
                    value = None  }
                  -> { v with statement_desc = (Block []) }
              | Variable
                  { ident; ident_info = { used_stats = Dead_non_pure  };
                    value = Some x }
                  -> { v with statement_desc = (Exp x) }
              | Variable
                  ({ ident; property = Immutable ;
                     value = Some
                       ({
                          expression_desc = Array
                            ((_::_::_ as ls),Immutable )
                          } as array)
                     } as variable)
                  ->
                  let bindings = ref [] in
                  let e =
                    List.mapi
                      (fun i  ->
                         fun (x : J.expression)  ->
                           match x.expression_desc with
                           | J.Var _|Number _|Str _ -> x
                           | _ ->
                               let v' = self#expression x in
                               let match_id =
                                 Ext_ident.create
                                   (Printf.sprintf "%s_%03d" ident.name i) in
                               (bindings := ((match_id, v') :: (!bindings));
                                E.var match_id)) ls in
                  let e =
                    { array with expression_desc = (Array (e, Immutable)) } in
                  let () = self#add_substitue ident e in
                  let bindings = !bindings in
                  let original_statement =
                    {
                      v with
                      statement_desc =
                        (Variable { variable with value = (Some e) })
                    } in
                  (match bindings with
                   | [] -> original_statement
                   | _ ->
                       (self#add_substitue ident e;
                        S.block @@
                          (Ext_list.rev_map_acc [original_statement]
                             (fun (id,v)  -> S.define ~kind:Strict id v)
                             bindings)))
              | _ -> super#statement v
            method! expression x =
              match x.expression_desc with
              | Access
                  ({ expression_desc = Var (Id id) },{
                                                       expression_desc =
                                                         Number (Int 
                                                         { i;_})
                                                       })
                  ->
                  (match Hashtbl.find self#get_substitution id with
                   | { expression_desc = Array (ls,Immutable ) } ->
                       (match List.nth ls i with
                        | { expression_desc = (J.Var _|Number _|Str _) } as x
                            -> x
                        | _ -> super#expression x)
                   | _ -> super#expression x
                   | exception Not_found  -> super#expression x)
              | _ -> super#expression x
          end
        let program js = (js |> subst_map#program) |> mark_dead_code
      end 
    module Js_pass_flatten :
      sig
        [@@@ocaml.text
          " A pass converting nested js statement into a flatten visual appearance "]
        val program : J.program -> J.program
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        let flatten_map =
          object (self)
            inherit  Js_map.map as super
            method! statement x =
              match x.statement_desc with
              | Exp ({ expression_desc = Seq _;_} as v) ->
                  S.block
                    (List.rev_map self#statement
                       (Js_analyzer.rev_flatten_seq v))
              | Exp { expression_desc = Cond (a,b,c);_} ->
                  S.if_ a [self#statement (S.exp b)]
                    ~else_:[self#statement (S.exp c)]
              | Exp
                  {
                    expression_desc = Bin
                      (Eq ,a,({ expression_desc = Seq _;_} as v));_}
                  ->
                  let block = Js_analyzer.rev_flatten_seq v in
                  (match block with
                   | { statement_desc = Exp last_one;_}::rest_rev ->
                       S.block
                         (Ext_list.rev_map_append self#statement rest_rev
                            [self#statement @@ (S.exp (E.assign a last_one))])
                   | _ -> assert false)
              | Return { return_value = { expression_desc = Cond (a,b,c);_} }
                  -> S.if_ a [S.return b] ~else_:[S.return c]
              | Return { return_value = ({ expression_desc = Seq _;_} as v) }
                  ->
                  let block = Js_analyzer.rev_flatten_seq v in
                  (match block with
                   | { statement_desc = Exp last_one;_}::rest_rev ->
                       super#statement
                         (S.block
                            (List.rev_append rest_rev [S.return last_one]))
                   | _ -> assert false)
              | Block (x::[]) -> self#statement x
              | _ -> super#statement x
            method! block b =
              match b with
              | { statement_desc = Block bs }::rest -> self#block (bs @ rest)
              | x::rest -> (self#statement x) :: (self#block rest)
              | [] -> []
          end
        let program (x : J.program) = flatten_map#program x
      end 
    module Int_map : sig include (Map.S with type  key =  int) end =
      struct
        include
          Map.Make(struct
                     type t = int
                     let compare (x : int) y = Pervasives.compare x y
                   end)
      end 
    module Ext_pp_scope :
      sig
        [@@@ocaml.text " Scope type to improve identifier name printing\n "]
        [@@@ocaml.text
          " Defines scope type [t], so that the pretty printer would print more beautiful code: \n    \n    print [identifer] instead of [identifier$1234] when it can\n "]
        type t
        val empty : t
        val add_ident : Ident.t -> t -> (int* t)
        val sub_scope : t -> Ident_set.t -> t
        val merge : Ident_set.t -> t -> t
        val string_of_id : Ident.t -> t -> (int* t)
      end =
      struct
        type t = int Int_map.t String_map.t
        let empty = String_map.empty
        let add_ident (id : Ident.t) (cxt : t) =
          (match String_map.find id.name cxt with
           | exception Not_found  ->
               (0,
                 (String_map.add id.name
                    (let open Int_map in add id.stamp 0 empty) cxt))
           | imap ->
               (match Int_map.find id.stamp imap with
                | exception Not_found  ->
                    let v = Int_map.cardinal imap in
                    (v,
                      (String_map.add id.name (Int_map.add id.stamp v imap)
                         cxt))
                | i -> (i, cxt)) : (int* t))
        let of_list lst cxt =
          List.fold_left (fun scope  -> fun i  -> snd (add_ident i scope))
            cxt lst
        let merge set cxt =
          Ident_set.fold
            (fun ident  -> fun acc  -> snd (add_ident ident acc)) set cxt
        let sub_scope (scope : t) ident_collection =
          (let cxt = empty in
           Ident_set.fold
             (fun (i : Ident.t)  ->
                fun acc  ->
                  match String_map.find i.name scope with
                  | exception Not_found  -> assert false
                  | imap ->
                      (match String_map.find i.name acc with
                       | exception Not_found  ->
                           String_map.add i.name imap acc
                       | _ -> acc)) ident_collection cxt : t)
        module P = Ext_format
        let string_of_id (id : Ident.t) (cxt : t) =
          (match String_map.find id.name cxt with
           | exception Not_found  ->
               (0,
                 (String_map.add id.name
                    (let open Int_map in add id.stamp 0 empty) cxt))
           | imap ->
               (match Int_map.find id.stamp imap with
                | exception Not_found  ->
                    let v = Int_map.cardinal imap in
                    (v,
                      (String_map.add id.name
                         (let open Int_map in add id.stamp v imap : int
                                                                    Int_map.t)
                         cxt))
                | i -> (i, cxt)) : (int* t))
      end 
    module Ext_pervasives :
      sig
        [@@@ocaml.text
          " Extension to standard library [Pervavives] module, safe to open \n  "]
        val finally : 'a -> ('a -> 'b) -> ('a -> 'c) -> 'b
        val with_file_as_chan : string -> (out_channel -> 'a) -> 'a
        val with_file_as_pp : string -> (Format.formatter -> 'a) -> 'a
      end =
      struct
        let finally v f action =
          match f v with
          | exception e -> (action v; raise e)
          | e -> (action v; e)
        let with_file_as_chan filename f =
          let chan = open_out filename in finally chan f close_out
        let with_file_as_pp filename f =
          let chan = open_out filename in
          finally chan
            (fun chan  ->
               let fmt = Format.formatter_of_out_channel chan in
               let v = f fmt in Format.pp_print_flush fmt (); v) close_out
      end 
    module Ext_pp :
      sig
        type t[@@ocaml.doc
                " A simple pretty printer\n    \n    Advantage compared with [Format], \n    [P.newline] does not screw the layout, have better control when do a newline (sicne JS has ASI)\n    Easy to tweak\n\n    {ul \n    {- be a little smarter}\n    {- buffer the last line, so that  we can do a smart newline, when it's really safe to do so}\n    }\n"]
        val indent_length : int
        val string : t -> string -> unit
        val space : t -> unit
        val group : t -> int -> (unit -> 'a) -> 'a[@@ocaml.doc
                                                    " [group] will record current indentation \n    and indent futher\n "]
        val vgroup : t -> int -> (unit -> 'a) -> 'a
        val paren : t -> (unit -> 'a) -> 'a
        val brace : t -> (unit -> 'a) -> 'a
        val paren_group : t -> int -> (unit -> 'a) -> 'a
        val paren_vgroup : t -> int -> (unit -> 'a) -> 'a
        val brace_group : t -> int -> (unit -> 'a) -> 'a
        val brace_vgroup : t -> int -> (unit -> 'a) -> 'a
        val bracket_group : t -> int -> (unit -> 'a) -> 'a
        val bracket_vgroup : t -> int -> (unit -> 'a) -> 'a
        val newline : t -> unit
        val force_newline : t -> unit[@@ocaml.doc
                                       " [force_newline] Always print a newline "]
        val to_out_channel : out_channel -> t
        val flush : t -> unit -> unit
      end =
      struct
        module L = struct let space = " "
                          let indent_str = "  " end
        let indent_length = String.length L.indent_str
        type t =
          {
          chan: out_channel;
          mutable indent_level: int;
          mutable last_new_line: bool;}
        let to_out_channel chan =
          { chan; indent_level = 0; last_new_line = false }
        let string t s = output_string t.chan s; t.last_new_line <- false
        let newline t =
          if not t.last_new_line
          then
            (output_char t.chan '\n';
             for i = 0 to t.indent_level - 1 do
               output_string t.chan L.indent_str
             done;
             t.last_new_line <- true)
        let force_newline t =
          output_char t.chan '\n';
          for i = 0 to t.indent_level - 1 do
            output_string t.chan L.indent_str
          done
        let space t = string t L.space
        let group t i action =
          if i = 0
          then action ()
          else
            (let old = t.indent_level in
             t.indent_level <- t.indent_level + i;
             Ext_pervasives.finally () action
               (fun _  -> t.indent_level <- old))
        let vgroup = group
        let paren t action =
          string t "("; (let v = action () in string t ")"; v)
        let brace fmt u = string fmt "{"; (let v = u () in string fmt "}"; v)
        let bracket fmt u =
          string fmt "["; (let v = u () in string fmt "]"; v)
        let brace_vgroup st n action =
          string st "{";
          (let v =
             vgroup st n (fun _  -> newline st; (let v = action () in v)) in
           force_newline st; string st "}"; v)
        let bracket_vgroup st n action =
          string st "[";
          (let v =
             vgroup st n (fun _  -> newline st; (let v = action () in v)) in
           force_newline st; string st "]"; v)
        let bracket_group st n action =
          group st n (fun _  -> bracket st action)
        let paren_vgroup st n action =
          string st "(";
          (let v =
             group st n (fun _  -> newline st; (let v = action () in v)) in
           newline st; string st ")"; v)
        let paren_group st n action = group st n (fun _  -> paren st action)
        let brace_group st n action = group st n (fun _  -> brace st action)
        let indent t n = t.indent_level <- t.indent_level + n
        let flush t () = flush t.chan
      end 
    module Js_dump :
      sig
        [@@@ocaml.text " Print JS IR to vanilla Javascript code "]
        val dump_program : J.program -> out_channel -> unit
      end =
      struct
        module P = Ext_pp
        module E = J_helper.Exp
        module S = J_helper.Stmt
        module L =
          struct
            let function_ = "function"
            let var = "var"
            let return = "return"
            let eq = "="
            let require = "require"
            let exports = "exports"
            let dot = "."
            let comma = ","
            let colon = ":"
            let throw = "throw"
            let default = "default"
            let length = "length"
            let char_code_at = "charCodeAt"
            let new_ = "new"
            let array = "Array"
            let question = "?"
            let plusplus = "++"
            let minusminus = "--"
            let semi = ";"
            let empty_block = "empty_block"
            let start_block = "start_block"
            let end_block = "end_block"
          end
        let return_indent = (String.length L.return) / Ext_pp.indent_length
        let throw_indent = (String.length L.throw) / Ext_pp.indent_length
        let string_of_number v =
          if v = infinity
          then "Infinity"
          else
            if v = neg_infinity
            then "-Infinity"
            else
              if v <> v
              then "NaN"
              else
                (let vint = int_of_float v in
                 if (float_of_int vint) = v
                 then
                   let rec div n i =
                     if (n <> 0) && ((n mod 10) = 0)
                     then div (n / 10) (succ i)
                     else
                       if i > 2
                       then Printf.sprintf "%de%d" n i
                       else string_of_int vint in
                   div vint 0
                 else
                   (let s1 = Printf.sprintf "%.12g" v in
                    if v = (float_of_string s1)
                    then s1
                    else
                      (let s2 = Printf.sprintf "%.15g" v in
                       if v = (float_of_string s2)
                       then s2
                       else Printf.sprintf "%.18g" v)))
        let semi f = P.string f L.semi
        let (op_prec,op_str) = let open Js_op_util in (op_prec, op_str)
        let best_string_quote s =
          let simple = ref 0 in
          let double = ref 0 in
          for i = 0 to (String.length s) - 1 do
            (match s.[i] with
             | '\'' -> incr simple
             | '"' -> incr double
             | _ -> ())
          done;
          if (!simple) < (!double) then '\'' else '"'
        let ident (cxt : Ext_pp_scope.t) f (id : Ident.t) =
          (if Ext_ident.is_js id
           then (P.string f id.name; cxt)
           else
             (let name = Ext_ident.convert id.name in
              let (i,new_cxt) = Ext_pp_scope.string_of_id id cxt in
              let () =
                P.string f
                  (if i == 0 then name else Printf.sprintf "%s$%d" name i) in
              new_cxt) : Ext_pp_scope.t)
        let pp_string f ?(quote= '"')  ?(utf= false)  s =
          let array_str1 =
            Array.init 256 (fun i  -> String.make 1 (Char.chr i)) in
          let array_conv =
            Array.init 16 (fun i  -> String.make 1 ("0123456789abcdef".[i])) in
          let quote_s = String.make 1 quote in
          P.string f quote_s;
          (let l = String.length s in
           for i = 0 to l - 1 do
             (let c = s.[i] in
              match c with
              | '\000' when
                  (i = (l - 1)) ||
                    (((s.[i + 1]) < '0') || ((s.[i + 1]) > '9'))
                  -> P.string f "\\0"
              | '\b' -> P.string f "\\b"
              | '\t' -> P.string f "\\t"
              | '\n' -> P.string f "\\n"
              | '\012' -> P.string f "\\f"
              | '\\' when not utf -> P.string f "\\\\"
              | '\r' -> P.string f "\\r"
              | '\000'..'\031'|'\127' ->
                  let c = Char.code c in
                  (P.string f "\\x";
                   P.string f (Array.unsafe_get array_conv (c lsr 4));
                   P.string f (Array.unsafe_get array_conv (c land 15)))
              | '\128'..'\255' when not utf ->
                  let c = Char.code c in
                  (P.string f "\\x";
                   P.string f (Array.unsafe_get array_conv (c lsr 4));
                   P.string f (Array.unsafe_get array_conv (c land 15)))
              | _ ->
                  if c = quote
                  then
                    (P.string f "\\";
                     P.string f (Array.unsafe_get array_str1 (Char.code c)))
                  else P.string f (Array.unsafe_get array_str1 (Char.code c)))
           done;
           P.string f quote_s)
        let pp_quote_string f s =
          pp_string f ~utf:false ~quote:(best_string_quote s) s
        let rec pp_function cxt (f : P.t) ?name  return (l : Ident.t list)
          (b : J.block) (env : Js_fun_env.t) =
          let ipp_ident cxt f id un_used =
            if un_used
            then ident cxt f (Ext_ident.make_unused ())
            else ident cxt f id in
          let rec formal_parameter_list cxt (f : P.t) l =
            let rec aux i cxt l =
              match l with
              | [] -> cxt
              | id::[] -> ipp_ident cxt f id (Js_fun_env.get_unused env i)
              | id::r ->
                  let cxt = ipp_ident cxt f id (Js_fun_env.get_unused env i) in
                  (P.string f L.comma; P.space f; aux (i + 1) cxt r) in
            match l with
            | [] -> cxt
            | i::[] ->
                if Js_fun_env.get_unused env 0 then cxt else ident cxt f i
            | _ -> aux 0 cxt l in
          let rec aux cxt f ls =
            match ls with
            | [] -> cxt
            | x::[] -> ident cxt f x
            | y::ys ->
                let cxt = ident cxt f y in (P.string f L.comma; aux cxt f ys) in
          let set_env =
            match name with
            | None  -> Js_fun_env.get_bound env
            | Some id -> Ident_set.add id (Js_fun_env.get_bound env) in
          let outer_cxt = Ext_pp_scope.merge set_env cxt in
          let inner_cxt = Ext_pp_scope.sub_scope outer_cxt set_env in
          (let action return =
             if return then P.string f "return " else ();
             P.string f L.function_;
             P.space f;
             (match name with
              | None  -> ()
              | Some x -> ignore (ident inner_cxt f x));
             (let body_cxt =
                P.paren_group f 1
                  (fun _  -> formal_parameter_list inner_cxt f l) in
              P.space f;
              ignore @@
                (P.brace_vgroup f 1
                   (fun _  -> statement_list false body_cxt f b))) in
           let lexical = Js_fun_env.get_lexical_scope env in
           let enclose action lexical return =
             if Ident_set.is_empty lexical
             then action return
             else
               (let lexical = Ident_set.elements lexical in
                if return then P.string f "return " else ();
                P.string f "(function(";
                ignore @@ (aux inner_cxt f lexical);
                P.string f ")";
                P.brace_vgroup f 0 (fun _  -> action true);
                P.string f "(";
                ignore @@ (aux inner_cxt f lexical);
                P.string f ")";
                P.string f ")") in
           enclose action lexical return);
          outer_cxt
        and output_one :
          'a . _ -> P.t -> (P.t -> 'a -> unit) -> 'a J.case_clause -> _=
          fun cxt  ->
            fun f  ->
              fun pp_cond  ->
                fun ({ case = e; body = (sl,break) } : _ J.case_clause)  ->
                  let cxt =
                    (P.group f 1) @@
                      (fun _  ->
                         (P.group f 1) @@
                           ((fun _  ->
                               P.string f "case ";
                               pp_cond f e;
                               P.space f;
                               P.string f L.colon));
                         P.space f;
                         (P.group f 1) @@
                           ((fun _  ->
                               let cxt =
                                 match sl with
                                 | [] -> cxt
                                 | _ ->
                                     (P.newline f;
                                      statement_list false cxt f sl) in
                               if break
                               then (P.newline f; P.string f "break"; semi f);
                               cxt))) in
                  P.newline f; cxt
        and loop :
          'a .
            Ext_pp_scope.t ->
              P.t ->
                (P.t -> 'a -> unit) ->
                  'a J.case_clause list -> Ext_pp_scope.t=
          fun cxt  ->
            fun f  ->
              fun pp_cond  ->
                fun cases  ->
                  match cases with
                  | [] -> cxt
                  | x::[] -> output_one cxt f pp_cond x
                  | x::xs ->
                      let cxt = output_one cxt f pp_cond x in
                      loop cxt f pp_cond xs
        and vident cxt f (v : J.vident) =
          match v with
          | Id v|Qualified (v,_,None ) -> ident cxt f v
          | Qualified (id,_,Some name) ->
              let cxt = ident cxt f id in
              (P.string f "."; P.string f (Ext_ident.convert name); cxt)
        and expression l cxt f (exp : J.expression) =
          (pp_comment_option f exp.comment;
           expression_desc cxt l f exp.expression_desc : Ext_pp_scope.t)
        and expression_desc cxt (l : int) f expression_desc =
          (match expression_desc with
           | Var v -> vident cxt f v
           | Seq (e1,e2) ->
               let action () =
                 let cxt = expression 0 cxt f e1 in
                 P.string f L.comma; P.space f; expression 0 cxt f e2 in
               if l > 0 then P.paren_group f 1 action else action ()
           | Fun (l,b,env) -> pp_function cxt f false l b env
           | Call (e,el,info) ->
               let action () =
                 P.group f 1
                   (fun _  ->
                      let () =
                        match info with
                        | { arity = NA  } -> ipp_comment f (Some "!")
                        | _ -> () in
                      let cxt = expression 15 cxt f e in
                      P.paren_group f 1 (fun _  -> arguments cxt f el)) in
               if l > 15 then P.paren_group f 1 action else action ()
           | Tag_ml_obj e ->
               P.group f 1
                 (fun _  ->
                    P.string f "Object.defineProperty";
                    P.paren_group f 1
                      (fun _  ->
                         let cxt = expression 1 cxt f e in
                         P.string f L.comma;
                         P.space f;
                         P.string f {|"##ml"|};
                         P.string f L.comma;
                         P.string f {|{"value" : true, "writable" : false}|};
                         cxt))
           | FlatCall (e,el) ->
               P.group f 1
                 (fun _  ->
                    let cxt = expression 15 cxt f e in
                    P.string f ".apply";
                    P.paren_group f 1
                      (fun _  ->
                         P.string f "null";
                         P.string f L.comma;
                         P.space f;
                         expression 1 cxt f el))
           | String_of_small_int_array e ->
               let action () =
                 P.group f 1
                   (fun _  ->
                      P.string f "String.fromCharCode.apply";
                      P.paren_group f 1
                        (fun _  ->
                           P.string f "null";
                           P.string f L.comma;
                           expression 1 cxt f e)) in
               if l > 15 then P.paren_group f 1 action else action ()
           | Array_append (e,el) ->
               P.group f 1
                 (fun _  ->
                    let cxt = expression 15 cxt f e in
                    P.string f ".concat";
                    P.paren_group f 1 (fun _  -> arguments cxt f el))
           | Dump (level,el) ->
               let obj =
                 match level with
                 | Log  -> "log"
                 | Info  -> "info"
                 | Warn  -> "warn"
                 | Error  -> "error" in
               P.group f 1
                 (fun _  ->
                    P.string f "console.";
                    P.string f obj;
                    P.paren_group f 1 (fun _  -> arguments cxt f el))
           | Char_to_int e ->
               (match e.expression_desc with
                | String_access (a,b) ->
                    P.group f 1
                      (fun _  ->
                         let cxt = expression 15 cxt f a in
                         P.string f L.dot;
                         P.string f L.char_code_at;
                         P.paren_group f 1 (fun _  -> expression 0 cxt f b))
                | _ ->
                    P.group f 1
                      (fun _  ->
                         let cxt = expression 15 cxt f e in
                         P.string f L.dot;
                         P.string f L.char_code_at;
                         P.string f "(0)";
                         cxt))
           | Char_of_int e ->
               P.group f 1
                 (fun _  ->
                    P.string f "String";
                    P.string f L.dot;
                    P.string f "fromCharCode";
                    P.paren_group f 1 (fun _  -> arguments cxt f [e]))
           | Math (name,el) ->
               P.group f 1
                 (fun _  ->
                    P.string f "Math";
                    P.string f L.dot;
                    P.string f name;
                    P.paren_group f 1 (fun _  -> arguments cxt f el))
           | Str (_,s) ->
               let quote = best_string_quote s in (pp_string f ~quote s; cxt)
           | Number v ->
               let s =
                 match v with
                 | Float v -> string_of_number v
                 | Int { i = v;_} -> string_of_int v in
               let need_paren =
                 if (s.[0]) = '-'
                 then l > 13
                 else (l = 15) && (((s.[0]) <> 'I') && ((s.[0]) <> 'N')) in
               let action _ = P.string f s in
               (if need_paren then P.paren f action else action (); cxt)
           | Int_of_boolean e ->
               let action () =
                 (P.group f 0) @@
                   (fun _  -> P.string f "+"; expression 13 cxt f e) in
               if l > 12 then P.paren_group f 1 action else action ()
           | Not e ->
               let action () = P.string f "!"; expression 13 cxt f e in
               if l > 13 then P.paren_group f 1 action else action ()
           | Is_type_number e ->
               let action () =
                 P.string f "typeof";
                 P.space f;
                 (let cxt = expression 13 cxt f e in
                  P.space f;
                  P.string f "===";
                  P.space f;
                  P.string f {|"number"|};
                  cxt) in
               let (out,_lft,_rght) = op_prec EqEqEq in
               if l > out then P.paren_group f 1 action else action ()
           | Bin
               (Eq
                ,{ expression_desc = Var i },{
                                               expression_desc =
                                                 (Bin
                                                  ((Plus  as op),{
                                                                   expression_desc
                                                                    = Var j
                                                                   },delta)
                                                  |Bin
                                                  ((Plus  as op),delta,
                                                   { expression_desc = Var j
                                                     })|Bin
                                                  ((Minus  as op),{
                                                                    expression_desc
                                                                    = Var j },delta))
                                               })
               when Js_op_util.same_vident i j ->
               (match (delta, op) with
                | ({ expression_desc = Number (Int { i = 1;_}) },Plus )
                  |({ expression_desc = Number (Int { i = (-1);_}) },Minus )
                    -> (P.string f L.plusplus; P.space f; vident cxt f i)
                | ({ expression_desc = Number (Int { i = (-1);_}) },Plus )
                  |({ expression_desc = Number (Int { i = 1;_}) },Minus ) ->
                    (P.string f L.minusminus; P.space f; vident cxt f i)
                | (_,_) ->
                    let cxt = vident cxt f i in
                    (P.space f;
                     if op = Plus then P.string f "+=" else P.string f "-=";
                     P.space f;
                     expression 13 cxt f delta))
           | Bin
               (Eq
                ,{
                   expression_desc = Access
                     ({ expression_desc = Var i;_},{
                                                     expression_desc = Number
                                                       (Int { i = k0 })
                                                     })
                   },{
                       expression_desc =
                         (Bin
                          ((Plus  as op),{
                                           expression_desc = Access
                                             ({ expression_desc = Var j;_},
                                              {
                                                expression_desc = Number (Int
                                                  { i = k1 })
                                                });_},delta)|Bin
                          ((Plus  as op),delta,{
                                                 expression_desc = Access
                                                   ({
                                                      expression_desc = Var j;_},
                                                    {
                                                      expression_desc =
                                                        Number (Int
                                                        { i = k1 })
                                                      });_})|Bin
                          ((Minus  as op),{
                                            expression_desc = Access
                                              ({ expression_desc = Var j;_},
                                               {
                                                 expression_desc = Number
                                                   (Int { i = k1 })
                                                 });_},delta))
                       })
               when (k0 = k1) && (Js_op_util.same_vident i j) ->
               let aux cxt f vid i =
                 let cxt = vident cxt f vid in
                 P.string f "[";
                 P.string f (string_of_int i);
                 P.string f "]";
                 cxt in
               (match (delta, op) with
                | ({ expression_desc = Number (Int { i = 1;_}) },Plus )
                  |({ expression_desc = Number (Int { i = (-1);_}) },Minus )
                    -> (P.string f L.plusplus; P.space f; aux cxt f i k0)
                | ({ expression_desc = Number (Int { i = (-1);_}) },Plus )
                  |({ expression_desc = Number (Int { i = 1;_}) },Minus ) ->
                    (P.string f L.minusminus; P.space f; aux cxt f i k0)
                | (_,_) ->
                    let cxt = aux cxt f i k0 in
                    (P.space f;
                     if op = Plus then P.string f "+=" else P.string f "-=";
                     P.space f;
                     expression 13 cxt f delta))
           | Bin
               (Minus
                ,{ expression_desc = Number (Int { i = 0;_}|Float 0.) },e)
               ->
               let action () = P.string f "-"; expression 13 cxt f e in
               if l > 13 then P.paren_group f 1 action else action ()
           | Bin (op,e1,e2) ->
               let (out,lft,rght) = op_prec op in
               let need_paren =
                 (l > out) ||
                   (match op with | Lsl |Lsr |Asr  -> true | _ -> false) in
               let action () =
                 let cxt = expression lft cxt f e1 in
                 P.space f;
                 P.string f (op_str op);
                 P.space f;
                 expression rght cxt f e2 in
               if need_paren then P.paren_group f 1 action else action ()
           | String_append (e1,e2) ->
               let op: Js_op.binop = Plus in
               let (out,lft,rght) = op_prec op in
               let need_paren =
                 (l > out) ||
                   (match op with | Lsl |Lsr |Asr  -> true | _ -> false) in
               let action () =
                 let cxt = expression lft cxt f e1 in
                 P.space f;
                 P.string f "+";
                 P.space f;
                 expression rght cxt f e2 in
               if need_paren then P.paren_group f 1 action else action ()
           | Array (el,_) ->
               (match el with
                | []|_::[] ->
                    (P.bracket_group f 1) @@
                      ((fun _  -> array_element_list cxt f el))
                | _ ->
                    (P.bracket_vgroup f 1) @@
                      ((fun _  -> array_element_list cxt f el)))
           | Access (e,e')|String_access (e,e') ->
               let action () =
                 (P.group f 1) @@
                   (fun _  ->
                      let cxt = expression 15 cxt f e in
                      (P.bracket_group f 1) @@
                        (fun _  -> expression 0 cxt f e')) in
               if l > 15 then P.paren_group f 1 action else action ()
           | Array_length e|String_length e|Bytes_length e|Function_length e
               ->
               let action () =
                 let cxt = expression 15 cxt f e in
                 P.string f L.dot; P.string f L.length; cxt in
               if l > 15 then P.paren_group f 1 action else action ()
           | Dot (e,nm,normal) ->
               if normal
               then
                 let action () =
                   let cxt = expression 15 cxt f e in
                   P.string f L.dot; P.string f (Ext_ident.convert nm); cxt in
                 (if l > 15 then P.paren_group f 1 action else action ())
               else
                 (let action () =
                    (P.group f 1) @@
                      (fun _  ->
                         let cxt = expression 15 cxt f e in
                         (P.bracket_group f 1) @@
                           ((fun _  ->
                               pp_string f ~quote:(best_string_quote nm) nm));
                         cxt) in
                  if l > 15 then P.paren_group f 1 action else action ())
           | New (e,el) ->
               let action () =
                 (P.group f 1) @@
                   (fun _  ->
                      P.string f L.new_;
                      P.space f;
                      (let cxt = expression 16 cxt f e in
                       (P.paren_group f 1) @@
                         (fun _  ->
                            match el with
                            | Some el -> arguments cxt f el
                            | None  -> cxt))) in
               if l > 15 then P.paren_group f 1 action else action ()
           | Array_of_size e ->
               let action () =
                 (P.group f 1) @@
                   (fun _  ->
                      P.string f L.new_;
                      P.space f;
                      P.string f L.array;
                      (P.paren_group f 1) @@
                        ((fun _  -> expression 0 cxt f e))) in
               if l > 15 then P.paren_group f 1 action else action ()
           | Cond (e,e1,e2) ->
               let action () =
                 let cxt = expression 3 cxt f e in
                 P.space f;
                 P.string f L.question;
                 P.space f;
                 (let cxt =
                    (P.group f 1) @@ (fun _  -> expression 3 cxt f e1) in
                  P.space f;
                  P.string f L.colon;
                  P.space f;
                  (P.group f 1) @@ ((fun _  -> expression 3 cxt f e2))) in
               if l > 2 then P.paren_vgroup f 1 action else action ()
           | Object lst ->
               (P.brace_group f 1) @@
                 ((fun _  -> property_name_and_value_list cxt f lst)) : 
          Ext_pp_scope.t)
        and property_name cxt f (s : J.property_name) =
          (pp_string f ~utf:true ~quote:(best_string_quote s) s; cxt : 
          Ext_pp_scope.t)
        and property_name_and_value_list cxt f l =
          (match l with
           | [] -> cxt
           | (pn,e)::[] ->
               (P.group f 0) @@
                 ((fun _  ->
                     let cxt = property_name cxt f pn in
                     P.string f L.colon; P.space f; expression 1 cxt f e))
           | (pn,e)::r ->
               let cxt =
                 (P.group f 0) @@
                   (fun _  ->
                      let cxt = property_name cxt f pn in
                      P.string f L.colon; P.space f; expression 1 cxt f e) in
               (P.string f L.comma;
                P.newline f;
                property_name_and_value_list cxt f r) : Ext_pp_scope.t)
        and array_element_list cxt f el =
          (match el with
           | [] -> cxt
           | e::[] -> expression 1 cxt f e
           | e::r ->
               let cxt = expression 1 cxt f e in
               (P.string f L.comma; P.newline f; array_element_list cxt f r) : 
          Ext_pp_scope.t)
        and arguments cxt f l =
          (match l with
           | [] -> cxt
           | e::[] -> expression 1 cxt f e
           | e::r ->
               let cxt = expression 1 cxt f e in
               (P.string f L.comma; P.space f; arguments cxt f r) : Ext_pp_scope.t)
        and variable_declaration top cxt f
          (variable : J.variable_declaration) =
          (match variable with
           | { ident = i; value = None ; ident_info;_} ->
               if ident_info.used_stats = Dead_pure
               then cxt
               else
                 (P.string f L.var;
                  P.space f;
                  (let cxt = ident cxt f i in semi f; cxt))
           | { ident = i; value = Some e; ident_info = { used_stats;_} } ->
               (match used_stats with
                | Dead_pure  -> cxt
                | Dead_non_pure  -> statement_desc top cxt f (J.Exp e)
                | _ ->
                    (match (e, top) with
                     | ({ expression_desc = Fun (params,b,env); comment = _ },true
                        ) -> pp_function cxt f ~name:i false params b env
                     | (_,_) ->
                         (P.string f L.var;
                          P.space f;
                          (let cxt = ident cxt f i in
                           P.space f;
                           P.string f L.eq;
                           P.space f;
                           (let cxt = expression 1 cxt f e in semi f; cxt))))) : 
          Ext_pp_scope.t)
        and ipp_comment : 'a . P.t -> 'a -> unit=
          fun f  -> fun comment  -> ()
        and pp_comment f comment =
          if (String.length comment) > 0 then P.string f "/* ";
          P.string f comment;
          P.string f " */"[@@ocaml.text
                            " don't print a new line -- ASI \n    FIXME: this still does not work in some cases...\n    {[\n    return /* ... */\n    [... ]\n    ]}\n"]
        and pp_comment_option f comment =
          match comment with | None  -> () | Some x -> pp_comment f x
        and statement top cxt f
          ({ statement_desc = s; comment;_} : J.statement) =
          (pp_comment_option f comment; statement_desc top cxt f s : 
          Ext_pp_scope.t)
        and statement_desc top cxt f (s : J.statement_desc) =
          (match s with
           | Block [] -> (ipp_comment f L.empty_block; cxt)
           | Block b ->
               (ipp_comment f L.start_block;
                (let cxt = statement_list top cxt f b in
                 ipp_comment f L.end_block; cxt))
           | Variable l -> variable_declaration top cxt f l
           | Exp { expression_desc = Var _ } -> (semi f; cxt)
           | Exp e ->
               let rec need_paren (e : J.expression) =
                 match e.expression_desc with
                 | Call ({ expression_desc = Fun _ },_,_) -> true
                 | Fun _|Object _ -> true
                 | String_of_small_int_array _|Call _|Array_append _
                   |Tag_ml_obj _|Seq _|Dot _|Cond _|Bin _|String_access _
                   |Access _|Array_of_size _|Array_length _|String_length _
                   |Bytes_length _|String_append _|Char_of_int _|Char_to_int
                   _|Dump _|Math _|Var _|Str _|Array _|FlatCall _
                   |Is_type_number _|Function_length _|Number _|Not _|New _
                   |Int_of_boolean _ -> false in
               let cxt =
                 (if need_paren e then P.paren_group f 1 else P.group f 0)
                   (fun _  -> expression 0 cxt f e) in
               (semi f; cxt)
           | If (e,s1,s2) ->
               let cxt =
                 P.string f "if";
                 P.space f;
                 (P.paren_group f 1) @@ ((fun _  -> expression 0 cxt f e)) in
               (P.space f;
                (let cxt = block cxt f s1 in
                 match s2 with
                 | None |Some []|Some ({ statement_desc = Block [] }::[]) ->
                     (P.newline f; cxt)
                 | Some s2 ->
                     (P.newline f;
                      P.string f "else";
                      P.space f;
                      block cxt f s2)))
           | While (label,e,s,_env) ->
               ((match label with
                 | Some i -> (P.string f i; P.string f L.colon; P.newline f)
                 | None  -> ());
                P.string f "while";
                (let cxt =
                   (P.paren_group f 1) @@ (fun _  -> expression 0 cxt f e) in
                 P.space f; (let cxt = block cxt f s in semi f; cxt)))
           | ForRange (for_ident_expression,finish,id,direction,s,env) ->
               let action cxt =
                 (P.vgroup f 0) @@
                   (fun _  ->
                      let cxt =
                        (P.group f 0) @@
                          (fun _  ->
                             P.string f "for";
                             (P.paren_group f 1) @@
                               ((fun _  ->
                                   let (cxt,new_id) =
                                     match (for_ident_expression,
                                             (finish.expression_desc))
                                     with
                                     | (Some
                                        ident_expression,(Number _|Var _)) ->
                                         (P.string f L.var;
                                          P.space f;
                                          (let cxt = ident cxt f id in
                                           P.space f;
                                           P.string f L.eq;
                                           P.space f;
                                           ((expression 0 cxt f
                                               ident_expression), None)))
                                     | (Some ident_expression,_) ->
                                         (P.string f L.var;
                                          P.space f;
                                          (let cxt = ident cxt f id in
                                           P.space f;
                                           P.string f L.eq;
                                           P.space f;
                                           (let cxt =
                                              expression 1 cxt f
                                                ident_expression in
                                            P.space f;
                                            P.string f L.comma;
                                            (let id =
                                               Ext_ident.create
                                                 ((Ident.name id) ^ "_finish") in
                                             let cxt = ident cxt f id in
                                             P.space f;
                                             P.string f L.eq;
                                             P.space f;
                                             ((expression 1 cxt f finish),
                                               (Some id))))))
                                     | (None ,(Number _|Var _)) ->
                                         (cxt, None)
                                     | (None ,_) ->
                                         (P.string f L.var;
                                          P.string f " ";
                                          (let id =
                                             Ext_ident.create
                                               ((Ident.name id) ^ "_finish") in
                                           let cxt = ident cxt f id in
                                           P.string f " = ";
                                           ((expression 15 cxt f finish),
                                             (Some id)))) in
                                   semi f;
                                   P.space f;
                                   (let cxt = ident cxt f id in
                                    let right_prec =
                                      match direction with
                                      | Upto  ->
                                          let (_,_,right) = op_prec Le in
                                          (P.string f "<="; right)
                                      | Downto  ->
                                          let (_,_,right) = op_prec Ge in
                                          (P.string f ">="; right) in
                                    P.space f;
                                    (let cxt =
                                       match new_id with
                                       | Some i ->
                                           expression right_prec cxt f
                                             (E.var i)
                                       | None  ->
                                           expression right_prec cxt f finish in
                                     semi f;
                                     P.space f;
                                     (let () =
                                        match direction with
                                        | Upto  -> P.string f "++"
                                        | Downto  -> P.string f "--" in
                                      ident cxt f id)))))) in
                      block cxt f s) in
               let lexical = Js_closure.get_lexical_scope env in
               if Ident_set.is_empty lexical
               then action cxt
               else
                 (let inner_cxt = Ext_pp_scope.merge lexical cxt in
                  let lexical = Ident_set.elements lexical in
                  let _enclose action inner_cxt lexical =
                    let rec aux cxt f ls =
                      match ls with
                      | [] -> cxt
                      | x::[] -> ident cxt f x
                      | y::ys ->
                          let cxt = ident cxt f y in
                          (P.string f L.comma; aux cxt f ys) in
                    P.vgroup f 0
                      (fun _  ->
                         P.string f "(function(";
                         ignore @@ (aux inner_cxt f lexical);
                         P.string f ")";
                         (let cxt =
                            P.brace_vgroup f 0 (fun _  -> action inner_cxt) in
                          P.string f "(";
                          ignore @@ (aux inner_cxt f lexical);
                          P.string f ")";
                          P.string f ")";
                          semi f;
                          cxt)) in
                  _enclose action inner_cxt lexical)
           | Continue s ->
               (P.string f "continue ";
                P.string f s;
                semi f;
                P.newline f;
                cxt)
           | Break  -> (P.string f "break "; semi f; P.newline f; cxt)
           | Return { return_value = e } ->
               (match e with
                | { expression_desc = Fun (l,b,env);_} ->
                    let cxt = pp_function cxt f true l b env in (semi f; cxt)
                | e ->
                    (P.string f L.return;
                     P.space f;
                     (P.group f return_indent) @@
                       ((fun _  ->
                           let cxt = expression 0 cxt f e in semi f; cxt))))
           | Int_switch (e,cc,def) ->
               (P.string f "switch";
                P.space f;
                (let cxt =
                   (P.paren_group f 1) @@ (fun _  -> expression 0 cxt f e) in
                 P.space f;
                 (P.brace_vgroup f 1) @@
                   ((fun _  ->
                       let cxt =
                         loop cxt f
                           (fun f  -> fun i  -> P.string f (string_of_int i))
                           cc in
                       match def with
                       | None  -> cxt
                       | Some def ->
                           (P.group f 1) @@
                             ((fun _  ->
                                 P.string f L.default;
                                 P.string f L.colon;
                                 P.newline f;
                                 statement_list false cxt f def))))))
           | String_switch (e,cc,def) ->
               (P.string f "switch";
                P.space f;
                (let cxt =
                   (P.paren_group f 1) @@ (fun _  -> expression 0 cxt f e) in
                 P.space f;
                 (P.brace_vgroup f 1) @@
                   ((fun _  ->
                       let cxt =
                         loop cxt f (fun f  -> fun i  -> pp_quote_string f i)
                           cc in
                       match def with
                       | None  -> cxt
                       | Some def ->
                           (P.group f 1) @@
                             ((fun _  ->
                                 P.string f L.default;
                                 P.string f L.colon;
                                 P.newline f;
                                 statement_list false cxt f def))))))
           | Throw e ->
               (P.string f L.throw;
                P.space f;
                (P.group f throw_indent) @@
                  ((fun _  -> let cxt = expression 0 cxt f e in semi f; cxt)))
           | Try (b,ctch,fin) ->
               (P.vgroup f 0) @@
                 ((fun _  ->
                     P.string f "try";
                     P.space f;
                     (let cxt = block cxt f b in
                      let cxt =
                        match ctch with
                        | None  -> cxt
                        | Some (i,b) ->
                            (P.newline f;
                             P.string f "catch (";
                             (let cxt = ident cxt f i in
                              P.string f ")"; block cxt f b)) in
                      match fin with
                      | None  -> cxt
                      | Some b ->
                          (P.group f 1) @@
                            ((fun _  ->
                                P.string f "finally";
                                P.space f;
                                block cxt f b))))) : Ext_pp_scope.t)
        and statement_list top cxt f b =
          match b with
          | [] -> cxt
          | s::[] -> statement top cxt f s
          | s::r ->
              let cxt = statement top cxt f s in
              (P.newline f;
               if top then P.force_newline f;
               statement_list top cxt f r)
        and block cxt f b =
          P.brace_vgroup f 1 (fun _  -> statement_list false cxt f b)
        let requires cxt f (modules : (Ident.t* string) list) =
          P.newline f;
          (let rec aux cxt modules =
             match modules with
             | [] -> cxt
             | (id,s)::rest ->
                 let cxt =
                   (P.group f 0) @@
                     (fun _  ->
                        P.string f L.var;
                        P.space f;
                        (let cxt = ident cxt f id in
                         P.space f;
                         P.string f L.eq;
                         P.space f;
                         P.string f L.require;
                         (P.paren_group f 0) @@
                           ((fun _  ->
                               pp_string f ~utf:true
                                 ~quote:(best_string_quote s) s));
                         cxt)) in
                 (semi f; P.newline f; aux cxt rest) in
           aux cxt modules)
        let exports cxt f (idents : Ident.t list) =
          P.newline f;
          List.iter
            (fun (id : Ident.t)  ->
               (P.group f 0) @@
                 ((fun _  ->
                     P.string f L.exports;
                     P.string f L.dot;
                     P.string f (Ext_ident.convert id.name);
                     P.space f;
                     P.string f L.eq;
                     P.space f;
                     ignore @@ (ident cxt f id);
                     semi f));
               P.newline f) idents
        let node_program f
          ({ modules; block = b; exports = exp; side_effect } : J.program) =
          let cxt = Ext_pp_scope.empty in
          let cxt = requires cxt f modules in
          let () = P.force_newline f in
          let cxt = statement_list true cxt f b in
          let () = P.force_newline f in exports cxt f exp
        let amd_program f
          ({ modules; block = b; exports = exp; side_effect } : J.program) =
          let rec aux cxt f modules =
            match modules with
            | [] -> cxt
            | (id,_)::[] -> ident cxt f id
            | (id,_)::rest ->
                let cxt = ident cxt f id in
                (P.string f L.comma; aux cxt f rest) in
          P.newline f;
          (let cxt = Ext_pp_scope.empty in
           let rec list ~pp_sep  pp_v ppf =
             function
             | [] -> ()
             | v::[] -> pp_v ppf v
             | v::vs -> (pp_v ppf v; pp_sep ppf (); list ~pp_sep pp_v ppf vs) in
           (P.vgroup f 1) @@
             (fun _  ->
                P.string f "define([";
                list ~pp_sep:(fun f  -> fun _  -> P.string f L.comma)
                  (fun f  ->
                     fun (_,s)  ->
                       pp_string f ~utf:true ~quote:(best_string_quote s) s)
                  f modules;
                P.string f "]";
                P.string f L.comma;
                P.newline f;
                P.string f L.function_;
                P.string f "(";
                (let cxt = aux cxt f modules in
                 P.string f ")";
                 (P.brace_vgroup f 1) @@
                   ((fun _  ->
                       let cxt = statement_list true cxt f b in
                       P.newline f;
                       P.string f L.return;
                       P.space f;
                       (P.brace_vgroup f 1) @@
                         ((fun _  ->
                             let rec aux cxt f (idents : Ident.t list) =
                               match idents with
                               | [] -> cxt
                               | id::[] ->
                                   (P.string f (Ext_ident.convert id.name);
                                    P.space f;
                                    P.string f L.colon;
                                    P.space f;
                                    ident cxt f id)
                               | id::rest ->
                                   (P.string f (Ext_ident.convert id.name);
                                    P.space f;
                                    P.string f L.colon;
                                    P.space f;
                                    (let cxt = ident cxt f id in
                                     P.string f L.comma;
                                     P.space f;
                                     P.newline f;
                                     aux cxt f rest)) in
                             ignore @@ (aux cxt f exp)))));
                 P.string f ")")))
        let dump_program (program : J.program) (oc : out_channel) =
          let f = P.to_out_channel oc in
          let () =
            P.string f "// Generated CODE, PLEASE EDIT WITH CARE";
            P.newline f;
            P.newline f;
            P.string f {|"use strict";|} in
          (match Sys.getenv "OCAML_AMD_MODULE" with
           | exception Not_found  -> node_program f program
           | _ -> amd_program f program);
          P.string f
            (match program.side_effect with
             | None  -> "/* No side effect */"
             | Some v -> Printf.sprintf "/* %s fail the pure module */" v);
          P.newline f;
          P.flush f ()
      end 
    module Lam_compile_group :
      sig
        [@@@ocaml.text " OCamlscript entry point in the OCaml compiler "]
        [@@@ocaml.text
          " Compile and register the hook of function to compile  a lambda to JS IR \n "]
        val compile :
          filename:string ->
            Env.t -> Types.signature -> Lambda.lambda -> J.program[@@ocaml.doc
                                                                    " For toplevel, [filename] is [\"\"] which is the same as\n    {!Env.get_unit_name ()}\n "]
        val lambda_as_module :
          bool -> Env.t -> Types.signature -> string -> Lambda.lambda -> unit
      end =
      struct
        module E = J_helper.Exp
        module S = J_helper.Stmt
        open Js_output.Ops
        exception Not_a_module
        let compile_group
          (({ filename = file_name; env } as meta) : Lam_stats.meta)
          (x : Lam_util.group) =
          (match (x, file_name) with
           | (Single
              (_,({ name = ("stdout"|"stderr"|"stdin");_} as id),_),"pervasives.ml")
               ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.runtime_ref J_helper.io id.name))
           | (Single (_,({ name = "infinity";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.js_global "Infinity"))
           | (Single
              (_,({ name = "neg_infinity";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.js_global "-Infinity"))
           | (Single (_,({ name = "nan";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.js_global "NaN"))
           | (Single (_,({ name = "^";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.runtime_ref J_helper.string "add"))
           | (Single
              (_,({ name = "print_endline";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.js_global "console.log"))
           | (Single
              (_,({ name = "prerr_endline";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.js_global "console.error"))
           | (Single
              (_,({ name = "string_of_int";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.runtime_ref J_helper.prim "string_of_int"))
           | (Single (_,({ name = "max_float";_} as id),_),"pervasives.ml")
               ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.js_global_dot "Number" "MAX_VALUE"))
           | (Single (_,({ name = "min_float";_} as id),_),"pervasives.ml")
               ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.js_global_dot "Number" "MIN_VALUE"))
           | (Single
              (_,({ name = "epsilon_float";_} as id),_),"pervasives.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.js_global_dot "Number" "EPSILON"))
           | (Single (_,({ name = "cat";_} as id),_),"bytes.ml") ->
               Js_output.of_stmt @@
                 (S.const_variable id
                    ~exp:(E.runtime_ref J_helper.string "bytes_cat"))
           | (Single (_,({ name = "max_array_length";_} as id),_),"sys.ml")
               ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.float 4294967295.))
           | (Single
              (_,({ name = "max_int";_} as id),_),("sys.ml"|"nativeint.ml"))
               ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.float 9007199254740991.))
           | (Single
              (_,({ name = "min_int";_} as id),_),("sys.ml"|"nativeint.ml"))
               ->
               Js_output.of_stmt @@
                 (S.const_variable id ~exp:(E.float (-9007199254740991.)))
           | (Single (kind,id,lam),_) ->
               Lam_compile.compile_let kind
                 {
                   st = (Declare (kind, id));
                   should_return = False;
                   jmp_table = Lam_compile_defs.empty_handler_map;
                   meta
                 } id lam
           | (Recursive id_lams,_) ->
               Lam_compile.compile_recursive_lets
                 {
                   st = EffectCall;
                   should_return = False;
                   jmp_table = Lam_compile_defs.empty_handler_map;
                   meta
                 } id_lams
           | (Nop lam,_) ->
               Lam_compile.compile_lambda
                 {
                   st = EffectCall;
                   should_return = False;
                   jmp_table = Lam_compile_defs.empty_handler_map;
                   meta
                 } lam : Js_output.t)
        let compile ~filename  env sigs lam =
          (let exports = Translmod.get_export_identifiers () in
           let () = Translmod.reset () in
           let () = Lam_compile_env.reset () in
           let lam = Lam_util.deep_flatten lam in
           let _d = Lam_util.dump env filename in
           let meta =
             Lam_pass_collect.count_alias_globals env filename exports lam in
           let lam =
             let lam =
               (lam |> Lam_pass_exits.simplify_exits) |>
                 (Lam_pass_remove_alias.simplify_alias meta) in
             let lam = Lam_util.deep_flatten lam in
             let () = Lam_pass_collect.collect_helper meta lam in
             let lam = Lam_pass_remove_alias.simplify_alias meta lam in
             let lam = Lam_util.deep_flatten lam in
             let () = Lam_pass_collect.collect_helper meta lam in
             (((lam |> (Lam_pass_alpha_conversion.alpha_conversion meta)) |>
                 Lam_pass_exits.simplify_exits)
                |> Lam_pass_lets_dce.simplify_lets)
               |> Lam_pass_exits.simplify_exits in
           match (lam : Lambda.lambda) with
           | Lprim (Psetglobal id,biglambda::[]) ->
               (match Lam_util.flatten [] biglambda with
                | (Lprim (Pmakeblock (_,_,_),lambda_exports),rest) ->
                    let (coercion_groups,new_exports) =
                      List.fold_right2
                        (fun eid  ->
                           fun lam  ->
                             fun (coercions,new_exports)  ->
                               match (lam : Lambda.lambda) with
                               | Lvar id when
                                   (Ident.name id) = (Ident.name eid) ->
                                   (coercions, (id :: new_exports))
                               | _ ->
                                   (((Lam_util.Single (Strict, eid, lam)) ::
                                     coercions), (eid :: new_exports)))
                        meta.export_idents lambda_exports ([], []) in
                    let () = meta.export_idents <- new_exports in
                    let rest = List.rev_append rest coercion_groups in
                    let () =
                      if filename != ""
                      then
                        let f =
                          (Filename.chop_extension filename) ^ ".lambda" in
                        (Ext_pervasives.with_file_as_pp f) @@
                          (fun fmt  ->
                             Format.pp_print_list
                               ~pp_sep:Format.pp_print_newline
                               (Lam_util.pp_group env) fmt rest) in
                    let rest = Lam_dce.remove meta.export_idents rest in
                    let module E = struct exception Not_pure of string end in
                      let no_side_effects rest =
                        Ext_list.for_all_opt
                          (fun (x : Lam_util.group)  ->
                             match x with
                             | Single (kind,id,body) ->
                                 (match kind with
                                  | Strict |Variable  ->
                                      if
                                        not @@
                                          (Lam_util.no_side_effects body)
                                      then Some (Printf.sprintf "%s" id.name)
                                      else None
                                  | _ -> None)
                             | Recursive bindings ->
                                 Ext_list.for_all_opt
                                   (fun (id,lam)  ->
                                      if
                                        not @@ (Lam_util.no_side_effects lam)
                                      then
                                        Some
                                          (Printf.sprintf "%s" id.Ident.name)
                                      else None) bindings
                             | Nop lam ->
                                 if not @@ (Lam_util.no_side_effects lam)
                                 then Some ""
                                 else None) rest in
                      let maybe_pure = no_side_effects rest in
                      let body =
                        ((rest |>
                            (List.map
                               (fun group  -> compile_group meta group)))
                           |> Js_output.concat)
                          |> Js_output.to_block in
                      let external_module_ids =
                        Lam_compile_env.get_requried_modules meta.env
                          meta.required_modules
                          (Js_fold_basic.calculate_hard_dependencies body) in
                      let v =
                        Lam_stats_util.export_to_cmj meta maybe_pure
                          external_module_ids lambda_exports in
                      (Ext_marshal.to_file
                         ((Filename.chop_extension filename) ^ ".cmj") v;
                       (let js =
                          Js_program_loader.make_program filename v.pure
                            meta.export_idents external_module_ids body in
                        (((js |> Js_pass_flatten.program) |>
                            Js_pass_flatten_and_mark_dead.program)
                           |>
                           (fun js  ->
                              ignore @@ (Js_pass_scope.program js); js))
                          |> Js_shake.shake_program))
                | _ -> raise Not_a_module)
           | _ -> raise Not_a_module : J.program)[@@ocaml.doc
                                                   " Actually simplify_lets is kind of global optimization since it requires you to know whether \n    it's used or not \n"]
        let current_file_name: string option ref = ref None
        let lambda_as_module (raw : bool) env (sigs : Types.signature)
          (filename : string) (lam : Lambda.lambda) =
          let () = current_file_name := (Some filename) in
          Ext_pervasives.with_file_as_chan
            ((Filename.chop_extension filename) ^ ".js")
            (fun chan  ->
               Js_dump.dump_program (compile ~filename env sigs lam) chan)
        let () = Printlambda.serialize_raw_js := (lambda_as_module true)
      end 
    module Ident_util =
      struct
        [@@@ocaml.text " Utilities for [ident] type "]
        let print_identset set =
          Lambda.IdentSet.iter
            (fun x  -> Ext_log.err __LOC__ "@[%a@]@." Ident.print x) set
          [@@ocaml.text " Utilities for [ident] type "]
      end
    module Lam_runtime =
      struct
        [@@@ocaml.text " Pre-defined runtime function name "]
        let builtin_modules =
          [("caml_array", true);
          ("caml_format", true);
          ("caml_md5", true);
          ("caml_sys", true);
          ("caml_bigarray", true);
          ("caml_hash", true);
          ("caml_obj_runtime", true);
          ("caml_c_ffi", true);
          ("caml_int64", true);
          ("caml_polyfill", true);
          ("caml_exceptions", true);
          ("caml_unix", true);
          ("caml_io", true);
          ("caml_primitive", true);
          ("caml_utils", true);
          ("caml_file", true);
          ("caml_lexer", true);
          ("caml_float", true);
          ("caml_marshal", true);
          ("caml_string", true)][@@ocaml.text
                                  " Pre-defined runtime function name "]
      end
    module Js_implementation :
      sig
        [@@@ocaml.text " High level compilation module "]
        [@@@ocaml.text
          " This module defines a function to compile the program directly into [js]\n    given [filename] and [outputprefix], \n    it will be useful if we don't care about bytecode output(generating js only).\n "]
        val implementation : Format.formatter -> string -> string -> unit
        [@@ocaml.doc
          " [implementation ppf sourcefile outprefix] compiles to JS directly "]
      end =
      struct
        let fprintf = Format.fprintf
        let tool_name = "ocamlscript"
        let print_if ppf flag printer arg =
          if !flag then fprintf ppf "%a@." printer arg; arg
        let implementation ppf sourcefile outputprefix =
          Compmisc.init_path false;
          (let modulename =
             Compenv.module_of_filename ppf sourcefile outputprefix in
           Env.set_unit_name modulename;
           (let env = Compmisc.initial_env () in
            try
              let (typedtree,coercion,finalenv,current_signature) =
                ((((Pparse.parse_implementation ~tool_name ppf sourcefile) |>
                     (print_if ppf Clflags.dump_parsetree
                        Printast.implementation))
                    |> (print_if ppf Clflags.dump_source Pprintast.structure))
                   |>
                   (Typemod.type_implementation_more sourcefile outputprefix
                      modulename env))
                  |>
                  (print_if ppf Clflags.dump_typedtree
                     (fun fmt  ->
                        fun (ty,co,_,_)  ->
                          Printtyped.implementation_with_coercion fmt
                            (ty, co))) in
              if !Clflags.print_types
              then Warnings.check_fatal ()
              else
                (((typedtree, coercion) |>
                    (Translmod.transl_implementation modulename))
                   |>
                   (print_if ppf Clflags.dump_rawlambda Printlambda.lambda))
                  |>
                  ((fun lambda  ->
                      Lam_compile_group.lambda_as_module true finalenv
                        current_signature sourcefile lambda));
              Stypes.dump (Some (outputprefix ^ ".annot"))
            with
            | x -> (Stypes.dump (Some (outputprefix ^ ".annot")); raise x)))
      end 
    module Lam_pass_eliminate_ref : sig  end = struct  end 
    module Lam_map =
      struct
        open Lambda
        type ident = Ident.t
        class virtual map =
          object (o : 'self_type)
            method string : string -> string= o#unknown
            method ref :
              'a 'a_out .
                ('self_type -> 'a -> 'a_out) -> 'a ref -> 'a_out ref=
              fun _f_a  ->
                fun { contents = _x }  ->
                  let _x = _f_a o _x in { contents = _x }
            method option :
              'a 'a_out .
                ('self_type -> 'a -> 'a_out) -> 'a option -> 'a_out option=
              fun _f_a  ->
                function
                | None  -> None
                | Some _x -> let _x = _f_a o _x in Some _x
            method list :
              'a 'a_out .
                ('self_type -> 'a -> 'a_out) -> 'a list -> 'a_out list=
              fun _f_a  ->
                function
                | [] -> []
                | _x::_x_i1 ->
                    let _x = _f_a o _x in
                    let _x_i1 = o#list _f_a _x_i1 in _x :: _x_i1
            method int : int -> int= o#unknown
            method bool : bool -> bool=
              function | false  -> false | true  -> true
            method tag_info : tag_info -> tag_info=
              function
              | Constructor _x -> let _x = o#string _x in Constructor _x
              | Tuple  -> Tuple
              | Array  -> Array
              | Variant _x -> let _x = o#string _x in Variant _x
              | Record  -> Record
              | NA  -> NA
            method structured_constant :
              structured_constant -> structured_constant=
              function
              | Const_base _x -> let _x = o#unknown _x in Const_base _x
              | Const_pointer (_x,_x_i1) ->
                  let _x = o#int _x in
                  let _x_i1 = o#pointer_info _x_i1 in
                  Const_pointer (_x, _x_i1)
              | Const_block (_x,_x_i1,_x_i2) ->
                  let _x = o#int _x in
                  let _x_i1 = o#tag_info _x_i1 in
                  let _x_i2 = o#list (fun o  -> o#structured_constant) _x_i2 in
                  Const_block (_x, _x_i1, _x_i2)
              | Const_float_array _x ->
                  let _x = o#list (fun o  -> o#string) _x in
                  Const_float_array _x
              | Const_immstring _x ->
                  let _x = o#string _x in Const_immstring _x
            method shared_code : shared_code -> shared_code=
              o#list
                (fun o  ->
                   fun (_x,_x_i1)  ->
                     let _x = o#int _x in
                     let _x_i1 = o#int _x_i1 in (_x, _x_i1))
            method raise_kind : raise_kind -> raise_kind=
              function
              | Raise_regular  -> Raise_regular
              | Raise_reraise  -> Raise_reraise
              | Raise_notrace  -> Raise_notrace
            method public_info : public_info -> public_info=
              o#option (fun o  -> o#string)
            method primitive : primitive -> primitive=
              function
              | Pidentity  -> Pidentity
              | Pbytes_to_string  -> Pbytes_to_string
              | Pbytes_of_string  -> Pbytes_of_string
              | Pchar_to_int  -> Pchar_to_int
              | Pchar_of_int  -> Pchar_of_int
              | Pmark_ocaml_object  -> Pmark_ocaml_object
              | Pignore  -> Pignore
              | Prevapply _x -> let _x = o#unknown _x in Prevapply _x
              | Pdirapply _x -> let _x = o#unknown _x in Pdirapply _x
              | Ploc _x -> let _x = o#loc_kind _x in Ploc _x
              | Pgetglobal _x -> let _x = o#ident _x in Pgetglobal _x
              | Psetglobal _x -> let _x = o#ident _x in Psetglobal _x
              | Pmakeblock (_x,_x_i1,_x_i2) ->
                  let _x = o#int _x in
                  let _x_i1 = o#tag_info _x_i1 in
                  let _x_i2 = o#unknown _x_i2 in
                  Pmakeblock (_x, _x_i1, _x_i2)
              | Pfield _x -> let _x = o#int _x in Pfield _x
              | Psetfield (_x,_x_i1) ->
                  let _x = o#int _x in
                  let _x_i1 = o#bool _x_i1 in Psetfield (_x, _x_i1)
              | Pfloatfield _x -> let _x = o#int _x in Pfloatfield _x
              | Psetfloatfield _x -> let _x = o#int _x in Psetfloatfield _x
              | Pduprecord (_x,_x_i1) ->
                  let _x = o#unknown _x in
                  let _x_i1 = o#int _x_i1 in Pduprecord (_x, _x_i1)
              | Plazyforce  -> Plazyforce
              | Pccall _x -> let _x = o#unknown _x in Pccall _x
              | Praise _x -> let _x = o#raise_kind _x in Praise _x
              | Psequand  -> Psequand
              | Psequor  -> Psequor
              | Pnot  -> Pnot
              | Pnegint  -> Pnegint
              | Paddint  -> Paddint
              | Psubint  -> Psubint
              | Pmulint  -> Pmulint
              | Pdivint  -> Pdivint
              | Pmodint  -> Pmodint
              | Pandint  -> Pandint
              | Porint  -> Porint
              | Pxorint  -> Pxorint
              | Plslint  -> Plslint
              | Plsrint  -> Plsrint
              | Pasrint  -> Pasrint
              | Pintcomp _x -> let _x = o#comparison _x in Pintcomp _x
              | Poffsetint _x -> let _x = o#int _x in Poffsetint _x
              | Poffsetref _x -> let _x = o#int _x in Poffsetref _x
              | Pintoffloat  -> Pintoffloat
              | Pfloatofint  -> Pfloatofint
              | Pnegfloat  -> Pnegfloat
              | Pabsfloat  -> Pabsfloat
              | Paddfloat  -> Paddfloat
              | Psubfloat  -> Psubfloat
              | Pmulfloat  -> Pmulfloat
              | Pdivfloat  -> Pdivfloat
              | Pfloatcomp _x -> let _x = o#comparison _x in Pfloatcomp _x
              | Pstringlength  -> Pstringlength
              | Pstringrefu  -> Pstringrefu
              | Pstringsetu  -> Pstringsetu
              | Pstringrefs  -> Pstringrefs
              | Pstringsets  -> Pstringsets
              | Pbyteslength  -> Pbyteslength
              | Pbytesrefu  -> Pbytesrefu
              | Pbytessetu  -> Pbytessetu
              | Pbytesrefs  -> Pbytesrefs
              | Pbytessets  -> Pbytessets
              | Pmakearray _x -> let _x = o#array_kind _x in Pmakearray _x
              | Parraylength _x ->
                  let _x = o#array_kind _x in Parraylength _x
              | Parrayrefu _x -> let _x = o#array_kind _x in Parrayrefu _x
              | Parraysetu _x -> let _x = o#array_kind _x in Parraysetu _x
              | Parrayrefs _x -> let _x = o#array_kind _x in Parrayrefs _x
              | Parraysets _x -> let _x = o#array_kind _x in Parraysets _x
              | Pisint  -> Pisint
              | Pisout  -> Pisout
              | Pbittest  -> Pbittest
              | Pbintofint _x -> let _x = o#boxed_integer _x in Pbintofint _x
              | Pintofbint _x -> let _x = o#boxed_integer _x in Pintofbint _x
              | Pcvtbint (_x,_x_i1) ->
                  let _x = o#boxed_integer _x in
                  let _x_i1 = o#boxed_integer _x_i1 in Pcvtbint (_x, _x_i1)
              | Pnegbint _x -> let _x = o#boxed_integer _x in Pnegbint _x
              | Paddbint _x -> let _x = o#boxed_integer _x in Paddbint _x
              | Psubbint _x -> let _x = o#boxed_integer _x in Psubbint _x
              | Pmulbint _x -> let _x = o#boxed_integer _x in Pmulbint _x
              | Pdivbint _x -> let _x = o#boxed_integer _x in Pdivbint _x
              | Pmodbint _x -> let _x = o#boxed_integer _x in Pmodbint _x
              | Pandbint _x -> let _x = o#boxed_integer _x in Pandbint _x
              | Porbint _x -> let _x = o#boxed_integer _x in Porbint _x
              | Pxorbint _x -> let _x = o#boxed_integer _x in Pxorbint _x
              | Plslbint _x -> let _x = o#boxed_integer _x in Plslbint _x
              | Plsrbint _x -> let _x = o#boxed_integer _x in Plsrbint _x
              | Pasrbint _x -> let _x = o#boxed_integer _x in Pasrbint _x
              | Pbintcomp (_x,_x_i1) ->
                  let _x = o#boxed_integer _x in
                  let _x_i1 = o#comparison _x_i1 in Pbintcomp (_x, _x_i1)
              | Pbigarrayref (_x,_x_i1,_x_i2,_x_i3) ->
                  let _x = o#bool _x in
                  let _x_i1 = o#int _x_i1 in
                  let _x_i2 = o#bigarray_kind _x_i2 in
                  let _x_i3 = o#bigarray_layout _x_i3 in
                  Pbigarrayref (_x, _x_i1, _x_i2, _x_i3)
              | Pbigarrayset (_x,_x_i1,_x_i2,_x_i3) ->
                  let _x = o#bool _x in
                  let _x_i1 = o#int _x_i1 in
                  let _x_i2 = o#bigarray_kind _x_i2 in
                  let _x_i3 = o#bigarray_layout _x_i3 in
                  Pbigarrayset (_x, _x_i1, _x_i2, _x_i3)
              | Pbigarraydim _x -> let _x = o#int _x in Pbigarraydim _x
              | Pstring_load_16 _x ->
                  let _x = o#bool _x in Pstring_load_16 _x
              | Pstring_load_32 _x ->
                  let _x = o#bool _x in Pstring_load_32 _x
              | Pstring_load_64 _x ->
                  let _x = o#bool _x in Pstring_load_64 _x
              | Pstring_set_16 _x -> let _x = o#bool _x in Pstring_set_16 _x
              | Pstring_set_32 _x -> let _x = o#bool _x in Pstring_set_32 _x
              | Pstring_set_64 _x -> let _x = o#bool _x in Pstring_set_64 _x
              | Pbigstring_load_16 _x ->
                  let _x = o#bool _x in Pbigstring_load_16 _x
              | Pbigstring_load_32 _x ->
                  let _x = o#bool _x in Pbigstring_load_32 _x
              | Pbigstring_load_64 _x ->
                  let _x = o#bool _x in Pbigstring_load_64 _x
              | Pbigstring_set_16 _x ->
                  let _x = o#bool _x in Pbigstring_set_16 _x
              | Pbigstring_set_32 _x ->
                  let _x = o#bool _x in Pbigstring_set_32 _x
              | Pbigstring_set_64 _x ->
                  let _x = o#bool _x in Pbigstring_set_64 _x
              | Pctconst _x ->
                  let _x = o#compile_time_constant _x in Pctconst _x
              | Pbswap16  -> Pbswap16
              | Pbbswap _x -> let _x = o#boxed_integer _x in Pbbswap _x
              | Pint_as_pointer  -> Pint_as_pointer
            method pointer_info : pointer_info -> pointer_info=
              function
              | NullConstructor _x ->
                  let _x = o#string _x in NullConstructor _x
              | NullVariant _x -> let _x = o#string _x in NullVariant _x
              | NAPointer  -> NAPointer
            method meth_kind : meth_kind -> meth_kind=
              function
              | Self  -> Self
              | Public _x -> let _x = o#public_info _x in Public _x
              | Cached  -> Cached
            method loc_kind : loc_kind -> loc_kind=
              function
              | Loc_FILE  -> Loc_FILE
              | Loc_LINE  -> Loc_LINE
              | Loc_MODULE  -> Loc_MODULE
              | Loc_LOC  -> Loc_LOC
              | Loc_POS  -> Loc_POS
            method let_kind : let_kind -> let_kind=
              function
              | Strict  -> Strict
              | Alias  -> Alias
              | StrictOpt  -> StrictOpt
              | Variable  -> Variable
            method lambda_switch : lambda_switch -> lambda_switch=
              fun
                { sw_numconsts = _x; sw_consts = _x_i1; sw_numblocks = _x_i2;
                  sw_blocks = _x_i3; sw_failaction = _x_i4 }
                 ->
                let _x = o#int _x in
                let _x_i1 =
                  o#list
                    (fun o  ->
                       fun (_x,_x_i1)  ->
                         let _x = o#int _x in
                         let _x_i1 = o#lambda _x_i1 in (_x, _x_i1)) _x_i1 in
                let _x_i2 = o#int _x_i2 in
                let _x_i3 =
                  o#list
                    (fun o  ->
                       fun (_x,_x_i1)  ->
                         let _x = o#int _x in
                         let _x_i1 = o#lambda _x_i1 in (_x, _x_i1)) _x_i3 in
                let _x_i4 = o#option (fun o  -> o#lambda) _x_i4 in
                {
                  sw_numconsts = _x;
                  sw_consts = _x_i1;
                  sw_numblocks = _x_i2;
                  sw_blocks = _x_i3;
                  sw_failaction = _x_i4
                }
            method lambda_event_kind :
              lambda_event_kind -> lambda_event_kind=
              function
              | Lev_before  -> Lev_before
              | Lev_after _x -> let _x = o#unknown _x in Lev_after _x
              | Lev_function  -> Lev_function
            method lambda_event : lambda_event -> lambda_event=
              fun
                { lev_loc = _x; lev_kind = _x_i1; lev_repr = _x_i2;
                  lev_env = _x_i3 }
                 ->
                let _x = o#unknown _x in
                let _x_i1 = o#lambda_event_kind _x_i1 in
                let _x_i2 =
                  o#option (fun o  -> o#ref (fun o  -> o#int)) _x_i2 in
                let _x_i3 = o#unknown _x_i3 in
                {
                  lev_loc = _x;
                  lev_kind = _x_i1;
                  lev_repr = _x_i2;
                  lev_env = _x_i3
                }
            method lambda : lambda -> lambda=
              function
              | Lvar _x -> let _x = o#ident _x in Lvar _x
              | Lconst _x -> let _x = o#structured_constant _x in Lconst _x
              | Lapply (_x,_x_i1,_x_i2) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#list (fun o  -> o#lambda) _x_i1 in
                  let _x_i2 = o#apply_info _x_i2 in Lapply (_x, _x_i1, _x_i2)
              | Lfunction (_x,_x_i1,_x_i2) ->
                  let _x = o#function_kind _x in
                  let _x_i1 = o#list (fun o  -> o#ident) _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in Lfunction (_x, _x_i1, _x_i2)
              | Llet (_x,_x_i1,_x_i2,_x_i3) ->
                  let _x = o#let_kind _x in
                  let _x_i1 = o#ident _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in
                  let _x_i3 = o#lambda _x_i3 in
                  Llet (_x, _x_i1, _x_i2, _x_i3)
              | Lletrec (_x,_x_i1) ->
                  let _x =
                    o#list
                      (fun o  ->
                         fun (_x,_x_i1)  ->
                           let _x = o#ident _x in
                           let _x_i1 = o#lambda _x_i1 in (_x, _x_i1)) _x in
                  let _x_i1 = o#lambda _x_i1 in Lletrec (_x, _x_i1)
              | Lprim (_x,_x_i1) ->
                  let _x = o#primitive _x in
                  let _x_i1 = o#list (fun o  -> o#lambda) _x_i1 in
                  Lprim (_x, _x_i1)
              | Lswitch (_x,_x_i1) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#lambda_switch _x_i1 in Lswitch (_x, _x_i1)
              | Lstringswitch (_x,_x_i1,_x_i2) ->
                  let _x = o#lambda _x in
                  let _x_i1 =
                    o#list
                      (fun o  ->
                         fun (_x,_x_i1)  ->
                           let _x = o#string _x in
                           let _x_i1 = o#lambda _x_i1 in (_x, _x_i1)) _x_i1 in
                  let _x_i2 = o#option (fun o  -> o#lambda) _x_i2 in
                  Lstringswitch (_x, _x_i1, _x_i2)
              | Lstaticraise (_x,_x_i1) ->
                  let _x = o#int _x in
                  let _x_i1 = o#list (fun o  -> o#lambda) _x_i1 in
                  Lstaticraise (_x, _x_i1)
              | Lstaticcatch (_x,_x_i1,_x_i2) ->
                  let _x = o#lambda _x in
                  let _x_i1 =
                    (fun (_x,_x_i1)  ->
                       let _x = o#int _x in
                       let _x_i1 = o#list (fun o  -> o#ident) _x_i1 in
                       (_x, _x_i1)) _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in
                  Lstaticcatch (_x, _x_i1, _x_i2)
              | Ltrywith (_x,_x_i1,_x_i2) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#ident _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in Ltrywith (_x, _x_i1, _x_i2)
              | Lifthenelse (_x,_x_i1,_x_i2) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#lambda _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in
                  Lifthenelse (_x, _x_i1, _x_i2)
              | Lsequence (_x,_x_i1) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#lambda _x_i1 in Lsequence (_x, _x_i1)
              | Lwhile (_x,_x_i1) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#lambda _x_i1 in Lwhile (_x, _x_i1)
              | Lfor (_x,_x_i1,_x_i2,_x_i3,_x_i4) ->
                  let _x = o#ident _x in
                  let _x_i1 = o#lambda _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in
                  let _x_i3 = o#unknown _x_i3 in
                  let _x_i4 = o#lambda _x_i4 in
                  Lfor (_x, _x_i1, _x_i2, _x_i3, _x_i4)
              | Lassign (_x,_x_i1) ->
                  let _x = o#ident _x in
                  let _x_i1 = o#lambda _x_i1 in Lassign (_x, _x_i1)
              | Lsend (_x,_x_i1,_x_i2,_x_i3,_x_i4) ->
                  let _x = o#meth_kind _x in
                  let _x_i1 = o#lambda _x_i1 in
                  let _x_i2 = o#lambda _x_i2 in
                  let _x_i3 = o#list (fun o  -> o#lambda) _x_i3 in
                  let _x_i4 = o#unknown _x_i4 in
                  Lsend (_x, _x_i1, _x_i2, _x_i3, _x_i4)
              | Levent (_x,_x_i1) ->
                  let _x = o#lambda _x in
                  let _x_i1 = o#lambda_event _x_i1 in Levent (_x, _x_i1)
              | Lifused (_x,_x_i1) ->
                  let _x = o#ident _x in
                  let _x_i1 = o#lambda _x_i1 in Lifused (_x, _x_i1)
            method ident : ident -> ident= o#unknown
            method function_kind : function_kind -> function_kind=
              function | Curried  -> Curried | Tupled  -> Tupled
            method compile_time_constant :
              compile_time_constant -> compile_time_constant=
              function
              | Big_endian  -> Big_endian
              | Word_size  -> Word_size
              | Ostype_unix  -> Ostype_unix
              | Ostype_win32  -> Ostype_win32
              | Ostype_cygwin  -> Ostype_cygwin
            method comparison : comparison -> comparison=
              function
              | Ceq  -> Ceq
              | Cneq  -> Cneq
              | Clt  -> Clt
              | Cgt  -> Cgt
              | Cle  -> Cle
              | Cge  -> Cge
            method boxed_integer : boxed_integer -> boxed_integer=
              function
              | Pnativeint  -> Pnativeint
              | Pint32  -> Pint32
              | Pint64  -> Pint64
            method bigarray_layout : bigarray_layout -> bigarray_layout=
              function
              | Pbigarray_unknown_layout  -> Pbigarray_unknown_layout
              | Pbigarray_c_layout  -> Pbigarray_c_layout
              | Pbigarray_fortran_layout  -> Pbigarray_fortran_layout
            method bigarray_kind : bigarray_kind -> bigarray_kind=
              function
              | Pbigarray_unknown  -> Pbigarray_unknown
              | Pbigarray_float32  -> Pbigarray_float32
              | Pbigarray_float64  -> Pbigarray_float64
              | Pbigarray_sint8  -> Pbigarray_sint8
              | Pbigarray_uint8  -> Pbigarray_uint8
              | Pbigarray_sint16  -> Pbigarray_sint16
              | Pbigarray_uint16  -> Pbigarray_uint16
              | Pbigarray_int32  -> Pbigarray_int32
              | Pbigarray_int64  -> Pbigarray_int64
              | Pbigarray_caml_int  -> Pbigarray_caml_int
              | Pbigarray_native_int  -> Pbigarray_native_int
              | Pbigarray_complex32  -> Pbigarray_complex32
              | Pbigarray_complex64  -> Pbigarray_complex64
            method array_kind : array_kind -> array_kind=
              function
              | Pgenarray  -> Pgenarray
              | Paddrarray  -> Paddrarray
              | Pintarray  -> Pintarray
              | Pfloatarray  -> Pfloatarray
            method apply_status : apply_status -> apply_status=
              function | NA  -> NA | Full  -> Full
            method apply_info : apply_info -> apply_info=
              fun { apply_loc = _x; apply_status = _x_i1 }  ->
                let _x = o#unknown _x in
                let _x_i1 = o#apply_status _x_i1 in
                { apply_loc = _x; apply_status = _x_i1 }
            method unknown : 'a . 'a -> 'a= fun x  -> x
          end
      end
    module Lam_fold =
      struct
        open Lambda
        type ident = Ident.t
        class virtual fold =
          object (o : 'self_type)
            method string : string -> 'self_type= o#unknown
            method ref :
              'a . ('self_type -> 'a -> 'self_type) -> 'a ref -> 'self_type=
              fun _f_a  -> fun { contents = _x }  -> let o = _f_a o _x in o
            method option :
              'a .
                ('self_type -> 'a -> 'self_type) -> 'a option -> 'self_type=
              fun _f_a  ->
                function | None  -> o | Some _x -> let o = _f_a o _x in o
            method list :
              'a . ('self_type -> 'a -> 'self_type) -> 'a list -> 'self_type=
              fun _f_a  ->
                function
                | [] -> o
                | _x::_x_i1 ->
                    let o = _f_a o _x in let o = o#list _f_a _x_i1 in o
            method int : int -> 'self_type= o#unknown
            method bool : bool -> 'self_type=
              function | false  -> o | true  -> o
            method tag_info : tag_info -> 'self_type=
              function
              | Constructor _x -> let o = o#string _x in o
              | Tuple  -> o
              | Array  -> o
              | Variant _x -> let o = o#string _x in o
              | Record  -> o
              | NA  -> o
            method structured_constant : structured_constant -> 'self_type=
              function
              | Const_base _x -> let o = o#unknown _x in o
              | Const_pointer (_x,_x_i1) ->
                  let o = o#int _x in let o = o#pointer_info _x_i1 in o
              | Const_block (_x,_x_i1,_x_i2) ->
                  let o = o#int _x in
                  let o = o#tag_info _x_i1 in
                  let o = o#list (fun o  -> o#structured_constant) _x_i2 in o
              | Const_float_array _x ->
                  let o = o#list (fun o  -> o#string) _x in o
              | Const_immstring _x -> let o = o#string _x in o
            method shared_code : shared_code -> 'self_type=
              o#list
                (fun o  ->
                   fun (_x,_x_i1)  ->
                     let o = o#int _x in let o = o#int _x_i1 in o)
            method raise_kind : raise_kind -> 'self_type=
              function
              | Raise_regular  -> o
              | Raise_reraise  -> o
              | Raise_notrace  -> o
            method public_info : public_info -> 'self_type=
              o#option (fun o  -> o#string)
            method primitive : primitive -> 'self_type=
              function
              | Pidentity  -> o
              | Pbytes_to_string  -> o
              | Pbytes_of_string  -> o
              | Pchar_to_int  -> o
              | Pchar_of_int  -> o
              | Pmark_ocaml_object  -> o
              | Pignore  -> o
              | Prevapply _x -> let o = o#unknown _x in o
              | Pdirapply _x -> let o = o#unknown _x in o
              | Ploc _x -> let o = o#loc_kind _x in o
              | Pgetglobal _x -> let o = o#ident _x in o
              | Psetglobal _x -> let o = o#ident _x in o
              | Pmakeblock (_x,_x_i1,_x_i2) ->
                  let o = o#int _x in
                  let o = o#tag_info _x_i1 in let o = o#unknown _x_i2 in o
              | Pfield _x -> let o = o#int _x in o
              | Psetfield (_x,_x_i1) ->
                  let o = o#int _x in let o = o#bool _x_i1 in o
              | Pfloatfield _x -> let o = o#int _x in o
              | Psetfloatfield _x -> let o = o#int _x in o
              | Pduprecord (_x,_x_i1) ->
                  let o = o#unknown _x in let o = o#int _x_i1 in o
              | Plazyforce  -> o
              | Pccall _x -> let o = o#unknown _x in o
              | Praise _x -> let o = o#raise_kind _x in o
              | Psequand  -> o
              | Psequor  -> o
              | Pnot  -> o
              | Pnegint  -> o
              | Paddint  -> o
              | Psubint  -> o
              | Pmulint  -> o
              | Pdivint  -> o
              | Pmodint  -> o
              | Pandint  -> o
              | Porint  -> o
              | Pxorint  -> o
              | Plslint  -> o
              | Plsrint  -> o
              | Pasrint  -> o
              | Pintcomp _x -> let o = o#comparison _x in o
              | Poffsetint _x -> let o = o#int _x in o
              | Poffsetref _x -> let o = o#int _x in o
              | Pintoffloat  -> o
              | Pfloatofint  -> o
              | Pnegfloat  -> o
              | Pabsfloat  -> o
              | Paddfloat  -> o
              | Psubfloat  -> o
              | Pmulfloat  -> o
              | Pdivfloat  -> o
              | Pfloatcomp _x -> let o = o#comparison _x in o
              | Pstringlength  -> o
              | Pstringrefu  -> o
              | Pstringsetu  -> o
              | Pstringrefs  -> o
              | Pstringsets  -> o
              | Pbyteslength  -> o
              | Pbytesrefu  -> o
              | Pbytessetu  -> o
              | Pbytesrefs  -> o
              | Pbytessets  -> o
              | Pmakearray _x -> let o = o#array_kind _x in o
              | Parraylength _x -> let o = o#array_kind _x in o
              | Parrayrefu _x -> let o = o#array_kind _x in o
              | Parraysetu _x -> let o = o#array_kind _x in o
              | Parrayrefs _x -> let o = o#array_kind _x in o
              | Parraysets _x -> let o = o#array_kind _x in o
              | Pisint  -> o
              | Pisout  -> o
              | Pbittest  -> o
              | Pbintofint _x -> let o = o#boxed_integer _x in o
              | Pintofbint _x -> let o = o#boxed_integer _x in o
              | Pcvtbint (_x,_x_i1) ->
                  let o = o#boxed_integer _x in
                  let o = o#boxed_integer _x_i1 in o
              | Pnegbint _x -> let o = o#boxed_integer _x in o
              | Paddbint _x -> let o = o#boxed_integer _x in o
              | Psubbint _x -> let o = o#boxed_integer _x in o
              | Pmulbint _x -> let o = o#boxed_integer _x in o
              | Pdivbint _x -> let o = o#boxed_integer _x in o
              | Pmodbint _x -> let o = o#boxed_integer _x in o
              | Pandbint _x -> let o = o#boxed_integer _x in o
              | Porbint _x -> let o = o#boxed_integer _x in o
              | Pxorbint _x -> let o = o#boxed_integer _x in o
              | Plslbint _x -> let o = o#boxed_integer _x in o
              | Plsrbint _x -> let o = o#boxed_integer _x in o
              | Pasrbint _x -> let o = o#boxed_integer _x in o
              | Pbintcomp (_x,_x_i1) ->
                  let o = o#boxed_integer _x in
                  let o = o#comparison _x_i1 in o
              | Pbigarrayref (_x,_x_i1,_x_i2,_x_i3) ->
                  let o = o#bool _x in
                  let o = o#int _x_i1 in
                  let o = o#bigarray_kind _x_i2 in
                  let o = o#bigarray_layout _x_i3 in o
              | Pbigarrayset (_x,_x_i1,_x_i2,_x_i3) ->
                  let o = o#bool _x in
                  let o = o#int _x_i1 in
                  let o = o#bigarray_kind _x_i2 in
                  let o = o#bigarray_layout _x_i3 in o
              | Pbigarraydim _x -> let o = o#int _x in o
              | Pstring_load_16 _x -> let o = o#bool _x in o
              | Pstring_load_32 _x -> let o = o#bool _x in o
              | Pstring_load_64 _x -> let o = o#bool _x in o
              | Pstring_set_16 _x -> let o = o#bool _x in o
              | Pstring_set_32 _x -> let o = o#bool _x in o
              | Pstring_set_64 _x -> let o = o#bool _x in o
              | Pbigstring_load_16 _x -> let o = o#bool _x in o
              | Pbigstring_load_32 _x -> let o = o#bool _x in o
              | Pbigstring_load_64 _x -> let o = o#bool _x in o
              | Pbigstring_set_16 _x -> let o = o#bool _x in o
              | Pbigstring_set_32 _x -> let o = o#bool _x in o
              | Pbigstring_set_64 _x -> let o = o#bool _x in o
              | Pctconst _x -> let o = o#compile_time_constant _x in o
              | Pbswap16  -> o
              | Pbbswap _x -> let o = o#boxed_integer _x in o
              | Pint_as_pointer  -> o
            method pointer_info : pointer_info -> 'self_type=
              function
              | NullConstructor _x -> let o = o#string _x in o
              | NullVariant _x -> let o = o#string _x in o
              | NAPointer  -> o
            method meth_kind : meth_kind -> 'self_type=
              function
              | Self  -> o
              | Public _x -> let o = o#public_info _x in o
              | Cached  -> o
            method loc_kind : loc_kind -> 'self_type=
              function
              | Loc_FILE  -> o
              | Loc_LINE  -> o
              | Loc_MODULE  -> o
              | Loc_LOC  -> o
              | Loc_POS  -> o
            method let_kind : let_kind -> 'self_type=
              function
              | Strict  -> o
              | Alias  -> o
              | StrictOpt  -> o
              | Variable  -> o
            method lambda_switch : lambda_switch -> 'self_type=
              fun
                { sw_numconsts = _x; sw_consts = _x_i1; sw_numblocks = _x_i2;
                  sw_blocks = _x_i3; sw_failaction = _x_i4 }
                 ->
                let o = o#int _x in
                let o =
                  o#list
                    (fun o  ->
                       fun (_x,_x_i1)  ->
                         let o = o#int _x in let o = o#lambda _x_i1 in o)
                    _x_i1 in
                let o = o#int _x_i2 in
                let o =
                  o#list
                    (fun o  ->
                       fun (_x,_x_i1)  ->
                         let o = o#int _x in let o = o#lambda _x_i1 in o)
                    _x_i3 in
                let o = o#option (fun o  -> o#lambda) _x_i4 in o
            method lambda_event_kind : lambda_event_kind -> 'self_type=
              function
              | Lev_before  -> o
              | Lev_after _x -> let o = o#unknown _x in o
              | Lev_function  -> o
            method lambda_event : lambda_event -> 'self_type=
              fun
                { lev_loc = _x; lev_kind = _x_i1; lev_repr = _x_i2;
                  lev_env = _x_i3 }
                 ->
                let o = o#unknown _x in
                let o = o#lambda_event_kind _x_i1 in
                let o = o#option (fun o  -> o#ref (fun o  -> o#int)) _x_i2 in
                let o = o#unknown _x_i3 in o
            method lambda : lambda -> 'self_type=
              function
              | Lvar _x -> let o = o#ident _x in o
              | Lconst _x -> let o = o#structured_constant _x in o
              | Lapply (_x,_x_i1,_x_i2) ->
                  let o = o#lambda _x in
                  let o = o#list (fun o  -> o#lambda) _x_i1 in
                  let o = o#apply_info _x_i2 in o
              | Lfunction (_x,_x_i1,_x_i2) ->
                  let o = o#function_kind _x in
                  let o = o#list (fun o  -> o#ident) _x_i1 in
                  let o = o#lambda _x_i2 in o
              | Llet (_x,_x_i1,_x_i2,_x_i3) ->
                  let o = o#let_kind _x in
                  let o = o#ident _x_i1 in
                  let o = o#lambda _x_i2 in let o = o#lambda _x_i3 in o
              | Lletrec (_x,_x_i1) ->
                  let o =
                    o#list
                      (fun o  ->
                         fun (_x,_x_i1)  ->
                           let o = o#ident _x in let o = o#lambda _x_i1 in o)
                      _x in
                  let o = o#lambda _x_i1 in o
              | Lprim (_x,_x_i1) ->
                  let o = o#primitive _x in
                  let o = o#list (fun o  -> o#lambda) _x_i1 in o
              | Lswitch (_x,_x_i1) ->
                  let o = o#lambda _x in let o = o#lambda_switch _x_i1 in o
              | Lstringswitch (_x,_x_i1,_x_i2) ->
                  let o = o#lambda _x in
                  let o =
                    o#list
                      (fun o  ->
                         fun (_x,_x_i1)  ->
                           let o = o#string _x in let o = o#lambda _x_i1 in o)
                      _x_i1 in
                  let o = o#option (fun o  -> o#lambda) _x_i2 in o
              | Lstaticraise (_x,_x_i1) ->
                  let o = o#int _x in
                  let o = o#list (fun o  -> o#lambda) _x_i1 in o
              | Lstaticcatch (_x,_x_i1,_x_i2) ->
                  let o = o#lambda _x in
                  let o =
                    (fun (_x,_x_i1)  ->
                       let o = o#int _x in
                       let o = o#list (fun o  -> o#ident) _x_i1 in o) _x_i1 in
                  let o = o#lambda _x_i2 in o
              | Ltrywith (_x,_x_i1,_x_i2) ->
                  let o = o#lambda _x in
                  let o = o#ident _x_i1 in let o = o#lambda _x_i2 in o
              | Lifthenelse (_x,_x_i1,_x_i2) ->
                  let o = o#lambda _x in
                  let o = o#lambda _x_i1 in let o = o#lambda _x_i2 in o
              | Lsequence (_x,_x_i1) ->
                  let o = o#lambda _x in let o = o#lambda _x_i1 in o
              | Lwhile (_x,_x_i1) ->
                  let o = o#lambda _x in let o = o#lambda _x_i1 in o
              | Lfor (_x,_x_i1,_x_i2,_x_i3,_x_i4) ->
                  let o = o#ident _x in
                  let o = o#lambda _x_i1 in
                  let o = o#lambda _x_i2 in
                  let o = o#unknown _x_i3 in let o = o#lambda _x_i4 in o
              | Lassign (_x,_x_i1) ->
                  let o = o#ident _x in let o = o#lambda _x_i1 in o
              | Lsend (_x,_x_i1,_x_i2,_x_i3,_x_i4) ->
                  let o = o#meth_kind _x in
                  let o = o#lambda _x_i1 in
                  let o = o#lambda _x_i2 in
                  let o = o#list (fun o  -> o#lambda) _x_i3 in
                  let o = o#unknown _x_i4 in o
              | Levent (_x,_x_i1) ->
                  let o = o#lambda _x in let o = o#lambda_event _x_i1 in o
              | Lifused (_x,_x_i1) ->
                  let o = o#ident _x in let o = o#lambda _x_i1 in o
            method ident : ident -> 'self_type= o#unknown
            method function_kind : function_kind -> 'self_type=
              function | Curried  -> o | Tupled  -> o
            method compile_time_constant :
              compile_time_constant -> 'self_type=
              function
              | Big_endian  -> o
              | Word_size  -> o
              | Ostype_unix  -> o
              | Ostype_win32  -> o
              | Ostype_cygwin  -> o
            method comparison : comparison -> 'self_type=
              function
              | Ceq  -> o
              | Cneq  -> o
              | Clt  -> o
              | Cgt  -> o
              | Cle  -> o
              | Cge  -> o
            method boxed_integer : boxed_integer -> 'self_type=
              function | Pnativeint  -> o | Pint32  -> o | Pint64  -> o
            method bigarray_layout : bigarray_layout -> 'self_type=
              function
              | Pbigarray_unknown_layout  -> o
              | Pbigarray_c_layout  -> o
              | Pbigarray_fortran_layout  -> o
            method bigarray_kind : bigarray_kind -> 'self_type=
              function
              | Pbigarray_unknown  -> o
              | Pbigarray_float32  -> o
              | Pbigarray_float64  -> o
              | Pbigarray_sint8  -> o
              | Pbigarray_uint8  -> o
              | Pbigarray_sint16  -> o
              | Pbigarray_uint16  -> o
              | Pbigarray_int32  -> o
              | Pbigarray_int64  -> o
              | Pbigarray_caml_int  -> o
              | Pbigarray_native_int  -> o
              | Pbigarray_complex32  -> o
              | Pbigarray_complex64  -> o
            method array_kind : array_kind -> 'self_type=
              function
              | Pgenarray  -> o
              | Paddrarray  -> o
              | Pintarray  -> o
              | Pfloatarray  -> o
            method apply_status : apply_status -> 'self_type=
              function | NA  -> o | Full  -> o
            method apply_info : apply_info -> 'self_type=
              fun { apply_loc = _x; apply_status = _x_i1 }  ->
                let o = o#unknown _x in let o = o#apply_status _x_i1 in o
            method unknown : 'a . 'a -> 'self_type= fun _  -> o
          end
      end
    module Lam_pass_unused_params :
      sig
        [@@@ocaml.text " A pass to mark all unused params "]
        val translate_unsed_params : Lambda.lambda -> Lambda.lambda
      end =
      struct
        class count var_tbl =
          object (self)
            inherit  Lam_fold.fold as super
            method! ident x =
              match Hashtbl.find var_tbl x with
              | exception Not_found  -> self
              | v -> (incr v; self)
          end
        class rewrite_unused_params =
          object (self)
            inherit  Lam_map.map as super
            method! lambda x =
              match x with
              | Lfunction (kind,args,lam) ->
                  let tbl = Hashtbl.create 17 in
                  (List.iter (fun i  -> Hashtbl.replace tbl i (ref 0)) args;
                   (let lam = self#lambda lam in
                    ignore @@ (((new count) tbl)#lambda lam);
                    Lfunction
                      (kind,
                        (List.map
                           (fun i  ->
                              if (!(Hashtbl.find tbl i)) = 0
                              then Ext_ident.make_unused ()
                              else i) args), lam)))
              | _ -> super#lambda x
          end
        let translate_unsed_params lam =
          (new rewrite_unused_params)#lambda lam
      end 
    module Js_inline_and_eliminate :
      sig
        [@@@ocaml.text " Inline and remove unused code in JS IR "]
        val inline_and_shake : J.program -> J.program
      end =
      struct
        module S = J_helper.Stmt
        module E = J_helper.Exp
        let count_collects () =
          object (self)
            inherit  Js_fold.fold as super
            val stats = Hashtbl.create 83
            method use id =
              match Hashtbl.find stats id with
              | exception Not_found  -> Hashtbl.add stats id (ref 1)
              | v -> incr v
            method! variable_declaration vd =
              match vd with
              | { ident = _; value = None ;_} -> self
              | { ident = _; value = Some x;_} -> self#expression x
            method! ident id = self#use id; self
            method get_stats = stats
          end
        let subst export_set (stats : (Ident.t,int ref) Hashtbl.t) =
          object (self)
            inherit  Js_map.map as super
            val subst = Hashtbl.create 83
            method! block bs =
              match bs with
              | ({
                   statement_desc = Variable
                     ({ value = Some ({ expression_desc = Fun _;_} as v) } as
                        vd);_}
                   as st)::rest
                  ->
                  let is_export = Ident_set.mem vd.ident export_set in
                  if is_export
                  then (super#statement st) :: (self#block rest)
                  else
                    (match Hashtbl.find stats vd.ident with
                     | exception Not_found  ->
                         if Js_analyzer.no_side_effect_expression v
                         then (S.exp v) :: (self#block rest)
                         else self#block rest
                     | number when
                         ((!number) = 1) &&
                           (Js_analyzer.no_side_effect_expression v)
                         ->
                         let v' = self#expression v in
                         (Hashtbl.add subst vd.ident v'; self#block rest)
                     | _ -> (super#statement st) :: (self#block rest))
              | x::xs -> (self#statement x) :: (self#block xs)
              | [] -> []
            method! expression e =
              match e.expression_desc with
              | Var (Id id) ->
                  (match Hashtbl.find subst id with
                   | exception Not_found  -> e
                   | v -> self#expression v)
              | _ -> super#expression e
          end
        type inline_state =
          | False
          | Inline_ignore of bool
          | Inline_ret of J.expression* bool
          | Inline_return
        let pass_beta =
          object (self)
            inherit  Js_map.map as super
            val inline_state = False
            method with_inline_state x = {<inline_state = x>}
            method! block bs =
              match bs with
              | { statement_desc = Block bs;_}::rest ->
                  self#block (bs @ rest)
              | {
                  statement_desc = Exp
                    {
                      expression_desc = Call
                        ({ expression_desc = Fun (params,body,env) },args,_info);_};_}::rest
                  when Ext_list.same_length args params ->
                  let body = self#block body in
                  (List.fold_right2
                     (fun p  ->
                        fun a  ->
                          fun acc  -> (S.define ~kind:Variable p a) :: acc)
                     params args
                     ((self#with_inline_state
                         (Inline_ignore (Js_fun_env.is_tailcalled env)))#block
                        body))
                    @ (self#block rest)
              | {
                  statement_desc = Exp
                    {
                      expression_desc = Bin
                        (Eq
                         ,e,{
                              expression_desc = Call
                                ({ expression_desc = Fun (params,body,env) },args,_info);_});_};_}::rest
                  when Ext_list.same_length args params ->
                  let body = self#block body in
                  (List.fold_right2
                     (fun p  ->
                        fun a  ->
                          fun acc  -> (S.define ~kind:Variable p a) :: acc)
                     params args
                     ((self#with_inline_state
                         (Inline_ret (e, (Js_fun_env.is_tailcalled env))))#block
                        body))
                    @ (self#block rest)
              | {
                  statement_desc = Return
                    {
                      return_value =
                        {
                          expression_desc = Call
                            ({ expression_desc = Fun (params,body,_) },args,_info);_}
                      };_}::rest
                  when Ext_list.same_length args params ->
                  let body = self#block body in
                  (List.fold_right2
                     (fun p  ->
                        fun a  ->
                          fun acc  -> (S.define ~kind:Variable p a) :: acc)
                     params args
                     ((self#with_inline_state Inline_return)#block body))
                    @ (self#block rest)
              | ({ statement_desc = Return { return_value = e } } as st)::rest
                  ->
                  (match inline_state with
                   | False  -> (self#statement st) :: (self#block rest)
                   | Inline_ignore b -> (S.exp (self#expression e)) ::
                       (if b
                        then (S.break ()) :: (self#block rest)
                        else self#block rest)
                   | Inline_ret (v,b) ->
                       (S.exp (E.assign v (self#expression e))) ::
                       (if b
                        then (S.break ()) :: (self#block rest)
                        else self#block rest)
                   | Inline_return  -> (S.return (self#expression e)) ::
                       (self#block rest))
              | x::xs -> (self#statement x) :: (self#block xs)
              | [] -> []
            method! expression e =
              match e.expression_desc with
              | Fun (params,body,env) ->
                  {
                    e with
                    expression_desc =
                      (Fun
                         (params, (({<inline_state = False>})#block body),
                           env))
                  }
              | _ -> super#expression e
          end
        let inline_and_shake (program : J.program) =
          let _stats = ((count_collects ())#program program)#get_stats in
          let _export_set = program.export_set in
          (program |> (subst _export_set _stats)#program) |>
            pass_beta#program
      end 
    module Ext_char : sig val escaped : char -> string end =
      struct
        external string_unsafe_set :
          string -> int -> char -> unit = "%string_unsafe_set"
        external string_create : int -> string = "caml_create_string"
        external unsafe_chr : int -> char = "%identity"
        let escaped =
          function
          | '\'' -> "\\'"
          | '\\' -> "\\\\"
          | '\n' -> "\\n"
          | '\t' -> "\\t"
          | '\r' -> "\\r"
          | '\b' -> "\\b"
          | ' '..'~' as c ->
              let s = string_create 1 in (string_unsafe_set s 0 c; s)
          | c ->
              let n = Char.code c in
              let s = string_create 4 in
              (string_unsafe_set s 0 '\\';
               string_unsafe_set s 1 (unsafe_chr (48 + (n / 100)));
               string_unsafe_set s 2 (unsafe_chr (48 + ((n / 10) mod 10)));
               string_unsafe_set s 3 (unsafe_chr (48 + (n mod 10)));
               s)[@@ocaml.doc
                   " {!Char.escaped} is locale sensitive in 4.02.3, fixed in the trunk,\n    backport it here\n "]
      end 
  end