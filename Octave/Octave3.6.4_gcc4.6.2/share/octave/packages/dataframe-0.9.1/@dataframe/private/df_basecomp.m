function [A, B, C] = df_basecomp(A, B, itercol=true, func=@plus);

  %# function [A, B, C] = df_basecomp(A, B, itercol)
  %# Basic size and metadata compatibility verifications for
  %# two-arguments operations on dataframe. Returns a scalar, a matrix,
  %# or a dataframe. Cell arrays are converted to df. Third output
  %# contains a merge of the metadata.

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
  %# $Id: df_basecomp.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if 1 == length(itercol), 
    strict = false;
  else
    strict = itercol(2); itercol = itercol(1);
  endif

  if (iscell(A)), A = dataframe(A); endif
  if (iscell(B)), B = dataframe(B); endif  

  switch (func2str(func)),
    case 'bsxfun'
      %# bsxfun compatibility rule: if there is at least one singleton
      %# dim, the smallest is repeated to reach the size of the
      %# greatest. Otherwise, all dims must be equal.
      if (any(size(A)(1:2) != size(B)(1:2)))
	if (!any (1 == [size(A) size(B)]))
	  error('bsxfun: both arguments must have the same dim, of one of them must have at least one singleton dim');
	else
	  Csize = max([size(A)(1:2); size(B)(1:2)]);
	endif
      else
	Csize = size(A)(1:2);
      endif
    case 'mldivide'
      if (isscalar(A)), 
	Csize = size(B)(1:2);
      else
        if (size(A, 1) != size(B, 1)),
	  error("Non compatible row sizes (op1 is %dx%d, op2 is %dx%d)",\
		size(A), size(B)(1:2));
	endif
	Csize = [size(A, 2) size(B, 2)];
      endif
    otherwise
      %# if strict is set, B may not be non-scalar vs scalar
      if ((!(isscalar(A) || isscalar(B)))||(strict && isscalar(A))),
	if (itercol), %# requires full compatibility
	  Csize = size(A)(1:2);
	  if (any(Csize - size(B)(1:2))),
	    %# disp([size(A) size(B)])
	    error("Non compatible row and columns sizes (op1 is %dx%d, op2 is %dx%d)",\
		  Csize, size(B));
	  endif
	else %# compatibility with matrix product
	  if (size(A, 2) - size(B, 1)),
	    error("Non compatible columns vs. rows size (op1 is %dx%d, op2 is %dx%d)",\
		  size(A)(1:2), size(B)(1:2));
	  endif
	  Csize = [size(A, 1) size(B, 2)];
	endif
      endif
  endswitch

  if !(isscalar(A) || isscalar(B))
    C = [];
    if (isa(A, 'dataframe'))
      if (nargout > 2 && all(Csize == size(A)(1:2))),
	C = df_allmeta(A, Csize);
      endif         
      if (isa(B, 'dataframe'))
	if (nargout > 2 && isempty(C) && all(Csize == size(B)(1:2))),
	  C = df_allmeta(B, Csize);
	endif
	if (strict),
	  %# compare indexes if both exist
	  if (!isempty(A._ridx))
	    if (!isempty(B._ridx) && itercol),
	      if (any(A._ridx-B._ridx)),
		error("Non compatible indexes");
	      endif
	    endif
	  else
	    if (nargout > 2 && itercol), C._ridx = B._ridx; endif
	  endif
	  
	  if (itercol),
	    idxB = 1; %# row-row comparison
	  else
	    idxB = 2; %# row-col comparsion
	  endif
	  
	  if (!isempty(A._name{1})) 
	    if (!isempty(B._name{idxB}))
	      dummy = !(strcmp(cellstr(A._name{1}), cellstr(B._name{idxB}))\
			| (A._over{1}(:)) | (B._over{idxB}(:)));
	      if (any(dummy)),
		if (itercol),
		  error("Incompatible row names");
		else
		  error("Incompatible row vs. column names");
		endif
	      endif
	      dummy = A._over{1} > B._over{idxB};
	      if (any(dummy)),
		C._name{1}(dummy) = B._name{idxB}(dummy);
		C._over{1}(dummy) = B._over{idxB}(dummy);
	      endif
	    endif
	  else
	    if (nargout > 2), 
	      C._name{1} = B._name{idxB}; C._over{1} = B._over{idxB};
	    endif
	  endif
	  
	  idxB = 3-idxB;
	  
	  if (!isempty(A._name{2}))
	    if (!isempty(B._name{idxB}))
	      dummy = !(strcmp(cellstr(A._name{2}), cellstr(B._name{2}))\
			| (A._over{2}(:)) | (B._over{2}(:)));
	      if (any(dummy)),
		if (itercol),
		  error("Incompatible column vs row names");
		else
		  error("Incompatible column names");
		endif
	      endif
	      dummy = A._over{2} > B._over{idxB};
	      if (any(dummy)),
		C._name{2}(dummy) = B._name{idxB}(dummy);
		C._over{2}(dummy) = B._over{idxB}(dummy);
	      endif
	    endif
	  else
	    if (nargout > 2 && !isempty(B._name{idxB})),
	      C._name{2} = B._name{idxB}; C._over{2} = B._over{idxB}; 
	    endif
	  endif
	endif

	if (isempty(A._src) && nargout > 2 && !isempty(B._src)), 
	  C._src = B._src;
	endif
	if (isempty(A._cmt) && nargout > 2 && !isempty(B._cmt)), 
	  C._cmt = B._cmt;
	endif
      else %# B is not a df
	if (nargout > 2 && isempty(C)),
	  C = df_allmeta(A);
	endif
      endif
    else %# A is not a df
      if (nargout > 2), 
	if (all(Csize==size(B)(1:2))),
	  C = df_allmeta(B, Csize); 
	else
	  C = df_allmeta(B); 
	endif         
      endif
    endif
  else %# both arg are  scalar
    if (nargout > 2),
      if (isa(A, 'dataframe')) 
	C = df_allmeta(A);     
      else
	C = df_allmeta(B); 
      endif
    endif
  endif
  
endfunction
