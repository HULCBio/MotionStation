function varargout=graph2dhelper(varargin)
%GRAPH2DHELPER Switchyard for private graph2d functions

%   FH=GRAPH2DHELPER(FNAME) returns a function handle to the function FNAME
%
%   [OUT1,OUT1,...]=GRAPH2DHELPER(FNAME,ARG1,ARG2,...) evaluates function
%   FNAME with arguments ARG1,ARG2,... and returns ouputs OUT1,OUT2,...
%   Legal functions include functions located in graph2d/private directory
%   and other functions that are on the MATLAB path.  Individual arguments
%   (ARG1, ARG2, etc.) may not be cell arrays (same as with feval).
%
%   GRAPH2DHELPER(FNAME,ARG1,ARG2,...) evaluates FNAME with ARG1,ARG2,...
%   and returns nothing (errors if FNAME specifies outputs).
%
%   GRAPH2DHELPER(NOUTS,FNAME,ARG1,ARG2,...) evaluates FNAME with
%   ARG1,ARG2,... and reurns NOUTS outputs.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $

if nargin==1 && ischar(varargin{1})
    varargout{1} = str2func(varargin{1});
else
    if nargout<1
        if isnumeric(varargin{1})
            [varargout{1:varargin{1}}] = feval(varargin{2:end});
        else
            feval(varargin{:});
        end
    else
        [varargout{1:nargout}] = feval(varargin{:});
    end
end