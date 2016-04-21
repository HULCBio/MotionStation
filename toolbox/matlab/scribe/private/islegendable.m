function res=islegendable(h,includeImages)
%ISLEGENDABLE Tests if an object should be can in a legend
%    RES = ISLEGENDABLE(H) returns true if graphics object H can
%    be shown in a legend.

%   Copyright 1984-2004 The MathWorks, Inc.

res= true;
switch get(h,'Type')
 case {'line','patch','surface'}
  if ( (isempty(get(h,'xdata')) | isallnan(get(h,'xdata'))) & ...
       (isempty(get(h,'ydata')) | isallnan(get(h,'ydata'))) & ...
       (isempty(get(h,'zdata')) | isallnan(get(h,'zdata'))) ) || ...
        ~hasbehavior(h,'legend')
    res = false;
  end
 case {'hggroup','hgtransform'}
  if ~hasbehavior(h,'legend') || ~isappdata(double(h),'LegendLegendInfo')
    res = false;
  end
 case {'image'}
  if ~includeImages || ~hasbehavior(h,'legend')
    res = false;
  end
otherwise
  res = false;
end

%----------------------------------------------------------------%
function allnan = isallnan(d)

nans = isnan(d);
allnan = all(nans(:));
