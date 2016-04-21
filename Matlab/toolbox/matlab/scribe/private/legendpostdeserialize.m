function legendpostdeserialize(ax,action)
%LEGENDPOSTDESERIALIZE Post-deserialization hook for legend
%   Internal helper function for legend.

%   Deletes the supplied legend and creates a new one in the same
%   place so that all the state and listeners are properly created.

%   Copyright 1984-2004 The MathWorks, Inc. 

ax = handle(ax);
leginfo = methods(ax,'postdeserialize');
delete(double(leginfo.leg));
if strcmp(action,'paste')
  leginfo.ax = gca;
end
props = leginfo.viewprops;
vals = leginfo.viewvals;
pvpairs = {props{:} ; vals{:}};
pvpairs = pvpairs(:).';
if strcmpi(leginfo.loc,'none')
  h = legend(leginfo.ax,leginfo.plotchildren,leginfo.strings);
  % setting Units twice assumes UDD doesn't coalesce the units
  pvpairs = {pvpairs{:},'Units','points',...
             'Position',leginfo.position,'Units',leginfo.units};
else
  h = legend(leginfo.ax,leginfo.plotchildren,leginfo.strings,...
         'Location',leginfo.loc);
end
set(h,pvpairs{:});
