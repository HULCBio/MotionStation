function Editor = layout(Editor,NZ,NP)
%LAYOUT  Lays out edit boxes for pole/zero editing.
%
%   NZ and NP are the desired number of rows in the Zeros
%   and Poles areas.

%   Author(s): Karen Gondoly, P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:55:19 $

HG = Editor.HG;
NZ0 = size(HG.ZeroEdit,1);  % current # rows
NP0 = size(HG.PoleEdit,1);
Nrows = max(NZ,NP);

% Adjust number of rows in zero and pole frames
if NZ~=NZ0 | NP~=NP0
    % Delete excess rows
    delete(HG.ZeroEdit(NZ+1:NZ0,:))
    delete(HG.PoleEdit(NP+1:NP0,:))
    HG.ZeroEdit(NZ+1:NZ0,:) = [];
    HG.PoleEdit(NP+1:NP0,:) = [];
    
    % Set figure dimension
    FigPos = get(HG.Figure,'Position');
    FigureHeight = 12 + 2*Nrows;
    Offset = FigureHeight - FigPos(4);
    FigPos(4) = FigureHeight;
    set(HG.Figure,'Position',FigPos)
    
    % Adjust vertical size
    FrameHeight = 6 + 2*Nrows;
    set(HG.ZPFrame,{'Position'},...
        {[0.8 2.6 44 FrameHeight];[45.8 2.6 44 FrameHeight]});
    
    % Shift top handles
    ShiftHandles = [HG.TopHandles;...
            HG.ZPText(:);...
            HG.ZeroEdit(:);...
            HG.PoleEdit(:)];
    LocalShiftPosition(ShiftHandles,Offset)
    
    % Create additional edit boxes if necessary
    HG.ZeroEdit = [HG.ZeroEdit ; ...
            LocalCreatePZ(HG.Figure,4,FrameHeight,NZ0,NZ-NZ0)];
    set(HG.ZeroEdit(NZ0+1:NZ,2),'Tag','Zero','UserData',1)
    set(HG.ZeroEdit(NZ0+1:NZ,4),'Tag','Zero','UserData',2)
    HG.PoleEdit = [HG.PoleEdit ; ...
            LocalCreatePZ(HG.Figure,49,FrameHeight,NP0,NP-NP0)];
    set(HG.PoleEdit(NP0+1:NP,2),'Tag','Pole','UserData',1)
    set(HG.PoleEdit(NP0+1:NP,4),'Tag','Pole','UserData',2)
end

% Adjust labels
switch Editor.Format
case 'RealImag'
    % Set text labels
    set(HG.ZPText(3,:),'String','Real')
    set(HG.ZPText(4,:),'String','Imaginary')
case 'Damping'
    % Set text labels
    set(HG.ZPText(3,:),'String','Damping')
    set(HG.ZPText(4,:),'String','Natural Freq.')
end

% Update HG database
Editor.HG = HG;


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShiftPosition %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShiftPosition(Handles,Offset)

for i=1:length(Handles)
   Pos = get(Handles(i),'Position');
   Pos(2) = Pos(2) + Offset;
   set(Handles(i),'Position',Pos)
end

%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreatePZ %%%
%%%%%%%%%%%%%%%%%%%%%
function Handles = LocalCreatePZ(PZfig,X0,FrameHeight,RowOffset,nRows)

Handles = zeros(nRows,5);
StdUnit = get(PZfig,'Units');

for ct=1:nRows
    Y0 = FrameHeight-(RowOffset+ct)*2;
    Handles(ct,1) = uicontrol('Parent',PZfig, ...
        'Units',StdUnit, ...
        'Position',[X0 Y0 3 1.5], ...
        'HelpTopicKey','sisopolezerodelete',...
        'Style','checkbox','Visible','off');
    Handles(ct,2) = uicontrol('Parent',PZfig, ...
        'Units',StdUnit, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Position',[X0+6 Y0 14 1.5], ...
        'HelpTopicKey','sisoeditcompensator',...
        'Style','edit','Visible','off');
    Handles(ct,3) = uicontrol('Parent',PZfig, ...
        'Units',StdUnit, ...
        'Position',[X0+20 Y0 3 1.5], ...
        'String',char(177), ...
        'HelpTopicKey','sisoeditcompensator',...
        'Style','text','Visible','off');
    Handles(ct,4) = uicontrol('Parent',PZfig, ...
        'Units',StdUnit, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Position',[X0+23.2 Y0 14 1.5], ...
        'HelpTopicKey','sisoeditcompensator',...
        'Style','edit','Visible','off');
    Handles(ct,5) = uicontrol('Parent',PZfig, ...
        'Units',StdUnit, ...
        'Position',[X0+37.5 Y0 3 1.5], ...
        'String','i', ...
        'HelpTopicKey','sisoeditcompensator',...
        'Style','text','Visible','off');
end

set(Handles(:,[1 2]),'Visible','on')


