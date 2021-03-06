// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Bytes = require("./bytes");
var Pervasives = require("./pervasives");
var Caml_exceptions = require("../runtime/caml_exceptions");
var Sys = require("./sys");
var $$String = require("./string");
var Caml_string = require("../runtime/caml_string");

function create(n) {
  var n$1 = n < 1 ? 1 : n;
  var n$2 = n$1 > Sys.max_string_length ? Sys.max_string_length : n$1;
  var s = Caml_string.caml_create_string(n$2);
  return [
          /* record */0,
          s,
          0,
          n$2,
          s
        ];
}

function contents(b) {
  return Bytes.sub_string(b[1], 0, b[2]);
}

function to_bytes(b) {
  return Bytes.sub(b[1], 0, b[2]);
}

function sub(b, ofs, len) {
  return ofs < 0 || len < 0 || ofs > b[2] - len ? Pervasives.invalid_arg("Buffer.sub") : Bytes.sub_string(b[1], ofs, len);
}

function blit(src, srcoff, dst, dstoff, len) {
  return len < 0 || srcoff < 0 || srcoff > src[2] - len || dstoff < 0 || dstoff > dst.length - len ? Pervasives.invalid_arg("Buffer.blit") : Bytes.blit(src[1], srcoff, dst, dstoff, len);
}

function nth(b, ofs) {
  return ofs < 0 || ofs >= b[2] ? Pervasives.invalid_arg("Buffer.nth") : b[1][ofs];
}

function length(b) {
  return b[2];
}

function clear(b) {
  b[2] = 0;
  return /* () */0;
}

function reset(b) {
  b[2] = 0;
  b[1] = b[4];
  b[3] = b[1].length;
  return /* () */0;
}

function resize(b, more) {
  var len = b[3];
  var new_len = len;
  while(b[2] + more > new_len) {
    new_len = 2 * new_len;
  };
  if (new_len > Sys.max_string_length) {
    b[2] + more <= Sys.max_string_length ? (new_len = Sys.max_string_length) : Pervasives.failwith("Buffer.add: cannot grow buffer");
  }
  var new_buffer = Caml_string.caml_create_string(new_len);
  Bytes.blit(b[1], 0, new_buffer, 0, b[2]);
  b[1] = new_buffer;
  b[3] = new_len;
  return /* () */0;
}

function add_char(b, c) {
  var pos = b[2];
  if (pos >= b[3]) {
    resize(b, 1);
  }
  b[1][pos] = c;
  b[2] = pos + 1;
  return /* () */0;
}

function add_substring(b, s, offset, len) {
  if (offset < 0 || len < 0 || offset + len > s.length) {
    Pervasives.invalid_arg("Buffer.add_substring/add_subbytes");
  }
  var new_position = b[2] + len;
  if (new_position > b[3]) {
    resize(b, len);
  }
  Bytes.blit_string(s, offset, b[1], b[2], len);
  b[2] = new_position;
  return /* () */0;
}

function add_subbytes(b, s, offset, len) {
  return add_substring(b, Bytes.unsafe_to_string(s), offset, len);
}

function add_string(b, s) {
  var len = s.length;
  var new_position = b[2] + len;
  if (new_position > b[3]) {
    resize(b, len);
  }
  Bytes.blit_string(s, 0, b[1], b[2], len);
  b[2] = new_position;
  return /* () */0;
}

function add_bytes(b, s) {
  return add_string(b, Bytes.unsafe_to_string(s));
}

function add_buffer(b, bs) {
  return add_subbytes(b, bs[1], 0, bs[2]);
}

function add_channel(b, ic, len) {
  if (len < 0 || len > Sys.max_string_length) {
    Pervasives.invalid_arg("Buffer.add_channel");
  }
  if (b[2] + len > b[3]) {
    resize(b, len);
  }
  Pervasives.really_input(ic, b[1], b[2], len);
  b[2] += len;
  return /* () */0;
}

function output_buffer(oc, b) {
  return Pervasives.output(oc, b[1], 0, b[2]);
}

function closing(param) {
  if (param !== 40) {
    if (param !== 123) {
      throw [
            0,
            Caml_exceptions.Assert_failure,
            [
              0,
              "buffer.ml",
              115,
              9
            ]
          ];
    }
    else {
      return /* "}" */125;
    }
  }
  else {
    return /* ")" */41;
  }
}

