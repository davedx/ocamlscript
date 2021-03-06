// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Caml_format = require("../runtime/caml_format");
var Caml_primitive = require("../runtime/caml_primitive");

function succ(n) {
  return n + 1;
}

function pred(n) {
  return n - 1;
}

function abs(n) {
  return n >= 0 ? n : -n;
}

function lognot(n) {
  return n ^ -1;
}

function to_string(n) {
  return Caml_format.caml_int32_format("%d", n);
}

function compare(x, y) {
  return Caml_primitive.caml_int32_compare(x, y);
}

var zero = 0;

var one = 1;

var minus_one = -1;

var max_int = 2147483647;

var min_int = -2147483648;

exports.zero = zero;
exports.one = one;
exports.minus_one = minus_one;
exports.succ = succ;
exports.pred = pred;
exports.abs = abs;
exports.max_int = max_int;
exports.min_int = min_int;
exports.lognot = lognot;
exports.to_string = to_string;
exports.compare = compare;
/* No side effect */
