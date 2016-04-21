function this = ZoomOutState(viewer,mode)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/03/24 20:41:09 $

this = MapViewer.ZoomOutState;

this.MapViewer = viewer;

if ~isempty(findstr(version,'R14'))
  iconroot = [matlabroot '/toolbox/map/icons/'];
else
  % For R13 the toolbox/map/icons directory must be on the path.
  iconroot = '';
end

icon = double(imread([iconroot 'view_zoom_out_cursor.bmp']));
icon(icon==255) = NaN; % NaN = transparent
icon(icon==0) = 1; % 1 = Black


KEY = 'matlab_graphics_resetplotview';
viewInfo = getappdata(this.MapViewer.Axis,KEY);
if (isempty(viewInfo))
   setappdata(this.MapViewer.Axis,KEY,viewInfo);
end

WindowButtonMotionFcn = get(viewer.Figure,'WindowButtonMotionFcn');
zoom(double(viewer.Figure),'outmode');
set(viewer.Figure,'WindowButtonMotionFcn',WindowButtonMotionFcn, ...
                  'Pointer','custom','PointerShapeCData',icon);


  
