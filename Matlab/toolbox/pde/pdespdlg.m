function pdespdlg(action)
%PDESPDLG creates and manages the grid spacing dialog box.
%       PDESPDLG is not stand-alone but is called from PDETOOL.

%       Magnus Ringh 11-09-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/18 03:12:01 $

if nargin==0,
  action='Grid Spacing';
end

% Check if figure is already on screen
if  figflag(action),
  % No need to create new dialog
  return

elseif strcmp(action,'EditCallback'),
  % Check to make sure spacings are admissible
  Edit = gco;
  EditStr = get(Edit,'String');
  [m,error_str]=matqparse(EditStr);
  error_str=strrep(error_str,'matqparse: ','');
  s=[];
  if isempty(error_str),
    n=size(m,1);
    for i=1:n,
      try
          s=m(i,:);
      catch
          s= '''foobar''';
      end
      if ischar(s), break; end
    end
  end
  if ischar(s),
    error_str = 'Cannot evaluate edit field input.';
  end
  if isempty(error_str),
    set(Edit,'UserData',EditStr)
  else
    pdetool('error',error_str);
    set(Edit,'String',get(Edit,'UserData'))
  end
  return

elseif strcmp(action,'AutoCallback'),

  h=gco;
  ud=get(gcf,'UserData');
  if get(h,'Value')==1,
    j=str2double(get(h,'Tag'));
    set(ud(j:j+1,2),'Enable','off')
  else
    j=str2double(get(h,'Tag'));
    set(ud(j:j+1,2),'Enable','on')
  end
  return

elseif strcmp(action,'ApplyCallback'),

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  ud=get(gcf,'UserData');
  for i=1:2:3,
    space=[];
    if get(ud(i,1),'Value'),
      % AutoCheckbox is checked, so set ax's TickMode(s) to auto
      if i==1,
        set(ax,'XTickMode','auto')
        [xstr,ystr]=pdet2str(ax,[],[]);
        set(ud(i,2),'Enable','off','String',xstr)
        set(ud(i+1,2),'Enable','off','String','')
        setappdata(ax,'extraspacex','')
      elseif i==3,
        set(ax,'YTickMode','auto')
        [xstr,ystr]=pdet2str(ax,[],[]);
        set(ud(i,2),'Enable','off','String',ystr)
        set(ud(i+1,2),'Enable','off','String','')
        setappdata(ax,'extraspacey','')
      end
    else
      s=get(ud(i,2),'UserData');
      spacestr=matqparse(s);
      n=size(spacestr,1);
      for j=1:n,
        space=[space eval(spacestr(j,:))];
      end
      xs=get(ud(i+1,2),'UserData');
      spacestr=matqparse(xs);
      n=size(spacestr,1);
      for j=1:n,
        space=[space eval(spacestr(j,:))];
      end
      % Make sure that they are unique, and sort them
      space = unique(space);

      % Set spaces and save extra spaces
      if i==1,                          % x-axis spacing = 1
        set(ax,'XTick',space)
        setappdata(ax,'extraspacex',xs)
      elseif i==3,                      % y-axis spacing = 3
        set(ax,'YTick',space)
        setappdata(ax,'extraspacey',xs)
      end

    end
  end
  return

end

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

DlgName = 'Grid Spacing';
PromptString = str2mat('X-axis linear spacing:',...
    'X-axis extra ticks:','Y-axis linear spacing:','Y-axis extra ticks:');

if ~strcmp(get(ax,'XTickMode'),'auto'),
  extrax = getappdata(ax,'extraspacex');
else
  extrax=[];
end
if ~strcmp(get(ax,'YTickMode'),'auto'),
  extray = getappdata(ax,'extraspacey');
else
  extray=[];
end
[xstr,ystr]=pdet2str(ax,extrax,extray);
EditStr=str2mat(xstr,extrax,ystr,extray);
AxesHandles=[ax NaN ax NaN ax NaN ax];
TextSize = size(PromptString);

% Get layout parameters
layout
mLineHeight = mLineHeight+8;
BWH = [mStdButtonWidth mStdButtonHeight+3];

% Define default position
ScreenUnits = get(0,'Units');
set(0,'Unit','pixels');
ScreenPos = get(0,'ScreenSize');
set(0,'Unit',ScreenUnits);
mCharacterWidth = 7;
Voff = 5;
FigWH = fliplr(TextSize).*[mCharacterWidth 2*(BWH(2)+Voff)] ...
    +[2*(mEdgeToFrame+mFrameToText)+BWH(1)+mFrameToText mLineHeight+BWH(2)+Voff];
MinFigW = 2*(BWH(1) +mFrameToText + mEdgeToFrame);
FigWH(1) = max([FigWH(1) MinFigW]);
FigWH = min(FigWH,ScreenPos(3:4)-50);
Position = [(ScreenPos(3:4)-FigWH)/2 FigWH];

% Make the figure
DefUIBgColor = get(0,'DefaultUIControlBackgroundColor');
fig = figure('NumberTitle','off',...
    'Name',DlgName,...
    'Units','pixels',...
    'Position',Position,...
    'IntegerHandle','off',...
    'HandleVisibility','callback',...
    'MenuBar','none',...
    'Colormap',zeros(1,3),...
    'Color',DefUIBgColor,...
    'Visible','off',...
    'Tag','PDESpaceDlg');

% Make the 2 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] FigWH(2)-UIPos(4)-2*mEdgeToFrame];
uicontrol(fig,'Style','frame','Position',UIPos);

% Make the text, and edit check uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
ud = zeros(TextSize(1),2);
AxesHandles = [NaN; AxesHandles(:); NaN];
nans = find(isnan(AxesHandles));
for i=1:TextSize(1),
  UIPos = UIPos - [0 BWH(2) 0 0];
  ax = AxesHandles(nans(i)+1:nans(i+1)-1);
  uicontrol(fig,'Style','text','String',PromptString(i,:),...
      'Position',UIPos,'HorizontalAlignment','left','UserData',ax);
  if i==1 || i==2,
    val=strcmp(get(ax,'XTickMode'),'auto');
    if val, enbl='off'; else enbl='on'; end
  elseif i==3 || i==4,
    val=strcmp(get(ax,'YTickMode'),'auto');
    if val, enbl='off'; else enbl='on'; end
  end
  if i==1 || i==3,
    AutoX = FigWH(1)-BWH(1)-mEdgeToFrame-mFrameToText;
    ud(i,1)=uicontrol(fig,'Style','check','String','Auto','Value',val,...
        'Position',[AutoX UIPos(2) BWH],'HorizontalAlignment','left',...
        'Tag',int2str(i),'CallBack','pdespdlg(''AutoCallback'')');
  end
  UIPos = UIPos - [0 BWH(2)+Voff 0 0];
  ud(i,2) = uicontrol(fig,'Style','edit','String',deblank(EditStr(i,:)),...
      'BackgroundColor','white','Enable',enbl,...
      'Position',UIPos,'HorizontalAlignment','left', ...
      'UserData',deblank(EditStr(i,:)),...
      'Callback','pdespdlg(''EditCallback'')');
  UIPos = UIPos -[0 Voff 0 0];
end

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
ApplyFcn = 'pdespdlg(''ApplyCallback'')';
uicontrol(fig,'Style','push','String','Apply','Callback',ApplyFcn, ...
    'Position',[Hspace mLineHeight/2 BWH]);

uicontrol(fig,'Style','push','String','Done',...
          'Callback','delete(gcf); drawnow', ...
          'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

% Finally, make all the uicontrols normalized and the figure visible
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',ud)
drawnow

% end pdespdlg

