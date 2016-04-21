function update(Editor,varargin)
%UPDATE  Updates PZ editor.

%   Author(s): Karen Gondoly. 
%              P. Gahinet (UDD implementation)
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/10 04:55:16 $

% Create editor if does not exist
InitFlag = isempty(Editor.HG);
if InitFlag
    Editor.initialize;
end

% Find groups with zeros and groups with poles
zGroups = find(~cellfun('isempty',get(Editor.PZGroup,{'Zero'})));
pGroups = find(~cellfun('isempty',get(Editor.PZGroup,{'Pole'})));  

% Adjust window layout (adds zero and pole edit boxes)
Editor.layout(length(zGroups),length(pGroups));

% Install CS help
% RE: Do this last after creating all UI controls for proper init 
%     when the PZ Editor is opened with CS help already on
if InitFlag
    cshelp(Editor.HG.Figure,Editor.Parent.Figure);
end

% Update edit box contents and adjust test/box visibility
HG = Editor.HG;
LocalUpdateRows('Zero',HG.ZeroEdit,Editor.PZGroup(zGroups),Editor);
LocalUpdateRows('Pole',HG.PoleEdit,Editor.PZGroup(pGroups),Editor);
        
% Update gain box
Gain = Editor.EditedObject.getgain;
set(HG.TopHandles(3),'String',sprintf('%0.3g',Gain),'UserData',Gain)


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateRows %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateRows(PZID,hArray,Groups,Editor)
% Syncs contents of Zeros/Poles area with internal P/Z data

Ng = length(Groups);

% Update edit box contents
for ct=1:Ng,
    hbox = hArray(ct,[2 4]);
    LocalUpdate(hbox,Groups(ct),Editor)
    % Set edit box callback
    set(hbox,'Callback',{@LocalEdit Editor Groups(ct)})
    % Add data listeners 
    set(hArray(ct,1),'UserData',...
        handle.listener(Groups(ct),findprop(Groups(ct),PZID),...
        'PropertyPostSet',{@LocalDataChanged hbox Editor}));
end

% Adjust visibility of text and edit boxes
switch Editor.Format
case 'RealImag'
    for ct=1:Ng,
        g = Groups(ct);
        if any(strcmp(g.Type,{'Real','LeadLag'}))
            set(hArray(ct,3:5),'Visible','off')
        else
            set(hArray(ct,3:5),'Visible','on')
        end
    end
case 'Damping'
    set(hArray(:,[3 5]),'Visible','off')
    set(hArray(:,4),'Visible','on')
end


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDataChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDataChanged(hProp,event,hbox,Editor)
% Callback when modifying group data
LocalUpdate(hbox,event.AffectedObject,Editor)


%%%%%%%%%%%%%%%%%%%
%%% LocalUpdate %%%
%%%%%%%%%%%%%%%%%%%
function LocalUpdate(hbox,g,Editor)
% Updates edit box content

% Get data
PZType = get(hbox(1),'Tag');
r = get(g,PZType);
if isempty(r)
    % Happens when part of notch or lead/lag group is deleted
    return
else
    r = r(1);
end

% Update contents
if isfinite(r)
    % Using NaN for empty boxes...
    switch Editor.Format
    case 'RealImag'
        set(hbox(1),'String',sprintf('%0.3g',real(r)))
        set(hbox(2),'String',sprintf('%0.3g',abs(imag(r))))
    case 'Damping'
        [Wn,Zeta] = damp(r,Editor.EditedObject.Ts);
        set(hbox(1),'String',sprintf('%0.3g',Zeta))
        set(hbox(2),'String',sprintf('%0.3g',...
            unitconv(Wn,'rad/sec',Editor.FrequencyUnits)))
    end
else
    set(hbox,'String','')
end


%%%%%%%%%%%%%%%%%
%%% LocalEdit %%%
%%%%%%%%%%%%%%%%%
function LocalEdit(hEdit,event,Editor,Group)
% Edit pole or zero data
Editor.editpz(hEdit,Group);

