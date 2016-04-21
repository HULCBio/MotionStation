function resu = isempty(df)
  %# -*- texinfo -*-
  %# @deftypefn {Function File} isempty(@var{df})
  %# Return 1 if df is an empty dataframe (either the number of rows, or
  %#   the number of columns, or both are zero).  Otherwise, return 0.
  %# @end deftypefn

  resu = any(0 == size(df));

endfunction
