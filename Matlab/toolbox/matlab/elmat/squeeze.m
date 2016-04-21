function b = squeeze(a)
%SQUEEZE Remove singleton dimensions.
%   B = SQUEEZE(A) returns an array B with the same elements as
%   A but with all the singleton dimensions removed.  A singleton
%   is a dimension such that size(A,dim)==1.  2-D arrays are
%   unaffected by squeeze so that row vectors remain rows.
%
%   For example,
%       squeeze(rand(2,1,3))
%   is 2-by-3.
%
%   See also SHIFTDIM.

%   Clay M. Thompson 3-15-94
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2003/05/01 20:41:59 $

if nargin==0 
  error('MATLAB:squeeze:NotEnoughInputs', 'Not enough input arguments.'); 
end

if ndims(a)>2,
  siz = size(a);
  siz(siz==1) = []; % Remove singleton dimensions.
  siz = [siz ones(1,2-length(siz))]; % Make sure siz is at least 2-D
  b = reshape(a,siz);
else
  b = a;
end
