// Generated CODE, PLEASE EDIT WITH CARE
"use strict";
var Bytes = require("./bytes");
var Caml_float = require("../runtime/caml_float");
var Pervasives = require("./pervasives");
var Caml_exceptions = require("../runtime/caml_exceptions");
var Caml_format = require("../runtime/caml_format");
var Char = require("./char");
var Sys = require("./sys");
var Caml_primitive = require("../runtime/caml_primitive");
var CamlinternalFormatBasics = require("./camlinternalFormatBasics");
var Buffer = require("./buffer");
var $$String = require("./string");
var Caml_string = require("../runtime/caml_string");

function create_char_set() {
  return Bytes.make(32, /* "\000" */0);
}

function add_in_char_set(char_set, c) {
  var str_ind = (c >>> 3);
  var mask = (1 << (c & 7));
  char_set[str_ind] = Pervasives.char_of_int(char_set[str_ind] | mask);
  return /* () */0;
}

function freeze_char_set(char_set) {
  return Bytes.to_string(char_set);
}

function rev_char_set(char_set) {
  var char_set$prime = create_char_set(/* () */0);
  for(var i = 0; i<= 31; ++i){
    char_set$prime[i] = Pervasives.char_of_int(char_set.charCodeAt(i) ^ 255);
  }
  return Bytes.unsafe_to_string(char_set$prime);
}

function is_in_char_set(char_set, c) {
  var str_ind = (c >>> 3);
  var mask = (1 << (c & 7));
  return +((char_set.charCodeAt(str_ind) & mask) !== 0);
}

function pad_of_pad_opt(pad_opt) {
  return pad_opt ? [
            /* Lit_padding */0,
            /* Right */1,
            pad_opt[1]
          ] : /* No_padding */0;
}

function prec_of_prec_opt(prec_opt) {
  return prec_opt ? [
            /* Lit_precision */0,
            prec_opt[1]
          ] : /* No_precision */0;
}

function param_format_of_ignored_format(ign, fmt) {
  if (typeof ign === "number") {
    switch (ign) {
      case 0 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Char */0,
                    fmt
                  ]
                ];
      case 1 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Caml_char */1,
                    fmt
                  ]
                ];
      case 2 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Bool */9,
                    fmt
                  ]
                ];
      case 3 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Reader */19,
                    fmt
                  ]
                ];
      case 4 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Scan_next_char */22,
                    fmt
                  ]
                ];
      
    }
  }
  else {
    switch (ign[0]) {
      case 0 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* String */2,
                    pad_of_pad_opt(ign[1]),
                    fmt
                  ]
                ];
      case 1 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Caml_string */3,
                    pad_of_pad_opt(ign[1]),
                    fmt
                  ]
                ];
      case 2 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Int */4,
                    ign[1],
                    pad_of_pad_opt(ign[2]),
                    /* No_precision */0,
                    fmt
                  ]
                ];
      case 3 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Int32 */5,
                    ign[1],
                    pad_of_pad_opt(ign[2]),
                    /* No_precision */0,
                    fmt
                  ]
                ];
      case 4 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Nativeint */6,
                    ign[1],
                    pad_of_pad_opt(ign[2]),
                    /* No_precision */0,
                    fmt
                  ]
                ];
      case 5 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Int64 */7,
                    ign[1],
                    pad_of_pad_opt(ign[2]),
                    /* No_precision */0,
                    fmt
                  ]
                ];
      case 6 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Float */8,
                    /* Float_f */0,
                    pad_of_pad_opt(ign[1]),
                    prec_of_prec_opt(ign[2]),
                    fmt
                  ]
                ];
      case 7 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Format_arg */13,
                    ign[1],
                    ign[2],
                    fmt
                  ]
                ];
      case 8 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Format_subst */14,
                    ign[1],
                    ign[2],
                    fmt
                  ]
                ];
      case 9 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Scan_char_set */20,
                    ign[1],
                    ign[2],
                    fmt
                  ]
                ];
      case 10 : 
          return [
                  /* Param_format_EBB */0,
                  [
                    /* Scan_get_counter */21,
                    ign[1],
                    fmt
                  ]
                ];
      
    }
  }
}

var default_float_precision = 6;

function buffer_create(init_size) {
  return [
          /* record */0,
          0,
          Caml_string.caml_create_string(init_size)
        ];
}

function buffer_check_size(buf, overhead) {
  var len = buf[2].length;
  var min_len = buf[1] + overhead;
  if (min_len > len) {
    var new_len = Pervasives.max(len * 2, min_len);
    var new_str = Caml_string.caml_create_string(new_len);
    Bytes.blit(buf[2], 0, new_str, 0, len);
    buf[2] = new_str;
    return /* () */0;
  }
  else {
    return 0;
  }
}

function buffer_add_char(buf, c) {
  buffer_check_size(buf, 1);
  buf[2][buf[1]] = c;
  ++ buf[1];
  return /* () */0;
}

function buffer_add_string(buf, s) {
  var str_len = s.length;
  buffer_check_size(buf, str_len);
  $$String.blit(s, 0, buf[2], buf[1], str_len);
  buf[1] += str_len;
  return /* () */0;
}

function buffer_contents(buf) {
  return Bytes.sub_string(buf[2], 0, buf[1]);
}

function char_of_iconv(iconv) {
  switch (iconv) {
    case 0 : 
    case 1 : 
    case 2 : 
        return /* "d" */100;
    case 3 : 
    case 4 : 
    case 5 : 
        return /* "i" */105;
    case 6 : 
    case 7 : 
        return /* "x" */120;
    case 8 : 
    case 9 : 
        return /* "X" */88;
    case 10 : 
    case 11 : 
        return /* "o" */111;
    case 12 : 
        return /* "u" */117;
    
  }
}

function char_of_fconv(fconv) {
  switch (fconv) {
    case 0 : 
    case 1 : 
    case 2 : 
        return /* "f" */102;
    case 3 : 
    case 4 : 
    case 5 : 
        return /* "e" */101;
    case 6 : 
    case 7 : 
    case 8 : 
        return /* "E" */69;
    case 9 : 
    case 10 : 
    case 11 : 
        return /* "g" */103;
    case 12 : 
    case 13 : 
    case 14 : 
        return /* "G" */71;
    case 15 : 
        return /* "F" */70;
    
  }
}

function char_of_counter(counter) {
  switch (counter) {
    case 0 : 
        return /* "l" */108;
    case 1 : 
        return /* "n" */110;
    case 2 : 
        return /* "N" */78;
    
  }
}

function bprint_char_set(buf, char_set) {
  var print_start = function (set) {
    var is_alone = function (c) {
      var match_001 = Char.chr(c - 1);
      var match_002 = Char.chr(c + 1);
      return +(is_in_char_set(set, c) && !(is_in_char_set(set, match_001) && is_in_char_set(set, match_002)));
    };
    if (is_alone(/* "]" */93)) {
      buffer_add_char(buf, /* "]" */93);
    }
    print_out(set, 1);
    return is_alone(/* "-" */45) ? buffer_add_char(buf, /* "-" */45) : 0;
  };
  var print_out = function (set, _i) {
    while(/* true */1) {
      var i = _i;
      if (i < 256) {
        if (is_in_char_set(set, Pervasives.char_of_int(i))) {
          return print_first(set, i);
        }
        else {
          _i = i + 1;
        }
      }
      else {
        return 0;
      }
    };
  };
  var print_first = function (set, i) {
    var match = Pervasives.char_of_int(i);
    /* initialize */var exit = 0;
    var switcher = -45 + match;
    if (!(48 < (switcher >>> 0))) {
      if (46 < (-1 + switcher >>> 0)) {
        return print_out(set, i + 1);
      }
      else {
        exit = 375;
      }
    }
    else {
      if (switcher >= 210) {
        return print_char(buf, 255);
      }
      else {
        exit = 375;
      }
    }
    if (exit === 375) {
      return print_second(set, i + 1);
    }
    
  };
  var print_second = function (set, i) {
    if (is_in_char_set(set, Pervasives.char_of_int(i))) {
      var match = Pervasives.char_of_int(i);
      /* initialize */var exit = 0;
      var switcher = -45 + match;
      if (!(48 < (switcher >>> 0))) {
        if (46 < (-1 + switcher >>> 0)) {
          if (!is_in_char_set(set, Pervasives.char_of_int(i + 1))) {
            print_char(buf, i - 1);
            return print_out(set, i + 1);
          }
          else {
            exit = 376;
          }
        }
        else {
          exit = 376;
        }
      }
      else {
        if (switcher >= 210) {
          print_char(buf, 254);
          return print_char(buf, 255);
        }
        else {
          exit = 376;
        }
      }
      if (exit === 376) {
        return !is_in_char_set(set, Pervasives.char_of_int(i + 1)) ? (print_char(buf, i - 1), print_char(buf, i), print_out(set, i + 2)) : print_in(set, i - 1, i + 2);
      }
      
    }
    else {
      print_char(buf, i - 1);
      return print_out(set, i + 1);
    }
  };
  var print_in = function (set, i, _j) {
    while(/* true */1) {
      var j = _j;
      if (j === 256 || !is_in_char_set(set, Pervasives.char_of_int(j))) {
        print_char(buf, i);
        print_char(buf, /* "-" */45);
        print_char(buf, j - 1);
        return j < 256 ? print_out(set, j + 1) : 0;
      }
      else {
        _j = j + 1;
      }
    };
  };
  var print_char = function (buf, i) {
    var c = Pervasives.char_of_int(i);
    return c !== 37 ? (
              c !== 64 ? buffer_add_char(buf, c) : (buffer_add_char(buf, /* "%" */37), buffer_add_char(buf, /* "@" */64))
            ) : (buffer_add_char(buf, /* "%" */37), buffer_add_char(buf, /* "%" */37));
  };
  buffer_add_char(buf, /* "[" */91);
  print_start(is_in_char_set(char_set, /* "\000" */0) ? (buffer_add_char(buf, /* "^" */94), rev_char_set(char_set)) : char_set);
  return buffer_add_char(buf, /* "]" */93);
}

function bprint_padty(buf, padty) {
  switch (padty) {
    case 0 : 
        return buffer_add_char(buf, /* "-" */45);
    case 1 : 
        return /* () */0;
    case 2 : 
        return buffer_add_char(buf, /* "0" */48);
    
  }
}

function bprint_ignored_flag(buf, ign_flag) {
  return ign_flag ? buffer_add_char(buf, /* "_" */95) : 0;
}

function bprint_pad_opt(buf, pad_opt) {
  return pad_opt ? buffer_add_string(buf, Pervasives.string_of_int(pad_opt[1])) : /* () */0;
}

function bprint_padding(buf, pad) {
  if (typeof pad === "number") {
    return /* () */0;
  }
  else {
    bprint_padty(buf, pad[1]);
    return pad[0] ? buffer_add_char(buf, /* "*" */42) : buffer_add_string(buf, Pervasives.string_of_int(pad[2]));
  }
}

function bprint_precision(buf, prec) {
  return typeof prec === "number" ? (
            prec !== 0 ? buffer_add_string(buf, ".*") : /* () */0
          ) : (buffer_add_char(buf, /* "." */46), buffer_add_string(buf, Pervasives.string_of_int(prec[1])));
}

function bprint_iconv_flag(buf, iconv) {
  /* initialize */var exit = 0;
  switch (iconv) {
    case 1 : 
    case 4 : 
        return buffer_add_char(buf, /* "+" */43);
    case 2 : 
    case 5 : 
        return buffer_add_char(buf, /* " " */32);
    case 7 : 
    case 9 : 
    case 11 : 
        exit = 364;
        break;
    case 0 : 
    case 3 : 
    case 6 : 
    case 8 : 
    case 10 : 
    case 12 : 
        return /* () */0;
    
  }
  if (exit === 364) {
    return buffer_add_char(buf, /* "#" */35);
  }
  
}

function bprint_int_fmt(buf, ign_flag, iconv, pad, prec) {
  buffer_add_char(buf, /* "%" */37);
  bprint_ignored_flag(buf, ign_flag);
  bprint_iconv_flag(buf, iconv);
  bprint_padding(buf, pad);
  bprint_precision(buf, prec);
  return buffer_add_char(buf, char_of_iconv(iconv));
}

function bprint_altint_fmt(buf, ign_flag, iconv, pad, prec, c) {
  buffer_add_char(buf, /* "%" */37);
  bprint_ignored_flag(buf, ign_flag);
  bprint_iconv_flag(buf, iconv);
  bprint_padding(buf, pad);
  bprint_precision(buf, prec);
  buffer_add_char(buf, c);
  return buffer_add_char(buf, char_of_iconv(iconv));
}

function bprint_fconv_flag(buf, fconv) {
  /* initialize */var exit = 0;
  switch (fconv) {
    case 1 : 
    case 4 : 
    case 7 : 
    case 10 : 
    case 13 : 
        exit = 356;
        break;
    case 2 : 
    case 5 : 
    case 8 : 
    case 11 : 
    case 14 : 
        exit = 357;
        break;
    case 0 : 
    case 3 : 
    case 6 : 
    case 9 : 
    case 12 : 
    case 15 : 
        return /* () */0;
    
  }
  switch (exit) {
    case 356 : 
        return buffer_add_char(buf, /* "+" */43);
    case 357 : 
        return buffer_add_char(buf, /* " " */32);
    
  }
}

function bprint_float_fmt(buf, ign_flag, fconv, pad, prec) {
  buffer_add_char(buf, /* "%" */37);
  bprint_ignored_flag(buf, ign_flag);
  bprint_fconv_flag(buf, fconv);
  bprint_padding(buf, pad);
  bprint_precision(buf, prec);
  return buffer_add_char(buf, char_of_fconv(fconv));
}

function string_of_formatting_lit(formatting_lit) {
  if (typeof formatting_lit === "number") {
    switch (formatting_lit) {
      case 0 : 
          return "@]";
      case 1 : 
          return "@}";
      case 2 : 
          return "@?";
      case 3 : 
          return "@\n";
      case 4 : 
          return "@.";
      case 5 : 
          return "@@";
      case 6 : 
          return "@%";
      
    }
  }
  else {
    switch (formatting_lit[0]) {
      case 0 : 
      case 1 : 
          return formatting_lit[1];
      case 2 : 
          return "@" + $$String.make(1, formatting_lit[1]);
      
    }
  }
}

function string_of_formatting_gen(formatting_gen) {
  return formatting_gen[1][2];
}

function bprint_char_literal(buf, chr) {
  return chr !== 37 ? buffer_add_char(buf, chr) : buffer_add_string(buf, "%%");
}

function bprint_string_literal(buf, str) {
  for(var i = 0 ,i_finish = str.length - 1; i<= i_finish; ++i){
    bprint_char_literal(buf, str.charCodeAt(i));
  }
  return /* () */0;
}

function bprint_fmtty(buf, _fmtty) {
  while(/* true */1) {
    var fmtty = _fmtty;
    if (typeof fmtty === "number") {
      return /* () */0;
    }
    else {
      switch (fmtty[0]) {
        case 0 : 
            buffer_add_string(buf, "%c");
            _fmtty = fmtty[1];
            break;
        case 1 : 
            buffer_add_string(buf, "%s");
            _fmtty = fmtty[1];
            break;
        case 2 : 
            buffer_add_string(buf, "%i");
            _fmtty = fmtty[1];
            break;
        case 3 : 
            buffer_add_string(buf, "%li");
            _fmtty = fmtty[1];
            break;
        case 4 : 
            buffer_add_string(buf, "%ni");
            _fmtty = fmtty[1];
            break;
        case 5 : 
            buffer_add_string(buf, "%Li");
            _fmtty = fmtty[1];
            break;
        case 6 : 
            buffer_add_string(buf, "%f");
            _fmtty = fmtty[1];
            break;
        case 7 : 
            buffer_add_string(buf, "%B");
            _fmtty = fmtty[1];
            break;
        case 8 : 
            buffer_add_string(buf, "%{");
            bprint_fmtty(buf, fmtty[1]);
            buffer_add_string(buf, "%}");
            _fmtty = fmtty[2];
            break;
        case 9 : 
            buffer_add_string(buf, "%(");
            bprint_fmtty(buf, fmtty[1]);
            buffer_add_string(buf, "%)");
            _fmtty = fmtty[3];
            break;
        case 10 : 
            buffer_add_string(buf, "%a");
            _fmtty = fmtty[1];
            break;
        case 11 : 
            buffer_add_string(buf, "%t");
            _fmtty = fmtty[1];
            break;
        case 12 : 
            buffer_add_string(buf, "%?");
            _fmtty = fmtty[1];
            break;
        case 13 : 
            buffer_add_string(buf, "%r");
            _fmtty = fmtty[1];
            break;
        case 14 : 
            buffer_add_string(buf, "%_r");
            _fmtty = fmtty[1];
            break;
        
      }
    }
  };
}

function int_of_custom_arity(param) {
  return param ? 1 + int_of_custom_arity(param[1]) : 0;
}

function bprint_fmt(buf, fmt) {
  var fmtiter = function (_fmt, _ign_flag) {
    while(/* true */1) {
      var ign_flag = _ign_flag;
      var fmt = _fmt;
      if (typeof fmt === "number") {
        return /* () */0;
      }
      else {
        switch (fmt[0]) {
          case 0 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, /* "c" */99);
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 1 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, /* "C" */67);
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 2 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              bprint_padding(buf, fmt[1]);
              buffer_add_char(buf, /* "s" */115);
              _ign_flag = /* false */0;
              _fmt = fmt[2];
              break;
          case 3 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              bprint_padding(buf, fmt[1]);
              buffer_add_char(buf, /* "S" */83);
              _ign_flag = /* false */0;
              _fmt = fmt[2];
              break;
          case 4 : 
              bprint_int_fmt(buf, ign_flag, fmt[1], fmt[2], fmt[3]);
              _ign_flag = /* false */0;
              _fmt = fmt[4];
              break;
          case 5 : 
              bprint_altint_fmt(buf, ign_flag, fmt[1], fmt[2], fmt[3], /* "l" */108);
              _ign_flag = /* false */0;
              _fmt = fmt[4];
              break;
          case 6 : 
              bprint_altint_fmt(buf, ign_flag, fmt[1], fmt[2], fmt[3], /* "n" */110);
              _ign_flag = /* false */0;
              _fmt = fmt[4];
              break;
          case 7 : 
              bprint_altint_fmt(buf, ign_flag, fmt[1], fmt[2], fmt[3], /* "L" */76);
              _ign_flag = /* false */0;
              _fmt = fmt[4];
              break;
          case 8 : 
              bprint_float_fmt(buf, ign_flag, fmt[1], fmt[2], fmt[3]);
              _ign_flag = /* false */0;
              _fmt = fmt[4];
              break;
          case 9 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, /* "B" */66);
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 10 : 
              buffer_add_string(buf, "%!");
              _fmt = fmt[1];
              break;
          case 11 : 
              bprint_string_literal(buf, fmt[1]);
              _fmt = fmt[2];
              break;
          case 12 : 
              bprint_char_literal(buf, fmt[1]);
              _fmt = fmt[2];
              break;
          case 13 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              bprint_pad_opt(buf, fmt[1]);
              buffer_add_char(buf, /* "{" */123);
              bprint_fmtty(buf, fmt[2]);
              buffer_add_char(buf, /* "%" */37);
              buffer_add_char(buf, /* "}" */125);
              _ign_flag = /* false */0;
              _fmt = fmt[3];
              break;
          case 14 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              bprint_pad_opt(buf, fmt[1]);
              buffer_add_char(buf, /* "(" */40);
              bprint_fmtty(buf, fmt[2]);
              buffer_add_char(buf, /* "%" */37);
              buffer_add_char(buf, /* ")" */41);
              _ign_flag = /* false */0;
              _fmt = fmt[3];
              break;
          case 15 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, /* "a" */97);
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 16 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, /* "t" */116);
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 17 : 
              bprint_string_literal(buf, string_of_formatting_lit(fmt[1]));
              _fmt = fmt[2];
              break;
          case 18 : 
              bprint_string_literal(buf, "@{");
              bprint_string_literal(buf, string_of_formatting_gen(fmt[1]));
              _fmt = fmt[2];
              break;
          case 19 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, /* "r" */114);
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 20 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              bprint_pad_opt(buf, fmt[1]);
              bprint_char_set(buf, fmt[2]);
              _ign_flag = /* false */0;
              _fmt = fmt[3];
              break;
          case 21 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              buffer_add_char(buf, char_of_counter(fmt[1]));
              _ign_flag = /* false */0;
              _fmt = fmt[2];
              break;
          case 22 : 
              buffer_add_char(buf, /* "%" */37);
              bprint_ignored_flag(buf, ign_flag);
              bprint_string_literal(buf, "0c");
              _ign_flag = /* false */0;
              _fmt = fmt[1];
              break;
          case 23 : 
              var match = param_format_of_ignored_format(fmt[1], fmt[2]);
              _ign_flag = /* true */1;
              _fmt = match[1];
              break;
          case 24 : 
              for(var _i = 1 ,_i_finish = int_of_custom_arity(fmt[1]); _i<= _i_finish; ++_i){
                buffer_add_char(buf, /* "%" */37);
                bprint_ignored_flag(buf, ign_flag);
                buffer_add_char(buf, /* "?" */63);
              }
              _ign_flag = /* false */0;
              _fmt = fmt[3];
              break;
          
        }
      }
    };
  };
  return fmtiter(fmt, /* false */0);
}

