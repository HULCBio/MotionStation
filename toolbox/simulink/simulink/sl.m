function varargout=sl(varargin)
%SL Gateway to Simulink functions.
%   OUTPUT=SL('functionname',ARG1,ARG2,...) runs the function in
%   simulink/private with the given input arguments.
%
%   The functions in simulink/private are unsupported and may change
%   without warning.  Use at your own risk.
%
%   See also SIMULINK.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 18:21:27 $

%--------1---------2---------3---------4---------5---------6---------7---------8

if nargout==0
    feval(varargin{:});
else
    [varargout{1:nargout}]=feval(varargin{:});
end
