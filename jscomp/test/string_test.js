// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Bytes = require("../stdlib/bytes");
var Mt = require("./mt");
var $$String = require("../stdlib/string");

function ff(x) {
  var a;
  switch (x) {
    case "0" : 
    case "1" : 
    case "2" : 
        a = 3;
        break;
    case "3" : 
        a = 4;
        break;
    case "4" : 
        a = 6;
        break;
    case "7" : 
        a = 7;
        break;
    default:
      a = 8;
  }
  return a + 3;
}

function gg(x) {
  var a;
  if (8 < (x >>> 0)) {
    a = 8;
  }
  else {
    switch (x) {
      case 0 : 
      case 1 : 
      case 2 : 
          a = 3;
          break;
      case 3 : 
          a = 4;
          break;
      case 4 : 
          a = 6;
          break;
      case 5 : 
      case 6 : 
      case 7 : 
          a = 8;
          break;
      case 8 : 
          a = 7;
          break;
      
    }
  }
  return a + 3;
}

Mt.from_pair_suites("string_test.ml", [
      /* :: */0,
      [
        /* tuple */0,
        "mutliple switch",
        function () {
          return [
                  /* Eq */0,
                  9,
                  ff("4")
                ];
        }
      ],
      [
        /* :: */0,
        [
          /* tuple */0,
          "int switch",
          function () {
            return [
                    /* Eq */0,
                    9,
                    gg(4)
                  ];
          }
        ],
        [
          /* :: */0,
          [
            /* tuple */0,
            "escape_normal",
            function () {
              return [
                      /* Eq */0,
                      "haha",
                      $$String.escaped("haha")
                    ];
            }
          ],
          [
            /* :: */0,
            [
              /* tuple */0,
              "escape_bytes",
              function () {
                return [
                        /* Eq */0,
                        Bytes.of_string("haha"),
                        Bytes.escaped(Bytes.of_string("haha"))
                      ];
              }
            ],
            [
              /* :: */0,
              [
                /* tuple */0,
                "escape_quote",
                function () {
                  return [
                          /* Eq */0,
                          '\\"\\"',
                          $$String.escaped('""')
                        ];
                }
              ],
              /* [] */0
            ]
          ]
        ]
      ]
    ]);

exports.ff = ff;
exports.gg = gg;
/*  fail the pure module */
