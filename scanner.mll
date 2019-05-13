(* Ocamllex scanner for MicroC *)

{ open Microcparse }

let digit = ['0' - '9']
let digits = digit+

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['      { LBRACKET }
| ']'      { RBRACKET }
| ';'      { SEMI }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '='      { ASSIGN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| "!"      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "matrix" { MATRIX }
| "int"    { INT }
| "bool"   { BOOL }
| "float"  { FLOAT }
| "char"   { CHAR }
| "string" { STRING }
| "void"   { VOID }
| "true"   { BLIT(true)  }
| "false"  { BLIT(false) }
| digits as lxm { LITERAL(int_of_string lxm) }
(*| digits '.'  digit* ( ['e' 'E'] ['+' '-']? digits )? as lxm { FLIT(lxm) }*)
| digits '.' digits as lxm { FLIT(float_of_string lxm) }
| ['\'']['a'-'z' 'A'-'Z' '0'-'9' '!''@''#''$''%''^''&''*''('')''_''-''+''=''{''[''}' ']' '\'' '|' '~' '`'  '\"' ':' ';' '<' ',' '>' '.' '?' '/']['\'']
 as lxm { CLIT(String.get lxm 1) }
 |['\"'](['a'-'z' ' ' 'A'-'Z' '0'-'9' '!''@''#''$''%''^''&''*''('')''_''-''+''=''{''[''}' ']' '\'' '|' '~' '`' ':' ';' '<' ',' '>' '.' '?' '/']* as lxm)['\"']
  { SLIT(lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*     as lxm { ID(lxm) }
(* | string as { STRINGLIT(un_esc s) } *)
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }
