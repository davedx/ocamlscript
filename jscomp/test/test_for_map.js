// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Pervasives = require("../stdlib/pervasives");
var Caml_exceptions = require("../runtime/caml_exceptions");
var Caml_primitive = require("../runtime/caml_primitive");

function compare(x, y) {
  return Caml_primitive.caml_int_compare(x, y);
}

function height(param) {
  return param ? param[5] : 0;
}

function create(l, x, d, r) {
  var hl = height(l);
  var hr = height(r);
  return [
          /* Node */0,
          l,
          x,
          d,
          r,
          hl >= hr ? hl + 1 : hr + 1
        ];
}

function singleton(x, d) {
  return [
          /* Node */0,
          /* Empty */0,
          x,
          d,
          /* Empty */0,
          1
        ];
}

function bal(l, x, d, r) {
  var hl = l ? l[5] : 0;
  var hr = r ? r[5] : 0;
  if (hl > hr + 2) {
    if (l) {
      var lr = l[4];
      var ld = l[3];
      var lv = l[2];
      var ll = l[1];
      return height(ll) >= height(lr) ? create(ll, lv, ld, create(lr, x, d, r)) : (
                lr ? create(create(ll, lv, ld, lr[1]), lr[2], lr[3], create(lr[4], x, d, r)) : Pervasives.invalid_arg("Map.bal")
              );
    }
    else {
      return Pervasives.invalid_arg("Map.bal");
    }
  }
  else {
    if (hr > hl + 2) {
      if (r) {
        var rr = r[4];
        var rd = r[3];
        var rv = r[2];
        var rl = r[1];
        return height(rr) >= height(rl) ? create(create(l, x, d, rl), rv, rd, rr) : (
                  rl ? create(create(l, x, d, rl[1]), rl[2], rl[3], create(rl[4], rv, rd, rr)) : Pervasives.invalid_arg("Map.bal")
                );
      }
      else {
        return Pervasives.invalid_arg("Map.bal");
      }
    }
    else {
      return [
              /* Node */0,
              l,
              x,
              d,
              r,
              hl >= hr ? hl + 1 : hr + 1
            ];
    }
  }
}

function is_empty(param) {
  return param ? /* false */0 : /* true */1;
}

function add(x, data, param) {
  if (param) {
    var r = param[4];
    var d = param[3];
    var v = param[2];
    var l = param[1];
    var c = compare(x, v);
    return c ? (
              c < 0 ? bal(add(x, data, l), v, d, r) : bal(l, v, d, add(x, data, r))
            ) : [
              /* Node */0,
              l,
              x,
              data,
              r,
              param[5]
            ];
  }
  else {
    return [
            /* Node */0,
            /* Empty */0,
            x,
            data,
            /* Empty */0,
            1
          ];
  }
}

function find(x, _param) {
  while(/* true */1) {
    var param = _param;
    if (param) {
      var c = compare(x, param[2]);
      if (c) {
        _param = c < 0 ? param[1] : param[4];
      }
      else {
        return param[3];
      }
    }
    else {
      throw Caml_exceptions.Not_found;
    }
  };
}

function mem(x, param) {
  if (param) {
    var c = compare(x, param[2]);
    return +(c === 0 || mem(x, c < 0 ? param[1] : param[4]));
  }
  else {
    return /* false */0;
  }
}

function min_binding(_param) {
  while(/* true */1) {
    var param = _param;
    if (param) {
      var l = param[1];
      if (l) {
        _param = l;
      }
      else {
        return [
                /* tuple */0,
                param[2],
                param[3]
              ];
      }
    }
    else {
      throw Caml_exceptions.Not_found;
    }
  };
}

function max_binding(_param) {
  while(/* true */1) {
    var param = _param;
    if (param) {
      var r = param[4];
      if (r) {
        _param = r;
      }
      else {
        return [
                /* tuple */0,
                param[2],
                param[3]
              ];
      }
    }
    else {
      throw Caml_exceptions.Not_found;
    }
  };
}

function remove_min_binding(param) {
  if (param) {
    var l = param[1];
    return l ? bal(remove_min_binding(l), param[2], param[3], param[4]) : param[4];
  }
  else {
    return Pervasives.invalid_arg("Map.remove_min_elt");
  }
}

function merge(t1, t2) {
  if (t1) {
    if (t2) {
      var match = min_binding(t2);
      return bal(t1, match[1], match[2], remove_min_binding(t2));
    }
    else {
      return t1;
    }
  }
  else {
    return t2;
  }
}

