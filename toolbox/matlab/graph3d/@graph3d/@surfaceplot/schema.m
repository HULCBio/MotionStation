function schema

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision $  $Date: 2004/04/06 21:53:02 $

pkg = findpackage('graph3d');
hgpkg = findpackage('hg');
hBaseClass = findclass(hgpkg,'surface');

% define class
hClass = schema.class(pkg,'surfaceplot',hBaseClass);

%init lists of properties for various listeners
l = [];

% DisplayName
hProp = schema.prop(hClass, 'DisplayName', 'string');
hProp.Description = 'Name used for displays and legends';

% XData,YData,CData listeners
hProp = [findprop(hBaseClass,'XData'), ...
         findprop(hBaseClass,'YData'), ...
         findprop(hBaseClass,'CData')];

% Use of hBaseClass required
l = Lappend(l,handle.listener(hBaseClass,hProp, 'PropertyPostSet',...
                              @LsetXYCData));
% XDataMode
hProp = schema.prop(hClass,'XDataMode','axesXLimModeType');
hProp.FactoryValue = 'Auto';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
  @LsetXYCDataMode));

% XDataSource
hProp = schema.prop(hClass,'XDataSource','string');
hProp.Description = 'Independent variable source';
hProp.AccessFlags.Serialize = 'off';

% YDataMode
hProp = schema.prop(hClass,'YDataMode','axesXLimModeType');
hProp.FactoryValue = 'Auto';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
  @LsetXYCDataMode));

% YDataSource
hProp = schema.prop(hClass,'YDataSource','string');
hProp.Description = 'Independent variable source';
hProp.AccessFlags.Serialize = 'off';

% CDataMode
hProp = schema.prop(hClass,'CDataMode','axesXLimModeType');
hProp.FactoryValue = 'Auto';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
  @LsetXYCDataMode));

% CDataSource
hProp = schema.prop(hClass,'CDataSource','string');
hProp.Description = 'Independent variable source';
hProp.AccessFlags.Serialize = 'off';

% ZData
hProp = findprop(hBaseClass,'ZData');
% Use of hBaseClass required
l = Lappend(l,handle.listener(hBaseClass,hProp,'PropertyPreSet',...
                              @LsetZData));

% ZData Source
hProp = schema.prop(hClass,'ZDataSource','string');
hProp.Description = 'Independent variable source';
hProp.AccessFlags.Serialize = 'off';

% Misc.
hProp = schema.prop(hClass, 'Initialized', 'double');
hProp.FactoryValue = false;
hProp.Visible = 'off';
hProp.AccessFlags.Serialize = 'off';

LSetListeners(hClass,l);

%--------------------------------------------------------%
function LSetListeners(hClass,l)
%set(hClass,'ClassListeners',l);
setappdata(0,'Graph3DSurfacePlotListeners',l);

%--------------------------------------------------------%
function [l] = LGetListeners(hClass)
l = getappdata(0,'Graph3DSurfacePlotListeners');
%l = get(hClass,'ClassListeners');

%--------------------------------------------------------%
function out = Lappend(in,data)
if isempty(in)
  out = data;
else
  out = [in data];
end

%--------------------------------------------------------%
function LsetXDataSilently(h,zdata)

%disp LsetXDataSilently

% turn off xdatamode listener before setting xdata
l = LGetListeners(h.classhandle);
set(l,'enable','off');
set(h,'XData',1:size(zdata,2));
set(l,'enable','on');

%--------------------------------------------------------%
function LsetYDataSilently(h,zdata)

%disp LsetYDataSilently

% turn off ydatamode listener before setting xdata
l = LGetListeners(h.classhandle);
set(l,'enable','off');
set(h,'YData',(1:size(zdata,1))');
set(l,'enable','on');

%--------------------------------------------------------%
function LsetCDataSilently(h,zdata)

%disp LsetCDataSilently

% turn off xdatamode listener before setting xdata
l = LGetListeners(h.classhandle);
set(l,'enable','off');
set(h,'CData',zdata);
set(l,'enable','on');

%--------------------------------------------------------%
function LsetZData(hSrc, eventData)

%disp LsetZData

h = handle(eventData.affectedObject);

% A UDD Bug will fire this callback before defining 
% a class. Bail out early if this class is not defined yet.
% Use ISA
if ~isprop(handle(h),'Initialized')
   return;
end

% User set ZData property, update XData,YData,CData if in auto-mode
if get(h,'Initialized')
  if strcmp(h.xdatamode,'auto') 
     LsetXDataSilently(h,eventData.newvalue);
  end
  if strcmp(h.ydatamode,'auto') 
     LsetYDataSilently(h,eventData.newvalue);
  end
  if strcmp(h.cdatamode,'auto') 
     LsetCDataSilently(h,eventData.newvalue);
  end
end

%--------------------------------------------------------%
function LsetXYCData(hSrc, eventData)

h = eventData.affectedObject;

% A UDD Bug will fire this callback before defining 
% a class. Bail out early if this class is not defined yet.
if ~isprop(handle(h),'Initialized')
   return;
end

% User is setting {X,Y}Data property, set corresponding 
% DataMode property to be manual
prop = hSrc.name;
set(h,[prop 'Mode'],'manual');

%--------------------------------------------------------%
function LsetXYCDataMode(hSrc, eventData)

%disp LsetXYCDataMode

h = eventData.affectedObject;
modeprop = hSrc.name;

if strcmp(get(h,modeprop),'auto') && get(h,'Initialized')
  switch lower(modeprop)
     case 'xdatamode'
        LsetXDataSilently(h,h.zdata);
     case 'ydatamode'
        LsetYDataSilently(h,h.zdata);
     case 'cdatamode'
        LsetCDataSilently(h,h.zdata);
  end
end






