function exportsetupdlg(fig)
%EXPORTSETUPDLG Figure style editor
%  EXPORTSETUPDLG launches a dialog to edit the current figure's
%  export settings.
%  EXPORTSETUPDLG(FIG) edits the export settings for figure FIG.
%
%  See also: HGEXPORT, PRINT

%   Copyright 1984-2004 The MathWorks, Inc.

if nargin == 0
  fig = gcf;
end

error(javachk('swing','The export setup dialog'));

% reuse window if one exists (and hold on to handles for callbacks also)
ui = getui(fig);

oldpointer = get(fig,'Pointer');
set(fig,'Pointer','watch');

noui = isempty(ui);
if noui
  ui = createui(fig);
end
ui.active = false; % turn off the ui while we update
setui(fig,ui);
pathname = getStyleDir;
if ~exist(pathname)
  mkdir(pathname);
  initStandardStyles(pathname);
end
style = getappdata(fig,'Exportsetup');
if isempty(style)
  try
    style = hgexport('readstyle','Default');
  catch
    style = hgexport('factorystyle');
  end
end
ui.style = style;

ui.styles = getStyles;
if noui
  ui.figure = fig;
  clearDirty(ui);
  ui = loadstyle(style,ui);
end
setui(fig,ui);
awtinvoke(ui.win,getMethod(getClass(ui.win),'toFront',[]));
drawnow;
awtinvoke(ui.win,'setVisible(Z)',true,@activateWindow,fig);
set(fig,'Pointer',oldpointer);

function activateWindow(fig)
ui = getui(fig);
ui.active = true;
setui(fig,ui);

%---------------------------  Style Loading -----------------------

function ui=loadstyle(style,ui)
ui.style = style;
ui.active = false;
setui(ui.figure,ui);
wintitle = xlate('Export Setup');
name = get(ui.figure,'Name');
if ~isempty(name)
  wintitle = [wintitle ': ' name];
elseif strcmp(get(ui.figure,'NumberTitle'),'on')
  wintitle = [wintitle ': Figure ' num2str(double(ui.figure))];
end
awtinvoke(ui.win,'setTitle(Ljava/lang/String;)',...
          java.lang.String(wintitle));
awtinvoke(ui.panelchoice,'setSelectedIndex(I)',0);
awtinvoke(ui.cardlayout,'show(Ljava/awt/Container;Ljava/lang/String;)',...
          ui.cardpane,java.lang.String('Size'));
awtinvoke(ui.selectstylebutton,'setModel(Ljavax/swing/ComboBoxModel;)',...
          javax.swing.DefaultComboBoxModel(ui.styles));
awtinvoke(ui.restorebutton,'setEnabled(Z)',~isempty(ui.oldstate));
ui=loadsizepanel(style,ui);
loadrenderingpanel(style,ui);
loadfontpanel(style,ui);
loadlinepanel(style,ui);
%loadepspanel(style,ui);
drawnow;
ui.active = true;
clearDirty(ui);

function ui=loadsizepanel(style,ui)
ui.widthitems = updateEditableComboBox(style.Width,...
                                       ui.widthitems,ui.widthtext,true);
ui.heightitems = updateEditableComboBox(style.Height,...
                                        ui.heightitems,ui.heighttext,true);
[vals,strs] = getUnitsVals;
ind = find(strcmpi(style.Units,vals));
if ~isempty(ind)
  awtinvoke(ui.unitsbutton,'setSelectedIndex(I)',ind-1);
end
awtinvoke(ui.boundsbutton,'setSelected(Z)',...
          isequal(style.Bounds,'tight'));

function loadrenderingpanel(style,ui)
color = style.Color;
[colors,strs] = getColorVals;
ind = find(strcmpi(color,colors));
if ~isempty(ind)
  awtinvoke(ui.colorbutton,'setSelectedIndex(I)',ind-1);
end
backcolor = style.Background;
awtinvoke(ui.backcolorcustombutton,'setSelected(Z)', ~isempty(backcolor));
awtinvoke(ui.backcolortext,'setText(Ljava/lang/String;)',...
          java.lang.String(backcolor));
val = style.Resolution;
if ~isempty(val) && ~strcmp('auto',val)
  val = num2str(val);
end
ui.resitems = updateEditableComboBox(val,ui.resitems,ui.restext,true);
ind = find(strcmpi(style.Renderer,getRendererVals));
if ~isempty(ind)
  awtinvoke(ui.rendererbutton,'setSelectedIndex(I)',ind-1);
else
  awtinvoke(ui.rendererbutton,'setSelectedIndex(I)',0);
end
rend = style.Renderer;
awtinvoke(ui.rendercustombutton,'setSelected(Z)',...
          ~isempty(rend) && ~isequal(rend,'auto'));
awtinvoke(ui.lockbutton,'setSelected(Z)',...
          isequal(style.LockAxes,'on'));
awtinvoke(ui.showuibutton,'setSelected(Z)',...
          isequal(style.ShowUI,'on'));

function loadfontpanel(style,ui)
switch style.FontMode
 case 'none'
  awtinvoke(ui.fontmodecustom,'setSelected(Z)',false);
 case 'scaled'
  awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
  awtinvoke(ui.fontmodescale,'setSelected(Z)',true);
 case 'fixed'
  awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
  awtinvoke(ui.fontmodefix,'setSelected(Z)',true);
end
awtinvoke(ui.fontscale,'setText(Ljava/lang/String;)',...
          java.lang.String(style.ScaledFontSize));
awtinvoke(ui.fontmin,'setText(Ljava/lang/String;)',...
          java.lang.String(num2str(style.FontSizeMin)));
awtinvoke(ui.fontfix,'setText(Ljava/lang/String;)',...
          java.lang.String(num2str(style.FixedFontSize)));
fontname = style.FontName;
awtinvoke(ui.fontnamecustom,'setSelected(Z)', ...
          ~isempty(fontname) && ~strcmp(fontname,'auto'));
if strcmp(fontname,'auto')
  fontname = '';
end
ind = find(strcmpi(style.FontName,ui.fontlist));
if ~isempty(ind)
  awtinvoke(ui.fontnametext,'setSelectedIndex(I)',ind-1);
else
  ind = find(strcmpi('helvetica',ui.fontlist));
  if isempty(ind)
    ind = find(strcmpi('ariel',ui.fontlist));
  end
  awtinvoke(ui.fontnametext,'setSelectedIndex(I)',ind-1);