function remove(x, param) {
  if (param) {
    var r = param[4];
    var d = param[3];
    var v = param[2];
    var l = param[1];
    var c = compare(x, v);
    return c ? (
              c < 0 ? bal(remove(x, l), v, d, r) : bal(l, v, d, remove(x, r))
            ) : merge(l, r);
  }
  else {
    return /* Empty */0;
  }
}

function iter(f, _param) {
  while(/* true */1) {
    var param = _param;
    if (param) {
      iter(f, param[1]);
      f(param[2], param[3]);
      _param = param[4];
    }
    else {
      return /* () */0;
    }
  };
}

function map(f, param) {
  if (param) {
    var l$prime = map(f, param[1]);
    var d$prime = f(param[3]);
    var r$prime = map(f, param[4]);
    return [
            /* Node */0,
            l$prime,
            param[2],
            d$prime,
            r$prime,
            param[5]
          ];
  }
  else {
    return /* Empty */0;
  }
}

function mapi(f, param) {
  if (param) {
    var v = param[2];
    var l$prime = mapi(f, param[1]);
    var d$prime = f(v, param[3]);
    var r$prime = mapi(f, param[4]);
    return [
            /* Node */0,
            l$prime,
            v,
            d$prime,
            r$prime,
            param[5]
          ];
  }
  else {
    return /* Empty */0;
  }
}

function fold(f, _m, _accu) {
  while(/* true */1) {
    var accu = _accu;
    var m = _m;
    if (m) {
      _accu = f(m[2], m[3], fold(f, m[1], accu));
      _m = m[4];
    }
    else {
      return accu;
    }
  };
}

function for_all(p, param) {
  return param ? +(p(param[2], param[3]) && for_all(p, param[1]) && for_all(p, param[4])) : /* true */1;
}

function exists(p, param) {
  return param ? +(p(param[2], param[3]) || exists(p, param[1]) || exists(p, param[4])) : /* false */0;
}

function add_min_binding(k, v, param) {
  return param ? bal(add_min_binding(k, v, param[1]), param[2], param[3], param[4]) : singleton(k, v);
}

function add_max_binding(k, v, param) {
  return param ? bal(param[1], param[2], param[3], add_max_binding(k, v, param[4])) : singleton(k, v);
}

function join(l, v, d, r) {
  if (l) {
    if (r) {
      var rh = r[5];
      var lh = l[5];
      return lh > rh + 2 ? bal(l[1], l[2], l[3], join(l[4], v, d, r)) : (
                rh > lh + 2 ? bal(join(l, v, d, r[1]), r[2], r[3], r[4]) : create(l, v, d, r)
              );
    }
    else {
      return add_max_binding(v, d, l);
    }
  }
  else {
    return add_min_binding(v, d, r);
  }
}

function concat(t1, t2) {
  if (t1) {
    if (t2) {
      var match = min_binding(t2);
      return join(t1, match[1], match[2], remove_min_binding(t2));
    }
    else {
      return t1;
    }
  }
  else {
    return t2;
  }
}

function concat_or_join(t1, v, d, t2) {
  return d ? join(t1, v, d[1], t2) : concat(t1, t2);
}

function split(x, param) {
  if (param) {
    var r = param[4];
    var d = param[3];
    var v = param[2];
    var l = param[1];
    var c = compare(x, v);
    if (c) {
      if (c < 0) {
        var match = split(x, l);
        return [
                /* tuple */0,
                match[1],
                match[2],
                join(match[3], v, d, r)
              ];
      }
      else {
        var match$1 = split(x, r);
        return [
                /* tuple */0,
                join(l, v, d, match$1[1]),
                match$1[2],
                match$1[3]
              ];
      }
    }
    else {
      return [
              /* tuple */0,
              l,
              [
                /* Some */0,
                d
              ],
              r
            ];
    }
  }
  else {
    return [
            /* tuple */0,
            /* Empty */0,
            /* None */0,
            /* Empty */0
          ];
  }
}

function merge$1(f, s1, s2) {
  /* initialize */var exit = 0;
  if (s1) {
    var v1 = s1[2];
    if (s1[5] >= height(s2)) {
      var match = split(v1, s2);
      return concat_or_join(merge$1(f, s1[1], match[1]), v1, f(v1, [
                      /* Some */0,
                      s1[3]
                    ], match[2]), merge$1(f, s1[4], match[3]));
    }
    else {
      exit = 20;
    }
  }
  else {
    if (s2) {
      exit = 20;
    }
    else {
      return /* Empty */0;
    }
  }
  if (exit === 20) {
    if (s2) {
      var v2 = s2[2];
      var match$1 = split(v2, s1);
      return concat_or_join(merge$1(f, match$1[1], s2[1]), v2, f(v2, match$1[2], [
                      /* Some */0,
                      s2[3]
                    ]), merge$1(f, match$1[3], s2[4]));
    }
    else {
      throw [
            0,
            Caml_exceptions.Assert_failure,
            [
              0,
              "map.ml",
              270,
              10
            ]
          ];
    }
  }
  
}

