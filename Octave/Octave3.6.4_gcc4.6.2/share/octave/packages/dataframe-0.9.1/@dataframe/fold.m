function resu = fold(df, dim, indr, indc)

  %# function resu = subasgn(df, S, RHS)
  %# The purpose is to fold a dataframe. Part from (1:indr-1) doesn't
  %# move, then content starting at indr is moved into the second,
  %# third, ... sheet. To be moved, there must be equality of rownames,
  %# if any, and of fields contained in indc.


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
  %# $Id: fold.m 9585 2012-02-05 15:32:46Z cdemills $
  %#
switch dim
  case 1
    [indr, nrow] = df_name2idx(df._name{1}, indr, df._cnt(1), 'row');
    [indc, ncol] = df_name2idx(df._name{2}, indc, df._cnt(2), 'column');
    
    if (indr(1) > 1),
      slice_size = indr(1) - 1;
      %# we can't use directly resu = df(1:slice_size, :, :)
      S.type = '()';
      S.subs = { 1:slice_size, ':', ':', 'dataframe'};
      resu = subsref(df, S);
      
      %# how many columns for each slice
      targets = cellfun(@length, df._rep);
      %# a test function to determine if the location is free
      for indj = 1:df._cnt(2),
	if (any(indj == indc)),
	  continue;
	endif
	switch df._type{indj}
	  case { 'char' }
	    testfunc{indj} = @(x, indr, indc) ...
		!isna(x{indr, indc});
	  otherwise
	    testfunc{indj} = @(x, indr, indc) ...
		!isna(x(indr, indc));
	endswitch
      endfor

      for indi = indr,
	%# where does this line go ?
	where = find(df._data{indc}(1:slice_size, 1) ...
		     == df._data{indc}(indi, 1));
	if (!isempty(where)),
	  %# transfering one line -- loop over columns
	  for indj = 1:df._cnt(2),
	    if any(indj == indc),
	      continue;
	    endif
	   
	    if (testfunc{indj}(resu._data{indj}, where, targets(indj))),
	      %# add one more sheet
	      resu = df_pad(resu, 3, 1, indj);
	      targets(indj) = targets(indj) + 1;
	    endif
	    %# transfer field
	    stop
	    resu._data{indj}(where, targets(indj)) = ...
		df._data{indj}(indi, 1);
	  endfor
	  %# update row index
	  resu._ridx(where, max(targets)) = df._ridx(indi);
	else
	  disp('line 65: FIXME'); keyboard;
	endif
      endfor

    else

      disp('line 70: FIXME '); keyboard
    endif


endswitch
