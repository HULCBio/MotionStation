function h = horizontalline(fun, varargin)
% HORIZONTALLINE  Creates a horizontal line from a constant function.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/10 23:26:29 $

if nargin < 1
    error('MATLAB:horizontalline:NeedsMoreArgs','HORIZONTALLINE requires at least one argument.');
end

h = graph2d.constantlineseries(fun, varargin{:});
