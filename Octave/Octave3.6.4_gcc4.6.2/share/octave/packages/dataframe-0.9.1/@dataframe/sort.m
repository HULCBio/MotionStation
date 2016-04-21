function [resu, idx] = sort(df, varargin) 
  
  %# -*- texinfo -*-
  %# @deftypefn  {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x})
  %# @deftypefnx {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x}, @var{dim})
  %# @deftypefnx {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x}, @var{mode})
  %# @deftypefnx {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x}, @var{dim},  @var{mode})
  %# Return a copy of @var{x} with the elements arranged in increasing
  %# order.  For matrices, @code{sort} orders the elements in each column.
  %#
  %# For example:
  %# 
  %# @example
  %# @group
  %# sort ([1, 2; 2, 3; 3, 1])
  %#      @result{}  1  1
  %#          2  2
  %#          3  3
  %# 
  %# @end group
  %# @end example
  %# 
  %# The @code{sort} function may also be used to produce a matrix
  %# containing the original row indices of the elements in the sorted
  %# matrix.  For example:
  %# 
  %# @example
  %# @group
  %# [s, i] = sort ([1, 2; 2, 3; 3, 1])
  %#      @result{} s = 1  1
  %#             2  2
  %#             3  3
  %#      @result{} i = 1  3
  %#             2  1
  %#             3  2
  %# @end group
  %# @end example
  %# 
  %# If the optional argument @var{dim} is given, then the matrix is sorted
  %# along the dimension defined by @var{dim}.  The optional argument @code{mode}
  %# defines the order in which the values will be sorted.  Valid values of
  %# @code{mode} are `ascend' or `descend'.
  %# 
  %# For equal elements, the indices are such that the equal elements are listed
  %# in the order that appeared in the original list.
  %# 
  %# The @code{sort} function may also be used to sort strings and cell arrays
  %# of strings, in which case the dictionary order of the strings is used.
  %# 
  %# The algorithm used in @code{sort} is optimized for the sorting of partially
  %# ordered lists.
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
  %# $Id: sort.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if !isa(df, 'dataframe'),
    resu = []; return;
  endif

  dim = []; mode = [];
  vout= varargin;

  indi = 1; while indi <= length(varargin)
    if isnumeric(varargin{indi}),
      if !isempty(dim),
	print_usage('@dataframe/sort');
	resu = [];
	return
      else
	dim = varargin{indi};
	if 3 == dim, vout(indi) = 2; endif
      endif
    else
      if !isempty(mode),
	print_usage('@dataframe/sort');
	resu = [];
	return
      else
	sort = varargin{indi};
      endif
    endif
    indi = indi + 1;
  endwhile;

  if isempty(dim), dim = 1; endif;

  %# pre-assignation
  resu = struct(df); 
  
  switch(dim)
    case {1},
      for indi = 1:resu._cnt(2),
	[resu._data{indi}, idx(:, indi, :)] = sort\
	    (resu._data{indi}(:, resu._rep{indi}), varargin{:});
	resu._data{indi} = squeeze(resu._data{indi});
	resu._rep{indi} = 1:size(resu._data{indi}, 2);
      endfor
      if (all([1 == size(idx, 2) 1 == size(idx, 3)])),
	if (size(resu._ridx, 1) == resu._cnt(1)),
	  resu._ridx = resu._ridx(idx, :);
	endif
	if (!isempty(resu._name{1, 1})),
	  resu._name{1, 1} = resu._name{1, 1}(idx);
	  resu._over{1, 1} = resu._over{1, 1}(idx);
	endif
      else
	%# data where mixed
	resu._ridx = idx;
	resu._name{1, 1} = []; resu._over{1, 1} = [];
      endif

    case {2},
      error('Operation not implemented');
    case {3},
      for indi = 1:resu._cnt(2),
	[resu._data{1, indi}, idx(:, indi)] = sort(resu._data{1, indi}, vout(:));
      endfor
     otherwise
      error("Invalid dimension %d", dim); 
  endswitch
  
  dummy = dbstack();
  if (any(strmatch('quantile', {dummy.name}))),
    resu = df_whole(resu);
  else
    resu = dataframe(resu);
  endif

endfunction
