function resu = bsxfun(func, A, B)

  %# function resu = bsxfun(func, A, B)
  %# Implements a wrapper around internal bsxfun

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
  %# $Id: bsxfun.m 9585 2012-02-05 15:32:46Z cdemills $
  %#


  try

    [A, B, resu] = df_basecomp(A, B, true, @bsxfun);

    for indi = 1:max(A._cnt(2), B._cnt(2)),
      indA = min(indi, A._cnt(2));
      indB = min(indi, B._cnt(2));
      Au = A._data{indA}(:, A._rep{indA});
      Bu = B._data{indB}(:, B._rep{indB});
      resu._data{indi} = bsxfun(func, Au, Bu);
      resu._rep{indi} = 1:size(resu._data{indi}, 2);
    endfor

    resu = df_thirddim(resu);

  catch
    disp(lasterr());
    error('bsxfun: non-compatible dimensions')
  end_try_catch
  
endfunction
