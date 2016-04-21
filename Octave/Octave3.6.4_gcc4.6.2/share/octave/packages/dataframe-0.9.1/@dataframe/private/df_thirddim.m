function [df] = df_thirddim(df)

  %# function [resu] = df_thirddim(df)
  %# This is a small helper function which recomputes the third dim each
  %# time a change may have occured.

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
  %# $Id: df_thirddim.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  %# sanity check
  dummy = max(cellfun(@length, df._rep));
  if (dummy != 1),
    df._cnt(3) = dummy;
  elseif (length(df._cnt) > 2), 
    df._cnt = df._cnt(1:2);
  endif

endfunction
