function varargout = find(df, varargin) 

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
  %# $Id: find.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  switch nargout
    case {0, 1}
      resu = []; mz = max(cellfun(@length, df._rep));
      for indc = 1:df._cnt(2),
	[indr, inds] = feval(@find, df._data{indc}(:, df._rep{indc}));
	%# create a vector the same size as indr
	dummy = indr; dummy(:) = indc;
	resu = [resu; sub2ind([df._cnt(1:2) mz], indr, dummy, inds)];
      endfor
      varargout{1} = sort(resu);
    case 2
      nz = 0; idx_i = []; idx_j = [];
      for indc = 1:df._cnt(2),
	[dum1, dum2] = feval(@find, df._data{indc}(:, df._rep{indc}));
	idx_i = [idx_i; dum1];
	idx_j = [idx_j; nz + dum2];
	nz = nz + df._cnt(1)*length(df._rep{indc});
      endfor
      varargout{1} = idx_i; varargout{2} = idx_j;
    case 3
      nz = 0; idx_i = []; idx_j = []; val = [];
      for indc = 1:df._cnt(2),
	[dum1, dum2, dum3] = feval(@find, df._data{indc}(:, df._rep{indc}));
	idx_i = [idx_i; dum1];
	idx_j = [idx_j; nz + dum2];
	val = [val; dum3];
	nz = nz + df._cnt(1)*length(df._rep{indc});
      endfor
      varargout{1} = idx_i; varargout{2} = idx_j; varargout{3} = val;
    otherwise
      print_usage('find');
  endswitch

endfunction
