function uictxtmnu = defaultUIContextMenu(hThis)

% Copyright 2003 The MathWorks, Inc.

hFig = ancestor(hThis,'figure');

uictxtmenu = uicontextmenu('Parent',hFig);

menuprops = struct;
menuprops.Parent = uictxtmenu;

menuprops.Label = 'Show Text';
menuprops.Checked = hThis.ShowText;
menuprops.Callback = {@localSetShowText,hThis};

u = uimenu(menuprops);


                

% VALUE DISPLAY
% no display
% datatip
% text box(es)


function localSetShowText(hMenu,evd,hThis)

switch get(hMenu,'Checked')
    case 'on'
        set(hMenu,'Checked','off')
        set(hThis,'ShowText','off')        
    case 'off'
        set(hMenu,'Checked','on')
        set(hThis,'ShowText','on')
end

