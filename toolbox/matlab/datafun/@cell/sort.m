function [y,ndx] = sort(x,dim)
%SORT   Sort for cell arrays of strings.
%   SORT(X) sorts the strings of X in ASCII dictionary order.
%
%   [Y,NDX] = SORT(X) also returns an column vector of indices, NDX, such
%   that Y = X(NDX).
%   
%   X must be a cell array whose elements are char arrays or empty
%   arrays.
%
%   See also SORTROWS.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.2 $  $Date: 2004/01/24 09:21:22 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following error checking code is to ensure that we throw a 
% meaningful error message when the SORT function is dispatched to
% the overloaded implementation for cell arrays.  This error checking
% code does not adversely impact the performance of cell/sort.

arrayIsNotCellstr  = ~iscellstr(x);
dimIsSpecified     = false;
dimNotNumericScalar= false;

try
    if nargin>1
        dimIsSpecified = true;
        dimNotNumericScalar = ~isnumeric(dim);
    end
    if any([arrayIsNotCellstr,...
            dimIsSpecified,...
            dimNotNumericScalar]);
        error(' ');
    end
    
catch
    if (arrayIsNotCellstr && dimNotNumericScalar && dimIsSpecified)
        if (iscell(x))
            error('MATLAB:sort:InputType',...
                'Input argument must be a cell array of strings.');
        else
            error('MATLAB:sort:InputType',...
                'DIM argument must be a numeric scalar.');
        end
    elseif (arrayIsNotCellstr && dimIsSpecified)
        error('MATLAB:sort:InputType',...
            'Input argument must be a cell array of strings.');
    elseif dimIsSpecified
        error('MATLAB:sort:DimIsSpecified',...
            'DIM argument not supported for cell arrays.');
    elseif arrayIsNotCellstr
        error('MATLAB:sort:InputType',...
              'Input argument must be a cell array of strings.');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isrow = ndims(x)==2 & size(x,1)==1;
x = x(:);
ndx = sortcellchar(x);
y = x(ndx);

if isrow
  y = y';
  ndx = ndx';
end












