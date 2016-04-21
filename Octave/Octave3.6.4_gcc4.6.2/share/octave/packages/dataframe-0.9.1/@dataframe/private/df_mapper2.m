function resu = df_mapper2(func, df, varargin)
  %# resu = df_mapper2(func, df)
  %# small interface to iterate some vector func over the elements of a
  %# dataframe. This one is specifically adapted to all functions where
  %# the first argument, if numeric, is 'dim'.

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
  %# $Id: df_mapper2.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  dim = 1; resu = []; vout = varargin;
  
  %# take care of constructs as min(x, [], dim)  
  if (!isempty(varargin)),
    indk = 1; while indk <= length(varargin),
      if (isnumeric(varargin{indk})),
	if (isempty(varargin{indk})),
	  indk = indk + 1; continue;
	endif
	dim = varargin{indk}; 
	%# the "third" dim is the second on stored data
	if 3 == dim, vout(indk) = 2; endif
      endif
      break;
    endwhile
  endif

  switch(dim)
    case {1},
      resu = df_colmeta(df);
      for indi = 1:df._cnt(2),
	resu._data{indi} = feval(func, df._data{indi}(:, df._rep{indi}), \
				 vout{:});
	resu._rep{indi} = 1:size(resu._data{indi}, 2);
      endfor
      resu._cnt(1) = max(cellfun('size', resu._data, 1));
      if (resu._cnt(1) == df._cnt(1)),
	%# the func was not contracting
	resu._ridx = df._ridx;
	resu._name{1} = resu._name{1}; resu._over{1} = resu._over{1};
      endif
    case {2},
      error('Operation not implemented');
    case {3},
      resu = df_allmeta(df); 
      for indi = 1:df._cnt(2),
	resu._data{indi} = feval(func, df._data{indi}(:, df._rep{indi}), \
				 vout{:});
	resu._rep{indi} = 1:size(resu._data{indi}, 2);
      endfor
    otherwise
      error("Invalid dimension %d", dim); 
  endswitch

  resu = df_thirddim(resu);

endfunction
