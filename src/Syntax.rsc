
module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id id Block block; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = Str question Id id ":" Type type; 

syntax ComputedQuestion
	= Question question "=" Expr computation;

syntax If
	= "if (" Expr condition ")" Block body;
	//| "if(" Expr condition ")" Block body;
	//TODO: allow if without space, add to cst2ast
	
	
syntax IfElse
	= If main ("else" Block thenBody)?;

syntax Block
	= "{" BlockElement* elements "}";
	//= "{" (If|IfElse|Question|ComputedQuestion)* element "}";
syntax BlockElement
	= IfElse|Question|ComputedQuestion;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = "(" Expr ")"
  	> right "!" Expr
  	> left Expr "*" Expr
  	| Expr "/" Expr
  	> left Expr lhs "+" Expr rhs
  	| Expr lhs "-" Expr rhs
  	> left Expr lhs "\<" Expr rhs
  	| Expr lhs "\>" Expr rhs
  	| Expr lhs "\<=" Expr rhs
  	| Expr lhs "\>=" Expr rhs
  	> left Expr lhs "==" Expr rhs
  	| Expr lhs "!=" Expr rhs
  	> left Expr lhs "&&" Expr rhs
  	> left Expr lhs "||" Expr rhs
  	> left Str literal
  	| Int literal
  	| Bool literal
  	> left Id \ "true" \ "false"; // true/false are reserved keywords
  
syntax Type
  = "integer"
  	| "boolean"
  	| "string";  
  
lexical Str = "\"" ![\"]*"\"";

lexical Int 
  = "-"?[1-9][0-9]*
  	| "0";

lexical Bool = "true"
	| "false";



