function val=ifelse(expr,v1,v2)
%IFELSE tertiary logical operator
%   IFELSE(LEXPR,V1,V1) if logical expression LEXPR is true then V1 is
%   returned, otherwise V2 is returned
%   IFELSE(NUM,V1,V2) if logical(NUM) is true, then V1 is returned, otherwise
%   V2 is returned

% Copyright 2002 The MathWorks, Inc.

if ~(isnumeric(expr)||islogical(expr))
    error('MATLAB,graph2d ....expression must be numeric or logical');
end
if logical(expr)
    val=v1;
else
    val=v2;
end