%VARARGIN Variable length input argument list.
%   Allows any number of arguments to a function.  The variable
%   VARARGIN is a cell array containing the optional arguments to the
%   function.  VARARGIN must be declared as the last input argument
%   and collects all the inputs from that point onwards. In the
%   declaration, VARARGIN must be lowercase (i.e., varargin).
%
%   For example, the function,
%
%       function myplot(x,varargin)
%       plot(x,varargin{:})
%
%   collects all the inputs starting with the second input into the 
%   variable "varargin".  MYPLOT uses the comma-separated list syntax
%   varargin{:} to pass the optional parameters to plot.  The call,
%
%       myplot(sin(0:.1:1),'color',[.5 .7 .3],'linestyle',':')
%
%   results in varargin being a 1-by-4 cell array containing the
%   values 'color', [.5 .7 .3], 'linestyle', and ':'.  
%
%   See also VARARGOUT, NARGIN, NARGOUT, INPUTNAME, FUNCTION, LISTS, PAREN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 04:16:13 $
%   Built-in function.
