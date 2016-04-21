function resu = df_whole(df);

  %# function resu = df_whole(df)
  %# Generate a full matrix from a column-compressed version of a dataframe.

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
  %# $Id: df_whole.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  inds = max(cellfun(@length, df._rep));

  resu = df._data{1}(:, df._rep{1});
  if (inds > 1),
    resu = reshape(resu, df._cnt(1), 1, []);
    if (1 == size(resu, 3)),
      resu = repmat(resu, [1 1 inds]);
    endif
  endif

  if df._cnt(2) > 1,
    resu = repmat(resu, [1 df._cnt(2)]);
    for indi = 2:df._cnt(2),
      dummy = df._data{indi}(:, df._rep{indi});
      if (inds > 1),
	dummy = reshape(dummy, df._cnt(1), 1, []);
	if (1 == size(dummy, 3)),
	  dummy = repmat(dummy, [1 1 inds]);
	endif
      endif
      resu(:, indi, :) = dummy;
    endfor
  endif

endfunction
