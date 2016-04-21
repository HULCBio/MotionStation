function ret = isevent(h, userInput)
%ISEVENT  True if event of object.
%   ISEVENT(OBJ,NAME) returns 1 if string NAME is an event of object
%   OBJ, and 0 otherwise.
%
%   Example:
%     h=actxcontrol('mwsamp.mwsampctrl.2');
%     f = isevent(h, 'click')
%
%   See also ISMETHOD, ISPROP.  
  
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/12/03 03:45:07 $

ret = 0;
[m,n] = size(h.classhandle.Events);
for i=1:m
    event = h.classhandle.Event(i).Name;
    ret = strcmpi(event, userInput);
    
    if(ret)
        break
    end
end    
    