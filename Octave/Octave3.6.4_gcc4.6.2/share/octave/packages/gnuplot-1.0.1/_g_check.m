### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function isok = _g_check (g)
### isok = _g_check (g)         - Check that g is a gnuplot_object
### 
### If nargout == 0, an error is raised if g is not a gnuplot_object.
### Else, isok is set to 0 and returned.
  isok = 1;
  if !isstruct (g)
    isok = 0;
    if !nargout, error ("1st argument is not a struct"); endif
    if !strcmp (g.type, "gnuplot_object")
      isok = 0;
      if !nargout, error ("1st argument is not a gnuplot_object"); endif
    endif
  endif
  if !nargout, clear isok; endif
endfunction
