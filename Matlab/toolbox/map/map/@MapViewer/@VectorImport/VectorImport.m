function h = VectorImport(viewer,type)
%VECTORIMPORT Import Vector Image from Workspace

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:19 $

h = MapViewer.VectorImport('NumberTitle','off',...
                           'Name','Import Vector Data',...
                           'Menubar','none',...
                           'Units','inches',...
                           'Resize','off',...
                           'Position',getWindowPosition(viewer,type),...
                           'HandleVisibility','off',...
                           'WindowStyle','modal');

backgroundColor = get(h,'Color');
disableColor = [0.7 0.7 0.7];

ax = axes('Parent',double(h),'Visible','off',...
          'XLimMode','manual','XLim',[0 1],...
          'YLimMode','manual','YLim',[0 1],...
          'Units','normalized','Position',[0 0 1 1]);

% Take inventory of variables in the base workspace
workspaceVars = evalin('base','whos');


margin = 18;
spacing = 3;
textHeight = 16;
if strcmp(lower(type),'cartesian') || strcmp(lower(type),'latlon')
  textPosition = [margin, 175, 200 textHeight];
else
  textPosition = [margin, 100, 200 textHeight];
end


% Buttons
numberOfButtons = 3;
buttonHeight = 0.08;
margins = 0.05;
spacing = 0.02;
buttonWidth = (1 - (2 * margins + 3 * spacing)) / 3;
lowerMargin = 0.04;

if strcmp(lower(type),'cartesian') || strcmp(lower(type),'latlon')
  cartesianImportDialog(h,ax,workspaceVars);
else 
  geoStructImportDialog(h,ax,workspaceVars);
  numberOfButtons = 3*2;
  buttonHeight = 0.08*2;
  lowerMargin = 0.04*2;

end



uicontrol('Parent',double(h),'Units','normalized','Style','push','String','OK',...
          'Position',[margins lowerMargin buttonWidth buttonHeight],...
          'Callback',{@doOKButton,h,viewer,type});

uicontrol('Parent',double(h),'Units','normalized','Style','push','String','Cancel',...
          'Position',[margins + buttonWidth + spacing lowerMargin buttonWidth buttonHeight],...
          'Callback',{@doCancelButton,h});

uicontrol('Parent',double(h),'Units','normalized','Style','push','String','Apply',...
          'Position',[margins + 2 * buttonWidth + 2 * spacing lowerMargin buttonWidth buttonHeight],...
          'Callback',{@doApplyButton,h,viewer,type});

% $$$ uicontrol('Parent',double(h),'Units','normalized','Style','push','String','Help',...
% $$$           'Position',[margins + 3 * buttonWidth + 3 * spacing lowerMargin buttonWidth buttonHeight],...
% $$$           'Callback',@doHelpButton);


function cartesianImportDialog(h,ax,workspaceVars)
% Convention for storing text/edit box pairs
%
% The text/edit box pairs of uicontrols are stored in a cell array and
% each assigned to one property of the class.  The text uicontrol is the
% first element of the cell array and the edit box is the second element.
% For example, the uicontrol for the text of X is stored in h.X{1} and the
% editable text uicontrol for X is stored in h.X{2}.

% Dimensions of the listboxes
listWidth = 0.8;
listHeight = 0.15;
listX = (1 - listWidth) / 2;
figColor = get(h,'Color');

% X
h.X{1} = text('Parent',ax,'Units','normalized','Position',[0.5, 0.92 ,0],...
              'String','X',...
              'HorizontalAlignment','center','Visible','on');
h.X{2} = uicontrol('Parent',double(h),...
                   'Units','normalized',...
                   'Position',[listX 0.75 listWidth listHeight],...
                   'BackgroundColor','w',...
                   'Style','listbox','Tag','xVarName');

vecVars = getVecVariables(workspaceVars);
if ~any(strcmp('',{vecVars.name}))
  set(h.X{2},'String',{vecVars.name});
else
  set(h.X{2},'String',{''});
  set(h.X{2},'BackGroundColor',figColor);
end

% Y 
h.Y{1} = text('Parent',ax,'Units','normalized','Position',[0.5, 0.70, 0],...
              'String','Y',...
              'HorizontalAlignment','center','Visible','on');
h.Y{2} = uicontrol('Parent',double(h),...
                   'Units','normalized',...
                   'Position',[listX 0.53 listWidth listHeight],...
                   'Style','listbox','Tag','yVarName',...
                   'BackgroundColor','w');

vecVars = getVecVariables(workspaceVars);
if ~any(strcmp('',{vecVars.name}))
  set(h.Y{2},'String',{vecVars.name});