function string_of_fmt(fmt) {
  var buf = buffer_create(16);
  bprint_fmt(buf, fmt);
  return buffer_contents(buf);
}

function symm(param) {
  if (typeof param === "number") {
    return /* End_of_fmtty */0;
  }
  else {
    switch (param[0]) {
      case 0 : 
          return [
                  /* Char_ty */0,
                  symm(param[1])
                ];
      case 1 : 
          return [
                  /* String_ty */1,
                  symm(param[1])
                ];
      case 2 : 
          return [
                  /* Int_ty */2,
                  symm(param[1])
                ];
      case 3 : 
          return [
                  /* Int32_ty */3,
                  symm(param[1])
                ];
      case 4 : 
          return [
                  /* Nativeint_ty */4,
                  symm(param[1])
                ];
      case 5 : 
          return [
                  /* Int64_ty */5,
                  symm(param[1])
                ];
      case 6 : 
          return [
                  /* Float_ty */6,
                  symm(param[1])
                ];
      case 7 : 
          return [
                  /* Bool_ty */7,
                  symm(param[1])
                ];
      case 8 : 
          return [
                  /* Format_arg_ty */8,
                  param[1],
                  symm(param[2])
                ];
      case 9 : 
          return [
                  /* Format_subst_ty */9,
                  param[2],
                  param[1],
                  symm(param[3])
                ];
      case 10 : 
          return [
                  /* Alpha_ty */10,
                  symm(param[1])
                ];
      case 11 : 
          return [
                  /* Theta_ty */11,
                  symm(param[1])
                ];
      case 12 : 
          return [
                  /* Any_ty */12,
                  symm(param[1])
                ];
      case 13 : 
          return [
                  /* Reader_ty */13,
                  symm(param[1])
                ];
      case 14 : 
          return [
                  /* Ignored_reader_ty */14,
                  symm(param[1])
                ];
      
    }
  }
}

function fmtty_rel_det(param) {
  if (typeof param === "number") {
    return [
            /* tuple */0,
            function () {
              return /* Refl */0;
            },
            function () {
              return /* Refl */0;
            },
            function () {
              return /* Refl */0;
            },
            function () {
              return /* Refl */0;
            }
          ];
  }
  else {
    switch (param[0]) {
      case 0 : 
          var match = fmtty_rel_det(param[1]);
          var af = match[2];
          var fa = match[1];
          return [
                  /* tuple */0,
                  function () {
                    fa(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af(/* Refl */0);
                    return /* Refl */0;
                  },
                  match[3],
                  match[4]
                ];
      case 1 : 
          var match$1 = fmtty_rel_det(param[1]);
          var af$1 = match$1[2];
          var fa$1 = match$1[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$1(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$1(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$1[3],
                  match$1[4]
                ];
      case 2 : 
          var match$2 = fmtty_rel_det(param[1]);
          var af$2 = match$2[2];
          var fa$2 = match$2[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$2(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$2(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$2[3],
                  match$2[4]
                ];
      case 3 : 
          var match$3 = fmtty_rel_det(param[1]);
          var af$3 = match$3[2];
          var fa$3 = match$3[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$3(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$3(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$3[3],
                  match$3[4]
                ];
      case 4 : 
          var match$4 = fmtty_rel_det(param[1]);
          var af$4 = match$4[2];
          var fa$4 = match$4[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$4(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$4(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$4[3],
                  match$4[4]
                ];
      case 5 : 
          var match$5 = fmtty_rel_det(param[1]);
          var af$5 = match$5[2];
          var fa$5 = match$5[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$5(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$5(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$5[3],
                  match$5[4]
                ];
      case 6 : 
          var match$6 = fmtty_rel_det(param[1]);
          var af$6 = match$6[2];
          var fa$6 = match$6[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$6(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$6(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$6[3],
                  match$6[4]
                ];
      case 7 : 
          var match$7 = fmtty_rel_det(param[1]);
          var af$7 = match$7[2];
          var fa$7 = match$7[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$7(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$7(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$7[3],
                  match$7[4]
                ];
      case 8 : 
          var match$8 = fmtty_rel_det(param[2]);
          var af$8 = match$8[2];
          var fa$8 = match$8[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$8(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$8(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$8[3],
                  match$8[4]
                ];
      case 9 : 
          var match$9 = fmtty_rel_det(param[3]);
          var de = match$9[4];
          var ed = match$9[3];
          var af$9 = match$9[2];
          var fa$9 = match$9[1];
          var ty = trans(symm(param[1]), param[2]);
          var match$10 = fmtty_rel_det(ty);
          var jd = match$10[4];
          var dj = match$10[3];
          var ga = match$10[2];
          var ag = match$10[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$9(/* Refl */0);
                    ag(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    ga(/* Refl */0);
                    af$9(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    ed(/* Refl */0);
                    dj(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    jd(/* Refl */0);
                    de(/* Refl */0);
                    return /* Refl */0;
                  }
                ];
      case 10 : 
          var match$11 = fmtty_rel_det(param[1]);
          var af$10 = match$11[2];
          var fa$10 = match$11[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$10(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$10(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$11[3],
                  match$11[4]
                ];
      case 11 : 
          var match$12 = fmtty_rel_det(param[1]);
          var af$11 = match$12[2];
          var fa$11 = match$12[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$11(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$11(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$12[3],
                  match$12[4]
                ];
      case 12 : 
          var match$13 = fmtty_rel_det(param[1]);
          var af$12 = match$13[2];
          var fa$12 = match$13[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$12(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$12(/* Refl */0);
                    return /* Refl */0;
                  },
                  match$13[3],
                  match$13[4]
                ];
      case 13 : 
          var match$14 = fmtty_rel_det(param[1]);
          var de$1 = match$14[4];
          var ed$1 = match$14[3];
          var af$13 = match$14[2];
          var fa$13 = match$14[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$13(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$13(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    ed$1(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    de$1(/* Refl */0);
                    return /* Refl */0;
                  }
                ];
      case 14 : 
          var match$15 = fmtty_rel_det(param[1]);
          var de$2 = match$15[4];
          var ed$2 = match$15[3];
          var af$14 = match$15[2];
          var fa$14 = match$15[1];
          return [
                  /* tuple */0,
                  function () {
                    fa$14(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    af$14(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    ed$2(/* Refl */0);
                    return /* Refl */0;
                  },
                  function () {
                    de$2(/* Refl */0);
                    return /* Refl */0;
                  }
                ];
      
    }
  }
}

function trans(ty1, ty2) {
  /* initialize */var exit = 0;
  if (typeof ty1 === "number") {
    if (typeof ty2 === "number") {
      if (ty2) {
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                816,
                23
              ]
            ];
      }
      else {
        return /* End_of_fmtty */0;
      }
    }
    else {
      switch (ty2[0]) {
        case 8 : 
            exit = 335;
            break;
        case 9 : 
            exit = 333;
            break;
        case 10 : 
            exit = 345;
            break;
        case 11 : 
            exit = 343;
            break;
        case 12 : 
            exit = 341;
            break;
        case 13 : 
            exit = 339;
            break;
        case 14 : 
            exit = 337;
            break;
        default:
          throw [
                0,
                Caml_exceptions.Assert_failure,
                [
                  0,
                  "camlinternalFormat.ml",
                  816,
                  23
                ]
              ];
      }
    }
  }
  else {
    switch (ty1[0]) {
      case 0 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 0 : 
                  return [
                          /* Char_ty */0,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 1 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 1 : 
                  return [
                          /* String_ty */1,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 2 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 2 : 
                  return [
                          /* Int_ty */2,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 3 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 3 : 
                  return [
                          /* Int32_ty */3,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 4 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 4 : 
                  return [
                          /* Nativeint_ty */4,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 5 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 5 : 
                  return [
                          /* Int64_ty */5,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 6 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 6 : 
                  return [
                          /* Float_ty */6,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 7 : 
          if (typeof ty2 === "number") {
            exit = 331;
          }
          else {
            switch (ty2[0]) {
              case 7 : 
                  return [
                          /* Bool_ty */7,
                          trans(ty1[1], ty2[1])
                        ];
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  exit = 333;
                  break;
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              
            }
          }
          break;
      case 8 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    802,
                    26
                  ]
                ];
          }
          else {
            switch (ty2[0]) {
              case 8 : 
                  return [
                          /* Format_arg_ty */8,
                          trans(ty1[1], ty2[1]),
                          trans(ty1[2], ty2[2])
                        ];
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              default:
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        802,
                        26
                      ]
                    ];
            }
          }
          break;
      case 9 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    812,
                    28
                  ]
                ];
          }
          else {
            switch (ty2[0]) {
              case 8 : 
                  exit = 335;
                  break;
              case 9 : 
                  var ty = trans(symm(ty1[2]), ty2[1]);
                  var match = fmtty_rel_det(ty);
                  match[2](/* Refl */0);
                  match[4](/* Refl */0);
                  return [
                          /* Format_subst_ty */9,
                          ty1[1],
                          ty2[2],
                          trans(ty1[3], ty2[3])
                        ];
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  exit = 337;
                  break;
              default:
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        812,
                        28
                      ]
                    ];
            }
          }
          break;
      case 10 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    780,
                    21
                  ]
                ];
          }
          else {
            if (ty2[0] === 10) {
              return [
                      /* Alpha_ty */10,
                      trans(ty1[1], ty2[1])
                    ];
            }
            else {
              throw [
                    0,
                    Caml_exceptions.Assert_failure,
                    [
                      0,
                      "camlinternalFormat.ml",
                      780,
                      21
                    ]
                  ];
            }
          }
          break;
      case 11 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    784,
                    21
                  ]
                ];
          }
          else {
            switch (ty2[0]) {
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  return [
                          /* Theta_ty */11,
                          trans(ty1[1], ty2[1])
                        ];
              default:
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        784,
                        21
                      ]
                    ];
            }
          }
          break;
      case 12 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    788,
                    19
                  ]
                ];
          }
          else {
            switch (ty2[0]) {
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  return [
                          /* Any_ty */12,
                          trans(ty1[1], ty2[1])
                        ];
              default:
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        788,
                        19
                      ]
                    ];
            }
          }
          break;
      case 13 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    792,
                    22
                  ]
                ];
          }
          else {
            switch (ty2[0]) {
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  return [
                          /* Reader_ty */13,
                          trans(ty1[1], ty2[1])
                        ];
              default:
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        792,
                        22
                      ]
                    ];
            }
          }
          break;
      case 14 : 
          if (typeof ty2 === "number") {
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    797,
                    30
                  ]
                ];
          }
          else {
            switch (ty2[0]) {
              case 10 : 
                  exit = 345;
                  break;
              case 11 : 
                  exit = 343;
                  break;
              case 12 : 
                  exit = 341;
                  break;
              case 13 : 
                  exit = 339;
                  break;
              case 14 : 
                  return [
                          /* Ignored_reader_ty */14,
                          trans(ty1[1], ty2[1])
                        ];
              default:
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        797,
                        30
                      ]
                    ];
            }
          }
          break;
      
    }
  }
  switch (exit) {
    case 345 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                781,
                21
              ]
            ];
    case 343 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                785,
                21
              ]
            ];
    case 341 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                789,
                19
              ]
            ];
    case 339 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                793,
                22
              ]
            ];
    case 337 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                798,
                30
              ]
            ];
    case 335 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                803,
                26
              ]
            ];
    case 333 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                813,
                28
              ]
            ];
    case 331 : 
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                817,
                23
              ]
            ];
    
  }
}

function fmtty_of_formatting_gen(formatting_gen) {
  return fmtty_of_fmt(formatting_gen[1][1]);
}

function fmtty_of_fmt(_fmtty) {
  while(/* true */1) {
    var fmtty = _fmtty;
    if (typeof fmtty === "number") {
      return /* End_of_fmtty */0;
    }
    else {
      switch (fmtty[0]) {
        case 2 : 
        case 3 : 
            return fmtty_of_padding_fmtty(fmtty[1], [
                        /* String_ty */1,
                        fmtty_of_fmt(fmtty[2])
                      ]);
        case 4 : 
            var ty_rest = fmtty_of_fmt(fmtty[4]);
            var prec_ty = fmtty_of_precision_fmtty(fmtty[3], [
                  /* Int_ty */2,
                  ty_rest
                ]);
            return fmtty_of_padding_fmtty(fmtty[2], prec_ty);
        case 5 : 
            var ty_rest$1 = fmtty_of_fmt(fmtty[4]);
            var prec_ty$1 = fmtty_of_precision_fmtty(fmtty[3], [
                  /* Int32_ty */3,
                  ty_rest$1
                ]);
            return fmtty_of_padding_fmtty(fmtty[2], prec_ty$1);
        case 6 : 
            var ty_rest$2 = fmtty_of_fmt(fmtty[4]);
            var prec_ty$2 = fmtty_of_precision_fmtty(fmtty[3], [
                  /* Nativeint_ty */4,
                  ty_rest$2
                ]);
            return fmtty_of_padding_fmtty(fmtty[2], prec_ty$2);
        case 7 : 
            var ty_rest$3 = fmtty_of_fmt(fmtty[4]);
            var prec_ty$3 = fmtty_of_precision_fmtty(fmtty[3], [
                  /* Int64_ty */5,
                  ty_rest$3
                ]);
            return fmtty_of_padding_fmtty(fmtty[2], prec_ty$3);
        case 8 : 
            var ty_rest$4 = fmtty_of_fmt(fmtty[4]);
            var prec_ty$4 = fmtty_of_precision_fmtty(fmtty[3], [
                  /* Float_ty */6,
                  ty_rest$4
                ]);
            return fmtty_of_padding_fmtty(fmtty[2], prec_ty$4);
        case 9 : 
            return [
                    /* Bool_ty */7,
                    fmtty_of_fmt(fmtty[1])
                  ];
        case 10 : 
            _fmtty = fmtty[1];
            break;
        case 13 : 
            return [
                    /* Format_arg_ty */8,
                    fmtty[2],
                    fmtty_of_fmt(fmtty[3])
                  ];
        case 14 : 
            var ty = fmtty[2];
            return [
                    /* Format_subst_ty */9,
                    ty,
                    ty,
                    fmtty_of_fmt(fmtty[3])
                  ];
        case 15 : 
            return [
                    /* Alpha_ty */10,
                    fmtty_of_fmt(fmtty[1])
                  ];
        case 16 : 
            return [
                    /* Theta_ty */11,
                    fmtty_of_fmt(fmtty[1])
                  ];
        case 11 : 
        case 12 : 
        case 17 : 
            _fmtty = fmtty[2];
            break;
        case 18 : 
            return CamlinternalFormatBasics.concat_fmtty(fmtty_of_formatting_gen(fmtty[1]), fmtty_of_fmt(fmtty[2]));
        case 19 : 
            return [
                    /* Reader_ty */13,
                    fmtty_of_fmt(fmtty[1])
                  ];
        case 20 : 
            return [
                    /* String_ty */1,
                    fmtty_of_fmt(fmtty[3])
                  ];
        case 21 : 
            return [
                    /* Int_ty */2,
                    fmtty_of_fmt(fmtty[2])
                  ];
        case 0 : 
        case 1 : 
        case 22 : 
            return [
                    /* Char_ty */0,
                    fmtty_of_fmt(fmtty[1])
                  ];
        case 23 : 
            return fmtty_of_ignored_format(fmtty[1], fmtty[2]);
        case 24 : 
            return fmtty_of_custom(fmtty[1], fmtty_of_fmt(fmtty[3]));
        
      }
    }
  };
}

function fmtty_of_custom(arity, fmtty) {
  return arity ? [
            /* Any_ty */12,
            fmtty_of_custom(arity[1], fmtty)
          ] : fmtty;
}

function fmtty_of_ignored_format(ign, fmt) {
  if (typeof ign === "number") {
    switch (ign) {
      case 3 : 
          return [
                  /* Ignored_reader_ty */14,
                  fmtty_of_fmt(fmt)
                ];
      case 0 : 
      case 1 : 
      case 2 : 
      case 4 : 
          return fmtty_of_fmt(fmt);
      
    }
  }
  else {
    switch (ign[0]) {
      case 8 : 
          return CamlinternalFormatBasics.concat_fmtty(ign[2], fmtty_of_fmt(fmt));
      case 0 : 
      case 1 : 
      case 2 : 
      case 3 : 
      case 4 : 
      case 5 : 
      case 6 : 
      case 7 : 
      case 9 : 
      case 10 : 
          return fmtty_of_fmt(fmt);
      
    }
  }
}

function fmtty_of_padding_fmtty(pad, fmtty) {
  return typeof pad === "number" ? fmtty : (
            pad[0] ? [
                /* Int_ty */2,
                fmtty
              ] : fmtty
          );
}

function fmtty_of_precision_fmtty(prec, fmtty) {
  return typeof prec === "number" ? (
            prec !== 0 ? [
                /* Int_ty */2,
                fmtty
              ] : fmtty
          ) : fmtty;
}

var Type_mismatch = [
  248,
  "CamlinternalFormat.Type_mismatch",
  ++ Caml_exceptions.caml_oo_last_id
];

function type_padding(pad, fmtty) {
  if (typeof pad === "number") {
    return [
            /* Padding_fmtty_EBB */0,
            /* No_padding */0,
            fmtty
          ];
  }
  else {
    if (pad[0]) {
      if (typeof fmtty === "number") {
        throw Type_mismatch;
      }
      else {
        if (fmtty[0] === 2) {
          return [
                  /* Padding_fmtty_EBB */0,
                  [
                    /* Arg_padding */1,
                    pad[1]
                  ],
                  fmtty[1]
                ];
        }
        else {
          throw Type_mismatch;
        }
      }
    }
    else {
      return [
              /* Padding_fmtty_EBB */0,
              [
                /* Lit_padding */0,
                pad[1],
                pad[2]
              ],
              fmtty
            ];
    }
  }
}

