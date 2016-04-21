function sz = sptsizes
%SPTSIZES Get size structure for laying out UIControls for SPTool and Clients.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% ====================================================================
% defines sizes (in pixels) for various dimensions
sz.ih = 47;   %icon height
sz.iw = 42;   %icon width
sz.lw = 130;  %listbox width
sz.fus = 5;   %frame/uicontrol spacing
sz.ffs = 5;   %frame/figure spacing
sz.lfs = 3;   %label/frame spacing
if ~isempty(findstr(computer,'PC'))
    sz.lh = get(0,'defaultuicontrolfontsize')+10;   %label height   
else
    sz.lh = get(0,'defaultuicontrolfontsize')+4;   %label height 
end
sz.uh = 20;   %uicontrol height
sz.rw = 130;  %ruler width
sz.rih = 40;  %ruler icon height
sz.riw = (sz.rw-2*sz.ffs-2*sz.fus)/2;  %ruler icon width
sz.rh = 2*sz.uh + 3*sz.fus-3;  % ruler height
sz.pmw = 14;  %plus/minus width
sz.lbs = 3;  %label/box spacing
sz.as = [50 40 20 30]; %spacing of main axes from [left bottom right top]
                       % of main axes port
scalefactor = (get(0,'screenpixelsperinch')/72)^.5;
sz.as = sz.as*scalefactor;

if strcmp(computer,'PCWIN'),
    tweak = 5;
else
    tweak = 0;
end    
sz.ph = 35+tweak; %panner height

sz.bw = 110;  % button width
