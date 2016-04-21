function varargout = checknargin(varargin)
%CHECKNARGIN Check number of input arguments.
%   CHECKNARGIN(LOW,HIGH,NUM_INPUTS,FUNCTION_NAME) checks whether 
%   NUM_INPUTS is in the range indicated by LOW and HIGH.  If not, CHECKNARGIN 
%   issues a formatted error message using the string in FUNCTION_NAME.
%
%   LOW should be a scalar nonnegative integer.
%
%   HIGH should be a scalar nonnegative integer or Inf.
%
%   FUNCTION_NAME should be a string.
%
%   ERR = CHECKNARGIN(...) returns any error structure encounterd 
%   during the validation without rethrowing the error. 
%
%   [MSG, ID] = CHECKNARGIN(...) returns any error message in MSG
%   and error identifier in ID.  MSG and ID will be [] if no error
%   is encountered during the validation.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/23 05:55:02 $

% Input arguments are not checked for validity.

fcn = @do_checknargin;

[varargout, needRethrow] = ...
    checkfunction(fcn, nargout, varargin{:});

if needRethrow
   rethrow(lasterror);    
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function do_checknargin(component, low, high, numInputs, function_name)
% Main function for checknargin.
% COMPONENT is the name for the error ID's first component. 

if numInputs < low
  msgId = sprintf('%s:%s:tooFewInputs', component, function_name);
  if low == 1
    msg1 = sprintf('Function %s expected at least 1 input argument', ...
                   upper(function_name));
  else
    msg1 = sprintf('Function %s expected at least %d input arguments', ...
                   upper(function_name), low);
  end
  
  if numInputs == 1
    msg2 = 'but was called instead with 1 input argument.';
  else
    msg2 = sprintf('but was called instead with %d input arguments.', ...
                   numInputs);
  end
  
  throwerr(msgId, '%s\n%s', msg1, msg2);
  
elseif numInputs > high
  msgId = sprintf('%s:%s:tooManyInputs', component, function_name);

  if high == 1
    msg1 = sprintf('Function %s expected at most 1 input argument', ...
                   upper(function_name));
  else
    msg1 = sprintf('Function %s expected at most %d input arguments', ...
                   upper(function_name), high);
  end
  
  if numInputs == 1
    msg2 = 'but was called instead with 1 input argument.';
  else
    msg2 = sprintf('but was called instead with %d input arguments.', ...
                   numInputs);
  end
  
  throwerr(msgId, '%s\n%s', msg1, msg2);
end

  
    
