(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast
open Sast

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module *)
let translate (globals, functions) =
  let context    = L.global_context () in
  let llmem = L.MemoryBuffer.of_file "matrix.bc" in
  let llmbit = Llvm_bitreader.parse_bitcode context llmem in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "MicroC" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  (* and string_t   = L.pointer_type (L.i8_type context) *)
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context
  (*and int_array_t = L.pointer_type (L.i32_type context)*)
  and int_array_t = L.i32_type    context
  and mat_t   = L.pointer_type (match L.type_by_name llmbit "INT_MATRIX" with (******)
      None -> raise (Failure "Matrix type is missing in C")
    | Some t -> t)
  (*and int_matrix_t = L.pointer_type (L.pointer_type (L.i32_type context))*)
  and int_matrix_t = L.i32_type    context
  in
  (* Return the LLVM type for a MicroC type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Char -> i8_t
    (* | A.String -> string_t *)
    | A.Void  -> void_t
    (*Need to change later*)
    | A.Matrix -> int_matrix_t
  in

  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
  (* let global_var m (t, n) = *)
    let global_var m (t, n, _) =
      let init = match t with
          A.Float -> L.const_float (ltype_of_typ t) 0.0
        (* | A.String -> L.const_array (ltype_of_typ t) "0" *)
        | _ -> L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  let printf_t : L.lltype =
      L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue =
      L.declare_function "printf" printf_t the_module in

  (* let printbig_t : L.lltype =
      L.function_type i32_t [| i32_t |] in
  let printbig_func : L.llvalue =
      L.declare_function "printbig" printbig_t the_module in *)

  let printMatrix_t = L.function_type i32_t [| mat_t; i32_t ; i32_t |] in
  let printMatrix_f = L.declare_function "print_int_matrix" printMatrix_t the_module in

  (*
  let matrix_init_t = L.function_type matrix_t [|i32_t ; i32_t|] in
  let matrix_init_f = L.declare_function "initMatrix_CG" matrix_init_t the_module in
  *)
  let init_int_matrix_t = L.function_type mat_t [|int_matrix_t; i32_t; i32_t|] in
  let init_int_matrix_f = L.declare_function "init_int_matrix" init_int_matrix_t the_module in

  let fill_int_matrix_t = L.function_type mat_t [|mat_t; i32_t; i32_t; i32_t; i32_t|] in
  let fill_int_matrix_f = L.declare_function "fill_int_matrix" fill_int_matrix_t the_module in

  (* Define each function (arguments and return type) so we can
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types =
	Array.of_list (List.map (fun (t,_,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in

  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and char_format_str = L.build_global_stringptr "%c\n" "fmt" builder
    and string_format_str = L.build_global_stringptr "%s\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p =
        L.set_value_name n p;
	let local = L.build_alloca (ltype_of_typ t) n builder in
        ignore (L.build_store p local builder);
	StringMap.add n local m

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
      and add_local m (t, n) =
	let local_var = L.build_alloca (ltype_of_typ t) n builder
	in StringMap.add n local_var m
      in
(*********)
      let sformals = List.map (fun (tp, vName, _) -> (tp, vName)) fdecl.sformals in
      let slocals= List.map (fun (tp, vName, _) -> (tp, vName)) fdecl.slocals in
(*********)
        (* let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals *)
      let formals = List.fold_left2 add_formal StringMap.empty sformals
          (Array.to_list (L.params the_function)) in
          (* List.fold_left add_local formals fdecl.slocals *)
      List.fold_left add_local formals slocals
    in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in
    (*
    let get_values_list2 ll : L.llvalue list  =
      let rec go acc = function
        | [] -> List.rev acc
        | l :: r -> go (List.rev_append l acc) r
          in
          go [] ll
    in
    *)
    let rec expr2 builder ((_, e) : sexpr) = (match e with
       SLiteral i  ->  [L.const_int i32_t i]
      | SBoolLit b  -> [L.const_int i1_t (if b then 1 else 0)]
      | SFliteral l -> [L.const_float_of_string float_t l]
      (*Turn character into integer representation*)
      | SCliteral l -> [L.const_int i8_t (int_of_char l)]
      (* | SSliteral l ->  L.build_global_stringptr s "str" builder *)
      | SNoexpr     -> [L.const_int i32_t 0]
      (* | SId s       -> L.build_load (lookup s) s builder *)
      (*dummy variable, mat shouldn't implement string type but for the sake of ocaml compiler*)
      | SLiteral i  -> [L.const_int i32_t i]
      | SMatrixLit (contents, rows, cols) -> get_values_list contents
    )
    and
    get_values_list mat_contents =
     let rec go acc = function
      | [] -> acc
      | hd :: tl -> go (List.append acc (expr2 builder hd)) tl
      in
      go [] mat_contents
    in
    let list_to_array l =
      let rec put_element arr list_content index =
        match list_content with
        [] -> arr
        | hd :: tl -> put_element (Array.set arr index hd; arr) tl (index + 1)
        in
        put_element (Array.make (List.length l) (List.hd l)) l 0
    in
    (*
    let to_llvm_array arr =
      L.const_array (L.type_of (Array.get arr 0)) arr
    in
    *)
    let build_int_pointer arr =
      L.const_gep (Array.get arr 0) arr
    in

     (*
      match m with
      | SMatrixLit (contents, rows, cols) ->
      let rec expr_list = function
        [] -> []
        | hd::tl -> expr2 builder hd::expr_list tl
          in
          let contents' = expr_list contents
          in
          get_values_list2 contents'

      | _ -> None
      in
      *)
(*
      let to_list m =

        let build_list (expr_list : sexpr list) acc = match List.hd expr_list with
          *)

    (* Construct code for an expression; return its value *)
    let rec expr builder ((_, e) : sexpr) = match e with
	      SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      (*Turn character into integer representation*)
      | SCliteral l -> L.const_int i8_t (int_of_char l)
      (* | SSliteral l ->  L.build_global_stringptr s "str" builder *)
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> L.build_load (lookup s) s builder

      | SMatrixLit (contents, rows, cols) ->
        let content_ptr = build_int_pointer (list_to_array (get_values_list contents))
        in
        L.build_call init_int_matrix_f [| content_ptr; L.const_int i32_t rows ; L.const_int i32_t cols|] "init_int_matrix" builder
        (*
        in
        ignore(List.map (fun f -> L.build_call fill_int_matrix [|mat; |]))
        let rec fill_matrix matrix row col arr count=
          if count == row * col - 1 then matrix
          else fill_matrix (L.build_call fill_int_matrix_f [| matrix; L.const_int i32_t row; L.const_int i32_t col; L.const_int i32_t (Array.get arr count); L.const_int i32_t count|])
              row col arr count + 1
          in
          fill_matrix create_empty_int_matrix rows cols contents' 0
          *)
        (*
        let rec expr_list = function
          [] -> []
          | hd::tl -> expr builder hd::expr_list tl
            in
            let contents' = expr_list contents
            in
            let m = L.build_call matrix_init_f [| L.const_int i32_t cols; L.const_int i32_t rows |] "matrix_init" builder
            in m
          *)

    | SAssign (s, e) -> let e' = expr builder e in
                          ignore(L.build_store e' (lookup s) builder); e'
    | SBinop ((A.Float,_ ) as e1, op, e2) ->
	  let e1' = expr builder e1
	  and e2' = expr builder e2 in
	  (match op with
	    A.Add     -> L.build_fadd
	  | A.Sub     -> L.build_fsub
	  | A.Mult    -> L.build_fmul
	  | A.Div     -> L.build_fdiv
	  | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
	  | A.Neq     -> L.build_fcmp L.Fcmp.One
	  | A.Less    -> L.build_fcmp L.Fcmp.Olt
	  | A.Leq     -> L.build_fcmp L.Fcmp.Ole
	  | A.Greater -> L.build_fcmp L.Fcmp.Ogt
	  | A.Geq     -> L.build_fcmp L.Fcmp.Oge
	  | A.And | A.Or ->
	      raise (Failure "internal error: semant should have rejected and/or on float")
	  ) e1' e2' "tmp" builder
      | SBinop (e1, op, e2) ->
	  let e1' = expr builder e1
	  and e2' = expr builder e2 in
	  (match op with
	    A.Add     -> L.build_add
	  | A.Sub     -> L.build_sub
	  | A.Mult    -> L.build_mul
          | A.Div     -> L.build_sdiv
	  | A.And     -> L.build_and
	  | A.Or      -> L.build_or
	  | A.Equal   -> L.build_icmp L.Icmp.Eq
	  | A.Neq     -> L.build_icmp L.Icmp.Ne
	  | A.Less    -> L.build_icmp L.Icmp.Slt
	  | A.Leq     -> L.build_icmp L.Icmp.Sle
	  | A.Greater -> L.build_icmp L.Icmp.Sgt
	  | A.Geq     -> L.build_icmp L.Icmp.Sge
	  ) e1' e2' "tmp" builder
      | SUnop(op, ((t, _) as e)) ->
          let e' = expr builder e in
	  (match op with
	    A.Neg when t = A.Float -> L.build_fneg
	  | A.Neg                  -> L.build_neg
          | A.Not                  -> L.build_not) e' "tmp" builder
      | SCall ("print", [e]) | SCall ("printb", [e]) ->
	  L.build_call printf_func [| int_format_str ; (expr builder e) |]
	    "printf" builder
      (* | SCall ("printbig", [e]) ->
	  L.build_call printbig_func [| (expr builder e) |] "printbig" builder *)
      | SCall ("printf", [e]) ->
	  L.build_call printf_func [| float_format_str ; (expr builder e) |]
	    "printf" builder
      | SCall ("printc", [e]) ->
    L.build_call printf_func [| char_format_str ; (expr builder e) |]
      "printf" builder

      | SCall ("printm", [e;e1;e2]) ->
        (*
        match e with
        (Matrix,  SMatrixLit (contents, rows, cols)) ->
        let contents' = build_int_pointer (list_to_array (contents e)) in
        *)
        L.build_call printMatrix_f [| (expr builder e); (expr builder e1) ; (expr builder e2)|] "print_int_matrix" builder
        (* THIS DOES NOT WORK^ *)

      | SCall ("prints", [e]) ->
    L.build_call printf_func [| string_format_str ; (expr builder e) |]
      "printf" builder
      | SCall (f, args) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
	 let llargs = List.rev (List.map (expr builder) (List.rev args)) in
	 let result = (match fdecl.styp with
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
    in

    (* LLVM insists each basic block end with exactly one "terminator"
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
	Some _ -> ()
      | None -> ignore (instr builder) in

    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)

    let rec stmt builder = function
	SBlock sl -> List.fold_left stmt builder sl
      | SExpr e -> ignore(expr builder e); builder
      | SReturn e -> ignore(match fdecl.styp with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder
                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder );
                     builder
      | SIf (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
	 let merge_bb = L.append_block context "merge" the_function in
         let build_br_merge = L.build_br merge_bb in (* partial function *)

	 let then_bb = L.append_block context "then" the_function in
	 add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
	   build_br_merge;

     (* first generates else/then label, then the statements *)

	 let else_bb = L.append_block context "else" the_function in
	 add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
	   build_br_merge;

    (* let end_b = L.append_block context "if_end" the_function in
    let br_end = L.build end_b in *)

    (* add_terminal(L.builder_at_end context then_b) br_end;
    add_terminal(L.builder_at_end context else_b) br_end;
    ignore(L.build_cond_br bool_val then_b else_b builder); *)

	 ignore(L.build_cond_br bool_val then_bb else_bb builder);
	 L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->

    (* let while_b = L.append_block context "while_end" the_function in
    (* generate label, then code for predicate *)
    let while_end = L.build_br while_b in
      (* Check statement *)
    let bool_addr = build_expr predicate in

    (* now we need to jump the body*)
    let body_b = L.append_block contest "while_body" the_function in
        (* Check statement *)
    ignore(build_stmt the_function (L.builder_at_end context body_b) body);
    add_terminal (stmt (L.builder_at_end context body_b) br_while; *)

	  let pred_bb = L.append_block context "while" the_function in
	  ignore(L.build_br pred_bb builder);

	  let body_bb = L.append_block context "while_body" the_function in
	  add_terminal (stmt (L.builder_at_end context body_bb) body)
	    (L.build_br pred_bb);

	  let pred_builder = L.builder_at_end context pred_bb in
	  let bool_val = expr pred_builder predicate in

	  let merge_bb = L.append_block context "merge" the_function in
	  ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
	  L.builder_at_end context merge_bb

      (* Implement for loops as while loops *)
      | SFor (e1, e2, e3, body) -> stmt builder
	    ( SBlock [SExpr e1 ; SWhile (e2, SBlock [body ; SExpr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.styp with
        A.Void -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module
