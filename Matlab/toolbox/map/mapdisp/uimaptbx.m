function uimaptbx(hndl,fcnstr,texthndl)

%UIMAPTBX  Processes the button down callbacks for the Mapping Toolbox objects
%
%  UIMAPTBX processes the mouse events for objects displayed using
%  the Mapping Toolbox, as long as no WindowButtonDownFcn is currently
%  assigned.  To assign it to an object, set the ButtonDownFcn to 'uimaptbx'.
%  This is the default setting for all Mapping Toolbox objects.
%
%  If UIMAPTBX is assigned to an object, the following mouse events are
%  recognized.  Single click and hold on an object displays its tag, or
%  type if no tag is specified.  Double click on an object opens up
%  the GUIDE object editor allowing all properties to be changed.
%  Extended click on an object allows the map properties to be edited.
%  Alternative click on an object allows selected properties to be
%  edited using the Click and Drag tools.
%
%  For Macintosh:   Extend click - Shift click mouse button
%                   Alternate click - Option click mouse button
%
%  For MS-Windows:  Extend click - Shift click left button or both buttons
%                   Alternate click - Control click left button or right button
%
%  For X-Windows:   Extend click - Shift click left button or middle button
%                   Alternate click - Control click left button or right button
%
%  See also  GUIDE, PROPEDIT

%  Written by:  E. Byrns, E. Brown
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.22.4.1 $  $Date: 2003/08/01 18:23:05 $


if nargin == 0
   hndl = gcbo;
   set(hndl,'Interruptible','off','BusyAction','cancel')
   
elseif nargin == 1
   if isempty(hndl)     %  No input handle
      return
   elseif any( ~ishandle(hndl))
      uiwait(errordlg('Valid handle required in UIMAPTBX',...
         'Mapping Toolbox Error','modal'))
      return
   end
   
   hndl = hndl(1);   %  Ensure a scalar handle
   
   
   
elseif nargin > 1      %  Callbacks from internal functions
   
   switch fcnstr
   case 'clickNdrag',   clickNdrag(hndl)
   case 'tagui',        tagui(hndl)
   case 'linemod',      linemod(hndl)
   case 'patchmod',     patchmod(hndl)
   case 'surfmod',      surfmod(hndl)
   case 'textmod',      textmod(hndl)
   case 'axmod',        axmod(hndl)
   case 'figmod',       figmod(hndl)
   end
   return
   
end

%  Return if there is a WindowButtonDownFcn active.  This occurs
%  if something like PANZOOM is in use.

if ~isempty(get(gcf,'WindowButtonDownFcn'));   return;   end

%  Switch on the mouse selection type

switch get(gcf,'SelectionType')
case 'normal',       tagui(hndl)
case 'open',         propedit(hndl)
case 'extend'     %  Click on axes or an object on the axes
   if strcmp(get(hndl,'Type'),'axes');   axesmui(hndl)
   else;                             axesmui(get(hndl,'Parent'))
   end
case 'alt'     %  Call the appropriate scribe function
   switch get(hndl,'Type')
   case 'axes',     axmod;
   case 'surface',  surfmod;
   case 'line',     linemod;
   case 'patch',    patchmod;
   case 'text',     textmod;
   case 'figure',   figmod;
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function  tagui(action)

%TAGUI  Interactive display of line tags
%
%  TAGUI(h) allows users to interactively display an object's
%  tag at the lower left hand corner of the figure window.
%  When the button is released, then this display is deleted.

%  Input test

if nargin ~= 1;        error('Incorrect number of arguments')
elseif isstr(action);  hndl = gco;
else;                  hndl = action;   action = 'initialize';
end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


%  Switch on the appropriate action

switch action
case 'initialize'
   
   %  Compute the Pixel and Font Scaling Factors so
   %  GUI figure windows and fonts look OK across all platforms
   
   PixelFactor = guifactm('pixels');
   FontScaling =  guifactm('fonts');
   
   % Lock the current state of the toolbar, so it doesn't bounce on and
   % off with each mouse click
   
   vernum = version; vernum = str2num(vernum(1:3));
   if vernum > 5.2
       OriginalToolbarState=get(gcf,'toolbar');
       plotedit(gcf,'locktoolbarvisibility');
	end
	   
   %  Create the display object
   
   thetext=uicontrol('Style','Text', 'String',namem(hndl),...
      'Units','Points',  'Position',PixelFactor*[2 2 500 20],...
      'FontWeight','normal',  'FontSize',FontScaling*12,...
      'HorizontalAlignment','left', 'Tag','TextObjectToDelete',...
      'ForegroundColor', 'black','BackgroundColor', get(gcf,'Color'),...
      'UserData',get(gcf,'WindowButtonUpFcn'));
	  
   % Save the toolbar's state for when the button is released
   if vernum > 5.2
       setappdata(thetext,'OriginalToolbarState',OriginalToolbarState);
   end
   
   set(gcf,'WindowButtonUpFcn','uimaptbx(''up'',''tagui'')');
   
case 'up'
   
   h = findobj(gcf,'Type','uicontrol','Tag','TextObjectToDelete');
   if ~isempty(h)
      set(gcf,'WindowButtonUpFcn',get(h,'UserData'));
      % Restore the toolbar's state
      vernum = version; vernum = str2num(vernum(1:3));
      if vernum > 5.2
         OriginalToolbarState=getappdata(h,'OriginalToolbarState');
      end
      delete(h);
      if vernum > 5.2
          set(gcf,'toolbar',OriginalToolbarState)
      end
   end
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function linemod(action)

% Modify the line based on a quick point-and-click interface
% Code is from an Alpha version of Scribe 6/96.  EVB

if nargin==0
   if strcmp(get(gcf,'SelectionType'),'alt');   action='init';  end
end

%  Compute the Pixel and Font Scaling Factor

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


