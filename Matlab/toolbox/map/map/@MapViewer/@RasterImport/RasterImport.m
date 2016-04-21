function h = RasterImport(viewer,type,varargin)
%RASTERIMPORT Import Raster Image from Workspace
%
%   Only variables that are 3x2 are valid reference matrices.  All numeric
%   variables in the matlab workspace are valid images.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:58 $

h = MapViewer.RasterImport(varargin{:},...
                           'NumberTitle','off',...
                           'Menubar','none',...
                           'Units','inches',...
                           'Resize','off',...
                           'Position',getWindowPosition(viewer,type),...
                           'HandleVisibility','off',...
                           'WindowStyle','modal');

set(h,'Name',sprintf('Import %c%s Data',upper(type(1)),lower(type(2:end))));

h.RasterType = type;
ax = axes('Parent',double(h),'Visible','off','Units','normalized','Position',[0 0 1 1]);

% Take inventory of variables in the base workspace
workspaceVars = evalin('base','whos');

if strcmp(lower(type),'image')
  imageImportDialog(h,ax,workspaceVars);
else %grid
  gridImportDialog(h,ax,workspaceVars);
end


% Buttons
numberOfButtons = 3;
buttonHeight = 0.08;
margins = 0.05;
spacing = 0.02;
buttonWidth = (1 - (2 * margins + 3 * spacing)) / 3;
lowerMargin = 0.04;

uicontrol('Parent',double(h),'Units','normalized','Style','push','String','OK',...
          'Position',[margins lowerMargin buttonWidth buttonHeight],...
          'Callback',{@doOKButton,h,viewer});

uicontrol('Parent',double(h),'Units','normalized','Style','push','String','Cancel',...
          'Position',[margins + buttonWidth + spacing lowerMargin buttonWidth buttonHeight],...
          'Callback',{@doCancelButton,h});

uicontrol('Parent',double(h),'Units','normalized','Style','push','String','Apply',...
          'Position',[margins + 2 * buttonWidth + 2 * spacing lowerMargin buttonWidth buttonHeight],...
          'Callback',{@doApplyButton,h,viewer});

% $$$ uicontrol('Parent',double(h),'Units','normalized','Style','push','String','Help',...
% $$$           'Position',[margins + 3 * buttonWidth + 3 * spacing lowerMargin buttonWidth buttonHeight],...
% $$$           'Callback',@doHelpButton);


function imageImportDialog(h,ax,workspaceVars)

% Dimensions of the listboxes
listWidth = 0.8;
listHeight = 0.15;
listX = (1 - listWidth) / 2;
figColor = get(h,'Color');

% Reference Matrix Interface
t = text('Parent',ax,'Units','normalized','Position',[0.5, 0.92 ,0],...
         'String','Referencing matrix name',...
         'HorizontalAlignment','center','Visible','on');
h.RefMatrixList = uicontrol('Parent',double(h),...
                            'Units','normalized',...
                            'Position',[listX 0.75 listWidth listHeight],...
                            'BackgroundColor','w',...
                            'Style','listbox','Tag','RefVarName');

refMatVars = getRefMatrixVariables(workspaceVars);
if ~any(strcmp('',{refMatVars.name}))
  set(h.RefMatrixList,'String',{refMatVars.name});
else
  set(h.RefMatrixList,'String',{''});
  set(h.RefMatrixList,'BackGroundColor',figColor);
end

% Image Data Interface
t = text('Parent',ax,'Units','normalized','Position',[0.5, 0.70, 0],...
         'String','Raster data name',...
         'HorizontalAlignment','center','Visible','on');
h.RasterMatrixList = uicontrol('Parent',double(h),...
                               'Units','normalized',...
                               'Position',[listX 0.53 listWidth listHeight],...
                               'Style','listbox','Tag','RasterVarName',...
                               'BackgroundColor','w',...
                               'Callback',{@setBandList h});

imageVars = getImageVariables(workspaceVars);
if ~any(strcmp('',{imageVars.name}))
  set(h.RasterMatrixList,'String',{imageVars.name});
else
  set(h.RasterMatrixList,'String',{''});
  set(h.RasterMatrixList,'BackgroundColor',figColor);
end

% Selection of RGB Bands

% Number of bands for first image.  Used to prime RGB popupmenus
if isempty(imageVars(1).name)
  str = {'Band 1'};
else
  n = getNumberOfBands(imageVars(1).name);
  for i=1:n
    str{i} = ['Band ' num2str(i)];
  end
end

y = 0.45;
spacing = 0.05;
t = text('Parent',ax,'Units','normalized','Position',[listX, y, 0],...
         'String','Red:','Color',[0.5 0 0]);
