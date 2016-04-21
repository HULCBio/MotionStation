function timercb(obj,type,val,event)
%TIMERCB Wrapper for timer object M-file callback.
%
%   TIMERCB(OBJ,TYPE,VAL,EVENT) calls the function VAL with parameters
%   OBJ and EVENT.  This function is not intended to be called by the 
%   user.
%
%   See also TIMER
%

%    RDD 12-2-01
%    Copyright 2001-2003 The MathWorks, Inc.
%    $Revision: 1.2.4.2 $  $Date: 2004/03/30 13:07:30 $

if ~isvalid(obj)
    return;
end

if isa(val,'char') % strings are evaled in base workspace.
    try
        evalin('base',val);
    catch
        if ~ strcmp(type,'ErrorFcn')
            [lerr lid] = lasterr;
            obj.jobject.callErrorFcn(lerr,lid);
        end
        lasterr(timererror('MATLAB:timer:badcallback',type,get(obj,'Name'),lasterr),'MATLAB:timer:badcallback');
        disp(lasterr);
    end
else % non-strings are fevaled with calling object and event struct as parameters
    % Construct the event structure.  The callback is expected to be of cb(obj,event,...) format
    eventStruct = struct(event);
    eventStruct.Data = struct(eventStruct.Data);
    
    % make sure val is a cell / only not a cell if user specified a function handle as callback.
    if isa(val, 'function_handle')
        val = {val};
    end
    
    % Execute callback function.
    try
        feval(val{1}, obj, eventStruct, val{2:end});
    catch
        if ~ strcmp(type,'ErrorFcn') 
            [lerr lid] = lasterr;
            try
                if isJavaTimer(obj.jobject)
                    obj.jobject.callErrorFcn(lerr,lid);
                end
            catch
            end
        end
        lasterr(timererror('MATLAB:timer:badcallback',type,get(obj,'Name'),lasterr),'MATLAB:timer:badcallback');
        disp(lasterr);
    end
end