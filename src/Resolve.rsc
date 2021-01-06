module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  Use us = {};
  
  visit(f){
  	case ref(AId id) : us += {<id.src, id.name>};
  } 
  
  return us;
}

Def defs(AForm f) {
	Def ds = {};
	
	visit(f){
		case q:question(str qText, AId qId, AType qType): ds += {<qId.name, q.src>};
		case cq:computedQuestion(AQuestion q, AExpr qExpr) : ds += {<q.qId.name, cq.src>};
	}


	return ds;
}