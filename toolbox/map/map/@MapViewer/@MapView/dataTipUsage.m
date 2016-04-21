function dataTipUsage(this, probType,toolstr)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:49:47 $

oldunits = get(this.Figure,'Units');
set(this.Figure,'Units','inches');
p = get(this.Figure,'Position');
set(this.Figure,'Units',oldunits);
w = 4.5;
h = 2.0;
x = p(1) + p(3)/2 - w/2;
y = p(2) + p(4)/2 - h/2;


position  = [x,y,w,h];

% activeLayer = this.getMap.getLayer(this.ActiveLayerName);
if strcmp(lower(probType),'default')
  h = dataTipUsageDlg(this, position);
elseif strcmp(lower(probType),'noactivelayer')
  warnStr = sprintf(['\n\tAn active layer is not selected!\n',...
                     'Select an active layer from the Active Layer drop-down\n',...
                     'menu before using the %s.'],toolstr);
  h = warndlg(warnStr,sprintf('%s Usage',toolstr),'modal');
  okButton = findall(get(h,'Children'),'type','uicontrol','String','OK');
  set(okButton,'Callback',{@doOK h [] [] []});
end
% $$$ elseif isempty(activeLayer.getAttributesNames)
% $$$   warnStr = sprintf(['\n\tThe  active layer does not have any attributes!\n',...
% $$$                      'Select another layer with attributes from the Active Layer\n',...
% $$$                      'drop-down menu before using the Datatip Tool.']);
% $$$   h = warndlg(warnStr,'Datatip Tool Usage','modal');
% $$$   okButton = findall(get(h,'Children'),'type','uicontrol','String','OK');
% $$$   set(okButton,'Callback',{@doOK h [] [] []});
% $$$ end  
  

function mutuallyExclusive(hSrc,event,handles)
set(handles(handles ~= hSrc),'Value',0);

function doOK(hSrc,event,h,viewer,chk1,chk2)
if ~isempty(chk1) && ~isempty(chk2)
  if get(chk1,'Value') == 1
    viewer.Preferences.ShowDatatipUsage = false;
  elseif get(chk2,'Value') == 1
    setpref('MathWorks_MapViewer','ShowDatatipUsage',false);
  end
end
delete(h);

function f = dataTipUsageDlg(this, position)
% This dialog is the same as a help dialog (helpdlg) but has two
% check boxes.
f = figure('Units','inches','Position',position,'menubar','none',...
           'toolbar','none','Name','Datatip Tool Usage','NumberTitle','off',...
           'Resize','off','IntegerHandle','off','Visible','off');
color = get(f,'Color');

ax1 = axes('Parent',f,'Units','normalized','Position',[0 0.3333 1 1-0.35], ...
           'Visible','off');
ax2 = axes('Parent',f,'Units','points','Position',[7 85 38 38], ...
           'Visible','off');
[icondata,iconmap] = getHelpIcon;
im = image('Parent',ax2,'Cdata',icondata);
set(ax2, 'XLim',get(im,'XData')+[-0.5 0.5],'YLim',get(im,'YData')+[-0.5 0.5], ...
         'YDir','reverse');
set(f,'Colormap',iconmap);

lhand=handle(this.Axis.getLayerHandles(this.ActiveLayerName));
attr = lhand(1).DataTipAttribute;
if isempty(attr) 
  lyr = this.getMap.getLayer(lhand(1).LayerName);
  attrNames = lyr.getAttributeNames;
  attr = attrNames{1};
end

str1 = sprintf(['The current label attribute is the ''%s'' attribute.\n',...
                'To set another label attribute:\n',...
                '   ->Select the active layer from the Layers menu\n',...
                '   ->Select Set Label Attribute'],attr);

t1 = text('Parent',ax1,'Units','normalized','Position',[0.1675 0.65 0],'String',str1,...
          'FontWeight','bold');
color = get(f,'Color');
str2 = ['Don''t show this message again: '];
t2 = uicontrol(f,'Style','text','Units','normalized',...
               'HorizontalAlignment','left',...
               'Position',[0.2 0.4 0.4 0.1],...
               'BackgroundColor',color,...
               'String',str2);
r1 = uicontrol(f,'Style','checkbox','Units','normalized',...
               'HorizontalAlignment','left',...
               'Position',[0.2 0.3 0.4 0.1],...
               'BackgroundColor',color,...
               'String','In this session','Value',1);
r2 = uicontrol(f,'Style','checkbox','Units','normalized',...
               'Position',[0.2 0.2 0.4 0.1],...
               'BackgroundColor',color,...
               'HorizontalAlignment','left',...
               'String','Ever again');
okButton = uicontrol('Style','pushbutton','Units','Points','Position',...
                     [141.8558 7 40 17],'String','OK','Callback',...
                     {@doOK f this r1 r2 });
set([r1,r2],'Callback',{@mutuallyExclusive [r1 r2]});
set(f,'WindowStyle','modal','Visible','on');


function [icondata, iconmap] = getHelpIcon()
% Used for locating cr
load dialogicons.mat
icondata = helpIconData;
iconmap = helpIconMap;
