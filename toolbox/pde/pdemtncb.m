function pdemtncb(flag)
%PDEMTNCB WindowButtonMotion callback for PDETOOL GUI.
%

%       Magnus Ringh 04-18-95, MR 10-05-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:30 $

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
hKids=get(pde_fig,'Children');
ax=findobj(hKids,'flat','Tag','PDEAxes');
hndl=get(ax,'UserData');
ptr=get(pde_fig,'Pointer');

if pdeonax(ax),

  pv=get(ax,'CurrentPoint');
  [xcurr,ycurr]=pdesnap(ax,pv,getappdata(ax,'snap'));
  if all(ptr(1:2)=='ar'),
    set(pde_fig,'Pointer','crosshair');
  end

  user_data=get(pde_fig,'UserData');
  set(user_data(1),'String',sprintf('%.4g',xcurr))
  set(user_data(2),'String',sprintf('%.4g',ycurr))
  if flag==0,
    return;
  elseif flag==1                                % rectangle
    x=get(hndl,'Xdata');
    y=get(hndl,'Ydata');
    x(2)=xcurr; x(3)=xcurr;
    y(3)=ycurr; y(4)=ycurr;
    set(hndl,'Xdata',x,'Ydata',y);
  elseif flag==-1                       % square
    x=get(hndl,'Xdata');
    y=get(hndl,'Ydata');
    dif=max(abs(xcurr-x(1)),abs(ycurr-y(1)));
    x(2)=x(1)+dif*sign(pv(1,1)-x(1)); x(3)=x(2);
    y(3)=y(1)+dif*sign(pv(1,2)-y(1)); y(4)=y(3);
    set(hndl,'Xdata',x,'Ydata',y);
  elseif flag==2                        % rectangle - start from center
    x=get(hndl,'Xdata'); xorig=0.5*(x(1)+x(2));
    y=get(hndl,'Ydata'); yorig=0.5*(y(1)+y(3));
    x(2)=xcurr; x(3)=xcurr;
    x(1)=xorig-(xcurr-xorig);
    x(4)=x(1); x(5)=x(1);
    y(3)=ycurr; y(4)=ycurr;
    y(1)=yorig-(ycurr-yorig);
    y(2)=y(1); y(5)=y(1);
    set(hndl,'Xdata',x,'Ydata',y);
  elseif flag==-2                       % square - start from center
    x=get(hndl,'Xdata'); xorig=0.5*(x(1)+x(2));
    y=get(hndl,'Ydata'); yorig=0.5*(y(1)+y(3));
    dif=max(abs(xcurr-xorig),abs(ycurr-yorig));
    x(2)=xorig+sign(pv(1,1)-xorig)*dif; x(3)=x(2);
    x(1)=xorig-sign(pv(1,1)-xorig)*dif;
    x(4)=x(1); x(5)=x(1);
    y(3)=yorig+sign(pv(1,2)-yorig)*dif; y(4)=y(3);
    y(1)=yorig-sign(pv(1,2)-yorig)*dif;
    y(2)=y(1); y(5)=y(1);
    set(hndl,'Xdata',x,'Ydata',y);
  elseif flag==3                        % ellipse - start at perimeter
    user_data=get(pde_fig,'UserData');
    origin=user_data(3:4);
    xc=0.5*(xcurr+origin(1));
    yc=0.5*(ycurr+origin(2));
    radiusx=sqrt((xc-xcurr)*(xc(1)-xcurr));
    radiusy=sqrt((yc-ycurr)*(yc-ycurr));
    t=0:pi/50:2*pi;
    xt=sin(t)*radiusx+xc; yt=cos(t)*radiusy+yc;
    set(hndl,'Xdata',xt,'Ydata',yt);
  elseif flag==-3                       % circle - start at perimeter
    user_data=get(pde_fig,'UserData');
    origin=user_data(3:4);
    dif=max(abs(xcurr-origin(1)),abs(ycurr-origin(2)));
    xsign=sign(pv(1,1)-origin(1));
    ysign=sign(pv(1,2)-origin(2));
    if xsign==0, xsign=1; end
    if ysign==0, ysign=1; end
    xc=0.5*(dif*xsign+2*origin(1));
    yc=0.5*(dif*ysign+2*origin(2));
    radius=0.5*dif;
    t=0:pi/50:2*pi;
    xt=sin(t)*radius+xc; yt=cos(t)*radius+yc;
    set(hndl,'Xdata',xt,'Ydata',yt);
  elseif flag==4                        % ellipse - start at center
    user_data=get(pde_fig,'UserData');
    pde_xc=user_data(3:4);
    radiusx=sqrt((pde_xc(1)-xcurr)*(pde_xc(1)-xcurr));
    radiusy=sqrt((pde_xc(2)-ycurr)*(pde_xc(2)-ycurr));
    t=0:pi/50:2*pi;
    xt=sin(t)*radiusx+pde_xc(1); yt=cos(t)*radiusy+pde_xc(2);
    set(hndl,'Xdata',xt,'Ydata',yt);
  elseif flag==-4                       % circle - start at center
    user_data=get(pde_fig,'UserData');
    pde_xc=user_data(3:4);
    dif=max(abs(xcurr-pde_xc(1)),abs(ycurr-pde_xc(2)));
    radius=dif;
    t=0:pi/50:2*pi;
    xt=sin(t)*radius+pde_xc(1); yt=cos(t)*radius+pde_xc(2);
    set(hndl,'Xdata',xt,'Ydata',yt);
  elseif flag==5,                       % moving frame
    if ~all(ptr(1:2)=='fl'),
      set(pde_fig,'Pointer','fleur')
    end
    selected=findobj(get(ax,'Children'),'flat',...
          'Tag','PDELblSel','Visible','on');
    for i=1:length(selected),
      pvold=get(selected(i),'UserData');
      pvtmp=pvold(2:3);
      pvold(2:3)=[xcurr ycurr];
      set(selected(i),'UserData',pvold);
      x=get(hndl(i),'Xdata');
      y=get(hndl(i),'Ydata');
      xdiff=xcurr-pvtmp(1); ydiff=ycurr-pvtmp(2);
      x=x+xdiff; y=y+ydiff;
      set(hndl(i),'Xdata',x,'Ydata',y);
    end
  elseif flag==10                       % polygon line
    x=get(hndl,'Xdata');
    y=get(hndl,'Ydata');
    x(2)=xcurr; y(2)=ycurr;
    set(hndl,'Xdata',x,'Ydata',y);
  end