function advance_to_closing(opening, closing, k, s, start) {
  var advance = function (_k, _i, lim) {
    while(/* true */1) {
      var i = _i;
      var k = _k;
      if (i >= lim) {
        throw Caml_exceptions.Not_found;
      }
      else {
        if (s.charCodeAt(i) === opening) {
          _i = i + 1;
          _k = k + 1;
        }
        else {
          if (s.charCodeAt(i) === closing) {
            if (k) {
              _i = i + 1;
              _k = k - 1;
            }
            else {
              return i;
            }
          }
          else {
            _i = i + 1;
          }
        }
      }
    };
  };
  return advance(k, start, s.length);
}

function advance_to_non_alpha(s, start) {
  var advance = function (_i, lim) {
    while(/* true */1) {
      var i = _i;
      if (i >= lim) {
        return lim;
      }
      else {
        var match = s.charCodeAt(i);
        /* initialize */var exit = 0;
        if (match >= 91) {
          if (match >= 97) {
            if (match >= 123) {
              return i;
            }
            else {
              exit = 14;
            }
          }
          else {
            if (match !== 95) {
              return i;
            }
            else {
              exit = 14;
            }
          }
        }
        else {
          if (match >= 58) {
            if (match >= 65) {
              exit = 14;
            }
            else {
              return i;
            }
          }
          else {
            if (match >= 48) {
              exit = 14;
            }
            else {
              return i;
            }
          }
        }
        if (exit === 14) {
          _i = i + 1;
        }
        
      }
    };
  };
  return advance(start, s.length);
}

function find_ident(s, start, lim) {
  if (start >= lim) {
    throw Caml_exceptions.Not_found;
  }
  else {
    var c = s.charCodeAt(start);
    /* initialize */var exit = 0;
    if (c !== 40) {
      if (c !== 123) {
        var stop = advance_to_non_alpha(s, start + 1);
        return [
                /* tuple */0,
                $$String.sub(s, start, stop - start),
                stop
              ];
      }
      else {
        exit = 11;
      }
    }
    else {
      exit = 11;
    }
    if (exit === 11) {
      var new_start = start + 1;
      var stop$1 = advance_to_closing(c, closing(c), 0, s, new_start);
      return [
              /* tuple */0,
              $$String.sub(s, new_start, stop$1 - start - 1),
              stop$1 + 1
            ];
    }
    
  }
}

function add_substitute(b, f, s) {
  var lim = s.length;
  var subst = function (_previous, _i) {
    while(/* true */1) {
      var i = _i;
      var previous = _previous;
      if (i < lim) {
        var current = s.charCodeAt(i);
        if (current !== 36) {
          if (previous === /* "\\" */92) {
            add_char(b, /* "\\" */92);
            add_char(b, current);
            _i = i + 1;
            _previous = /* " " */32;
          }
          else {
            if (current !== 92) {
              add_char(b, current);
              _i = i + 1;
              _previous = current;
            }
            else {
              _i = i + 1;
              _previous = current;
            }
          }
        }
        else {
          if (previous === /* "\\" */92) {
            add_char(b, current);
            _i = i + 1;
            _previous = /* " " */32;
          }
          else {
            var j = i + 1;
            var match = find_ident(s, j, lim);
            add_string(b, f(match[1]));
            _i = match[2];
            _previous = /* " " */32;
          }
        }
      }
      else {
        return previous === /* "\\" */92 ? add_char(b, previous) : 0;
      }
    };
  };
  return subst(/* " " */32, 0);
}

exports.create = create;
exports.contents = contents;
exports.to_bytes = to_bytes;
exports.sub = sub;
exports.blit = blit;
exports.nth = nth;
exports.length = length;
exports.clear = clear;
exports.reset = reset;
exports.add_char = add_char;
exports.add_string = add_string;
exports.add_bytes = add_bytes;
exports.add_substring = add_substring;
exports.add_subbytes = add_subbytes;
exports.add_substitute = add_substitute;
exports.add_buffer = add_buffer;
exports.add_channel = add_channel;
exports.output_buffer = output_buffer;
/* No side effect */
