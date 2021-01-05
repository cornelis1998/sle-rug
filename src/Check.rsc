module Check

import AST;
import Resolve;
import Message; // see standard library

import IO;//todo: remove


data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
	RefGraph rg = resolve(f);
	TEnv env = {};
	
	visit(f){
		case (AQuestion) q : env += {<q.src, q.qId.name, q.qText, toType(q.qType)>};
	}
	
  return env; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
	

  return {}; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
	

  return {}; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
	case or(AExpr lhs, AExpr rhs) : 
		if(!(typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef)==tbool())) 
			msgs += { error("or operator need 2 boolean operants", e.src)};

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
	switch (e) {
		case ref(id(_, src = loc u)):  
			if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
				return t;
			}
		case boolean(_) : return tbool();
		case integer(_) : return tint();
		case string(_) : return tstr();
		case or(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef)==tbool()) ? tbool(): tunknown();
		case and(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef)==tbool()) ? tbool(): tunknown();
		case equal(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef)) ? tbool(): tunknown();
		case geq(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case leq(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case greater(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case less(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case subtract(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case add(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case divide(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case multiply(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef)==tint()) ? tint(): tunknown();
		case not(AExpr lhs): return (typeOf(lhs, tenv, useDef) == tbool()) ? tbool(): tunknown();
		case brackets(AExpr lhs): return typeOf(lhs, tenv, useDef);

  }
  return tunknown(); 
}

Type toType(typ(str val)){
	//println(val);

	if(val == "string") return tstr();
	if(val == "boolean") return tbool();
	if(val == "integer") return tint();
	
	return tunknown();
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

