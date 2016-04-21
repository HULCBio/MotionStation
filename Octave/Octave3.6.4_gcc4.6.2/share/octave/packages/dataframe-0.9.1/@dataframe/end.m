function resu = end(df, k, n)
  %# function resu = end(df, k, n)
  %# This is the end operator for a dataframe object, returning the
  %# maximum number of rows or columns

  %% Copyright (C) 2009-2012 Pascal Dupuis <Pascal.Dupuis@uclouvain.be>
  %%
  %% This file is part of Octave.
  %%
  %% Octave is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 2, or (at your option) any later version.
  %%
  %% Octave is distributed in the hope that it will be useful,
  %% but WITHOUT ANY WARRANTY; without even the implied
  %% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  %% PURPOSE.  See the GNU General Public License for more
  %% details.
  %%
  %% You should have received a copy of the GNU General Public
  %% License along with Octave; see the file COPYING.  If not,
  %% write to the Free Software Foundation, 51 Franklin Street -
  %% Fifth Floor, Boston, MA 02110-1301, USA.
  
  %#
  %# $Id: end.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  try
    if k < 3,
      resu = df._cnt(k);
    else
      resu =  max(cellfun(@length, df._rep));
    endif
  catch
    error("incorrect call to end, index greater than number of dimensions");
  end_try_catch

endfunction