textExtent = get(t,'Extent');
h.RedBandList = uicontrol('Parent',double(h),'Units','normalized',...
                          'Position',[listX + 0.2, y - textExtent(4) / 2, 0.4, textExtent(4)],...
                          'Style','popupmenu','string',str,...
                          'BackgroundColor','w',...
                          'HorizontalAlignment','center');

y = y - 2 * textExtent(4);
t = text('Parent',ax,'Units','normalized','Position',[listX, y, 0],...
         'String','Green:','Color',[0 0.5 0]);
textExtent = get(t,'Extent');
h.GreenBandList = uicontrol('Parent',double(h),'Units','normalized',...
                            'Position',[listX + 0.2, y - textExtent(4) / 2, 0.4, textExtent(4)],...
                            'Style','popupmenu','string',str,...
                            'BackgroundColor','w',...
                            'HorizontalAlignment','center');

y = y - 2 * textExtent(4);
t = text('Parent',ax,'Units','normalized','Position',[listX, y, 0],...
         'String','Blue:','Color',[0 0 0.5]);
textExtent = get(t,'Extent');
h.BlueBandList = uicontrol('Parent',double(h),'Units','normalized',...
                           'Position',[listX + 0.2, y - textExtent(4) / 2, 0.4, textExtent(4)],...
                           'Style','popupmenu','string',str,...
                           'BackgroundColor','w',...
                           'HorizontalAlignment','center');

setBandList(h.RasterMatrixList,[],h);


function gridImportDialog(h,ax,workspaceVars)

% Dimensions of the listboxes
listWidth = 0.8;
listHeight = 0.175;
listX = (1 - listWidth) / 2;
figColor = get(h,'Color');

% X Geolocation Array Interface
t = text('Parent',ax,'Units','normalized','Position',[0.5, 0.925 ,0],...
         'String','X geolocation array name',... 
         'HorizontalAlignment','center','Visible','on');
h.XGeoArrayList = uicontrol('Parent',double(h),...
                            'Units','normalized',...
                            'Position',[listX 0.725 listWidth listHeight],...
                            'BackgroundColor','w',...
                            'Style','listbox','Tag','XGeoName');

xGeoVars = getXnYGeoArrayVariables(workspaceVars);
if ~any(strcmp('',{xGeoVars.name}))
  set(h.XGeoArrayList,'String',{xGeoVars.name});
else
  set(h.XGeoArrayList,'String',{''});
  set(h.XGeoArrayList,'BackgroundColor',figColor);
end

% Y Geolocation Array Interface
t = text('Parent',ax,'Units','normalized','Position',[0.5, 0.675 ,0],...
         'String','Y geolocation array name',...
         'HorizontalAlignment','center','Visible','on');
h.YGeoArrayList = uicontrol('Parent',double(h),...
                            'Units','normalized',...
                            'Position',[listX 0.475 listWidth listHeight],...
                            'BackgroundColor','w',...
                            'Style','listbox','Tag','YGeoName');

yGeoVars = getXnYGeoArrayVariables(workspaceVars);
if ~any(strcmp('',{yGeoVars.name}))
  set(h.YGeoArrayList,'String',{yGeoVars.name});
else
  set(h.YGeoArrayList,'String',{''});
  set(h.YGeoArrayList,'BackgroundColor',figColor);
end

% Data Grid Array Interface
t = text('Parent',ax,'Units','normalized','Position',[0.5, 0.425 ,0],...
         'String','Data grid array name',...
         'HorizontalAlignment','center','Visible','on');

h.DataGridArrayList = uicontrol('Parent',double(h),...
                                'Units','normalized',...
                                'Position',[listX 0.225 listWidth listHeight],...
                                'BackgroundColor','w',...
                                'Style','listbox','Tag','DataGridName');

dataGridVars = getDataGridArrayVariables(workspaceVars);
if ~any(strcmp('',{dataGridVars.name}))
  set(h.DataGridArrayList,'String',{dataGridVars.name});
else
  set(h.DataGridArrayList,'String',{''});
  set(h.DataGridArrayList,'BackgroundColor',figColor);
end

% Render Type Interface
% $$$ t = text('Parent',ax,'Units','normalized','Position',[0.5, 0.28, 0],...
% $$$          'String','Display type',...
% $$$          'HorizontalAlignment','center','Visible','on');
% $$$ 
% $$$ radioButtons(1) = uicontrol('Parent',double(h),'Units','Normalized',...
% $$$                    'Position',[0.15 0.18 0.3 0.05],...
% $$$                    'Style','radiobutton','String','Surf','HorizontalAlignment', ...
% $$$                    'center','Value',1);
h.DisplayType = 'surf';
% $$$ radioButtons(2) = uicontrol('Parent',double(h),'Units','Normalized',...
% $$$                    'Position',[0.55 0.18 0.3 0.05],...
% $$$                    'Style','radiobutton','String','Mesh','HorizontalAlignment', ...
% $$$                    'left', 'Enable','off');
% $$$ 
% $$$ radioButtons(3) = uicontrol('Parent',double(h),'Units','Normalized',...
% $$$                    'Position',[0.3 0.14 0.4 0.05],...
% $$$                    'Style','radiobutton','String','Contour','HorizontalAlignment', ...
% $$$                    'left');

