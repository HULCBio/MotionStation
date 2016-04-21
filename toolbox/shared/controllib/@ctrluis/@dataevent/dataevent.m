function h = dataevent(hSrc,eventName,data)
%DATAEVENT  Subclass of EVENTDATA to handle mxArray-valued event data.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:46 $


% Create class instance
h = ctrluis.dataevent(hSrc,eventName);
h.Data = data;
