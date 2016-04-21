function comp = getplottool (h, name)
% GETPLOTTOOL  Utility function for creating and obtaining the 
% figure components used for plot editing.
%
% c = GETPLOTTOOL (h, 'figurepalette') returns the Java figure 
%        palette for the given figure.
% c = GETPLOTTOOL (h, 'plotbrowser') returns the Java plot
%        browser for the given figure.
% c = GETPLOTTOOL (h, 'propertyeditor') returns the Java property
%        editor for the given figure.
%
% In each case, the component is created if it does not already exist.  The
% component is not automatically shown.  If you want to both create it and
% show it, use SHOWPLOTTOOL.

% Copyright 2003-2004 The MathWorks, Inc.

% Called by showplottool, which in turn is called by the component-specific
% functions (propertyeditor, plotbrowser, figurepalette).

if isempty (get (h, 'JavaFrame'))
    error (sprintf ('The plot tools require Java figures to be enabled!'));
end

cmd = lower (name);
switch cmd
case 'propertyeditor'
    comp = createOrGetPropertyEditor (h);
case 'plotbrowser'
    comp = createOrGetPlotBrowser (h);
case 'figurepalette'
    comp = createOrGetFigurePalette (h);
end


%-------------------------
function props = createOrGetPropertyEditor (h)
if (~isprop (h, 'propertyeditor')) 
     selMgr = createOrGetSelectionManager (h);
     props = com.mathworks.page.plottool.PropertyEditor (h, selMgr);
     if (isprop (h, 'propertyeditor'))
         % check again; might have run twice in quick succession
         props = get (handle(h), 'propertyeditor');
         return;
     end
     p = schema.prop (handle(h), 'propertyeditor', 'MATLAB array');
     p.AccessFlags.Serialize = 'off';
     set (handle(h), 'propertyeditor', props);
     props.setVisible (false);
     javacomponent (props, java.awt.BorderLayout.SOUTH,  handle(h));
else
     props = get (handle(h), 'propertyeditor');
end

%-------------------------
function browser = createOrGetPlotBrowser (h)
if (~isprop (h, 'plotbrowser')) 
     selMgr = createOrGetSelectionManager (h);
     browser = com.mathworks.page.plottool.PlotBrowser (h, selMgr);
     if (isprop (h, 'plotbrowser'))
         % check again; might have run twice in quick succession
         browser = get (handle(h), 'plotbrowser');
         return;
     end
     p = schema.prop (handle(h), 'plotbrowser', 'MATLAB array');
     p.AccessFlags.Serialize = 'off';
     set (handle(h), 'plotbrowser', browser);
     browser.setVisible (false);
     javacomponent (browser, java.awt.BorderLayout.EAST,  handle(h));
else
     browser = get (handle(h), 'plotbrowser');
end

%-------------------------
function palette = createOrGetFigurePalette (h)
if (~isprop (h, 'figurepalette')) 
     selMgr = createOrGetSelectionManager (h);
     palette = com.mathworks.page.plottool.FigurePalette (h, selMgr);
     if (isprop (h, 'figurepalette'))
         % check again; might have run twice in quick succession
         palette = get (handle(h), 'figurepalette');
         return;
     end
     p = schema.prop (handle(h), 'figurepalette', 'MATLAB array');
     p.AccessFlags.Serialize = 'off';
     set (handle(h), 'figurepalette', palette);
     palette.setVisible (false);
     javacomponent (palette, java.awt.BorderLayout.WEST,  handle(h));
else
     palette = get (handle(h), 'figurepalette');
end

%-------------------------
function selMgr = createOrGetSelectionManager (h)
if (~isprop (h, 'SelectionManager')) 
     % Temporary workaround:  protect figure from renderer lossage...
     try 
         s = feature ('getopengldata');
         if isprop (h, 'WVisual') 
             str = 'WVisual';
         else
             str = 'XVisual';
         end
         set (h, str, s.Visual);
     end
     
     plotedit (h,'on');
     selMgr = com.mathworks.page.plottool.SelectionManager (h);
     if (isprop (h, 'SelectionManager'))
         % check again; might have run twice in quick succession
         selMgr = get (handle(h), 'SelectionManager');
         return;
     end
     p = schema.prop (handle(h), 'SelectionManager', 'MATLAB array');
     p.AccessFlags.Serialize = 'off';
     set (handle(h), 'SelectionManager', selMgr);
     drawnow;
else
     selMgr = get (handle(h), 'SelectionManager');
end

