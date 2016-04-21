function pdebddsp(dl)
%PDEBDDSP Displays subdomain borders.
%   PDEBDDSP(DL) draws white lines to indicate subdomain borders
%   according to the PDE toolbox final decomposed geometry matrix DL

%   M. Ringh 12-20-94, MR 1-25-95.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:23 $

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

% do: for all selected geometry objects
n=size(dl,2);
for i=1:n,
  regs=find(dl(6,:)==i | dl(7,:)==i);
  for j=regs,
    %
    %case: line segment
    if dl(1,j)==2,
      x=dl(2:3,j)';
      y=dl(4:5,j)';
      line(x,y,'Erasemode','background','Color','w',...
          'Parent',ax,...
          'Tag','PDESelRegion','UserData',j);
    %
    %case: circle arc
    elseif dl(1,j)==1,
      delta=2*pi/100;
      arg1=atan2(dl(4,j)-dl(9,j),...
          dl(2,j)-dl(8,j));
      arg2=atan2(dl(5,j)-dl(9,j),...
          dl(3,j)-dl(8,j));
      if arg2<0 && arg1>0, arg2=arg2+2*pi; end
      darg=abs(arg2-arg1);
      ns=max(2,ceil(darg/delta));
      arc=linspace(arg1,arg2,ns);
      xc(1:ns)=(dl(8,j)+dl(10,j)*cos(arc))';
      yc(1:ns)=(dl(9,j)+dl(10,j)*sin(arc))';
      line(xc(1:ns),yc(1:ns),ones(1,ns),'Erasemode','background',...
          'Parent',ax,...
          'Color','w','Tag','PDESelRegion','UserData',j);
    %
    %case: ellipse arc
    elseif dl(1,j)==4,
      delta=2*pi/100;
      ca=cos(dl(12,j)); sa=sin(dl(12,j));
      xd=dl(2,j)-dl(8,j);
      yd=dl(4,j)-dl(9,j);
      x1=ca*xd+sa*yd;
      y1=-sa*xd+ca*yd;
      th1=atan2(y1./dl(11,j),x1./dl(10,j));
      xd=dl(3,j)-dl(8,j);
      yd=dl(5,j)-dl(9,j);
      x1=ca*xd+sa*yd;
      y1=-sa*xd+ca*yd;
      th2=atan2(y1./dl(11,j),x1./dl(10,j));
      if th2<th1, th2=th2+2*pi; end
      darg=abs(th2-th1);
      ns=max(2,ceil(darg/delta));
      arc=linspace(th1,th2,ns);
      x1=dl(10,j).*cos(arc)'; y1=dl(11,j).*sin(arc)';
      xc(1:ns)=dl(8,j)+ca*x1-sa*y1;
      yc(1:ns)=dl(9,j)+sa*x1+ca*y1;
      line(xc(1:ns),yc(1:ns),ones(1,ns),'Erasemode','background',...
          'Parent',ax,...
          'Color','w','Tag','PDESelRegion','UserData',j);
    end
  end
end