else
  set(h.Y{2},'String',{''});
  set(h.Y{2},'BackgroundColor',figColor);
end

% Geometry
t =  text('Parent',ax,'Units','normalized','Position',[0.5, 0.475, 0],...
              'String','Geometry',...
              'HorizontalAlignment','center','Visible','on');

h.VectorTopologyText = t;

radioWidth = 0.4;
radioX = listX + 0.2;
y = 0.4;
textExtent = get(t,'Extent');
radioPosition = [radioX, y - textExtent(4) / 2, 0.4, textExtent(4)];
pointButton = uicontrol('Parent',double(h),...
                        'Units','normalized',...
                        'Position',radioPosition,...
                        'Style','radiobutton','Tag','point',...
                        'BackgroundColor',figColor,...
                        'Enable','on',...
                        'String','Point','HorizontalAlignment','center');

y = y - 2 * textExtent(4);
radioPosition = [radioX, y - textExtent(4) / 2, 0.4, textExtent(4)];

lineButton = uicontrol('Parent',double(h),...
                       'Units','normalized',...
                       'Position',radioPosition,...
                       'Style','radiobutton','Tag','point',...
                       'BackgroundColor',figColor,...
                       'Enable','on',...
                       'String','Line','HorizontalAlignment','center');

y = y - 2 * textExtent(4);
radioPosition = [radioX, y - textExtent(4) / 2, 0.4, textExtent(4)];

polygonButton = uicontrol('Parent',double(h),...
                          'Units','normalized',...
                          'Position',radioPosition,...
                          'Style','radiobutton','Tag','point',...
                          'BackgroundColor',figColor,...
                          'Enable','on',...
                          'String','Polygon','HorizontalAlignment','center');

set([pointButton,polygonButton,lineButton],...
    'Callback',{@mutuallyExclusive, [pointButton, polygonButton, lineButton]});

h.Topology = [pointButton,polygonButton,lineButton];

function geoStructImportDialog(h,ax,workspaceVars)
% Vector Shape Structure

% This should be the same for unix and windows.  Why would points be
% different sizes?
%if isunix
%  textPosition = [margin, radioPosition(2) - radioHeight - 24, 120 16];
%else
%  textPosition = [margin, radioPosition(2) - radioHeight - 24 - 13, 120 16];
%end

% Dimensions of the listboxes
listWidth = 0.9;
listHeight = 0.4 ;
listX = (1 - listWidth) / 2;
figColor = get(h,'Color');

% Geo Data Structure
h.ShapeStruct{1} = text('Parent',ax,'Units','normalized','Position',[0.5, 0.82 ,0],...
                        'String','Geographic Data Structure',...
                        'HorizontalAlignment','center','Visible','on');

h.ShapeStruct{2} = uicontrol('Parent',double(h),...
                             'Units','normalized',...
                             'Position',[listX 0.375 listWidth listHeight],...
                             'BackgroundColor','w',...
                             'Style','listbox','Tag','RefVarName');


geoStructVars = getGeoStructVariables(workspaceVars);
if ~any(strcmp('',{geoStructVars.name}))
  set(h.ShapeStruct{2},'String',{geoStructVars.name});
else
  set(h.ShapeStruct{2},'String',{''});
  set(h.ShapeStruct{2},'BackGroundColor',figColor);
end

function mutuallyExclusive(hSrc,event,handles)
set(handles(handles ~= hSrc),'Value',0);

function doOKButton(hSrc,event,this,viewer,type)
v = doImport(this,viewer,type);
if v == false;
  this.close;
end

function doApplyButton(hSrc,event,this,viewer,type)
doImport(this,viewer,type);

function doCancelButton(hSrc,event,this)
this.close;

function localSetCartesian(hSrc,event,this,disable)
this.setCartesian;
set(disable,'Value',0);

function localSetLatLon(hSrc,event,this,disable)
this.setLatLon;
set(disable,'Value',0);

function localSetShapeStruct(hSrc,event,this,disable)
this.setShapeStruct;
set(disable,'Value',0);

function type = getShapeType(this)
values = get(this.Topology,'Value');
idx = find([values{:}] == 1);
if isempty(idx)
  type = '';
else
  switch lower(get(this.Topology(idx),'String'))
   case 'polygon'
    type = 'Polygon';
   case 'line'
    type = 'Line';
   case {'point','multipoint'}
    type = 'Point';
   otherwise 
    type = ''
  end
end

