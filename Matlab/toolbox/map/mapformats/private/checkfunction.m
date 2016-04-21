function [outputs, needRethrow] = checkfunction(fcn, noutputs, varargin)
%CHECKFUNCTION Error parsing for a "check" function.
%
% Use checkfunction to construct the main routine in the
% checksomething function. Using checkfunction, throwerr
% and the construct in the example below leads to cleaner, 
% easier to decipher error output on the MATLAB command line.
%
% Example
% -------
%    function varargout = checksomething(varargin)
% 
%    fcn = @do_checksomething;
% 
%    [varargout, needRethrow] = ...
%       checkfunction(fcn, nargout, varargin{:});
% 
%    if needRethrow
%       rethrow(lasterror);    
%    end
%
%    %----------------------------------------------
% 
%    function do_checksomething(component, A, ...)
%    [ body of do_checksomething
%      uses "throwerr" rather than "error"]
%
% See also: CHECKINPUT, CHECKNARGIN, THROWERR.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2003/08/01 18:19:20 $

err.message    = '';
err.identifier = '';
try
	feval(fcn, getcomp, varargin{:});   
catch
    err = lasterror;
end
        
switch noutputs
    case {0,1}
        outputs{1} = err;
    otherwise
        outputs{1} = err.message;
        outputs{2} = err.identifier;
end

needRethrow = (noutputs == 0) && ~isempty(err.message);
