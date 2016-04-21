function daqmexcb(fcn,obj,event,optional)
%DAQMEXCB Wrapper for Data Acquisition Toolbox M-file callbacks.
%
%   DAQMEXCB(FCN,OBJ,EVENT) calls the function FCN with parameters
%   OBJ and EVENT.
%

%    GBL 8-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:40:50 $

s=warning;
warning('');
warning off
try
   feval(fcn,obj,event,optional{:})
catch
   warning(s)
   error('daq:daqmexcb:unexpected', lasterr)
end

warning(s)
   
if ~isempty(lastwarn)
   error('daq:daqmexcb:unexpected', lastwarn)
end

   
   