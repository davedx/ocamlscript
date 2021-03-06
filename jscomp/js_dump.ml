(* OCamlScript compiler
 * Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * http://www.ocsigen.org/js_of_ocaml/
 * Copyright (C) 2010 Jérôme Vouillon
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)
(* Authors: Jérôme Vouillon, Hongbo Zhang  *)



(*
  http://stackoverflow.com/questions/2846283/what-are-the-rules-for-javascripts-automatic-semicolon-insertion-asi
  ASI catch up
  {[
  a=b
  ++c
  ---
  a=b ++c
  ====================
  a ++
  ---
  a 
  ++
  ====================
  a --
  ---
  a 
  --
  ====================
  (continue/break/return/throw) a
  ---
  (continue/break/return/throw)
  a
  ====================
  ]}

*)

(* module P = Ext_format *)
module P = Ext_pp
module E = J_helper.Exp 
module S = J_helper.Stmt 

module L = struct
  let function_ = "function"
  let var = "var" (* should be able to switch to [let] easily*)
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
let return_indent = (String.length L.return / Ext_pp.indent_length) 

let throw_indent = (String.length L.throw / Ext_pp.indent_length) 


let semi f = P.string f L.semi

let op_prec, op_str  =
  Js_op_util.(op_prec, op_str)

let best_string_quote s =
  let simple = ref 0 in
  let double = ref 0 in
  for i = 0 to String.length s - 1 do
    match s.[i] with
    | '\'' -> incr simple
    | '"' -> incr double
    | _ -> ()
  done;
  if !simple < !double
  then '\''
  else '"'

let ident (cxt : Ext_pp_scope.t) f (id : Ident.t) : Ext_pp_scope.t  =
  if Ext_ident.is_js id then (* reserved by compiler *)
    begin P.string f id.name ; cxt end
  else 
    (* if false then *)
    (*   (\** Faster print ..  *)
    (*       Also for debugging *)
    (*    *\) *)
    (*   let name = Ext_ident.convert id.name in *)
    (*   ( P.string f (Printf.sprintf "%s$%d" name id.stamp ); cxt) *)
    (* else *)
    let name = Ext_ident.convert id.name in
    (* Attention: 
       $$Array.length, there is an invariant: that global module is 
       always printed in the begining(in the imports), so you get a gurantee, 
       (global modules can not be renamed like List$1) 

       However, this means we loose the ability of dynamic loading, is it a big 
       deal? we can fix this by a scanning first, since we already know which 
       modules are global

       check [test/test_global_print.ml] for regression

    *)
    let i,new_cxt = Ext_pp_scope.string_of_id  id cxt in
    let () =  
      P.string f 
        (if i == 0 then 
           name (* var $$String = require("String")*)
         else
           Printf.sprintf"%s$%d" name i) in
    new_cxt

let pp_string f ?(quote='"') ?(utf=false) s =
  let array_str1 =
    Array.init 256 (fun i -> String.make 1 (Char.chr i)) in
  let array_conv =
    Array.init 16 (fun i -> String.make 1 (("0123456789abcdef").[i])) in
  let quote_s = String.make 1 quote in
  P.string f quote_s;
  let l = String.length s in
  for i = 0 to l - 1 do
    let c = s.[i] in
    match c with
    | '\000' when i = l - 1 || s.[i + 1] < '0' || s.[i + 1] > '9' -> P.string f "\\0"
    | '\b' -> P.string f "\\b"
    | '\t' -> P.string f "\\t"
    | '\n' -> P.string f "\\n"
          (* This escape sequence is not supported by IE < 9
             | '\011' -> "\\v"
           *)
    | '\012' -> P.string f "\\f"
    | '\\' when not utf -> P.string f "\\\\"
    | '\r' -> P.string f "\\r"
    | '\000' .. '\031'  | '\127'->
        let c = Char.code c in
        P.string f "\\x";
        P.string f (Array.unsafe_get array_conv (c lsr 4));
        P.string f (Array.unsafe_get array_conv (c land 0xf))
    | '\128' .. '\255' when not utf ->
        let c = Char.code c in
        P.string f "\\x";
        P.string f (Array.unsafe_get array_conv (c lsr 4));
        P.string f (Array.unsafe_get array_conv (c land 0xf))
    | _ ->
        if c = quote
        then
          (P.string f "\\"; P.string f (Array.unsafe_get array_str1 (Char.code c)))
        else
          P.string f (Array.unsafe_get array_str1 (Char.code c))
  done;
  P.string f quote_s
;;