switch action
case 'init',
   SavedStuff.Hndl=gcbo;
   SavedStuff.Units = get(gcf,'Units');
   
   set(gcf,'Units','inches');
   currPt=get(gcf,'CurrentPoint');
   
   if strcmp(namem(SavedStuff.Hndl),'Parallel') | ...
         strcmp(namem(SavedStuff.Hndl),'Meridian')
      numProps=5;   boxsize = [1.7 1.1];
   else
      numProps=8;   boxsize = [1.7 1.7];
   end
   
   axes('Units','points', ...
      'Position',PixelFactor*72*[currPt(1) currPt(2) boxsize], ...
      'Color',0.8*[1 1 1], ...
      'XColor',[1 1 1],'YColor',[1 1 1], ...
      'Box','on', 'DrawMode','fast', ...
      'XLim',[-4 1.5],'YLim',[-1 numProps+1], ...
      'XTick',[],'YTick',[], ...
      'SelectionHighlight','on',...
      'ButtonDownFcn','uimaptbx(''axesdown'',''clickNdrag'')');
   axLims=axis;
   
   %
   text(-0.75,0,'EXIT', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''exit'',''clickNdrag'')');
   %	
   
   objNumber=1;
   objData.prop='Hide/Show/Delete';
   text(-1.5,objNumber,'Hide', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''hide'',''clickNdrag'')');
   text(-1.0,objNumber,'Delete', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''delete'',''clickNdrag'')');
   
   objNumber=objNumber+1;
   objData.prop='LineStyle';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},...
         {'-','--',':','-.','none'}];
   objData.index=1;
   t = text(-1,objNumber,objData.prop, ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle', ...
      'ButtonDownFcn','uimaptbx(''linereset'',''linemod'')');
   h=line([0 1],objNumber*[1 1], ...
      'LineStyle',objData.list{objData.index}, ...
      'LineWidth',2, ...
      'Color','black', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''linemod'')');
   set(t,'UserData',h)
   
   objNumber=objNumber+1;
   objData.prop='LineWidth';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},...
         num2cell(0.5:0.5:5)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   line([0 1],objNumber*[1 1], ...
      'LineWidth',objData.list{objData.index}, ...
      'Color','black', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''linemod'')');
   
   objNumber=objNumber+1;
   objData.prop='Color';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};num2cell(get(gcf,'ColorMap'),2)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   line([0 1],objNumber*[1 1], ...
      'Color',objData.list{objData.index}, ...
      'LineWidth',4, ...
      'UserData',objData, ...
      'EraseMode','none', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''linemod'')');
   
   if numProps == 8
      objNumber=objNumber+1;
      objData.prop='MarkerSize';
      objData.list=[{get(SavedStuff.Hndl,objData.prop)},num2cell(2:2:20)];
      objData.index=1;
      text(-1,objNumber,objData.prop, ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle');
      line(.5,objNumber, ...
         'Color','black', ...
         'Marker','x', ...
         'MarkerSize',objData.list{objData.index}, ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''linemod'')');
      
      objNumber=objNumber+1;
      objData.prop='MarkerColor';
      objData.list=[{get(SavedStuff.Hndl,'MarkerEdgeColor')};...
            num2cell(get(gcf,'ColorMap'),2);{'auto'}];
      objData.index=1;
      text(-1,objNumber,objData.prop, ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle');
      
      markeredge = get(SavedStuff.Hndl,'MarkerEdgeColor');
      if strcmp(markeredge,'auto') | strcmp(markeredge,'none')
         markeredge = get(SavedStuff.Hndl,'Color');
      end
      line(.5,objNumber, ...
         'MarkerEdgeColor',markeredge, ...
         'MarkerFaceColor',markeredge, ...
         'Marker','o', ...
         'MarkerSize',6, ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''linemod'')');
      
      objNumber=objNumber+1;
      objData.prop='Marker';
      objData.list=[{get(SavedStuff.Hndl,objData.prop)},...
            {'x','o','*','+','.','>','v','<','^','none'}];
      objData.index=1;
      text(-1,objNumber,objData.prop, ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle')
      line(0.5,objNumber, ...
         'Marker',objData.list{objData.index}, ...
         'MarkerSize',8, ...
         'MarkerFaceColor','black', ...
         'MarkerEdgeColor','black', ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''linemod'')');
   end
   
   objNumber=objNumber+1;
   TitleStr = namem(SavedStuff.Hndl);
   TitleStr = TitleStr(1:min(length(TitleStr),20));
   if strcmp(TitleStr,'Parallel') | strcmp(TitleStr,'Meridian')
      TitleStr = 'Grid';
   end
   
   text(mean(axLims(1:2)),objNumber,TitleStr, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle');
   
   set(gca,'UserData',SavedStuff)
   
   
case 'mousedown',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   SavedStuff.ObjHndl=gcbo;
   SavedStuff.StartPt=get(gcf,'CurrentPoint');
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'Color')
      objData.list=[{get(SavedStuff.Hndl,objData.prop)};num2cell(get(gcf,'ColorMap'),2)];
      set(SavedStuff.ObjHndl,'UserData',objData)
   elseif strcmp(objData.prop,'MarkerColor')
      objData.list=[{get(SavedStuff.Hndl,'MarkerEdgeColor')};...
            num2cell(get(gcf,'ColorMap'),2);{'auto'}];
      set(SavedStuff.ObjHndl,'UserData',objData)
   end
   
   set(gca,'UserData',SavedStuff)
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''mousemove'',''linemod'')')
   
   if strcmp(namem(SavedStuff.Hndl),'Parallel') | ...
         strcmp(namem(SavedStuff.Hndl),'Meridian')
      set(gcf,'WindowButtonUpFcn','uimaptbx(''gridup'',''linemod'')')
   else
      set(gcf,'WindowButtonUpFcn','uimaptbx(''mouseup'',''linemod'')')
   end
   
case 'mousemove',
   SavedStuff = get(gca,'UserData');
   currPt=get(gcf,'CurrentPoint');
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   divisor=1.5/length(objData.list);
   
   indexOffset=floor(sqrt((currPt(1)-SavedStuff.StartPt(1))^2+ ...
      (currPt(2)-SavedStuff.StartPt(2))^2)/divisor);
   objIndex=max(1,min(length(objData.list),objData.index+indexOffset));
   
   if strcmp(objData.prop,'MarkerColor')
      set(SavedStuff.ObjHndl,'MarkerFaceColor',objData.list{objIndex});
      set(SavedStuff.ObjHndl,'MarkerEdgeColor',objData.list{objIndex});
   else
      set(SavedStuff.ObjHndl,objData.prop,objData.list{objIndex});
   end
   
case 'mouseup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'MarkerColor')
      set(SavedStuff.Hndl,'MarkerFaceColor',...
         get(SavedStuff.ObjHndl,'MarkerEdgeColor'))
      set(SavedStuff.Hndl,'MarkerEdgeColor',...
         get(SavedStuff.ObjHndl,'MarkerEdgeColor'))
   else
      set(SavedStuff.Hndl,objData.prop,...
         get(SavedStuff.ObjHndl,objData.prop))
   end
   
case 'gridup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   mapaxes = get(SavedStuff.Hndl,'Parent');
   mstruct = gcm(mapaxes);
   mhndl = handlem('Meridian',mapaxes);
   phndl = handlem('Parallel',mapaxes);
   
   switch objData.prop
   case 'Color'
      set([mhndl phndl],'Color',get(SavedStuff.ObjHndl,'Color'))
      mstruct.gcolor = get(SavedStuff.Hndl,'Color');
   case 'LineWidth'
      set([mhndl phndl],'LineWidth',get(SavedStuff.ObjHndl,'LineWidth'))
      mstruct.glinewidth = get(SavedStuff.Hndl,'LineWidth');
   case 'LineStyle'
      set([mhndl phndl],'LineStyle',get(SavedStuff.ObjHndl,'LineStyle'))
      mstruct.glinestyle = get(SavedStuff.Hndl,'LineStyle');
   end
   
   set(mapaxes,'UserData',mstruct)
   
case 'linereset',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   h=get(gcbo,'UserData');
   linestyle = get(h,'LineStyle');
   if strcmp(linestyle,'none');    set(h,'LineStyle','-')
   else;                           set(h,'LineStyle','none')
   end
   
   if strcmp(namem(SavedStuff.Hndl),'Parallel') | ...
         strcmp(namem(SavedStuff.Hndl),'Meridian')
      mapaxes = get(SavedStuff.Hndl,'Parent');
      mstruct = gcm(mapaxes);
      mhndl = handlem('Meridian',mapaxes);
      phndl = handlem('Parallel',mapaxes);
      set([mhndl phndl],'LineStyle',get(h,'LineStyle'))
      mstruct.glinestyle = get(SavedStuff.Hndl,'LineStyle');
      set(mapaxes,'UserData',mstruct)
   else
      set(SavedStuff.Hndl,'LineStyle',get(h,'LineStyle'))
   end
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function surfmod(action)

% Modify the axes based on a quick point-and-click interface
% Code is from an Alpha version of Scribe 6/96.  EVB

if nargin==0
   if strcmp(get(gcf,'SelectionType'),'alt');   action='init';  end
end

%  Compute the Pixel and Font Scaling Factor

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


switch action
case 'init',
   SavedStuff.Hndl=gcbo;
   SavedStuff.Units = get(gcf,'Units');
   
   set(gcf,'Units','inches');
   currPt=get(gcf,'CurrentPoint');
   
   numProps=6;
   axes('Units','points', ...
      'Position',PixelFactor*72*[currPt(1) currPt(2) 2  1.5], ...
      'Color',0.8*[1 1 1], ...
      'XColor',[1 1 1],'YColor',[1 1 1], ...
      'Box','on', ...
      'DrawMode','fast', ...
      'XLim',[-4 1.5],'YLim',[-1 numProps+1], ...
      'XTick',[],'YTick',[], ...
      'SelectionHighlight','on',...
      'ButtonDownFcn','uimaptbx(''axesdown'',''clickNdrag'')');
   axLims=axis;
   
   text(-0.75,0,'EXIT', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''exit'',''clickNdrag'')');
   
   objNumber=1;
   objData.prop='Hide/Show/Delete';
   text(-1.5,objNumber,'Hide', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''hide'',''clickNdrag'')');
   text(-1.0,objNumber,'Delete', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''delete'',''clickNdrag'')');
   
   objNumber=objNumber+1;
   objData.prop='Graticule';
   t=text(mean(axLims(1:2)),objNumber,objData.prop, ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''graticule'',''surfmod'')');
   
   userdata = get(SavedStuff.Hndl,'UserData');
   indx = strmatch('maplegend',char(fieldnames(userdata)),'exact');
   if length(indx) ~= 1;    set(t,'Visible','off');   end
   
   objNumber=objNumber+1;
   objData.prop='EdgeColor';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};num2cell(get(gcf,'ColorMap'),2)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   objHndl=line([0 1],objNumber*[1 1], ...
      'Color',objData.list{objData.index}, ...
      'LineWidth',4, ...
      'UserData',objData, ...
      'EraseMode','none', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''surfmod'')');
   
   objNumber=objNumber+1;
   objData.prop='LineWidth';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},num2cell(0.5:0.5:5)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   objHndl=line([0 1],objNumber*[1 1], ...
      'LineWidth',objData.list{objData.index}, ...
      'Color','black', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''surfmod'')');
   
   objNumber=objNumber+1;
   objData.prop='LineStyle';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},{'-','--',':','-.','none'}];
   objData.index=1;
   t = text(-1,objNumber,objData.prop, ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''linereset'',''surfmod'')');
   objHndl=line([0 1],objNumber*[1 1], ...
      'LineStyle',objData.list{objData.index}, ...
      'LineWidth',2, ...
      'Color','black', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''surfmod'')');
   set(t,'UserData',objHndl)
   
   objNumber=objNumber+1;
   TitleStr = namem(SavedStuff.Hndl);
   TitleStr = TitleStr(1:min(length(TitleStr),20));
   text(mean(axLims(1:2)),objNumber,TitleStr, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle');
   
   set(gca,'UserData',SavedStuff)
   
case 'mousedown',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   SavedStuff.ObjHndl=gcbo;
   SavedStuff.StartPt=get(gcf,'CurrentPoint');
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'EdgeColor')
      objData.list=[{get(SavedStuff.Hndl,objData.prop)};num2cell(get(gcf,'ColorMap'),2)];
      set(SavedStuff.ObjHndl,'UserData',objData)
   end
   
   set(gca,'UserData',SavedStuff)
   
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''mousemove'',''surfmod'')')
   set(gcf,'WindowButtonUpFcn','uimaptbx(''mouseup'',''surfmod'')')
   
