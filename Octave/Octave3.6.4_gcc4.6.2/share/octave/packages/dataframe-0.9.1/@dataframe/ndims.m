function resu = ndims(df)
  %# -*- texinfo -*-
  %# @deftypefn {Function File} ndims(@var{df})
  %# overloaded function implementing ndims for a dataframe
  %# @end deftypefn

  resu = 2;
  nseq = max(cellfun(@length, df._rep));

  if nseq > 1, resu = 3; endif

endfunction
