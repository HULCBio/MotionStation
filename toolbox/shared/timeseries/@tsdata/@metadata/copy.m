function hout = copy(h)
%COPY Copy constructor for metadata objects
%
%   Author(s): J.G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:21 $

hout = tsdata.metadata;
set(hout,'Units',h.Units,'Scale',h.Scale,'Offset',h.Offset,'Name',h.Name,...
    'Interpolation', copy(h.Interpolation),'GridFirst',h.GridFirst);
