(* OCamlScript compiler
 * Copyright (C) 2015-2016 Bloomberg Finance L.P.
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
(* Author: Hongbo Zhang  *)
(** GENERATED CODE for fold visitor patten of JS IR  *)
open J
  
class virtual fold =
  object ((o : 'self_type))
    method string : string -> 'self_type = o#unknown
    method option :
      'a. ('self_type -> 'a -> 'self_type) -> 'a option -> 'self_type =
      fun _f_a -> function | None -> o | Some _x -> let o = _f_a o _x in o
    method list :
      'a. ('self_type -> 'a -> 'self_type) -> 'a list -> 'self_type =
      fun _f_a ->
        function
        | [] -> o
        | _x :: _x_i1 -> let o = _f_a o _x in let o = o#list _f_a _x_i1 in o
    method int : int -> 'self_type = o#unknown
    method bool : bool -> 'self_type = function | false -> o | true -> o
    method vident : vident -> 'self_type =
      function
      | Id _x -> let o = o#ident _x in o
      | Qualified (_x, _x_i1, _x_i2) ->
          let o = o#ident _x in
          let o = o#kind _x_i1 in
          let o = o#option (fun o -> o#string) _x_i2 in o
    method variable_declaration : variable_declaration -> 'self_type =
      fun { ident = _x; value = _x_i1; property = _x_i2; ident_info = _x_i3 }
        ->
        let o = o#ident _x in
        let o = o#option (fun o -> o#expression) _x_i1 in
        let o = o#property _x_i2 in let o = o#ident_info _x_i3 in o
    method statement_desc : statement_desc -> 'self_type =
      function
      | Block _x -> let o = o#block _x in o
      | Variable _x -> let o = o#variable_declaration _x in o
      | Exp _x -> let o = o#expression _x in o
      | If (_x, _x_i1, _x_i2) ->
          let o = o#expression _x in
          let o = o#block _x_i1 in
          let o = o#option (fun o -> o#block) _x_i2 in o
      | While (_x, _x_i1, _x_i2, _x_i3) ->
          let o = o#option (fun o -> o#label) _x in
          let o = o#expression _x_i1 in
          let o = o#block _x_i2 in let o = o#unknown _x_i3 in o
      | ForRange (_x, _x_i1, _x_i2, _x_i3, _x_i4, _x_i5) ->
          let o = o#option (fun o -> o#for_ident_expression) _x in
          let o = o#finish_ident_expression _x_i1 in
          let o = o#for_ident _x_i2 in
          let o = o#for_direction _x_i3 in
          let o = o#block _x_i4 in let o = o#unknown _x_i5 in o
      | Continue _x -> let o = o#label _x in o
      | Break -> o
      | Return _x -> let o = o#return_expression _x in o
      | Int_switch (_x, _x_i1, _x_i2) ->
          let o = o#expression _x in
          let o =
            o#list
              (fun o ->
                 (* OCamlScript compiler
 * Copyright (C) 2015-2016 Bloomberg Finance L.P.
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
                 (* Author: Hongbo Zhang  *)
                 (** Javascript IR
  
    It's a subset of Javascript AST specialized for OCaml lambda backend

    Note it's not exactly the same as Javascript, the AST itself follows lexical
    convention and [Block] is just a sequence of statements, which means it does 
    not introduce new scope
*)
                 (** object literal, if key is ident, in this case, it might be renamed by 
    Google Closure  optimizer,
    currently we always use quote
 *)
                 (* Since camldot is only available for toplevel module accessors,
       we don't need print  `A.length$2`
       just print `A.length` - it's guarateed to be unique
       
       when the third one is None, it means the whole module 
     *)
                 (* used in [js_create_array] primitive, note having
       uninitilized array is not as bad as in ocaml, 
       since GC does not rely on it
     *)
                 (* For [caml_array_append]*) (* typeof v === "number"*)
                 (* !v *) (* String.fromCharCode.apply(null, args) *)
                 (* Convert JS boolean into OCaml boolean 
       like [+true], note this ast talks using js
       terminnology unless explicity stated                       
     *)
                 (* to support 
       val log1 : 'a -> unit
       val log2 : 'a -> 'b -> unit 
       val log3 : 'a -> 'b -> 'c -> unit 
     *)
                 (* TODO: Add some primitives so that [js inliner] can do a better job *)
                 (* | Int32_bin of int_op * expression * expression *)
                 (* f.apply(null,args) -- Fully applied guaranteed 
       TODO: once we know args's shape --
       if it's know at compile time, we can turn it into
       f(args[0], args[1], ... )
     *)
                 (* Analysze over J expression is hard since, 
        some primitive  call is translated 
        into a plain call, it's better to keep them
    *)
                 (* Invariant: 
       The second argument has to be type of [int],
       This can be constructed either in a static way [E.index] or a dynamic way 
       [E.access]
     *)
                 (* The third argument bool indicates whether we should 
       print it as 
       a["idd"] -- false
       or 
       a.idd  -- true
       There are several kinds of properties
       1. OCaml module dot (need to be escaped or not)
          All exported declarations have to be OCaml identifiers
       2. Javascript dot (need to be preserved/or using quote)
     *)
                 (* TODO: option remove *)
                 (* A string is UTF-8 encoded, the string may contain
       escape sequences.
       The first argument is used to mark it is non-pure, please
       don't optimize it, since it does have side effec, 
       examples like "use asm;" and our compiler may generate "error;..." 
       which is better to leave it alone
     *)
                 (* pure*) (* pure *)
                 (* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/block
   block can be nested, specified in ES3 
 *)
                 (* Delay some units like [primitive] into JS layer ,
   benefit: better cross module inlining, and smaller IR size?
 *)
                 (* 
  [closure] captured loop mutable values in the outer loop

  check if it contains loop mutable values, happens in nested loop
  when closured, it's no longer loop mutable value. 
  which means the outer loop mutable value can not peek into the inner loop
  {[
  var i = f ();
  for(var finish = 32; i < finish; ++i){
  }
  ]}
  when [for_ident_expression] is [None], [var i] has to 
  be initialized outside, so 

  {[
  var i = f ()
  (function (xxx){
  for(var finish = 32; i < finish; ++i)
  }(..i))
  ]}
  This happens rare it's okay

  this is because [i] has to be initialized outside, if [j] 
  contains a block side effect
  TODO: create such example
*)
                 (* Since in OCaml, 
   
  [for i = 0 to k end do done ]
  k is only evaluated once , to encode this invariant in JS IR,
  make sure [ident] is defined in the first b

  TODO: currently we guarantee that [bound] was only 
  excecuted once, should encode this in AST level
*)
                 (* Can be simplified to keep the semantics of OCaml
   For (var i, e, ...){
     let  j = ... 
   }

   if [i] or [j] is captured inside closure

   for (var i , e, ...){
     (function (){
     })(i)
   }
*)
                 (* Single return is good for ininling..
   However, when you do tail-call optmization
   you loose the expression oriented semantics
   Block is useful for implementing goto
   {[
   xx:{
   break xx;
   }
   ]}
*)
                 (* Function declaration and Variable declaration  *)
                 (* check if it contains loop mutable values, happens in nested loop *)
                 (* only used when inline a fucntion *)
                 (* Here we need track back a bit ?, move Return to Function ...
                              Then we can only have one Return, which is not good *)
                 o#case_clause (fun o -> o#int))
              _x_i1 in
          let o = o#option (fun o -> o#block) _x_i2 in o
      | String_switch (_x, _x_i1, _x_i2) ->
          let o = o#expression _x in
          let o =
            o#list (fun o -> o#case_clause (fun o -> o#string)) _x_i1 in
          let o = o#option (fun o -> o#block) _x_i2 in o
      | Throw _x -> let o = o#expression _x in o
      | Try (_x, _x_i1, _x_i2) ->
          let o = o#block _x in
          let o =
            o#option
              (fun o (_x, _x_i1) ->
                 let o = o#exception_ident _x in let o = o#block _x_i1 in o)
              _x_i1 in
          let o = o#option (fun o -> o#block) _x_i2 in o
    method statement : statement -> 'self_type =
      fun { statement_desc = _x; comment = _x_i1 } ->
        let o = o#statement_desc _x in
        let o = o#option (fun o -> o#string) _x_i1 in o
    method return_expression : return_expression -> 'self_type =
      fun { return_value = _x } -> let o = o#expression _x in o
    method required_modules : required_modules -> 'self_type = o#unknown
    method property_name : property_name -> 'self_type = o#string
    method property_map : property_map -> 'self_type =
      o#list
        (fun o (_x, _x_i1) ->
           let o = o#property_name _x in let o = o#expression _x_i1 in o)
    method property : property -> 'self_type = o#unknown
    method program : program -> 'self_type =
      fun
        {
          name = _x;
          modules = _x_i1;
          block = _x_i2;
          exports = _x_i3;
          export_set = _x_i4;
          side_effect = _x_i5
        } ->
        let o = o#string _x in
        let o = o#required_modules _x_i1 in
        let o = o#block _x_i2 in
        let o = o#exports _x_i3 in
        let o = o#unknown _x_i4 in
        let o = o#option (fun o -> o#string) _x_i5 in o
    method number : number -> 'self_type = o#unknown
    method mutable_flag : mutable_flag -> 'self_type = o#unknown
    method label : label -> 'self_type = o#string
    method kind : kind -> 'self_type = o#unknown
    method int_op : int_op -> 'self_type = o#unknown
    method ident_info : ident_info -> 'self_type = o#unknown
    method ident : ident -> 'self_type = o#unknown
    method for_ident_expression : for_ident_expression -> 'self_type =
      o#expression
    method for_ident : for_ident -> 'self_type = o#ident
    method for_direction : for_direction -> 'self_type = o#unknown
    method finish_ident_expression : finish_ident_expression -> 'self_type =
      o#expression
    method expression_desc : expression_desc -> 'self_type =
      function
      | Math (_x, _x_i1) ->
          let o = o#string _x in
          let o = o#list (fun o -> o#expression) _x_i1 in o
      | Array_length _x -> let o = o#expression _x in o
      | String_length _x -> let o = o#expression _x in o
      | Bytes_length _x -> let o = o#expression _x in o
      | Function_length _x -> let o = o#expression _x in o
      | Char_of_int _x -> let o = o#expression _x in o
      | Char_to_int _x -> let o = o#expression _x in o
      | Array_of_size _x -> let o = o#expression _x in o
      | Array_append (_x, _x_i1) ->
          let o = o#expression _x in
          let o = o#list (fun o -> o#expression) _x_i1 in o
      | Tag_ml_obj _x -> let o = o#expression _x in o
      | String_append (_x, _x_i1) ->
          let o = o#expression _x in let o = o#expression _x_i1 in o
      | Int_of_boolean _x -> let o = o#expression _x in o
      | Is_type_number _x -> let o = o#expression _x in o
      | Not _x -> let o = o#expression _x in o
      | String_of_small_int_array _x -> let o = o#expression _x in o
      | Dump (_x, _x_i1) ->
          let o = o#unknown _x in
          let o = o#list (fun o -> o#expression) _x_i1 in o
      | Seq (_x, _x_i1) ->
          let o = o#expression _x in let o = o#expression _x_i1 in o
      | Cond (_x, _x_i1, _x_i2) ->
          let o = o#expression _x in
          let o = o#expression _x_i1 in let o = o#expression _x_i2 in o
      | Bin (_x, _x_i1, _x_i2) ->
          let o = o#binop _x in
          let o = o#expression _x_i1 in let o = o#expression _x_i2 in o
      | FlatCall (_x, _x_i1) ->
          let o = o#expression _x in let o = o#expression _x_i1 in o
      | Call (_x, _x_i1, _x_i2) ->
          let o = o#expression _x in
          let o = o#list (fun o -> o#expression) _x_i1 in
          let o = o#unknown _x_i2 in o
      | String_access (_x, _x_i1) ->
          let o = o#expression _x in let o = o#expression _x_i1 in o
      | Access (_x, _x_i1) ->
          let o = o#expression _x in let o = o#expression _x_i1 in o
      | Dot (_x, _x_i1, _x_i2) ->
          let o = o#expression _x in
          let o = o#string _x_i1 in let o = o#bool _x_i2 in o
      | New (_x, _x_i1) ->
          let o = o#expression _x in
          let o = o#option (fun o -> o#list (fun o -> o#expression)) _x_i1
          in o
      | Var _x -> let o = o#vident _x in o
      | Fun (_x, _x_i1, _x_i2) ->
          let o = o#list (fun o -> o#ident) _x in
          let o = o#block _x_i1 in let o = o#unknown _x_i2 in o
      | Str (_x, _x_i1) -> let o = o#bool _x in let o = o#string _x_i1 in o
      | Array (_x, _x_i1) ->
          let o = o#list (fun o -> o#expression) _x in
          let o = o#mutable_flag _x_i1 in o
      | Number _x -> let o = o#number _x in o
      | Object _x -> let o = o#property_map _x in o
    method expression : expression -> 'self_type =
      fun { expression_desc = _x; comment = _x_i1 } ->
        let o = o#expression_desc _x in
        let o = o#option (fun o -> o#string) _x_i1 in o
    method exports : exports -> 'self_type = o#unknown
    method exception_ident : exception_ident -> 'self_type = o#ident
    method case_clause :
      (* since in ocaml, it's expression oriented langauge, [return] in
    general has no jumps, it only happens when we do 
    tailcall conversion, in that case there is a jump.
    However, currently  a single [break] is good to cover
    our compilation strategy 

    Attention: we should not insert [break] arbitrarily, otherwise 
    it would break the semantics
    A more robust signature would be 
    {[ goto : label option ; ]}
  *)
        'a. ('self_type -> 'a -> 'self_type) -> 'a case_clause -> 'self_type =
      fun _f_a { case = _x; body = _x_i1 } ->
        let o = _f_a o _x in
        let o =
          (fun (_x, _x_i1) -> let o = o#block _x in let o = o#bool _x_i1 in o)
            _x_i1
        in o
    method block : block -> 'self_type = (* true means break *)
      (* TODO: For efficency: block should not be a list, it should be able to 
   be concatenated in both ways 
 *)
      o#list (fun o -> o#statement)
    method binop : binop -> 'self_type = o#unknown
    method unknown : 'a. 'a -> 'self_type = fun _ -> o
  end
  

