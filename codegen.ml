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
  let the_module = L.create_module context "DRiHM" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  (* and string_t   = L.pointer_type (L.i8_type context) *)
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context
  and string_t   = L.pointer_type (L.i8_type context)
  and int_mat_t   = L.pointer_type (match L.type_by_name llmbit "struct.int_matrix" with (******)
      None -> raise (Failure "Matrix type is missing in C")
    | Some t -> t)
  in
  (* Return the LLVM type for a DRiHM type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Char -> i8_t
    | A.String -> string_t
    | A.Void  -> void_t
    | A.Matrix -> int_mat_t
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

  let print_int_matrix_t = L.function_type i32_t [| int_mat_t; i32_t ; i32_t |] in
  let print_int_matrix_f = L.declare_function "print_int_matrix" print_int_matrix_t the_module in

  let print_float_matrix_t = L.function_type i32_t [| int_mat_t; i32_t ; i32_t |] in
  let print_float_matrix_f = L.declare_function "print_float_matrix" print_float_matrix_t the_module in

  let init_int_matrix_t = L.function_type int_mat_t [|(*int_ptr_t;*) i32_t ; i32_t|] in
  let init_int_matrix_f = L.declare_function "init_int_matrix" init_int_matrix_t the_module in

  let fill_int_matrix_t = L.function_type int_mat_t [|int_mat_t; i32_t; i32_t; i32_t|] in
  let fill_int_matrix_f = L.declare_function "fill_int_matrix" fill_int_matrix_t the_module in

  let fill_float_matrix_t = L.function_type int_mat_t [|int_mat_t; i32_t; i32_t; float_t|] in
  let fill_float_matrix_f = L.declare_function "fill_float_matrix" fill_float_matrix_t the_module in

  let add_int_matrix_t = L.function_type int_mat_t [|int_mat_t; int_mat_t; i32_t; i32_t|] in
  let add_int_matrix_f = L.declare_function "add_int_matrix" add_int_matrix_t the_module in

  let add_float_matrix_t = L.function_type int_mat_t [|int_mat_t; int_mat_t; i32_t; i32_t|] in
  let add_float_matrix_f = L.declare_function "add_float_matrix" add_float_matrix_t the_module in

  let subtract_int_matrix_t = L.function_type int_mat_t [|int_mat_t; int_mat_t; i32_t; i32_t|] in
  let subtract_int_matrix_f = L.declare_function "subtract_int_matrix" subtract_int_matrix_t the_module in

  let subtract_float_matrix_t = L.function_type int_mat_t [|int_mat_t; int_mat_t; i32_t; i32_t|] in
  let subtract_float_matrix_f = L.declare_function "subtract_float_matrix" subtract_float_matrix_t the_module in

  let multiply_int_matrix_t = L.function_type int_mat_t [|int_mat_t; int_mat_t; i32_t; i32_t; i32_t|] in
  let multiply_int_matrix_f = L.declare_function "multiply_int_matrix" multiply_int_matrix_t the_module in

  let multiply_float_matrix_t = L.function_type int_mat_t [|int_mat_t; int_mat_t; i32_t; i32_t; i32_t|] in
  let multiply_float_matrix_f = L.declare_function "multiply_float_matrix" multiply_float_matrix_t the_module in

  let determinant_int_matrix_t = L.function_type i32_t [|int_mat_t; i32_t|] in
  let determinant_int_matrix_f = L.declare_function "int_det" determinant_int_matrix_t the_module in

  let determinant_float_matrix_t = L.function_type i32_t [|int_mat_t; i32_t|] in
  let determinant_float_matrix_f = L.declare_function "float_det" determinant_float_matrix_t the_module in

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
      (*let add_assign (tp, vName, ex) =
        match ex with
        SNoexpr -> (tp, vName)
        | _ ->
        let e' = expr builder e in
          ignore(L.build_store e' (lookup s) builder);
      *)
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

    (*Map of matrix pointers to row and col values*)
    let temp_matrix_map =  ref StringMap.empty
    in
    (*Add row and col dimension information of a newly created matrix*)
    let add_temp_matrix mat_ptr rows cols t =
      temp_matrix_map := StringMap.add (L.value_name mat_ptr) (rows, cols, t) !temp_matrix_map
    in
    let lookup_dim mat_ptr =
      StringMap.find (L.value_name mat_ptr) !temp_matrix_map
    in
    let extract_row mat = match (lookup_dim mat) with
    (row, _, _) -> row
    in
    let extract_col mat = match (lookup_dim mat) with
    (_, col, _) -> col
    in
    let extract_type mat = match (lookup_dim mat) with
    (_, _, t) -> t
    in

    (*Map of matrix variables to matrix pointers*)
    let var_matrix_map = ref StringMap.empty
    in
    (*Called when new assignment is made for a matrix*)
    let add_var_matrix s mat_ptr =
      var_matrix_map := StringMap.add s mat_ptr !var_matrix_map
    in
    let [@warning "-40"] lookup_mat s =
      StringMap.find s !var_matrix_map
    in

    (*Map of string pointers to strings*)
    let temp_string_map = ref StringMap.empty
    in
    let add_temp_string string_ptr string =
      temp_string_map := StringMap.add (L.string_of_llvalue string_ptr) string !temp_string_map;
    in
    let [@warning "-40"] lookup_string string_ptr =
      StringMap.find (L.string_of_llvalue string_ptr) !temp_string_map
    in

    (*Map of string variables to string pointers*)
    let var_string_map = ref StringMap.empty
    in
    (*Called when new assignment is made for a matrix*)
    let add_var_string v string_ptr =
      var_string_map := StringMap.add v string_ptr !var_string_map
    in
    let lookup_string_ptr v =
      StringMap.find v !var_string_map
    in

    let rec expr2 builder ((_, e) : sexpr) = (match e with
        SLiteral i  ->  [L.const_int i32_t i]
      | SBoolLit b  -> [L.const_int i1_t (if b then 1 else 0)]
      | SFliteral l -> [L.const_float float_t l]
      (*Turn character into integer representation*)
      | SCliteral l -> [L.const_int i8_t (int_of_char l)]
      | SSliteral l -> [L.build_global_stringptr l "string" builder]
      | SNoexpr     -> [L.const_int i32_t 0]
      | SMatrixLit (contents, _, _ ) -> build_contents_list contents
      | _ -> raise (Failure "Invalid data type in matrix")
    )
   and
   build_contents_list mat_contents =
     let rec go acc = function
      | [] -> acc
      | hd :: tl -> go (List.append acc (expr2 builder hd)) tl
      in
      go [] mat_contents
    in
    (* Construct code for an expression; return its value *)
    let rec expr builder ((t, e) : sexpr) = match e with
	      SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float float_t l
      (*Turn character into integer representation*)
      | SCliteral l -> L.const_int i8_t (int_of_char l)
      | SSliteral l ->
        let string_ptr = L.build_global_stringptr l "string" builder
        in
        (*L.set_value_name l string_ptr;*)
        ignore(add_temp_string string_ptr l); string_ptr
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       ->
        if t = Matrix then lookup_mat s
        else if t = String then lookup_string_ptr s
        else
        L.build_load (lookup s) s builder
      | SMatrixLit (contents, rows, cols) ->
          let matrix_contents = build_contents_list contents
          in
          let matrix = L.build_call init_int_matrix_f [|L.const_int i32_t rows; L.const_int i32_t cols|] "init_int_matrix" builder
          in
          if L.type_of (List.hd matrix_contents) = i32_t then
            (
            ignore(add_temp_matrix matrix rows cols "int");
            ignore(List.map (fun elt -> L.build_call fill_int_matrix_f [|matrix; L.const_int i32_t rows; L.const_int i32_t cols; elt|] "fill_int_matrix" builder) matrix_contents); matrix
            )
          else if L.type_of (List.hd matrix_contents) = float_t then
            (
            ignore(add_temp_matrix matrix rows cols "float");
            ignore(List.map (fun elt -> L.build_call fill_float_matrix_f [|matrix; L.const_int i32_t rows; L.const_int i32_t cols; elt|] "fill_float_matrix" builder) matrix_contents); matrix
            )
          else raise(Failure "Marix contains incompatible type(s)")
    | SAssign (s, e) ->
      let e' = expr builder e
      in
      if L.type_of e' = int_mat_t then (ignore(add_var_matrix s e'); e')
      else if L.type_of e' = string_t then (ignore(add_var_string s e'); e')
      else
      (ignore(L.build_store e' (lookup s) builder); e')
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
    if (L.type_of e1' = int_mat_t && L.type_of e2' = int_mat_t) then
      let row1 = extract_row e1'
      in
      let col1 = extract_col e1'
      in
      let row2 = extract_row e2'
      in
      let col2 = extract_col e2'
      in
      let dimension_check = (row1 = row2) && (col1 = col2)
      in
      let mult_dimension_check = (col1 = row2)
      in
      match op with
      A.Add  when dimension_check ->
        if ((extract_type e1') = "int" && (extract_type e2') = "int") then
        let matrix = L.build_call add_int_matrix_f [| e1'; e2'; L.const_int i32_t row1; L.const_int i32_t col1|] "add_int_mat" builder
        in
        ignore(add_temp_matrix matrix row1 col1 "int"); matrix
        else
        let matrix = L.build_call add_float_matrix_f [| e1'; e2'; L.const_int i32_t row1; L.const_int i32_t col1|] "add_float_mat" builder
        in
        ignore(add_temp_matrix matrix row1 col1 "float"); matrix
    | A.Sub when dimension_check    ->
        if ((extract_type e1') = "int" && (extract_type e2') = "int") then
        let matrix = L.build_call subtract_int_matrix_f [| e1'; e2'; L.const_int i32_t row1; L.const_int i32_t col1|] "subtract_int_mat" builder
        in
        ignore(add_temp_matrix matrix row1 col1 "int"); matrix
        else
        let matrix = L.build_call subtract_float_matrix_f [| e1'; e2'; L.const_int i32_t row1; L.const_int i32_t col1|] "subtract_float_mat" builder
        in
        ignore(add_temp_matrix matrix row1 col1 "float"); matrix
    | A.Mult when mult_dimension_check ->
        if ((extract_type e1') = "int" && (extract_type e2') = "int") then
        let matrix = L.build_call multiply_int_matrix_f [|e1'; e2'; L.const_int i32_t row1; L.const_int i32_t col1; L.const_int i32_t col2|] "multiply_int_mat" builder
        in
        ignore(add_temp_matrix  matrix row1 col2 "int"); matrix
        else
        let matrix = L.build_call multiply_float_matrix_f [|e1'; e2'; L.const_int i32_t row1; L.const_int i32_t col1; L.const_int i32_t col2|] "multiply_float_mat" builder
        in
        ignore(add_temp_matrix  matrix row1 col2 "float"); matrix
    |_ -> raise (Failure "Matrix dimension mismatch")
    else if (L.type_of e1' = string_t && L.type_of e2' = string_t) then
      match op with
      A.Add ->
        let s1 = lookup_string e1'
        in
        let s2 = lookup_string e2'
        in
        let buffer_to_string b =
          Buffer.add_string b s1;
          Buffer.add_string b s2;
          Buffer.contents b
        in
        let new_string = buffer_to_string (Buffer.create 80)
        in
        let string_ptr = L.build_global_stringptr new_string "string" builder
        in
        (*L.set_value_name new_string string_ptr;*)
        ignore(add_temp_string string_ptr new_string); string_ptr
      | _ -> raise (Failure "Unsupported operation for String types")
    else
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
      | SCall ("printm", [e]) ->
        let e' = expr builder e
        in
        let rows = extract_row e'
        in
        let cols = extract_col e'
        in
        if ((extract_type e') = "int") then
        L.build_call print_int_matrix_f [| (e'); ( L.const_int i32_t rows); (L.const_int i32_t cols)|] "printm" builder
        else
        L.build_call print_float_matrix_f [| (e'); ( L.const_int i32_t rows); (L.const_int i32_t cols)|] "printm" builder
      | SCall ("det", [e]) ->
        (*need to add dimension checking*)
        let e' = expr builder e
        in
        let rows = extract_row e'
        in
        let cols = extract_col e'
        in
        if rows = cols then
          if ((extract_type e') = "int") then
            L.build_call determinant_int_matrix_f [|(e'); (L.const_int i32_t rows)|] "int_det" builder
          else
            L.build_call determinant_float_matrix_f [|(e'); (L.const_int i32_t rows)|] "float_det" builder
        else raise(Failure "Determinant can't be calculated for a matrix that doesn't have eqaul number of rows and columns")
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
