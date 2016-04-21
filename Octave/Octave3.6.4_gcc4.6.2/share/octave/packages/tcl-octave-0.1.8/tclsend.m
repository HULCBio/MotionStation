## Author: Paul Kienzle
## This program is public domain.
function tclsend(name, m)
  if ischar(m)
    send(name,m);
  else
    send(name,sprintf("%.15g ", m));
  endif
endfunction
