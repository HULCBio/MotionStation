function pt = getprinttemplate( h )
%GETPRINTTEMPLATE Get a figure's PrintTemplate

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 17:08:27 $

pt = get(h, 'PrintTemplate');
if ~isempty(pt)
  if isfield(pt,'VersionNumber')
    ver = pt.VersionNumber;
  else
    ver = nan;
  end
  if isnan(ver)
    ptnew = printtemplate;
    ptnew.Name = pt.Name;
    ptnew.FrameName = pt.FrameName;
    if pt.DriverColor
      ptnew.DriverColor = 1;
    else
      ptnew.DriverColor = 0;
    end
    ptnew.AxesFreezeTicks = pt.AxesFreezeTicks;
    ptnew.AxesFreezeLimits = pt.AxesFreezeLimits;
    pt = ptnew;
  end
end