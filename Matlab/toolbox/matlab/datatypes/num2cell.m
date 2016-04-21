function c = num2cell(a,dims)
%NUM2CELL Convert numeric array into cell array.
%   C = NUM2CELL(A) converts the array A into a cell array by
%   placing each element of A into a separate cell.  C will
%   be the same size as A.
%
%   C = NUM2CELL(A,DIMS) converts the array A into a cell array by
%   placing the dimensions specified by DIMS into separate cells.  
%   C will be the same size as A except that the dimensions matching
%   DIMS will be 1. For example, NUM2CELL(A,2) places the rows of A
%   into separate cells.  Similarly NUM2CELL(A,[1 3]) places the
%   column-depth pages of A into separate cells.
%
%   NUM2CELL works for all array types.
%
%   Use CELL2MAT or CAT(DIM,C{:}) to convert back.
%
%   See also MAT2CELL, CELL2MAT

%   Clay M. Thompson 3-15-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/04/10 23:25:30 $
if nargin<1
    error(nargchk(1,2,nargin));
end
if isempty(a)
    c = {}; 
    return
end
if nargin==1
    c = cell(size(a));
    for i=1:numel(a)
        c{i} = a(i);
    end 
    return
end

% Size of input array
siz = [size(a),ones(1,max(dims)-ndims(a))];

% Create remaining dimensions vector
rdims = 1:max(ndims(a),max(dims));
rdims(dims) = []; % Remaining dims

% Size of extracted subarray
bsize = siz;
bsize(rdims) = 1; % Set remaining dimensions to 1

% Size of output cell
csize = siz;
csize(dims) = 1; % Set selected dimensions to 1
c = cell(csize);

% Permute A so that requested dims are the first few dimensions
a = permute(a,[dims rdims]); 

% Make offset and index into a
offset = prod(bsize);
ndx = 1:prod(bsize);
for i=0:prod(csize)-1,
  c{i+1} = reshape(a(ndx+i*offset),bsize);
end
