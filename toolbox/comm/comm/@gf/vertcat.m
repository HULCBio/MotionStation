function z=vertcat(varargin)
%VERTCAT Vertical concatenation [a; b; ...] of GF arrays.
%   [A;B] is the vertical concatenation of matrices A and B.  A and B must
%   have the same number of columns. Any number of matrices can be
%   concatenated within one pair of brackets.  Horizontal and vertical
%   concatenation can be combined together as in [1 2;3 4].
%
%   [A B; C] is allowed if the number of rows of A equals the number of
%   rows of B and the number of columns of A plus the number of columns
%   of B equals the number of columns of C.  The matrices in a
%   concatenation expression can themselves by formed via a
%   concatenation as in [A B;[C D]].  These rules generalize in a
%   hopefully obvious way to allow fairly complicated constructions.
%
%   See also HORZCAT.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:16:54 $ 

for k=1:length(varargin)
  if isa(varargin{k},'gf')
    m = varargin{k}.m;
    prim_poly = varargin{k}.prim_poly;
    break
  end
end
for k=1:length(varargin)
  if ~isa(varargin{k},'gf')
     varargin{k} = gf(varargin{k},m,prim_poly);
  end
end
z = varargin{1};
for k=2:length(varargin)
   z.x = [z.x; varargin{k}.x];
   if z.m~=varargin{k}.m
     error('Orders must match.')
   elseif z.prim_poly~=varargin{k}.prim_poly
     error('Primitive polynomials must match.')
   end
end