function type_padprec(pad, prec, fmtty) {
  var match = type_padding(pad, fmtty);
  if (typeof prec === "number") {
    if (prec !== 0) {
      var match$1 = match[2];
      if (typeof match$1 === "number") {
        throw Type_mismatch;
      }
      else {
        if (match$1[0] === 2) {
          return [
                  /* Padprec_fmtty_EBB */0,
                  match[1],
                  /* Arg_precision */1,
                  match$1[1]
                ];
        }
        else {
          throw Type_mismatch;
        }
      }
    }
    else {
      return [
              /* Padprec_fmtty_EBB */0,
              match[1],
              /* No_precision */0,
              match[2]
            ];
    }
  }
  else {
    return [
            /* Padprec_fmtty_EBB */0,
            match[1],
            [
              /* Lit_precision */0,
              prec[1]
            ],
            match[2]
          ];
  }
}

function type_format(fmt, fmtty) {
  var match = type_format_gen(fmt, fmtty);
  if (typeof match[2] === "number") {
    return match[1];
  }
  else {
    throw Type_mismatch;
  }
}

function type_format_gen(fmt, fmtty) {
  /* initialize */var exit = 0;
  if (typeof fmt === "number") {
    return [
            /* Fmt_fmtty_EBB */0,
            /* End_of_format */0,
            fmtty
          ];
  }
  else {
    switch (fmt[0]) {
      case 0 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0]) {
              exit = 293;
            }
            else {
              var match = type_format_gen(fmt[1], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Char */0,
                        match[1]
                      ],
                      match[2]
                    ];
            }
          }
          break;
      case 1 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0]) {
              exit = 293;
            }
            else {
              var match$1 = type_format_gen(fmt[1], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Caml_char */1,
                        match$1[1]
                      ],
                      match$1[2]
                    ];
            }
          }
          break;
      case 2 : 
          var match$2 = type_padding(fmt[1], fmtty);
          var match$3 = match$2[2];
          if (typeof match$3 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$3[0] === 1) {
              var match$4 = type_format_gen(fmt[2], match$3[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* String */2,
                        match$2[1],
                        match$4[1]
                      ],
                      match$4[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 3 : 
          var match$5 = type_padding(fmt[1], fmtty);
          var match$6 = match$5[2];
          if (typeof match$6 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$6[0] === 1) {
              var match$7 = type_format_gen(fmt[2], match$6[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Caml_string */3,
                        match$5[1],
                        match$7[1]
                      ],
                      match$7[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 4 : 
          var match$8 = type_padprec(fmt[2], fmt[3], fmtty);
          var match$9 = match$8[3];
          if (typeof match$9 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$9[0] === 2) {
              var match$10 = type_format_gen(fmt[4], match$9[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Int */4,
                        fmt[1],
                        match$8[1],
                        match$8[2],
                        match$10[1]
                      ],
                      match$10[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 5 : 
          var match$11 = type_padprec(fmt[2], fmt[3], fmtty);
          var match$12 = match$11[3];
          if (typeof match$12 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$12[0] === 3) {
              var match$13 = type_format_gen(fmt[4], match$12[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Int32 */5,
                        fmt[1],
                        match$11[1],
                        match$11[2],
                        match$13[1]
                      ],
                      match$13[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 6 : 
          var match$14 = type_padprec(fmt[2], fmt[3], fmtty);
          var match$15 = match$14[3];
          if (typeof match$15 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$15[0] === 4) {
              var match$16 = type_format_gen(fmt[4], match$15[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Nativeint */6,
                        fmt[1],
                        match$14[1],
                        match$14[2],
                        match$16[1]
                      ],
                      match$16[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 7 : 
          var match$17 = type_padprec(fmt[2], fmt[3], fmtty);
          var match$18 = match$17[3];
          if (typeof match$18 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$18[0] === 5) {
              var match$19 = type_format_gen(fmt[4], match$18[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Int64 */7,
                        fmt[1],
                        match$17[1],
                        match$17[2],
                        match$19[1]
                      ],
                      match$19[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 8 : 
          var match$20 = type_padprec(fmt[2], fmt[3], fmtty);
          var match$21 = match$20[3];
          if (typeof match$21 === "number") {
            throw Type_mismatch;
          }
          else {
            if (match$21[0] === 6) {
              var match$22 = type_format_gen(fmt[4], match$21[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Float */8,
                        fmt[1],
                        match$20[1],
                        match$20[2],
                        match$22[1]
                      ],
                      match$22[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 9 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 7) {
              var match$23 = type_format_gen(fmt[1], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Bool */9,
                        match$23[1]
                      ],
                      match$23[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 10 : 
          var match$24 = type_format_gen(fmt[1], fmtty);
          return [
                  /* Fmt_fmtty_EBB */0,
                  [
                    /* Flush */10,
                    match$24[1]
                  ],
                  match$24[2]
                ];
      case 11 : 
          var match$25 = type_format_gen(fmt[2], fmtty);
          return [
                  /* Fmt_fmtty_EBB */0,
                  [
                    /* String_literal */11,
                    fmt[1],
                    match$25[1]
                  ],
                  match$25[2]
                ];
      case 12 : 
          var match$26 = type_format_gen(fmt[2], fmtty);
          return [
                  /* Fmt_fmtty_EBB */0,
                  [
                    /* Char_literal */12,
                    fmt[1],
                    match$26[1]
                  ],
                  match$26[2]
                ];
      case 13 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 8) {
              var sub_fmtty$prime = fmtty[1];
              if (Caml_primitive.caml_notequal([
                      /* Fmtty_EBB */0,
                      fmt[2]
                    ], [
                      /* Fmtty_EBB */0,
                      sub_fmtty$prime
                    ])) {
                throw Type_mismatch;
              }
              var match$27 = type_format_gen(fmt[3], fmtty[2]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Format_arg */13,
                        fmt[1],
                        sub_fmtty$prime,
                        match$27[1]
                      ],
                      match$27[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 14 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 9) {
              var sub_fmtty1 = fmtty[1];
              if (Caml_primitive.caml_notequal([
                      /* Fmtty_EBB */0,
                      CamlinternalFormatBasics.erase_rel(fmt[2])
                    ], [
                      /* Fmtty_EBB */0,
                      CamlinternalFormatBasics.erase_rel(sub_fmtty1)
                    ])) {
                throw Type_mismatch;
              }
              var match$28 = type_format_gen(fmt[3], CamlinternalFormatBasics.erase_rel(fmtty[3]));
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Format_subst */14,
                        fmt[1],
                        sub_fmtty1,
                        match$28[1]
                      ],
                      match$28[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 15 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 10) {
              var match$29 = type_format_gen(fmt[1], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Alpha */15,
                        match$29[1]
                      ],
                      match$29[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 16 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 11) {
              var match$30 = type_format_gen(fmt[1], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Theta */16,
                        match$30[1]
                      ],
                      match$30[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 17 : 
          var match$31 = type_format_gen(fmt[2], fmtty);
          return [
                  /* Fmt_fmtty_EBB */0,
                  [
                    /* Formatting_lit */17,
                    fmt[1],
                    match$31[1]
                  ],
                  match$31[2]
                ];
      case 18 : 
          return type_formatting_gen(fmt[1], fmt[2], fmtty);
      case 19 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 13) {
              var match$32 = type_format_gen(fmt[1], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Reader */19,
                        match$32[1]
                      ],
                      match$32[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 20 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 1) {
              var match$33 = type_format_gen(fmt[3], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Scan_char_set */20,
                        fmt[1],
                        fmt[2],
                        match$33[1]
                      ],
                      match$33[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 21 : 
          if (typeof fmtty === "number") {
            exit = 293;
          }
          else {
            if (fmtty[0] === 2) {
              var match$34 = type_format_gen(fmt[2], fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Scan_get_counter */21,
                        fmt[1],
                        match$34[1]
                      ],
                      match$34[2]
                    ];
            }
            else {
              exit = 293;
            }
          }
          break;
      case 23 : 
          return type_ignored_param(fmt[1], fmt[2], fmtty);
      case 22 : 
      case 24 : 
          exit = 293;
          break;
      
    }
  }
  if (exit === 293) {
    throw Type_mismatch;
  }
  
}

function type_formatting_gen(formatting_gen, fmt0, fmtty0) {
  if (formatting_gen[0]) {
    var match = formatting_gen[1];
    var match$1 = type_format_gen(match[1], fmtty0);
    var match$2 = type_format_gen(fmt0, match$1[2]);
    return [
            /* Fmt_fmtty_EBB */0,
            [
              /* Formatting_gen */18,
              [
                /* Open_box */1,
                [
                  /* Format */0,
                  match$1[1],
                  match[2]
                ]
              ],
              match$2[1]
            ],
            match$2[2]
          ];
  }
  else {
    var match$3 = formatting_gen[1];
    var match$4 = type_format_gen(match$3[1], fmtty0);
    var match$5 = type_format_gen(fmt0, match$4[2]);
    return [
            /* Fmt_fmtty_EBB */0,
            [
              /* Formatting_gen */18,
              [
                /* Open_tag */0,
                [
                  /* Format */0,
                  match$4[1],
                  match$3[2]
                ]
              ],
              match$5[1]
            ],
            match$5[2]
          ];
  }
}

function type_ignored_param(ign, fmt, fmtty) {
  if (typeof ign === "number") {
    switch (ign) {
      case 3 : 
          if (typeof fmtty === "number") {
            throw Type_mismatch;
          }
          else {
            if (fmtty[0] === 14) {
              var match = type_format_gen(fmt, fmtty[1]);
              return [
                      /* Fmt_fmtty_EBB */0,
                      [
                        /* Ignored_param */23,
                        /* Ignored_reader */3,
                        match[1]
                      ],
                      match[2]
                    ];
            }
            else {
              throw Type_mismatch;
            }
          }
          break;
      case 0 : 
      case 1 : 
      case 2 : 
      case 4 : 
          return type_ignored_param_one(ign, fmt, fmtty);
      
    }
  }
  else {
    switch (ign[0]) {
      case 7 : 
          return type_ignored_param_one([
                      /* Ignored_format_arg */7,
                      ign[1],
                      ign[2]
                    ], fmt, fmtty);
      case 8 : 
          var match$1 = type_ignored_format_substitution(ign[2], fmt, fmtty);
          var match$2 = match$1[2];
          return [
                  /* Fmt_fmtty_EBB */0,
                  [
                    /* Ignored_param */23,
                    [
                      /* Ignored_format_subst */8,
                      ign[1],
                      match$1[1]
                    ],
                    match$2[1]
                  ],
                  match$2[2]
                ];
      case 0 : 
      case 1 : 
      case 2 : 
      case 3 : 
      case 4 : 
      case 5 : 
      case 6 : 
      case 9 : 
      case 10 : 
          return type_ignored_param_one(ign, fmt, fmtty);
      
    }
  }
}

function type_ignored_param_one(ign, fmt, fmtty) {
  var match = type_format_gen(fmt, fmtty);
  return [
          /* Fmt_fmtty_EBB */0,
          [
            /* Ignored_param */23,
            ign,
            match[1]
          ],
          match[2]
        ];
}

function type_ignored_format_substitution(sub_fmtty, fmt, fmtty) {
  /* initialize */var exit = 0;
  if (typeof sub_fmtty === "number") {
    return [
            /* Fmtty_fmt_EBB */0,
            /* End_of_fmtty */0,
            type_format_gen(fmt, fmtty)
          ];
  }
  else {
    switch (sub_fmtty[0]) {
      case 0 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0]) {
              exit = 297;
            }
            else {
              var match = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Char_ty */0,
                        match[1]
                      ],
                      match[2]
                    ];
            }
          }
          break;
      case 1 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 1) {
              var match$1 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* String_ty */1,
                        match$1[1]
                      ],
                      match$1[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 2 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 2) {
              var match$2 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Int_ty */2,
                        match$2[1]
                      ],
                      match$2[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 3 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 3) {
              var match$3 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Int32_ty */3,
                        match$3[1]
                      ],
                      match$3[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 4 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 4) {
              var match$4 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Nativeint_ty */4,
                        match$4[1]
                      ],
                      match$4[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 5 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 5) {
              var match$5 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Int64_ty */5,
                        match$5[1]
                      ],
                      match$5[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 6 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 6) {
              var match$6 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Float_ty */6,
                        match$6[1]
                      ],
                      match$6[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 7 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 7) {
              var match$7 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Bool_ty */7,
                        match$7[1]
                      ],
                      match$7[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 8 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 8) {
              var sub2_fmtty$prime = fmtty[1];
              if (Caml_primitive.caml_notequal([
                      /* Fmtty_EBB */0,
                      sub_fmtty[1]
                    ], [
                      /* Fmtty_EBB */0,
                      sub2_fmtty$prime
                    ])) {
                throw Type_mismatch;
              }
              var match$8 = type_ignored_format_substitution(sub_fmtty[2], fmt, fmtty[2]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Format_arg_ty */8,
                        sub2_fmtty$prime,
                        match$8[1]
                      ],
                      match$8[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 9 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 9) {
              var sub2_fmtty$prime$1 = fmtty[2];
              var sub1_fmtty$prime = fmtty[1];
              if (Caml_primitive.caml_notequal([
                      /* Fmtty_EBB */0,
                      CamlinternalFormatBasics.erase_rel(sub_fmtty[1])
                    ], [
                      /* Fmtty_EBB */0,
                      CamlinternalFormatBasics.erase_rel(sub1_fmtty$prime)
                    ])) {
                throw Type_mismatch;
              }
              if (Caml_primitive.caml_notequal([
                      /* Fmtty_EBB */0,
                      CamlinternalFormatBasics.erase_rel(sub_fmtty[2])
                    ], [
                      /* Fmtty_EBB */0,
                      CamlinternalFormatBasics.erase_rel(sub2_fmtty$prime$1)
                    ])) {
                throw Type_mismatch;
              }
              var sub_fmtty$prime = trans(symm(sub1_fmtty$prime), sub2_fmtty$prime$1);
              var match$9 = fmtty_rel_det(sub_fmtty$prime);
              match$9[2](/* Refl */0);
              match$9[4](/* Refl */0);
              var match$10 = type_ignored_format_substitution(CamlinternalFormatBasics.erase_rel(sub_fmtty[3]), fmt, fmtty[3]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Format_subst_ty */9,
                        sub1_fmtty$prime,
                        sub2_fmtty$prime$1,
                        symm(match$10[1])
                      ],
                      match$10[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 10 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 10) {
              var match$11 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Alpha_ty */10,
                        match$11[1]
                      ],
                      match$11[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 11 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 11) {
              var match$12 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Theta_ty */11,
                        match$12[1]
                      ],
                      match$12[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 12 : 
          exit = 297;
          break;
      case 13 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 13) {
              var match$13 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Reader_ty */13,
                        match$13[1]
                      ],
                      match$13[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      case 14 : 
          if (typeof fmtty === "number") {
            exit = 297;
          }
          else {
            if (fmtty[0] === 14) {
              var match$14 = type_ignored_format_substitution(sub_fmtty[1], fmt, fmtty[1]);
              return [
                      /* Fmtty_fmt_EBB */0,
                      [
                        /* Ignored_reader_ty */14,
                        match$14[1]
                      ],
                      match$14[2]
                    ];
            }
            else {
              exit = 297;
            }
          }
          break;
      
    }
  }
  if (exit === 297) {
    throw Type_mismatch;
  }
  
}

function recast(fmt, fmtty) {
  return type_format(fmt, CamlinternalFormatBasics.erase_rel(symm(fmtty)));
}

function fix_padding(padty, width, str) {
  var len = str.length;
  var match_001 = Pervasives.abs(width);
  var match_002 = width < 0 ? /* Left */0 : padty;
  var padty$1 = match_002;
  var width$1 = match_001;
  if (width$1 <= len) {
    return str;
  }
  else {
    var res = Bytes.make(width$1, padty$1 === /* Zeros */2 ? /* "0" */48 : /* " " */32);
    switch (padty$1) {
      case 0 : 
          $$String.blit(str, 0, res, 0, len);
          break;
      case 1 : 
          $$String.blit(str, 0, res, width$1 - len, len);
          break;
      case 2 : 
          if (len > 0 && (str[0] === "+" || str[0] === "-" || str[0] === " ")) {
            res[0] = str.charCodeAt(0);
            $$String.blit(str, 1, res, width$1 - len + 1, len - 1);
          }
          else {
            if (len > 1 && str[0] === "0" && (str[1] === "x" || str[1] === "X")) {
              res[1] = str.charCodeAt(1);
              $$String.blit(str, 2, res, width$1 - len + 2, len - 2);
            }
            else {
              $$String.blit(str, 0, res, width$1 - len, len);
            }
          }
          break;
      
    }
    return Bytes.unsafe_to_string(res);
  }
}

function fix_int_precision(prec, str) {
  var prec$1 = Pervasives.abs(prec);
  var len = str.length;
  var c = str.charCodeAt(0);
  /* initialize */var exit = 0;
  if (c >= 58) {
    if (c >= 71) {
      if (5 < (-97 + c >>> 0)) {
        return str;
      }
      else {
        exit = 276;
      }
    }
    else {
      if (c >= 65) {
        exit = 276;
      }
      else {
        return str;
      }
    }
  }
  else {
    if (c !== 32) {
      if (c >= 43) {
        switch (-43 + c) {
          case 0 : 
          case 2 : 
              exit = 275;
              break;
          case 1 : 
          case 3 : 
          case 4 : 
              return str;
          case 5 : 
              if (prec$1 + 2 > len && len > 1 && (str[1] === "x" || str[1] === "X")) {
                var res = Bytes.make(prec$1 + 2, /* "0" */48);
                res[1] = str.charCodeAt(1);
                $$String.blit(str, 2, res, prec$1 - len + 4, len - 2);
                return Bytes.unsafe_to_string(res);
              }
              else {
                exit = 276;
              }
              break;
          case 6 : 
          case 7 : 
          case 8 : 
          case 9 : 
          case 10 : 
          case 11 : 
          case 12 : 
          case 13 : 
          case 14 : 
              exit = 276;
              break;
          
        }
      }
      else {
        return str;
      }
    }
    else {
      exit = 275;
    }
  }
  switch (exit) {
    case 275 : 
        if (prec$1 + 1 > len) {
          var res$1 = Bytes.make(prec$1 + 1, /* "0" */48);
          res$1[0] = c;
          $$String.blit(str, 1, res$1, prec$1 - len + 2, len - 1);
          return Bytes.unsafe_to_string(res$1);
        }
        else {
          return str;
        }
        break;
    case 276 : 
        if (prec$1 > len) {
          var res$2 = Bytes.make(prec$1, /* "0" */48);
          $$String.blit(str, 0, res$2, prec$1 - len, len);
          return Bytes.unsafe_to_string(res$2);
        }
        else {
          return str;
        }
        break;
    
  }
}

function string_to_caml_string(str) {
  return $$String.concat($$String.escaped(str), [
              /* :: */0,
              '"',
              [
                /* :: */0,
                '"',
                /* [] */0
              ]
            ]);
}

function format_of_iconv(iconv) {
  switch (iconv) {
    case 0 : 
        return "%d";
    case 1 : 
        return "%+d";
    case 2 : 
        return "% d";
    case 3 : 
        return "%i";
    case 4 : 
        return "%+i";
    case 5 : 
        return "% i";
    case 6 : 
        return "%x";
    case 7 : 
        return "%#x";
    case 8 : 
        return "%X";
    case 9 : 
        return "%#X";
    case 10 : 
        return "%o";
    case 11 : 
        return "%#o";
    case 12 : 
        return "%u";
    
  }
}

function format_of_aconv(iconv, c) {
  var seps;
  switch (iconv) {
    case 0 : 
        seps = [
          /* :: */0,
          "%",
          [
            /* :: */0,
            "d",
            /* [] */0
          ]
        ];
        break;
    case 1 : 
        seps = [
          /* :: */0,
          "%+",
          [
            /* :: */0,
            "d",
            /* [] */0
          ]
        ];
        break;
    case 2 : 
        seps = [
          /* :: */0,
          "% ",
          [
            /* :: */0,
            "d",
            /* [] */0
          ]
        ];
        break;
    case 3 : 
        seps = [
          /* :: */0,
          "%",
          [
            /* :: */0,
            "i",
            /* [] */0
          ]
        ];
        break;
    case 4 : 
        seps = [
          /* :: */0,
          "%+",
          [
            /* :: */0,
            "i",
            /* [] */0
          ]
        ];
        break;
    case 5 : 
        seps = [
          /* :: */0,
          "% ",
          [
            /* :: */0,
            "i",
            /* [] */0
          ]
        ];
        break;
    case 6 : 
        seps = [
          /* :: */0,
          "%",
          [
            /* :: */0,
            "x",
            /* [] */0
          ]
        ];
        break;
    case 7 : 
        seps = [
          /* :: */0,
          "%#",
          [
            /* :: */0,
            "x",
            /* [] */0
          ]
        ];
        break;
    case 8 : 
        seps = [
          /* :: */0,
          "%",
          [
            /* :: */0,
            "X",
            /* [] */0
          ]
        ];
        break;
    case 9 : 
        seps = [
          /* :: */0,
          "%#",
          [
            /* :: */0,
            "X",
            /* [] */0
          ]
        ];
        break;
    case 10 : 
        seps = [
          /* :: */0,
          "%",
          [
            /* :: */0,
            "o",
            /* [] */0
          ]
        ];
        break;
    case 11 : 
        seps = [
          /* :: */0,
          "%#",
          [
            /* :: */0,
            "o",
            /* [] */0
          ]
        ];
        break;
    case 12 : 
        seps = [
          /* :: */0,
          "%",
          [
            /* :: */0,
            "u",
            /* [] */0
          ]
        ];
        break;
    
  }
  return $$String.concat($$String.make(1, c), seps);
}

function format_of_fconv(fconv, prec) {
  if (fconv === /* Float_F */15) {
    return "%.12g";
  }
  else {
    var prec$1 = Pervasives.abs(prec);
    var symb = char_of_fconv(fconv);
    var buf = buffer_create(16);
    buffer_add_char(buf, /* "%" */37);
    bprint_fconv_flag(buf, fconv);
    buffer_add_char(buf, /* "." */46);
    buffer_add_string(buf, Pervasives.string_of_int(prec$1));
    buffer_add_char(buf, symb);
    return buffer_contents(buf);
  }
}

function convert_int(iconv, n) {
  return Caml_format.caml_format_int(format_of_iconv(iconv), n);
}

function convert_int32(iconv, n) {
  return Caml_format.caml_int32_format(format_of_aconv(iconv, /* "l" */108), n);
}

function convert_nativeint(iconv, n) {
  return Caml_format.caml_nativeint_format(format_of_aconv(iconv, /* "n" */110), n);
}

function convert_int64(iconv, n) {
  return Caml_primitive.caml_int64_format(format_of_aconv(iconv, /* "L" */76), n);
}

function convert_float(fconv, prec, x) {
  var prec$1 = Pervasives.abs(prec);
  var str = Caml_format.caml_format_float(format_of_fconv(fconv, prec$1), x);
  if (fconv !== /* Float_F */15) {
    return str;
  }
  else {
    var len = str.length;
    var is_valid = function (_i) {
      while(/* true */1) {
        var i = _i;
        if (i === len) {
          return /* false */0;
        }
        else {
          var match = str.charCodeAt(i);
          var switcher = -46 + match;
          if (!(23 < (switcher >>> 0))) {
            if (21 < (-1 + switcher >>> 0)) {
              return /* true */1;
            }
            else {
              _i = i + 1;
            }
          }
          else {
            if (switcher !== 55) {
              _i = i + 1;
            }
            else {
              return /* true */1;
            }
          }
        }
      };
    };
    var match = Caml_float.caml_classify_float(x);
    return match !== 3 ? (
              match >= 4 ? "nan" : (
                  is_valid(0) ? str : str + "."
                )
            ) : (
              x < 0 ? "neg_infinity" : "infinity"
            );
  }
}

function format_caml_char(c) {
  return $$String.concat(Char.escaped(c), [
              /* :: */0,
              "'",
              [
                /* :: */0,
                "'",
                /* [] */0
              ]
            ]);
}

function string_of_fmtty(fmtty) {
  var buf = buffer_create(16);
  bprint_fmtty(buf, fmtty);
  return buffer_contents(buf);
}

function make_printf(_k, o, _acc, _fmt) {
  while(/* true */1) {
    var fmt = _fmt;
    var acc = _acc;
    var k = _k;
    if (typeof fmt === "number") {
      return k(o, acc);
    }
    else {
      switch (fmt[0]) {
        case 0 : 
            var rest = fmt[1];
            return (function(k,acc,rest){
            return function (c) {
              var new_acc = [
                /* Acc_data_char */5,
                acc,
                c
              ];
              return make_printf(k, o, new_acc, rest);
            }
            }(k,acc,rest));
        case 1 : 
            var rest$1 = fmt[1];
            return (function(k,acc,rest$1){
            return function (c) {
              var new_acc_002 = format_caml_char(c);
              var new_acc = [
                /* Acc_data_string */4,
                acc,
                new_acc_002
              ];
              return make_printf(k, o, new_acc, rest$1);
            }
            }(k,acc,rest$1));
        case 2 : 
            return make_string_padding(k, o, acc, fmt[2], fmt[1], function (str) {
                        return str;
                      });
        case 3 : 
            return make_string_padding(k, o, acc, fmt[2], fmt[1], string_to_caml_string);
        case 4 : 
            return make_int_padding_precision(k, o, acc, fmt[4], fmt[2], fmt[3], convert_int, fmt[1]);
        case 5 : 
            return make_int_padding_precision(k, o, acc, fmt[4], fmt[2], fmt[3], convert_int32, fmt[1]);
        case 6 : 
            return make_int_padding_precision(k, o, acc, fmt[4], fmt[2], fmt[3], convert_nativeint, fmt[1]);
        case 7 : 
            return make_int_padding_precision(k, o, acc, fmt[4], fmt[2], fmt[3], convert_int64, fmt[1]);
        case 8 : 
            return make_float_padding_precision(k, o, acc, fmt[4], fmt[2], fmt[3], fmt[1]);
        case 9 : 
            var rest$2 = fmt[1];
            return (function(k,acc,rest$2){
            return function (b) {
              return make_printf(k, o, [
                          /* Acc_data_string */4,
                          acc,
                          Pervasives.string_of_bool(b)
                        ], rest$2);
            }
            }(k,acc,rest$2));
        case 10 : 
            _fmt = fmt[1];
            _acc = [
              /* Acc_flush */7,
              acc
            ];
            break;
        case 11 : 
            _fmt = fmt[2];
            _acc = [
              /* Acc_string_literal */2,
              acc,
              fmt[1]
            ];
            break;
        case 12 : 
            _fmt = fmt[2];
            _acc = [
              /* Acc_char_literal */3,
              acc,
              fmt[1]
            ];
            break;
        case 13 : 
            var rest$3 = fmt[3];
            var ty = string_of_fmtty(fmt[2]);
            return (function(k,acc,rest$3,ty){
            return function () {
              return make_printf(k, o, [
                          /* Acc_data_string */4,
                          acc,
                          ty
                        ], rest$3);
            }
            }(k,acc,rest$3,ty));
        case 14 : 
            var rest$4 = fmt[3];
            var fmtty = fmt[2];
            return (function(k,acc,fmtty,rest$4){
            return function (param) {
              return make_printf(k, o, acc, CamlinternalFormatBasics.concat_fmt(recast(param[1], fmtty), rest$4));
            }
            }(k,acc,fmtty,rest$4));
        case 15 : 
            var rest$5 = fmt[1];
            return (function(k,acc,rest$5){
            return function (f, x) {
              return make_printf(k, o, [
                          /* Acc_delay */6,
                          acc,
                          function (o) {
                            return f(o, x);
                          }
                        ], rest$5);
            }
            }(k,acc,rest$5));
        case 16 : 
            var rest$6 = fmt[1];
            return (function(k,acc,rest$6){
            return function (f) {
              return make_printf(k, o, [
                          /* Acc_delay */6,
                          acc,
                          f
                        ], rest$6);
            }
            }(k,acc,rest$6));
        case 17 : 
            _fmt = fmt[2];
            _acc = [
              /* Acc_formatting_lit */0,
              acc,
              fmt[1]
            ];
            break;
        case 18 : 
            var match = fmt[1];
            if (match[0]) {
              var rest$7 = fmt[2];
              var k$prime = (function(k,acc,rest$7){
              return function (koc, kacc) {
                return make_printf(k, koc, [
                            /* Acc_formatting_gen */1,
                            acc,
                            [
                              /* Acc_open_box */1,
                              kacc
                            ]
                          ], rest$7);
              }
              }(k,acc,rest$7));
              _fmt = match[1][1];
              _acc = /* End_of_acc */0;
              _k = k$prime;
            }
            else {
              var rest$8 = fmt[2];
              var k$prime$1 = (function(k,acc,rest$8){
              return function (koc, kacc) {
                return make_printf(k, koc, [
                            /* Acc_formatting_gen */1,
                            acc,
                            [
                              /* Acc_open_tag */0,
                              kacc
                            ]
                          ], rest$8);
              }
              }(k,acc,rest$8));
              _fmt = match[1][1];
              _acc = /* End_of_acc */0;
              _k = k$prime$1;
            }
            break;
        case 19 : 
            throw [
                  0,
                  Caml_exceptions.Assert_failure,
                  [
                    0,
                    "camlinternalFormat.ml",
                    1449,
                    4
                  ]
                ];
        case 20 : 
            var rest$9 = fmt[3];
            var new_acc = [
              /* Acc_invalid_arg */8,
              acc,
              "Printf: bad conversion %["
            ];
            return (function(k,rest$9,new_acc){
            return function () {
              return make_printf(k, o, new_acc, rest$9);
            }
            }(k,rest$9,new_acc));
        case 21 : 
            var rest$10 = fmt[2];
            return (function(k,acc,rest$10){
            return function (n) {
              var new_acc_002 = Caml_format.caml_format_int("%u", n);
              var new_acc = [
                /* Acc_data_string */4,
                acc,
                new_acc_002
              ];
              return make_printf(k, o, new_acc, rest$10);
            }
            }(k,acc,rest$10));
        case 22 : 
            var rest$11 = fmt[1];
            return (function(k,acc,rest$11){
            return function (c) {
              var new_acc = [
                /* Acc_data_char */5,
                acc,
                c
              ];
              return make_printf(k, o, new_acc, rest$11);
            }
            }(k,acc,rest$11));
        case 23 : 
            return make_ignored_param(k, o, acc, fmt[1], fmt[2]);
        case 24 : 
            return make_custom(k, o, acc, fmt[3], fmt[1], fmt[2](/* () */0));
        
      }
    }
  };
}

function make_ignored_param(k, o, acc, ign, fmt) {
  if (typeof ign === "number") {
    switch (ign) {
      case 3 : 
          throw [
                0,
                Caml_exceptions.Assert_failure,
                [
                  0,
                  "camlinternalFormat.ml",
                  1517,
                  39
                ]
              ];
      case 0 : 
      case 1 : 
      case 2 : 
      case 4 : 
          return make_invalid_arg(k, o, acc, fmt);
      
    }
  }
  else {
    switch (ign[0]) {
      case 8 : 
          return make_from_fmtty(k, o, acc, ign[2], fmt);
      case 0 : 
      case 1 : 
      case 2 : 
      case 3 : 
      case 4 : 
      case 5 : 
      case 6 : 
      case 7 : 
      case 9 : 
      case 10 : 
          return make_invalid_arg(k, o, acc, fmt);
      
    }
  }
}

function make_from_fmtty(k, o, acc, fmtty, fmt) {
  if (typeof fmtty === "number") {
    return make_invalid_arg(k, o, acc, fmt);
  }
  else {
    switch (fmtty[0]) {
      case 0 : 
          var rest = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest, fmt);
          };
      case 1 : 
          var rest$1 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$1, fmt);
          };
      case 2 : 
          var rest$2 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$2, fmt);
          };
      case 3 : 
          var rest$3 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$3, fmt);
          };
      case 4 : 
          var rest$4 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$4, fmt);
          };
      case 5 : 
          var rest$5 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$5, fmt);
          };
      case 6 : 
          var rest$6 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$6, fmt);
          };
      case 7 : 
          var rest$7 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$7, fmt);
          };
      case 8 : 
          var rest$8 = fmtty[2];
          return function () {
            return make_from_fmtty(k, o, acc, rest$8, fmt);
          };
      case 9 : 
          var rest$9 = fmtty[3];
          var ty = trans(symm(fmtty[1]), fmtty[2]);
          return function () {
            return make_from_fmtty(k, o, acc, CamlinternalFormatBasics.concat_fmtty(ty, rest$9), fmt);
          };
      case 10 : 
          var rest$10 = fmtty[1];
          return function (_, _$1) {
            return make_from_fmtty(k, o, acc, rest$10, fmt);
          };
      case 11 : 
          var rest$11 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$11, fmt);
          };
      case 12 : 
          var rest$12 = fmtty[1];
          return function () {
            return make_from_fmtty(k, o, acc, rest$12, fmt);
          };
      case 13 : 
          throw [
                0,
                Caml_exceptions.Assert_failure,
                [
                  0,
                  "camlinternalFormat.ml",
                  1540,
                  31
                ]
              ];
      case 14 : 
          throw [
                0,
                Caml_exceptions.Assert_failure,
                [
                  0,
                  "camlinternalFormat.ml",
                  1541,
                  31
                ]
              ];
      
    }
  }
}

function make_invalid_arg(k, o, acc, fmt) {
  return make_printf(k, o, [
              /* Acc_invalid_arg */8,
              acc,
              "Printf: bad conversion %_"
            ], fmt);
}

function make_string_padding(k, o, acc, fmt, pad, trans) {
  if (typeof pad === "number") {
    return function (x) {
      var new_acc_002 = trans(x);
      var new_acc = [
        /* Acc_data_string */4,
        acc,
        new_acc_002
      ];
      return make_printf(k, o, new_acc, fmt);
    };
  }
  else {
    if (pad[0]) {
      var padty = pad[1];
      return function (w, x) {
        var new_acc_002 = fix_padding(padty, w, trans(x));
        var new_acc = [
          /* Acc_data_string */4,
          acc,
          new_acc_002
        ];
        return make_printf(k, o, new_acc, fmt);
      };
    }
    else {
      var width = pad[2];
      var padty$1 = pad[1];
      return function (x) {
        var new_acc_002 = fix_padding(padty$1, width, trans(x));
        var new_acc = [
          /* Acc_data_string */4,
          acc,
          new_acc_002
        ];
        return make_printf(k, o, new_acc, fmt);
      };
    }
  }
}

function make_int_padding_precision(k, o, acc, fmt, pad, prec, trans, iconv) {
  if (typeof pad === "number") {
    if (typeof prec === "number") {
      return prec !== 0 ? function (p, x) {
                var str = fix_int_precision(p, trans(iconv, x));
                return make_printf(k, o, [
                            /* Acc_data_string */4,
                            acc,
                            str
                          ], fmt);
              } : function (x) {
                var str = trans(iconv, x);
                return make_printf(k, o, [
                            /* Acc_data_string */4,
                            acc,
                            str
                          ], fmt);
              };
    }
    else {
      var p = prec[1];
      return function (x) {
        var str = fix_int_precision(p, trans(iconv, x));
        return make_printf(k, o, [
                    /* Acc_data_string */4,
                    acc,
                    str
                  ], fmt);
      };
    }
  }
  else {
    if (pad[0]) {
      var padty = pad[1];
      if (typeof prec === "number") {
        return prec !== 0 ? function (w, p, x) {
                  var str = fix_padding(padty, w, fix_int_precision(p, trans(iconv, x)));
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str
                            ], fmt);
                } : function (w, x) {
                  var str = fix_padding(padty, w, trans(iconv, x));
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str
                            ], fmt);
                };
      }
      else {
        var p$1 = prec[1];
        return function (w, x) {
          var str = fix_padding(padty, w, fix_int_precision(p$1, trans(iconv, x)));
          return make_printf(k, o, [
                      /* Acc_data_string */4,
                      acc,
                      str
                    ], fmt);
        };
      }
    }
    else {
      var w = pad[2];
      var padty$1 = pad[1];
      if (typeof prec === "number") {
        return prec !== 0 ? function (p, x) {
                  var str = fix_padding(padty$1, w, fix_int_precision(p, trans(iconv, x)));
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str
                            ], fmt);
                } : function (x) {
                  var str = fix_padding(padty$1, w, trans(iconv, x));
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str
                            ], fmt);
                };
      }
      else {
        var p$2 = prec[1];
        return function (x) {
          var str = fix_padding(padty$1, w, fix_int_precision(p$2, trans(iconv, x)));
          return make_printf(k, o, [
                      /* Acc_data_string */4,
                      acc,
                      str
                    ], fmt);
        };
      }
    }
  }
}