end
fontweight = style.FontWeight;
awtinvoke(ui.fontweightcustom,'setSelected(Z)', ...
          ~isempty(fontweight) && ~strcmp(fontweight,'auto'));
[vals,strs] = getWeightVals;
ind = find(strcmpi(fontweight,vals));
if ~isempty(ind)
  awtinvoke(ui.weightbutton,'setSelectedIndex(I)',ind-1);
else
  awtinvoke(ui.weightbutton,'setSelectedIndex(I)',0);
end
fontangle = style.FontAngle;
awtinvoke(ui.fontanglecustom,'setSelected(Z)', ...
          ~isempty(fontangle) && ~strcmp(fontangle,'auto'));
[vals,strs] = getAngleVals;
ind = find(strcmpi(fontangle,vals));
if ~isempty(ind)
  awtinvoke(ui.anglebutton,'setSelectedIndex(I)',ind-1);
else
  awtinvoke(ui.anglebutton,'setSelectedIndex(I)',0);
end

function loadlinepanel(style,ui)
switch style.LineMode
 case 'none'
  awtinvoke(ui.linemodecustom,'setSelected(Z)',false);
 case 'scaled'
  awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
  awtinvoke(ui.linemodescale,'setSelected(Z)',true);
 case 'fixed'
  awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
  awtinvoke(ui.linemodefix,'setSelected(Z)',true);
end
awtinvoke(ui.linescale,'setText(Ljava/lang/String;)',...
          java.lang.String(style.ScaledLineWidth));
awtinvoke(ui.linemin,'setText(Ljava/lang/String;)',...
          java.lang.String(num2str(style.LineWidthMin)));
awtinvoke(ui.linefix,'setText(Ljava/lang/String;)',...
          java.lang.String(num2str(style.FixedLineWidth)));
awtinvoke(ui.stylebutton,'setSelected(Z)',...
          isequal(style.LineStyleMap,'bw'));

function loadepspanel(style,ui)
% unused right now - remove if final
awtinvoke(ui.previewbutton,'setSelected(Z)',...
          isequal(style.Preview,'tiff'));
awtinvoke(ui.pslevelbutton,'setSelected(Z)',...
          isequal(style.PSLevel,2));
awtinvoke(ui.encodingbutton,'setSelected(Z)',...
          isequal(style.FontEncoding,'adobe'));
awtinvoke(ui.separatebutton,'setSelected(Z)',...
          isequal(style.SeparateText,'on'));

%---------------------------  Dialog Creation  -----------------------

function ui = createui(fig)
win = com.mathworks.mwswing.MJFrame('Export Setup');
ui.win = win;
ui.oldstate = [];
hfig = handle(fig);
ui.figcloseListener = handle.listener(hfig,findprop(hfig,'Visible'),'PropertyPostSet',{@doCloseForce,fig});
ui.figdeleteListener = handle.listener(hfig,'ObjectBeingDestroyed',{@doCloseForce,fig});
contents = getContentPane(win);
setLayout(contents,java.awt.GridBagLayout);
midpane = com.mathworks.mwswing.MJPanel;
[panes,strs] = getTabs;
ui.panelchoice = com.mathworks.mwswing.MJList(strs);
setcallback(ui.panelchoice,'ValueChangedCallback',{@doPanelChoice,fig});
setBorder(ui.panelchoice,javax.swing.BorderFactory.createEtchedBorder);
ui.cardpane = com.mathworks.mwswing.MJPanel;
ui.cardlayout = java.awt.CardLayout;
setPreferredSize(ui.panelchoice,java.awt.Dimension(80,20));
setLayout(ui.cardpane,ui.cardlayout);
setLayout(midpane,java.awt.GridBagLayout);
gbc = java.awt.GridBagConstraints;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.weightx = 0;
gbc.insets = java.awt.Insets(0,10,10,0);
gbc.fill = java.awt.GridBagConstraints.BOTH;
add(midpane,ui.panelchoice,gbc);
gbc.gridx = 1;
add(midpane,ui.cardpane,gbc);
border = javax.swing.BorderFactory.createEtchedBorder;
tborder = javax.swing.BorderFactory.createTitledBorder(border,...
            java.lang.String(xlate('Properties')));
setBorder(midpane,tborder);
ui = createsizepanel(ui,fig);
ui = createrenderpanel(ui,fig);
ui = createfontpanel(ui,fig);
ui = createlinepanel(ui,fig);
[ui,p] = createStyleLoadSave(ui,fig);
[ui,p2] = createOKCancel(ui,fig);

% add everything to the window
gbc = java.awt.GridBagConstraints;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.weightx = 0;
gbc.fill = java.awt.GridBagConstraints.HORIZONTAL;
gbc.insets = java.awt.Insets(3,10,3,10);
add(contents,midpane,gbc);
gbc.gridy = gbc.gridy + 1;
add(contents,p,gbc);
gbc.gridy = 0;
gbc.gridx = gbc.gridx + 1;
gbc.gridheight = 2;
gbc.anchor = java.awt.GridBagConstraints.NORTH;
add(contents,p2,gbc);
pack(win);
screen = get(0,'ScreenSize');
if strcmp(get(fig,'WindowStyle'),'docked')
  x = screen(3)/2 - 200;
  y = (screen(4)/2) - 200;
else
  pos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),...
                       'pixels',0);
  x = pos(1)+20;
  y = screen(4)-pos(2)-pos(4)+200;
  if y < 0, y = 0; end
end
setLocation(win,java.awt.Point(x,y));


function [ui,p] = createStyleLoadSave(ui,fig)
p = com.mathworks.mwswing.MJPanel;
setLayout(p,java.awt.GridBagLayout);
gbc = java.awt.GridBagConstraints;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.weightx = 0;
gbc.fill = java.awt.GridBagConstraints.HORIZONTAL;
gbc.anchor = java.awt.GridBagConstraints.WEST;
gbc.insets = java.awt.Insets(3,10,3,10);
border = javax.swing.BorderFactory.createEtchedBorder;
tborder = javax.swing.BorderFactory.createTitledBorder(border,...
            java.lang.String(xlate('Export Styles')));
setBorder(p,tborder);
ui.styles = getStyles;
ui.selectstylebutton = com.mathworks.mwswing.MJComboBox(ui.styles);
setAccessibleName(getAccessibleContext(ui.selectstylebutton),...
                  'Available styles');
