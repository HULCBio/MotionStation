function [out] = hgfeval(fcn,varargin)
% This undocumented helper function is for internal use.

% HGFEVAL Utility for executing function_handle callbacks
%   HGFEVAL(FCN) Executes the function_handle C, equivalent to feval(C). 
%             
%   HGFEVAL(FCN) Executes cell array C where the first element of C 
%              is a function_handle and the remaining elements 
%              are input arguments to that function_handle.
%              Equivalent to feval(C{1},C{2:end}). 
%
%   HGFEVAL(FCN,ARG1,ARG2,...) Similar to previous syntax, except that the
%              the additional input arguments are pre-appended to the 
%              argument list. Equivalent to feval(C{1},ARG1,ARG2,...,C{2:end})
%
%  OUT = HGFEVAL(...) Gets function outputs
%
%  See also FEVAL.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision $  $Date: 2003/12/24 19:13:39 $

if nargout>0
  doout = true;
else
  doout = false;
end

if isa(fcn,'function_handle')
   fcn = {fcn};
end

if ~iscell(fcn) || ~isa(fcn{1},'function_handle')
   error('MATLAB:hgfeval:invalidInput','Invalid Input');
end

if doout
  out = feval(fcn{1},varargin{:},fcn{2:end});
else
  feval(fcn{1},varargin{:},fcn{2:end});
end
