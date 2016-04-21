function pdeobdlg(action,flag)
%PDEOBDLG Manages the object dialog box for the PDE Toolbox GUI.
%
%       Called from PDETOOL when double-clicking on (selected)
%       objects.
%
%       See also: PDETOOL

%       Magnus G. Ringh 11-15-94, MR 10-12-95
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.12.4.1 $  $Date: 2003/11/18 03:11:36 $

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

%
% case: open object dialog box for exact adjustment of object's
%       size, position, and name

if strcmp(action,'start')

  DlgName='Object Dialog';
  % If an object dialog box already exists, close it:
  [fflag,figs]=figflag(DlgName,1);
  if fflag,
    close(figs)
  end

  % flag contains array of columns in PDEGD for the objects
  % double-clicked on

  pdeinfo('Adjust size and/or position of selected object(s), and rename object if desired.');

  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');

  DefUIBgColor = get(0,'DefaultUIControlBackgroundColor');
  wtcol=ones(1,3);

  if length(flag)==1,
    % case: one basic object selected

    obj_type=pdegd(1,flag);

    name=getappdata(pde_fig,'objnames');
    name=deblank(char(name(:,flag)'));

    StyleStr=['Text';'Edit';'Edit';'Edit';'Edit'];

    ColMtx=[DefUIBgColor;wtcol;wtcol;wtcol;wtcol];
    EnableStr=['on';'on';'on';'on';'on'];
    if obj_type==1,
      type='Circle';
      string1='X-center:';
      string2='Y-center:';
      string3='Radius:';
      string4=sprintf('%.17g',pdegd(2,flag));
      string5=sprintf('%.17g',pdegd(3,flag));
      string6=sprintf('%.17g',pdegd(4,flag));
      PromptStr=str2mat('Object type:',string1,string2,string3,'Name:');
      EditStr=str2mat(type,string4,string5,string6,name);
    elseif obj_type==2,
      type='Polygon';
      string1='Coordinates:';
      string2='X-value edit box:';
      string3='Y-value edit box:';
      n=pdegd(2,flag);
      string4='';
      for i=1:n,
        string4=[string4, sprintf(' %.4g, %.4g|',pdegd(3+i-1,flag),...
          pdegd(3+n+i-1,flag))];
      end
      string4=string4(1:length(string4)-1);
      string5=sprintf('%.17g',pdegd(3,flag));
      string6=sprintf('%.17g',pdegd(3+n,flag));
      PromptStr=str2mat('Object type:',string1,string2,string3,'Name:');
      EditStr=str2mat(type,string4,string5,string6,name);
      StyleStr=str2mat('Text','Popup','Edit','Edit','Edit');
      ColMtx=[DefUIBgColor;DefUIBgColor;wtcol;wtcol;wtcol];
    elseif obj_type==3,
      type='Rectangle';
      string1='Left:';
      string2='Bottom:';
      string3='Width:';
      string4='Height:';
      string5=sprintf('%.17g',min(pdegd(3,flag),pdegd(4,flag)));
      string6=sprintf('%.17g',min(pdegd(7,flag),pdegd(9,flag)));
      string7=sprintf('%.17g',abs(pdegd(4,flag)-pdegd(3,flag)));
      string8=sprintf('%.17g',abs(pdegd(9,flag)-pdegd(7,flag)));
      PromptStr=...
        str2mat('Object type:',string1,string2,string3,string4,'Name:');
      EditStr=str2mat(type,string5,string6,string7,string8,name);
      EnableStr=['on';'on';'on';'on';'on';'on'];
      StyleStr=['Text';'Edit';'Edit';'Edit';'Edit';'Edit'];
      ColMtx=[DefUIBgColor;wtcol;wtcol;wtcol;wtcol;wtcol];
    elseif obj_type==4,
      type='Ellipse';
      string1='X-center:';
      string2='Y-center:';
      string3='A-semiaxes:';
      string4='B-semiaxes:';
      string5='Rotation (degrees):';
      string6=sprintf('%.17g',pdegd(2,flag));
      string7=sprintf('%.17g',pdegd(3,flag));
      string8=sprintf('%.17g',pdegd(4,flag));
      string9=sprintf('%.17g',pdegd(5,flag));
      string10=sprintf('%.17g',180*pdegd(6,flag)/pi);
      EnableStr=['on';'on';'on';'on';'on';'on';'on'];
      PromptStr=...
       str2mat('Object type:',string1,string2,string3,string4,string5,'Name:');
      EditStr=str2mat(type,string6,string7,string8,string9,string10,name);
      StyleStr=str2mat('Text','Edit','Edit','Edit','Edit','Edit','Edit');
      ColMtx=[DefUIBgColor;wtcol;wtcol;wtcol;wtcol;wtcol;wtcol];
    end

  else
    obj_type=0;
    % Multiple objects selected
    type = 'Generic';
    string1='X displacement:';
    string2='Y displacement:';
    string3='0.0';
    string4='0.0';
    name='';
    StyleStr=str2mat('Text','Edit','Edit','Edit');
    EnableStr=str2mat('on','on','on','off');
    PromptStr=str2mat('Object type:',string1,string2,'Name:');
    EditStr=str2mat(type,string3,string4,name);
    ColMtx=[DefUIBgColor;wtcol;wtcol;wtcol];
  end

  text1=20; text2=30;
  TextSize=[size(PromptStr,1), text1+text2];
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
  FigWH = fliplr(TextSize).*[mCharacterWidth (BWH(2)+Voff)] ...
        +[2*(mEdgeToFrame+mFrameToText)+BWH(1)+mFrameToText mLineHeight+BWH(2)+Voff];
  MinFigW = 2*(BWH(1) +mFrameToText + mEdgeToFrame);
  FigWH(1) = max([FigWH(1) MinFigW]);
  FigWH = min(FigWH,ScreenPos(3:4)-50);
  Position = [(ScreenPos(3:4)-FigWH)/2 FigWH];

  % Make the figure
  ObjTag='PDEObjDlgFig';
  obj_fig = figure('NumberTitle','off',...
                   'Name',DlgName,...
                   'Position',Position,...
                   'IntegerHandle','off',...
                   'HandleVisibility','callback',...
                   'MenuBar','none',...
                   'Colormap',zeros(1,3),...
                   'Color',DefUIBgColor,...
                   'Tag',ObjTag,...
                   'Visible','off');

  % Make the 2 frame uicontrols
  UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
  uicontrol(obj_fig,'Style','frame','Position',UIPos);
  UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] FigWH(2)-UIPos(4)-2*mEdgeToFrame];
  frameh=uicontrol(obj_fig,'Style','frame',...
    'Position',UIPos,'UserData',pdegd(:,flag));

  % Make the text, and edit check uicontrol(s)
  UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
    FigWH(1)*text1/(text1+text2)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
  ud = zeros(TextSize(1),2);
  for i=1:TextSize(1),
    UIPos = UIPos - [0 BWH(2) 0 0];
    EdX = FigWH(1)*text1/(text1+text2)-mEdgeToFrame-mFrameToText;
    EdX2 = FigWH(1)*text2/(text1+text2)-mEdgeToFrame-mFrameToText;
    ud(i,1)=uicontrol(obj_fig,'Style','text',...
      'String',PromptStr(i,:),'Enable',EnableStr(i,:),...
      'Position',UIPos,'HorizontalAlignment','left');
    ud(i,2) = uicontrol(obj_fig,'Style',StyleStr(i,:),...
      'Enable',EnableStr(i,:),...
      'String',deblank(EditStr(i,:)),'BackgroundColor',ColMtx(i,:),...
      'UserData',EditStr(i,:),...
      'Position',[EdX UIPos(2) EdX2 BWH(2)],'Tag',int2str(i),...
      'HorizontalAlignment','left','CallBack','pdeobdlg(''edit_cb'')');
    UIPos = UIPos - [0 Voff 0 0];
  end

  % Make the pushbuttons
  Hspace = (FigWH(1)-2*BWH(1))/3;
  OKFcn = 'pdeobdlg(''OK'')';
  uicontrol(obj_fig,'Style','push','String','OK','Callback',OKFcn, ...
    'Position',[Hspace mLineHeight/2 BWH]);
  uicontrol(obj_fig,'Style','push','String','Cancel',...
    'Callback','pdeobdlg(''cancel'')', ...
    'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

  % Finally, make all the uicontrols normalized and the figure visible
  set(get(obj_fig,'Children'),'Unit','normalized');
  set(obj_fig,'Visible','on','UserData',[obj_type; frameh; ud(:,2); flag(:)])

  drawnow

%
% case: edit callback - check validity of entry:

elseif strcmp(action,'edit_cb')

  h=gco;
  obj_fig=gcf;

  ui_hndls=get(obj_fig,'UserData');

  obj_type=ui_hndls(1);
  olddata=get(h,'UserData');
  editbox_no=str2double(get(h,'Tag'));
  gencheck=0; namecheck=0;
  if editbox_no==2,
    if obj_type==2
    % Polygon: This is a popup menu
      i=get(h,'Value');
      gdcol=get(ui_hndls(2),'UserData');
      n=gdcol(2);
      set(ui_hndls(5),'String',sprintf('%.17g',gdcol(3+i-1)),...
        'UserData',sprintf('%.17g',gdcol(3+i-1)))
      set(ui_hndls(6),'String',sprintf('%.17g',gdcol(3+n+i-1)),...
        'UserData',sprintf('%.17g',gdcol(3+n+i-1)))
    else
    % Rectangle: left
    % Circle or ellipse: x-center
    % Generic: x displacement
      gencheck=1;
    end
  elseif editbox_no==3,
    if obj_type==2,
    % Polygon: Check value and update popup menu and geometry data
    % This is the new X-coordinate.
      newx=str2num(get(h,'String'));
      if isempty(newx),
        pdetool('error',' Parameter entry incorrect.')
        set(h,'String',olddata)
        return;
      elseif numel(newx)>1,
        pdetool('error',' Parameter must be a scalar.')
        set(h,'String',olddata)
        return;
      end
      gdcol=get(ui_hndls(2),'UserData');
      n=gdcol(2);
      val=get(ui_hndls(4),'Value');
      gdcol(3+val-1)=newx;
      if csgchk(gdcol),
        pdetool('error',' Polygons must not intersect.');
        set(h,'String',olddata)
        return;
      end
      str='';
      for i=1:n,
        str=[str, sprintf(' %.4g, %.4g|',gdcol(3+i-1),...
          gdcol(3+n+i-1))];
      end
      str=str(1:length(str)-1);
      set(ui_hndls(4),'String',str,'Value',val)
      set(ui_hndls(2),'UserData',gdcol)
    else
      gencheck=1;
    end
  elseif editbox_no==4,
    if obj_type==2,
    % Polygon: Check value and update popup menu and geometry data
    % This is the new Y-coordinate.
      newy=str2num(get(h,'String'));
      if isempty(newy),
        pdetool('error',' Parameter entry incorrect.')
        set(h,'String',olddata)
        return;
      elseif numel(newy)>1,
        pdetool('error',' Parameter must be a scalar.')
        set(h,'String',olddata)
        return;
      end
      gdcol=get(ui_hndls(2),'UserData');
      n=gdcol(2);
      val=get(ui_hndls(4),'Value');
      gdcol(3+n+val-1)=newy;
      if csgchk(gdcol),
        pdetool('error',' Polygons must not intersect.');
        set(h,'String',olddata)
        return;
      end
      str='';
      for i=1:n,
        str=[str, sprintf(' %.4g, %.4g|',gdcol(3+i-1),...
          gdcol(3+n+i-1))];
      end
      str=str(1:length(str)-1);
      set(ui_hndls(4),'String',str,'Value',val)
      set(ui_hndls(2),'UserData',gdcol)
    elseif (obj_type==1 || obj_type==4)
    % Circle or ellipse: radius/semiaxes
      val=str2num(get(h,'String'));
      if isempty(val),
        pdetool('error',' Parameter entry incorrect.')
        set(h,'String',olddata)
      elseif numel(val)>1,
        pdetool('error',' Parameter must be a scalar.')
        set(h,'String',olddata)
      elseif val<=0,
        pdetool('error',' Parameter must be positive.')
        set(h,'String',olddata)
      end
    elseif obj_type==3,
      gencheck=1;
    else
      namecheck=1;
    end
  elseif editbox_no==5,
    if obj_type==4,
    % Ellipse: semiaxes
      val=str2num(get(h,'String'));
      if isempty(val),
        pdetool('error',' Parameter entry incorrect.')
        set(h,'String',olddata)
      elseif numel(val)>1,
        pdetool('error',' Parameter must be a scalar.')
        set(h,'String',olddata)
      elseif val<=0,
        pdetool('error',' Parameter must be positive.')
        set(h,'String',olddata)
      end
    elseif obj_type==3,
      gencheck=1;
    else
      namecheck=1;
    end
  elseif editbox_no==6,
    if obj_type==4,
    % Ellipse: rotation angle
      val=str2num(get(h,'String'));
      if isempty(val),
        pdetool('error',' Parameter entry incorrect.')
        set(h,'String',olddata)
      elseif numel(val)>1,
        pdetool('error',' Parameter must be a scalar.')
        set(h,'String',olddata)
      end
    else
      namecheck=1;
    end
  elseif editbox_no==7,
  % Ellipse only, name
    namecheck=1;
  end

  if namecheck,         % name edit field
    name=get(h,'String');
    olddata=deblank(olddata);
    if pdeisusd(name) && ~strcmp(name,olddata),
      pdetool('error', ' Object names must be unique.')
      set(h,'String',olddata)
    end
  elseif gencheck,      % general entry check
    val=str2num(get(h,'String'));
    if isempty(val),
      pdetool('error',' Parameter entry incorrect.')
      set(h,'String',olddata)
    elseif numel(val)>1,
      pdetool('error',' Parameter must be a scalar.')
      set(h,'String',olddata)
    end
  end

%
% case: update object size and position and close dialog box

elseif strcmp(action,'OK')

  pde_circ=1; pde_poly=2; pde_rect=3; pde_ellip=4;

  obj_fig=gcf;

  ui_hndls=get(obj_fig,'UserData');

  obj_type=ui_hndls(1);
  n=length(ui_hndls);
  if obj_type==0,
    geom_cols=ui_hndls(7:n);
  elseif (obj_type==1 || obj_type==2),
    geom_cols=ui_hndls(8:n);
  elseif obj_type==3,
    geom_cols=ui_hndls(9:n);
  elseif obj_type==4,
    geom_cols=ui_hndls(10:n);
  end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  xlim=diff(get(ax,'XLim')); ylim=diff(get(ax,'YLim'));

  meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  pdegd=get(meshhndl,'UserData');

  if obj_type==2
  % case: polygon

    newcol=get(ui_hndls(2),'UserData');
    if csgchk(newcol),
      pdetool('error',' Polygons must not intersect.');
      return;
    end
    pdegd(:,geom_cols)=newcol;

    name=deblank(get(ui_hndls(7),'String'));
    oldname=deblank(get(ui_hndls(7),'UserData'));

  elseif obj_type==3
  % case: rectangle

    newdata=[str2double(get(ui_hndls(4),'String')),...
      str2num(get(ui_hndls(5),'String')),...
      str2num(get(ui_hndls(6),'String')),...
      str2num(get(ui_hndls(7),'String'))];

    if (newdata(3)<=0 || newdata(4)<=0),
      pdetool('error',' Width and height must be positive.');
      return;
    end

    if pdegd(3,geom_cols)<pdegd(4,geom_cols),
      pdegd([3 6],geom_cols)=[newdata(1);newdata(1)];
      pdegd([4 5],geom_cols)=[newdata(1)+newdata(3);newdata(1)+newdata(3)];
    else
      pdegd([4 5],geom_cols)=[newdata(1);newdata(1)];
      pdegd([3 6],geom_cols)=[newdata(1)+newdata(3);newdata(1)+newdata(3)];
    end
    if pdegd(7,geom_cols)<pdegd(9,geom_cols),
      pdegd([7 8],geom_cols)=[newdata(2);newdata(2)];
      pdegd([9 10],geom_cols)=[newdata(2)+newdata(4);newdata(2)+newdata(4)];
    else
      pdegd([9 10],geom_cols)=[newdata(2);newdata(2)];
      pdegd([7 8],geom_cols)=[newdata(2)+newdata(4);newdata(2)+newdata(4)];
    end

    if csgchk(pdegd),
      pdetool('error',' Rectangle caused invalid solid geometry.')
      return;
    end

    name=deblank(get(ui_hndls(8),'String'));
    oldname=deblank(get(ui_hndls(8),'UserData'));

  elseif obj_type==1
  % case: circle

    newdata=[str2num(get(ui_hndls(4),'String')),...
      str2num(get(ui_hndls(5),'String')),...
      str2num(get(ui_hndls(6),'String'))];
    pdegd(2:4,geom_cols)=newdata';

    if any(csgchk(pdegd,xlim,ylim)==2),
      pdetool('error',' Circles must be unique.')
      return;
    end

    name=deblank(get(ui_hndls(7),'String'));
    oldname=deblank(get(ui_hndls(7),'UserData'));

  elseif obj_type==4
  % case: ellipse

    newdata=[str2num(get(ui_hndls(4),'String')),...
      str2num(get(ui_hndls(5),'String')),...
      str2num(get(ui_hndls(6),'String')),...
      str2num(get(ui_hndls(7),'String')),...
      pi*str2num(get(ui_hndls(8),'String'))/180];
    pdegd(2:6,geom_cols)=newdata';

    if any(csgchk(pdegd,xlim,ylim)==2),
      pdetool('error',' Ellipses must be unique.')
      return;
    end

    name=deblank(get(ui_hndls(9),'String'));
    oldname=deblank(get(ui_hndls(9),'UserData'));

  elseif obj_type==0
  % case: generic displacement (if more than one object selected)
    xdiff=str2num(get(ui_hndls(4),'String'));
    ydiff=str2num(get(ui_hndls(5),'String'));

    for i=1:length(geom_cols),
      type=pdegd(1,geom_cols(i));
      if type==pde_rect
        pdegd(3:6,geom_cols(i))=...
            pdegd(3:6,geom_cols(i))+xdiff;
        pdegd(7:10,geom_cols(i))=...
            pdegd(7:10,geom_cols(i))+ydiff;
      elseif type==pde_poly
        n=pdegd(2,geom_cols(i));
        pdegd(3:3+n-1,geom_cols(i))=...
            pdegd(3:3+n-1,geom_cols(i))+xdiff;
        pdegd(3+n:3+2*n-1,geom_cols(i))=...
            pdegd(3+n:3+2*n-1,geom_cols(i))+ydiff;
      elseif type==pde_circ || type==pde_ellip
        ctr=pdegd(2:3,geom_cols(i));
        pdegd(2:3,geom_cols(i))=...
            [ctr(1)+xdiff ctr(2)+ydiff]';
      end
    end

    name=deblank(get(ui_hndls(6),'String'));
    oldname=deblank(get(ui_hndls(6),'UserData'));

  end
  set(pde_fig,'Pointer','watch')

  close(obj_fig)
  drawnow

  boundhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  oldpdedl=get(boundhndl,'UserData');

  % First call DECSG to decompose geometry;
  [dl1,bt1,pdedl,bt,msb]=decsg(pdegd);

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  h=[];
  for i=geom_cols,
    h=[h; findobj(get(ax,'Children'),'flat','Tag','PDELabel',...
      'UserData',i); findobj(get(ax,'Children'),'flat','Tag','PDELblSel',...
      'UserData',i)];
    set(h,'Tag','PDELblSel')
  end

  % Did name change?
  if ~strcmp(name,oldname) && length(geom_cols)==1,
    pdesetlb(name,geom_cols)
    set(h,'Erasemode','normal'), set(h,'Erasemode','background')
    hh=copyobj(h,ax); delete(h)
    set(hh,'String',name)
  end

  % Did geometry change?
  if all(size(oldpdedl)==size(pdedl)),
    if all(oldpdedl==pdedl),
      change=0;
    else
      change=1;
    end
  else
    change=1;
  end
  if change,
    pdepatch(pdedl,bt,msb);
    set(boundhndl,'UserData',pdedl)
    set(meshhndl,'UserData',pdegd)
    setappdata(pde_fig,'dl1',dl1)
    setappdata(pde_fig,'bt1',bt1)

    pdeframe(pdegd,geom_cols)
  end

  set(pde_fig,'Pointer','arrow')
  drawnow
  pdeinfo

%
% case: cancel

elseif strcmp(action,'cancel')

  close(gcf)
  drawnow
  pdeinfo

end

