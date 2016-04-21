function postserialize(this,olddata)
%POSTSERIALIZE Restore object after serialization

%   Copyright 1984-2004 The MathWorks, Inc.

methods(this,'set_contextmenu','on');
rmappdata(double(this),'PlotChildren');
rmappdata(double(this),'PeerAxes');