case 'mousemove',
   SavedStuff = get(gca,'UserData');
   currPt=get(gcf,'CurrentPoint');
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   divisor=1.5/length(objData.list);
   
   indexOffset=floor(sqrt((currPt(1)-SavedStuff.StartPt(1))^2+ ...
      (currPt(2)-SavedStuff.StartPt(2))^2)/divisor);
   objIndex=max(1,min(length(objData.list),objData.index+indexOffset));
   
   if strcmp(objData.prop,'EdgeColor')
      set(SavedStuff.ObjHndl,'Color',objData.list{objIndex});
   else
      set(SavedStuff.ObjHndl,objData.prop,objData.list{objIndex});
   end
   
case 'mouseup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'EdgeColor')
      set(SavedStuff.Hndl,objData.prop,...
         get(SavedStuff.ObjHndl,'Color'))
   else
      set(SavedStuff.Hndl,objData.prop,...
         get(SavedStuff.ObjHndl,objData.prop))
   end
   
case 'linereset',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   h=get(gcbo,'UserData');
   linestyle = get(h,'LineStyle');
   if strcmp(linestyle,'none');	set(h,'LineStyle','-')
   else;                       set(h,'LineStyle','none')
   end
   set(SavedStuff.Hndl,'LineStyle',get(h,'LineStyle'))
   
case 'graticule',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   prompt   = 'Edit Graticule size (2 element vector [# #]):';
   titlestr = 'Graticule Mesh';
   answer = {['[',num2str(size(get(SavedStuff.Hndl,'Xdata'))),']']};
   
   while 1
      lasterr('')
      answer=inputdlg(prompt,titlestr,1,answer(1));
      
      if ~isempty(answer)
         set(get(0,'CurrentFigure'),'CurrentAxes',get(SavedStuff.Hndl,'Parent'))
         eval(['setm(SavedStuff.Hndl,''MeshGrat'',',answer{1},');'],...
            'uiwait(errordlg(lasterr,''Graticule Mesh Error'',''modal''))')
         set(get(0,'CurrentFigure'),'CurrentAxes',get(gcbo,'Parent'))
         if isempty(lasterr);   break;   end
      else
         break
      end
   end
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function patchmod(action)

% Modify the patch based on a quick point-and-click interface
% Code is a modificaton of linemod from an Alpha version of Scribe 8/96.  EVB


if nargin==0
   if strcmp(get(gcf,'SelectionType'),'alt');   action='init';  end
end

%  Compute the Pixel and Font Scaling Factor

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