setPreferredSize(ui.selectstylebutton,java.awt.Dimension(150,20));
ui.loadstylebutton = com.mathworks.mwswing.MJButton(xlate('Load'));
setcallback(ui.loadstylebutton,'actionPerformedCallback',{@doLoadStyle,fig});
add(p,com.mathworks.mwswing.MJLabel(xlate('Load settings from:')),gbc);
gbc.gridx = gbc.gridx + 1;
gbc.weightx = 1;
add(p,ui.selectstylebutton,gbc);
gbc.weightx = 0;
gbc.gridx = gbc.gridx + 1;
add(p,ui.loadstylebutton,gbc);

gbc.gridx = 0;
gbc.gridy = 1;
add(p,com.mathworks.mwswing.MJLabel(xlate('Save as style named:')),gbc);
gbc.gridx = gbc.gridx + 1;
ui.savetext = com.mathworks.mwswing.MJTextField(xdefault);
add(p,ui.savetext,gbc);
gbc.gridx = gbc.gridx + 1;
ui.savebutton = com.mathworks.mwswing.MJButton(xlate('Save'));
setcallback(ui.savebutton,'actionPerformedCallback',{@doSave,fig});
add(p,ui.savebutton,gbc);

gbc.gridx = 0;
gbc.gridy = 2;
add(p,com.mathworks.mwswing.MJLabel(xlate('Delete a style:')),gbc);
gbc.gridx = gbc.gridx + 1;
styles = ui.styles;
styles(strcmp(xdefault,styles)) = [];
styles(strcmp('PowerPoint',styles)) = [];
styles(strcmp('MSWord',styles)) = [];
enableDelete = ~isempty(styles);
if isempty(styles), styles = {' '}; end
ui.deletestylelist = com.mathworks.mwswing.MJComboBox(styles);
add(p,ui.deletestylelist,gbc);
gbc.gridx = gbc.gridx + 1;
ui.deletebutton = com.mathworks.mwswing.MJButton(xlate('Delete'));
setEnabled(ui.deletebutton,enableDelete);
setcallback(ui.deletebutton,'actionPerformedCallback',{@doDelete,fig});
add(p,ui.deletebutton,gbc);

function [ui,p2] = createOKCancel(ui,fig)
p2 = com.mathworks.mwswing.MJPanel;
setLayout(p2,java.awt.GridLayout(6,1,5,5));
add(p2,com.mathworks.mwswing.MJPanel);
ui.applybutton = com.mathworks.mwswing.MJButton(xlate('Apply to Figure'));
setcallback(ui.applybutton,'actionPerformedCallback',{@doApply,fig});
add(p2,ui.applybutton);
ui.restorebutton = com.mathworks.mwswing.MJButton(xlate('Restore Figure'));
setcallback(ui.restorebutton,'actionPerformedCallback',{@doRestore,fig});
add(p2,ui.restorebutton);
ui.exportbutton = com.mathworks.mwswing.MJButton(xlate('Export...'));
setcallback(ui.exportbutton,'actionPerformedCallback',{@doExport,fig});
add(p2,ui.exportbutton);
ui.okbutton = com.mathworks.mwswing.MJButton('OK');
setcallback(ui.okbutton,'actionPerformedCallback',{@doOK,fig});
add(p2,ui.okbutton);
ui.closebutton = com.mathworks.mwswing.MJButton(xlate('Cancel'));
setcallback(ui.closebutton,'actionPerformedCallback',{@doCancel,fig});
add(p2,ui.closebutton);

function ui = createsizepanel(ui,fig)
pane = com.mathworks.mwswing.MJPanel;
setLayout(pane,java.awt.GridBagLayout);
[gbc,gbc2] = initGridBagConstraints;

% panel for width and units
p2 = com.mathworks.mwswing.MJPanel;
flowright = java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,0,0);
setLayout(p2,flowright);

% Width 
ui.widthitems = {xauto};
widthtext = com.mathworks.mwswing.MJComboBox(ui.widthitems);
setcallback(widthtext,'actionPerformedCallback',{@widthChanged,fig});
setcallback(widthtext,'focusLostCallback',{@widthChanged,fig});
setPreferredSize(widthtext,java.awt.Dimension(75,20));
setEditable(widthtext,true);
add(pane,com.mathworks.mwswing.MJLabel(xlate('  Width:')),gbc);
add(p2,widthtext);
ui.widthtext = widthtext;
setAccessibleName(getAccessibleContext(ui.widthtext),...
                  'Figure width');

% Units
[vals,strs] = getUnitsVals;
unitsbutton = com.mathworks.mwswing.MJComboBox(strs);
setcallback(unitsbutton,'actionPerformedCallback',{@unitsChanged,fig});
add(p2,com.mathworks.mwswing.MJLabel(xlate('  Units:')));
setPreferredSize(unitsbutton,java.awt.Dimension(100,20));
add(p2,unitsbutton);
ui.unitsbutton = unitsbutton;
setAccessibleName(getAccessibleContext(ui.unitsbutton),...
                  'Units');

gbc2.gridwidth = java.awt.GridBagConstraints.REMAINDER;
gbc2.anchor = java.awt.GridBagConstraints.WEST;
add(pane,p2,gbc2);
gbc2.anchor = java.awt.GridBagConstraints.WEST;
gbc2.gridwidth = 1;
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;

