function instrcb(val,obj,event)
%INSTRCB Wrapper for serial object M-file callback.
%
%  INSTRCB(FCN,OBJ,EVENT) calls the function FCN with parameters
%  OBJ and EVENT.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:03:57 $

% Store the warning state.
warning('');
s = warning('backtrace', 'off');

switch (nargin)
case 1
    try
        evalin('base', val);
    catch
        warning(s);
        rethrow(lasterror);
    end
case 3    
    % Construct the event structure.
    eventStruct = struct(event);
    eventStruct.Data = struct(eventStruct.Data);
 
    if isa(val, 'function_handle')
        val = {val};
    end
    
    % Execute callback function.
    try
        feval(val{1}, obj, eventStruct, val{2:end});
    catch
        warning(s);
        rethrow(lasterror);
    end
end

% Restore the warning state.
warning(s)
  
% Report the last warning if it occurred.
if ~isempty(lastwarn)
   warning('MATLAB:instrcb:invalidcallback', lastwarn);
end