function failed = doImport(this,viewer,type)
failed = false;
switch type
 case 'cartesian'
  shapeData.Geometry = getShapeType(this);
  if isempty(shapeData.Geometry)
    this.error({'You must select a','Vector Topology.'});
    failed = true;
    return;
  end
  xstr = get(this.X{2},'String');
  xInd = get(this.X{2},'Value');
  ystr = get(this.Y{2},'String');
  yInd = get(this.Y{2},'Value');
  
  xstr = xstr{xInd};
  ystr = ystr{yInd};
  layername = [xstr '/' ystr];
  if isempty(xstr) | isempty(ystr)
    this.error({'X and Y must be names of 1-by-N or N-by-1',...
                'vectors in the base workspace.'});
    failed = true;
    return
  end
  try
    shapeData.X = evalin('base',xstr);
    shapeData.Y = evalin('base',ystr);
    shapeData.BoundingBox = [min(shapeData.X), min(shapeData.Y);...
                        max(shapeData.X), max(shapeData.Y)];
  catch
    this.error({'X and Y must be names of 1-by-N or N-by-1',...
                'vectors in the base workspace.'});
    failed = true;
    return;
  end
case 'latlon'
  shapeData.Geometry= getShapeType(this);
  if isempty(shapeData.Geometry)
    this.error({'You must select a','Vector Topology.'});
    failed = true;
    return;
  end
  latstr = get(this.Lat{2},'String')
  lonstr = get(this.Lon{2},'String')
  layername = [latstr '/' lonstr];
  if isempty(latstr) | isempty(lonstr)
    this.error({'Lat and Lon must be names of 1-by-N or N-by-1',...
                'vectors in the base workspace.'});
    failed = true;
    return;
  end
  try
    shapeData.X = evalin('base',latstr);
    shapeData.Y = evalin('base',lonstr);
    shapeData.BoundingBox = [min([shapeData.X, shapeData.Y]);...
                        max([shapeData.X, shapeData.Y])];
  catch
      this.error({'Lat and Lon must be names of 1-by-N or N-by-1',...
                  'vectors in the base workspace.'});
      failed = true;
      return;
  end
 case 'struct'
  shapestr = get(this.ShapeStruct{2},'String');
  ind = get(this.ShapeStruct{2},'Value');
  layername = shapestr{ind};
  if isempty(shapestr{ind})
    this.error({'Vector Shape Structure must be a structure',...
                'in the base workspace.'});
    failed = true;
    return;
  end
  try
    shapeData = evalin('base',shapestr{ind});
  catch
    this.error({'Vector Shape Structure must be a structure',...
                'in the base workspace.'});
    failed = true;
    return;
  end
end
try
  [shapeData, spec] = updategeostruct(shapeData);

  % Project the data if needed
  if isfield(shapeData,'Lat') && isfield(shapeData,'Lon')
    %shape = projectGeoStruct(ax, shape);
    [shapeData.X] = deal(shapeData.Lon);
    [shapeData.Y] = deal(shapeData.Lat);
  end

  [layer,tmp] = mapgate('createVectorLayer',shapeData,layername);
  if isstruct(spec)
     layerlegend = layer.legend;
     layerlegend.override(rmfield(spec,'ShapeType'));
  end

catch
  this.error('Invalid Geographic Data Structure');
  %this.error(lasterror.message);
  failed = true;
  return;
end

try
  viewer.setCursor('wait');
  this.Pointer = 'watch';
  viewer.addLayer(layer);
  viewer.setCursor('restore');
  this.Pointer = 'arrow';
catch
  viewer.setCursor('restore');
  this.Pointer = 'arrow';
  this.error(['A layer named ' layername ' already exists.']);
  failed = true;
end

%----------------------------------------------------------------------%
function p = getWindowPosition(viewer,type)
p = viewer.getPosition('inches');

w = 2.5;
x = p(1) + p(3)/2 - 2.8/2;
if strcmp(lower(type),'cartesian') || strcmp(lower(type),'latlon')
  h = 3.75;
else
  h = 2;
end
y = p(2) + p(4)/2 - h/2;
p = [x,y,w,h];

%----------------------------------------------------------------------%
function attrStruct = getShapeAttributeStruct(shapeData)
attrStruct = mapgate('geoattribstruct',shapeData);

function vars = getVecVariables(workspaceVars)
vars = struct('name','','size',[],'bytes',[],'class','');
j = 1;
for i = 1:length(workspaceVars)
  if (any(workspaceVars(i).size ==1))
    vars(j) = workspaceVars(i);
    j = j + 1;
  end
end

function vars = getGeoStructVariables(workspaceVars)
vars = struct('name','','size',[],'bytes',[],'class','');
j = 1;
for i = 1:length(workspaceVars)
  if strcmp(workspaceVars(i).class,'struct')
    vars(j) = workspaceVars(i);
    j = j + 1;
  end
end
