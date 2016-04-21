function [resu, idx] = isfield(df, name, strict)
  
  %# -*- texinfo -*-
  %# @deftypefn {Function File} [@var{resu}, @var{idx}] = isfield
  %# (@var{df}, @var{name}, @var{strict})
  %# Return true if the expression @var{df} is a dataframe and it
  %# includes an element matching @var{name}.  If @var{name} is a cell
  %# array, a logical array of equal dimension is returned. @var{idx}
  %# contains the column indexes of number of fields matching
  %# @var{name}. To enforce strict matching instead of regexp matching,
  %# set the third argument to 'true'.
  %# @end deftypefn 

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
  %# $Id: isfield.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if !isa(df, 'dataframe'),
    resu = false; return;
  endif

  if nargin <2 || nargin > 3,
    print_usage();
    resu = false; return;
  endif

  if 2 == nargin, strict = false; endif

  if isa(name, 'char'),
    if strict, %# use strmatch to get indexes
      for indi = size(name, 1):-1:1,
	dummy = strmatch(name(indi, :), df._name{2}, "exact");
	resu(indi, 1) = !isempty(dummy);
	for indj = 1:length(dummy),
	  idx(indi, indj) = dummy(indj);
	endfor
      endfor
    else
      for indi = size(name, 1):-1:1,
	try
	  dummy = df_name2idx(df._name{2}, name(indi, :), \
			      df._cnt(2), 'column');
	  resu(indi, 1) = !isempty(dummy);
	  for indj = 1:length(dummy),
	    idx(indi, indj) = dummy(indj);
	  endfor
	catch
	  resu(indi, 1) = false; idx(indi, 1) = 0;
	end_try_catch
      endfor
    endif
  elseif isa(name, 'cell'),
    if strict, %# use strmatch to get indexes
      for indi = size(name, 1):-1:1,
	dummy = strmatch(name{indi}, df._name{2}, "exact");
	resu{indi, 1} = !isempty(dummy);
	idx{indi, 1} = dummy;
      endfor
    else
      for indi = length(name):-1:1,
	try
	  dummy = df_name2idx(df._name{2}, name{indi}, \
			      df._cnt(2), 'column');
	  keyboard
	  resu{indi, 1} = !isempty(dummy); idx{indi, 1} = dummy;
	catch
	  resu{indi, 1} = false; cnt{indi, 1} = 0;
	end_try_catch
      endfor
    endif
  endif
endfunction