function filter(p, param) {
  if (param) {
    var d = param[3];
    var v = param[2];
    var l$prime = filter(p, param[1]);
    var pvd = p(v, d);
    var r$prime = filter(p, param[4]);
    return pvd ? join(l$prime, v, d, r$prime) : concat(l$prime, r$prime);
  }
  else {
    return /* Empty */0;
  }
}

function partition(p, param) {
  if (param) {
    var d = param[3];
    var v = param[2];
    var match = partition(p, param[1]);
    var lf = match[2];
    var lt = match[1];
    var pvd = p(v, d);
    var match$1 = partition(p, param[4]);
    var rf = match$1[2];
    var rt = match$1[1];
    return pvd ? [
              /* tuple */0,
              join(lt, v, d, rt),
              concat(lf, rf)
            ] : [
              /* tuple */0,
              concat(lt, rt),
              join(lf, v, d, rf)
            ];
  }
  else {
    return [
            /* tuple */0,
            /* Empty */0,
            /* Empty */0
          ];
  }
}

function cons_enum(_m, _e) {
  while(/* true */1) {
    var e = _e;
    var m = _m;
    if (m) {
      _e = [
        /* More */0,
        m[2],
        m[3],
        m[4],
        e
      ];
      _m = m[1];
    }
    else {
      return e;
    }
  };
}

function compare$1(cmp, m1, m2) {
  var compare_aux = function (_e1, _e2) {
    while(/* true */1) {
      var e2 = _e2;
      var e1 = _e1;
      if (e1) {
        if (e2) {
          var c = compare(e1[1], e2[1]);
          if (c !== 0) {
            return c;
          }
          else {
            var c$1 = cmp(e1[2], e2[2]);
            if (c$1 !== 0) {
              return c$1;
            }
            else {
              _e2 = cons_enum(e2[3], e2[4]);
              _e1 = cons_enum(e1[3], e1[4]);
            }
          }
        }
        else {
          return 1;
        }
      }
      else {
        return e2 ? -1 : 0;
      }
    };
  };
  return compare_aux(cons_enum(m1, /* End */0), cons_enum(m2, /* End */0));
}

function equal(cmp, m1, m2) {
  var equal_aux = function (e1, e2) {
    return e1 ? (
              e2 ? +(compare(e1[1], e2[1]) === 0 && cmp(e1[2], e2[2]) && equal_aux(cons_enum(e1[3], e1[4]), cons_enum(e2[3], e2[4]))) : /* false */0
            ) : (
              e2 ? /* false */0 : /* true */1
            );
  };
  return equal_aux(cons_enum(m1, /* End */0), cons_enum(m2, /* End */0));
}

function cardinal(param) {
  return param ? cardinal(param[1]) + 1 + cardinal(param[4]) : 0;
}

function bindings_aux(_accu, _param) {
  while(/* true */1) {
    var param = _param;
    var accu = _accu;
    if (param) {
      _param = param[1];
      _accu = [
        /* :: */0,
        [
          /* tuple */0,
          param[2],
          param[3]
        ],
        bindings_aux(accu, param[4])
      ];
    }
    else {
      return accu;
    }
  };
}

function bindings(s) {
  return bindings_aux(/* [] */0, s);
}

var IntMap = [
  0,
  /* Empty */0,
  is_empty,
  mem,
  add,
  singleton,
  remove,
  merge$1,
  compare$1,
  equal,
  iter,
  fold,
  for_all,
  exists,
  filter,
  partition,
  cardinal,
  bindings,
  min_binding,
  max_binding,
  min_binding,
  split,
  find,
  map,
  mapi
];

function assertion_test() {
  var m = /* Empty */0;
  var count = 1000000;
  for(var i = 0; i<= count; ++i){
    m = add(i, i, m);
  }
  for(var i$1 = 0; i$1<= count; ++i$1){
    find(i$1, m);
  }
  return /* () */0;
}

exports.IntMap = IntMap;
exports.assertion_test = assertion_test;
/* No side effect */
