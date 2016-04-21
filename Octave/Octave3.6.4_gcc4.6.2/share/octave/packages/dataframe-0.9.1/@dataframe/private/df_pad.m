function df = df_pad(df, dim, n, coltype=[])
  %# function resu = df_pad(df, dim, n, coltype = [])
  %# given a dataframe, insert n rows or columns, and adjust everything
  %# accordingly. Coltype is a supplemental argument:
  %# dim = 1 => not used
  %# dim = 2 => type of the added column(s)
  %# dim = 3 => index of columns receiving a new sheet (default: all)

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
  %# $Id: df_pad.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  switch dim
    case 1
      if (!isempty(df._name{1})),
	if (length(df._name{1}) < df._cnt(1)+n),
	  %# generate a name for the new row(s)
	  df._name{1}(df._cnt(1)+(1:n), 1) = {'_'};
	  df._over{1}(1, df._cnt(1)+(1:n), 1) = true;
	endif
      endif
      %# complete row indexes: by default, row number.
      if (isempty(df._ridx)),
	dummy = (1:n)(:);
      else
	dummy = vertcat(df._ridx, repmat(size(df._ridx, 1)+(1:n)(:), ...
					 1, size(df._ridx, 2))); 
      endif
      df._ridx = dummy; 
      %# pad every line
      for indi = 1:min(size(df._data, 2), df._cnt(2)),
	neff = n + df._cnt(1) - size(df._data{indi}, 1);
	if (neff > 0),
	  m = size(df._data{indi}, 2);
	  switch df._type{indi}
	    case {'char'}
	      dummy = {}; dummy(1:neff, 1:m) = NA;
	      dummy = vertcat(df._data{indi}, dummy);
	    case { 'double' }
	      dummy = vertcat(df._data{indi}, repmat(NA, neff, m));
	    otherwise
	      dummy = cast(vertcat(df._data{indi}, repmat(NA, neff, m)), ...
			   df._type{indi});
	  endswitch
	  df._data{indi} = dummy;
	endif
      endfor
      df._cnt(1) = df._cnt(1) + n;

    case 2
      %# create new columns
      if (isempty(coltype))
	error("df_pad: dim equals 2, and coltype undefined");
      endif
      if (length(n) > 1), %#second value is an offset
	indc =  n(2); n = n(1);
	if (indc < df._cnt(2)),
	  %# shift to the right
	  df._name{2}(n + (indc+1:end)) =  df._name{2}(indc+1:end);
	  df._over{2}(n + (indc+1:end)) =  df._over{2}(indc+1:end);
	  dummy = cstrcat(repmat('_', n, 1), ...
			  strjust(num2str(indc + (1:n).'), 'left'));
	  df._name{2}(indc + (1:n)) = cellstr(dummy);	 
  	  df._over{2}(indc + (1:n)) = true;
	  df._type(n+(indc+1:end)) = df._type(indc+1:end);
	  df._type(indc + (1:n)) = NA;
	  df._data(n + (indc+1:end)) = df._data(indc+1:end);
	  df._rep(n + (indc+1:end)) = df._rep(indc+1:end);
	  df._data(indc + (1:n)) = NA;
	  df._rep(indc + (1:n)) = 1;
	endif
      else
	%# add new values after the last column
	indc = min(size(df._data, 2), df._cnt(2)); 
      endif
      if (!isa(coltype, 'cell')), coltype = {coltype}; endif
      if (isscalar(coltype) && n > 1),
	coltype = repmat(coltype, 1, n);
      endif
      for indi = (1:n),
	switch coltype{indi}
	  case {'char'}
	    dummy = {repmat(NA, df._cnt(1), 1) }; 
	    dummy(:, 1) = '_';
	  case { 'double'}
	    dummy = repmat(NA, df._cnt(1), 1);
	  case {'logical'} %# there is no NA in logical type
	    dummy = repmat(false, df._cnt(1), 1);
	  otherwise
	    dummy = cast(repmat(NA, df._cnt(1), 1), coltype{indi});
	endswitch
	df._data{indc+indi} = dummy;
	df._rep{indc+indi} = 1;
	df._type{indc+indi} = coltype{indi};
      endfor
   
      if (size(df._data, 2) > df._cnt(2)),
	df._cnt(2) =  size(df._data, 2);
      endif
      if (length(df._name{2}) < df._cnt(2)),
	%# generate a name for the new column(s)
	dummy = cstrcat(repmat('_', n, 1), ...
			strjust(num2str(indc + (1:n).'), 'left'));
	df._name{2}(indc + (1:n)) = cellstr(dummy);
	df._over{2}(1, indc + (1:n)) = true;
      endif   
      
    case 3
      if (n <= 0), return; endif
      if (isempty(coltype)),
	coltype = 1:df._cnt(2);
      endif
      dummy = max(n+cellfun(@length, df._rep(coltype)));
      if (size(df._ridx, 2) < dummy),
	df._ridx(:, end+1:dummy) = NA;
      endif
      for indi = coltype,
	switch df._type{indi}
	  case {'char'}
	    if (isa(df._data{indi}, 'char')),
	      dummy = horzcat(df._data{indi}(:, df._rep{indi}), \
			      {repmat(NA, df._cnt(1), 1)});
	    else
	      dummy = df._data{indi};
	    endif
	  case { 'double' }
	    dummy = horzcat(df._data{indi}(:, df._rep{indi}), \
			    repmat(NA, df._cnt(1), 1));
	  case { 'logical' }
	    %# there is no logical 'NA' -- fill empty elems with false
	    dummy = horzcat(df._data{indi}(:, df._rep{indi}), \
			    repmat(false, df._cnt(1), 1));
	  otherwise
	    dummy = cast(horzcat(df._data{indi}(:, df._rep{indi}), \
				 repmat(NA, df._cnt(1), 1)), \
			 df._type{indi});
	endswitch
	df._data{indi} = dummy;
	df._rep{indi} = [df._rep{indi} length(df._rep{indi})+ones(1, n)];
      endfor
        df =  df_thirddim(df);
    otherwise
      error('Invalid dimension in df_pad');
  endswitch

endfunction		
