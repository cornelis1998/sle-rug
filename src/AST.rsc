module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(AId name, ABlock block)
  ; 

data ABlock(loc src = |tmp:///|)
	= block(
		list[AIfElse] ifElses,
		list[AQuestion] questions, 
		list[AComputedQuestion] computedQuestions
		);

data AQuestion(loc src = |tmp:///|)
	= question(str qText, AId qId, AType qType);
	
data AComputedQuestion(loc src = |tmp:///|)
	= computedQuestion(AQuestion q, AExpr qExpr); 
  
data AIf(loc src = |tmp:///|)
	= ifThen(AExpr condition, ABlock body);

data AIfElse(loc src = |tmp:///|)
	=ifElse(AIf ifThen, ABlock elseBody);

data AExpr(loc src = |tmp:///|)
  = brackets(AExpr expr)
  | not(AExpr expr)
  | multiply(AExpr lhs, AExpr rhs)
  | divide(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | subtract(AExpr lhs, AExpr rhs)
  | less(AExpr lhs, AExpr rhs)
  | greater(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | equal(AExpr lhs, AExpr rhs)
  | notEqual(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  | string(str val)
  | integer(int i)
  | boolean(bool b)
  | ref(AId id);

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
	= typ(str val);
