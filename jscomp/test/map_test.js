// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Pervasives = require("../stdlib/pervasives");
var Caml_exceptions = require("../runtime/caml_exceptions");
var Test_inline_map2 = require("./test_inline_map2");
var Mt = require("./mt");
var Test_map_find = require("./test_map_find");
var Caml_primitive = require("../runtime/caml_primitive");
var $$String = require("../stdlib/string");
var List = require("../stdlib/list");
var Test_inline_map = require("./test_inline_map");

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

function cardinal(param) {
  return param ? cardinal(param[1]) + 1 + cardinal(param[4]) : 0;
}

function height$1(param) {
  return param ? param[5] : 0;
}

function create$1(l, x, d, r) {
  var hl = height$1(l);
  var hr = height$1(r);
  return [
          /* Node */0,
          l,
          x,
          d,
          r,
          hl >= hr ? hl + 1 : hr + 1
        ];
}

function bal$1(l, x, d, r) {
  var hl = l ? l[5] : 0;
  var hr = r ? r[5] : 0;
  if (hl > hr + 2) {
    if (l) {
      var lr = l[4];
      var ld = l[3];
      var lv = l[2];
      var ll = l[1];
      return height$1(ll) >= height$1(lr) ? create$1(ll, lv, ld, create$1(lr, x, d, r)) : (
                lr ? create$1(create$1(ll, lv, ld, lr[1]), lr[2], lr[3], create$1(lr[4], x, d, r)) : Pervasives.invalid_arg("Map.bal")
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
        return height$1(rr) >= height$1(rl) ? create$1(create$1(l, x, d, rl), rv, rd, rr) : (
                  rl ? create$1(create$1(l, x, d, rl[1]), rl[2], rl[3], create$1(rl[4], rv, rd, rr)) : Pervasives.invalid_arg("Map.bal")
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

function add$1(x, data, param) {
  if (param) {
    var r = param[4];
    var d = param[3];
    var v = param[2];
    var l = param[1];
    var c = $$String.compare(x, v);
    return c ? (
              c < 0 ? bal$1(add$1(x, data, l), v, d, r) : bal$1(l, v, d, add$1(x, data, r))
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
      var c = $$String.compare(x, param[2]);
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

function of_list(kvs) {
  return List.fold_left(function (acc, param) {
              return add(param[1], param[2], acc);
            }, /* Empty */0, kvs);
}

var int_map_suites_001 = [
  /* tuple */0,
  "add",
  function () {
    var v = of_list([
          /* :: */0,
          [
            /* tuple */0,
            1,
            /* "1" */49
          ],
          [
            /* :: */0,
            [
              /* tuple */0,
              2,
              /* "3" */51
            ],
            [
              /* :: */0,
              [
                /* tuple */0,
                3,
                /* "4" */52
              ],
              /* [] */0
            ]
          ]
        ]);
    if (cardinal(v) === 3) {
      return 0;
    }
    else {
      throw [
            0,
            Caml_exceptions.Assert_failure,
            [
              0,
              "map_test.ml",
              16,
              4
            ]
          ];
    }
  }
];

var int_map_suites_002 = [
  /* :: */0,
  [
    /* tuple */0,
    "equal",
    function () {
      var v = of_list([
            /* :: */0,
            [
              /* tuple */0,
              1,
              /* "1" */49
            ],
            [
              /* :: */0,
              [
                /* tuple */0,
                2,
                /* "3" */51
              ],
              [
                /* :: */0,
                [
                  /* tuple */0,
                  3,
                  /* "4" */52
                ],
                /* [] */0
              ]
            ]
          ]);
      var u = of_list([
            /* :: */0,
            [
              /* tuple */0,
              2,
              /* "3" */51
            ],
            [
              /* :: */0,
              [
                /* tuple */0,
                3,
                /* "4" */52
              ],
              [
                /* :: */0,
                [
                  /* tuple */0,
                  1,
                  /* "1" */49
                ],
                /* [] */0
              ]
            ]
          ]);
      if (compare$1(function (prim, prim$1) {
              return Caml_primitive.caml_compare(prim, prim$1);
            }, u, v)) {
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "map_test.ml",
                21,
                4
              ]
            ];
      }
      else {
        return 0;
      }
    }
  ],
  [
    /* :: */0,
    [
      /* tuple */0,
      "test_inline_map",
      Test_inline_map.assertions
    ],
    [
      /* :: */0,
      [
        /* tuple */0,
        "test_inline_map2",
        Test_inline_map2.assertions1
      ],
      [
        /* :: */0,
        [
          /* tuple */0,
          "test_inline_map2_1",
          Test_inline_map2.assertions2
        ],
        [
          /* :: */0,
          [
            /* tuple */0,
            "test_map_find",
            Test_map_find.assert_test
          ],
          [
            /* :: */0,
            [
              /* tuple */0,
              "iteration",
              function () {
                var m = /* Empty */0;
                var count = 10000;
                for(var i = 0; i<= count; ++i){
                  m = add$1(Pervasives.string_of_int(i), Pervasives.string_of_int(i), m);
                }
                for(var i$1 = 0; i$1<= count; ++i$1){
                  Mt.assert_equal(find(Pervasives.string_of_int(i$1), m), Pervasives.string_of_int(i$1));
                }
                return /* () */0;
              }
            ],
            /* [] */0
          ]
        ]
      ]
    ]
  ]
];

var int_map_suites = [
  /* :: */0,
  int_map_suites_001,
  int_map_suites_002
];

Mt.from_suites("map_test", int_map_suites);

/*  fail the pure module */
