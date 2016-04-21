### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function c = _g_istoken (str, token) 
### Check that first chararcters of str match that of token and that the first
### non-matching char is ":"

  if isempty (str),      c = 0;            return; endif
  if isempty (token),    c = str(1)==":" ; return; endif
  
  c = 1;
  while 1
    if str(c) != token(c)
      if c > 1 && str(c) == ":", return; end
      c = 0;
      return;
    endif
    c++;
    if c > length(str)
      c--;
      if str(c) == ":"; return; endif
      c = 0; return; 
    endif
    if c > length(token)
      c--;
      if token(c) == ":"; return; endif
      c = 0;
      return;
    endif
  endwhile
endfunction