%set(radioButtons,'callback',{@makeMutuallyExclusive h radioButtons});

%--------------------Button Callbacks--------------------%

function doApplyButton(hSrc,event,this,viewer)
if (strcmp(lower(this.RasterType),'image'))
  status = addLayerFromWS_Image(this,viewer);
else
  status = addLayerFromWS_Grid(this,viewer);
end

function doOKButton(hSrc,event,this,viewer)
if (strcmp(lower(this.RasterType),'image'))
  status = addLayerFromWS_Image(this,viewer);
else
  status = addLayerFromWS_Grid(this,viewer);
end

if ~status
  delete(this);
end

function doCancelButton(hSrc,event,this)
delete(this);

function doHelpButton(hSrc,event)

function status = addLayerFromWS_Image(this,viewer)
SUCCESS = 0;
FAIL = 1;
status = SUCCESS;
% Reference Matrix
refVarNames = get(this.RefMatrixList,'String');
if iscell(refVarNames)
  refName = refVarNames{get(this.RefMatrixList,'Value')};
else
  refName = refVarNames
end
if isempty(refName)
  errordlg('The reference matrix must be a 3-by-2 numeric matrix.','Import Error','modal');
  status = FAIL;
  return;
else
  R = evalin('base',refName);
end

rasterVarNames = get(this.RasterMatrixList,'String');
if iscell(rasterVarNames)
  rasterName = rasterVarNames{get(this.RasterMatrixList,'Value')};
else
  rasterName = rasterVarNames;
end
if isempty(rasterName)
  errordlg('You must select the raster data.','Import Error','modal');
  status = FAIL;
  return;
end
r = get(this.RedBandList,'Value');
g = get(this.GreenBandList,'Value');
b = get(this.BlueBandList,'Value');
I = evalin('base',[rasterName '(:,:,[' num2str(r) ',' num2str(g) ',' num2str(b) '])']);

% Perform some additional error checking
if ~isnumeric(R) 
  errordlg('The reference matrix must be a 3-by-2 numeric matrix.','Import Error','modal');
  status = FAIL;
  return
elseif ~isnumeric(I)
  errordlg('The reference matrix must be numeric.','Import Error','modal');  
  status = FAIL;
  return  
end

% Create and Add New Layer
try
  viewer.setCursor('wait');
  this.Pointer = 'watch';
  layer = createRGBLayer(viewer,R,I,rasterName);      
  viewer.addLayer(layer);
  viewer.setCursor('restore');
  this.Pointer = 'arrow';
catch
  errordlg(lasterr,'Import Error','modal');
  viewer.setCursor('restore');
  this.Pointer = 'arrow';
  status = FAIL;
end

function status = addLayerFromWS_Grid(this,viewer)
SUCCESS = 0;
FAIL = 1;
status = SUCCESS;

% X Geolocation Array
xGeoVarNames = get(this.XGeoArrayList,'String');
if iscell(xGeoVarNames)
  xGeoName = xGeoVarNames{get(this.XGeoArrayList,'Value')};
else
  xGeoName = xGeoVarNames;
end

if isempty(xGeoName)
  errordlg('The X geolocation array must vector.','Import Error','modal');
  status = FAIL;
  return;
else
  X = evalin('base',xGeoName);
end

% Y Geolocation Array
yGeoVarNames = get(this.YGeoArrayList,'String');
if iscell(yGeoVarNames)
  yGeoName = yGeoVarNames{get(this.YGeoArrayList,'Value')};
else
  yGeoName = yGeoVarNames;
end

if isempty(yGeoName)
  errordlg('The Y geolocation array must vector.','Import Error','modal');
  status = FAIL;
  return;
else
  Y = evalin('base',yGeoName);
end

% Data Grid Array
dataGridVarNames = get(this.DataGridArrayList,'String');
if iscell(yGeoVarNames)
  dataGridName = dataGridVarNames{get(this.DataGridArrayList,'Value')};
else
  dataGridName = dataGridVarNames;
end

if isempty(dataGridName)
  errordlg('The Data Grid Array must be a M-by-N matrix.','Import Error','modal');
  status = FAIL;
  return;
else
  Z = evalin('base',dataGridName);
end

% Perform some additional error checking
sizeX = size(X);
sizeY = size(Y);
sizeZ = size(Z);
if ~isnumeric(X) || ~isnumeric(Y) || ~isnumeric(Z)
    errordlg('The X, Y geolocation array and Data Grid Array must be numeric.','Import Error','modal');
  status = FAIL;
  return
