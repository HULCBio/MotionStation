function defaultbdf(Constr)
%DEFAULTBDF  Defines default ButtonDown callback.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:12:28 $

Constr.ButtonDownFcn = {@LocalDefaultBDF Constr};


function LocalDefaultBDF(eventSrc,eventData,Constr)
% Callback
Constr.mouseevent('bd',hSrc);