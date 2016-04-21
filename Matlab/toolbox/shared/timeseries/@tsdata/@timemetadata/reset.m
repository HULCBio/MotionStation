function reset(h, t)
%RESET Syncronizes timemetadata object with a time vector
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:33:40 $

%% Check time
if length(t)<1
    error('timemetadata:reset:invlen',...
        'Time vector must have length of at least 1 sample')
end
t = tsChkTime(t);

%% Check t is strictly increasing
dt = diff(t);
if min(dt)<=0
    error('timemetadata:reset:nosort',...
        'Time vector must be strictly increasing')
end

%% Prevent auto modification of the "End" property
h.Length = NaN;

%% Update the increment proeprty
if (max(dt)-min(dt))/min(dt)<1e-6
    h.Increment = dt(1);
else
    h.Increment = NaN;
end
h.Start = t(1);
h.End = t(end);

%% Set the length back to its former value
h.Length = length(t);
