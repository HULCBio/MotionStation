function updatestring(hThis)
% Update string for datatip 

% Copyright 2002-2003 The MathWorks, Inc.

% Do not update the string if there is no datacursor.
hDataCursor = hThis.DataCursorHandle;
if isempty(hDataCursor)
    return;
end

% Cast target to double for 
set(hDataCursor,'Target',double(hThis.Host));
set(hDataCursor,'Interpolate',get(hThis,'Interpolate'));

% Call the application supplied function handle if it exists. 
% There are three function handles to consider, two of them
% are planned to be removed in later release.
%  -UpdateFcn  
%  -StringFcn (to be removed in later release)
%  -EmptyArgUpdateFcn (to be removed in later release)

strFcn = get(hThis,'StringFcn');
if ~isempty(strFcn)
  arg1 = hThis.Host;
  arg2 = hDataCursor;   
else
   strFcn = get(hThis,'EmptyArgUpdateFcn');
   if ~isempty(strFcn)
      arg1 = [];
      arg2 = hDataCursor;
   else  
      strFcn = get(hThis,'UpdateFcn');
      arg1 = hThis;
      arg2 = hDataCursor;
   end
end
   
% Evaluate function handle
if ~isempty(strFcn) 
   str = hgfeval(strFcn,arg1,arg2);
else
   % Should be a static method
   str=getDataCursorText(hDataCursor,hThis.Host,hDataCursor,hThis);  
end

% Don't update the datatip if the datacursor position is empty
if isempty(str)
   return;
end

set(hThis,'String',str);
% Explicitly set text box string since listener may be disabled
private_set_string(hThis,str);

% Throw update event
hEvent = handle.EventData(hThis,'UpdateCursor');
send(hThis,'UpdateCursor',hEvent);
