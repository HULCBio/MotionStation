function [df, S] = df_cow(df, S, col)

  %# function [resu, S] = df_cow(df, S, col)
  %# Implements Copy-On-Write on dataframe. If one or more columns
  %# specified in inds is aliased to another one, duplicate it and
  %# adjust the repetition index to remove the aliasing

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
  %# $Id: df_cow.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if length(col) > 1,
    error("df_cow must work on a column-by-column basis");
  endif
  
  if (1 == length(S.subs)),
    inds = 1; 
  else
    inds = S.subs{2};
  endif

  if (!isnumeric(inds)), 
    if !strcmp(inds, ':'),
      error("Unknown sheet selector %s", inds);
    endif
    inds = 1:length(df._rep(col));
  endif

  for indi = inds(:).',
    dummy = df._rep{col}; dummy(indi) = 0;
    [t1, t2] = ismember(df._rep{col}(indi)(:), dummy);
    for indj = t2(find(t2)), %# Copy-On-Write
      %# determines the index for the next column
      t1 = 1+max(df._rep{col}); 
      %# duplicate the touched column
      df._data{col} = horzcat(df._data{col}, \
                              df._data{col}(:, df._rep{col}(indj)));  
      if (indi > 1),
        %# a new column has been created
        df._rep{col}(indi) = t1;
      else
        %# update repetition index aliasing this one
        df._rep{col}(find(dummy == indi)) = t1;
      endif
    endfor
  endfor

  %# reorder S
  if (length(S.subs) > 1),
    if (S.subs{2} != 1 || length(S.subs{2}) > 1), 
      %# adapt sheet index according to df_rep
      S.subs{2} = df._rep{col}(S.subs{2});
    endif
  endif

  df = df_thirddim(df);

endfunction