function make_float_padding_precision(k, o, acc, fmt, pad, prec, fconv) {
  if (typeof pad === "number") {
    if (typeof prec === "number") {
      return prec !== 0 ? function (p, x) {
                var str = convert_float(fconv, p, x);
                return make_printf(k, o, [
                            /* Acc_data_string */4,
                            acc,
                            str
                          ], fmt);
              } : function (x) {
                var str = convert_float(fconv, default_float_precision, x);
                return make_printf(k, o, [
                            /* Acc_data_string */4,
                            acc,
                            str
                          ], fmt);
              };
    }
    else {
      var p = prec[1];
      return function (x) {
        var str = convert_float(fconv, p, x);
        return make_printf(k, o, [
                    /* Acc_data_string */4,
                    acc,
                    str
                  ], fmt);
      };
    }
  }
  else {
    if (pad[0]) {
      var padty = pad[1];
      if (typeof prec === "number") {
        return prec !== 0 ? function (w, p, x) {
                  var str = fix_padding(padty, w, convert_float(fconv, p, x));
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str
                            ], fmt);
                } : function (w, x) {
                  var str = convert_float(fconv, default_float_precision, x);
                  var str$prime = fix_padding(padty, w, str);
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str$prime
                            ], fmt);
                };
      }
      else {
        var p$1 = prec[1];
        return function (w, x) {
          var str = fix_padding(padty, w, convert_float(fconv, p$1, x));
          return make_printf(k, o, [
                      /* Acc_data_string */4,
                      acc,
                      str
                    ], fmt);
        };
      }
    }
    else {
      var w = pad[2];
      var padty$1 = pad[1];
      if (typeof prec === "number") {
        return prec !== 0 ? function (p, x) {
                  var str = fix_padding(padty$1, w, convert_float(fconv, p, x));
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str
                            ], fmt);
                } : function (x) {
                  var str = convert_float(fconv, default_float_precision, x);
                  var str$prime = fix_padding(padty$1, w, str);
                  return make_printf(k, o, [
                              /* Acc_data_string */4,
                              acc,
                              str$prime
                            ], fmt);
                };
      }
      else {
        var p$2 = prec[1];
        return function (x) {
          var str = fix_padding(padty$1, w, convert_float(fconv, p$2, x));
          return make_printf(k, o, [
                      /* Acc_data_string */4,
                      acc,
                      str
                    ], fmt);
        };
      }
    }
  }
}

function make_custom(k, o, acc, rest, arity, f) {
  if (arity) {
    var arity$1 = arity[1];
    return function (x) {
      return make_custom(k, o, acc, rest, arity$1, f(x));
    };
  }
  else {
    return make_printf(k, o, [
                /* Acc_data_string */4,
                acc,
                f
              ], rest);
  }
}

