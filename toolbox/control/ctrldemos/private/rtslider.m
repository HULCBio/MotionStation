function rtslider(varargin)
%RTSLIDER  Create a real-time slider bar

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/10 06:42:03 $

%---Default properties
 p = struct(...
    'Parent',[],...
    'Units','normalized',...
    'Position',[0 0 .5 .1],...
    'Range',[0 1],...
    'ShowRange',1,...
    'Value',.5,...
    'Marker','s',...
    'MarkerSize',8,...
    'MarkerColor','k',...
    'LineWidth',2,...
    'LineStyle','-',...
    'Color',[.5 .5 .5],...
    'FontSize',[],...
    'FontWeight','normal',...
    'Label','',...
    'LabelFontSize',[],...
    'LabelFontWeight','bold',...
    'EditBoxHeight',.05,...
    'ShowEditBox',1,...
    'ButtonDownFcn','',...
    'ButtonUpFcn','',...
    'Scale','linear',...
    'Tag','',...
    'Callback','');
 plist = fieldnames(p);

%---Merge user-specified properties
 for i=1:2:nargin-1
    Property = pnmatch(varargin{i},plist);
    Value = varargin{i+1};
    p.(Property) = Value;
 end
 if isempty(p.Parent), p.Parent = gcf; end
 if isempty(p.FontSize), p.FontSize = get(p.Parent,'DefaultTextFontSize'); end
 if isempty(p.LabelFontSize), p.LabelFontSize = p.FontSize+2; end   

%---Slider axes
 ax = axes('Parent',p.Parent,'Units',p.Units,'Position',p.Position,'XLim',p.Range,'YLim',[-1 1],'DrawMode','fast','Visible','off','XScale',p.Scale,'Tag',p.Tag);

%---Slider lines
 line('Parent',ax,'Color',p.Color,'LineWidth',p.LineWidth,'Clipping','off',...
    'XData',[p.Range NaN p.Range(1) p.Range(1) NaN p.Range(2) p.Range(2)],'YData',[0 0 NaN -1 1 NaN -1 1]);
 sl = line('Parent',ax,'XData',p.Value,'YData',0,'Color',p.MarkerColor,'MarkerFaceColor',p.MarkerColor,...
    'Marker',p.Marker,'MarkerSize',p.MarkerSize,'Tag','slider');

%---Slider text
 if p.ShowRange
    text('Parent',ax,'String',num2str(p.Range(1)),'Units','data','Position',[p.Range(1) -1.5],...
       'HorizontalAlignment','center','VerticalAlignment','top','FontSize',p.FontSize,'FontWeight',p.FontWeight,'Clipping','off');
    text('Parent',ax,'String',num2str(p.Range(2)),'Units','data','Position',[p.Range(2) -1.5],...
       'HorizontalAlignment','center','VerticalAlignment','top','FontSize',p.FontSize,'FontWeight',p.FontWeight,'Clipping','off');
 end
 text('Parent',ax,'String',p.Label,'Units','normalized','Position',[-.1 0.5],'HorizontalAlignment','right',...
    'VerticalAlignment','middle','FontSize',p.LabelFontSize,'FontWeight',p.LabelFontWeight,'Clipping','off');

%---Slider uicontrol (edit box)
 pos = [p.Position(1)+0.25*p.Position(3) p.Position(2)-p.EditBoxHeight p.Position(3)/2 p.EditBoxHeight];
 u = uicontrol('Parent',p.Parent,'Style','edit','Units',p.Units,'Position',pos,...
    'Background',[1 1 1],'String',num2str(p.Value),'Value',p.Value,'FontSize',p.FontSize,'Visible','off','Tag',p.Tag);
 if p.ShowEditBox
    e = get(u,'Extent');
    if ispc, e(4)=1.1*e(4); end
    set(u,'Position',[pos(1) p.Position(2)-e(4) pos(3) e(4)],'Visible','on');
 end

%---Install callbacks/userdata
 ud = struct(...
    'Slider',sl,...
    'EditBox',u,...
    'Axes',ax,...
    'Figure',p.Parent,...
    'ButtonDownFcn',{p.ButtonDownFcn},...
    'ButtonUpFcn',{p.ButtonUpFcn},...
    'Callback',{p.Callback});
 set(u, 'UserData',ud,'Callback',@localEditBoxCallback);
 set(sl,'UserData',ud,'ButtonDownFcn',@localSliderCallback);

