function wlan80211a_open_graphics(blk, forceClose);
% forceClose: 1 = force figure to close; 0 = toggle open/close

% Copyright 2003 The MathWorks, Inc.

gfig = findobj('type', 'figure', 'tag', blk);
if isempty(gfig)                                   
    if ~forceClose
        gfig = openfig(get_param(blk, 'graphicsName'));
        set(gfig, 'tag', blk);
    end
else                                               
    close(gfig);                                   
end                                                
