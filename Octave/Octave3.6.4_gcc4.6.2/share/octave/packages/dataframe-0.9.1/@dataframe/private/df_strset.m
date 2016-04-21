function [x, over] = df_strset(x, over, S, RHS, pad = ' ')
  %# x = df_strset(x, over, S, RHS, pad = " ")
  %# replaces the strings in cellstr x at indr by strings at y. Adapt
  %# the width of x if required. Use x 'over' attribute to display a
  %# message in case strings are overwritten.

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
  %# $Id: df_strset.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  %# adjust x size, if required
  if isnull(RHS),
    %# clearing
    if isempty(S),
      x = cell(0, 1); over = zeros(1, 0);
      return
    endif
    dummy = S; dummy(1).subs(2:end) = [];
    over = builtin('subsasgn', over, dummy, true);
  else
    if isempty(S), %# complete overwrite
      if ischar(RHS), RHS = cellstr(RHS); endif
      nrow = length(RHS);
      if any(~over(nrow)),
	warning('going to overwrite names');
      endif
      x(1:nrow) = RHS;
      over(1:nrow) = false;
      if nrow < length(x),
	x(nrow+1:end) = {pad};
      endif
      return
    else
      dummy = S(1); dummy.subs(2:end) = []; % keep first dim only
      if any(~(builtin('subsref', over, dummy)));
	warning('going to overwrite names');
      endif
      over = builtin('subsasgn', over, dummy, false);
    endif
  endif

  %# common part
  if ischar(RHS) && length(S(1).subs) > 1, 
    %# partial accesses to a char array
    dummy = char(x);
    dummy = builtin('subsasgn', dummy, S, RHS);
    if isempty(dummy),
      x = cell(0, 1); over = zeros(1, 0);
      return
    endif
    if size(dummy, 1) == length(x),
      x = cellstr(dummy);
      return
    endif
    %# partial clearing gone wrong ? retry
    RHS = { RHS }; 
  endif
  x = builtin('subsasgn', x, S, RHS);
    
endfunction
