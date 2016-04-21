function pdeframe(geom,cols)
%PDEFRAME Puts a black frame around selected objects.
%       PDEFRAME(GEOM,COLS) puts a black frame, indicating selection,
%       around the PDETOOL geometry objects found in columns COL of
%       PDE toolbox geometry specification matrix GEOM

%       M. Ringh 9-05-94, MR 8-25-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 2001/02/09 17:03:15 $

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

% do: for all selected geometry objects
for i=cols(:)',
  %
  %case: polygon (rectangle)
  if geom(1,i)==2 | geom(1,i)==3,
    n=geom(2,i);
    x=[geom(3:3+n-1,i)' geom(3,i)];
    y=[geom(3+n:3+2*n-1,i)' geom(3+n,i)];

  %
  %case: circle
  elseif geom(1,i)==1,
    t=0:pi/50:2*pi;
    x=sin(t)*geom(4,i)+geom(2,i);
    y=cos(t)*geom(4,i)+geom(3,i);

  %
  %case: ellipse
  elseif geom(1,i)==4,
    t=0:pi/50:2*pi;
    x=sin(t)*geom(4,i)+geom(2,i);
    y=cos(t)*geom(5,i)+geom(3,i);
    ang=360-180*geom(6,i)/pi;
    % line not visible; temporarily created to let rotate.m do the job
    h=line(x,y,zeros(size(x)),...
        'Parent',ax,...
        'Visible','off',...
	'Erasemode','xor');
    rotate(h,[0 -90],ang,[geom(2:3,i); 0])
    x=get(h,'XData'); y=get(h,'YData');
    delete(h)
  end

  % draw the frame
  line(x,y,ones(size(x)),'Erasemode','background','Color','k',...
      'Parent',ax,...
      'Tag','PDESelFrame','UserData',i);
end

