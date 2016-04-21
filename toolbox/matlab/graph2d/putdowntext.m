function varargout = putdowntext(varargin)
%PUTDOWNTEXT  Plot Editor helper function
%
%   See also PLOTEDIT
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.50.6.5 $  $Date: 2004/04/10 23:26:32 $

if ischar(varargin{1})
   fig = gcbf;
   if isempty(fig) | ~ishandle(fig), return, end   
   action = varargin{1};
   toolButton = getappdata(fig,'ScribeCurrentToolButton');

   if nargin>1
      if ~isempty(toolButton)  % aborting one operation and starting another
         if ishandle(toolButton) ...
            & strcmp(get(toolButton,'Type'),'uitoggletool') ...
            & toolButton ~= gcbo  % not the same button
            set(toolButton,'State','off');
         else
            toolButton = [];
         end
      end
      toolButton = varargin{2};
   end
else
   fig = varargin{1}(1);
   if isempty(fig) | ~ishandle(fig), return, end
   action = varargin{2};
   toolButton = getappdata(fig,'ScribeCurrentToolButton');
end

if isempty(fig) | ~ishandle(fig), return, end
setappdata(fig,'ScribeCurrentToolButton',toolButton);

% black by factory default.  Can be changed by the user
defaultAnnotationColor = get(fig,'DefaultTextColor');

stateData = getappdata(fig,'ScribeAddAnnotationStateData');
if isempty(stateData)
   stateData = LInitStateData(fig);
   setappdata(fig,'ScribeAddAnnotationStateData', stateData);
end


switch action

case 'select'
   switch get(toolButton,'State')
   case 'off'
      plotedit(fig,'off');         
   case 'on'
      plotedit(fig,'on');
   end
      
case 'start'
   varargout{1} = 1;
   
   LSetSelect(fig,'off');  % plotedit off first
   
   LMaskAll(fig,'off');    % this saves windowXXXFcn settings
   set(toolButton,'State','on');      

   set(fig,'Pointer',stateData.oldPointer);
   if ~isempty(stateData.myline) & ishandle(stateData.myline)
      delete(stateData.myline);
   end
   stateData = LInitStateData(fig);
   setappdata(fig,'ScribeAddAnnotationStateData', stateData);

case 'axesstart'
   if putdowntext('start')
      set(fig,'Pointer','crosshair',...
              'WindowButtonDownFcn','putdowntext hitaxes');
   end
case 'hitaxes'
   rect = rbbox;  % returns a rectangle in figure units
   units = get(fig,'Units');
   if rect(3:4)>[0 0]
       %jpropeditutils('jundo','start',fig);
       
       newAx = axes('Parent',fig,...
           'Units',units,...
           'Position',rect);
       set(newAx,'Units','normalized');
       axH = scribehandle(axisobj(newAx));
       %set(axH,'Draggable',1);

       %jpropeditutils('jundo','stop',fig);
   end
   putdowntext reset;
   % end add with plotedit on always
   LSetSelect(fig,'on'); % do this last

case 'textstart'
   if putdowntext('start')
      set(fig,'Pointer','ibeam',...
              'WindowButtonDownFcn','putdowntext hittext')   
   end
case 'hittext'
   set(fig,'WindowButtonDownFcn','')   
   
   ax = LGetOverlayAxis(fig);
   if isempty(ax), return, end
   
   set(fig,'CurrentObject',ax);
   
   pt = get(ax,'CurrentPoint');
   
   %Register a new undo transaction
   %jpropeditutils('jundo','start',fig);
   
   th = newtext(pt(1,1),pt(1,2),' ','Parent',ax);
   
   %complete an undo transaction
   %jpropeditutils('jundo','stop',fig);
   
   
   
   putdowntext reset;
   % end add with plotedit on always
   LSetSelect(fig,'on'); % do this last
   
   if ~isempty(th)
	   propedit(th.HGHandle,'-noopen');
   end
   