elseif any(sizeX==1) ~= any(sizeY==1)
  errordlg(sprintf(['The X and Y geolocation array must be M-by-N matrices of the \n',...
                    'size or vectors']),'Import Error','modal');
  status = FAIL;
  return  
elseif (all(sizeX~=1) && all(sizeY~=1))
  if ~isequal(sizeX,sizeY,sizeZ)
    errordlg(sprintf(['For X and Y geolocation array matrices, the sizes ' ...
                      '\nmust be equal to the Data Grid Array.']),['Import ' ...
                        'Error'],'modal');
    status = FAIL;
    return 
  end
end

rasterName = dataGridName;

% Create and Add New Layer
null = 0;
try
  viewer.setCursor('wait');
  this.Pointer = 'watch';
  layer = createGridLayer(null,X,Y,Z,rasterName,this.DisplayType);      
  viewer.addLayer(layer);
  viewer.setCursor('restore');
  this.Pointer = 'arrow';
catch
  errordlg(lasterr,'Import Error','modal');
  viewer.setCursor('restore');
  this.Pointer = 'arrow';
  status = FAIL;
end

function newLayer = createRGBLayer(map,R,I,name)
newLayer = MapModel.RasterLayer(name);
newComponent = MapModel.RGBComponent(R,I,struct([]));
newLayer.addComponent(newComponent);

function newLayer = createGridLayer(map,X,Y,Z,name,dispType)
newLayer = MapModel.RasterLayer(name);
newComponent = MapModel.GriddedComponent(X,Y,Z,dispType);
newLayer.addComponent(newComponent);

%--------------------Listbox Callbacks--------------------%

function setBandList(hSrc,event,this)
v = get(hSrc,'value');
strs = get(hSrc,'String');

if isempty(strs{1})
  n = 0;
  str = {'Band 1'};
else
  n = getNumberOfBands(strs{v});
  for i=1:n
    str{i} = ['Band ' num2str(i)];
  end
end

if n>=3
  set(this.RedBandList,'Value',1,'String',str);
  set(this.GreenBandList,'Value',2,'String',str);
  set(this.BlueBandList,'Value',3,'String',str);
else
  set(this.RedBandList,'Value',1,'String',str);
  set(this.GreenBandList,'Value',1,'String',str);
  set(this.BlueBandList,'Value',1,'String',str);
end

function n = getNumberOfBands(varname)
variable = evalin('base',['whos(''' varname ''');']);
if length(variable.size) > 2
  n = variable.size(3);
else
  n = 1;
end

%--------------------Helper Functions--------------------%

function vars = getRefMatrixVariables(workspaceVars)
vars = struct('name','','size',[],'bytes',[],'class','');
j = 1;
% Reference Matrix variables must be 3-by-2
for i=1:length(workspaceVars)
  if (length(workspaceVars(i).size) == 2) && ...
        all(workspaceVars(i).size == [3 2])
    vars(j) = workspaceVars(i);
    j = j + 1;
  end
end

function vars = getImageVariables(workspaceVars)
vars = struct('name','','size',[],'bytes',[],'class','');
numericClasses = {'double','single','uint8','int8','uint16','int16',...
                 'uint32','int32','uint64','int64','logical'};
j = 1;
for i = 1:length(workspaceVars)
  if strmatch(workspaceVars(i).class,numericClasses,'exact')
    vars(j) = workspaceVars(i);
    j = j + 1;
  end
end


function vars = getXnYGeoArrayVariables(workspaceVars)
vars = struct('name','','size',[],'bytes',[],'class','');

%j = 1;
for i=1:length(workspaceVars)
%  if (any(workspaceVars(i).size == 1))
    vars(i) = workspaceVars(i);
%    vars(j) = workspaceVars(i);
%    j = j + 1;
%  end
end


function vars = getDataGridArrayVariables(workspaceVars)
vars = struct('name','','size',[],'bytes',[],'class','');

j = 1;
for i = 1:length(workspaceVars)
  if (~any(workspaceVars(i).size == 1))
    vars(j) = workspaceVars(i);
    j = j + 1;
  end
end


function pos = getWindowPosition(viewer,type)
pos = viewer.getPosition('inches');

w = 2.5;
x = pos(1) + pos(3)/2 - 2.8/2;
if strcmp(lower(type),'image')
  h = 4;
else 
  h = 3.75;
end
y = pos(2) + pos(4)/2 - h/2;
pos = [x,y,w,h];

function makeMutuallyExclusive(hSrc, event, this, objArray)
dispType = {'surf','mesh','contour'};
ind = (hSrc == objArray);
set(objArray(~ind),'Value',0);
set(hSrc,'Value',1);
this.DisplayType = dispType{ind};
