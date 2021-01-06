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
	set[Message] msg = {};
	
	visit(f){
		case (AExpr) e: msg += check(e, tenv, useDef); 
		case ifThen(AExpr condition, _) : msg += checkSingleBool(condition, tenv, useDef);
		case (AQuestion) q: msg += check(q, tenv, useDef);
	}
	
	
	
	for(true){
	;
	}

  return msg; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
	set[Message] msg = {};
	
	str n = q.qId.name;
	if((<loc l, n, _, Type t> <- tenv) && t != toType(q.qType)){
		msg += {error("This question has type <q.qType.val>, and the other has type <typeToString(t)>", q.src)};
		msg += {error("The location of the other occurence is at", l)};
		
		
		//println("This question has type <q.qType.val>, and the other has type <typeToString(t)>");
	
	}
	
	
  return msg; 
}


// - the declared type computed questions should match the type of the expression.
set[Message] check(computedQuestion(AQuestion q, AExpr qExpr), TEnv tenv, UseDef useDef) {
	set[Message] msg = {};
		
	t = typeOf(qExpr, tenv, useDef);
	
	if(t != toType(q.qType)){
		msg += {error("expected <toType(q.qType)>, but got <typeToString(t)>", qExpr.src)};
	}

	return msg; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msg = {};
  
  switch (e) {
    case ref(AId x):
      msg += { error("Undeclared variable", x.src) | useDef[x.src] == {} };
	case or(AExpr lhs, AExpr rhs) : msg += checkBool(lhs, rhs, tenv, useDef);
	case and(AExpr lhs, AExpr rhs) : msg += checkBool(lhs, rhs, tenv, useDef);
	case equal(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case geq(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case leq(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case greater(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case less(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case subtract(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case add(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case divide(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case multiply(AExpr lhs, AExpr rhs) : msg += checkInt(lhs, rhs, tenv, useDef);
	case not(AExpr lhs) : msg += checkSingleBool(lhs, tenv, useDef);
	case brackets(AExpr lhs) : msg += check(lhs, tenv, useDef);
	
	case boolean(_) : ;
	case integer(_) : ;
	case string(_) : ;
	
	default: msg += {warning("Unhandled expression: <e>", e.src)};
  }
  
  return msg; 
}

set[Message] checkSingleBool(AExpr lhs, TEnv tenv, UseDef useDef){
	lhsType = typeOf(lhs, tenv, useDef);

	msg = lhsType == tbool() ? {} : {error("Expected type was boolean, but got <typeToString(lhsType)>", lhs.src)};
	
	return msg;
}

set[Message] checkBool(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef){
	lhsType = typeOf(lhs, tenv, useDef);
	rhsType = typeOf(rhs, tenv, useDef);

	msg = lhsType == tbool() ? {} : {error("Expected type was boolean, but got <typeToString(lhsType)>", lhs.src)};
	msg += rhsType == tbool() ? {} : {error("Expected type was boolean, but got <typeToString(rhsType)>", rhs.src)};
	
	return msg;
}

set[Message] checkInt(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef){
	lhsType = typeOf(lhs, tenv, useDef);
	rhsType = typeOf(rhs, tenv, useDef);

	msg = lhsType == tint() ? {} : {error("Expected type was integer, but got <typeToString(lhsType)>", lhs.src)};
	msg += rhsType == tint() ? {} : {error("Expected type was integer, but got <typeToString(rhsType)>", rhs.src)};
	
	return msg;
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
	switch (e) {
		case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
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

str typeToString(Type t){
	if(t == tbool()) return"boolean";
	if(t == tint()) return"integer";
	if(t == tstr()) return"string";

	return "unknown";
	
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
 
 

