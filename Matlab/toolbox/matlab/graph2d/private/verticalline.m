function h = verticalline(fun, varargin)
% VERTICALLINE  Creates a vertical straight line from a constant function.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/10 23:26:31 $

if nargin < 1
    error('MATLAB:verticalline:NeedsMoreArgs','VERTICALLINE requires at least one argument.');
end

h = graph2d.constantlineseries(fun, varargin{:});
h = changedependvar(h,'x');