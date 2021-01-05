module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;
import Boolean;

import IO;//todo: remove

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(Form f) {
  //Form f = sf.top; // remove layout before and after form
  //return form(,,);
  return form(cst2ast(f.id), cst2ast(f.block), src=f@\loc); 
}

ABlock cst2ast(Block b){
	println("in ABlock cst2ast");
	ie = [cst2ast(i) | (BlockElement)  `<IfElse i>` <- b.elements];
	qs = [cst2ast(i) | (BlockElement)  `<Question i>` <- b.elements];
	computed = [cst2ast(i) | (BlockElement)  `<ComputedQuestion i>` <- b.elements];
	
	return block(ie, qs, computed);
}

AQuestion cst2ast(Question q) {
	switch(q) {
  		case(Question) `<Str qText> <Id id> : <Type tipe>`: return question("<qText>", cst2ast(id), cst2ast(tipe), src=q@\loc);
  	
  		default: throw "Unhandled question: <q>";
  	}
}

AComputedQuestion cst2ast(ComputedQuestion cq) {
	switch(cq) {
  		case(ComputedQuestion) `<Question q>  = <Expr e>`: return computedQuestion(cst2ast(q), cst2ast(e), src=cq@\loc);
  	
  		default: throw "Unhandled question: <cq>";
  	}
}

AIf cst2ast(If q) {
	switch(q){
		case(If) `if ( <Expr e> ) <Block b>`: return ifThen(cst2ast(e), cst2ast(b), src=q@\loc);
		default: throw "Unhandled if <q>";
	}
}

AIfElse cst2ast(IfElse q) {
	switch(q) {
  		case(IfElse) `<If i>`: return ifElse(cst2ast(i), block([],[],[]), src=q@\loc);
  		case(IfElse) `<If i> else <Block b>`: return ifElse(cst2ast(i), cst2ast(b), src=q@\loc);
  	
  		default: throw "Unhandled type: <q>";
  	}
}


AExpr cst2ast(Expr e) {

  switch (e) {
    case(Expr) `<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case(Expr) `<Int literal>`: return integer(toInt("<literal>"), src=literal@\loc);
    case(Expr) `<Bool literal>`: return boolean(fromString("<literal>"), src=literal@\loc);
    case(Expr) `<Str literal>`: return string("<literal>", src=literal@\loc);
    case(Expr) `<Expr lhs>||<Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>&&<Expr rhs>`: return and(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>!=<Expr rhs>`: return notEqual(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>==<Expr rhs>`: return equal(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>\>=<Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>\<=<Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>\><Expr rhs>`: return greater(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>\<<Expr rhs>`: return less(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>-<Expr rhs>`: return subtract(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>+<Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>/<Expr rhs>`: return divide(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs>*<Expr rhs>`: return multiply(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `!<Expr lhs>`: return not(cst2ast(lhs), src=e@\loc);
    case(Expr) `(<Expr lhs>)`: return cst2ast(lhs);
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
	switch(t) {
  	case(Type) `<Type t>`: return typ("<t>", src=t@\loc);
  	
  	default: throw "Unhandled type: <t>";
  	}

}

AId cst2ast(Id i){
	println("in AId cst2ast");
	//return id("test123");
	
	switch(i) {
  	case(Id) `<Id i>`: return id("<i>", src=i@\loc);
  	
  	default: throw "Unhandled type: <i>";
  	}
}
