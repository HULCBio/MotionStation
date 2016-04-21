## Copyright (C) 2012 Robert T. Short <octave@phaselockedsystems.com>
##
## This is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your
## option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{y1}, @dots{}] =} tablify (@var{x1}, @dots{})
##
## @noindent
## Create a table out of the input arguments, if possible.  The table is
## created by extending row and column vectors to like dimensions.  If
## the dimensions of input vectors are not commensurate an error will
## occur. Dimensions are commensurate if they have the same number of
## rows and columns, a single row and the same number of columns, or the
## same number of rows and a single column.  In other words, vectors
## will only be extended along singleton dimensions.
##
## @noindent
## For example:
##
## @example 
## @group
## [a, b] = tablify ([1 2; 3 4], 5) 
## @result{} a = [ 1, 2; 3, 4 ] 
## @result{} b = [ 5, 5; 5, 5 ] 
## @end group 
## @end example
## @example 
## @group
## [a, b, c] = tablify (1, [1 2 3 4], [5;6;7]) 
## @result{}
## b = [ 1 1 1 1; 1 1 1 1; 1 1 1 1] 
## @result{} b = [ 1 2 3 4; 1 2 3 4; 1 2 3 4] 
## @result{} c = [ 5 5 5 5; 6 6 6 6; 7 7 7 7 ] 
## @end group 
## @end example
##
## @noindent
## The following example attempts to expand vectors that do not have
## commensurate dimensions and will produce an error.
##
## @example 
## @group
## tablify([1 2],[3 4 5]) 
## @end group 
## @end example
##
## @noindent
## Note that use of array operations and broadcasting is more efficient
## for many situations.
##
## @seealso {common_size}
##
## @end deftypefn

## Author: Robert T. Short
## Created: 3/6/2012

function [varargout] = tablify (varargin)

  if (nargin < 2)
    varargout = varargin;
    return;
  endif

  empty = cellfun (@isempty, varargin);

  nrows = cellfun (@rows, varargin(~empty));
  ridx  = nrows>1;
  if (any(ridx))
    rdim = nrows(ridx)(1);
  else
    rdim = 1;
  endif

  ncols = cellfun (@columns, varargin(~empty));
  cidx  = ncols>1;
  if (any(cidx))
    cdim = ncols(cidx)(1);
  else
    cdim = 1;
  endif

  if ( any(nrows(ridx) != rdim ) || any(ncols(cidx) != cdim ))
    error('tablify: incommensurate sizes');
  endif

  varargout        = varargin;
  varargout(~ridx) = cellindexmat(varargout(~ridx),ones(rdim,1),':');
  varargout(~cidx) = cellindexmat(varargout(~cidx),':',ones(1,cdim));

endfunction

%!error tablify([1,2],[3,4,5])
%!error tablify([1;2],[3;4;5])

%!test
%! a = 1; b = 1; c = 1;
%! assert(tablify(a),a);
%! [x,y,z]=tablify(a,b,c);
%! assert(x,a);
%! assert(y,b);
%! assert(z,c);

%!test
%! a = 1; b = [1 2 3];
%! [x,y]=tablify(a,b);
%! assert(x,[1 1 1]);
%! assert(y,[1 2 3]);

%!test
%! a = 1; b = [1;2;3];
%! [x,y]=tablify(a,b);
%! assert(x,[1;1;1]);
%! assert(y,[1;2;3]);

%!test
%! a = [1 2]; b = [1;2;3]; c=1;
%! [x,y,z]=tablify(a,b,c);
%! assert(x,[1 2; 1 2; 1 2]);
%! assert(y,[1 1; 2 2; 3 3]);
%! assert(z,[1 1; 1 1; 1 1]);

%!test
%! a = [1 2]; b = [1;2;3]; c=[2 3];
%! [x,y,z]=tablify(a,b,c);
%! assert(x,[1 2; 1 2; 1 2]);
%! assert(y,[1 1; 2 2; 3 3]);
%! assert(z,[2 3; 2 3; 2 3]);

%!test
%! a = [1 2]; b = [1;2;3]; c=[];
%! [x,y,z]=tablify(a,b,c);
%! assert(x,[1 2; 1 2; 1 2]);
%! assert(y,[1 1; 2 2; 3 3]);
%! assert(z,[]);

