// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Bytes = require("../stdlib/bytes");
var Caml_string = require("../runtime/caml_string");

function escaped(s) {
  var n = 0;
  for(var i = 0 ,i_finish = s.length - 1; i<= i_finish; ++i){
    var c = s[i];
    var $js;
    /* initialize */var exit = 0;
    c >= 14 ? (
        c !== 34 ? (
            c !== 92 ? (exit = 6) : ($js = 2)
          ) : ($js = 2)
      ) : (
        c >= 11 ? (
            c >= 13 ? ($js = 2) : (exit = 6)
          ) : (
            c >= 8 ? ($js = 2) : (exit = 6)
          )
      );
    if (exit === 6) {
      $js = Caml_string.caml_is_printable(c) ? 1 : 4;
    }
    n += $js;
  }
  if (n === s.length) {
    return Bytes.copy(s);
  }
  else {
    var s$prime = Caml_string.caml_create_string(n);
    n = 0;
    for(var i$1 = 0 ,i_finish$1 = s.length - 1; i$1<= i_finish$1; ++i$1){
      var c$1 = s[i$1];
      /* initialize */var exit$1 = 0;
      var switcher = -34 + c$1;
      if (!(58 < (switcher >>> 0))) {
        if (56 < (-1 + switcher >>> 0)) {
          s$prime[n] = /* "\\" */92;
          ++ n;
          s$prime[n] = c$1;
        }
        else {
          exit$1 = 3;
        }
      }
      else {
        if (switcher >= -20) {
          exit$1 = 3;
        }
        else {
          switch (34 + switcher) {
            case 8 : 
                s$prime[n] = /* "\\" */92;
                ++ n;
                s$prime[n] = /* "b" */98;
                break;
            case 9 : 
                s$prime[n] = /* "\\" */92;
                ++ n;
                s$prime[n] = /* "t" */116;
                break;
            case 10 : 
                s$prime[n] = /* "\\" */92;
                ++ n;
                s$prime[n] = /* "n" */110;
                break;
            case 0 : 
            case 1 : 
            case 2 : 
            case 3 : 
            case 4 : 
            case 5 : 
            case 6 : 
            case 7 : 
            case 11 : 
            case 12 : 
                exit$1 = 3;
                break;
            case 13 : 
                s$prime[n] = /* "\\" */92;
                ++ n;
                s$prime[n] = /* "r" */114;
                break;
            
          }
        }
      }
      if (exit$1 === 3) {
        if (Caml_string.caml_is_printable(c$1)) {
          s$prime[n] = c$1;
        }
        else {
          s$prime[n] = /* "\\" */92;
          ++ n;
          s$prime[n] = 48 + (c$1 / 100 | 0);
          ++ n;
          s$prime[n] = 48 + (c$1 / 10 | 0) % 10;
          ++ n;
          s$prime[n] = 48 + c$1 % 10;
        }
      }
      ++ n;
    }
    return s$prime;
  }
}

exports.escaped = escaped;
/* No side effect */
