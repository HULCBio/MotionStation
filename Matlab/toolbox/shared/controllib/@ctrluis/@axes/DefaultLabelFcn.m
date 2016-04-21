function LabelMap = DefaultLabelFcn(this)
%DEFAULTLABELFCN  Default implementation of LabelFcn.
%
%   Maps label, units, and transform properties into HG label contents.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:23 $

LabelMap = struct(...
   'XLabel',sprintf('%s%s',this.XLabel,LocalUnitInfo(this.XUnits)),...
   'XLabelStyle',this.XLabelStyle,...
   'YLabel',sprintf('%s%s',this.YLabel,LocalUnitInfo(this.YUnits)),...
   'YLabelStyle',this.YLabelStyle);

%---------- Local Functions ---------------------------

function str = LocalUnitInfo(unit)
% Returns string capturing unit and transform info
if isempty(unit)
   str = '';
else
   str = sprintf(' (%s)',unit);
end