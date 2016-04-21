function y=subsref(x,varargin)
%SUBSREF Subscripted reference for GF arrays.
%   A(I) is an array formed from the elements of A specifed by the
%   subscript vector I.  The resulting array is the same size as I except
%   for the special case where A and I are both vectors.  In this case,
%   A(I) has the same number of elements as I but has the orientation of A.
%
%   A(I,J) is an array formed from the elements of the rectangular
%   submatrix of A specified by the subscript vectors I and J.  The
%   resulting array has LENGTH(I) rows and LENGTH(J) columns.  A colon
%   used as a subscript, as in A(I,:), indicates the entire column (or
%   row).

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.5 $  $Date: 2002/04/14 20:11:16 $ 


switch varargin{1}.type
case '()'
  y=x;
  y.x = y.x(varargin{1}.subs{:});
case '{}'
  error('{} reference not allowed')
case '.'
  switch varargin{1}.subs
  case 'x'
     y = x.x;
  case 'm'
     y = x.m;
  case 'prim_poly'
     y = x.prim_poly;
  otherwise
     error([ 'Invalid property name "' varargin{1}.subs '". The valid properties are x, m and prim_poly.'])
  end
end

