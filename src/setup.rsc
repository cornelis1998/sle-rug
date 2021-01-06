module setup

import Syntax;
import AST;
import CST2AST;
import Resolve;
import Check;
import Compile;
import ParseTree;

import util::IDE;
import Message;
import ParseTree;


private str MyQL ="MyQL";

anno rel[loc, loc] Tree@hyperlinks;

void imports(){
	import ParseTree;
}

void setup() {
  a = parse(#Form, |project://QL/examples/errors.myql|);
  b = cst2ast(a);
  c = resolve(b);
  d = collect(b);
  check(b,d,c.useDef);
  
}