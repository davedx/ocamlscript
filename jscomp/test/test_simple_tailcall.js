// Generated CODE, PLEASE EDIT WITH CARE
"use strict";

function tailcall() {
  while(/* true */1) {
    
  };
}

function non_length(x) {
  return x ? 1 + non_length(x[2]) : 0;
}

function length(_acc, _x) {
  while(/* true */1) {
    var x = _x;
    var acc = _acc;
    if (x) {
      var tl = x[2];
      if (tl) {
        return 1 + length(acc + 1, tl[2]);
      }
      else {
        _x = tl;
        _acc = acc + 1;
      }
    }
    else {
      return acc;
    }
  };
}

exports.tailcall = tailcall;
exports.non_length = non_length;
exports.length = length;
/* No side effect */
