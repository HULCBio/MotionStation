function setlabels(this,varargin)
%SETLABELS  Updates visibility, style, and contents of HG labels.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:34 $

% Reapply styles and contents
hgax = this.Axes2d;
% Title
set(get(hgax,'Title'),'String',this.Title,struct(this.TitleStyle))

% X and Y labels
LabelMap = feval(this.LabelFcn{:});
set(get(hgax,'XLabel'),'String',LabelMap.XLabel,struct(LabelMap.XLabelStyle))
set(get(hgax,'YLabel'),'String',LabelMap.YLabel,struct(LabelMap.YLabelStyle))