function str = getDatatipText(this,dataCursor)
%GETDATATIPTEXT Get quiver datatip text
  
%   Copyright 1984-2003 The MathWorks, Inc. 

res = 3;

is3D = ~isempty(this.ZData);

x = get(this,'XData'); y = get(this,'YData');
u = get(this,'UData'); v = get(this,'VData');

% DataIndex was computed in updateDataCursor
ind = dataCursor.DataIndex;

xx = num2str(x(ind),res); yy = num2str(y(ind),res);
uu = num2str(u(ind),res); vv = num2str(v(ind),res);

if ~is3D
  str = { ['[X,Y] = ', xx, ',  ', yy],...
          ['[U,V] = ', uu, ',  ', vv]};
else
  z = get(this,'ZData'); zz = num2str(z(ind),res);
  w = get(this,'WData'); ww = num2str(w(ind),res);
  str = { ['[X,Y,Z] = ', xx, ',  ', yy, ',  ',zz],...
          ['[U,V,W] = ', uu, ',  ', vv, ',  ',ww]};
end
