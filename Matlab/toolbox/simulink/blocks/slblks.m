function varargout=slblks(varargin)
%SL Gateway to Simulink Blocks functions.
%   OUTPUT=SLBLKS('functionname',ARG1,ARG2,...) runs the functions in
%   toolbox/simulink/blocks/private with the given input arguments.
%
%   The functions in private area are unsupported and may change
%   without warning.  Use at your own risk.
%
%   See also SIMULINK.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/04 03:39:11 $

%--------1---------2---------3---------4---------5---------6---------7---------8

if nargout==0
    feval(varargin{:});
else
    [varargout{1:nargout}]=feval(varargin{:});
end