switch action
case 'init',
   SavedStuff.Hndl=gcbo;
   SavedStuff.Units = get(gcf,'Units');
   
   set(gcf,'Units','inches');
   currPt=get(gcf,'CurrentPoint');
   
   if strcmp(namem(SavedStuff.Hndl),'Frame')
      numProps=5;   boxsize = [1.7 1.1];
   else
      numProps=9;   boxsize = [1.7  1.8];
   end
   
   axes('Units','points', ...
      'Position',PixelFactor*72*[currPt(1) currPt(2) boxsize], ...
      'Color',0.8*[1 1 1], ...
      'XColor',[1 1 1],'YColor',[1 1 1], ...
      'Box','on', ...
      'DrawMode','fast', ...
      'XLim',[-4 1.5],'YLim',[-1 numProps+1], ...
      'XTick',[],'YTick',[], ...
      'SelectionHighlight','on',...
      'ButtonDownFcn','uimaptbx(''axesdown'',''clickNdrag'')');
   axLims=axis;
   
   text(-0.75,0,'EXIT', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''exit'',''clickNdrag'')');
   
   objNumber=1;
   objData.prop='Hide/Show/Delete';
   text(-1.5,objNumber,'Hide', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''hide'',''clickNdrag'')');
   text(-1.0,objNumber,'Delete', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''delete'',''clickNdrag'')');
   
   objNumber=objNumber+1;
   objData.prop='FaceColor';
   objData.index=1;
   if strcmp(get(SavedStuff.Hndl,'FaceColor'),'flat')  %  Remove cdata indexing of patch
      clim  = get(get(SavedStuff.Hndl,'Parent'),'Clim');
      cdata = get(SavedStuff.Hndl,'Cdata');
      cmap  = colormap;      caxis(clim);
      
      if cdata < min(clim);          clrs = cmap(1,:);
      elseif cdata > max(clim);  clrs = cmap(size(cmap,1),:);
      else;                      cindx = linspace(min(clim),max(clim),size(cmap,1))';
         clrs  = interp1(cindx, cmap,cdata);
      end
      set(SavedStuff.Hndl,'FaceColor',clrs)
      
      objData.list=[{clrs}; num2cell(get(gcf,'ColorMap'),2);{'none'}];
   else
      objData.list=[{get(SavedStuff.Hndl,objData.prop)};...
            num2cell(get(gcf,'ColorMap'),2);{'none'}];
   end
   
   t = text(-1,objNumber,objData.prop, ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''facereset'',''patchmod'')');
   h=patch('Xdata',[0 1 1 0],'Ydata',objNumber+[-0.2 -0.2 0.2 0.2], ...
      'FaceColor',objData.list{objData.index}, ...
      'EdgeColor','none',...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
   set(t,'UserData',h)
   
   objNumber=objNumber+1;
   objData.prop='EdgeColor';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};...
         num2cell(get(gcf,'ColorMap'),2);{'none'}];
   objData.index=1;
   
   t = text(-1,objNumber,objData.prop, ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''edgereset'',''patchmod'')');
   h=patch('Xdata',[0 1 1 0],'Ydata',objNumber+[-0.2 -0.2 0.2 0.2], ...
      'FaceColor',objData.list{objData.index}, ...
      'EdgeColor','none',...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
   set(t,'UserData',h)
   
   objNumber=objNumber+1;
   objData.prop='LineWidth';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},num2cell(0.5:0.5:5)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   line([0 1],objNumber*[1 1], ...
      'LineWidth',objData.list{objData.index}, ...
      'Color','black', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
   
   if numProps == 9
      objNumber=objNumber+1;
      objData.prop='LineStyle';
      objData.list=[{get(SavedStuff.Hndl,objData.prop)},{'-','--',':','-.','none'}];
      objData.index=1;
      t = text(-1,objNumber,objData.prop, ...
         'Color','blue', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle', ...
         'ButtonDownFcn','uimaptbx(''linereset'',''patchmod'')');
      h=line([0 1],objNumber*[1 1], ...
         'LineStyle',objData.list{objData.index}, ...
         'LineWidth',2, ...
         'Color','black', ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
      set(t,'UserData',h)
      
      objNumber=objNumber+1;
      objData.prop='Marker';
      objData.list=[{get(SavedStuff.Hndl,objData.prop)},...
            {'x','o','*','+','.','>','v','<','^','none'}];
      objData.index=1;
      text(-1,objNumber,objData.prop, ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle');
      line(0.5,objNumber, ...
         'Marker',objData.list{objData.index}, ...
         'MarkerSize',8, ...
         'LineWidth',1, ...
         'MarkerFaceColor','black','MarkerEdgeColor','black',...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
      
      objNumber=objNumber+1;
      objData.prop='MarkerSize';
      objData.list=[{get(SavedStuff.Hndl,objData.prop)},num2cell(6:2:20)];
      objData.index=1;
      text(-1,objNumber,objData.prop, ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle');
      line(.5,objNumber, ...
         'Color','black', ...
         'Marker','x', ...
         'MarkerSize',objData.list{objData.index}, ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
      
      objNumber=objNumber+1;
      objData.prop='MarkerColor';
      objData.list=[{get(SavedStuff.Hndl,'MarkerEdgeColor')};...
            num2cell(get(gcf,'ColorMap'),2);{'auto'}];
      objData.index=1;
      text(-1,objNumber,objData.prop, ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle');
      markeredge = get(SavedStuff.Hndl,'MarkerEdgeColor');
      if strcmp(markeredge,'auto') | strcmp(markeredge,'none')
         markeredge = get(SavedStuff.Hndl,'FaceColor');
      end
      line(.5,objNumber, ...
         'LineStyle','none',...
         'Marker','o', ...
         'MarkerEdgeColor',markeredge, ...
         'MarkerFaceColor',markeredge, ...
         'MarkerSize',8, ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''patchmod'')');
   end
   
   objNumber=objNumber+1;
   TitleStr = namem(SavedStuff.Hndl);
   TitleStr = TitleStr(1:min(length(TitleStr),20));
   text(mean(axLims(1:2)),objNumber,TitleStr, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle');
   
   set(gca,'UserData',SavedStuff)
   
   
case 'mousedown',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   SavedStuff.ObjHndl=gcbo;
   SavedStuff.StartPt=get(gcf,'CurrentPoint');
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'EdgeColor') | strcmp(objData.prop,'FaceColor')
      objData.list=[{get(SavedStuff.Hndl,objData.prop)};...
            num2cell(get(gcf,'ColorMap'),2);{'none'}];
      set(SavedStuff.ObjHndl,'UserData',objData)
   elseif strcmp(objData.prop,'MarkerColor')
      objData.list=[{get(SavedStuff.Hndl,'MarkerEdgeColor')};...
            num2cell(get(gcf,'ColorMap'),2);{'auto'}];
      set(SavedStuff.ObjHndl,'UserData',objData)
   end
   
   set(gca,'UserData',SavedStuff)
   
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''mousemove'',''patchmod'')')
   if strcmp(namem(SavedStuff.Hndl),'Frame')
      set(gcf,'WindowButtonUpFcn','uimaptbx(''frameup'',''patchmod'')')
   else
      set(gcf,'WindowButtonUpFcn','uimaptbx(''mouseup'',''patchmod'')')
   end
   
case 'mousemove',
   SavedStuff = get(gca,'UserData');
   currPt=get(gcf,'CurrentPoint');
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   divisor=1.5/length(objData.list);
   
   indexOffset=floor(sqrt((currPt(1)-SavedStuff.StartPt(1))^2+ ...
      (currPt(2)-SavedStuff.StartPt(2))^2)/divisor);
   objIndex=max(1,min(length(objData.list),objData.index+indexOffset));
   
   if strcmp(objData.prop,'MarkerColor')
      set(SavedStuff.ObjHndl,'MarkerFaceColor',objData.list{objIndex});
      set(SavedStuff.ObjHndl,'MarkerEdgeColor',objData.list{objIndex});
   elseif strcmp(objData.prop,'FaceColor') | strcmp(objData.prop,'EdgeColor')
      set(SavedStuff.ObjHndl,'FaceColor',objData.list{objIndex});
   else
      set(SavedStuff.ObjHndl,objData.prop,objData.list{objIndex});
   end
   
case 'mouseup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'MarkerColor')
      set(SavedStuff.Hndl,'MarkerFaceColor',...
         get(SavedStuff.ObjHndl,'MarkerEdgeColor'))
      set(SavedStuff.Hndl,'MarkerEdgeColor',...
         get(SavedStuff.ObjHndl,'MarkerEdgeColor'))
      
   elseif strcmp(objData.prop,'FaceColor') | ...
         strcmp(objData.prop,'EdgeColor')
      set(SavedStuff.Hndl,objData.prop,...
         get(SavedStuff.ObjHndl,'FaceColor'))
      
   else
      set(SavedStuff.Hndl,objData.prop,...
         get(SavedStuff.ObjHndl,objData.prop))
   end
   
case 'frameup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   mapaxes = get(SavedStuff.Hndl,'Parent');
   mstruct = gcm(mapaxes);
   
   switch objData.prop
   case 'FaceColor'
      set(SavedStuff.Hndl,'FaceColor',get(SavedStuff.ObjHndl,'FaceColor'))
      mstruct.ffacecolor = get(SavedStuff.Hndl,'FaceColor');
   case 'EdgeColor'
      set(SavedStuff.Hndl,'EdgeColor',get(SavedStuff.ObjHndl,'FaceColor'))
      mstruct.fedgecolor = get(SavedStuff.Hndl,'EdgeColor');
   case 'LineWidth'
      set(SavedStuff.Hndl,'LineWidth',get(SavedStuff.ObjHndl,'LineWidth'))
      mstruct.flinewidth = get(SavedStuff.Hndl,'LineWidth');
   end
   
   set(mapaxes,'UserData',mstruct)
   
case 'linereset',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   h=get(gcbo,'UserData');
   linestyle = get(h,'LineStyle');
   if strcmp(linestyle,'none');	set(h,'LineStyle','-')
   else;                       set(h,'LineStyle','none')
   end
   
   set(SavedStuff.Hndl,'LineStyle',get(h,'LineStyle'))
   if strcmp(namem(SavedStuff.Hndl),'Frame')
      mapaxes = get(SavedStuff.Hndl,'Parent');
      mstruct = gcm(mapaxes);
      mstruct.flinestyle = get(SavedStuff.Hndl,'LineStyle');
      set(mapaxes,'UserData',mstruct)
   end
   
case 'facereset',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   h=get(gcbo,'UserData');
   facecolor = get(h,'FaceColor');
   if strcmp(facecolor,'none');	set(h,'FaceColor','black')
   else;                       set(h,'FaceColor','none')
   end
   
   set(SavedStuff.Hndl,'FaceColor',get(h,'FaceColor'))
   if strcmp(namem(SavedStuff.Hndl),'Frame')
      mapaxes = get(SavedStuff.Hndl,'Parent');
      mstruct = gcm(mapaxes);
      mstruct.ffacecolor = get(SavedStuff.Hndl,'FaceColor');
      set(mapaxes,'UserData',mstruct)
   end
   
case 'edgereset',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   h=get(gcbo,'UserData');
   edgecolor = get(h,'FaceColor');
   if strcmp(edgecolor,'none');	set(h,'FaceColor','black')
   else;                       set(h,'FaceColor','none')
   end
   
   set(SavedStuff.Hndl,'EdgeColor',get(h,'FaceColor'))
   if strcmp(namem(SavedStuff.Hndl),'Frame')
      mapaxes = get(SavedStuff.Hndl,'Parent');
      mstruct = gcm(mapaxes);
      mstruct.fedgecolor = get(SavedStuff.Hndl,'EdgeColor');
      set(mapaxes,'UserData',mstruct)
   end
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function textmod(action)

% Modify the line based on a quick point-and-click interface
% Code is from an Alpha version of Scribe 6/96.  EVB


if nargin==0
   if strcmp(get(gcf,'SelectionType'),'alt');   action='init';  end
end

%  Compute the Pixel and Font Scaling Factor

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


switch action
case 'init',
   SavedStuff.Hndl=gcbo;
   SavedStuff.Units = get(gcf,'Units');
   SavedStuff.TextUnits = get(gcbo,'Units');
   SavedStuff.OrigTextUnits = get(gcbo,'Units');
   set(SavedStuff.Hndl,'Units','points');
   
   set(gcf,'Units','inches');
   currPt=get(gcf,'CurrentPoint');
   
   if strcmp(namem(SavedStuff.Hndl),'PLabel') | ...
         strcmp(namem(SavedStuff.Hndl),'MLabel')
      numProps=6;   boxsize = [1.75 1.5];
   else
      numProps=8;   boxsize = [1.75  1.7];
   end
   
   % delete open Scribe Axes prior to constructing new ones
   h = findobj('Type','Axes','Tag','ScribeAxes');
   if ishandle(h); delete(h); end
   
   axes('Units','points', ...
      'Position',PixelFactor*72*[currPt(1) currPt(2) boxsize], ...
      'Color',0.8*[1 1 1], ...
      'XColor',[1 1 1],'YColor',[1 1 1], ...
      'Box','on',...
      'Tag', 'ScribeAxes',...
      'DrawMode','fast', ...
      'XLim',[-4 1.5],'YLim',[-1 numProps+1], ...
      'XTick',[],'YTick',[], ...
      'SelectionHighlight','on',...
      'ButtonDownFcn','uimaptbx(''axesdown'',''clickNdrag'')');
   axLims=axis;
   
   text(-0.75,0,'EXIT', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''exit'',''clickNdrag'')');
   
   objNumber=1;
   objData.prop='Hide/Show/Delete';
   text(-1.5,objNumber,'Hide', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''hide'',''clickNdrag'')');
   text(-1.0,objNumber,'Delete', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''delete'',''clickNdrag'')');
   
   if numProps==8
      objNumber=objNumber+1;
      text(mean(axLims(1:2)),objNumber,'Edit', ...
         'Color','blue', ...
         'FontWeight','bold', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','middle', ...
         'ButtonDownFcn','uimaptbx(''edit'',''textmod'')');
   end
   
   objNumber=objNumber+1;
   text(mean(axLims(1:2)),objNumber,'Drag', ...
      'Color','blue', ...
      'FontWeight','bold', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'UserData',SavedStuff.Hndl, ...
      'ButtonDownFcn','uimaptbx(''drag'',''textmod'')');
   
   objNumber=objNumber+1;
   objData.prop='FontSize';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},num2cell(8:2:24)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   text(.5,objNumber,'ab2', ...
      'Color','black', ...
      'FontSize',FontScaling*objData.list{objData.index}, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''textmod'')');
   
   objNumber=objNumber+1;
   objData.prop='FontName';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)},...
         {'courier','helvetica','symbol','times'}];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   text(.5,objNumber,'ab2', ...
      'Color','black', ...
      'FontSize',FontScaling*12, ...
      'FontName',objData.list{objData.index}, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''textmod'')');
   
   if numProps==8
      objNumber=objNumber+1;
      objData.prop='HorizontalAlignment';
      objData.list=[{get(SavedStuff.Hndl,objData.prop)},...
            {'left','center','right'}];
      objData.index=1;
      text(-1,objNumber,'Alignment', ...
         'Color','black', ...
         'FontSize',FontScaling*10, ...
         'HorizontalAlignment','right', ...
         'VerticalAlignment','middle');
      text(.5,objNumber,objData.list{objData.index}, ...
         'Color','black', ...
         'FontSize',FontScaling*12, ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','middle', ...
         'UserData',objData, ...
         'EraseMode','background', ...
         'ButtonDownFcn','uimaptbx(''mousedown'',''textmod'')');
   end
   
   objNumber=objNumber+1;
   objData.prop='Color';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};num2cell(get(gcf,'ColorMap'),2)];
   objData.index=1;
   text(-1,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   text(.5,objNumber,'ab2', ...
      'Color',objData.list{objData.index}, ...
      'FontSize',FontScaling*12, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'UserData',objData, ...
      'EraseMode','none', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''textmod'')');
   
   objNumber=objNumber+1;
   TitleStr = namem(SavedStuff.Hndl);
   TitleStr = TitleStr(1:min(length(TitleStr),20));
   if strcmp(TitleStr,'PLabel') | strcmp(TitleStr,'MLabel')
      TitleStr = 'Map Labels';
   end
   text(mean(axLims(1:2)),objNumber,TitleStr, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle');
   
   set(gca,'UserData',SavedStuff)
   
case 'mousedown',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   SavedStuff.ObjHndl=gcbo;
   SavedStuff.StartPt=get(gcf,'CurrentPoint');
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'Color')
      objData.list=[{get(SavedStuff.Hndl,objData.prop)};num2cell(get(gcf,'ColorMap'),2)];
      set(SavedStuff.ObjHndl,'UserData',objData)
   end
   set(gca,'UserData',SavedStuff)
   
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''mousemove'',''textmod'')')
   if strcmp(namem(SavedStuff.Hndl),'PLabel') | ...
         strcmp(namem(SavedStuff.Hndl),'MLabel')
      set(gcf,'WindowButtonUpFcn','uimaptbx(''labelup'',''textmod'')')
   else
      set(gcf,'WindowButtonUpFcn','uimaptbx(''mouseup'',''textmod'')')
   end
   
