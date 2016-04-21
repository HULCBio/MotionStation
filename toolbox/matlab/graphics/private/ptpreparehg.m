function pt = ptpreparehg( pt, h )
%PREPAREHG Method of PrintTemplate object that formats a Figure for output.
%   Input of PrintTemplate object and a Figure to modify on.
%   Figure has numerous properites modifed to account for template settings.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:08:53 $

if pt.DebugMode
    disp(['Preparing Figure ' num2str(h)])
    pt
end

theAxes = findall( h, 'type', 'axes' );

% Output Axes with same tick MARKS as on screen
if pt.AxesFreezeTicks
    pt.tickState.handles = theAxes; 
    pt.tickState.values = get(theAxes, {'XTickMode','YTickMode','ZTickMode'} );
    set( pt.tickState.handles, {'XTickMode','YTickMode','ZTickMode'}, {'manual','manual','manual'})
end

% Output Axes with same tick LIMITS as on screen
if pt.AxesFreezeLimits
    pt.limState.handles = theAxes; 
    pt.limState.values = get(theAxes, {'XLimMode','YLimMode','ZLimMode'} );
    set( pt.limState.handles, {'XLimMode','YLimMode','ZLimMode'}, {'manual','manual','manual'})
end

