module Eval

import AST;
import Resolve;

import IO;//TODO: remove

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
	VEnv venv = ();

	visit(f){
		case (AQuestion) q : {
			//println("test123");
			switch(q.qType){
				case typ("string"): venv +=(q.qId.name: vstr(""));
				case typ("integer"): venv += (q.qId.name: vint(0));
				case typ("boolean"): venv += (q.qId.name: vbool(false));
				
				default: println("Question type not known <q.qType.val>");//This shouldn't happen, but well
			}
			
		}
	}

  return venv;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  return (); 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  return (); 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(AId id): return venv[id.name];
    case boolean(bool b): return vbool(b);
    case integer(int x): return vint(x);
    case string(str s): return vstr(s);
    
    case or(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b || eval(rhs, venv).b);
    case and(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case equal(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) == eval(rhs, venv));
    
    case geq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    case greater(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    case less(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    
    case subtract(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    case add(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case divide(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case multiply(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    
    
    case not(AExpr lhs): return vbool(!eval(lhs, venv).b);
    case brackets(AExpr lhs): return eval(lhs, venv);
    
    
    default: throw "Unsupported expression <e>";
  }
}