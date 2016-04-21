function pdertdlg(action)
%PDERTDLG Displays and manages the rotate dialog box.
%       If the  rotation center option is used, [xc, yc] is
%       found in the Rotation Center edit box.
%
%       See also: PDETOOL

%       User data returned in figure's UserData:
%       A vector [ui(1) ui(2) ui(3) ui(4) ui(5)] of uicontrol handles:
%       ui(1) = Rotation header text handle
%       ui(2) = Rotation angle edit box handle
%       ui(3) = Rotation center text handle
%       ui(4) = Rotation center edit box handle
%       ui(5) = Use center-of-mass checkbox handle

%       Magnus Ringh 11-16-94, MR 9-08-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/18 03:11:52 $

if nargin<1,
  action='initialize';
end

%
% case: initialize dialog

if strcmp(action,'initialize')

  pdeinfo('Enter counter clock-wise rotation (degrees) of selected objects.');

  % Check if figure exist; if first time through, create it.
  DlgName = 'Rotate';
  [flag,fig]=figflag(DlgName);

  rotate_fig=findobj(get(0,'Children'),'flat','Tag','PDERotateFig');

  if ~flag,

    PromptString = str2mat('Rotation (degrees):                        ',...
        'Rotation center:');
    DefString=str2mat(num2str(0),' ');
    EnStr=str2mat('on','off');

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
        +[2*(mEdgeToFrame+mFrameToText)+BWH(1)+mFrameToText ...
        mLineHeight+BWH(2)+Voff];
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
        'Tag','PDERotateFig',...
        'Color',DefUIBgColor,...
        'Visible','off');

    % Make the 2 frame uicontrols
    UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
    uicontrol(fig,'Style','frame','Position',UIPos);
    UIPos = [UIPos(1:3)+...
            [0 UIPos(4)+mEdgeToFrame 0] FigWH(2)-UIPos(4)-2*mEdgeToFrame];
    uicontrol(fig,'Style','frame','Position',UIPos);

    % Make the text, edit, and check uicontrol(s)
    UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
            FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
    ud = zeros(TextSize(1),3);

    for i=1:TextSize(1),
      UIPos = UIPos - [0 BWH(2) 0 0];
      ui(1,i)=uicontrol(fig,'Style','text',...
          'String',PromptString(i,:),...
          'Position',UIPos,'Enable',EnStr(i,:),...
          'HorizontalAlignment','left');
      if i==2,
        CenterPos = FigWH(1)-2*BWH(1)-mEdgeToFrame-mFrameToText;
        CenterStr='Use center-of-mass';
        h=uicontrol(fig,'Style','check','String',CenterStr,...
            'Value',1,'Position',[CenterPos UIPos(2) 2*BWH(1) BWH(2)],...
            'HorizontalAlignment','left',...
            'CallBack','pdertdlg(''cog_cb'')');
      end
      UIPos = UIPos - [0 BWH(2)+Voff 0 0];
      ui(2,i)=uicontrol(fig,'Style','edit',...
          'String',DefString(i,:),'UserData',DefString(i,:),...
          'BackgroundColor','white','Enable',EnStr(i,:),...
          'Position',UIPos,'HorizontalAlignment','left', ...
          'Callback','');
      UIPos = UIPos -[0 Voff 0 0];
    end

    % Make the pushbuttons
    Hspace = (FigWH(1)-2*BWH(1))/3;
    uicontrol(fig,'Style','push','String','OK',...
        'Callback','pdertdlg(''ok'')',...
        'Position',[Hspace mLineHeight/2 BWH]);
    uicontrol(fig,'Style','push','String','Cancel',...
        'Callback','pdertdlg(''cancel'')',...
        'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

    % Finally, make all the uicontrols normalized and the figure visible
    set(get(fig,'Children'),'Unit','norm');
    ui=[ui(1,1) ui(2,1) ui(1,2) ui(2,2) h];
    set(fig,'Visible','on','UserData',ui)

  else

    set(fig,'Visible','on');

  end

%
% case: center-of-mass button feedback

elseif strcmp(action,'cog_cb')

  ui=get(gcf,'UserData');
  cg=get(ui(5),'Value');
  if cg,                                % use center-of-mass
    set(ui(3:4),'Enable','off')
  else
    set(ui(3:4),'Enable','on')
  end

%
% case: ok

elseif strcmp(action,'ok')

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  fig=gcf;
  ui=get(gcf,'UserData');
  ang=str2num(get(ui(2),'String'));
  if length(ang)~=1,
    pdetool('error','Angle must be a scalar.')
    set(ui(2),'String',get(ui(2),'UserData'))
    return;
  end
  usecg=get(ui(5),'Value');
  if ~usecg,                            % use user entry for rotation
    rot_ctr=str2num(get(ui(4),'String'));
    [n,m]=size(rot_ctr);
    if n*m~=2,
      pdetool('error','Entry must be a vector [xc yc].')
      set(ui(4),'String',get(ui(4),'UserData'))
      return;
    else
      set(ui(2),'UserData',get(ui(2),'String'))
      set(ui(4),'UserData',get(ui(4),'String'))
    end
  end

  set(fig,'Visible','off')
  set(0,'CurrentFigure',pde_fig)
  set(pde_fig,'Pointer','watch');
  drawnow

  pde_circ=1; pde_poly=2; pde_rect=3; pde_ellip=4;

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  selected=findobj(get(ax,'Children'),'flat','Tag','PDELblSel',...
      'Visible','on');
  sel_col=[];

  hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  pdegd=get(hndl,'UserData');
  oldpdegd=pdegd;

  if ~isempty(selected),
    % rotate and update PDEGD's geometry description:

    for i=1:length(selected)
      column=get(selected(i),'UserData');
      sel_col=[sel_col column];
      type=pdegd(1,column);
      if type==pde_circ && ~usecg,
        % circle: (not center-of-mass case only)
        x = pdegd(2,column)-rot_ctr(1);
        y = pdegd(3,column)-rot_ctr(2);
        z=0;
        phi = pi*0/180;
        theta = pi*90/180;
        u = [cos(theta)*cos(phi); cos(theta)*sin(phi); sin(theta)];
        newxyz = [x, y, z];
        alph = (360-ang)*pi/180;
        cosa = cos(alph);
        sina = sin(alph);
        vera = 1 - cosa;
        x = u(1);
        y = u(2);
        z = u(3);
        rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
            x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
            x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera];
        newxyz = newxyz*rot;
        % update PDEGD after ''global'' rotation
        pdegd(2,column)=rot_ctr(1)+newxyz(1);
        pdegd(3,column)=rot_ctr(2)+newxyz(2);
      elseif type==pde_ellip
        % ellipse:
        if ~usecg,
          rc=[rot_ctr 0];
        else
          rc=[pdegd(2,column) pdegd(3,column) 0];
        end
        x = pdegd(2,column)-rc(1);
        y = pdegd(3,column)-rc(2);
        z=0;
        phi = pi*0/180;
        theta = pi*90/180;
        u = [cos(theta)*cos(phi); cos(theta)*sin(phi); sin(theta)];
        newxyz = [x, y, z];
        alph = (360-ang)*pi/180;
        cosa = cos(alph);
        sina = sin(alph);
        vera = 1 - cosa;
        x = u(1);
        y = u(2);
        z = u(3);
        rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
            x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
            x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera];
        newxyz = newxyz*rot;
        % update PDEGD after ''global'' rotation
        pdegd(2,column)=rc(1)+newxyz(1);
        pdegd(3,column)=rc(2)+newxyz(2);
        % update PDEGD with rotation angle (in radians):
        pdegd(6,column)=pdegd(6,column)+ang*pi/180;

      elseif type==pde_poly || type==pde_rect
        % polygons and rectangles:
        nv=pdegd(2,column);
        xm=mean(pdegd(3:nv+2,column));
        ym=mean(pdegd(nv+3:2*nv+2,column));
        if usecg
          rc=[xm ym 0];
        else
          rc=[rot_ctr 0];
        end
        x=xm-rc(1);
        y=ym-rc(2);
        z=0;
        phi = pi*0/180;
        theta = pi*90/180;
        u = [cos(theta)*cos(phi); cos(theta)*sin(phi); sin(theta)];
        newxyz = [pdegd(3:nv+2,column)-rc(1),...
                  pdegd(nv+3:2*nv+2,column)-rc(2),zeros(nv,1)];
        alph = (360-ang)*pi/180;
        cosa = cos(alph);
        sina = sin(alph);
        vera = 1 - cosa;
        x = u(1);
        y = u(2);
        z = u(3);
        rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
            x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
            x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera];
        newxyz = newxyz*rot;
        % update PDEGD after ''global'' rotation
        pdegd(1,column)=2; % Hack: make rotated rectangle into polygon.
        pdegd(3:nv+2,column)=newxyz(:,1)+rc(1);
        pdegd(nv+3:2*nv+2,column)=newxyz(:,2)+rc(2);
      end
    end
  end

  set(pde_fig,'CurrentAxes',ax)

  % Check geometry before proceeding:
  xlim=get(ax,'Xlim');
  ylim=get(ax,'Ylim');
  stat=csgchk(pdegd,diff(xlim),diff(ylim));
  if any(stat==2),

    % Rotation resulted in non-unique objects:
    % Restore selection indication and alert user

    pdeframe(oldpdegd,sel_col)

    pdetool('error','  Rotation resulted in non-unique circle/ellipse.');

  else

    set(hndl,'UserData',pdegd);

    % First call DECSG to decompose geometry;

    [dl1,bt1,pdedl,bt,msb]=decsg(pdegd);

    pdepatch(pdedl,bt,msb);
    set(findobj(get(pde_fig,'Children'),'flat',...
        'Tag','PDEBoundMenu'),'UserData',pdedl);

    setappdata(pde_fig,'dl1',dl1)
    setappdata(pde_fig,'bt1',bt1)

    pdeframe(pdegd,sel_col)

  end

  set(pde_fig,'Pointer','arrow');
  drawnow

  h=[];
  for i=sel_col,
    h=[h; findobj(get(ax,'Children'),'flat','Tag','PDELabel','UserData',i)];
  end
  set(h,'Tag','PDELblSel');

  pdeinfo

%
% case: cancel

elseif strcmp(action,'cancel')

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

  set(gcf,'Visible','off')
  set(0,'CurrentFigure',pde_fig)

  pdeinfo

end

