function [minval, indx] = min(x,y,dim)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Only supports dimensions of 1 or 2. 
% 2) Cannot handle NaN(s).
% 3) Does not handle complex.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/@double/min.m $
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/22 01:35:47 $
 
eml_assert(nargin > 0,'error','Not enough input arguments.');
eml_assert(isreal(x),'Complex inputs to MIN are not supported.');
if (nargin == 2)
    eml_assert(eml_all(size(x) == size(y)) | (length(x) == 1) | (length(y) == 1),'error','Matrix dimensions must agree.'); 
    eml_assert(nargout <= 1,'error','Too many output arguments.');
    eml_assert(isreal(y),'Complex inputs to MIN are not supported.');
end
if (nargin == 3)
    eml_assert(isempty(y),'error','MIN with two matrices to compare and a working dimension is not supported.');
    eml_assert(dim <= 2,'error','Value of dim can be either 1 or 2 for input');
end

% if the input is complex, then we should take the absolute values of the
% input, and then perform the min on those values. still to implement ...
% xxx

% computes min along columns
nrows = size(x,1);
ncols = size(x,2);
if isempty(x)  %find out appropriate minimum value when x is a non-empty vector (matrix)
    minval = x;  % handle the case when x is an empty vector.
else    
    switch (nargin)
        case 1
            % Handle the case when input is a vector. 
            % The only difference in the 2 conditional loops is that nrows
            % and ncols are swapped. 
            if (nrows == 1)
                % This means that the input is a vector and we need to find min along
                % the non-singleton dimension. 
                [minval,indx]  = findmin(x,nrows, ncols);
                
            else  
                [minval,indx]  = findmin(x,ncols, nrows);
            end
            
        case 2
            % The only difference between the 2 conditional loops is that the x
            % and y vectors have been swapped, correspondingly nrows and ncols
            % have been swapped too. 
            if ((length(x) == 1) && (length(y(:)) > 1))
                minval = handle2nargin(y,x);
            else
                minval = handle2nargin(x,y);
            end
            
        case 3
            if(dim == 2)
                minval = zeros(nrows,1,class(x));
                indx   = zeros(nrows,1);
                for p = 1:nrows
                    minval(p) = x(p);
                    indx(p)   = 1;
                    for q = 1:ncols
                        offset = (q-1)*nrows + p;
                        if (x(offset) < minval(p))
                            minval(p) = x(offset);
                            indx(p) = q;
                        end
                    end
                end
            else
                [minval,indx]  = findmin(x,ncols, nrows);
            end
    end
end
%if(0)
% Comment out until G165192 is fixed by Akernel
switch (nargin)
    case 1
        eml_ignore('mlmin = builtin(''min'',x);');
        eml_ignore('R_mlmin = 0==abs(minval-mlmin);');
        eml_ignore(eml_assert(       ... % when in MATLAB, assert
            eml_all(R_mlmin)              ... % that results are within tolerance
            | eml_all(isnan(mlmin(~R_mlmin))) ... % but allow for NaN(s)
            | eml_all(isinf(mlmin(~R_mlmin))) ... % but allow for inf(s)
            ));
    case 2
        eml_ignore('mlmin = builtin(''min'',x,y);');
        eml_ignore('R_mlmin = 0==abs(minval-mlmin);');
        eml_ignore(eml_assert(       ... % when in MATLAB, assert
            eml_all(R_mlmin)              ... % that results are within tolerance
            | eml_all(isnan(mlmin(~R_mlmin))) ... % but allow for NaN(s)
            | eml_all(isinf(mlmin(~R_mlmin))) ... % but allow for inf(s)
            ));
    case 3
        eml_ignore('mlmin = builtin(''min'',x,[],dim);');
        eml_ignore('R_mlmin = 0==abs(minval-mlmin);');
        eml_ignore(eml_assert(       ... % when in MATLAB, assert
            eml_all(R_mlmin)              ... % that results are within tolerance
            | eml_all(isnan(mlmin(~R_mlmin))) ... % but allow for NaN(s)
            | eml_all(isinf(mlmin(~R_mlmin))) ... % but allow for inf(s)
            ));
%end
end

%%%%%%%%
function [minimum_value,index_value] = findmin(x,dim1, dim2)
minimum_value = zeros(1,dim1,class(x));
index_value   = zeros(1,dim1);
for p = 1:dim1
    firstelem = (p-1)*dim2+1;
    minimum_value(p) = x(firstelem);
    index_value(p)   = 1;
    % WISH: should actually be 2:dim2, but eML complains in case of dim2 == 1. 
    for q = 1:dim2
        offset = (p-1)*dim2+q;
        if (x(offset) < minimum_value(p))
            minimum_value(p) = x(offset);
            index_value(p) = q;
        end
    end
end

%%%%%%%%
function minimum_value = handle2nargin(in1,in2)            
nrows = size(in1,1);
ncols = size(in1,2);
if isreal(in1),
    minimum_value = zeros(nrows,ncols,class(in1));
else
    minimum_value = zeros(nrows,ncols,class(in1)) + 0i;
end;
for q = 1:ncols
    for p = 1:nrows
        if (length(in2) == 1)
            ytemp = in2;
        else
            ytemp = in2(p,q);
        end
        if (in1(p,q) < ytemp)
            minimum_value(p,q) = in1(p,q);
        else
            minimum_value(p,q) = ytemp;
        end
    end
end


