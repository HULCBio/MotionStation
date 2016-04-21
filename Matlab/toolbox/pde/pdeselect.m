function pdeselect(action,flag)
%PDESELECT Handles selection and move actions in the PDETOOL GUI.
%   PDESELECT contains callback actions for selecting and moving
%   solid objects in the PDETOOL GUI.

%   M. Ringh 10-03-95.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:11:54 $

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

%
% case: select

if strcmp(action,'select'),

  hFigKids=get(pde_fig,'Children');
  ax=findobj(hFigKids,'flat','Tag','PDEAxes');
  if ~pdeonax(ax) && nargin==1, return; end

  if getappdata(ax,'selinit') && nargin==1,
    pdeselect moveup;
    return;
  end

  boundh=findobj(hFigKids,'flat','Tag','PDEBoundMenu');
  dl=get(boundh,'UserData');
  % if geometry empty, return
  if isempty(dl), return; end

  set(pde_fig,'CurrentAxes',ax)

  hKids=get(ax,'Children');
  selected=findobj(hKids,'flat','Tag','PDELblSel','Visible','on');

  p=getappdata(pde_fig,'pinit');
  t=getappdata(pde_fig,'tinit');
  pv=get(ax,'CurrentPoint');
  xcurr=pv(1,1); ycurr=pv(1,2);
  [uxy,tn,a2,a3]=tri2grid(p,t,zeros(size(p,2)),xcurr,ycurr);

  %
  % case: select all (flag is set)

  if nargin>1
    sel=findobj(hKids,'flat','Tag','PDELabel');
    if ~isempty(sel),
      frames=findobj(hKids,'flat','Tag','PDESelFrame');
      delete(frames)
      pdegd=get(findobj(hFigKids,'flat',...
          'Tag','PDEMeshMenu'),'UserData');
      set(sel,'Tag','PDELblSel')
      pdeframe(pdegd,1:size(pdegd,2));
    end

  %
  % case: shift-click to deselect or multi-select

  elseif findstr(get(pde_fig,'SelectionType'),'extend')

    if isnan(tn),
      % clicked outside of geometry objects: deselect all
      h=findobj(hKids,'flat','Tag','PDELblSel',...
          'Visible','on');
      set(h,'Tag','PDELabel')
      frames=[findobj(hKids,'flat','Tag','PDESelFrame'); ...
              findobj(hKids,'flat','Tag','PDEStretch')];
      delete(frames)
      return
    else
      j=t(4,tn);
    end

    curr_obj=get(pde_fig,'CurrentObject');
    curr_type=get(curr_obj,'type');
    if strcmp(curr_type,'patch'),
      % clicked in minimal region
      % j = row in Boolean Table for minimal region clicked in
      bt=get(get(ax,'Title'),'UserData');
      l=find(bt(j,:)==1);
      % l = array of column in PDEGD for geometrical objects
      % whose intersection is minimal region j.
      h=[];
      for i=l,
        h=[h; findobj(hKids,'flat',...
                'Tag','PDELblSel','Visible','on','UserData',i);...
                findobj(hKids,'flat',...
                'Tag','PDELabel','Visible','on','UserData',i)];
      end
    elseif strcmp(curr_type,'text'),
      % clicked on label
      l=get(curr_obj,'UserData');
      h=curr_obj;
    else
      return
    end

    if isempty(findobj(h,'Tag','PDELblSel'))
      % if not selected, select
      set(h,'Tag','PDELblSel');
      pdegd=get(findobj(hFigKids,'flat',...
          'Tag','PDEMeshMenu'),'UserData');
      pdeframe(pdegd,l);
    else
      % if already selected, deselect
      set(h,'Tag','PDELabel');
      frames=[];
      for i=l,
        frames=[frames; ...
                findobj(hKids,'flat','Tag',...
                'PDESelFrame','Visible','on','UserData',i)];
      end
      delete(frames)
    end

  %
  % case: double-click to open dialog box

  elseif findstr(get(pde_fig,'SelectionType'),'open')

    if ~isnan(tn),
      h=findobj(hKids,'flat','Tag','PDELblSel','Visible','on');
      if ~isempty(h),
        nh=length(h);
        l=zeros(1,nh);
        for i=1:length(h),
          tmp=get(h(i),'UserData');
          l(i)=tmp(1);
        end
        set(pde_fig,'WindowButtonDownFcn','',...
                    'Pointer','watch')
        drawnow
        if strcmp(computer,'PCWIN'),
                pderel
           end
        pdeobdlg('start',l)
        set(pde_fig,'WindowButtonDownFcn','pdeselect select',...
                    'Pointer','arrow')
        drawnow
      end
    end

  %
  % case: click to select

  elseif findstr(get(pde_fig,'SelectionType'),'normal')

    if isnan(tn),
      % clicked outside of geometry objects: deselect all
      h=findobj(hKids,'flat','Tag','PDELblSel',...
          'Visible','on');
      set(h,'Tag','PDELabel')
      delete(findobj(hKids,'flat','Tag','PDESelFrame'));
      return
    else
      j=t(4,tn);
    end

    curr_obj=get(pde_fig,'CurrentObject');
    curr_type=get(curr_obj,'type');
    hnotsel = [];
    if strcmp(curr_type,'patch'),
      % clicked in minimal region
      % j = row in Boolean Table for minimal region clicked in
      bt=get(get(ax,'Title'),'UserData');
      l=find(bt(j,:)==1);
      % l = array of column in PDEGD for geometrical objects
      % whose intersection is minimal region j.
      hsel=[];
      for i=l,
        hsel=[hsel; findobj(hKids,'flat',...
                'Tag','PDELblSel','Visible','on','UserData',i)];
        hnotsel=[hnotsel; findobj(hKids,'flat',...
                'Tag','PDELabel','Visible','on','UserData',i)];
      end
      if ~isempty(hsel),
        h=hsel;
        nhs=length(hsel);
        l=zeros(1,nhs);
        for i=1:nhs,
          l(i)=get(hsel(i),'UserData');
        end
      else
        h=hnotsel;
      end

    elseif strcmp(curr_type,'text'),
      % clicked on label
      l=get(curr_obj,'UserData'); l=l(1);
      hnotsel=curr_obj;
      h=get(pde_fig,'CurrentObject');
    end

    % if: not already selected
    if ~isempty(hnotsel)
      set(selected,'Tag','PDELabel');
      set(h,'Tag','PDELblSel');
      delete(findobj(hKids,'flat','Tag','PDESelFrame'));
      pdegd=get(findobj(hFigKids,'flat',...
          'Tag','PDEMeshMenu'),'UserData');
      pdeframe(pdegd,l)
    end

    % Initiate move:

    [xcurr,ycurr]=pdesnap(ax,pv,getappdata(ax,'snap'));

    axKids=get(ax,'Children');
    selected=findobj(axKids,'flat',...
                     'Tag','PDELblSel',...
                     'Visible','on');

    n=length(selected);
    hndl=zeros(1,n);
    for i=1:n,
      tmp=get(selected(i),'UserData');

      % pick up selected object's frame to get x- and y-data:
      frame=findobj(axKids,'flat',...
                    'Tag','PDESelFrame',...
                    'Visible','on',...
                    'UserData',tmp(1));

      x=get(frame,'XData'); y=get(frame,'YData');
      % hold on;
      set(pde_fig,'NextPlot','add')
      set(ax,'NextPlot','add')
      hndl(i)=line(x,y,'Color','r','EraseMode','xor');
      % hold off;
      set(ax,'NextPlot','replace')
      %tmp(1)=column in PDEGD; tmp(2:5)=new and old x and y data
      tmp(2:5)=[xcurr ycurr xcurr ycurr];
      set(selected(i),'UserData',tmp);
    end

    % Store handles to moving frames in the PDEAxes' UserData
    set(ax,'UserData',hndl)

    set(pde_fig,'WindowButtonMotionFcn','pdemtncb(5)',...
        'WindowButtonUpFcn','pdeselect moveup')

    if nargin==1,
      setappdata(ax,'selinit',1)
    end
  end

  edithndl=findobj(hFigKids,'flat','Tag','PDEEditMenu');
  hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEClear');
  if isempty(findobj(get(ax,'Children'),'flat',...
        'Tag','PDELblSel','Visible','on')),
    % if no object is selected:
    set(hndl,'Enable','off')
  else
    set(hndl,'Enable','on')
  end