function output_acc(o, _acc) {
  while(/* true */1) {
    var acc = _acc;
    /* initialize */var exit = 0;
    if (typeof acc === "number") {
      return /* () */0;
    }
    else {
      switch (acc[0]) {
        case 0 : 
            var s = string_of_formatting_lit(acc[2]);
            output_acc(o, acc[1]);
            return Pervasives.output_string(o, s);
        case 1 : 
            var match = acc[2];
            var p = acc[1];
            output_acc(o, p);
            if (match[0]) {
              Pervasives.output_string(o, "@[");
              _acc = match[1];
            }
            else {
              Pervasives.output_string(o, "@{");
              _acc = match[1];
            }
            break;
        case 2 : 
        case 4 : 
            exit = 215;
            break;
        case 3 : 
        case 5 : 
            exit = 216;
            break;
        case 6 : 
            output_acc(o, acc[1]);
            return acc[2](o);
        case 7 : 
            output_acc(o, acc[1]);
            return Pervasives.flush(o);
        case 8 : 
            output_acc(o, acc[1]);
            return Pervasives.invalid_arg(acc[2]);
        
      }
    }
    switch (exit) {
      case 215 : 
          output_acc(o, acc[1]);
          return Pervasives.output_string(o, acc[2]);
      case 216 : 
          output_acc(o, acc[1]);
          return Pervasives.output_char(o, acc[2]);
      
    }
  };
}

function bufput_acc(b, _acc) {
  while(/* true */1) {
    var acc = _acc;
    /* initialize */var exit = 0;
    if (typeof acc === "number") {
      return /* () */0;
    }
    else {
      switch (acc[0]) {
        case 0 : 
            var s = string_of_formatting_lit(acc[2]);
            bufput_acc(b, acc[1]);
            return Buffer.add_string(b, s);
        case 1 : 
            var match = acc[2];
            var p = acc[1];
            bufput_acc(b, p);
            if (match[0]) {
              Buffer.add_string(b, "@[");
              _acc = match[1];
            }
            else {
              Buffer.add_string(b, "@{");
              _acc = match[1];
            }
            break;
        case 2 : 
        case 4 : 
            exit = 210;
            break;
        case 3 : 
        case 5 : 
            exit = 211;
            break;
        case 6 : 
            bufput_acc(b, acc[1]);
            return acc[2](b);
        case 7 : 
            _acc = acc[1];
            break;
        case 8 : 
            bufput_acc(b, acc[1]);
            return Pervasives.invalid_arg(acc[2]);
        
      }
    }
    switch (exit) {
      case 210 : 
          bufput_acc(b, acc[1]);
          return Buffer.add_string(b, acc[2]);
      case 211 : 
          bufput_acc(b, acc[1]);
          return Buffer.add_char(b, acc[2]);
      
    }
  };
}

function strput_acc(b, _acc) {
  while(/* true */1) {
    var acc = _acc;
    /* initialize */var exit = 0;
    if (typeof acc === "number") {
      return /* () */0;
    }
    else {
      switch (acc[0]) {
        case 0 : 
            var s = string_of_formatting_lit(acc[2]);
            strput_acc(b, acc[1]);
            return Buffer.add_string(b, s);
        case 1 : 
            var match = acc[2];
            var p = acc[1];
            strput_acc(b, p);
            if (match[0]) {
              Buffer.add_string(b, "@[");
              _acc = match[1];
            }
            else {
              Buffer.add_string(b, "@{");
              _acc = match[1];
            }
            break;
        case 2 : 
        case 4 : 
            exit = 205;
            break;
        case 3 : 
        case 5 : 
            exit = 206;
            break;
        case 6 : 
            strput_acc(b, acc[1]);
            return Buffer.add_string(b, acc[2](/* () */0));
        case 7 : 
            _acc = acc[1];
            break;
        case 8 : 
            strput_acc(b, acc[1]);
            return Pervasives.invalid_arg(acc[2]);
        
      }
    }
    switch (exit) {
      case 205 : 
          strput_acc(b, acc[1]);
          return Buffer.add_string(b, acc[2]);
      case 206 : 
          strput_acc(b, acc[1]);
          return Buffer.add_char(b, acc[2]);
      
    }
  };
}

function failwith_message(param) {
  var buf = Buffer.create(256);
  var k = function (_, acc) {
    strput_acc(buf, acc);
    return Pervasives.failwith(Buffer.contents(buf));
  };
  return make_printf(k, /* () */0, /* End_of_acc */0, param[1]);
}

function open_box_of_string(str) {
  if (str === "") {
    return [
            /* tuple */0,
            0,
            /* Pp_box */4
          ];
  }
  else {
    var len = str.length;
    var invalid_box = function () {
      return failwith_message([
                    /* Format */0,
                    [
                      /* String_literal */11,
                      "invalid box description ",
                      [
                        /* Caml_string */3,
                        /* No_padding */0,
                        /* End_of_format */0
                      ]
                    ],
                    "invalid box description %S"
                  ])(str);
    };
    var parse_spaces = function (_i) {
      while(/* true */1) {
        var i = _i;
        if (i === len) {
          return i;
        }
        else {
          var match = str.charCodeAt(i);
          if (match !== 9) {
            if (match !== 32) {
              return i;
            }
            else {
              _i = i + 1;
            }
          }
          else {
            _i = i + 1;
          }
        }
      };
    };
    var parse_lword = function (_, _j) {
      while(/* true */1) {
        var j = _j;
        if (j === len) {
          return j;
        }
        else {
          var match = str.charCodeAt(j);
          if (25 < (-97 + match >>> 0)) {
            return j;
          }
          else {
            _j = j + 1;
          }
        }
      };
    };
    var parse_int = function (_, _j) {
      while(/* true */1) {
        var j = _j;
        if (j === len) {
          return j;
        }
        else {
          var match = str.charCodeAt(j);
          /* initialize */var exit = 0;
          if (match >= 48) {
            if (match >= 58) {
              return j;
            }
            else {
              exit = 194;
            }
          }
          else {
            if (match !== 45) {
              return j;
            }
            else {
              exit = 194;
            }
          }
          if (exit === 194) {
            _j = j + 1;
          }
          
        }
      };
    };
    var wstart = parse_spaces(0);
    var wend = parse_lword(wstart, wstart);
    var box_name = $$String.sub(str, wstart, wend - wstart);
    var nstart = parse_spaces(wend);
    var nend = parse_int(nstart, nstart);
    var indent;
    if (nstart === nend) {
      indent = 0;
    }
    else {
      try {
        indent = Caml_format.caml_int_of_string($$String.sub(str, nstart, nend - nstart));
      }
      catch (exn){
        if (exn[1] === Caml_exceptions.Failure) {
          indent = invalid_box(/* () */0);
        }
        else {
          throw exn;
        }
      }
    }
    var exp_end = parse_spaces(nend);
    if (exp_end !== len) {
      invalid_box(/* () */0);
    }
    var box_type;
    switch (box_name) {
      case "" : 
      case "b" : 
          box_type = /* Pp_box */4;
          break;
      case "h" : 
          box_type = /* Pp_hbox */0;
          break;
      case "hov" : 
          box_type = /* Pp_hovbox */3;
          break;
      case "hv" : 
          box_type = /* Pp_hvbox */2;
          break;
      case "v" : 
          box_type = /* Pp_vbox */1;
          break;
      default:
        box_type = invalid_box(/* () */0);
    }
    return [
            /* tuple */0,
            indent,
            box_type
          ];
  }
}

function make_padding_fmt_ebb(pad, fmt) {
  return typeof pad === "number" ? [
            /* Padding_fmt_EBB */0,
            /* No_padding */0,
            fmt
          ] : (
            pad[0] ? [
                /* Padding_fmt_EBB */0,
                [
                  /* Arg_padding */1,
                  pad[1]
                ],
                fmt
              ] : [
                /* Padding_fmt_EBB */0,
                [
                  /* Lit_padding */0,
                  pad[1],
                  pad[2]
                ],
                fmt
              ]
          );
}

function make_precision_fmt_ebb(prec, fmt) {
  return typeof prec === "number" ? (
            prec !== 0 ? [
                /* Precision_fmt_EBB */0,
                /* Arg_precision */1,
                fmt
              ] : [
                /* Precision_fmt_EBB */0,
                /* No_precision */0,
                fmt
              ]
          ) : [
            /* Precision_fmt_EBB */0,
            [
              /* Lit_precision */0,
              prec[1]
            ],
            fmt
          ];
}

function make_padprec_fmt_ebb(pad, prec, fmt) {
  var match = make_precision_fmt_ebb(prec, fmt);
  var fmt$prime = match[2];
  var prec$1 = match[1];
  return typeof pad === "number" ? [
            /* Padprec_fmt_EBB */0,
            /* No_padding */0,
            prec$1,
            fmt$prime
          ] : (
            pad[0] ? [
                /* Padprec_fmt_EBB */0,
                [
                  /* Arg_padding */1,
                  pad[1]
                ],
                prec$1,
                fmt$prime
              ] : [
                /* Padprec_fmt_EBB */0,
                [
                  /* Lit_padding */0,
                  pad[1],
                  pad[2]
                ],
                prec$1,
                fmt$prime
              ]
          );
}