else

  set(pde_fig,'Units','normalized')
  pv=get(pde_fig,'CurrentPoint');

  if all(ptr(1:2)=='cr'),
    set(pde_fig,'Pointer','arrow');
    % Hack: prevent zoomed axes to cover btngroup axes:
    btnaxes=[findobj(hKids,'flat','Type','axes',...
              'Tag','draw'),...
            findobj(hKids,'flat','Type','axes',...
              'Tag','solve'),...
            findobj(hKids,'flat','Type','axes',...
              'Tag','zoom')];
    for i=1:length(btnaxes),
      set(pde_fig,'Currentaxes',btnaxes(i))
    end
  end
  if getappdata(pde_fig,'toolhelp'),
    if pv(1,2)>0.96
      if pv(1,1)<0.04,
        pdeinfo('Click and drag at corner to create rectangle.',2);
      elseif pv(1,1)<0.08
        pdeinfo('Click and drag at center to create rectangle.',2);
      elseif pv(1,1)<0.12
        pdeinfo('Click and drag at perimeter to create ellipse.',2);
      elseif pv(1,1)<0.16
        pdeinfo('Click and drag at center to create ellipse.',2);
      elseif pv(1,1)<0.20
        pdeinfo('Click to create polygon. Close by clicking at starting point.',2);
      elseif pv(1,1)<0.24
        pdeinfo('Push to define boundary cond''s.',2);
      elseif pv(1,1)<0.28
        pdeinfo('Push to specify PDE coefficients.',2);
      elseif pv(1,1)<0.32
        pdeinfo('Push to initialize mesh.',2);
      elseif pv(1,1)<0.36
        pdeinfo('Push to refine mesh.',2);
      elseif pv(1,1)<0.40
        pdeinfo('Push to solve PDE.',2);
      elseif pv(1,1)<0.44
        pdeinfo('Push to specify PDE solution plot.',2);
      elseif pv(1,1)<0.48
          pdeinfo('Push to invoke and disable zoom feature.',2);
      elseif pv(1,1)<0.77
          pdeinfo('Select the type of PDE application from this pop-up menu.',2);
      elseif pv(1,1)<0.89
        pdeinfo('The current x-axis coordinate is displayed here.',2);
      else
        pdeinfo('The current y-axis coordinate is displayed here.',2);
      end
    else
      [str,val]=pdeinfo;
      pdeinfo(str,val);
    end
  end
  set(pde_fig,'Units','pixels')
  drawnow
end

