%VARARGOUT Variable length output argument list.
%   Allows any number of output arguments from a function.  The
%   variable VARARGOUT is a cell array containing the
%   optional output arguments from the function.  VARARGOUT must be
%   declared as the last output argument and must contain all the
%   outputs after that point onwards.  In the declaration, VARARGOUT
%   must be lowercase (i.e., varargout).  
%
%   VARARGOUT is not initialized when the function is invoked.  You
%   must create it before your function returns.  Use NARGOUT to
%   determine the number of outputs to produce.
%
%   For example, the function,
%
%       function [s,varargout] = mysize(x)
%       nout = max(nargout,1)-1;
%       s = size(x);
%       for i=1:nout, varargout(i) = {s(i)}; end
%
%   returns the size vector and optionally individual sizes.  So,
%
%      [s,rows,cols] = mysize(rand(4,5));
%
%   returns s = [4 5], rows = 4, cols = 5.
%
%   See also VARARGIN, NARGIN, NARGOUT, FUNCTION, LISTS, PAREN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/15 04:16:51 $
%   Built-in function.
