function pdeinfclk(mode)
%PDEINFCLK Provides information about mesh and solution on info line.
%
%
%       Called from PDETOOL when clicking on the
%       mesh or the solution plot.
%
%       See also: PDETOOL

%       Magnus Ringh 6-16-95
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:28 $

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

cv=get(ax,'CurrentPoint');
x=cv(1,1); y=cv(1,2);

if pdeonax(ax),
  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
  ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
  p=get(hp,'UserData'); t=get(ht,'UserData');

  if mode==1,
    % Mesh mode

    [unused,trino,a2,a3]=tri2grid(p,t,zeros(size(p,2),1),x,y);
    if isnan(trino),
      pdeinfo('Pointer location is outside of problem geometry.');
    else
      if strcmp(get(pde_fig,'SelectionType'),'extend')
        str=sprintf('Triangle no %i.',trino);
        pdeinfo(str);
      else
        diff=p-kron([x, y],ones(size(p,2),1))';
        pnorm=diff(1,:).^2+diff(2,:).^2;
        nodeno=find(pnorm==min(pnorm));
        str=sprintf('Node no %i.',nodeno);
        pdeinfo(str);
      end
    end
  elseif mode==2,
    % Solve mode
    xydata=getappdata(pde_fig,'xydata');
    if isempty(xydata),
      pdeinfo('No scalar solution data on screen.');
    else
      plotflags=getappdata(pde_fig,'plotflags');
      if plotflags(17),
        meshdeformation=getappdata(pde_fig,'meshdef');
        if ~isempty(meshdeformation),
          p=p+meshdeformation;
        end
      end
      if size(xydata,2)==size(t,2),
        % convert to node data:
        xydata=pdeprtni(p,t,xydata);
      end
      [u,trino,a2,a3]=tri2grid(p,t,xydata,x,y);

      if isnan(trino),
        pdeinfo('Pointer location is outside of problem geometry.');
      else
        xystr=deblank(getappdata(pde_fig,'xystr'));
        str=sprintf('Triangle no %i. Value of %s: %g',trino,xystr,u);
        pdeinfo(str);
      end
    end
  end
end

