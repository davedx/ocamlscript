// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Bytes = require("./bytes");
var Hashtbl = require("./hashtbl");
var Caml_exceptions = require("../runtime/caml_exceptions");
var Stream = require("./stream");
var Caml_format = require("../runtime/caml_format");
var Char = require("./char");
var $$String = require("./string");
var Caml_string = require("../runtime/caml_string");
var List = require("./list");

var initial_buffer = new Array(32);

var buffer = [
  0,
  initial_buffer
];

var bufpos = [
  0,
  0
];

function reset_buffer() {
  buffer[1] = initial_buffer;
  bufpos[1] = 0;
  return /* () */0;
}

function store(c) {
  if (bufpos[1] >= buffer[1].length) {
    var newbuffer = Caml_string.caml_create_string(2 * bufpos[1]);
    Bytes.blit(buffer[1], 0, newbuffer, 0, bufpos[1]);
    buffer[1] = newbuffer;
  }
  buffer[1][bufpos[1]] = c;
  return ++ bufpos[1];
}

function get_string() {
  var s = Bytes.sub_string(buffer[1], 0, bufpos[1]);
  buffer[1] = initial_buffer;
  return s;
}

function make_lexer(keywords) {
  var kwd_table = Hashtbl.create(/* None */0, 17);
  List.iter(function (s) {
        return Hashtbl.add(kwd_table, s, [
                    /* Kwd */0,
                    s
                  ]);
      }, keywords);
  var ident_or_keyword = function (id) {
    try {
      return Hashtbl.find(kwd_table, id);
    }
    catch (exn){
      if (exn === Caml_exceptions.Not_found) {
        return [
                /* Ident */1,
                id
              ];
      }
      else {
        throw exn;
      }
    }
  };
  var keyword_or_error = function (c) {
    var s = $$String.make(1, c);
    try {
      return Hashtbl.find(kwd_table, s);
    }
    catch (exn){
      if (exn === Caml_exceptions.Not_found) {
        throw [
              0,
              Stream.$$Error,
              "Illegal character " + s
            ];
      }
      else {
        throw exn;
      }
    }
  };
  var next_token = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      if (match) {
        var c = match[1];
        /* initialize */var exit = 0;
        if (c < 124) {
          var switcher = -65 + c;
          if (!(57 < (switcher >>> 0))) {
            var switcher$1 = -26 + switcher;
            if (5 < (switcher$1 >>> 0)) {
              exit = 10;
            }
            else {
              switch (switcher$1) {
                case 1 : 
                case 3 : 
                    exit = 11;
                    break;
                case 4 : 
                    exit = 10;
                    break;
                case 0 : 
                case 2 : 
                case 5 : 
                    exit = 13;
                    break;
                
              }
            }
          }
          else {
            if (switcher >= 58) {
              exit = 13;
            }
            else {
              switch (65 + switcher) {
                case 9 : 
                case 10 : 
                case 12 : 
                case 13 : 
                case 26 : 
                case 32 : 
                    exit = 9;
                    break;
                case 34 : 
                    Stream.junk(strm__);
                    reset_buffer(/* () */0);
                    return [
                            /* Some */0,
                            [
                              /* String */4,
                              string(strm__)
                            ]
                          ];
                case 39 : 
                    Stream.junk(strm__);
                    var c$1;
                    try {
                      c$1 = $$char(strm__);
                    }
                    catch (exn){
                      if (exn === Stream.Failure) {
                        throw [
                              0,
                              Stream.$$Error,
                              ""
                            ];
                      }
                      else {
                        throw exn;
                      }
                    }
                    var match$1 = Stream.peek(strm__);
                    /* initialize */var exit$1 = 0;
                    if (match$1) {
                      if (match$1[1] !== 39) {
                        exit$1 = 4;
                      }
                      else {
                        Stream.junk(strm__);
                        return [
                                /* Some */0,
                                [
                                  /* Char */5,
                                  c$1
                                ]
                              ];
                      }
                    }
                    else {
                      exit$1 = 4;
                    }
                    if (exit$1 === 4) {
                      throw [
                            0,
                            Stream.$$Error,
                            ""
                          ];
                    }
                    break;
                case 40 : 
                    Stream.junk(strm__);
                    return maybe_comment(strm__);
                case 45 : 
                    Stream.junk(strm__);
                    return neg_number(strm__);
                case 48 : 
                case 49 : 
                case 50 : 
                case 51 : 
                case 52 : 
                case 53 : 
                case 54 : 
                case 55 : 
                case 56 : 
                case 57 : 
                    exit = 12;
                    break;
                case 0 : 
                case 1 : 
                case 2 : 
                case 3 : 
                case 4 : 
                case 5 : 
                case 6 : 
                case 7 : 
                case 8 : 
                case 11 : 
                case 14 : 
                case 15 : 
                case 16 : 
                case 17 : 
                case 18 : 
                case 19 : 
                case 20 : 
                case 21 : 
                case 22 : 
                case 23 : 
                case 24 : 
                case 25 : 
                case 27 : 
                case 28 : 
                case 29 : 
                case 30 : 
                case 31 : 
                case 41 : 
                case 44 : 
                case 46 : 
                case 59 : 
                    exit = 13;
                    break;
                case 33 : 
                case 35 : 
                case 36 : 
                case 37 : 
                case 38 : 
                case 42 : 
                case 43 : 
                case 47 : 
                case 58 : 
                case 60 : 
                case 61 : 
                case 62 : 
                case 63 : 
                case 64 : 
                    exit = 11;
                    break;
                
              }
            }
          }
        }
        else {
          exit = c >= 127 ? (
              c >= 192 ? 10 : 13
            ) : (
              c !== 125 ? 11 : 13
            );
        }
        switch (exit) {
          case 13 : 
              Stream.junk(strm__);
              return [
                      /* Some */0,
                      keyword_or_error(c)
                    ];
          case 9 : 
              Stream.junk(strm__);
              break;
          case 10 : 
              Stream.junk(strm__);
              reset_buffer(/* () */0);
              store(c);
              return ident(strm__);
          case 11 : 
              Stream.junk(strm__);
              reset_buffer(/* () */0);
              store(c);
              return ident2(strm__);
          case 12 : 
              Stream.junk(strm__);
              reset_buffer(/* () */0);
              store(c);
              return number(strm__);
          
        }
      }
      else {
        return /* None */0;
      }
    };
  };
  var ident = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      /* initialize */var exit = 0;
      if (match) {
        var c = match[1];
        /* initialize */var exit$1 = 0;
        if (c >= 91) {
          var switcher = -95 + c;
          27 < (switcher >>> 0) ? (
              switcher >= 97 ? (exit$1 = 16) : (exit = 15)
            ) : (
              switcher !== 1 ? (exit$1 = 16) : (exit = 15)
            );
        }
        else {
          c >= 48 ? (
              6 < (-58 + c >>> 0) ? (exit$1 = 16) : (exit = 15)
            ) : (
              c !== 39 ? (exit = 15) : (exit$1 = 16)
            );
        }
        if (exit$1 === 16) {
          Stream.junk(strm__);
          store(c);
        }
        
      }
      else {
        exit = 15;
      }
      if (exit === 15) {
        return [
                /* Some */0,
                ident_or_keyword(get_string(/* () */0))
              ];
      }
      
    };
  };
  var ident2 = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      /* initialize */var exit = 0;
      if (match) {
        var c = match[1];
        /* initialize */var exit$1 = 0;
        if (c >= 94) {
          var switcher = -95 + c;
          30 < (switcher >>> 0) ? (
              switcher >= 32 ? (exit = 18) : (exit$1 = 19)
            ) : (
              switcher !== 29 ? (exit = 18) : (exit$1 = 19)
            );
        }
        else {
          if (c >= 65) {
            c !== 92 ? (exit = 18) : (exit$1 = 19);
          }
          else {
            if (c >= 33) {
              switch (-33 + c) {
                case 1 : 
                case 6 : 
                case 7 : 
                case 8 : 
                case 11 : 
                case 13 : 
                case 15 : 
                case 16 : 
                case 17 : 
                case 18 : 
                case 19 : 
                case 20 : 
                case 21 : 
                case 22 : 
                case 23 : 
                case 24 : 
                case 26 : 
                    exit = 18;
                    break;
                case 0 : 
                case 2 : 
                case 3 : 
                case 4 : 
                case 5 : 
                case 9 : 
                case 10 : 
                case 12 : 
                case 14 : 
                case 25 : 
                case 27 : 
                case 28 : 
                case 29 : 
                case 30 : 
                case 31 : 
                    exit$1 = 19;
                    break;
                
              }
            }
            else {
              exit = 18;
            }
          }
        }
        if (exit$1 === 19) {
          Stream.junk(strm__);
          store(c);
        }
        
      }
      else {
        exit = 18;
      }
      if (exit === 18) {
        return [
                /* Some */0,
                ident_or_keyword(get_string(/* () */0))
              ];
      }
      
    };
  };
  var neg_number = function (strm__) {
    var match = Stream.peek(strm__);
    /* initialize */var exit = 0;
    if (match) {
      var c = match[1];
      if (9 < (-48 + c >>> 0)) {
        exit = 22;
      }
      else {
        Stream.junk(strm__);
        reset_buffer(/* () */0);
        store(/* "-" */45);
        store(c);
        return number(strm__);
      }
    }
    else {
      exit = 22;
    }
    if (exit === 22) {
      reset_buffer(/* () */0);
      store(/* "-" */45);
      return ident2(strm__);
    }
    
  };
  var number = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      /* initialize */var exit = 0;
      if (match) {
        var c = match[1];
        /* initialize */var exit$1 = 0;
        if (c >= 58) {
          c !== 69 ? (
              c !== 101 ? (exit = 27) : (exit$1 = 29)
            ) : (exit$1 = 29);
        }
        else {
          if (c !== 46) {
            if (c >= 48) {
              Stream.junk(strm__);
              store(c);
            }
            else {
              exit = 27;
            }
          }
          else {
            Stream.junk(strm__);
            store(/* "." */46);
            return decimal_part(strm__);
          }
        }
        if (exit$1 === 29) {
          Stream.junk(strm__);
          store(/* "E" */69);
          return exponent_part(strm__);
        }
        
      }
      else {
        exit = 27;
      }
      if (exit === 27) {
        return [
                /* Some */0,
                [
                  /* Int */2,
                  Caml_format.caml_int_of_string(get_string(/* () */0))
                ]
              ];
      }
      
    };
  };
  var decimal_part = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      /* initialize */var exit = 0;
      if (match) {
        var c = match[1];
        var switcher = -69 + c;
        if (32 < (switcher >>> 0)) {
          if (9 < (21 + switcher >>> 0)) {
            exit = 32;
          }
          else {
            Stream.junk(strm__);
            store(c);
          }
        }
        else {
          if (30 < (-1 + switcher >>> 0)) {
            Stream.junk(strm__);
            store(/* "E" */69);
            return exponent_part(strm__);
          }
          else {
            exit = 32;
          }
        }
      }
      else {
        exit = 32;
      }
      if (exit === 32) {
        return [
                /* Some */0,
                [
                  /* Float */3,
                  Caml_format.caml_float_of_string(get_string(/* () */0))
                ]
              ];
      }
      
    };
  };
  var exponent_part = function (strm__) {
    var match = Stream.peek(strm__);
    if (match) {
      var c = match[1];
      /* initialize */var exit = 0;
      if (c !== 43) {
        if (c !== 45) {
          return end_exponent_part(strm__);
        }
        else {
          exit = 37;
        }
      }
      else {
        exit = 37;
      }
      if (exit === 37) {
        Stream.junk(strm__);
        store(c);
        return end_exponent_part(strm__);
      }
      
    }
    else {
      return end_exponent_part(strm__);
    }
  };
  var end_exponent_part = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      /* initialize */var exit = 0;
      if (match) {
        var c = match[1];
        if (9 < (-48 + c >>> 0)) {
          exit = 39;
        }
        else {
          Stream.junk(strm__);
          store(c);
        }
      }
      else {
        exit = 39;
      }
      if (exit === 39) {
        return [
                /* Some */0,
                [
                  /* Float */3,
                  Caml_format.caml_float_of_string(get_string(/* () */0))
                ]
              ];
      }
      
    };
  };
  var string = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      if (match) {
        var c = match[1];
        if (c !== 34) {
          if (c !== 92) {
            Stream.junk(strm__);
            store(c);
          }
          else {
            Stream.junk(strm__);
            var c$1;
            try {
              c$1 = $$escape(strm__);
            }
            catch (exn){
              if (exn === Stream.Failure) {
                throw [
                      0,
                      Stream.$$Error,
                      ""
                    ];
              }
              else {
                throw exn;
              }
            }
            store(c$1);
          }
        }
        else {
          Stream.junk(strm__);
          return get_string(/* () */0);
        }
      }
      else {
        throw Stream.Failure;
      }
    };
  };
  var $$char = function (strm__) {
    var match = Stream.peek(strm__);
    if (match) {
      var c = match[1];
      if (c !== 92) {
        Stream.junk(strm__);
        return c;
      }
      else {
        Stream.junk(strm__);
        try {
          return $$escape(strm__);
        }
        catch (exn){
          if (exn === Stream.Failure) {
            throw [
                  0,
                  Stream.$$Error,
                  ""
                ];
          }
          else {
            throw exn;
          }
        }
      }
    }
    else {
      throw Stream.Failure;
    }
  };
  var $$escape = function (strm__) {
    var match = Stream.peek(strm__);
    if (match) {
      var c1 = match[1];
      /* initialize */var exit = 0;
      if (c1 >= 58) {
        var switcher = -110 + c1;
        if (6 < (switcher >>> 0)) {
          exit = 56;
        }
        else {
          switch (switcher) {
            case 0 : 
                Stream.junk(strm__);
                return /* "\n" */10;
            case 4 : 
                Stream.junk(strm__);
                return /* "\r" */13;
            case 1 : 
            case 2 : 
            case 3 : 
            case 5 : 
                exit = 56;
                break;
            case 6 : 
                Stream.junk(strm__);
                return /* "\t" */9;
            
          }
        }
      }
      else {
        if (c1 >= 48) {
          Stream.junk(strm__);
          var match$1 = Stream.peek(strm__);
          /* initialize */var exit$1 = 0;
          if (match$1) {
            var c2 = match$1[1];
            if (9 < (-48 + c2 >>> 0)) {
              exit$1 = 52;
            }
            else {
              Stream.junk(strm__);
              var match$2 = Stream.peek(strm__);
              /* initialize */var exit$2 = 0;
              if (match$2) {
                var c3 = match$2[1];
                if (9 < (-48 + c3 >>> 0)) {
                  exit$2 = 50;
                }
                else {
                  Stream.junk(strm__);
                  return Char.chr((c1 - 48) * 100 + (c2 - 48) * 10 + (c3 - 48));
                }
              }
              else {
                exit$2 = 50;
              }
              if (exit$2 === 50) {
                throw [
                      0,
                      Stream.$$Error,
                      ""
                    ];
              }
              
            }
          }
          else {
            exit$1 = 52;
          }
          if (exit$1 === 52) {
            throw [
                  0,
                  Stream.$$Error,
                  ""
                ];
          }
          
        }
        else {
          exit = 56;
        }
      }
      if (exit === 56) {
        Stream.junk(strm__);
        return c1;
      }
      
    }
    else {
      throw Stream.Failure;
    }
  };
  var maybe_comment = function (strm__) {
    var match = Stream.peek(strm__);
    return match ? (
              match[1] !== 42 ? [
                  /* Some */0,
                  keyword_or_error(/* "(" */40)
                ] : (Stream.junk(strm__), comment(strm__), next_token(strm__))
            ) : [
              /* Some */0,
              keyword_or_error(/* "(" */40)
            ];
  };
  var comment = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      if (match) {
        /* initialize */var exit = 0;
        var switcher = -40 + match[1];
        if (2 < (switcher >>> 0)) {
          exit = 60;
        }
        else {
          switch (switcher) {
            case 0 : 
                Stream.junk(strm__);
                return maybe_nested_comment(strm__);
            case 1 : 
                exit = 60;
                break;
            case 2 : 
                Stream.junk(strm__);
                return maybe_end_comment(strm__);
            
          }
        }
        if (exit === 60) {
          Stream.junk(strm__);
        }
        
      }
      else {
        throw Stream.Failure;
      }
    };
  };
  var maybe_nested_comment = function (strm__) {
    var match = Stream.peek(strm__);
    if (match) {
      return match[1] !== 42 ? (Stream.junk(strm__), comment(strm__)) : (Stream.junk(strm__), comment(strm__), comment(strm__));
    }
    else {
      throw Stream.Failure;
    }
  };
  var maybe_end_comment = function (strm__) {
    while(/* true */1) {
      var match = Stream.peek(strm__);
      if (match) {
        var c = match[1];
        return c !== 41 ? (
                  c !== 42 ? (Stream.junk(strm__), comment(strm__)) : Stream.junk(strm__)
                ) : (Stream.junk(strm__), /* () */0);
      }
      else {
        throw Stream.Failure;
      }
    };
  };
  return function (input) {
    return Stream.from(function () {
                return next_token(input);
              });
  };
}

exports.make_lexer = make_lexer;
/* Hashtbl fail the pure module */