case 'mousemove',
   SavedStuff = get(gca,'UserData');
   currPt=get(gcf,'CurrentPoint');
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   divisor=1.5/length(objData.list);
   
   indexOffset=floor(sqrt((currPt(1)-SavedStuff.StartPt(1))^2+ ...
      (currPt(2)-SavedStuff.StartPt(2))^2)/divisor);
   objIndex=max(1,min(length(objData.list),objData.index+indexOffset));
   
   if strcmp(objData.prop,'HorizontalAlignment')
      set(SavedStuff.ObjHndl,'String',objData.list{objIndex});
   else
      set(SavedStuff.ObjHndl,objData.prop,objData.list{objIndex});
   end
   
case 'mouseup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   if strcmp(objData.prop,'HorizontalAlignment')
      set(SavedStuff.Hndl,objData.prop,get(SavedStuff.ObjHndl,'String'))
   else
      set(SavedStuff.Hndl,objData.prop,get(SavedStuff.ObjHndl,objData.prop))
   end
   
case 'labelup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   mapaxes = get(SavedStuff.Hndl,'Parent');
   mstruct = gcm(mapaxes);
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   hndl1 = findobj(get(SavedStuff.Hndl,'Parent'),...
      'Type','text','Tag','PLabel');
   hndl2 = findobj(get(SavedStuff.Hndl,'Parent'),...
      'Type','text','Tag','MLabel');
   
   switch objData.prop
   case 'FontSize'
      mstruct.fontsize = get(SavedStuff.ObjHndl,objData.prop);
      mstruct.fontunits = 'points';
      set([hndl1;hndl2],'FontUnits','points')
   case 'FontName'
      mstruct.fontname = get(SavedStuff.ObjHndl,objData.prop);
   case 'Color'
      mstruct.fontcolor = get(SavedStuff.ObjHndl,objData.prop);
   end
   
   set([hndl1;hndl2],objData.prop,get(SavedStuff.ObjHndl,objData.prop))
   set(mapaxes,'UserData',mstruct)
   
