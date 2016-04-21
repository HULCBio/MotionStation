function colorbarpostdeserialize(ax,action)
%COLORBARPOSTDESERIALIZE Post-deserialization hook for colorbar
%   Internal helper function for colorbar.

%   Deletes the supplied colorbar and creates a new one in the same
%   place so that all the state and listeners are properly created.

%   Copyright 1984-2003 The MathWorks, Inc.

ax = handle(ax);
cbarinfo = methods(ax,'postdeserialize');

delete(double(cbarinfo.cbar));

if strcmp(action,'paste')
  cbarinfo.ax = gca;
end

if strcmpi(cbarinfo.location,'manual')
  colorbar('peer',cbarinfo.ax,cbarinfo.position);
else
  colorbar('peer',cbarinfo.ax,cbarinfo.location);
end
