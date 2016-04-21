function val = methods(this,fcn,varargin)
% METHODS - methods for line class

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $

% this dispatches methods from instances of line to lineMethods, allowing
% methods to be used more generally within lineMethods

val = [];
% one arg is methods(obj) call
if nargin==1
    cls = this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

if nargout>0
    val = lineMethods(this,fcn,varargin{:});
else
    lineMethods(this,fcn,varargin{:});
end
    