(* TODO: check utf's correct semantics *)
let pp_quote_string f s = 
  pp_string f ~utf:false ~quote:(best_string_quote s ) s 

(* IdentMap *)
(*
f/122 --> 
  f/122 is in the map 
  if in, use the old mapping
  else 
    check  f,
     if in last bumped id
     else 
        use "f", register it 

  check "f"       
         if not , use "f", register stamp -> 0 
         else 
           check stamp 
             if in  use it 
             else check last bumped id, increase it and register
*)

let rec pp_function cxt (f : P.t) ?name  return (l : Ident.t list) (b : J.block) (env : Js_fun_env.t ) =  
  let ipp_ident cxt f id un_used = 
    if un_used then 
      ident cxt f (Ext_ident.make_unused ())
    else 
      ident cxt f id  in
  let rec formal_parameter_list cxt (f : P.t) l =
    let rec aux i cxt l = 
      match l with
      | []     -> cxt
      | [id]    -> ipp_ident cxt f id (Js_fun_env.get_unused env i)
      | id :: r -> 
        let cxt = ipp_ident cxt f id (Js_fun_env.get_unused env i) in
        P.string f L.comma; P.space f;
        aux (i + 1) cxt  r
    in
    match l with 
    | [] -> cxt 
    | [i] -> 
      (** necessary, since some js libraries like [mocha]...*)
      if Js_fun_env.get_unused env 0 then cxt else ident cxt f i 
    | _ -> 
      aux 0 cxt l  in

  let rec aux  cxt f ls  =
    match ls with
    | [] -> cxt
    | [x] -> ident cxt f x
    | y :: ys ->
        let cxt = ident cxt f y in
        P.string f L.comma;
        aux cxt f ys  in

  let set_env = (** identifiers will be printed following*)
    match name with 
    | None ->
        Js_fun_env.get_bound env 
    | Some id -> Ident_set.add id (Js_fun_env.get_bound env )
  in
  (* the context will be continued after this function *)
  let outer_cxt = Ext_pp_scope.merge set_env cxt in  
  (* the context used to be printed inside this function*)
  let inner_cxt = Ext_pp_scope.sub_scope outer_cxt set_env in

  (
    (* (if not @@ Js_fun_env.is_empty env then *)
    (* pp_comment  f (Some (Js_fun_env.to_string env))) ; *)
    let action return = 

      (if return then P.string f "return " else ());
      P.string f L.function_;
      P.space f ;
      (match name with None  -> () | Some x -> ignore (ident inner_cxt f x));
      let body_cxt = P.paren_group f 1 (fun _ -> 
          formal_parameter_list inner_cxt  f l )
      in
      P.space f ;
      ignore @@ P.brace_vgroup f 1 (fun _ -> statement_list false body_cxt f b );
    in
    let lexical = Js_fun_env.get_lexical_scope env in
    let enclose action lexical  return = 

      if  Ident_set.is_empty lexical  
      then
        action return 
      else
        let lexical = Ident_set.elements lexical in

        (if return then P.string f "return " else ());
        P.string f "(function(";
        ignore @@ aux inner_cxt f lexical;
        P.string f ")";
        P.brace_vgroup f 0  (fun _ -> action true);
        P.string f "(";
        ignore @@ aux inner_cxt f lexical;
        P.string f ")";
        P.string f ")"

    in
    enclose action lexical return 
  ) ;
  outer_cxt


(* Assume the cond would not change the context, 
    since it can be either [int] or [string]
 *)
and output_one : 'a . 
    _ -> P.t -> (P.t -> 'a -> unit) -> 'a J.case_clause -> _
    = fun cxt f  pp_cond
    ({case = e; body = (sl,break)} : _ J.case_clause) -> 
  let cxt = 
    P.group f 1 @@ fun _ -> 
      P.group f 1 @@ (fun _ -> 
        P.string f "case ";
        pp_cond  f e;
        P.space f ;
        P.string f L.colon  );
      
      P.space f;
      P.group f 1 @@ fun _ ->
        let cxt =
          match sl with 
          | [] -> cxt 
          | _ ->
              P.newline f ;
              statement_list false cxt  f sl
        in
        (if break then 
          begin
            P.newline f ;
            P.string f "break";
            semi f;
          end) ;
        cxt
  in
  P.newline f;
  cxt 

and loop  :  'a . Ext_pp_scope.t ->
  P.t -> (P.t -> 'a -> unit) -> 'a J.case_clause list -> Ext_pp_scope.t
      = fun  cxt  f pp_cond cases ->
  match cases with 
  | [] -> cxt 
  | [x] -> output_one cxt f pp_cond x
  | x::xs ->
      let cxt = output_one cxt f pp_cond x 
      in loop  cxt f pp_cond  xs 

and vident cxt f  (v : J.vident) =
  begin match v with 
  | Id v | Qualified(v, _, None) ->  
      ident cxt f v
  | Qualified (id,_, Some name) ->
      let cxt = ident cxt f id in
      P.string f ".";
      P.string f (Ext_ident.convert name);
      cxt
  end

and expression l cxt  f (exp : J.expression) : Ext_pp_scope.t = 
  pp_comment_option f exp.comment ;
  expression_desc cxt l f exp.expression_desc

and
  expression_desc cxt (l:int) f expression_desc : Ext_pp_scope.t  =
  match expression_desc with
  | Var v ->
    vident cxt f v 

  | Seq (e1, e2) ->
    let action () = 
      let cxt = expression 0 cxt f e1 in
      P.string f L.comma ;
      P.space f ;
      expression 0 cxt f e2  in
    if l > 0 then 
      P.paren_group f 1 action
    else action ()

  | Fun (l, b, env) ->  (* TODO: dump for comments *)
    pp_function cxt f false  l b env

  | Call (e, el, info) ->
    let action () = 
      P.group f 1 (fun _ -> 
          let () =
            match info with
            | {arity = NA } -> ipp_comment f (Some "!")
            | _ -> () in
          let cxt = expression 15 cxt f e in 
          P.paren_group f 1 (fun _ -> arguments cxt  f el ) ) 
    in
    if l > 15 then P.paren_group f 1 action   
    else action ()

  | Tag_ml_obj e -> 
    P.group f 1 (fun _ -> 
        P.string f "Object.defineProperty";
        P.paren_group f 1 (fun _ ->
            let cxt = expression 1 cxt f e in
            P.string f L.comma;
            P.space f ; 
            P.string f {|"##ml"|};
            P.string f L.comma;
            P.string f {|{"value" : true, "writable" : false}|} ; 
            cxt ))

  | FlatCall(e,el) -> 
    P.group f 1 (fun _ -> 
        let cxt = expression 15 cxt f e in
        P.string f ".apply";
        P.paren_group f 1 (fun _ ->
            P.string f "null";
            P.string f L.comma;
            P.space f ; 
            expression 1 cxt f el
          )
      )
  | String_of_small_int_array (e) -> 
    let action () = 
      P.group f 1 (fun _ -> 
          P.string f "String.fromCharCode.apply";
          P.paren_group f 1 (fun _ -> 
              P.string f "null";
              P.string f L.comma;
              expression 1 cxt  f e  ) ) 
    in
    if l > 15 then P.paren_group f 1 action   
    else action ()

  | Array_append (e, el) -> 
    P.group f 1 (fun _ -> 
        let cxt = expression 15 cxt f e in
        P.string f ".concat";
        P.paren_group f 1 (fun _ -> arguments cxt f el))

  | Dump (level, el) -> 
    let obj = 
      match level with 
      | Log -> "log"
      | Info -> "info"
      | Warn -> "warn"
      | Error -> "error" in
    P.group f 1 (fun _ -> 
        P.string f "console.";
        P.string f obj ;
        P.paren_group f 1 (fun _ -> arguments cxt f el))

  | Char_to_int e -> 
    begin match e.expression_desc with 
      | String_access (a,b) -> 
        P.group f 1 (fun _ -> 
            let cxt = expression 15 cxt f a in
            P.string f L.dot;
            P.string f L.char_code_at;
            P.paren_group f 1 (fun _ -> expression 0 cxt f b);
          )
      | _ -> 
        P.group f 1 (fun _ -> 
            let cxt = expression 15 cxt f e in
            P.string f L.dot;
            P.string f L.char_code_at;
            P.string f "(0)";
            cxt)
    end

  | Char_of_int e -> 
    P.group f 1 (fun _ -> 
        P.string f "String";
        P.string f L.dot;
        P.string f "fromCharCode";
        P.paren_group f 1 (fun _ -> arguments cxt f [e])
      )


  | Math (name, el) -> 
    P.group f 1 (fun _ ->
        P.string f "Math";
        P.string f L.dot;
        P.string f name;
        P.paren_group f 1 (fun _ -> arguments cxt f el)
      )

  | Str (_, s) ->
    let quote = best_string_quote s in 
    (*TODO --
       when utf8-> it will not escape '\\' which is definitely not we want
     *)
    pp_string f (* ~utf:(kind = `Utf8) *) ~quote s; cxt 

  | Number v ->
    let s = 
      match v with 
      | Float v -> 
        Js_number.to_string v (* attach string here for float constant folding?*)
      | Int { i = v; _} 
        -> string_of_int v (* check , js convention with ocaml lexical convention *)in
    let need_paren =
      if s.[0] = '-'
      then l > 13  (* Negative numbers may need to be parenthesized. *)
      else l = 15  (* Parenthesize as well when followed by a dot. *)
           && s.[0] <> 'I' (* Infinity *)
           && s.[0] <> 'N' (* NaN *)
    in
    let action = fun _ -> P.string f s  in
    (
      if need_paren 
      then P.paren f  action
      else action ()
    ); 
    cxt 

  | Int_of_boolean e -> 
    let action () = 
      P.group f 0 @@ fun _ -> 
        P.string f "+" ;
        expression 13 cxt f e 
    in
    (* need to tweak precedence carefully 
       here [++x --> +(+x)]
    *)
    if l > 12 
    then P.paren_group f 1 action 
    else action ()

  | Not e ->
    let action () = 
      P.string f "!" ;
      expression 13 cxt f e 
    in
    if l > 13 
    then P.paren_group f 1 action 
    else action ()

  | Is_type_number e 
    ->
    let action () = 
      P.string f "typeof";
      P.space f ;
      let cxt = expression 13 cxt f e in
      P.space f ;
      P.string f "===";
      P.space f ;
      P.string f {|"number"|};
      cxt 
    in
    let (out, _lft, _rght) = op_prec EqEqEq in
    if l > out 
    then P.paren_group f 1 action 
    else action ()
  | Bin (Eq, {expression_desc = Var i },
         {expression_desc = 
            (
              Bin(
                (Plus as op), {expression_desc = Var j}, delta)
            | Bin(
                (Plus as op), delta, {expression_desc = Var j})
            | Bin(
                (Minus as op), {expression_desc = Var j}, delta)
            )
         })
    when Js_op_util.same_vident i j -> 
    (* TODO: parenthesize when necessary *)
    begin match delta, op with 
      | {expression_desc = Number (Int { i =  1; _})}, Plus
        (* TODO: float 1. instead, 
             since in JS, ++ is a float operation           
        *)        
      | {expression_desc = Number (Int { i =  -1; _})}, Minus
        ->
        P.string f L.plusplus;
        P.space f ; 
        vident cxt f i

      | {expression_desc = Number (Int { i =  -1; _})}, Plus
      | {expression_desc = Number (Int { i =  1; _})}, Minus
        -> 
        P.string f L.minusminus; 
        P.space f ; 
        vident cxt f i;
      | _, _ -> 
        let cxt = vident cxt f i in
        P.space f ;
        if op = Plus then P.string f "+=" 
        else P.string f "-=";
        P.space f ; 
        expression 13 cxt  f delta
    end
  | Bin (Eq, {expression_desc = Access({expression_desc = Var i; _},
                                       {expression_desc = Number (Int {i = k0 })}
                                      ) },
         {expression_desc = 
            (Bin((Plus as op), 
                 {expression_desc = Access(
                      {expression_desc = Var j; _},
                      {expression_desc = Number (Int {i = k1; })}
                    ); _}, delta)
            | Bin((Plus as op), delta,
                  {expression_desc = Access(
                       {expression_desc = Var j; _},
                       {expression_desc = Number (Int {i = k1; })}
                     ); _})
            | Bin((Minus as op), 
                  {expression_desc = Access(
                       {expression_desc = Var j; _},
                       {expression_desc = Number (Int {i = k1; })}
                     ); _}, delta)

            )})
    when  k0 = k1 && Js_op_util.same_vident i j 
    (* Note that 
       {[x = x + 1]}
       is exactly the same  (side effect, and return value)
       as {[ ++ x]}
       same to 
       {[ x = x + a]}
       {[ x += a ]}
       they both return the modified value too
    *)
    (* TODO:
       handle parens..
    *)
    ->
    let aux cxt f vid i = 
      let cxt = vident cxt f vid in
      P.string f "[";
      P.string f (string_of_int i);
      P.string f"]"; 
      cxt in
    (** TODO: parenthesize when necessary *)

    begin match delta, op with 
      | {expression_desc = Number (Int { i =  1; _})}, Plus
      | {expression_desc = Number (Int { i =  -1; _})}, Minus
        ->
        P.string f L.plusplus;
        P.space f ; 
        aux cxt f i k0
      | {expression_desc = Number (Int { i =  -1; _})}, Plus
      | {expression_desc = Number (Int { i =  1; _})}, Minus
        -> 
        P.string f L.minusminus; 
        P.space f ; 
        aux cxt f  i k0
      | _, _ -> 
        let cxt = aux cxt f i k0 in
        P.space f ;
        if op = Plus then P.string f "+=" 
        else P.string f "-=";
        P.space f ; 
        expression 13 cxt  f delta
    end

  | Bin (Minus, {expression_desc = Number (Int {i=0;_} | Float 0.)}, e) 
    ->
    let action () = 
      P.string f "-" ;
      expression 13 cxt f e 
    in
    if l > 13 then P.paren_group f 1 action 
    else action ()

  | Bin (op, e1, e2) ->
    let (out, lft, rght) = op_prec op in
    let need_paren =
      l > out || (match op with Lsl | Lsr | Asr -> true | _ -> false) in

    let action () = 
      (* We are more conservative here, to make the generated code more readable
          to the user
       *)

      let cxt = expression lft cxt  f e1 in
      P.space f; 
      P.string f (op_str op);
      P.space f;
      expression rght cxt   f e2 
    in
    if need_paren 
    then P.paren_group f 1 action 
    else action ()

  | String_append (e1, e2) -> 
    let op : Js_op.binop = Plus in
    let (out, lft, rght) = op_prec op in
    let need_paren =
      l > out || (match op with Lsl | Lsr | Asr -> true | _ -> false) in

    let action () = 
      let cxt = expression  lft cxt f e1 in
      P.space f ;
      P.string f "+";
      P.space f;
      expression rght  cxt   f e2 
    in
    if need_paren then P.paren_group f 1 action else action ()

  | Array (el,_) ->
    (** TODO: simplify for singleton list *)
    begin match el with 
      | []| [ _ ] -> P.bracket_group f 1 @@ fun _ -> array_element_list  cxt f el 
      | _ -> P.bracket_vgroup f 1 @@ fun _ -> array_element_list  cxt f el 
    end

  | Access (e, e') 

  | String_access (e,e')
    ->
    let action () = 
      P.group f 1 @@ fun _ -> 
        let cxt = expression 15 cxt f e in
        P.bracket_group f 1 @@ fun _ -> 
          expression 0 cxt f e' 
    in
    if l > 15 then P.paren_group f 1 action else action ()

  | Array_length e | String_length e | Bytes_length e | Function_length e -> 
    let action () =  (** Todo: check parens *)
      let cxt = expression 15 cxt f e in
      P.string f L.dot;
      P.string f L.length;
      cxt  in
    if l > 15 then P.paren_group f 1 action else action ()

  | Dot (e, nm,normal) ->
    if normal then 
      begin 
        let action () = 
          let cxt = expression 15 cxt f e in
          P.string f L.dot;
          P.string f (Ext_ident.convert nm); 
          (* See [Js_program_loader.obj_of_exports] 
             maybe in the ast level we should have 
             refer and export
          *)
          cxt in
        if l > 15 then P.paren_group f 1 action else action ()
      end
    else begin
      let action () = 
        P.group f 1 @@ fun _ -> 
          let cxt = expression 15 cxt f e in
          (P.bracket_group f 1 @@ fun _ -> 
              pp_string f (* ~utf:(kind = `Utf8) *) ~quote:( best_string_quote nm) nm);
          cxt 
      in
      if l > 15 then P.paren_group f 1 action else action ()
    end

  | New (e,  el) ->
    let action () = 
      P.group f 1 @@ fun _ -> 
        P.string f L.new_;
        P.space f;
        let cxt = expression 16 cxt f e in
        P.paren_group f 1 @@ fun _ -> 
          match el with 
          | Some el  -> arguments cxt f el  
          | None -> cxt
    in
    if l > 15 then P.paren_group f 1 action else action ()

  | Array_of_size e ->
    let action () = 
      P.group f 1 @@ fun _ -> 
        P.string f L.new_;
        P.space f;
        P.string f L.array;
        P.paren_group f 1 @@ fun _ -> expression 0 cxt f e
    in
    if l > 15 then P.paren_group f 1 action else action ()

  | Cond (e, e1, e2) ->
    let action () = 
      (* P.group f 1 @@ fun _ ->  *)
      let cxt =  expression 3 cxt f e in
      P.space f;
      P.string f L.question; 
      P.space f;
      (* 
            [level 1] is correct, however
            to make nice indentation , force nested conditional to be parenthesized
          *)
      let cxt = (P.group f 1 @@ fun _ -> expression 3 cxt f e1) in
      (* let cxt = (P.group f 1 @@ fun _ -> expression 1 cxt f e1) in *)
      P.space f;
      P.string f L.colon;
      P.space f ; 

      (* idem *)
      P.group f 1 @@ fun _ -> expression 3 cxt f e2
      (* P.group f 1 @@ fun _ -> expression 1 cxt f e2 *)
    in
    if l > 2 then P.paren_vgroup f 1 action else action ()

  | Object lst ->
    P.brace_group f 1 @@ fun _ -> 
      property_name_and_value_list cxt f lst

and property_name cxt f (s : J.property_name) : Ext_pp_scope.t =
  pp_string f ~utf:true ~quote:(best_string_quote s) s; cxt 

and property_name_and_value_list cxt f l : Ext_pp_scope.t =
  match l with
  | [] -> cxt
  | [(pn, e)] ->
    P.group f 0 @@ fun _ -> 
      let cxt = property_name cxt  f pn in
      P.string f L.colon;
      P.space f;
      expression 1 cxt f e 
  | (pn, e) :: r ->
    let cxt = P.group f 0 @@ fun _ -> 
        let cxt = property_name cxt f pn in
        P.string f L.colon;
        P.space f;
        expression 1 cxt f e in
    P.string f L.comma;
    P.newline f;
    property_name_and_value_list cxt f r

and array_element_list cxt f el : Ext_pp_scope.t =
  match el with
  | []     -> cxt 
  | [e]    ->  expression 1 cxt f e
  | e :: r ->
    let cxt =  expression 1 cxt f e 
    in
    P.string f L.comma; P.newline f; array_element_list cxt f r

and arguments cxt f l : Ext_pp_scope.t =
  match l with
  | []     -> cxt 
  | [e]    ->   expression 1 cxt f e
  | e :: r -> 
    let cxt =   expression 1 cxt f e in
    P.string f L.comma; P.space f; arguments cxt f r

and variable_declaration top cxt f 
    (variable : J.variable_declaration) : Ext_pp_scope.t = 
  (* TODO: print [const/var] for different backends  *)
  match variable with
  | {ident = i; value =  None; ident_info ; _} -> 
    if ident_info.used_stats = Dead_pure 
    then cxt
    else 
      begin
        P.string f L.var;
        P.space f;
        let cxt = ident cxt  f i in
        semi f ; 
        cxt
      end 
  | { ident = i ; value =  Some e; ident_info = {used_stats; _}} ->
    begin match used_stats with
      | Dead_pure -> 
        cxt 
      | Dead_non_pure -> 
        (* Make sure parens are added correctly *)
        statement_desc top cxt f (J.Exp e)
      | _ -> 
        begin match e, top  with 
          | {expression_desc = Fun (params, b, env ); comment = _}, true -> 
            pp_function cxt f ~name:i false params b env 
          | _, _ -> 
              P.string f L.var;
              P.space f;
              let cxt = ident cxt f i in
              P.space f ;
              P.string f L.eq;
              P.space f ;
              let cxt = expression 1 cxt f e in
              semi f;
              cxt 
        end
    end
and ipp_comment : 'a . P.t -> 'a  -> unit = fun   f comment -> 
  ()


(** don't print a new line -- ASI 
    FIXME: this still does not work in some cases...
    {[
    return /* ... */
    [... ]
    ]}
*)

and pp_comment f comment = 
  if String.length comment > 0 then 
    P.string f "/* "; P.string f comment ; P.string f " */" 

and pp_comment_option f comment  = 
    match comment with 
    | None -> ()
    | Some x -> pp_comment f x
and statement top cxt f 
    ({statement_desc = s;  comment ; _} : J.statement)  : Ext_pp_scope.t =

  pp_comment_option f comment ;
  statement_desc top cxt f s 

and statement_desc top cxt f (s : J.statement_desc) : Ext_pp_scope.t = 
  match s with
  | Block [] -> 
      ipp_comment f  L.empty_block; (* debugging*)
      cxt

  | Block b -> (* No braces needed here *)
      ipp_comment f L.start_block;
      let cxt = statement_list top cxt  f b in
      ipp_comment f  L.end_block;
      cxt
  | Variable l ->
      variable_declaration top cxt  f l
  | Exp {expression_desc = Var _;}-> (* Does it make sense to optimize here? *)
      semi f; cxt 
  | Exp e ->
    (* Parentheses are required when the expression
       starts syntactically with "{" or "function" 
       TODO:  be more conservative, since Google Closure will handle
       the precedence correctly, we also need people read the code..
       Here we force parens for some alien operators

       If we move assign into a statement, will be less?
       TODO: construct a test case that do need parenthesisze for expression
       IIE does not apply (will be inlined?)
    *)

    let rec need_paren  (e : J.expression) =
      match e.expression_desc with
      | Call ({expression_desc = Fun _; },_,_) -> true

      | Fun _ | Object _ -> true
      | String_of_small_int_array _
      | Call _ 
      | Array_append _ 
      | Tag_ml_obj _
      | Seq _
      | Dot _
      | Cond _
      | Bin _ 
      | String_access _ 
      | Access _
      | Array_of_size _ 
      | Array_length _
      | String_length _ 
      | Bytes_length _
      | String_append _ 
      | Char_of_int _ 
      | Char_to_int _
      | Dump _
      | Math _
      | Var _ 
      | Str _ 
      | Array _ 
      | FlatCall _ 
      | Is_type_number _
      | Function_length _ 
      | Number _
      | Not _ 
      | New _ 
      | Int_of_boolean _ -> false
      (* e = function(x){...}(x);  is good
       *)
    in
    let cxt = 
      (
        if need_paren  e 
        then (P.paren_group f 1)
        else (P.group f 0)
      ) (fun _ -> expression 0 cxt f e ) in
    semi f;
    cxt 

  | If (e, s1,  s2) -> (* TODO: always brace those statements *)
    let cxt = 
      P.string f "if";
      P.space f;
      P.paren_group f 1 @@ fun _ -> expression 0 cxt f e
    in
    P.space f;
    let cxt =
      block cxt f s1
    in
    (match s2 with 
     | None | (Some []) |Some [{statement_desc = Block []; }]
       -> P.newline f; cxt
     | Some s2 -> 
       P.newline f;
       P.string f "else";
       P.space f ;
       block  cxt f s2 )

  | While (label, e, s, _env) ->  (*  FIXME: print scope as well *)
    (match label with 
     | Some i ->
       P.string f i ; 
       P.string f L.colon;
       P.newline f ;
     | None -> ());
    P.string f "while";
    let cxt = P.paren_group f 1 @@ fun _ ->  expression 0 cxt f e in
    P.space f ; 
    let cxt = block cxt f s in
    semi f;
    cxt

  | ForRange (for_ident_expression, finish, id, direction, s, env) -> 
    let action cxt  = 
      P.vgroup f 0 @@ fun _ -> 
        let cxt = P.group f 0 @@ fun _ -> 
            (* The only place that [semi] may have semantics here *)
            P.string f "for";
            P.paren_group f 1 @@ fun _ -> 
              let cxt, new_id = 
                (match for_ident_expression, finish.expression_desc with 
                 | Some ident_expression , (Number _ | Var _ ) -> 
                   P.string f L.var;
                   P.space f;
                   let cxt  =  ident cxt f id in
                   P.space f; 
                   P.string f L.eq;
                   P.space f;
                   expression 0 cxt f ident_expression, None
                 | Some ident_expression, _ -> 
                   P.string f L.var;
                   P.space f;
                   let cxt  =  ident cxt f id in
                   P.space f;
                   P.string f L.eq;
                   P.space f; 
                   let cxt = expression 1 cxt f ident_expression in
                   P.space f ; 
                   P.string f L.comma;
                   let id = Ext_ident.create (Ident.name id ^ "_finish") in
                   let cxt = ident cxt f id in
                   P.space f ; 
                   P.string f L.eq;
                   P.space f;
                   expression 1 cxt f finish, Some id
                 | None, (Number _ | Var _) -> 
                   cxt, None 
                 | None , _ -> 
                   P.string f L.var;
                   P.string f " ";
                   let id = Ext_ident.create (Ident.name id ^ "_finish") in
                   let cxt = ident cxt f id in
                   P.string f " = ";
                   expression 15 cxt f finish, Some id
                ) in
              semi f ; 
              P.space f;
              let cxt = ident cxt f id in
              let right_prec  = 

                match direction with 
                | Upto -> 
                  let (_,_,right) = op_prec Le  in
                  P.string f "<=";
                  right
                | Downto -> 
                  let (_,_,right) = op_prec Ge in
                  P.string f ">=" ;
                  right
              in
              P.space f ; 
              let cxt  = 
                match new_id with 
                | Some i -> expression   right_prec cxt  f (E.var i)
                | None -> expression  right_prec cxt  f finish
              in
              semi f; 
              P.space f;
              let ()  = 
                match direction with 
                | Upto -> P.string f "++"
                | Downto -> P.string f "--" in
              ident cxt f id
        in
        block  cxt f s  in
    let lexical = Js_closure.get_lexical_scope env in
    if Ident_set.is_empty lexical 
    then action cxt
    else 
      (* unlike function, 
         [print for loop] has side effect, 
         we should take it out
      *)
      let inner_cxt = Ext_pp_scope.merge lexical cxt in
      let lexical = Ident_set.elements lexical in
      let _enclose action inner_cxt lexical   = 
        let rec aux  cxt f ls  =
          match ls with
          | [] -> cxt
          | [x] -> ident cxt f x
          | y :: ys ->
            let cxt = ident cxt f y in
            P.string f L.comma;
            aux cxt f ys  in
        P.vgroup f 0
          (fun _ ->
             (
               P.string f "(function(";
               ignore @@ aux inner_cxt f lexical;
               P.string f ")";
               let cxt = P.brace_vgroup f 0  (fun _ -> action inner_cxt) in
               P.string f "(";
               ignore @@ aux inner_cxt f lexical;
               P.string f ")";
               P.string f ")";
               semi f;
               cxt
             )) 
      in
      _enclose action inner_cxt lexical

  | Continue s ->
    P.string f "continue "; (* ASI becareful...*)
    P.string f s;
    semi f;
    P.newline f;
    cxt

  | Break
    ->
    P.string f "break ";
    semi f;
    P.newline f; 
    cxt

  | Return {return_value = e} ->
    begin match e with
      | {expression_desc = Fun ( l, b, env); _} ->
        let cxt = pp_function cxt f true l b env in
        semi f ; cxt 
      | e ->
        P.string f L.return ;
        P.space f ;

        (* P.string f "return ";(\* ASI -- when there is a comment*\) *)
        P.group f return_indent @@ fun _ -> 
          let cxt =  expression 0 cxt f e in
          semi f;
          cxt 
          (* There MUST be a space between the return and its
             argument. A line return will not work *)
    end
  | Int_switch (e, cc, def) ->
    P.string f "switch";  
    P.space f;
    let cxt = P.paren_group f 1 @@ fun _ ->  expression 0 cxt f e 
    in
    P.space f;
    P.brace_vgroup f 1 @@ fun _ -> 
      let cxt = loop cxt f (fun f i -> P.string f (string_of_int i) ) cc in
      (match def with
       | None -> cxt
       | Some def ->
         P.group f 1 @@ fun _ -> 
           P.string f L.default;
           P.string f L.colon;
           P.newline f;
           statement_list  false cxt  f def 
      )

  | String_switch (e, cc, def) ->
    P.string f "switch";
    P.space f;
    let cxt = P.paren_group f 1 @@ fun _ ->  expression 0 cxt f e 
    in
    P.space f;
    P.brace_vgroup f 1 @@ fun _ -> 
      let cxt = loop cxt f (fun f i -> pp_quote_string f i ) cc in
      (match def with
       | None -> cxt
       | Some def ->
         P.group f 1 @@ fun _ -> 
           P.string f L.default;
           P.string f L.colon;
           P.newline f;
           statement_list  false cxt  f def )

  | Throw e ->
    P.string f L.throw;
    P.space f ;
    P.group f throw_indent @@ fun _ -> 

      let cxt = expression 0 cxt f e in
      semi f ; cxt 

  (* There must be a space between the return and its
     argument. A line return would not work *)
  | Try (b, ctch, fin) ->
    P.vgroup f 0 @@ fun _-> 
      P.string f "try";
      P.space f ; 
      let cxt = block cxt f b in
      let cxt = 
        match ctch with
        | None ->
          cxt
        | Some (i, b) ->
          P.newline f;
          P.string f "catch (";
          let cxt = ident cxt f i in
          P.string f ")";
          block cxt f b
      in 
      begin match fin with
        | None -> cxt
        | Some b ->
          P.group f 1 @@ fun _ -> 
            P.string f "finally";
            P.space f;
            block cxt f b 
      end
(* similar to [block] but no braces *)
and statement_list top cxt f  b =
  match b with
  | []     -> cxt
  | [s]    -> statement top  cxt f  s
  | s :: r -> 
    let cxt = statement top cxt f s in
    P.newline f;
    (if top then P.force_newline f);
    statement_list top cxt f  r

(* and statement_list cxt f b =  *)
(*   match b with  *)
(*   | [] -> cxt  *)
(*   | _ -> P.vgroup f 0 (fun _ -> loop_statement cxt f b) *)

and block cxt f b =
  (* This one is for '{' *)
  P.brace_vgroup f 1 (fun _ -> statement_list false cxt   f b )

(* Node style *)
let requires cxt f (modules : (Ident.t * string) list ) =
  P.newline f ; 
  let rec aux cxt  modules =
    match modules with
    | [] -> cxt 
    | (id,s) :: rest  ->
      let cxt = P.group f 0 @@ fun _ -> 
          P.string f L.var;
          P.space f ;
          let cxt = ident cxt f id in
          P.space f;
          P.string f L.eq;
          P.space f;
          P.string f L.require;
          P.paren_group f 0 @@ (fun _ ->
              pp_string f ~utf:true ~quote:(best_string_quote s) s  );
          cxt in
      semi f ; 
      P.newline f ;
      aux cxt rest 
  in aux cxt modules 

let exports cxt f (idents : Ident.t list) = 
  P.newline f ;
  List.iter (fun (id : Ident.t) -> 
      P.group f 0 @@ (fun _ ->  
          P.string f L.exports;
          P.string f L.dot;
          P.string f (Ext_ident.convert id.name); 
          P.space f ;
          P.string f L.eq;
          P.space f;
          ignore @@ ident cxt f id;
          semi f;);
      P.newline f;
    ) 
    idents

let node_program 
    f
    ({modules; block = b ; exports = exp ; side_effect  } : J.program)
  = 
  let cxt = Ext_pp_scope.empty in
  let cxt = requires cxt  f modules in
  let () = P.force_newline f in
  let cxt =  statement_list true cxt f b  in
  let () = P.force_newline f in
  exports cxt f exp


let amd_program f ({modules; block = b ; exports = exp ; side_effect  } : J.program)
  = 
  let rec aux cxt f modules = 
    match modules with
    | [] -> cxt 
    | [(id,_)] -> ident cxt f id
    | (id,_) :: rest -> 
      let cxt = ident cxt f id in
      P.string f L.comma;
      aux cxt f rest 
  in
  P.newline f ; 
  let cxt = Ext_pp_scope.empty in
  let rec list ~pp_sep pp_v ppf = function
    | [] -> ()
    | [v] -> pp_v ppf v
    | v :: vs ->
      pp_v ppf v;
      pp_sep ppf ();
      list ~pp_sep pp_v ppf vs in

  P.vgroup f 1 @@ fun _ -> 
    P.string f "define([";
    list ~pp_sep:(fun f _ -> P.string f L.comma)
      (fun f (_,s) -> 
         pp_string f ~utf:true ~quote:(best_string_quote s) s; ) f modules;
    P.string f "]";
    P.string f L.comma;
    P.newline f;
    P.string f L.function_;
    P.string f "(";
    let cxt = aux cxt f modules in
    P.string f ")";

    P.brace_vgroup f 1 @@ (fun _ -> 
        let cxt =  statement_list true cxt f  b in 
        (* FIXME AMD : use {[ function xx ]} or {[ var x = function ..]} *)
        P.newline f;
        P.string f L.return;
        P.space f;
        P.brace_vgroup f 1 @@ fun _ -> 
          let rec aux cxt f (idents : Ident.t list) = 
            match idents with
            | [] -> cxt 
            | [id] -> 
              P.string f (Ext_ident.convert id.name);
              P.space f ;
              P.string f L.colon;
              P.space f ;
              ident cxt f id
            | id :: rest 
              -> 
              P.string f (Ext_ident.convert id.name);
              P.space f ;
              P.string f L.colon;
              P.space f;
              let cxt = ident cxt f id  in
              P.string f L.comma;
              P.space f ;
              P.newline f ;
              aux cxt f rest 

          in
          ignore @@ aux cxt f exp);
    P.string f ")";
;;

let pp_program (program : J.program) (f : Ext_pp.t) = 
  let () = 
    P.string f "// Generated CODE, PLEASE EDIT WITH CARE";
    P.newline f; 
    P.newline f ;
    P.string f {|"use strict";|};
  in
  (match Sys.getenv "OCAML_AMD_MODULE" with 
   | exception Not_found -> 
    node_program f program
             | _ -> amd_program f program ) ;
  P.string f (
    match program.side_effect with
    | None -> "/* No side effect */"
    | Some v -> Printf.sprintf "/* %s fail the pure module */" v );
  P.newline f;
  P.flush f ()

let dump_program 
    (program : J.program)
    (oc : out_channel) = 
  pp_program program (P.from_channel oc)
