function resu = df_allmeta(df, dim = [])

  %# function resu = df_allmeta(df)
  %# Returns a new dataframe, initalised with the all the
  %# meta-information but with empty data

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
  %# $Id: df_allmeta.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  resu = dataframe([]);

  if (isempty(dim)), 
    dim = df._cnt(1:2); 
  else
    dim = dim(1:2); %# ignore third dim, if any
  endif

  resu._cnt(1:2) = min(dim, df._cnt(1:2));
  if (!isempty(df._name{1})),
    resu._name{1} = df._name{1}(1:resu._cnt(1));
    resu._over{1} = df._over{1}(1:resu._cnt(1));
  endif
  if (!isempty(df._name{2})),
    resu._name{2} = df._name{2}(1:resu._cnt(2));
    resu._over{2} = df._over{2}(1:resu._cnt(2));
  endif
  if (!isempty(df._ridx)),
    if (size(df._ridx, 2) >= resu._cnt(2)),
      resu._ridx = df._ridx(1:resu._cnt(1), :, :);
    else
      resu._ridx = df._ridx(1:resu._cnt(1), 1, :);
    endif
  endif
  %# init it with the right orientation
  resu._data = cell(size(df._data));
  resu._rep = cell(size(df._rep));
  resu._type = df._type(1:resu._cnt(2));
  resu._src  = df._src;
  resu._cmt  = df._cmt;
  
endfunction
