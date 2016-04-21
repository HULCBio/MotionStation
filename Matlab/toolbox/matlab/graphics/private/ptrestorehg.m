function ptrestorehg( pt, h )
%FORMAT Method that restores a Figure after formating it for output.
%   Input of PrintTemplate object and a Figure to modify.
%   Figure has numerous properites restore to previous values modified
%   to account for template settings.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:08:56 $

if pt.DebugMode
    disp(['Restoring Figure ' num2str(h)])
    pt
end

% Output Axes with same tick MARKS as on screen
if pt.AxesFreezeTicks
    set( pt.tickState.handles, {'XTickMode','YTickMode','ZTickMode'}, pt.tickState.values )
    pt.tickState = {};
end

% Output Axes with same tick LIMITS as on screen
if pt.AxesFreezeLimits
    set( pt.limState.handles, {'XLimMode','YLimMode','ZLimMode'}, pt.limState.values )
    pt.limState = {};
end