case 'arrowstart'
   if putdowntext('start')
      stateData.isarrow = 1;
      setappdata(fig,'ScribeAddAnnotationStateData', stateData);   
      set(fig,'Pointer','crosshair',...
              'WindowButtonDownFcn','putdowntext linego');
   end
case 'linestart'
   if putdowntext('start')
      set(fig,'Pointer','crosshair',...
              'WindowButtonDownFcn','putdowntext linego');
   end
case 'linego'
    %Register a new undo transaction
    %jpropeditutils('jundo','start',fig);
    
   oldUnits = get(fig,'Units');
   set(fig,'WindowButtonDownFcn','',...
           'Units','pixels');

   stateData.figPt = get(fig,'CurrentPoint');
   set(fig,'Units',oldUnits);
   
   ax = LGetOverlayAxis(fig);
   set(fig,'CurrentObject',ax);

   pt = get(ax,'CurrentPoint');
   stateData.x = pt(1);
   stateData.y = pt(3);

   stateData.myline = line(stateData.x,stateData.y,'EraseMode','xor',...
           'Parent',ax,...
           'Color',defaultAnnotationColor,...
           'CreateFcn','');

   set(fig,...
       'WindowButtonMotionFcn','putdowntext linedrag',...
       'WindowButtonUpFcn','putdowntext linepoint1');
   setappdata(fig,'ScribeAddAnnotationStateData', stateData);

case 'linepoint1' 
   xUp = get(stateData.myline,'XData');
   yUp = get(stateData.myline,'YData');
   if length(xUp)==1 & length(yUp)==1 % clicked once without dragging
      % continue
      set(fig,'WindowButtonDownFcn','putdowntext reset',...
              'WindowButtonUpFcn','',...
              'WindowButtonMotionFcn','putdowntext linepoint2');
   else % end dragging
      putdowntext lineend;
   end

case 'linepoint2'
   ax = LGetOverlayAxis(fig);   
   set(fig,'CurrentObject',ax);
   
   set(fig,'WindowButtonMotionFcn','putdowntext linedrag',...
           'WindowButtonDownFcn','putdowntext lineend');   
   
case 'linedrag'
   ax = LGetOverlayAxis(fig);
   pt = get(ax,'CurrentPoint');
   set(stateData.myline,'XData', [stateData.x pt(1)], 'YData', [stateData.y pt(3)]);

