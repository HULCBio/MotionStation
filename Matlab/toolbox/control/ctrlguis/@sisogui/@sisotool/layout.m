function layout(sisodb)
%LAYOUT  Positions graphical editors in SISO Tool figure.

%   Author(s): K. Gondoy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 04:58:55 $

% Active editors
isActive = strcmp(get(sisodb.PlotEditors,'Visible'),'on');
ActivePlotEditors = find(isActive);
NumActive = length(ActivePlotEditors);

% Parameters for layout geometry
FigPos = get(sisodb.Figure,'Position');
FigW = FigPos(3);
FigH = FigPos(4);
Border = 3;  % 3 character border
if NumActive==1 | FigW>120
    hOffset = 8;   % Offset for LHS axis border
    YlabelVis = repmat({'on'},[NumActive 1]);
else    
    % Don't display Y labels if figure is too small
    hOffset = 4;  
    YlabelVis = repmat({'off'},[NumActive 1]);
end
if NumActive<=2 | FigH>40
    vOffset = 5;   % Offset for vertical axis spacing
    SepXlabelVis = 'on'; 
else    
    % Don't display X labels if figure is too small
    vOffset = 3;  
    SepXlabelVis = 'off';
end
AxesW1 = FigW-2*Border-hOffset;        % Axes width in single-column config
AxesW2 = (FigW-3*Border-2*hOffset)/2;  % Axes width in two-column config
AxesH1 = FigH-13;                      % Axes height in single-row config
AxesH2 = (FigH-13-vOffset)/2;          % Axes height in two-row config

% Compute new normalized positions
Xs1 = Border+hOffset;
Xs2 = FigW-Border-AxesW2;
switch NumActive
case 1
    XlabelVis = {'on'};
    NewPos = {[Xs1 5.8 AxesW1 AxesH1]};
case 2
    XlabelVis = {'on';'on'};
    NewPos = {[Xs1 5.8 AxesW2 AxesH1] ; [Xs2 5.8 AxesW2 AxesH1]};
case 3
    XlabelVis = {SepXlabelVis;'on';'on'};
    NewPos = {[Xs1 5.8+AxesH2+vOffset AxesW2 AxesH2] ; ...
            [Xs1 5.8 AxesW2 AxesH2] ; ...
            [Xs2 5.8 AxesW2 AxesH1]};
    % If Bode Editor is active, make sure it uses the full height
    idx = ActivePlotEditors(LocalFindMultiAxis(sisodb.PlotEditors(ActivePlotEditors)));
    if ~isempty(idx)
        ActivePlotEditors = [ActivePlotEditors(ActivePlotEditors~=idx);idx];
    end
case 4
    XlabelVis = {SepXlabelVis;'on';SepXlabelVis;'on'};
    NewPos = {[Xs1 5.8+AxesH2+vOffset AxesW2 AxesH2] ; [Xs1 5.8 AxesW2 AxesH2] ;...
            [Xs2 5.8+AxesH2+vOffset AxesW2 AxesH2] ; [Xs2 5.8 AxesW2 AxesH2]};
end


% Reset positions of active editors and adjust label visibility
% RE: axes position is expected in normalized units!
for ct=1:NumActive,
    Editor = sisodb.PlotEditors(ActivePlotEditors(ct));
    % New position
    Editor.Axes.Position = NewPos{ct}./[FigW FigH FigW FigH];
    % Label visibility
    Editor.xylabelvis(XlabelVis{ct},YlabelVis{ct})
end


%----------------------- Local functions ----------------------------------

function idx = LocalFindMultiAxis(ActiveEditors);

idx = [];
for ct=1:length(ActiveEditors)
    if length(getaxes(ActiveEditors(ct).Axes))>1
        idx = ct;  break;
    end
end