case 'edit',
   SavedStuff = get(gca,'UserData');
   prompt   = 'Edit the string below:';
   titlestr = 'Text Edit';
   answer = {get(SavedStuff.Hndl,'String')};
   
   while 1
      lasterr('')
      answer=inputdlg(prompt,titlestr,5,answer(1));
      
      if ~isempty(answer)
         set(get(0,'CurrentFigure'),'CurrentAxes',get(SavedStuff.Hndl,'Parent'))
         eval(['set(SavedStuff.Hndl,''String'',answer{1});'],...
            'uiwait(errordlg(lasterr,''Text Edit Error'',''modal''))')
         set(get(0,'CurrentFigure'),'CurrentAxes',get(gcbo,'Parent'))
         if isempty(lasterr);   break;   end
      else
         break
      end
   end
   
case 'drag',
   SavedStuff = get(gca,'UserData');
   
   viewpt = get(get(SavedStuff.Hndl,'Parent'),'View');
   if viewpt(1) ~= 0
      uiwait(errordlg('Axes must be in 2D view to drag text',...
         'Text Drag Error','modal'))
      return
   end
   
   SavedStuff.OldAxes   = gca;
   SavedStuff.EraseMode = get(SavedStuff.Hndl,'EraseMode');
   SavedStuff.TextUnits = get(SavedStuff.Hndl,'Units');
   set(gca,'UserData',SavedStuff)
   
   set(SavedStuff.Hndl,'Units','data','EraseMode','xor');
   
   set(SavedStuff.Hndl,'Selected','on','SelectionHighlight','on')
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''dragtext'',''textmod'')')
   set(gcf,'WindowButtonDownFcn','uimaptbx(''textplace'',''textmod'')')
   set(gcf,'CurrentObject',SavedStuff.Hndl, ...
      'CurrentAxes',get(SavedStuff.Hndl,'Parent'))
   
case 'dragtext',
   currPt=get(gca,'CurrentPoint');
   set(gco,'Position',currPt([1 3]));
   
case 'textplace',
   h = findobj(gcf,'Type','axes','Tag','ScribeAxes');
   SavedStuff = get(h,'UserData');
   set(SavedStuff.Hndl,'EraseMode',SavedStuff.EraseMode,...
      'Units',SavedStuff.TextUnits, ...
      'Selected','off','EraseMode','normal')
   
   refresh(gcf)
   
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonDownFcn','')
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function axmod(action)

% Modify the axes based on a quick point-and-click interface
% Code is from an Alpha version of Scribe 6/96.  EVB

if nargin==0
   if strcmp(get(gcf,'SelectionType'),'alt');   action='init';  end
end

%  Compute the Pixel and Font Scaling Factor

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


