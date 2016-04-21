function hgset_labels(Editor,NewSettings,LabelType)
% HG rendering of editor's Title, Xlabel, and Ylabel properties.

%   $Revision: 1.5 $  $Date: 2001/08/10 21:07:58 $
%   Copyright 1986-2001 The MathWorks, Inc.

MagOn = strcmp(Editor.MagVisible,'on');
PhaseOn = strcmp(Editor.PhaseVisible,'on');

% HG data
HG = Editor.HG;
hLabel = get(Editor.hgget_axeshandle,LabelType);  % HG title handles

% Update HG title, xlabel, or ylabel 
switch LabelType
case 'Ylabel'
    % Special treatment needed for label strings
    NewLabelStrings = NewSettings.String;
    % Ylabel for mag axes
    NewSettings.String = NewLabelStrings{1};
    set(hLabel{1},NewSettings)
    % Ylabel for mag axes
    NewSettings.String = NewLabelStrings{2};
    set(hLabel{2},NewSettings)
otherwise       
    set([hLabel{:}],NewSettings)
end


% Adjust label visibility
if strcmp(Editor.Visible,'off')
    % Turn all labels off
    set([hLabel{:}],'Visible','off')
else
    % Visibility is conditioned by mag/phase visibility
    switch LabelType
    case 'Title'
        if MagOn
            set(hLabel{1},'Visible','on')
            set(hLabel{2},'Visible','off')
        elseif PhaseOn
            set(hLabel{1},'Visible','off')
            set(hLabel{2},'Visible','on')
        end
    case 'Xlabel'
        if PhaseOn
            set(hLabel{1},'Visible','off')
            set(hLabel{2},'Visible','on')
        elseif MagOn
            set(hLabel{1},'Visible','on')
            set(hLabel{2},'Visible','off')
        end
    case 'Ylabel'
        LabVis = {NewSettings.Visible;NewSettings.Visible};
        LabVis([~MagOn ~PhaseOn]) = {'off'};
        set([hLabel{:}],{'Visible'},LabVis)
    end
end

