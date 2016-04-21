function sf_cruise_button_mgr(figH,method)

persistent normal_cdata inc_cdata dec_cdata;

% Load required images if they don't exist

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/15 00:52:58 $
if isempty(normal_cdata)
    normal_cdata = imread('sf_cruise_normal.bmp');
    inc_cdata = imread('sf_cruise_inc.bmp');
    dec_cdata = imread('sf_cruise_dec.bmp');
end

axH = findobj(figH,'Type','axes');
imageH = findobj(axH,'Type','image');
axPos = get(axH,'Position');

switch(method),
case 'down'
    bdPos = get(figH,'CurrentPoint');
    if bdPos(1) > (axPos(1) + axPos(3)/2),
        % Dec button
        try
            blockH = get_param('sf_cruise_control/hg/dec','Handle');
        catch
            blockH = [];
        end
        
        if isempty(blockH)
            return;
        end
        set_param(blockH,'Value','1');
        set(axH,'UserData',blockH);
        set(imageH,'Cdata',dec_cdata);
    else
        % Inc button
        try
            blockH = get_param('sf_cruise_control/hg/inc','Handle');
        catch
            blockH = [];
        end
        
        if isempty(blockH)
            return;
        end
        set_param(blockH,'Value','1');
        set(axH,'UserData',blockH);
        set(imageH,'Cdata',inc_cdata);
    end
case 'up'
    blockH = get(axH,'UserData');
    set_param(blockH,'Value','0');
    set(imageH,'Cdata',normal_cdata);
end
        
        
        
    
