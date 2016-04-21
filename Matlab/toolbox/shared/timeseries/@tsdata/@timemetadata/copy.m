function hout = copy(h)
%COPY Copy constructor for timemetedata
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:36 $

hout = tsdata.timemetadata;
set(hout,'Units',h.Units,'Format',h.Format,'Startdate',h.Startdate,...
     'Start',h.Start,'End',h.End,'Increment',h.Increment,'Length',h.Length);




