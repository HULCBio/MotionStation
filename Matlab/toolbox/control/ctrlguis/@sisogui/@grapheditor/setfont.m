function setfont(Editor,Component,Property,Value)
% Sets font for designated editor component

%   Author(s): P. Gahinet
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2001/08/18 22:43:45 $

switch Component
case 'title'
    % Title font
    % Revisit: merge
    Title = Editor.Title;
    Title = setfield(Title,Property,Value);
    Editor.Title = Title;
case 'xylabel'
    % XY label font
    % Revisit: merge
    Xlabel = Editor.Xlabel;
    Xlabel = setfield(Xlabel,Property,Value);
    Editor.Xlabel = Xlabel;
    Ylabel = Editor.Ylabel;
    Ylabel = setfield(Ylabel,Property,Value);
    Editor.Ylabel = Ylabel;
case 'axes'
    % Tick label font
    HG = Editor.HG;
    % Axes tick labels
    set(Editor.hgget_axeshandle,Property,Value)
    % Grid labels
    if isfield(HG,'GridLines')
        set(findobj(HG.GridLines,'Type','text'),Property,Value)
    end
end

