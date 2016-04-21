function LabelMap = DefaultLabelFcn(this)
%DEFAULTLABELFCN  Default implementation of LabelFcn.
%
%   Maps label, units, and transform properties into HG label contents.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:26 $

LabelMap = struct(...
   'XLabel',sprintf('%s%s',this.XLabel,LocalUnitInfo(this.XUnits)),...
   'XLabelStyle',this.XLabelStyle,...
   'YLabel',{{sprintf('%s%s',this.YLabel{1},LocalUnitInfo(this.YUnits{1}));...
      sprintf('%s%s',this.YLabel{2},LocalUnitInfo(this.YUnits{2}))}},...
   'YLabelStyle',this.YLabelStyle);
   
%---------- Local Functions ---------------------------

function str = LocalUnitInfo(unit)
% Returns string capturing unit and transform info
if isempty(unit)
   str = '';
else
   str = sprintf(' (%s)',unit);
end