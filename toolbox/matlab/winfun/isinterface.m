function ret = isinterface(h)
%ISINTERFACE  true for COM Interfaces.
%   ISINTERFACE(H)  returns true if H is a COM Interface, false otherwise.
%
%   Example:
%     h=actxserver('excel.application');
%     workbooks = get(h, 'workbooks');
%     ret = isinterface(workbooks);       
%
%   See also ISCOM, ISOBJECT, ACTXCONTROL, ACTXSERVER.
  
%   Copyright 1999-2003 The MathWorks, Inc.

ret = strncmp(class(h),'Interface.',10);