%---Set WindowButtonMotionFcn
 if isempty(get(p.Parent,'WindowButtonMotionFcn'))
    set(p.Parent,'WindowButtonMotionFcn',@localHover);
 end

%%%%%%%%%%%%%%
% localHover %
%%%%%%%%%%%%%%
function localHover(eventSrc,eventData)
 %---WindowButtonMotionFcn
  obj = hittest(eventSrc);
  switch lower(get(obj,'tag'))
  case 'slider'
     setptr(eventSrc,'hand');
  otherwise
     setptr(eventSrc,'arrow');
  end

%%%%%%%%%%%%%%%%%%%%%%%%
% localEditBoxCallback %
%%%%%%%%%%%%%%%%%%%%%%%%
function localEditBoxCallback(eventSrc,eventData)
 %---Editbox callback
  ud = get(eventSrc,'UserData'); 
  val = localEvalNum(get(ud.EditBox,'String'),get(ud.Axes,'XLim'));
  if isempty(val)
     val = get(ud.EditBox,'Value');
  end
  set(ud.Slider,'XData',val);
  set(ud.EditBox,'String',num2str(val),'Value',val);  
  localEvalFcn(ud.Callback,ud.Slider,val);

%%%%%%%%%%%%%%%%%%%%%%%
% localSliderCallback %
%%%%%%%%%%%%%%%%%%%%%%%
function localSliderCallback(eventSrc,eventData,action)
 %---Slider callback
  persistent ud SAVEPROPS SAVEVALS;
  if nargin==2
     %---Get slider userdata
      ud = get(eventSrc,'UserData');
     %---Save original figure properties which we may alter
      SAVEPROPS = {'WindowButtonMotionFcn','WindowButtonUpFcn','Pointer','PointerShapeCData','PointerShapeHotSpot'};
      SAVEVALS = get(ud.Figure,SAVEPROPS);
     %---Activate drag
      set(ud.Figure,'WindowButtonMotionFcn',{@localSliderCallback,'drag'},'WindowButtonUpFcn',{@localSliderCallback,'end'});
      setptr(ud.Figure,'closedhand');
      set(ud.Slider,'EraseMode','xor');
     %---Evaluate user ButtonDownFcn
      localEvalFcn(ud.ButtonDownFcn,ud.Figure,[]);
  elseif strcmp(action,'drag')
     %---Set new slider value
      cp = get(ud.Axes,'CurrentPoint');
      lim = get(ud.Axes,'XLim');
      val = min(max(cp(1,1),lim(1)),lim(2));
      set(ud.Slider,'XData',val);
      set(ud.EditBox,'String',num2str(val),'Value',val);
     %---Evaluate user Callback
      localEvalFcn(ud.Callback,ud.Slider,val);
  else
     %---Evaluate user ButtonUpFcn
      localEvalFcn(ud.ButtonUpFcn,ud.Figure,[]);
     %---Restore slider EraseMode
      set(ud.Slider,'EraseMode','normal');
     %---Restore altered figure properties
      set(ud.Figure,SAVEPROPS,SAVEVALS);
     %---Evaluate WindowButtonMotionFcn
      localEvalFcn(SAVEVALS{1},ud.Figure,[]);
  end

%%%%%%%%%%%%%%%%
% localEvalNum %
%%%%%%%%%%%%%%%%
function val = localEvalNum(val,lims)
 %---Evaluate string val
  if ~isempty(val)
     val = evalin('base',val,'[]');
     if ~isnumeric(val) | ~(isreal(val) & isfinite(val)) | length(val)~=1 | val<lims(1) | val>lims(2)
        val = [];
     end
  end

%%%%%%%%%%%%%%%%
% localEvalFcn %
%%%%%%%%%%%%%%%%
function localEvalFcn(fcn,eventSrc,eventData)
 %---Evaluate fcn
  switch class(fcn)
  case 'function_handle'
     feval(fcn,eventSrc,eventData);
  case 'cell'
     feval(fcn{1},eventSrc,eventData,fcn{2:end});
  case 'char'
     eval(fcn);
  end
