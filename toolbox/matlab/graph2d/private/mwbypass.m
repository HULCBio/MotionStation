function hh = mwbypass(h,id,varargin)
%MWBYPASS  Graph2d bypass function.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 04:06:29 $

%   h        : target object which contains bypass function information
%   id       : name of appdata field which contains bypass function
%   varargin : arguments passed to standard form of function (non-bypass)
%   hh       : output handle (if requested)

fcn = getappdata(h,id);

if nargout > 0
   if ~iscell(fcn)
      hh = feval(fcn,varargin{:});
   else
      hh = feval(fcn{:},varargin{:});
   end
else
   if ~iscell(fcn)
      feval(fcn,varargin{:});
   else
      feval(fcn{:},varargin{:});
   end
end
