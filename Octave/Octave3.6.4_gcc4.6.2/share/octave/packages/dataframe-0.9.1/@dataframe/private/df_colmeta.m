function resu = df_colmeta(df)

  %# function resu = df_colmeta(df)
  %# Returns a new dataframe, initalised with the meta-information
  %# about columns from the source, but with empty data

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
  %# $Id: df_func.m 7943 2010-11-24 15:33:54Z cdemills $
  %#

  resu = dataframe([]);

  resu._cnt(2) = df._cnt(2);
  resu._name{2} = df._name{2};
  resu._over{2} = df._over{2};
  resu._type = df._type;
  %# init it with the right orientation
  resu._data = cell(size(df._data));
  resu._rep = cell(size(df._rep));
  resu._src  = df._src;
  resu._cmt  = df._cmt;

endfunction
