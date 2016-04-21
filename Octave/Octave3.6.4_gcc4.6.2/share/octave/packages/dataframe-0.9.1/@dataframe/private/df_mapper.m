function resu = df_mapper(func, df, varargin)
  %# resu = df_mapper(func, df)
  %# small interface to iterate some func over the elements of a dataframe.

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
  %# $Id: df_mapper.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  resu = df_allmeta(df);
  resu._data = cellfun(@(x) feval(func, x, varargin{:}), df._data, \
		       "UniformOutput", false);
  resu._rep = df._rep; %# things didn't change
  resu._type = cellfun(@(x) class(x(1)), resu._data, "UniformOutput", false);

  resu = df_thirddim(resu);

endfunction