case 'lineend'
   ax = LGetOverlayAxis(fig);   
   set(fig,'CurrentObject',ax);

   lineobj=[];
   
   oldUnits = get(fig,'Units');
   set(fig,'Units','pixels');
   pt = get(fig,'CurrentPoint');
   set(fig,'Units',oldUnits);
   % minimum size: 5 pixel
   if sum(abs(pt-stateData.figPt).^2)>=25
      
      if stateData.isarrow
         % we really have a line
         % redundant check
         x = get(stateData.myline,'XData');
         y = get(stateData.myline,'YData');
         if length(x)>1 & length(y)>1
            % at least two points
            ax = LGetOverlayAxis(fig);
            lineobj = scribehandle(arrowline(x,y,...
                    'Color',defaultAnnotationColor,...
                    'Parent',ax));
         end
         delete(stateData.myline);
         stateData.myline = [];
      else
         lineobj = scribehandle(editline(stateData.myline));
         stateData.myline = [];
      end % if stateData.isarrow
      
      if ~isempty(lineobj)
         set(lineobj,'EraseMode','normal');
         %set(lineobj,'IsSelected',1); take care of selection in the property editor  
         set(lineobj,'DragConstraint','');
      end

   end % if sum(

   setappdata(fig,'ScribeAddAnnotationStateData',stateData);
   putdowntext reset;
   % end add with plotedit on always
   LSetSelect(fig,'on'); % do this last
   
   %complete an undo transaction
   %jpropeditutils('jundo','stop',fig);
   
   if ~isempty(lineobj)
       propedit(lineobj.HGHandle,'-noopen'); %select but do not force open
      %HG = get(lineobj,'MyHGHandle');
      %set(fig,'CurrentObject',HG);
      %setappdata(fig,'ScribeHGCurrentObject',HG);
   end
   
case 'reset'
   
   try
      if ~isempty(stateData.myline) & ishandle(stateData.myline)
         delete(stateData.myline);
         stateData.myline = [];      
      end
      
      if ishandle(fig)
         % set(fig,'Pointer',stateData.oldPointer,...
         %         'WindowButtonDownFcn','',...
         %         'WindowButtonMotionFcn','',...
         %         'WindowButtonUpFcn','');
      
         if ~isempty(toolButton)
            set(toolButton,'State','off');
         end
         
         stateData = LInitStateData(fig);
         setappdata(fig,'ScribeAddAnnotationStateData', stateData);
         
         LMaskAll(fig,'on');  % restore
      end
   catch
      % state may have changed while we were finishing
      % up. e.g. window closed etc.
   end
 
 case 'zoomin'
   fixtoolbar(fig);
   onoff = get(toolButton,'State');
   if strcmp(onoff,'on')
       zoom(fig,'inmode');
   else
       zoom(fig,'off')
   end
  
 case 'zoomout'
   fixtoolbar(fig);
   onoff = get(toolButton,'State');
   if strcmp(onoff,'on')
       zoom(fig,'outmode');
   else
       zoom(fig,'off')
   end
   
 case 'pan'
   fixtoolbar(fig);
   if ishandle(toolButton)
      pan(fig,get(toolButton,'State'));
   end
  
 case 'rotate3d'
   fixtoolbar(fig);
   if ishandle(toolButton)
      rotate3d(fig,get(toolButton,'State'));
   else
      rotate3d;
   end

case 'datatip'
    fixtoolbar(fig);
    if ishandle(toolButton)
      datacursormode(fig,get(toolButton,'State'));
    end
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function overlayAxis = LGetOverlayAxis(fig)

axH=findall(fig,'type','axes');
if ~isempty(axH)
    overlayAxis=double(find(handle(axH),'-class','graph2d.annotationlayer'));
    if isempty(overlayAxis)
        overlayAxis = findall(axH,'Tag','ScribeOverlayAxesActive');
    end
else
    overlayAxis=[];
end

if isempty(overlayAxis)
    alreadyOn = plotedit(fig,'isactive');
    plotedit(fig,'on','silent');
    if ~alreadyOn
        plotedit(fig,'off','silent');
    end
    
    axH=findall(fig,'type','axes');
    if ~isempty(axH)
        overlayAxis=double(find(handle(axH),'-class','graph2d.annotationlayer'));
        if isempty(overlayAxis)
            overlayAxis = findall(axH,'Tag','ScribeOverlayAxesActive');
        end
    else
        overlayAxis=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LMaskAll(fig,  setting)

WindowFcnList = {...
        'Pointer',...
        'WindowButtonDownFcn', ...
        'WindowButtonMotionFcn',...
        'WindowButtonUpFcn'};

savedSettings = getappdata(fig,'ScribeWindowMaskSettings');

switch setting
case 'on'  % restore
   if ~isempty(savedSettings) & isstruct(savedSettings)
      set(fig, WindowFcnList, savedSettings.WindowFcns);
      savedSettings = [];
   end
case 'off' % save
   promoteoverlay(fig);
   savedSettings.WindowFcns = get(fig, WindowFcnList);
   set(fig, WindowFcnList(2:4), {'' '' ''});
end

setappdata(fig,'ScribeWindowMaskSettings',savedSettings);

function LSetSelect(fig,state)
if ishandle(fig)
   switch state
      case 'off'
         scribeclearmode(fig,'putdowntext',fig,'reset');
      case 'on'
         plotedit(fig,'on');
   end
end
   
function stateData = LInitStateData(fig)
stateData = struct(...
        'x',[], ...
        'y', [], ...
        'myline', [], ...
        'isarrow', 0, ...
        'oldPointer', get(fig,'Pointer'));
     