%
% case: move ButtonUp callback

elseif strcmp(action,'moveup')

  kids=get(pde_fig,'Children');
  ax=findobj(kids,'flat','Tag','PDEAxes');
  if ~getappdata(ax,'selinit'),
    return;
  end

  pde_circ=1; pde_poly=2; pde_rect=3; pde_ellip=4;

  set(pde_fig,'Pointer','crosshair',...
              'WindowButtonMotionFcn','pdemtncb(0)',...
              'WindowButtonUpFcn','')

  %get the handles to the moving - - - 'frames' and turn them off
  hndl=get(ax,'UserData');
  delete(hndl);
  set(ax,'UserData',[]);

  axKids=get(ax,'Children');
  selected=findobj(axKids,'flat','Type','text',...
      'Tag','PDELblSel','Visible','on');
  if isempty(selected),
    setappdata(ax,'selinit',0)
    return;
  end

  % All selected patches' move frame userdata contains new and old x data
  % and y data in userdata(2)-userdata(5)
  tmp=get(selected(1),'UserData');
  n=length(selected);
  sel=zeros(1,n);
  % dump the x and y data so the UserData is a pure PDEGD column number:
  % and collect columns in PDEGD of moved objects
  for i=1:n,
    udata=get(selected(i),'UserData');
    set(selected(i),'UserData',udata(1))
    sel(i)=udata(1);
  end

  % Don't bother if the move is ''very small''.
  xlim=get(ax,'Xlim');
  ylim=get(ax,'Ylim');

  xdiff=tmp(2)-tmp(4);
  ydiff=tmp(3)-tmp(5);
  small=100*eps;
  if abs(xdiff)<small*diff(xlim) && abs(ydiff)<small*diff(ylim),
    setappdata(ax,'selinit',0)
    return
  end

  opthndl=findobj(kids,'flat','Tag','PDEOptMenu');

  % Update PDEGD matrix
  %
  pdegd=get(findobj(kids,'flat','Tag','PDEMeshMenu'),'UserData');

  % circles and ellipses:

  indx=find(pdegd(1,sel)==pde_circ | pdegd(1,sel)==pde_ellip);
  pdegd(2,sel(indx))=pdegd(2,sel(indx))+xdiff;
  pdegd(3,sel(indx))=pdegd(3,sel(indx))+ydiff;

  % polygons:

  indx=find(pdegd(1,sel)==pde_poly | pdegd(1,sel)==pde_rect);
  vertices=pdegd(2,:);
  n=length(indx);
  for i=1:n,
    pdegd(3:2+vertices(sel(indx(i))),sel(indx(i)))=...
        pdegd(3:2+vertices(sel(indx(i))),sel(indx(i)))+xdiff;
    pdegd(3+vertices(sel(indx(i))):2*vertices(sel(indx(i)))+2,...
        sel(indx(i)))=...
        pdegd(3+vertices(sel(indx(i))):2*vertices(sel(indx(i)))+2,...
        sel(indx(i)))+ydiff;
  end

  set(pde_fig,'Pointer','watch');

  % Check geometry before proceeding:
  stat=csgchk(pdegd,diff(xlim),diff(ylim));
  if any(stat==2),
    pdetool('error',' Move resulted in non-unique circle/ellipse.')
    set(pde_fig,'Pointer','arrow');
    setappdata(ax,'selinit',0)
    return
  end

  % First call DECSG to decompose geometry;
  try
      [dl1,bt1,pdedl,bt,msb] = decsg(pdegd);
  catch
     pdetool('error',lasterr);
    set(pde_fig,'Pointer','arrow');
    setappdata(ax,'selinit',0)
    return
  end

  err=pdepatch(pdedl,bt,msb);
  if err
    pdetool('error',lasterr);
    set(pde_fig,'Pointer','arrow');
    setappdata(ax,'selinit',0)
    return
  end

  pdeframe(pdegd,sel);

  % Save PDEDL and PDEGD
  set(findobj(kids,'flat','Tag','PDEBoundMenu'),'UserData',pdedl);
  set(findobj(kids,'flat','Tag','PDEMeshMenu'),'UserData',pdegd);

  setappdata(pde_fig,'dl1',dl1)
  setappdata(pde_fig,'bt1',bt1)

  axKids=get(ax,'Children');
  h=[];
  for i=sel,
    h=[h; findobj(axKids,'flat','Tag','PDELabel','UserData',i)];
  end
  set(h,'Tag','PDELblSel');

  h=findobj(kids,'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData');
  flags(1)=1;                           % need_save=1
  flags(3)=1;                           % flag1=1
  set(h,'UserData',flags)

  set(pde_fig,'Pointer','arrow');

  setappdata(ax,'selinit',0)
end

