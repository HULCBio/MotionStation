function output = prod(x, dim)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Only supports 1 and 2 dimensional matrices;
%    therefore, dimension argument must be 1 or 2.
           
% $INCLUDE(DOC) toolbox/eml/lib/matlab/prod.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:31 $

% This function can only have 1 or 2 input arguments
eml_assert(nargin > 0,  'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''prod'' is not defined for values of class ''' class(x) '''.']);

% If there's a second argument, enforce its type/value/size
if (nargin == 2)
    eml_assert(~isempty(dim), 'error', 'Dimension argument must be an integer scalar with value 1 or 2.');
    eml_assert(length(dim) == 1, 'error', 'Dimension argument must be an integer scalar with value 1 or 2.');
    eml_assert(dim == 1 || dim == 2, 'error', 'Dimension argument must be an integer scalar with value 1 or 2.');
end

if isempty(x),
    if (dim == 1),
	output = zeros(1,0);
    end,
    if (dim == 2),
	output = zeros(0,1);
    end;
    return;
end

%-----------------------------------
% Figure out dim if it's not specified.
%
% dim = 1: column-wise (add vertically)
% dim = 2: row-wise (add horizontally)
%
% Vector inputs:
%       If no dimension is specified:
%               - If x is a row vector, dim = 2
%               - If x is a column-vector, dim = 1
%
% Matrix inputs:
%       If no dim is sprcified, dim = 1
%-----------------------------------
if (nargin == 1)
    if (size(x,1) == 1 && size(x,2) > 1) %if x is a row vector
        dim = 2;
    else
        dim = 1;
    end
end

%--------------------------------
% Compute the class of the result
%--------------------------------
switch class(x)
    case 'single', resultClass = 'single';
    otherwise, resultClass = 'double';
end

%------------------
% Initialize output
%------------------
if (size(x,1) == 1 && size(x,2) > 1)
    % If x is a row vector
    if(dim == 1)
        out = zeros(1, size(x,2),resultClass);
    elseif (dim == 2)
        out = zeros(1,resultClass);
    end
elseif (size(x,1) > 1 && size(x,2) == 1)
    % If x is a column vector
    if(dim == 1)
        out = zeros(1,resultClass);
    elseif (dim == 2)
        out = zeros(size(x,1), 1,resultClass);
    end
elseif (size(x,1) > 1 && size(x,2) > 1)
    % If x is a matrix
    if(dim == 1)
        out = zeros(1, size(x,2),resultClass);
    elseif (dim == 2)
        out = zeros(size(x,1), 1,resultClass);
    end
elseif (size(x,1) == 1 && size(x,2) == 1)
    % If x is a scalar
    out = zeros(1,resultClass);
end
output = initVar(x, out);


%---------------
% Compute output 
%---------------
if (dim == 1)
    for colnum = 1:size(x,2)
        colprod = initVar(x,ones(1,1,resultClass));
        for rownum = 1:size(x,1)
            colprod = colprod * x(rownum, colnum);
        end
        output(1, colnum) = colprod;
    end
elseif (dim == 2)
    for rownum = 1:size(x,1)
        rowprod = initVar(x,ones(1,1,resultClass));
        for colnum = 1:size(x,2)
            rowprod = rowprod * x(rownum, colnum);
        end
        output(rownum,1) = rowprod;
    end
end


%----------------------------------
% Initialize var as real or complex 
%----------------------------------
function out = initVar(x,in)
    if(~isreal(x))
        out = complex(in);
    else
        out = in;
    end
    
    
function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
    
% [EOF]
