function output = sum(x, dimension, outClass)
% Embedded MATLAB Library function.
%
% Limitations:
%
% 1) It is not consistent with MATLAB on empty matrices with other
%    dimensions, e.g. sum(zeros(0,4),1) => [0 0 0 0]

% $INCLUDE(DOC) toolbox/eml/lib/matlab/sum.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:42 $
% Comments:
% Scalar rounding needs a proper rewrite.

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x) || ischar(x) || isa(x,'logical'), 'error', ['Function ''sum'' is not defined for values of class ''' class(x) '''.']);

% Unpack inputs
switch nargin
case 1, 
    dim     = getDimFromInput(x);
    classin = getClassFromInput(x);
case 2,
    % Second input can be a dimension or class string
    if(ischar(dimension))
        dim     = getDimFromInput(x);
        classin = dimension;
    else
        dim     = dimension;
        classin = getClassFromInput(x);
    end
case 3,
    dim     = dimension;
    classin = outClass;
end    

% Validate dimension
eml_assert(isscalar(dim), 'error', 'Dimension argument must be a scalar with value 1 or 2');
eml_assert(dim == 1 || dim == 2, 'error', 'Dimension argument must be one or two.');

% Vaidate class
eml_assert(ischar(classin), 'error', 'Class argument must be a string');
eml_assert(strcmp(classin,'double') || strcmp(classin,'native'), 'error', 'Trailing string input must be ''double'' or ''native''.');

switch classin
case 'native', classout = class(x);
case 'double', classout = 'double';
end

%-------------------------
% Handle empty first input
%-------------------------
if (isempty(x))
    if (nargin == 1)
        output = initVar(x, zeros(1,1,classout));
    else
        if(dim == 1)
            output = initVar(x, zeros(1,0,classout));
        else
            output = initVar(x, zeros(0,1,classout));
        end
    end
    return;
end

%------------------
% Initialize output
%------------------
if (dim == 1)
    output = initVar(x, zeros(1, size(x,2), classout));
else
    output = initVar(x, zeros(size(x,1), 1, classout));
end

%---------------
% Compute output
%---------------
if (dim == 1)
    for colnum = 1:size(x,2)
        colsum = initVar(x,zeros(1,1,classout));
        for rownum = 1:size(x,1)
            colsum = colsum + cast(x(rownum, colnum), classout);
        end
        output(1, colnum) = colsum;
    end
else
    for rownum = 1:size(x,1)
        rowsum = initVar(x,zeros(1,1,classout));
        for colnum = 1:size(x,2)
            rowsum = rowsum + cast(x(rownum, colnum), classout);
        end
        output(rownum,1) = rowsum;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize var as real or complex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = initVar(x,in)
    if(~isreal(x))
        out = complex(in);
    else
        out = in;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure out if input is a float
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get output dimension if input dimension is unspecified
% If xIn is a row vector, output dimension is 2,
% otherwise it's 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dim = getDimFromInput(xIn)
    dim = 1;
    if (size(xIn,1) == 1 && size(xIn,2) > 1)
        dim = 2;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get classin based on input type.
% From MATLAB's help on SUM:
%     If X is floating point, that is double or single, S is
%     accumulated natively, that is in the same class as X,
%     and S has the same class as X. If X is not floating point,
%     S is accumulated in double and S has class double.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classin = getClassFromInput(xIn)
    if(isfloat(xIn))
        classin = 'native';
    else
        classin = 'double';
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Type cast variable to specified type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outVar = cast(inVar, class)
    switch class
    case 'double',  outVar = double(inVar);
    case 'single',  outVar = single(inVar);
    case 'logical', outVar = logical(inVar);
    case 'char',    outVar = char(inVar);
    otherwise eml_assert(0,'error','Unsupported class argument.');
    end


% [EOF]
