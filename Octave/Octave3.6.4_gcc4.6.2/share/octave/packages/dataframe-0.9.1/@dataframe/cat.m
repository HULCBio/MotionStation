function resu = cat(dim, A, varargin)
  %# function resu = cat(dim, A, varargin)
  %# This is the concatenation operator for a dataframe object. "Dim"
  %# has the same meaning as ordinary cat. Next arguments may be
  %# dataframe, vector/matrix, or two elements cells. First one is taken
  %# as row/column name, second as data.

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
  %# $Id: cat.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if (!isa(A, 'dataframe')),
    A = dataframe(A);
  endif

  switch dim
    case 1
      resu = A;
          
      for indi = 1:length(varargin),
	B = varargin{indi};
	if !isa(B, 'dataframe'),
	  if iscell(B) && 2 == length(B),
	    B = dataframe(B{2}, 'rownames', B{1});
	  else
	    B = dataframe(B, 'colnames', inputname(2+indi));
	  endif
	endif
	if resu._cnt(2) != B._cnt(2),
	  error('Different number of columns in dataframes');
	endif
	%# do not duplicate empty names
	if !isempty(resu._name{1}) || !isempty(B._name{1}),
	  if length(resu._name{1}) < resu._cnt(1),
	    resu._name{1}(end+1:resu._cnt(1), 1) = {''};
	  endif
	  if length(B._name{1}) < B._cnt(1),
	    B._name{1}(end+1:B._cnt(1), 1) = {''};
	  endif
	  resu._name{1} = vertcat(resu._name{1}(:),  B._name{1}(:));
	  resu._over{1} = [resu._over{1} B._over{1}];
	endif
	resu._cnt(1) = resu._cnt(1) + B._cnt(1);
	if size(resu._ridx, 2) < size(B._ridx, 2),
	  resu._ridx(:, end+1:size(B._ridx, 2)) = NA;
	elseif size(resu._ridx, 2) > size(B._ridx, 2),
	  B._ridx(:, end+1:size(resu._ridx, 2)) = NA;
	endif
	resu._ridx = [resu._ridx; B._ridx];
	%# find data with same column names
	dummy = A._over{2} & B._over{2}; 
	indA = true(1, resu._cnt(2));
	indB = true(1, resu._cnt(2));
	for indj = 1:resu._cnt(2),
	  if (dummy(indj)),
	    indk = strmatch(resu._name{2}(indj), B._name{2}, 'exact');
	    if (~isempty(indk)),
	      indk = indk(1);
	      if ~strcmp(resu._type{indj}, B._type{indk}),
		error("Trying to mix columns of different types");
	      endif
	    endif
	  else
	    indk = indj;
	  endif
	  resu._data{indj} = [resu._data{indj}; B._data{indk}];
	  indA(indj) = false; indB(indk) = false;
	endfor
	if any(indA) || any(indB)
	  error('Different number/names of columns in dataframe');
	endif
	
      endfor
      
    case 2
      resu = A;

      for indi = 1:length(varargin),
	B = varargin{indi};
	if !isa(B, 'dataframe'),
	  if iscell(B) && 2 == length(B),
	    B = dataframe(B{2}, 'colnames', B{1});
	  else
	    B = dataframe(B, 'colnames', inputname(2+indi));
	  endif
	  B._ridx = resu._ridx; %# make them compatibles
	endif
	if resu._cnt(1) != B._cnt(1),
	  error('Different number of rows in dataframes');
	endif
	if any(resu._ridx(:) - B._ridx(:))
	  error('dataframes row indexes not matched');
	endif
	resu._name{2} = vertcat(resu._name{2}, B._name{2});
	resu._over{2} = [resu._over{2} B._over{2}];
	resu._data(resu._cnt(2)+(1:B._cnt(2))) = B._data;
	resu._type(resu._cnt(2)+(1:B._cnt(2))) = B._type;
	resu._cnt(2) = resu._cnt(2) + B._cnt(2);	
      endfor
      
    case 3
      resu = A;
      
      for indi = 1:length(varargin),
	B = varargin{indi};
	if (!isa(B, 'dataframe')),
	  if (iscell(B) && 2 == length(B)),
	    B = dataframe(B{2}, 'rownames', B{1});
	  else
	    B = dataframe(B, 'colnames', inputname(indi+2)); 
	  endif
	endif
	if (resu._cnt(1) != B._cnt(1)),
	  error('Different number of rows in dataframes');
	endif
	if (resu._cnt(2) != B._cnt(2)),
	  error('Different number of columns in dataframes');
	endif
	%# to be merged against 3rd dim, rownames must be equals, if
	%# non-empty. Columns are merged based upon their name; columns
	%# with identic content are kept.

	if size(resu._ridx, 2) < size(B._ridx, 2),
	  resu._ridx(:, end+1:size(B._ridx, 2)) = NA;
	elseif size(resu._ridx, 2) > size(B._ridx, 2),
	  B._ridx(:, end+1:size(resu._ridx, 2)) = NA;
	endif
	resu._ridx = cat(3, resu._ridx, B._ridx);
	%# find data with same column names
	indA = true(1, resu._cnt(2));
	indB = true(1, resu._cnt(2));
	dummy = A._over{2} & B._over{2}; 
	for indj = 1:resu._cnt(2),
	  if (dummy(indj)),
	    indk = strmatch(resu._name{2}(indj), B._name{2}, 'exact');
	    if (~isempty(indk)),
	      indk = indk(1);
	      if (~strcmp(resu._type{indj}, B._type{indk})),
		error("Trying to mix columns of different types");
	      endif
	    endif
	  else
	    indk = indj;
	  endif
	  if (all([isnumeric(resu._data{indj}) isnumeric(B._data{indk})])),
	    %# iterate over the columns of resu and B
	    op1 = resu._data{indj}; op2 = B._data{indk};
	    for ind2=1:columns(op2),
	      indr = false;
	      for ind1=1:columns(op1),
		if (all(abs(op1(:, ind1) - op2(:, ind2)) <= eps)),
		  resu._rep{indj} = [resu._rep{indj} ind1];
		  indr = true;
		  break;
		endif
	      endfor
	      if (!indr),
		%# pad in the second dim
		resu._data{indj} = [resu._data{indj}, B._data{indk}];
		resu._rep{indj} = [resu._rep{indj} 1+length(resu._rep{indj})];
	      endif
	    endfor
	  else
	    resu._data{indj} = [resu._data{indj} B._data{indk}];
	    resu._rep{indj} = [resu._rep{indj} 1+length(resu._rep({indj}))];
	  endif
	  indA(indj) = false; indB(indk) = false;
	endfor
	if (any(indA) || any(indB)),
	  error('Different number/names of columns in dataframe');
	endif
      endfor
     
      resu = df_thirddim(resu);
      
    otherwise
      error('Incorrect call to cat');
  endswitch
  
  %#  disp('End of cat'); keyboard
endfunction
