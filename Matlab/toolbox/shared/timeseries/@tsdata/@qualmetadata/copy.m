function hout = copy(h)
%COPY Copy constructor for qualmetadata objects
%
%   Author(s): J.G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:29 $

hout = tsdata.qualmetadata;
hout.Code = h.Code;
hout.Description = h.Description;