switch action
case 'init',
   SavedStuff.Hndl=gca;
   SavedStuff.Units = get(gcf,'Units');
   
   set(gcf,'Units','inches');
   currPt=get(gcf,'CurrentPoint');
   
   numProps=8;
   axes('Units','points', ...
      'Position',PixelFactor*72*[currPt(1) currPt(2) 2.3  1.7], ...
      'Color',0.8*[1 1 1], ...
      'XColor',[1 1 1],'YColor',[1 1 1], ...
      'SelectionHighlight','on',...
      'Box','on', ...
      'DrawMode','fast', ...
      'XLim',[-2 1.5],'YLim',[-1 numProps+1], ...
      'XTick',[],'YTick',[], ...
      'ButtonDownFcn','uimaptbx(''axesdown'',''clickNdrag'')');
   axLims=axis;
   
   text(mean(axLims(1:2)),0,'EXIT', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''exit'',''clickNdrag'')');
   
   
   objNumber=1;
   objData.prop='Hide/Show/Delete';
   text(-.5,objNumber,'Hide', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''hide'',''clickNdrag'')');
   text(-0.25,objNumber,'Delete', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''delete'',''clickNdrag'')');
   
   objNumber=objNumber+1;
   text(mean(axLims(1:2)),objNumber,'Meridian Labels', ...
      'Color','blue', 'FontWeight','bold', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'ButtonDownFcn','uimaptbx(''toggle'',''axmod'')');
   
   objNumber=objNumber+1;
   text(mean(axLims(1:2)),objNumber,'Parallel Labels', ...
      'Color','blue', ...
      'FontWeight','bold', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'ButtonDownFcn','uimaptbx(''toggle'',''axmod'')');
   
   objNumber=objNumber+1;
   text(mean(axLims(1:2)),objNumber,'Frame', ...
      'Color','blue', ...
      'FontWeight','bold', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'ButtonDownFcn','uimaptbx(''toggle'',''axmod'')');
   
   objNumber=objNumber+1;
   text(mean(axLims(1:2)),objNumber,'Grid', ...
      'Color','blue', ...
      'FontWeight','bold', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'ButtonDownFcn','uimaptbx(''toggle'',''axmod'')');
   
   objNumber=objNumber+1;
   objData.prop='String';
   objData.list=[{getm(SavedStuff.Hndl,'MapProjection')};...
         num2cell(sortrows(maps('idlist')),2)];
   objData.index=1;
   text(-0.25,objNumber,'Map Projection', ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   text(0,objNumber,objData.list{objData.index}, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''axmod'')');
   
   objNumber=objNumber+1;
   objData.prop='Color';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};...
         num2cell(flipud(gray(10)),2)];
   objData.index=1;
   text(-0.25,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   line([0 1],objNumber*[1 1], ...
      'Color',objData.list{objData.index}, ...
      'LineWidth',4, ...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''axmod'')');
   
   objNumber=objNumber+1;
   TitleStr = namem(SavedStuff.Hndl);
   TitleStr = TitleStr(1:min(length(TitleStr),20));
   text(mean(axLims(1:2)),objNumber,TitleStr, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle');
   
   set(gca,'UserData',SavedStuff)
   
case 'mousedown',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   SavedStuff.ObjHndl=gcbo;
   SavedStuff.StartPt=get(gcf,'CurrentPoint');
   set(gca,'UserData',SavedStuff)
   
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''mousemove'',''axmod'')')
   set(gcf,'WindowButtonUpFcn','uimaptbx(''mouseup'',''axmod'')')
   
case 'mousemove',
   SavedStuff = get(gca,'UserData');
   currPt=get(gcf,'CurrentPoint');
   objData=get(SavedStuff.ObjHndl,'UserData');
   divisor=1.5/length(objData.list);
   
   indexOffset=floor(sqrt((currPt(1)-SavedStuff.StartPt(1))^2+ ...
      (currPt(2)-SavedStuff.StartPt(2))^2)/divisor);
   objIndex=max(1,min(length(objData.list),objData.index+indexOffset));
   set(SavedStuff.ObjHndl,objData.prop,objData.list{objIndex});
   
case 'mouseup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   
   if strcmp(objData.prop,'String')
      setm(SavedStuff.Hndl,'MapProjection',...
         get(SavedStuff.ObjHndl,objData.prop))
   else
      set(SavedStuff.Hndl,objData.prop,...
         get(SavedStuff.ObjHndl,objData.prop))
   end
   
case 'toggle',
   SavedStuff = get(gca,'UserData');
   if ~ishandle(SavedStuff.Hndl)
      uiwait(errordlg('Object has been deleted or replaced','Edit Tool Error','modal'))
      delete(get(gcbo,'Parent'))
      return
   end
   
   ScribeAxes = get(gcbo,'Parent');
   LabelStr = get(gcbo,'String');
   
   set(gcf,'CurrentAxes',SavedStuff.Hndl)
   switch LabelStr
   case 'Meridian Labels',     mlabel
   case 'Parallel Labels',     plabel
   case 'Frame',               framem
   case 'Grid',                gridm
   end
   set(gcf,'CurrentAxes',ScribeAxes)
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function figmod(action)

% Modify the axes based on a quick point-and-click interface
% Code is a modificaton of linemod from an Alpha version of Scribe 8/96.  EVB

if nargin==0
   if strcmp(get(gcf,'SelectionType'),'alt');   action='init';  end
end

%  Compute the Pixel and Font Scaling Factor

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


switch action
case 'init',
   SavedStuff.Hndl=gcbo;
   SavedStuff.Units = get(gcf,'Units');
   
   set(gcf,'Units','inches');
   currPt=get(gcf,'CurrentPoint');
   
   numProps=4;
   axes('Units','points', ...
      'Position',PixelFactor*72*[currPt(1) currPt(2) 2  1.1], ...
      'Color',0.8*[1 1 1], ...
      'XColor',[1 1 1],'YColor',[1 1 1], ...
      'Box','on', ...
      'DrawMode','fast', ...
      'XLim',[-2.5 2],'YLim',[-1 numProps+1], ...
      'XTick',[],'YTick',[], ...
      'SelectionHighlight','on',...
      'ButtonDownFcn','uimaptbx(''axesdown'',''clickNdrag'')');
   axLims=axis;
   
   text(mean(axLims(1:2)),0,'EXIT', ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''exit'',''clickNdrag'')');
   
   objNumber=1;
   objData.prop='Name';
   text(mean(axLims(1:2)),objNumber,objData.prop, ...
      'Color','blue', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle',...
      'ButtonDownFcn','uimaptbx(''name'',''figmod'')');
   
   objNumber=objNumber+1;
   objData.prop='Renderer';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};{'zbuffer';'painters'}];
   objData.index=1;
   text(-0.25,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   text(0,objNumber,objData.list{objData.index}, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''figmod'')');
   
   objNumber=objNumber+1;
   objData.prop='NumberTitle';
   objData.list=[{get(SavedStuff.Hndl,objData.prop)};{'on';'off'}];
   objData.index=1;
   text(-0.25,objNumber,objData.prop, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','right', ...
      'VerticalAlignment','middle');
   text(0,objNumber,objData.list{objData.index}, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'HorizontalAlignment','left', ...
      'VerticalAlignment','middle',...
      'UserData',objData, ...
      'EraseMode','background', ...
      'ButtonDownFcn','uimaptbx(''mousedown'',''figmod'')');
   
   objNumber=objNumber+1;
   TitleStr = namem(SavedStuff.Hndl);
   TitleStr = TitleStr(1:min(length(TitleStr),20));
   text(mean(axLims(1:2)),objNumber,TitleStr, ...
      'Color','black', ...
      'FontSize',FontScaling*10, ...
      'FontWeight','bold',...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle');
   
   set(gca,'UserData',SavedStuff)
   
case 'mousedown',
   SavedStuff = get(gca,'UserData');
   SavedStuff.ObjHndl=gcbo;
   SavedStuff.StartPt=get(gcf,'CurrentPoint');
   set(gca,'UserData',SavedStuff)
   
   set(gcf,'WindowButtonMotionFcn','uimaptbx(''mousemove'',''figmod'')')
   set(gcf,'WindowButtonUpFcn','uimaptbx(''mouseup'',''figmod'')')
   
case 'mousemove',
   SavedStuff = get(gca,'UserData');
   currPt=get(gcf,'CurrentPoint');
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   divisor=0.75/length(objData.list);
   
   indexOffset=floor(sqrt((currPt(1)-SavedStuff.StartPt(1))^2+ ...
      (currPt(2)-SavedStuff.StartPt(2))^2)/divisor);
   objIndex=max(1,min(length(objData.list),objData.index+indexOffset));
   set(SavedStuff.ObjHndl,'String',objData.list{objIndex});
   
case 'mouseup',
   SavedStuff = get(gca,'UserData');
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
   objData=get(SavedStuff.ObjHndl,'UserData');
   set(SavedStuff.Hndl,objData.prop,get(SavedStuff.ObjHndl,'String'))
   
case 'name',
   SavedStuff = get(gca,'UserData');
   prompt   = 'Edit the figure name:';
   titlestr = 'Figure Name';
   answer = {get(SavedStuff.Hndl,'Name')};
   
   while 1
      lasterr('')
      answer=inputdlg(prompt,titlestr,1,answer(1));
      
      if ~isempty(answer)
         eval(['set(SavedStuff.Hndl,''Name'',answer{1});'],...
            'uiwait(errordlg(lasterr,''Figure Name Error'',''modal''))')
         if isempty(lasterr);   break;   end
      else
         break
      end
   end
   
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function clickNdrag(action)

% Common functionality for all Click-N-Drag tools

%  Compute the Pixel Scaling Factor

PixelFactor = guifactm('pixels');


switch action
   
case 'exit'
   SavedStuff = get(gca,'UserData');
   set(gcf,'Units',SavedStuff.Units)
   if strcmp(get(SavedStuff.Hndl,'Type'),'text')
      set(SavedStuff.Hndl,'Units',SavedStuff.OrigTextUnits)
   end
   delete(gca);   refresh
   
case 'axesdown'
   if strcmp(get(gcf,'SelectionType'),'alt')
      SavedStuff = get(gca,'UserData');
      set(gcf,'Units',SavedStuff.Units)
      if strcmp(get(SavedStuff.Hndl,'Type'),'text')
         set(SavedStuff.Hndl,'Units',SavedStuff.OrigTextUnits)
      end
      delete(gca);   refresh
   elseif strcmp(get(gcf,'SelectionType'),'extend')
      SavedStuff = get(gca,'UserData');
      SavedStuff.StartPt=PixelFactor*72*get(gcf,'CurrentPoint');
      position = get(gca,'Position');
      SavedStuff.Offset=SavedStuff.StartPt-position([1 2]);
      set(gca,'UserData',SavedStuff,'Selected','on')
      set(gcf,'WindowButtonMotionFcn','uimaptbx(''axesmove'',''clickNdrag'')')
      set(gcf,'WindowButtonUpFcn','uimaptbx(''axesup'',''clickNdrag'')')
   end
   
case 'axesmove',
   SavedStuff = get(gca,'UserData');
   currPt=PixelFactor*72*get(gcf,'CurrentPoint');
   position = get(gca,'Position');
   position([1 2]) = currPt - SavedStuff.Offset;
   set(gca,'Position',position)
   
case 'axesup',
   SavedStuff = get(gca,'UserData');
   set(gca,'Selected','off')
   set(gcf,'WindowButtonMotionFcn','')
   set(gcf,'WindowButtonUpFcn','')
   
case 'hide',
   SavedStuff = get(gca,'UserData');
   set(gcbo,'String','Show','ButtonDownFcn','uimaptbx(''show'',''clickNdrag'')')
   if strcmp(namem(SavedStuff.Hndl),'Meridian') | ...
         strcmp(namem(SavedStuff.Hndl),'Parallel')
      set(handlem('Grid',get(SavedStuff.Hndl,'Parent')),'Visible','off')
   elseif strcmp(namem(SavedStuff.Hndl),'MLabel') | ...
         strcmp(namem(SavedStuff.Hndl),'PLabel')
      set(handlem('MLabel',get(SavedStuff.Hndl,'Parent')),'Visible','off')
      set(handlem('PLabel',get(SavedStuff.Hndl,'Parent')),'Visible','off')
   else
      set(SavedStuff.Hndl,'Visible','off')
   end
   
case 'show',
   SavedStuff = get(gca,'UserData');
   set(gcbo,'String','Hide','ButtonDownFcn','uimaptbx(''hide'',''clickNdrag'')')
   if strcmp(namem(SavedStuff.Hndl),'Meridian') | ...
         strcmp(namem(SavedStuff.Hndl),'Parallel')
      set(handlem('Grid',get(SavedStuff.Hndl,'Parent')),'Visible','on')
   elseif strcmp(namem(SavedStuff.Hndl),'MLabel') | ...
         strcmp(namem(SavedStuff.Hndl),'PLabel')
      set(handlem('MLabel',get(SavedStuff.Hndl,'Parent')),'Visible','on')
      set(handlem('PLabel',get(SavedStuff.Hndl,'Parent')),'Visible','on')
   else
      set(SavedStuff.Hndl,'Visible','on')
   end
   
case 'delete',
   SavedStuff = get(gca,'UserData');
   Btn = questdlg('Are You Sure','Confirm Deletion','Yes','No','No');
   if strcmp(Btn,'Yes')
      delete(gca)
      if ishandle(SavedStuff.Hndl)
          if strcmp(namem(SavedStuff.Hndl),'Meridian') | ...
                strcmp(namem(SavedStuff.Hndl),'Parallel')
             mstruct = get(get(SavedStuff.Hndl,'Parent'),'UserData');
             mstruct.grid = 'off';
             set(get(SavedStuff.Hndl,'Parent'),'UserData',mstruct)
             delete(handlem('Grid',get(SavedStuff.Hndl,'Parent')))
          elseif strcmp(namem(SavedStuff.Hndl),'MLabel') | ...
                strcmp(namem(SavedStuff.Hndl),'PLabel')
             mstruct = get(get(SavedStuff.Hndl,'Parent'),'UserData');
             mstruct.parallellabel = 'off';
             mstruct.meridianlabel = 'off';
             set(get(SavedStuff.Hndl,'Parent'),'UserData',mstruct)
             hndl1 = findobj(get(SavedStuff.Hndl,'Parent'),...
                'Type','text','Tag','PLabel');
             hndl2 = findobj(get(SavedStuff.Hndl,'Parent'),...
                'Type','text','Tag','MLabel');
             delete([hndl1;hndl2])
          elseif strcmp(namem(SavedStuff.Hndl),'Frame')
             mstruct = get(get(SavedStuff.Hndl,'Parent'),'UserData');
             mstruct.frame = 'off';
             set(get(SavedStuff.Hndl,'Parent'),'UserData',mstruct)
             delete(SavedStuff.Hndl)
          else
             delete(SavedStuff.Hndl)
          end
      end
      refresh
   end
end



%*************************************************************************
%*************************************************************************
%*************************************************************************

