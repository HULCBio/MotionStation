function resu = permute(df, perm) 
  
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
  %# $Id: permute.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  resu = dataframe([]);

  if (length(df._cnt) >= length(perm)),
    resu._cnt = df._cnt(perm);
  else
    resu._cnt = [df._cnt 1](perm);
  endif
  
  if (ndims(df._ridx) < 3),
    resu._ridx = permute(df._ridx, [min(perm(1), 2) min(perm(2:end))]);
  else
    resu._ridx = permute(df._ridx, perm);
  endif

  if (size(resu._ridx, 1) < resu._cnt(1)),
    %# adjust index size, if required
    resu._ridx(end+1:resu._cnt(1), :, :) = NA;
  endif

  if (2 == perm(1)),
    resu._name{1} = df._name{2};
    resu._over{1} = df._over{2};
    indc = length(resu._name{1});
    indi = resu._cnt(1) - indc;
    if (indi > 0),
      %# generate a name for the new row(s)
      dummy = cstrcat(repmat('_', indi, 1), ...
		      strjust(num2str(indc + (1:indi).'), 'left'));
      resu._name{1}(indc + (1:indi)) = cellstr(dummy);
      resu._over{1}(1, indc + (1:indi)) = true;
    endif 
  else
    resu._name{1} = df._name{1};
    resu._over{1} = df._over{1};
  endif

  
  if (2 == perm(2)),
    resu._name{2} = df._name{2};
    resu._over{2} = df._over{2};
  else
    resu._name{2} = df._name{1};
    resu._over{2} = df._over{1};
  endif
  
  if (isempty(resu._name{2})),
    indc = 0;
  else
    indc = length(resu._name{2});
  endif
  indi = resu._cnt(2) - indc;
  if (indi > 0),
    %# generate a name for the new column(s)
    dummy = cstrcat(repmat('_', indi, 1), ...
		    strjust(num2str(indc + (1:indi).'), 'left'));
    resu._name{2}(indc + (1:indi)) = cellstr(dummy);
    resu._over{2}(1, indc + (1:indi)) = true;    
  endif 
  
  if (2 != perm(2)),
    %# recompute the new type
    dummy = zeros(0, class(sum(cellfun(@(x) zeros(1, class(x(1))),\
				       df._data))));
    resu._type(1:resu._cnt(2)) = class(dummy);
    dummy = permute(df_whole(df), perm);
    for indi = 1:resu._cnt(2),
      resu._data{indi} = squeeze(dummy(:, indi, :));
      resu._rep{indi} = 1:size(resu._data{indi}, 2);
    endfor 
  else %# 2 == perm(2)
    if (1 == perm(1)), %# blank operation
      resu._type = df._type;
      resu._data = df._data;
      resu._rep = df._rep;
    else
      for indi = 1:resu._cnt(2),
	unfolded = df._data{indi}(:, df._rep{indi});
	resu._data{indi} = permute(unfolded, [2 1]);
	resu._rep{indi} = 1:size(resu._data{indi}, 2);
	resu._type{indi} = df._type{indi};
      endfor    
    endif
  endif

  resu._src = df._src;
  resu._cmt = df._cmt;

endfunction
