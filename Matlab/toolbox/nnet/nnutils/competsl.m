function a = competsl(n)
%COMPETSL Competitive transfer function used by SIMULINK.
%
%  Syntax
%
%    a = competsl(n)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

[maxn,indn] = max(n,[],1);
a = zeros(size(n));
a(indn) = 1;