function fmt_ebb_of_string(legacy_behavior, str) {
  var legacy_behavior$1 = legacy_behavior ? legacy_behavior[1] : /* true */1;
  var invalid_format_message = function (str_ind, msg) {
    return failwith_message([
                  /* Format */0,
                  [
                    /* String_literal */11,
                    "invalid format ",
                    [
                      /* Caml_string */3,
                      /* No_padding */0,
                      [
                        /* String_literal */11,
                        ": at character number ",
                        [
                          /* Int */4,
                          /* Int_d */0,
                          /* No_padding */0,
                          /* No_precision */0,
                          [
                            /* String_literal */11,
                            ", ",
                            [
                              /* String */2,
                              /* No_padding */0,
                              /* End_of_format */0
                            ]
                          ]
                        ]
                      ]
                    ]
                  ],
                  "invalid format %S: at character number %d, %s"
                ])(str, str_ind, msg);
  };
  var unexpected_end_of_format = function (end_ind) {
    return invalid_format_message(end_ind, "unexpected end of format");
  };
  var invalid_nonnull_char_width = function (str_ind) {
    return invalid_format_message(str_ind, "non-zero widths are unsupported for %c conversions");
  };
  var invalid_format_without = function (str_ind, c, s) {
    return failwith_message([
                  /* Format */0,
                  [
                    /* String_literal */11,
                    "invalid format ",
                    [
                      /* Caml_string */3,
                      /* No_padding */0,
                      [
                        /* String_literal */11,
                        ": at character number ",
                        [
                          /* Int */4,
                          /* Int_d */0,
                          /* No_padding */0,
                          /* No_precision */0,
                          [
                            /* String_literal */11,
                            ", '",
                            [
                              /* Char */0,
                              [
                                /* String_literal */11,
                                "' without ",
                                [
                                  /* String */2,
                                  /* No_padding */0,
                                  /* End_of_format */0
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ],
                  "invalid format %S: at character number %d, '%c' without %s"
                ])(str, str_ind, c, s);
  };
  var expected_character = function (str_ind, expected, read) {
    return failwith_message([
                  /* Format */0,
                  [
                    /* String_literal */11,
                    "invalid format ",
                    [
                      /* Caml_string */3,
                      /* No_padding */0,
                      [
                        /* String_literal */11,
                        ": at character number ",
                        [
                          /* Int */4,
                          /* Int_d */0,
                          /* No_padding */0,
                          /* No_precision */0,
                          [
                            /* String_literal */11,
                            ", ",
                            [
                              /* String */2,
                              /* No_padding */0,
                              [
                                /* String_literal */11,
                                " expected, read ",
                                [
                                  /* Caml_char */1,
                                  /* End_of_format */0
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ],
                  "invalid format %S: at character number %d, %s expected, read %C"
                ])(str, str_ind, expected, read);
  };
  var parse = function (beg_ind, end_ind) {
    return parse_literal(beg_ind, beg_ind, end_ind);
  };
  var parse_literal = function (lit_start, _str_ind, end_ind) {
    while(/* true */1) {
      var str_ind = _str_ind;
      if (str_ind === end_ind) {
        return add_literal(lit_start, str_ind, /* End_of_format */0);
      }
      else {
        var match = str.charCodeAt(str_ind);
        if (match !== 37) {
          if (match !== 64) {
            _str_ind = str_ind + 1;
          }
          else {
            var match$1 = parse_after_at(str_ind + 1, end_ind);
            return add_literal(lit_start, str_ind, match$1[1]);
          }
        }
        else {
          var match$2 = parse_format(str_ind, end_ind);
          return add_literal(lit_start, str_ind, match$2[1]);
        }
      }
    };
  };
  var parse_format = function (pct_ind, end_ind) {
    return parse_ign(pct_ind, pct_ind + 1, end_ind);
  };
  var parse_ign = function (pct_ind, str_ind, end_ind) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var match = str.charCodeAt(str_ind);
    return match !== 95 ? parse_flags(pct_ind, str_ind, end_ind, /* false */0) : parse_flags(pct_ind, str_ind + 1, end_ind, /* true */1);
  };
  var parse_flags = function (pct_ind, str_ind, end_ind, ign) {
    var zero = [
      0,
      /* false */0
    ];
    var minus = [
      0,
      /* false */0
    ];
    var plus = [
      0,
      /* false */0
    ];
    var space = [
      0,
      /* false */0
    ];
    var sharp = [
      0,
      /* false */0
    ];
    var set_flag = function (str_ind, flag) {
      if (flag[1] && !legacy_behavior$1) {
        failwith_message([
                /* Format */0,
                [
                  /* String_literal */11,
                  "invalid format ",
                  [
                    /* Caml_string */3,
                    /* No_padding */0,
                    [
                      /* String_literal */11,
                      ": at character number ",
                      [
                        /* Int */4,
                        /* Int_d */0,
                        /* No_padding */0,
                        /* No_precision */0,
                        [
                          /* String_literal */11,
                          ", duplicate flag ",
                          [
                            /* Caml_char */1,
                            /* End_of_format */0
                          ]
                        ]
                      ]
                    ]
                  ]
                ],
                "invalid format %S: at character number %d, duplicate flag %C"
              ])(str, str_ind, str.charCodeAt(str_ind));
      }
      flag[1] = /* true */1;
      return /* () */0;
    };
    var read_flags = function (_str_ind) {
      while(/* true */1) {
        var str_ind = _str_ind;
        if (str_ind === end_ind) {
          unexpected_end_of_format(end_ind);
        }
        var match = str.charCodeAt(str_ind);
        /* initialize */var exit = 0;
        var switcher = -32 + match;
        if (16 < (switcher >>> 0)) {
          exit = 7;
        }
        else {
          switch (switcher) {
            case 0 : 
                set_flag(str_ind, space);
                _str_ind = str_ind + 1;
                break;
            case 3 : 
                set_flag(str_ind, sharp);
                _str_ind = str_ind + 1;
                break;
            case 11 : 
                set_flag(str_ind, plus);
                _str_ind = str_ind + 1;
                break;
            case 13 : 
                set_flag(str_ind, minus);
                _str_ind = str_ind + 1;
                break;
            case 1 : 
            case 2 : 
            case 4 : 
            case 5 : 
            case 6 : 
            case 7 : 
            case 8 : 
            case 9 : 
            case 10 : 
            case 12 : 
            case 14 : 
            case 15 : 
                exit = 7;
                break;
            case 16 : 
                set_flag(str_ind, zero);
                _str_ind = str_ind + 1;
                break;
            
          }
        }
        if (exit === 7) {
          return parse_padding(pct_ind, str_ind, end_ind, zero[1], minus[1], plus[1], sharp[1], space[1], ign);
        }
        
      };
    };
    return read_flags(str_ind);
  };
  var parse_padding = function (pct_ind, str_ind, end_ind, zero, minus, plus, sharp, space, ign) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var padty = zero !== 0 ? (
        minus !== 0 ? (
            legacy_behavior$1 ? /* Left */0 : incompatible_flag(pct_ind, str_ind, /* "-" */45, "0")
          ) : /* Zeros */2
      ) : (
        minus !== 0 ? /* Left */0 : /* Right */1
      );
    var match = str.charCodeAt(str_ind);
    /* initialize */var exit = 0;
    if (match >= 48) {
      if (match >= 58) {
        exit = 16;
      }
      else {
        var match$1 = parse_positive(str_ind, end_ind, 0);
        return parse_after_padding(pct_ind, match$1[1], end_ind, minus, plus, sharp, space, ign, [
                    /* Lit_padding */0,
                    padty,
                    match$1[2]
                  ]);
      }
    }
    else {
      if (match !== 42) {
        exit = 16;
      }
      else {
        return parse_after_padding(pct_ind, str_ind + 1, end_ind, minus, plus, sharp, space, ign, [
                    /* Arg_padding */1,
                    padty
                  ]);
      }
    }
    if (exit === 16) {
      switch (padty) {
        case 0 : 
            if (!legacy_behavior$1) {
              invalid_format_without(str_ind - 1, /* "-" */45, "padding");
            }
            return parse_after_padding(pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, /* No_padding */0);
        case 1 : 
            return parse_after_padding(pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, /* No_padding */0);
        case 2 : 
            return parse_after_padding(pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, [
                        /* Lit_padding */0,
                        /* Right */1,
                        0
                      ]);
        
      }
    }
    
  };
  var parse_after_padding = function (pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, pad) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var symb = str.charCodeAt(str_ind);
    return symb !== 46 ? parse_conversion(pct_ind, str_ind + 1, end_ind, plus, sharp, space, ign, pad, /* No_precision */0, pad, symb) : parse_precision(pct_ind, str_ind + 1, end_ind, minus, plus, sharp, space, ign, pad);
  };
  var parse_precision = function (pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, pad) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var parse_literal = function (minus, str_ind) {
      var match = parse_positive(str_ind, end_ind, 0);
      return parse_after_precision(pct_ind, match[1], end_ind, minus, plus, sharp, space, ign, pad, [
                  /* Lit_precision */0,
                  match[2]
                ]);
    };
    var symb = str.charCodeAt(str_ind);
    /* initialize */var exit = 0;
    if (symb >= 48) {
      if (symb >= 58) {
        exit = 19;
      }
      else {
        return parse_literal(minus, str_ind);
      }
    }
    else {
      if (symb >= 42) {
        switch (-42 + symb) {
          case 0 : 
              return parse_after_precision(pct_ind, str_ind + 1, end_ind, minus, plus, sharp, space, ign, pad, /* Arg_precision */1);
          case 1 : 
          case 3 : 
              exit = 21;
              break;
          case 2 : 
          case 4 : 
          case 5 : 
              exit = 19;
              break;
          
        }
      }
      else {
        exit = 19;
      }
    }
    switch (exit) {
      case 21 : 
          if (legacy_behavior$1) {
            return parse_literal(+(minus || symb === /* "-" */45), str_ind + 1);
          }
          else {
            exit = 19;
          }
          break;
      case 19 : 
          return legacy_behavior$1 ? parse_after_precision(pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, pad, [
                        /* Lit_precision */0,
                        0
                      ]) : invalid_format_without(str_ind - 1, /* "." */46, "precision");
      
    }
  };
  var parse_after_precision = function (pct_ind, str_ind, end_ind, minus, plus, sharp, space, ign, pad, prec) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var parse_conv = function (padprec) {
      return parse_conversion(pct_ind, str_ind + 1, end_ind, plus, sharp, space, ign, pad, prec, padprec, str.charCodeAt(str_ind));
    };
    if (typeof pad === "number") {
      /* initialize */var exit = 0;
      if (typeof prec === "number") {
        if (prec !== 0) {
          exit = 24;
        }
        else {
          return parse_conv(/* No_padding */0);
        }
      }
      else {
        exit = 24;
      }
      if (exit === 24) {
        return minus !== 0 ? (
                  typeof prec === "number" ? parse_conv([
                          /* Arg_padding */1,
                          /* Left */0
                        ]) : parse_conv([
                          /* Lit_padding */0,
                          /* Left */0,
                          prec[1]
                        ])
                ) : (
                  typeof prec === "number" ? parse_conv([
                          /* Arg_padding */1,
                          /* Right */1
                        ]) : parse_conv([
                          /* Lit_padding */0,
                          /* Right */1,
                          prec[1]
                        ])
                );
      }
      
    }
    else {
      return parse_conv(pad);
    }
  };
  var parse_conversion = function (pct_ind, str_ind, end_ind, plus, sharp, space, ign, pad, prec, padprec, symb) {
    var plus_used = [
      0,
      /* false */0
    ];
    var sharp_used = [
      0,
      /* false */0
    ];
    var space_used = [
      0,
      /* false */0
    ];
    var ign_used = [
      0,
      /* false */0
    ];
    var pad_used = [
      0,
      /* false */0
    ];
    var prec_used = [
      0,
      /* false */0
    ];
    var get_plus = function () {
      plus_used[1] = /* true */1;
      return plus;
    };
    var get_sharp = function () {
      sharp_used[1] = /* true */1;
      return sharp;
    };
    var get_space = function () {
      space_used[1] = /* true */1;
      return space;
    };
    var get_ign = function () {
      ign_used[1] = /* true */1;
      return ign;
    };
    var get_pad = function () {
      pad_used[1] = /* true */1;
      return pad;
    };
    var get_prec = function () {
      prec_used[1] = /* true */1;
      return prec;
    };
    var get_padprec = function () {
      pad_used[1] = /* true */1;
      return padprec;
    };
    var check_no_0 = function (symb, pad) {
      return typeof pad === "number" ? pad : (
                pad[0] ? (
                    pad[1] >= 2 ? (
                        legacy_behavior$1 ? [
                            /* Arg_padding */1,
                            /* Right */1
                          ] : incompatible_flag(pct_ind, str_ind, symb, "0")
                      ) : pad
                  ) : (
                    pad[1] >= 2 ? (
                        legacy_behavior$1 ? [
                            /* Lit_padding */0,
                            /* Right */1,
                            pad[2]
                          ] : incompatible_flag(pct_ind, str_ind, symb, "0")
                      ) : pad
                  )
              );
    };
    var opt_of_pad = function (c, pad) {
      if (typeof pad === "number") {
        return /* None */0;
      }
      else {
        if (pad[0]) {
          return incompatible_flag(pct_ind, str_ind, c, "'*'");
        }
        else {
          switch (pad[1]) {
            case 0 : 
                return legacy_behavior$1 ? [
                          /* Some */0,
                          pad[2]
                        ] : incompatible_flag(pct_ind, str_ind, c, "'-'");
            case 1 : 
                return [
                        /* Some */0,
                        pad[2]
                      ];
            case 2 : 
                return legacy_behavior$1 ? [
                          /* Some */0,
                          pad[2]
                        ] : incompatible_flag(pct_ind, str_ind, c, "'0'");
            
          }
        }
      }
    };
    var get_pad_opt = function (c) {
      return opt_of_pad(c, get_pad(/* () */0));
    };
    var get_padprec_opt = function (c) {
      return opt_of_pad(c, get_padprec(/* () */0));
    };
    var get_prec_opt = function () {
      var match = get_prec(/* () */0);
      return typeof match === "number" ? (
                match !== 0 ? incompatible_flag(pct_ind, str_ind, /* "_" */95, "'*'") : /* None */0
              ) : [
                /* Some */0,
                match[1]
              ];
    };
    var fmt_result;
    /* initialize */var exit = 0;
    if (symb >= 124) {
      exit = 63;
    }
    else {
      switch (symb) {
        case 33 : 
            var match = parse(str_ind, end_ind);
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Flush */10,
                match[1]
              ]
            ];
            break;
        case 40 : 
            var sub_end = search_subformat_end(str_ind, end_ind, /* ")" */41);
            var match$1 = parse(sub_end + 2, end_ind);
            var fmt_rest = match$1[1];
            var match$2 = parse(str_ind, sub_end);
            var sub_fmtty = fmtty_of_fmt(match$2[1]);
            if (get_ign(/* () */0)) {
              var ignored_001 = get_pad_opt(/* "_" */95);
              var ignored = [
                /* Ignored_format_subst */8,
                ignored_001,
                sub_fmtty
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored,
                  fmt_rest
                ]
              ];
            }
            else {
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Format_subst */14,
                  get_pad_opt(/* "(" */40),
                  sub_fmtty,
                  fmt_rest
                ]
              ];
            }
            break;
        case 44 : 
            fmt_result = parse(str_ind, end_ind);
            break;
        case 37 : 
        case 64 : 
            exit = 68;
            break;
        case 67 : 
            var match$3 = parse(str_ind, end_ind);
            var fmt_rest$1 = match$3[1];
            fmt_result = get_ign(/* () */0) ? [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  /* Ignored_caml_char */1,
                  fmt_rest$1
                ]
              ] : [
                /* Fmt_EBB */0,
                [
                  /* Caml_char */1,
                  fmt_rest$1
                ]
              ];
            break;
        case 78 : 
            var match$4 = parse(str_ind, end_ind);
            var fmt_rest$2 = match$4[1];
            var counter = /* Token_counter */2;
            if (get_ign(/* () */0)) {
              var ignored$1 = [
                /* Ignored_scan_get_counter */10,
                counter
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored$1,
                  fmt_rest$2
                ]
              ];
            }
            else {
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Scan_get_counter */21,
                  counter,
                  fmt_rest$2
                ]
              ];
            }
            break;
        case 83 : 
            var pad$1 = check_no_0(symb, get_padprec(/* () */0));
            var match$5 = parse(str_ind, end_ind);
            var fmt_rest$3 = match$5[1];
            if (get_ign(/* () */0)) {
              var ignored_001$1 = get_padprec_opt(/* "_" */95);
              var ignored$2 = [
                /* Ignored_caml_string */1,
                ignored_001$1
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored$2,
                  fmt_rest$3
                ]
              ];
            }
            else {
              var match$6 = make_padding_fmt_ebb(pad$1, fmt_rest$3);
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Caml_string */3,
                  match$6[1],
                  match$6[2]
                ]
              ];
            }
            break;
        case 91 : 
            var match$7 = parse_char_set(str_ind, end_ind);
            var char_set = match$7[2];
            var match$8 = parse(match$7[1], end_ind);
            var fmt_rest$4 = match$8[1];
            if (get_ign(/* () */0)) {
              var ignored_001$2 = get_pad_opt(/* "_" */95);
              var ignored$3 = [
                /* Ignored_scan_char_set */9,
                ignored_001$2,
                char_set
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored$3,
                  fmt_rest$4
                ]
              ];
            }
            else {
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Scan_char_set */20,
                  get_pad_opt(/* "[" */91),
                  char_set,
                  fmt_rest$4
                ]
              ];
            }
            break;
        case 32 : 
        case 35 : 
        case 43 : 
        case 45 : 
        case 95 : 
            exit = 69;
            break;
        case 97 : 
            var match$9 = parse(str_ind, end_ind);
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Alpha */15,
                match$9[1]
              ]
            ];
            break;
        case 66 : 
        case 98 : 
            exit = 67;
            break;
        case 99 : 
            var char_format = function (fmt_rest) {
              return get_ign(/* () */0) ? [
                        /* Fmt_EBB */0,
                        [
                          /* Ignored_param */23,
                          /* Ignored_char */0,
                          fmt_rest
                        ]
                      ] : [
                        /* Fmt_EBB */0,
                        [
                          /* Char */0,
                          fmt_rest
                        ]
                      ];
            };
            var scan_format = function (fmt_rest) {
              return get_ign(/* () */0) ? [
                        /* Fmt_EBB */0,
                        [
                          /* Ignored_param */23,
                          /* Ignored_scan_next_char */4,
                          fmt_rest
                        ]
                      ] : [
                        /* Fmt_EBB */0,
                        [
                          /* Scan_next_char */22,
                          fmt_rest
                        ]
                      ];
            };
            var match$10 = parse(str_ind, end_ind);
            var fmt_rest$5 = match$10[1];
            var match$11 = get_pad_opt(/* "c" */99);
            fmt_result = match$11 ? (
                match$11[1] !== 0 ? (
                    !legacy_behavior$1 ? invalid_nonnull_char_width(str_ind) : char_format(fmt_rest$5)
                  ) : scan_format(fmt_rest$5)
              ) : char_format(fmt_rest$5);
            break;
        case 69 : 
        case 70 : 
        case 71 : 
        case 101 : 
        case 102 : 
        case 103 : 
            exit = 66;
            break;
        case 76 : 
        case 108 : 
        case 110 : 
            exit = 65;
            break;
        case 114 : 
            var match$12 = parse(str_ind, end_ind);
            var fmt_rest$6 = match$12[1];
            fmt_result = get_ign(/* () */0) ? [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  /* Ignored_reader */3,
                  fmt_rest$6
                ]
              ] : [
                /* Fmt_EBB */0,
                [
                  /* Reader */19,
                  fmt_rest$6
                ]
              ];
            break;
        case 115 : 
            var pad$2 = check_no_0(symb, get_padprec(/* () */0));
            var match$13 = parse(str_ind, end_ind);
            var fmt_rest$7 = match$13[1];
            if (get_ign(/* () */0)) {
              var ignored_001$3 = get_padprec_opt(/* "_" */95);
              var ignored$4 = [
                /* Ignored_string */0,
                ignored_001$3
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored$4,
                  fmt_rest$7
                ]
              ];
            }
            else {
              var match$14 = make_padding_fmt_ebb(pad$2, fmt_rest$7);
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* String */2,
                  match$14[1],
                  match$14[2]
                ]
              ];
            }
            break;
        case 116 : 
            var match$15 = parse(str_ind, end_ind);
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Theta */16,
                match$15[1]
              ]
            ];
            break;
        case 88 : 
        case 100 : 
        case 105 : 
        case 111 : 
        case 117 : 
        case 120 : 
            exit = 64;
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
        case 9 : 
        case 10 : 
        case 11 : 
        case 12 : 
        case 13 : 
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
        case 26 : 
        case 27 : 
        case 28 : 
        case 29 : 
        case 30 : 
        case 31 : 
        case 34 : 
        case 36 : 
        case 38 : 
        case 39 : 
        case 41 : 
        case 42 : 
        case 46 : 
        case 47 : 
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
        case 58 : 
        case 59 : 
        case 60 : 
        case 61 : 
        case 62 : 
        case 63 : 
        case 65 : 
        case 68 : 
        case 72 : 
        case 73 : 
        case 74 : 
        case 75 : 
        case 77 : 
        case 79 : 
        case 80 : 
        case 81 : 
        case 82 : 
        case 84 : 
        case 85 : 
        case 86 : 
        case 87 : 
        case 89 : 
        case 90 : 
        case 92 : 
        case 93 : 
        case 94 : 
        case 96 : 
        case 104 : 
        case 106 : 
        case 107 : 
        case 109 : 
        case 112 : 
        case 113 : 
        case 118 : 
        case 119 : 
        case 121 : 
        case 122 : 
            exit = 63;
            break;
        case 123 : 
            var sub_end$1 = search_subformat_end(str_ind, end_ind, /* "}" */125);
            var match$16 = parse(str_ind, sub_end$1);
            var match$17 = parse(sub_end$1 + 2, end_ind);
            var fmt_rest$8 = match$17[1];
            var sub_fmtty$1 = fmtty_of_fmt(match$16[1]);
            if (get_ign(/* () */0)) {
              var ignored_001$4 = get_pad_opt(/* "_" */95);
              var ignored$5 = [
                /* Ignored_format_arg */7,
                ignored_001$4,
                sub_fmtty$1
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored$5,
                  fmt_rest$8
                ]
              ];
            }
            else {
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Format_arg */13,
                  get_pad_opt(/* "{" */123),
                  sub_fmtty$1,
                  fmt_rest$8
                ]
              ];
            }
            break;
        
      }
    }
    switch (exit) {
      case 64 : 
          var iconv = compute_int_conv(pct_ind, str_ind, get_plus(/* () */0), get_sharp(/* () */0), get_space(/* () */0), symb);
          var match$18 = parse(str_ind, end_ind);
          var fmt_rest$9 = match$18[1];
          if (get_ign(/* () */0)) {
            var ignored_002 = get_pad_opt(/* "_" */95);
            var ignored$6 = [
              /* Ignored_int */2,
              iconv,
              ignored_002
            ];
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Ignored_param */23,
                ignored$6,
                fmt_rest$9
              ]
            ];
          }
          else {
            var match$19 = get_pad(/* () */0);
            var match$20 = get_prec(/* () */0);
            var pad$3;
            /* initialize */var exit$1 = 0;
            typeof match$20 === "number" ? (
                match$20 !== 0 ? (exit$1 = 36) : (pad$3 = match$19)
              ) : (exit$1 = 36);
            if (exit$1 === 36) {
              pad$3 = typeof match$19 === "number" ? /* No_padding */0 : (
                  match$19[0] ? (
                      match$19[1] >= 2 ? (
                          legacy_behavior$1 ? [
                              /* Arg_padding */1,
                              /* Right */1
                            ] : incompatible_flag(pct_ind, str_ind, /* "0" */48, "precision")
                        ) : match$19
                    ) : (
                      match$19[1] >= 2 ? (
                          legacy_behavior$1 ? [
                              /* Lit_padding */0,
                              /* Right */1,
                              match$19[2]
                            ] : incompatible_flag(pct_ind, str_ind, /* "0" */48, "precision")
                        ) : match$19
                    )
                );
            }
            var match$21 = make_padprec_fmt_ebb(pad$3, get_prec(/* () */0), fmt_rest$9);
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Int */4,
                iconv,
                match$21[1],
                match$21[2],
                match$21[3]
              ]
            ];
          }
          break;
      case 65 : 
          if (str_ind === end_ind || !is_int_base(str.charCodeAt(str_ind))) {
            var match$22 = parse(str_ind, end_ind);
            var fmt_rest$10 = match$22[1];
            var counter$1 = counter_of_char(symb);
            if (get_ign(/* () */0)) {
              var ignored$7 = [
                /* Ignored_scan_get_counter */10,
                counter$1
              ];
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Ignored_param */23,
                  ignored$7,
                  fmt_rest$10
                ]
              ];
            }
            else {
              fmt_result = [
                /* Fmt_EBB */0,
                [
                  /* Scan_get_counter */21,
                  counter$1,
                  fmt_rest$10
                ]
              ];
            }
          }
          else {
            exit = 63;
          }
          break;
      case 66 : 
          var fconv = compute_float_conv(pct_ind, str_ind, get_plus(/* () */0), get_space(/* () */0), symb);
          var match$23 = parse(str_ind, end_ind);
          var fmt_rest$11 = match$23[1];
          if (get_ign(/* () */0)) {
            var ignored_001$5 = get_pad_opt(/* "_" */95);
            var ignored_002$1 = get_prec_opt(/* () */0);
            var ignored$8 = [
              /* Ignored_float */6,
              ignored_001$5,
              ignored_002$1
            ];
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Ignored_param */23,
                ignored$8,
                fmt_rest$11
              ]
            ];
          }
          else {
            var match$24 = make_padprec_fmt_ebb(get_pad(/* () */0), get_prec(/* () */0), fmt_rest$11);
            fmt_result = [
              /* Fmt_EBB */0,
              [
                /* Float */8,
                fconv,
                match$24[1],
                match$24[2],
                match$24[3]
              ]
            ];
          }
          break;
      case 67 : 
          var match$25 = parse(str_ind, end_ind);
          var fmt_rest$12 = match$25[1];
          fmt_result = get_ign(/* () */0) ? [
              /* Fmt_EBB */0,
              [
                /* Ignored_param */23,
                /* Ignored_bool */2,
                fmt_rest$12
              ]
            ] : [
              /* Fmt_EBB */0,
              [
                /* Bool */9,
                fmt_rest$12
              ]
            ];
          break;
      case 68 : 
          var match$26 = parse(str_ind, end_ind);
          fmt_result = [
            /* Fmt_EBB */0,
            [
              /* Char_literal */12,
              symb,
              match$26[1]
            ]
          ];
          break;
      case 69 : 
          fmt_result = failwith_message([
                  /* Format */0,
                  [
                    /* String_literal */11,
                    "invalid format ",
                    [
                      /* Caml_string */3,
                      /* No_padding */0,
                      [
                        /* String_literal */11,
                        ": at character number ",
                        [
                          /* Int */4,
                          /* Int_d */0,
                          /* No_padding */0,
                          /* No_precision */0,
                          [
                            /* String_literal */11,
                            ", flag ",
                            [
                              /* Caml_char */1,
                              [
                                /* String_literal */11,
                                " is only allowed after the '",
                                [
                                  /* Char_literal */12,
                                  /* "%" */37,
                                  [
                                    /* String_literal */11,
                                    "', before padding and precision",
                                    /* End_of_format */0
                                  ]
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ],
                  "invalid format %S: at character number %d, flag %C is only allowed after the '%%', before padding and precision"
                ])(str, pct_ind, symb);
          break;
      case 63 : 
          if (symb >= 108) {
            if (symb >= 111) {
              exit = 62;
            }
            else {
              switch (-108 + symb) {
                case 0 : 
                    var iconv$1 = compute_int_conv(pct_ind, str_ind + 1, get_plus(/* () */0), get_sharp(/* () */0), get_space(/* () */0), str.charCodeAt(str_ind));
                    var match$27 = parse(str_ind + 1, end_ind);
                    var fmt_rest$13 = match$27[1];
                    if (get_ign(/* () */0)) {
                      var ignored_002$2 = get_pad_opt(/* "_" */95);
                      var ignored$9 = [
                        /* Ignored_int32 */3,
                        iconv$1,
                        ignored_002$2
                      ];
                      fmt_result = [
                        /* Fmt_EBB */0,
                        [
                          /* Ignored_param */23,
                          ignored$9,
                          fmt_rest$13
                        ]
                      ];
                    }
                    else {
                      var match$28 = make_padprec_fmt_ebb(get_pad(/* () */0), get_prec(/* () */0), fmt_rest$13);
                      fmt_result = [
                        /* Fmt_EBB */0,
                        [
                          /* Int32 */5,
                          iconv$1,
                          match$28[1],
                          match$28[2],
                          match$28[3]
                        ]
                      ];
                    }
                    break;
                case 1 : 
                    exit = 62;
                    break;
                case 2 : 
                    var iconv$2 = compute_int_conv(pct_ind, str_ind + 1, get_plus(/* () */0), get_sharp(/* () */0), get_space(/* () */0), str.charCodeAt(str_ind));
                    var match$29 = parse(str_ind + 1, end_ind);
                    var fmt_rest$14 = match$29[1];
                    if (get_ign(/* () */0)) {
                      var ignored_002$3 = get_pad_opt(/* "_" */95);
                      var ignored$10 = [
                        /* Ignored_nativeint */4,
                        iconv$2,
                        ignored_002$3
                      ];
                      fmt_result = [
                        /* Fmt_EBB */0,
                        [
                          /* Ignored_param */23,
                          ignored$10,
                          fmt_rest$14
                        ]
                      ];
                    }
                    else {
                      var match$30 = make_padprec_fmt_ebb(get_pad(/* () */0), get_prec(/* () */0), fmt_rest$14);
                      fmt_result = [
                        /* Fmt_EBB */0,
                        [
                          /* Nativeint */6,
                          iconv$2,
                          match$30[1],
                          match$30[2],
                          match$30[3]
                        ]
                      ];
                    }
                    break;
                
              }
            }
          }
          else {
            if (symb !== 76) {
              exit = 62;
            }
            else {
              var iconv$3 = compute_int_conv(pct_ind, str_ind + 1, get_plus(/* () */0), get_sharp(/* () */0), get_space(/* () */0), str.charCodeAt(str_ind));
              var match$31 = parse(str_ind + 1, end_ind);
              var fmt_rest$15 = match$31[1];
              if (get_ign(/* () */0)) {
                var ignored_002$4 = get_pad_opt(/* "_" */95);
                var ignored$11 = [
                  /* Ignored_int64 */5,
                  iconv$3,
                  ignored_002$4
                ];
                fmt_result = [
                  /* Fmt_EBB */0,
                  [
                    /* Ignored_param */23,
                    ignored$11,
                    fmt_rest$15
                  ]
                ];
              }
              else {
                var match$32 = make_padprec_fmt_ebb(get_pad(/* () */0), get_prec(/* () */0), fmt_rest$15);
                fmt_result = [
                  /* Fmt_EBB */0,
                  [
                    /* Int64 */7,
                    iconv$3,
                    match$32[1],
                    match$32[2],
                    match$32[3]
                  ]
                ];
              }
            }
          }
          break;
      case 62 : 
          fmt_result = failwith_message([
                  /* Format */0,
                  [
                    /* String_literal */11,
                    "invalid format ",
                    [
                      /* Caml_string */3,
                      /* No_padding */0,
                      [
                        /* String_literal */11,
                        ": at character number ",
                        [
                          /* Int */4,
                          /* Int_d */0,
                          /* No_padding */0,
                          /* No_precision */0,
                          [
                            /* String_literal */11,
                            ', invalid conversion "',
                            [
                              /* Char_literal */12,
                              /* "%" */37,
                              [
                                /* Char */0,
                                [
                                  /* Char_literal */12,
                                  /* "\"" */34,
                                  /* End_of_format */0
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ],
                  'invalid format %S: at character number %d, invalid conversion "%%%c"'
                ])(str, str_ind - 1, symb);
          break;
      
    }
    if (!legacy_behavior$1) {
      if (!plus_used[1] && plus) {
        incompatible_flag(pct_ind, str_ind, symb, "'+'");
      }
      if (!sharp_used[1] && sharp) {
        incompatible_flag(pct_ind, str_ind, symb, "'#'");
      }
      if (!space_used[1] && space) {
        incompatible_flag(pct_ind, str_ind, symb, "' '");
      }
      if (!pad_used[1] && Caml_primitive.caml_notequal([
              /* Padding_EBB */0,
              pad
            ], [
              /* Padding_EBB */0,
              /* No_padding */0
            ])) {
        incompatible_flag(pct_ind, str_ind, symb, "`padding'");
      }
      if (!prec_used[1] && Caml_primitive.caml_notequal([
              /* Precision_EBB */0,
              prec
            ], [
              /* Precision_EBB */0,
              /* No_precision */0
            ])) {
        incompatible_flag(pct_ind, str_ind, ign ? /* "_" */95 : symb, "`precision'");
      }
      if (ign && plus) {
        incompatible_flag(pct_ind, str_ind, /* "_" */95, "'+'");
      }
      
    }
    if (!ign_used[1] && ign) {
      /* initialize */var exit$2 = 0;
      exit$2 = symb >= 38 ? (
          symb !== 44 ? (
              symb !== 64 ? 27 : 28
            ) : 28
        ) : (
          symb !== 33 ? (
              symb >= 37 ? 28 : 27
            ) : 28
        );
      switch (exit$2) {
        case 28 : 
            if (!legacy_behavior$1) {
              exit$2 = 27;
            }
            break;
        case 27 : 
            incompatible_flag(pct_ind, str_ind, symb, "'_'");
            break;
        
      }
    }
    return fmt_result;
  };
  var parse_after_at = function (str_ind, end_ind) {
    if (str_ind === end_ind) {
      return [
              /* Fmt_EBB */0,
              [
                /* Char_literal */12,
                /* "@" */64,
                /* End_of_format */0
              ]
            ];
    }
    else {
      var c = str.charCodeAt(str_ind);
      /* initialize */var exit = 0;
      if (c >= 65) {
        if (c >= 94) {
          var switcher = -123 + c;
          if (2 < (switcher >>> 0)) {
            exit = 91;
          }
          else {
            switch (switcher) {
              case 0 : 
                  return parse_tag(/* true */1, str_ind + 1, end_ind);
              case 1 : 
                  exit = 91;
                  break;
              case 2 : 
                  var match = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            /* Close_tag */1,
                            match[1]
                          ]
                        ];
              
            }
          }
        }
        else {
          if (c >= 91) {
            switch (-91 + c) {
              case 0 : 
                  return parse_tag(/* false */0, str_ind + 1, end_ind);
              case 1 : 
                  exit = 91;
                  break;
              case 2 : 
                  var match$1 = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            /* Close_box */0,
                            match$1[1]
                          ]
                        ];
              
            }
          }
          else {
            exit = 91;
          }
        }
      }
      else {
        if (c !== 10) {
          if (c >= 32) {
            switch (-32 + c) {
              case 0 : 
                  var match$2 = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            [
                              /* Break */0,
                              "@ ",
                              1,
                              0
                            ],
                            match$2[1]
                          ]
                        ];
              case 5 : 
                  if (str_ind + 1 < end_ind && str[str_ind + 1] === "%") {
                    var match$3 = parse(str_ind + 2, end_ind);
                    return [
                            /* Fmt_EBB */0,
                            [
                              /* Formatting_lit */17,
                              /* Escaped_percent */6,
                              match$3[1]
                            ]
                          ];
                  }
                  else {
                    var match$4 = parse(str_ind, end_ind);
                    return [
                            /* Fmt_EBB */0,
                            [
                              /* Char_literal */12,
                              /* "@" */64,
                              match$4[1]
                            ]
                          ];
                  }
                  break;
              case 12 : 
                  var match$5 = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            [
                              /* Break */0,
                              "@,",
                              0,
                              0
                            ],
                            match$5[1]
                          ]
                        ];
              case 14 : 
                  var match$6 = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            /* Flush_newline */4,
                            match$6[1]
                          ]
                        ];
              case 27 : 
                  return parse_good_break(str_ind + 1, end_ind);
              case 28 : 
                  return parse_magic_size(str_ind + 1, end_ind);
              case 1 : 
              case 2 : 
              case 3 : 
              case 4 : 
              case 6 : 
              case 7 : 
              case 8 : 
              case 9 : 
              case 10 : 
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
              case 25 : 
              case 26 : 
              case 29 : 
              case 30 : 
                  exit = 91;
                  break;
              case 31 : 
                  var match$7 = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            /* FFlush */2,
                            match$7[1]
                          ]
                        ];
              case 32 : 
                  var match$8 = parse(str_ind + 1, end_ind);
                  return [
                          /* Fmt_EBB */0,
                          [
                            /* Formatting_lit */17,
                            /* Escaped_at */5,
                            match$8[1]
                          ]
                        ];
              
            }
          }
          else {
            exit = 91;
          }
        }
        else {
          var match$9 = parse(str_ind + 1, end_ind);
          return [
                  /* Fmt_EBB */0,
                  [
                    /* Formatting_lit */17,
                    /* Force_newline */3,
                    match$9[1]
                  ]
                ];
        }
      }
      if (exit === 91) {
        var match$10 = parse(str_ind + 1, end_ind);
        return [
                /* Fmt_EBB */0,
                [
                  /* Formatting_lit */17,
                  [
                    /* Scan_indic */2,
                    c
                  ],
                  match$10[1]
                ]
              ];
      }
      
    }
  };
  var check_open_box = function (fmt) {
    if (typeof fmt === "number") {
      return /* () */0;
    }
    else {
      if (fmt[0] === 11) {
        if (typeof fmt[2] === "number") {
          try {
            return open_box_of_string(fmt[1]);
          }
          catch (exn){
            if (exn[1] === Caml_exceptions.Failure) {
              return /* () */0;
            }
            else {
              throw exn;
            }
          }
        }
        else {
          return /* () */0;
        }
      }
      else {
        return /* () */0;
      }
    }
  };
  var parse_tag = function (is_open_tag, str_ind, end_ind) {
    try {
      if (str_ind === end_ind) {
        throw Caml_exceptions.Not_found;
      }
      var match = str.charCodeAt(str_ind);
      if (match !== 60) {
        throw Caml_exceptions.Not_found;
      }
      else {
        var ind = $$String.index_from(str, str_ind + 1, /* ">" */62);
        if (ind >= end_ind) {
          throw Caml_exceptions.Not_found;
        }
        var sub_str = $$String.sub(str, str_ind, ind - str_ind + 1);
        var match$1 = parse(ind + 1, end_ind);
        var match$2 = parse(str_ind, ind + 1);
        var sub_fmt = match$2[1];
        var sub_format = [
          /* Format */0,
          sub_fmt,
          sub_str
        ];
        var formatting = is_open_tag ? [
            /* Open_tag */0,
            sub_format
          ] : (check_open_box(sub_fmt), [
              /* Open_box */1,
              sub_format
            ]);
        return [
                /* Fmt_EBB */0,
                [
                  /* Formatting_gen */18,
                  formatting,
                  match$1[1]
                ]
              ];
      }
    }
    catch (exn){
      if (exn === Caml_exceptions.Not_found) {
        var match$3 = parse(str_ind, end_ind);
        var sub_format$1 = [
          /* Format */0,
          /* End_of_format */0,
          ""
        ];
        var formatting$1 = is_open_tag ? [
            /* Open_tag */0,
            sub_format$1
          ] : [
            /* Open_box */1,
            sub_format$1
          ];
        return [
                /* Fmt_EBB */0,
                [
                  /* Formatting_gen */18,
                  formatting$1,
                  match$3[1]
                ]
              ];
      }
      else {
        throw exn;
      }
    }
  };
  var parse_good_break = function (str_ind, end_ind) {
    var match;
    try {
      if (str_ind === end_ind || str.charCodeAt(str_ind) !== /* "<" */60) {
        throw Caml_exceptions.Not_found;
      }
      var str_ind_1 = parse_spaces(str_ind + 1, end_ind);
      var match$1 = str.charCodeAt(str_ind_1);
      /* initialize */var exit = 0;
      if (match$1 >= 48) {
        if (match$1 >= 58) {
          throw Caml_exceptions.Not_found;
        }
        else {
          exit = 113;
        }
      }
      else {
        if (match$1 !== 45) {
          throw Caml_exceptions.Not_found;
        }
        else {
          exit = 113;
        }
      }
      if (exit === 113) {
        var match$2 = parse_integer(str_ind_1, end_ind);
        var width = match$2[2];
        var str_ind_3 = parse_spaces(match$2[1], end_ind);
        var match$3 = str.charCodeAt(str_ind_3);
        var switcher = -45 + match$3;
        if (!(12 < (switcher >>> 0))) {
          if (1 < (-1 + switcher >>> 0)) {
            var match$4 = parse_integer(str_ind_3, end_ind);
            var str_ind_5 = parse_spaces(match$4[1], end_ind);
            if (str.charCodeAt(str_ind_5) !== /* ">" */62) {
              throw Caml_exceptions.Not_found;
            }
            var s = $$String.sub(str, str_ind - 2, str_ind_5 - str_ind + 3);
            match = [
              /* tuple */0,
              str_ind_5 + 1,
              [
                /* Break */0,
                s,
                width,
                match$4[2]
              ]
            ];
          }
          else {
            throw Caml_exceptions.Not_found;
          }
        }
        else {
          if (switcher !== 17) {
            throw Caml_exceptions.Not_found;
          }
          else {
            var s$1 = $$String.sub(str, str_ind - 2, str_ind_3 - str_ind + 3);
            match = [
              /* tuple */0,
              str_ind_3 + 1,
              [
                /* Break */0,
                s$1,
                width,
                0
              ]
            ];
          }
        }
      }
      
    }
    catch (exn){
      if (exn === Caml_exceptions.Not_found) {
        match = [
          /* tuple */0,
          str_ind,
          [
            /* Break */0,
            "@;",
            1,
            0
          ]
        ];
      }
      else {
        if (exn[1] === Caml_exceptions.Failure) {
          match = [
            /* tuple */0,
            str_ind,
            [
              /* Break */0,
              "@;",
              1,
              0
            ]
          ];
        }
        else {
          throw exn;
        }
      }
    }
    var match$5 = parse(match[1], end_ind);
    return [
            /* Fmt_EBB */0,
            [
              /* Formatting_lit */17,
              match[2],
              match$5[1]
            ]
          ];
  };
  var parse_magic_size = function (str_ind, end_ind) {
    var match;
    try {
      var str_ind_1 = parse_spaces(str_ind, end_ind);
      var match$1 = str.charCodeAt(str_ind_1);
      /* initialize */var exit = 0;
      match$1 >= 48 ? (
          match$1 >= 58 ? (match = /* None */0) : (exit = 123)
        ) : (
          match$1 !== 45 ? (match = /* None */0) : (exit = 123)
        );
      if (exit === 123) {
        var match$2 = parse_integer(str_ind_1, end_ind);
        var str_ind_3 = parse_spaces(match$2[1], end_ind);
        if (str.charCodeAt(str_ind_3) !== /* ">" */62) {
          throw Caml_exceptions.Not_found;
        }
        var s = $$String.sub(str, str_ind - 2, str_ind_3 - str_ind + 3);
        match = [
          /* Some */0,
          [
            /* tuple */0,
            str_ind_3 + 1,
            [
              /* Magic_size */1,
              s,
              match$2[2]
            ]
          ]
        ];
      }
      
    }
    catch (exn){
      if (exn === Caml_exceptions.Not_found) {
        match = /* None */0;
      }
      else {
        if (exn[1] === Caml_exceptions.Failure) {
          match = /* None */0;
        }
        else {
          throw exn;
        }
      }
    }
    if (match) {
      var match$3 = match[1];
      var match$4 = parse(match$3[1], end_ind);
      return [
              /* Fmt_EBB */0,
              [
                /* Formatting_lit */17,
                match$3[2],
                match$4[1]
              ]
            ];
    }
    else {
      var match$5 = parse(str_ind, end_ind);
      return [
              /* Fmt_EBB */0,
              [
                /* Formatting_lit */17,
                [
                  /* Scan_indic */2,
                  /* "<" */60
                ],
                match$5[1]
              ]
            ];
    }
  };
  var parse_char_set = function (str_ind, end_ind) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var char_set = create_char_set(/* () */0);
    var add_char = function (c) {
      return add_in_char_set(char_set, c);
    };
    var add_range = function (c, c$prime) {
      for(var i = c; i<= c$prime; ++i){
        add_in_char_set(char_set, Pervasives.char_of_int(i));
      }
      return /* () */0;
    };
    var fail_single_percent = function (str_ind) {
      return failwith_message([
                    /* Format */0,
                    [
                      /* String_literal */11,
                      "invalid format ",
                      [
                        /* Caml_string */3,
                        /* No_padding */0,
                        [
                          /* String_literal */11,
                          ": '",
                          [
                            /* Char_literal */12,
                            /* "%" */37,
                            [
                              /* String_literal */11,
                              "' alone is not accepted in character sets, use ",
                              [
                                /* Char_literal */12,
                                /* "%" */37,
                                [
                                  /* Char_literal */12,
                                  /* "%" */37,
                                  [
                                    /* String_literal */11,
                                    " instead at position ",
                                    [
                                      /* Int */4,
                                      /* Int_d */0,
                                      /* No_padding */0,
                                      /* No_precision */0,
                                      [
                                        /* Char_literal */12,
                                        /* "." */46,
                                        /* End_of_format */0
                                      ]
                                    ]
                                  ]
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ],
                    "invalid format %S: '%%' alone is not accepted in character sets, use %%%% instead at position %d."
                  ])(str, str_ind);
    };
    var parse_char_set_start = function (str_ind, end_ind) {
      if (str_ind === end_ind) {
        unexpected_end_of_format(end_ind);
      }
      var c = str.charCodeAt(str_ind);
      return parse_char_set_after_char(str_ind + 1, end_ind, c);
    };
    var parse_char_set_content = function (_str_ind, end_ind) {
      while(/* true */1) {
        var str_ind = _str_ind;
        if (str_ind === end_ind) {
          unexpected_end_of_format(end_ind);
        }
        var c = str.charCodeAt(str_ind);
        if (c !== 45) {
          return c !== 93 ? parse_char_set_after_char(str_ind + 1, end_ind, c) : str_ind + 1;
        }
        else {
          add_char(/* "-" */45);
          _str_ind = str_ind + 1;
        }
      };
    };
    var parse_char_set_after_char = function (_str_ind, end_ind, _c) {
      while(/* true */1) {
        var c = _c;
        var str_ind = _str_ind;
        if (str_ind === end_ind) {
          unexpected_end_of_format(end_ind);
        }
        var c$prime = str.charCodeAt(str_ind);
        /* initialize */var exit = 0;
        if (c$prime >= 46) {
          if (c$prime !== 64) {
            if (c$prime !== 93) {
              exit = 132;
            }
            else {
              add_char(c);
              return str_ind + 1;
            }
          }
          else {
            exit = 133;
          }
        }
        else {
          if (c$prime !== 37) {
            if (c$prime >= 45) {
              return parse_char_set_after_minus(str_ind + 1, end_ind, c);
            }
            else {
              exit = 132;
            }
          }
          else {
            exit = 133;
          }
        }
        switch (exit) {
          case 133 : 
              if (c === /* "%" */37) {
                add_char(c$prime);
                return parse_char_set_content(str_ind + 1, end_ind);
              }
              else {
                exit = 132;
              }
              break;
          case 132 : 
              if (c === /* "%" */37) {
                fail_single_percent(str_ind);
              }
              add_char(c);
              _c = c$prime;
              _str_ind = str_ind + 1;
              break;
          
        }
      };
    };
    var parse_char_set_after_minus = function (str_ind, end_ind, c) {
      if (str_ind === end_ind) {
        unexpected_end_of_format(end_ind);
      }
      var c$prime = str.charCodeAt(str_ind);
      if (c$prime !== 37) {
        return c$prime !== 93 ? (add_range(c, c$prime), parse_char_set_content(str_ind + 1, end_ind)) : (add_char(c), add_char(/* "-" */45), str_ind + 1);
      }
      else {
        if (str_ind + 1 === end_ind) {
          unexpected_end_of_format(end_ind);
        }
        var c$prime$1 = str.charCodeAt(str_ind + 1);
        /* initialize */var exit = 0;
        if (c$prime$1 !== 37) {
          if (c$prime$1 !== 64) {
            return fail_single_percent(str_ind);
          }
          else {
            exit = 134;
          }
        }
        else {
          exit = 134;
        }
        if (exit === 134) {
          add_range(c, c$prime$1);
          return parse_char_set_content(str_ind + 2, end_ind);
        }
        
      }
    };
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var match = str.charCodeAt(str_ind);
    var match$1 = match !== 94 ? [
        /* tuple */0,
        str_ind,
        /* false */0
      ] : [
        /* tuple */0,
        str_ind + 1,
        /* true */1
      ];
    var next_ind = parse_char_set_start(match$1[1], end_ind);
    var char_set$1 = freeze_char_set(char_set);
    return [
            /* tuple */0,
            next_ind,
            match$1[2] ? rev_char_set(char_set$1) : char_set$1
          ];
  };
  var parse_spaces = function (_str_ind, end_ind) {
    while(/* true */1) {
      var str_ind = _str_ind;
      if (str_ind === end_ind) {
        unexpected_end_of_format(end_ind);
      }
      if (str[str_ind] === " ") {
        _str_ind = str_ind + 1;
      }
      else {
        return str_ind;
      }
    };
  };
  var parse_positive = function (_str_ind, end_ind, _acc) {
    while(/* true */1) {
      var acc = _acc;
      var str_ind = _str_ind;
      if (str_ind === end_ind) {
        unexpected_end_of_format(end_ind);
      }
      var c = str.charCodeAt(str_ind);
      if (9 < (-48 + c >>> 0)) {
        return [
                /* tuple */0,
                str_ind,
                acc
              ];
      }
      else {
        var new_acc = acc * 10 + (c - /* "0" */48);
        if (new_acc > Sys.max_string_length) {
          return failwith_message([
                        /* Format */0,
                        [
                          /* String_literal */11,
                          "invalid format ",
                          [
                            /* Caml_string */3,
                            /* No_padding */0,
                            [
                              /* String_literal */11,
                              ": integer ",
                              [
                                /* Int */4,
                                /* Int_d */0,
                                /* No_padding */0,
                                /* No_precision */0,
                                [
                                  /* String_literal */11,
                                  " is greater than the limit ",
                                  [
                                    /* Int */4,
                                    /* Int_d */0,
                                    /* No_padding */0,
                                    /* No_precision */0,
                                    /* End_of_format */0
                                  ]
                                ]
                              ]
                            ]
                          ]
                        ],
                        "invalid format %S: integer %d is greater than the limit %d"
                      ])(str, new_acc, Sys.max_string_length);
        }
        else {
          _acc = new_acc;
          _str_ind = str_ind + 1;
        }
      }
    };
  };
  var parse_integer = function (str_ind, end_ind) {
    if (str_ind === end_ind) {
      unexpected_end_of_format(end_ind);
    }
    var match = str.charCodeAt(str_ind);
    if (match >= 48) {
      if (match >= 58) {
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                2621,
                11
              ]
            ];
      }
      else {
        return parse_positive(str_ind, end_ind, 0);
      }
    }
    else {
      if (match !== 45) {
        throw [
              0,
              Caml_exceptions.Assert_failure,
              [
                0,
                "camlinternalFormat.ml",
                2621,
                11
              ]
            ];
      }
      else {
        if (str_ind + 1 === end_ind) {
          unexpected_end_of_format(end_ind);
        }
        var c = str.charCodeAt(str_ind + 1);
        if (9 < (-48 + c >>> 0)) {
          return expected_character(str_ind + 1, "digit", c);
        }
        else {
          var match$1 = parse_positive(str_ind + 1, end_ind, 0);
          return [
                  /* tuple */0,
                  match$1[1],
                  -match$1[2]
                ];
        }
      }
    }
  };
  var add_literal = function (lit_start, str_ind, fmt) {
    var size = str_ind - lit_start;
    return size !== 0 ? (
              size !== 1 ? [
                  /* Fmt_EBB */0,
                  [
                    /* String_literal */11,
                    $$String.sub(str, lit_start, size),
                    fmt
                  ]
                ] : [
                  /* Fmt_EBB */0,
                  [
                    /* Char_literal */12,
                    str.charCodeAt(lit_start),
                    fmt
                  ]
                ]
            ) : [
              /* Fmt_EBB */0,
              fmt
            ];
  };
  var search_subformat_end = function (_str_ind, end_ind, c) {
    while(/* true */1) {
      var str_ind = _str_ind;
      if (str_ind === end_ind) {
        failwith_message([
                /* Format */0,
                [
                  /* String_literal */11,
                  "invalid format ",
                  [
                    /* Caml_string */3,
                    /* No_padding */0,
                    [
                      /* String_literal */11,
                      ': unclosed sub-format, expected "',
                      [
                        /* Char_literal */12,
                        /* "%" */37,
                        [
                          /* Char */0,
                          [
                            /* String_literal */11,
                            '" at character number ',
                            [
                              /* Int */4,
                              /* Int_d */0,
                              /* No_padding */0,
                              /* No_precision */0,
                              /* End_of_format */0
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ],
                'invalid format %S: unclosed sub-format, expected "%%%c" at character number %d'
              ])(str, c, end_ind);
      }
      var match = str.charCodeAt(str_ind);
      if (match !== 37) {
        _str_ind = str_ind + 1;
      }
      else {
        if (str_ind + 1 === end_ind) {
          unexpected_end_of_format(end_ind);
        }
        if (str.charCodeAt(str_ind + 1) === c) {
          return str_ind;
        }
        else {
          var match$1 = str.charCodeAt(str_ind + 1);
          /* initialize */var exit = 0;
          if (match$1 >= 95) {
            if (match$1 >= 123) {
              if (match$1 >= 126) {
                exit = 155;
              }
              else {
                switch (-123 + match$1) {
                  case 0 : 
                      var sub_end = search_subformat_end(str_ind + 2, end_ind, /* "}" */125);
                      _str_ind = sub_end + 2;
                      break;
                  case 1 : 
                      exit = 155;
                      break;
                  case 2 : 
                      return expected_character(str_ind + 1, "character ')'", /* "}" */125);
                  
                }
              }
            }
            else {
              if (match$1 >= 96) {
                exit = 155;
              }
              else {
                if (str_ind + 2 === end_ind) {
                  unexpected_end_of_format(end_ind);
                }
                var match$2 = str.charCodeAt(str_ind + 2);
                if (match$2 !== 40) {
                  if (match$2 !== 123) {
                    _str_ind = str_ind + 3;
                  }
                  else {
                    var sub_end$1 = search_subformat_end(str_ind + 3, end_ind, /* "}" */125);
                    _str_ind = sub_end$1 + 2;
                  }
                }
                else {
                  var sub_end$2 = search_subformat_end(str_ind + 3, end_ind, /* ")" */41);
                  _str_ind = sub_end$2 + 2;
                }
              }
            }
          }
          else {
            if (match$1 !== 40) {
              if (match$1 !== 41) {
                exit = 155;
              }
              else {
                return expected_character(str_ind + 1, "character '}'", /* ")" */41);
              }
            }
            else {
              var sub_end$3 = search_subformat_end(str_ind + 2, end_ind, /* ")" */41);
              _str_ind = sub_end$3 + 2;
            }
          }
          if (exit === 155) {
            _str_ind = str_ind + 2;
          }
          
        }
      }
    };
  };
  var is_int_base = function (symb) {
    var switcher = -88 + symb;
    if (32 < (switcher >>> 0)) {
      return /* false */0;
    }
    else {
      switch (switcher) {
        case 1 : 
        case 2 : 
        case 3 : 
        case 4 : 
        case 5 : 
        case 6 : 
        case 7 : 
        case 8 : 
        case 9 : 
        case 10 : 
        case 11 : 
        case 13 : 
        case 14 : 
        case 15 : 
        case 16 : 
        case 18 : 
        case 19 : 
        case 20 : 
        case 21 : 
        case 22 : 
        case 24 : 
        case 25 : 
        case 26 : 
        case 27 : 
        case 28 : 
        case 30 : 
        case 31 : 
            return /* false */0;
        case 0 : 
        case 12 : 
        case 17 : 
        case 23 : 
        case 29 : 
        case 32 : 
            return /* true */1;
        
      }
    }
  };
  var counter_of_char = function (symb) {
    /* initialize */var exit = 0;
    if (symb >= 108) {
      if (symb >= 111) {
        exit = 159;
      }
      else {
        switch (-108 + symb) {
          case 0 : 
              return /* Line_counter */0;
          case 1 : 
              exit = 159;
              break;
          case 2 : 
              return /* Char_counter */1;
          
        }
      }
    }
    else {
      if (symb !== 76) {
        exit = 159;
      }
      else {
        return /* Token_counter */2;
      }
    }
    if (exit === 159) {
      throw [
            0,
            Caml_exceptions.Assert_failure,
            [
              0,
              "camlinternalFormat.ml",
              2683,
              34
            ]
          ];
    }
    
  };
  var compute_int_conv = function (pct_ind, str_ind, _plus, _sharp, _space, symb) {
    while(/* true */1) {
      var space = _space;
      var sharp = _sharp;
      var plus = _plus;
      /* initialize */var exit = 0;
      if (plus !== 0) {
        if (sharp !== 0) {
          exit = 161;
        }
        else {
          if (space !== 0) {
            exit = 160;
          }
          else {
            if (symb !== 100) {
              if (symb !== 105) {
                exit = 160;
              }
              else {
                return /* Int_pi */4;
              }
            }
            else {
              return /* Int_pd */1;
            }
          }
        }
      }
      else {
        if (sharp !== 0) {
          if (space !== 0) {
            exit = 161;
          }
          else {
            if (symb !== 88) {
              if (symb !== 111) {
                if (symb !== 120) {
                  exit = 161;
                }
                else {
                  return /* Int_Cx */7;
                }
              }
              else {
                return /* Int_Co */11;
              }
            }
            else {
              return /* Int_CX */9;
            }
          }
        }
        else {
          if (space !== 0) {
            if (symb !== 100) {
              if (symb !== 105) {
                exit = 160;
              }
              else {
                return /* Int_si */5;
              }
            }
            else {
              return /* Int_sd */2;
            }
          }
          else {
            var switcher = -88 + symb;
            if (32 < (switcher >>> 0)) {
              exit = 160;
            }
            else {
              switch (switcher) {
                case 0 : 
                    return /* Int_X */8;
                case 12 : 
                    return /* Int_d */0;
                case 17 : 
                    return /* Int_i */3;
                case 23 : 
                    return /* Int_o */10;
                case 29 : 
                    return /* Int_u */12;
                case 1 : 
                case 2 : 
                case 3 : 
                case 4 : 
                case 5 : 
                case 6 : 
                case 7 : 
                case 8 : 
                case 9 : 
                case 10 : 
                case 11 : 
                case 13 : 
                case 14 : 
                case 15 : 
                case 16 : 
                case 18 : 
                case 19 : 
                case 20 : 
                case 21 : 
                case 22 : 
                case 24 : 
                case 25 : 
                case 26 : 
                case 27 : 
                case 28 : 
                case 30 : 
                case 31 : 
                    exit = 160;
                    break;
                case 32 : 
                    return /* Int_x */6;
                
              }
            }
          }
        }
      }
      switch (exit) {
        case 161 : 
            /* initialize */var exit$1 = 0;
            var switcher$1 = -88 + symb;
            if (32 < (switcher$1 >>> 0)) {
              exit = 160;
            }
            else {
              switch (switcher$1) {
                case 0 : 
                    if (legacy_behavior$1) {
                      return /* Int_CX */9;
                    }
                    else {
                      exit = 160;
                    }
                    break;
                case 23 : 
                    if (legacy_behavior$1) {
                      return /* Int_Co */11;
                    }
                    else {
                      exit = 160;
                    }
                    break;
                case 12 : 
                case 17 : 
                case 29 : 
                    exit$1 = 163;
                    break;
                case 1 : 
                case 2 : 
                case 3 : 
                case 4 : 
                case 5 : 
                case 6 : 
                case 7 : 
                case 8 : 
                case 9 : 
                case 10 : 
                case 11 : 
                case 13 : 
                case 14 : 
                case 15 : 
                case 16 : 
                case 18 : 
                case 19 : 
                case 20 : 
                case 21 : 
                case 22 : 
                case 24 : 
                case 25 : 
                case 26 : 
                case 27 : 
                case 28 : 
                case 30 : 
                case 31 : 
                    exit = 160;
                    break;
                case 32 : 
                    if (legacy_behavior$1) {
                      return /* Int_Cx */7;
                    }
                    else {
                      exit = 160;
                    }
                    break;
                
              }
            }
            if (exit$1 === 163) {
              if (legacy_behavior$1) {
                _sharp = /* false */0;
              }
              else {
                return incompatible_flag(pct_ind, str_ind, symb, "'#'");
              }
            }
            break;
        case 160 : 
            if (plus !== 0) {
              if (space !== 0) {
                if (legacy_behavior$1) {
                  _space = /* false */0;
                }
                else {
                  return incompatible_flag(pct_ind, str_ind, /* " " */32, "'+'");
                }
              }
              else {
                if (legacy_behavior$1) {
                  _plus = /* false */0;
                }
                else {
                  return incompatible_flag(pct_ind, str_ind, symb, "'+'");
                }
              }
            }
            else {
              if (space !== 0) {
                if (legacy_behavior$1) {
                  _space = /* false */0;
                }
                else {
                  return incompatible_flag(pct_ind, str_ind, symb, "' '");
                }
              }
              else {
                throw [
                      0,
                      Caml_exceptions.Assert_failure,
                      [
                        0,
                        "camlinternalFormat.ml",
                        2716,
                        28
                      ]
                    ];
              }
            }
            break;
        
      }
    };
  };
  var compute_float_conv = function (pct_ind, str_ind, _plus, _space, symb) {
    while(/* true */1) {
      var space = _space;
      var plus = _plus;
      if (plus !== 0) {
        if (space !== 0) {
          if (legacy_behavior$1) {
            _space = /* false */0;
          }
          else {
            return incompatible_flag(pct_ind, str_ind, /* " " */32, "'+'");
          }
        }
        else {
          /* initialize */var exit = 0;
          if (symb >= 72) {
            var switcher = -101 + symb;
            if (2 < (switcher >>> 0)) {
              exit = 164;
            }
            else {
              switch (switcher) {
                case 0 : 
                    return /* Float_pe */4;
                case 1 : 
                    return /* Float_pf */1;
                case 2 : 
                    return /* Float_pg */10;
                
              }
            }
          }
          else {
            if (symb >= 69) {
              switch (-69 + symb) {
                case 0 : 
                    return /* Float_pE */7;
                case 1 : 
                    exit = 164;
                    break;
                case 2 : 
                    return /* Float_pG */13;
                
              }
            }
            else {
              exit = 164;
            }
          }
          if (exit === 164) {
            if (legacy_behavior$1) {
              _plus = /* false */0;
            }
            else {
              return incompatible_flag(pct_ind, str_ind, symb, "'+'");
            }
          }
          
        }
      }
      else {
        if (space !== 0) {
          /* initialize */var exit$1 = 0;
          if (symb >= 72) {
            var switcher$1 = -101 + symb;
            if (2 < (switcher$1 >>> 0)) {
              exit$1 = 165;
            }
            else {
              switch (switcher$1) {
                case 0 : 
                    return /* Float_se */5;
                case 1 : 
                    return /* Float_sf */2;
                case 2 : 
                    return /* Float_sg */11;
                
              }
            }
          }
          else {
            if (symb >= 69) {
              switch (-69 + symb) {
                case 0 : 
                    return /* Float_sE */8;
                case 1 : 
                    exit$1 = 165;
                    break;
                case 2 : 
                    return /* Float_sG */14;
                
              }
            }
            else {
              exit$1 = 165;
            }
          }
          if (exit$1 === 165) {
            if (legacy_behavior$1) {
              _space = /* false */0;
            }
            else {
              return incompatible_flag(pct_ind, str_ind, symb, "' '");
            }
          }
          
        }
        else {
          if (symb >= 72) {
            var switcher$2 = -101 + symb;
            if (2 < (switcher$2 >>> 0)) {
              throw [
                    0,
                    Caml_exceptions.Assert_failure,
                    [
                      0,
                      "camlinternalFormat.ml",
                      2744,
                      25
                    ]
                  ];
            }
            else {
              switch (switcher$2) {
                case 0 : 
                    return /* Float_e */3;
                case 1 : 
                    return /* Float_f */0;
                case 2 : 
                    return /* Float_g */9;
                
              }
            }
          }
          else {
            if (symb >= 69) {
              switch (-69 + symb) {
                case 0 : 
                    return /* Float_E */6;
                case 1 : 
                    return /* Float_F */15;
                case 2 : 
                    return /* Float_G */12;
                
              }
            }
            else {
              throw [
                    0,
                    Caml_exceptions.Assert_failure,
                    [
                      0,
                      "camlinternalFormat.ml",
                      2744,
                      25
                    ]
                  ];
            }
          }
        }
      }
    };
  };
  var incompatible_flag = function (pct_ind, str_ind, symb, option) {
    var subfmt = $$String.sub(str, pct_ind, str_ind - pct_ind);
    return failwith_message([
                  /* Format */0,
                  [
                    /* String_literal */11,
                    "invalid format ",
                    [
                      /* Caml_string */3,
                      /* No_padding */0,
                      [
                        /* String_literal */11,
                        ": at character number ",
                        [
                          /* Int */4,
                          /* Int_d */0,
                          /* No_padding */0,
                          /* No_precision */0,
                          [
                            /* String_literal */11,
                            ", ",
                            [
                              /* String */2,
                              /* No_padding */0,
                              [
                                /* String_literal */11,
                                " is incompatible with '",
                                [
                                  /* Char */0,
                                  [
                                    /* String_literal */11,
                                    "' in sub-format ",
                                    [
                                      /* Caml_string */3,
                                      /* No_padding */0,
                                      /* End_of_format */0
                                    ]
                                  ]
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ],
                  "invalid format %S: at character number %d, %s is incompatible with '%c' in sub-format %S"
                ])(str, pct_ind, option, symb, subfmt);
  };
  return parse(0, str.length);
}

function format_of_string_fmtty(str, fmtty) {
  var match = fmt_ebb_of_string(/* None */0, str);
  try {
    return [
            /* Format */0,
            type_format(match[1], fmtty),
            str
          ];
  }
  catch (exn){
    if (exn === Type_mismatch) {
      return failwith_message([
                    /* Format */0,
                    [
                      /* String_literal */11,
                      "bad input: format type mismatch between ",
                      [
                        /* Caml_string */3,
                        /* No_padding */0,
                        [
                          /* String_literal */11,
                          " and ",
                          [
                            /* Caml_string */3,
                            /* No_padding */0,
                            /* End_of_format */0
                          ]
                        ]
                      ]
                    ],
                    "bad input: format type mismatch between %S and %S"
                  ])(str, string_of_fmtty(fmtty));
    }
    else {
      throw exn;
    }
  }
}

function format_of_string_format(str, param) {
  var match = fmt_ebb_of_string(/* None */0, str);
  try {
    return [
            /* Format */0,
            type_format(match[1], fmtty_of_fmt(param[1])),
            str
          ];
  }
  catch (exn){
    if (exn === Type_mismatch) {
      return failwith_message([
                    /* Format */0,
                    [
                      /* String_literal */11,
                      "bad input: format type mismatch between ",
                      [
                        /* Caml_string */3,
                        /* No_padding */0,
                        [
                          /* String_literal */11,
                          " and ",
                          [
                            /* Caml_string */3,
                            /* No_padding */0,
                            /* End_of_format */0
                          ]
                        ]
                      ]
                    ],
                    "bad input: format type mismatch between %S and %S"
                  ])(str, param[2]);
    }
    else {
      throw exn;
    }
  }
}

exports.is_in_char_set = is_in_char_set;
exports.rev_char_set = rev_char_set;
exports.create_char_set = create_char_set;
exports.add_in_char_set = add_in_char_set;
exports.freeze_char_set = freeze_char_set;
exports.param_format_of_ignored_format = param_format_of_ignored_format;
exports.make_printf = make_printf;
exports.output_acc = output_acc;
exports.bufput_acc = bufput_acc;
exports.strput_acc = strput_acc;
exports.type_format = type_format;
exports.fmt_ebb_of_string = fmt_ebb_of_string;
exports.format_of_string_fmtty = format_of_string_fmtty;
exports.format_of_string_format = format_of_string_format;
exports.char_of_iconv = char_of_iconv;
exports.string_of_formatting_lit = string_of_formatting_lit;
exports.string_of_formatting_gen = string_of_formatting_gen;
exports.string_of_fmtty = string_of_fmtty;
exports.string_of_fmt = string_of_fmt;
exports.open_box_of_string = open_box_of_string;
exports.symm = symm;
exports.trans = trans;
exports.recast = recast;
/* No side effect */
