function [resu, rcond] = inv(df);

  %# function [x, rcond] = inv(df)
  %# Overloaded function computing the inverse of a dataframe. To
  %# succeed, the dataframe must be convertible to an square array. Row
  %# and column meta-information are exchanged.  

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
  %# $Id: inv.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if (length(df._cnt) > 2 || (df._cnt(1) != df._cnt(2))),
    error("Dataframe is not square");
  endif

  %# quick and dirty conversion
  [dummy, rcond] = inv(horzcat(df._data{:}));

  resu = df_allmeta(df);
  
  [resu._name{2}, resu._name{1}] = deal(resu._name{1}, resu._name{2});
  [resu._over{2}, resu._over{1}] = deal(resu._over{1}, resu._over{2});
  if (isempty(resu._name{2})),
    resu._name{2} = cellstr(repmat('_', resu._cnt(2), 1));
    resu._over{2} = ones(1, resu._cnt(2));
  endif
  for indi = resu._cnt(1):-1:1,
    resu._data{indi} = dummy(:, indi);
  endfor
  resu._type(:) = class(dummy);
  
endfunction
