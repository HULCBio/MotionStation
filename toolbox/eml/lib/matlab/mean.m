function y = mean(x,dim)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/mean.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:26 $

eml_assert(nargin > 0, 'Not enough input arguments');
eml_assert(isfloat(x) || ischar(x), 'error', ['Function ''mean'' is not defined for values of class ''' class(x) '''.']);

x1 = double(x);

% If no dimension is supplied then find the mean along the first
% non-singleton dimension of 'x' (columnwise for matrix)
% dim ==1, implies find the mean of each column of data
% dim ==2, implies mean of each row of data

sz = size(x1);
r = sz(1);
if nargin == 1
    if r == 1;
        dim = 2;
    else
        dim = 1;
    end
end

eml_assert(isscalar(dim), 'error', 'Dimension must be a scalar');
eml_assert(dim == 1 || dim == 2,'Dimension must be either 1 or 2');

y = sum(x1,dim)/size(x1,dim);

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');