% Height 
ui.heightitems = {xauto};
heighttext = com.mathworks.mwswing.MJComboBox(ui.heightitems);
setEditable(heighttext,true);
setcallback(heighttext,'actionPerformedCallback',{@heightChanged,fig});
setcallback(heighttext,'focusLostCallback',{@heightChanged,fig});
setPreferredSize(heighttext,java.awt.Dimension(75,20));
add(pane,com.mathworks.mwswing.MJLabel(xlate('  Height:')),gbc);
add(pane,heighttext,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.heighttext = heighttext;
setAccessibleName(getAccessibleContext(ui.heighttext),...
                  'Figure height');

% Bounds button
boundsbutton = com.mathworks.mwswing.MJCheckBox(xlate('Expand axes to fill figure'));
setcallback(boundsbutton,'actionPerformedCallback',{@boundsChanged,fig});
add(pane,boundsbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.boundsbutton = boundsbutton;

% extra panel to get the spacing to put the widgets in the upper left
gbc2.weighty = 1;
add(pane,com.mathworks.mwswing.MJPanel,gbc2);

setAccessibleName(getAccessibleContext(pane),'Size');
add(ui.cardpane,pane,'Size');


function ui = createrenderpanel(ui,fig)
pane = com.mathworks.mwswing.MJPanel;
setLayout(pane,java.awt.GridBagLayout);
[gbc,gbc2] = initGridBagConstraints;

% Color
[colors,strs] = getColorVals;
colorbutton = com.mathworks.mwswing.MJComboBox(strs);
setcallback(colorbutton,'actionPerformedCallback',{@colorChanged,fig});
add(pane,com.mathworks.mwswing.MJLabel(xlate('  Colorspace:')),gbc);
add(pane,colorbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.colorbutton = colorbutton;
setAccessibleName(getAccessibleContext(ui.colorbutton),...
                  'Colorspace');

% BackgroundColor
backcolortext = com.mathworks.mwswing.MJTextField(10);
setcallback(backcolortext,'actionPerformedCallback',{@backcolorChanged,fig});
setcallback(backcolortext,'focusLostCallback',{@backcolorChanged,fig});
backcolorcustombutton = com.mathworks.mwswing.MJCheckBox(...
    xlate('Custom color:'));
setcallback(backcolorcustombutton,'actionPerformedCallback',{@backcolorcustomChanged,fig});
add(pane,backcolorcustombutton,gbc);
add(pane,backcolortext,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.backcolortext = backcolortext;
ui.backcolorcustombutton = backcolorcustombutton;
setAccessibleName(getAccessibleContext(ui.backcolortext),...
                  'Background color');
setAccessibleName(getAccessibleContext(ui.backcolorcustombutton),...
                  'Custom background color');

% Renderer
[rends,strs] = getRendererVals;
rendererbutton = com.mathworks.mwswing.MJComboBox(strs);
setcallback(rendererbutton,'actionPerformedCallback',{@rendererChanged,fig});
rendercustombutton = com.mathworks.mwswing.MJCheckBox(xlate('Custom renderer:'));
setcallback(rendercustombutton,'actionPerformedCallback',{@rendercustomChanged,fig});
add(pane,rendercustombutton,gbc);
add(pane,rendererbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.rendererbutton = rendererbutton;
ui.rendercustombutton = rendercustombutton;
setAccessibleName(getAccessibleContext(ui.rendererbutton),...
                  'Renderer');
setAccessibleName(getAccessibleContext(ui.rendercustombutton),...
                  'Custom renderer');

% Resolution
ui.resitems = {xscreen,'150','300','600',xauto};
restext = com.mathworks.mwswing.MJComboBox(ui.resitems);
setcallback(restext,'actionPerformedCallback',{@resChanged,fig});
setcallback(restext,'focusLostCallback',{@resChanged,fig});
setEditable(restext,true);
add(pane,com.mathworks.mwswing.MJLabel(xlate('  Resolution (dpi):')),gbc);
add(pane,restext,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.restext = restext;
setAccessibleName(getAccessibleContext(ui.restext),...
                  'Resolution');

% Lock button
lockbutton = com.mathworks.mwswing.MJCheckBox(xlate('Keep axis limits'));
setcallback(lockbutton,'actionPerformedCallback',{@lockChanged,fig});
add(pane,lockbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.lockbutton = lockbutton;

% Showui button
showuibutton = com.mathworks.mwswing.MJCheckBox(xlate('Show uicontrols'));
setcallback(showuibutton,'actionPerformedCallback',{@showuiChanged,fig});
add(pane,showuibutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.showuibutton = showuibutton;

% extra panel to get the spacing to put the widgets in the upper left
gbc2.weighty = 1;
add(pane,com.mathworks.mwswing.MJPanel,gbc2);

setAccessibleName(getAccessibleContext(pane),'Rendering');
add(ui.cardpane,pane,'Rendering');


function ui = createfontpanel(ui,fig)
pane = com.mathworks.mwswing.MJPanel;
setLayout(pane,java.awt.GridBagLayout);
[gbc,gbc2] = initGridBagConstraints;

% FontMode
fontmodecustom = com.mathworks.mwswing.MJCheckBox(xlate('Custom size:'));
setcallback(fontmodecustom,'actionPerformedCallback',{@fontmodecustomChanged,fig});
add(pane,fontmodecustom,gbc);
ui.fontmodecustom = fontmodecustom;
setAccessibleName(getAccessibleContext(ui.fontmodecustom),...
                  'Custom font size');

fontgroup = javax.swing.ButtonGroup;
flowlayout = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,0);
p1 = com.mathworks.mwswing.MJPanel;
setLayout(p1,flowlayout);
fontmodescale = com.mathworks.mwswing.MJRadioButton(xlate('Scale font by '));
setcallback(fontmodescale,'actionPerformedCallback',{@fontmodescaleChanged,fig});
add(p1,fontmodescale);
fontscale = com.mathworks.mwswing.MJTextField(5);
setcallback(fontscale,'actionPerformedCallback',{@fontscaleChanged,fig});
setcallback(fontscale,'focusLostCallback',{@fontscaleChanged,fig});
add(p1,fontscale);
add(p1, com.mathworks.mwswing.MJLabel('%'));
p2 = com.mathworks.mwswing.MJPanel;
setLayout(p2,flowlayout);
add(p2, com.mathworks.mwswing.MJLabel(xlate('       with minimum of ')));
fontmin = com.mathworks.mwswing.MJTextField(5);
setcallback(fontmin,'actionPerformedCallback',{@fontminChanged,fig});
setcallback(fontmin,'focusLostCallback',{@fontminChanged,fig});
add(p2,fontmin);
add(p2, com.mathworks.mwswing.MJLabel(xlate(' points')));
add(pane,p1,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
add(pane,p2,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.fontmodescale = fontmodescale;
ui.fontscale = fontscale;
ui.fontmin = fontmin;
setAccessibleName(getAccessibleContext(ui.fontmodescale),...
                  'Scale fonts');
setAccessibleName(getAccessibleContext(ui.fontscale),...
                  'Font scale factor');
setAccessibleName(getAccessibleContext(ui.fontmin),...
                  'Minimum font size');

p1 = com.mathworks.mwswing.MJPanel;
setLayout(p1,flowlayout);
fontmodefix = com.mathworks.mwswing.MJRadioButton(xlate('Use fixed font size '));
setcallback(fontmodefix,'actionPerformedCallback',{@fontmodefixChanged,fig});
add(p1,fontmodefix);
fontfix = com.mathworks.mwswing.MJTextField(5);
setcallback(fontfix,'actionPerformedCallback',{@fontfixChanged,fig});
setcallback(fontfix,'focusLostCallback',{@fontfixChanged,fig});
add(p1,fontfix);
add(p1, com.mathworks.mwswing.MJLabel(xlate(' points')));
add(pane,p1,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.fontmodefix = fontmodefix;
ui.fontfix = fontfix;
add(fontgroup,fontmodescale);
add(fontgroup,fontmodefix);
setAccessibleName(getAccessibleContext(ui.fontmodefix),...
                  'Fixed font size');
setAccessibleName(getAccessibleContext(ui.fontfix),...
                  'Font size');

% FontName
fontnamecustom = com.mathworks.mwswing.MJCheckBox(xlate('Custom name:'));
setcallback(fontnamecustom,'actionPerformedCallback',{@fontnamecustomChanged,fig});
add(pane,fontnamecustom,gbc);
ui.fontlist = listfonts;
fontnametext = com.mathworks.mwswing.MJComboBox(ui.fontlist);
setcallback(fontnametext,'actionPerformedCallback',{@fontnameChanged,fig});
add(pane,fontnametext,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.fontnamecustom = fontnamecustom;
ui.fontnametext = fontnametext;
setAccessibleName(getAccessibleContext(ui.fontnamecustom),...
                  'Custom font name');
setAccessibleName(getAccessibleContext(ui.fontnametext),...
                  'Font name');

% FontWeight
fontweightcustom = com.mathworks.mwswing.MJCheckBox(xlate('Custom weight:'));
setcallback(fontweightcustom,'actionPerformedCallback',{@fontweightcustomChanged,fig});
add(pane,fontweightcustom,gbc);
[vals,strs] = getWeightVals;
weightbutton = com.mathworks.mwswing.MJComboBox(strs);
setcallback(weightbutton,'actionPerformedCallback',{@weightChanged,fig});
add(pane,weightbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.weightbutton = weightbutton;
ui.fontweightcustom = fontweightcustom;
setAccessibleName(getAccessibleContext(ui.fontweightcustom),...
                  'Custom font weight');
setAccessibleName(getAccessibleContext(ui.weightbutton),...
                  'Font weight');

% FontAngle
fontanglecustom = com.mathworks.mwswing.MJCheckBox(xlate('Custom angle:'));
setcallback(fontanglecustom,'actionPerformedCallback',{@fontanglecustomChanged,fig});
add(pane,fontanglecustom,gbc);
[vals,strs] = getAngleVals;
anglebutton = com.mathworks.mwswing.MJComboBox(strs);
setcallback(anglebutton,'actionPerformedCallback',{@angleChanged,fig});
add(pane,anglebutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.anglebutton = anglebutton;
ui.fontanglecustom = fontanglecustom;
setAccessibleName(getAccessibleContext(ui.fontanglecustom),...
                  'Custom font angle');
setAccessibleName(getAccessibleContext(ui.anglebutton),...
                  'Font angle');

% extra panel to get the spacing to put the widgets in the upper left
gbc2.weighty = 1;
add(pane,com.mathworks.mwswing.MJPanel,gbc2);

setAccessibleName(getAccessibleContext(pane),'Fonts');
add(ui.cardpane,pane,'Fonts');


function ui = createlinepanel(ui,fig)
pane = com.mathworks.mwswing.MJPanel;
setLayout(pane,java.awt.GridBagLayout);
[gbc,gbc2] = initGridBagConstraints;

% LineMode
linemodecustom = com.mathworks.mwswing.MJCheckBox(xlate('Custom width:'));
setcallback(linemodecustom,'actionPerformedCallback',{@linemodecustomChanged,fig});
add(pane,linemodecustom,gbc);
ui.linemodecustom = linemodecustom;

linegroup = javax.swing.ButtonGroup;
flowlayout = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,0);
p1 = com.mathworks.mwswing.MJPanel;
setLayout(p1,flowlayout);
linemodescale = com.mathworks.mwswing.MJRadioButton(xlate('Scale line width by '));
setcallback(linemodescale,'actionPerformedCallback',{@linemodescaleChanged,fig});
add(p1,linemodescale);
linescale = com.mathworks.mwswing.MJTextField(5);
setcallback(linescale,'actionPerformedCallback',{@linescaleChanged,fig});
setcallback(linescale,'focusLostCallback',{@linescaleChanged,fig});
add(p1,linescale);
add(p1, com.mathworks.mwswing.MJLabel('%'));
p2 = com.mathworks.mwswing.MJPanel;
setLayout(p2,flowlayout);
add(p2, com.mathworks.mwswing.MJLabel(xlate('       with minimum of ')));
linemin = com.mathworks.mwswing.MJTextField(5);
setcallback(linemin,'actionPerformedCallback',{@lineminChanged,fig});
setcallback(linemin,'focusLostCallback',{@lineminChanged,fig});
add(p2,linemin);
add(p2, com.mathworks.mwswing.MJLabel(xlate(' points')));
add(pane,p1,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
add(pane,p2,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.linemodescale = linemodescale;
ui.linescale = linescale;
ui.linemin = linemin;
setAccessibleName(getAccessibleContext(ui.linemodescale),...
                  'Scale line widths');
setAccessibleName(getAccessibleContext(ui.linescale),...
                  'Line width scale factor');
setAccessibleName(getAccessibleContext(ui.linemin),...
                  'Minimum line width');

p1 = com.mathworks.mwswing.MJPanel;
setLayout(p1,flowlayout);
linemodefix = com.mathworks.mwswing.MJRadioButton(xlate('Use fixed line width '));
setcallback(linemodefix,'actionPerformedCallback',{@linemodefixChanged,fig});
add(p1,linemodefix);
linefix = com.mathworks.mwswing.MJTextField(5);
setcallback(linefix,'actionPerformedCallback',{@linefixChanged,fig});
setcallback(linefix,'focusLostCallback',{@linefixChanged,fig});
add(p1,linefix);
add(p1, com.mathworks.mwswing.MJLabel(xlate(' points')));
add(pane,p1,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.linemodefix = linemodefix;
ui.linefix = linefix;
add(linegroup,linemodescale);
add(linegroup,linemodefix);
setAccessibleName(getAccessibleContext(ui.linemodefix),...
                  'Fixed line width');
setAccessibleName(getAccessibleContext(ui.linefix),...
                  'Line width');

% Style button
stylebutton = com.mathworks.mwswing.MJCheckBox(...
    xlate('Convert solid lines to cycle through line styles'));
setcallback(stylebutton,'actionPerformedCallback',{@styleChanged,fig});
gbc.gridwidth = java.awt.GridBagConstraints.REMAINDER;
gbc.anchor = java.awt.GridBagConstraints.WEST;
add(pane,stylebutton,gbc);
gbc.anchor = java.awt.GridBagConstraints.WEST;
gbc.gridwidth = 1;
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.stylebutton = stylebutton;

% extra panel to get the spacing to put the widgets in the upper left
gbc2.weighty = 1;
add(pane,com.mathworks.mwswing.MJPanel,gbc2);

setAccessibleName(getAccessibleContext(pane),'Line');
add(ui.cardpane,pane,'Lines');


function ui = createepspanel(ui,fig)
% unused right now - remove if final
pane = com.mathworks.mwswing.MJPanel;
setLayout(pane,java.awt.GridBagLayout);
[gbc,gbc2] = initGridBagConstraints;

% Preview button
previewbutton = com.mathworks.mwswing.MJCheckBox('Include TIFF preview');
setcallback(previewbutton,'actionPerformedCallback',{@previewChanged,fig});
add(pane,com.mathworks.mwswing.MJLabel(' '),gbc);
add(pane,previewbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.previewbutton = previewbutton;

% Pslevel button
pslevelbutton = com.mathworks.mwswing.MJCheckBox(['Use Postscript ' ...
                    'level 2']);
setcallback(pslevelbutton,'actionPerformedCallback',{@pslevelChanged,fig});
add(pane,pslevelbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.pslevelbutton = pslevelbutton;

% Encoding button
encodingbutton = com.mathworks.mwswing.MJCheckBox(['Use Adobe Postscript ' ...
                    'font encoding']);
setcallback(encodingbutton,'actionPerformedCallback',{@encodingChanged,fig});
add(pane,encodingbutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.encodingbutton = encodingbutton;

% Separate button
separatebutton = com.mathworks.mwswing.MJCheckBox(['Create separate EPS ' ...
                    'file for text']);
setcallback(separatebutton,'actionPerformedCallback',{@separateChanged,fig});
add(pane,separatebutton,gbc2);
gbc.gridy = gbc.gridy + 1;
gbc2.gridy = gbc2.gridy + 1;
ui.separatebutton = separatebutton;


% extra panel to get the spacing to put the widgets in the upper left
gbc2.weighty = 1;
add(pane,com.mathworks.mwswing.MJPanel,gbc2);

setAccessibleName(getAccessibleContext(pane),'EPS');
add(ui.cardpane,pane,'EPS');

%---------------------------  Callbacks  -----------------------

function doPanelChoice(hSrc, eventData, fig);
ui = getui(fig);
if ui.active
  ind = getSelectedIndex(ui.panelchoice);
  [tabs,strs] = getTabs;
  awtinvoke(ui.cardlayout,'show(Ljava/awt/Container;Ljava/lang/String;)',...
            ui.cardpane,java.lang.String(tabs{ind+1}));
end

function doLoadStyle(hSrc, eventData, fig);
ui = getui(fig);
if ui.active
  ind = getSelectedIndex(ui.selectstylebutton);
  stylename = ui.styles{ind+1};
  if strcmp(stylename,xdefault), stylename = 'default'; end
  path = getStyleDir;
  if strcmpi(stylename,'default')
    ui.style = hgexport('factorystyle');
  else
    try
      ui.style = hgexport('readstyle',stylename);
    catch
      errordlg(['Unable to load style ''' stylename '''.']);
      return;
    end
  end
  ui.active = false;
  setui(fig,ui);
  ui = loadstyle(ui.style,ui);
end

function doApply(hSrc, eventData,fig);
ui = getui(fig);
if ~isempty(ui.figure) && ishandle(ui.figure)
  drawnow;
  if ~isempty(ui.oldstate)
    doRestore(hSrc,eventData,fig);
  end
  ui.oldstate = hgexport(ui.figure,tempname,ui.style,'applystyle', true);
  drawnow;
  setappdata(ui.figure,'ExportsetupApplied',true);
  setappdata(ui.figure,'Exportsetup',ui.style)
end
setui(fig,ui);
awtinvoke(ui.restorebutton,'setEnabled(Z)',true);

function doRestore(hSrc, eventData,fig);
ui = getui(fig);
if ~isempty(ui.figure) && ishandle(ui.figure) && ~isempty(ui.oldstate)
  drawnow;
  old = ui.oldstate;
  for n=1:length(old.objs)
    try
      if ~iscell(old.values{n}) & iscell(old.prop{n})
        old.values{n} = {old.values{n}};
      end
      set(old.objs{n}, old.prop{n}, old.values{n});
    end
  end
end
ui.oldstate = [];
if ~isempty(ui.figure) && ishandle(ui.figure)
  try
    rmappdata(ui.figure,'ExportsetupApplied');
  end
end
setui(fig,ui);
awtinvoke(ui.restorebutton,'setEnabled(Z)',false);
drawnow;

function doExport(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  oldstyle = getappdata(fig,'Exportsetup');
  if isempty(oldstyle)
    setappdata(fig,'Exportsetup',ui.style);
  end
  filemenufcn(fig,'FileSaveAs');
  if isempty(oldstyle)
    try
      rmappdata(fig,'Exportsetup');
    end
  end
end

function doDelete(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  oldpointer = getCursor(getContentPane(ui.win));
  awtinvoke(getContentPane(ui.win),'setCursor(Ljava/awt/Cursor;)',...
	    java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
  drawnow;
  path = getStyleDir;
  name = char(getSelectedItem(ui.deletestylelist));
  try
    delete(fullfile(path,[name '.txt']));
  end
  ui.styles = getStyles;
  updateStyleLists(ui);
  awtinvoke(getContentPane(ui.win),'setCursor(Ljava/awt/Cursor;)',...
	    oldpointer);
  drawnow;
  ui.active = true;
  setui(fig,ui);
end

function doSave(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  name = char(getText(ui.savetext));
  if ~isempty(name)
    hgexport('writestyle',ui.style,name);
    ui.styles = getStyles;
    ui.active = false;
    clearDirty(ui);
    updateStyleLists(ui);
    drawnow;
  end
  ui.active = true;
  setui(fig,ui);
end

function updateStyleLists(ui)
awtinvoke(ui.selectstylebutton,'setModel(Ljavax/swing/ComboBoxModel;)',...
	  javax.swing.DefaultComboBoxModel(ui.styles));
styles = ui.styles;
styles(strcmp(xdefault,styles)) = [];
styles(strcmp('PowerPoint',styles)) = [];
styles(strcmp('MSWord',styles)) = [];
enableDelete = ~isempty(styles);
if isempty(styles), styles = {' '}; end
awtinvoke(ui.deletestylelist,'setModel(Ljavax/swing/ComboBoxModel;)',...
	  javax.swing.DefaultComboBoxModel(styles));
awtinvoke(ui.deletebutton,'setEnabled(Z)',enableDelete);

function doOK(hSrc, eventData,fig);
ui = getui(fig);
ui.active = false;
if ishandle(ui.figure)
  drawnow;
  setappdata(ui.figure,'Exportsetup',ui.style)
end
setui(fig,ui);
awtinvoke(ui.win,'setVisible(Z)',false);

function doCloseForce(hSrc, eventData,fig);
ui = getui(fig);
awtinvoke(ui.win,'dispose');

function doCancel(hSrc, eventData,fig);
ui = getui(fig);
ui.active = false;
setui(fig,ui);
doRestore(hSrc,eventData,fig);
awtinvoke(ui.win,'dispose');
drawnow;
setui(fig,[]);

function widthChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  newval = char(getSelectedItem(ui.widthtext));
  if isempty(newval) || strcmp(newval,xauto)
    newval = 'auto';
  end
  if ~isequal(ui.style.Width,newval)
    ui.widthitems = updateEditableComboBox(newval,ui.widthitems,...
                                           ui.widthtext,false);
    ui.style.Width = newval;
    setDirty(ui);
  end
end

function heightChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  newval = char(getSelectedItem(ui.heighttext));
  if isempty(newval)
    newval = 'auto';
  end
  if ~isequal(ui.style.Height,newval)
    ui.heightitems = updateEditableComboBox(newval,ui.heightitems,...
                                            ui.heighttext,false);
    ui.style.Height = newval;
    setDirty(ui);
  end
end

function unitsChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  units = getUnitsVals;
  ui.style.Units = units{getSelectedIndex(ui.unitsbutton)+1};
  setDirty(ui);
end

function previewChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.previewbutton)
    ui.style.Preview = 'tiff';
  else
    ui.style.Preview = 'none';
  end
  setDirty(ui);
end

function boundsChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.boundsbutton)
    ui.style.Bounds = 'tight';
  else
    ui.style.Bounds = 'loose';
  end
  setDirty(ui);
end

function pslevelChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.pslevelbutton)
    ui.style.PSLevel = 2;
  else
    ui.style.PSLevel = 1;
  end
  setDirty(ui);
end

function colorChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  [colors,strs] = getColorVals;
  ui.style.Color = colors{getSelectedIndex(ui.colorbutton)+1};
  setDirty(ui);
end

function backcolorChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.Background = char(getText(ui.backcolortext));
  setDirty(ui);
end

function backcolorcustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.backcolorcustombutton)
    ui.style.Background = '';
  else
    ui.style.Background = char(getText(ui.backcolortext));
  end
  setDirty(ui);
end

function rendererChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  [rends,strs] = getRendererVals;
  ui.style.Renderer = rends{getSelectedIndex(ui.rendererbutton)+1};
  awtinvoke(ui.rendercustombutton,'setSelected(Z)',true);
  setDirty(ui);
end

function rendercustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.rendercustombutton)
    ui.style.Renderer = 'auto';
  else
    [rends,strs] = getRendererVals;
    ui.style.Renderer = rends{getSelectedIndex(ui.rendererbutton)+1};
  end
  setDirty(ui);
end

function resChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  newvalstr = char(getSelectedItem(ui.restext));
  newval = newvalstr;
  if isempty(newvalstr)
    newval = 'auto';
  end
  if strcmp(newvalstr,xscreen)
    newval = 0;
  elseif ~strcmp(newvalstr,'auto')
    try
      newval = str2num(newvalstr);
    catch
      return; % don't set values if they are illegal
    end
  end
  if ~isequal(ui.style.Resolution,newval)
    ui.resitems = updateEditableComboBox(newvalstr,ui.resitems,ui.restext,false);
    ui.style.Resolution = newval;
    setDirty(ui);
  end
end

function lockChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.lockbutton)
    ui.style.LockAxes = 'on';
  else
    ui.style.LockAxes = 'off';
  end
  setDirty(ui);
end

function showuiChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.showuibutton)
    ui.style.ShowUI = 'on';
  else
    ui.style.ShowUI = 'off';
  end
  setDirty(ui);
end

function separateChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.separatebutton)
    ui.style.SeparateText = 'on';
  else
    ui.style.SeparateText = 'off';
  end
  setDirty(ui);
end

function fontmodecustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.fontmodecustom)
    ui.style.FontMode = 'none';
  elseif isSelected(ui.fontmodescale)
    ui.style.FontMode = 'scaled';
  else
    ui.style.FontMode = 'fixed';
  end
  setDirty(ui);
end

function fontmodescaleChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.fontmodescale)
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    ui.style.FontMode = 'scaled';
  end
  setDirty(ui);
end

function fontmodefixChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.fontmodefix)
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    ui.style.FontMode = 'fixed';
  end
  setDirty(ui);
end

function fontscaleChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.ScaledFontSize = char(getText(ui.fontscale));
  awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
  awtinvoke(ui.fontmodescale,'setSelected(Z)',true);
  ui.style.FontMode = 'scaled';
  setDirty(ui);
end

function fontminChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.FontSizeMin = str2num(getText(ui.fontmin));
  awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
  awtinvoke(ui.fontmodescale,'setSelected(Z)',true);
  ui.style.FontMode = 'scaled';
  setDirty(ui);
end

function fontfixChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.FixedFontSize = str2num(getText(ui.fontfix));
  awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
  awtinvoke(ui.fontmodefix,'setSelected(Z)',true);
  ui.style.FontMode = 'fixed';
  setDirty(ui);
end

function fontnameChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ind = getSelectedIndex(ui.fontnametext);
  ui.style.FontName = ui.fontlist{ind+1};
  awtinvoke(ui.fontnamecustom,'setSelected(Z)',true);
  setDirty(ui);
end

function fontnamecustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.fontnamecustom)
    ui.style.FontName = 'auto';
  end
  setDirty(ui);
end

function fontweightcustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.fontweightcustom)
    ui.style.FontWeight = 'auto';
  end
  setDirty(ui);
end

function weightChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  vals = getWeightVals;
  ui.style.FontWeight = vals{getSelectedIndex(ui.weightbutton)+1};
  awtinvoke(ui.fontweightcustom,'setSelected(Z)',true);
  setDirty(ui);
end

function fontanglecustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.fontanglecustom)
    ui.style.FontAngle = 'auto';
  end
  setDirty(ui);
end

function angleChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  vals = getAngleVals;
  ui.style.FontAngle = vals{getSelectedIndex(ui.anglebutton)+1};
  awtinvoke(ui.fontanglecustom,'setSelected(Z)',true);
  setDirty(ui);
end

function encodingChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.encodingbutton)
    ui.style.FontEncoding = 'adobe';
  else
    ui.style.FontEncoding = 'latin1';
  end
  setDirty(ui);
end

function linemodecustomChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if ~isSelected(ui.linemodecustom)
    ui.style.LineMode = 'none';
  elseif isSelected(ui.linemodescale)
    ui.style.LineMode = 'scaled';
  else
    ui.style.LineMode = 'fixed';
  end
  setDirty(ui);
end

function linemodescaleChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.linemodescale)
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    ui.style.LineMode = 'scaled';
  end
  setDirty(ui);
end

function linemodefixChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.linemodefix)
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    ui.style.LineMode = 'fixed';
  end
  setDirty(ui);
end

function linescaleChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.ScaledLineWidth = char(getText(ui.linescale));
  awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
  awtinvoke(ui.linemodescale,'setSelected(Z)',true);
  ui.style.LineMode = 'scaled';
  setDirty(ui);
end

function lineminChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.LineWidthMin = str2num(getText(ui.linemin));
  awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
  awtinvoke(ui.linemodescale,'setSelected(Z)',true);
  ui.style.LineMode = 'scaled';
  setDirty(ui);
end

function linefixChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  ui.style.FixedLineWidth = str2num(getText(ui.linefix));
  awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
  awtinvoke(ui.linemodefix,'setSelected(Z)',true);
  ui.style.LineMode = 'fixed';
  setDirty(ui);
end

function styleChanged(hSrc, eventData,fig);
ui = getui(fig);
if ui.active
  if isSelected(ui.stylebutton)
    ui.style.LineStyleMap = 'bw';
  else
    ui.style.LineStyleMap = 'none';
  end
  setDirty(ui);
end

%-------------------------  Helper Subfunctions  ----------------------

function [gbc,gbc2] = initGridBagConstraints;
gbc = java.awt.GridBagConstraints;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.weightx = 0;
gbc.insets = java.awt.Insets(2,0,2,0);
gbc.anchor = java.awt.GridBagConstraints.WEST;
gbc2 = java.awt.GridBagConstraints;
gbc2.gridx = 1;
gbc2.gridy = 0;
gbc2.weightx = 1;
gbc2.insets = java.awt.Insets(2,0,2,0);
gbc2.anchor = java.awt.GridBagConstraints.WEST;

function [out,strs] = getUnitsVals;
out = {'inches','centimeters','points'};
strs = xcell(out);

function [out,strs] = getColorVals;
out = {'bw','gray','rgb','cmyk'};
strs = {xlate('black and white'),xlate('grayscale'),xlate('RGB color'),xlate('CMYK color')};

function [out,strs] = getRendererVals;
out = {'painters','opengl','zbuffer'};
strs = {xlate('painters (vector format)'),xlate('OpenGL (bitmap format)'),...
        xlate('zbuffer (bitmap format)')};

function [out,strs] = getWeightVals;
out = {'normal','light','demi','bold'};
strs = xcell(out);

function [out,strs] = getAngleVals;
out = {'normal','italic','oblique'};
strs = xcell(out);

function [out,strs] = getTabs;
out = {'Size','Rendering','Fonts','Lines'};
strs = xcell(out);

function items = updateEditableComboBox(str,items,combobox,select)
if isempty(str) || strcmp(str,'auto'), str = xauto; end
ind = find(strcmpi(str,items));
if isempty(ind)
  if strcmp(str,'0'), str = xscreen; end % for resolution = 0
  items = {str, items{:}};
  awtinvoke(combobox,'insertItemAt(Ljava/lang/Object;I)',...
            java.lang.String(str),0);
  ind = 1;
end
if select
  awtinvoke(combobox,'setSelectedIndex(I)',ind-1);
end

function path = getStyleDir
path = fullfile(prefdir(0),'ExportSetup');

function initStandardStyles(path)
wordfile = fullfile(path,'MSWord.txt');
if ~exist(wordfile)
  word = hgexport('factorystyle');
  hgexport('writestyle',word,'MSWord');
end
pptfile = fullfile(path,'PowerPoint.txt');
if ~exist(pptfile)
  ppt = hgexport('factorystyle');
  ppt.FontWeight = 'bold';
  ppt.FontMode = 'scaled';
  ppt.ScaledFontSize = '140';
  ppt.LineMode = 'fixed';
  ppt.FixedLineWidth = 2;
  hgexport('writestyle',ppt,'PowerPoint');
end

function setDirty(ui)
if ui.active
  ui.dirty = true;
  setui(ui.figure,ui);
end

function clearDirty(ui)
ui.dirty = false;
setui(ui.figure,ui);

function styles = getStyles
styledir = getStyleDir;
files = dir(styledir);
files = files([files.isdir] == 0);
styles = {files.name};
isstyle = false(length(styles),1);
for k=1:length(styles)
  if regexp(styles{k},'\.txt$')
    isstyle(k) = true;
    styles{k} = styles{k}(1:end-4);
  end
end
styles = styles(isstyle);
if ~any(strcmpi(styles,xdefault))
  styles = {xdefault,styles{:}};
end
if ~any(strcmp(styles,'PowerPoint'))
  styles = {styles{:}, 'PowerPoint'};
end
if ~any(strcmp(styles,'MSWord'))
  styles = {styles{:}, 'MSWord'};
end

function ui = getui(fig)
ui = [];
if isprop(handle(fig),'ExportsetupWindow')
  ui = get(handle(fig),'ExportsetupWindow');
end

function setui(fig,ui)
hfig = handle(fig);
if ~isprop(hfig,'ExportsetupWindow')
  p = schema.prop(hfig,'ExportsetupWindow','MATLAB array');
  p.AccessFlags.Serialize = 'off';
  p.Visible = 'off';
end
set(hfig,'ExportsetupWindow',ui);

function setcallback(java_obj, callback, value)
set(handle(java_obj,'callbackproperties'),callback,value);

% I18N support helpers

function out = xauto
out = xlate('auto');

function out = xscreen
out = xlate('screen');

function out = xdefault
out = xlate('default');

function out = xcell(in)
for k=length(in):-1:1
  out{k} = xlate(in{k});
end