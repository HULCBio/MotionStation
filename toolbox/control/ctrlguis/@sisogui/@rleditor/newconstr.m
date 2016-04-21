function out = newconstr(Editor,keyword,CurrentConstr)
%NEWCONSTR  Interface with dialog for creating new constraints.
%
%   LIST = NEWCONSTR(Editor) returns the list of all available 
%   constraint types for this editor.
%
%   CONSTR = NEWCONSTR(Editor,TYPE) creates a constraint of the 
%   specified type.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/05/14 06:04:39 $

% RE: Editor.newconstr(type,currentconstr) is reserved for calls by newdlg
ni = nargin;
if ni==1
    % Return list of valid constraints
    out = {'Settling Time';'Percent Overshoot';'Damping Ratio';'Natural Frequency'};
else
    switch keyword
        case 'Settling Time'
            Class = 'plotconstr.pzsettling';
        case {'Damping Ratio','Percent Overshoot'}
            Class = 'plotconstr.pzdamping';
        case 'Natural Frequency'
            Class = 'plotconstr.pzfrequency';
    end
    % Create instance
    if ni>2 & isa(CurrentConstr,Class)
        % Recycle existing instance if of same class
        Constr = CurrentConstr;  
    else
        % Create new instance
        Constr = feval(Class); 
        if strcmp(keyword,'Natural Frequency')
            Constr.FrequencyUnits = Editor.FrequencyUnits;
            % Install temp. listener to track freq. units in newdlg (will be cleared by initialize)
            Constr.Listeners = handle.listener(Editor,Editor.findprop('FrequencyUnits'),...
                'PropertyPostSet',{@LocalUpdate Constr});
        end
    end
    % Fine tuning
    switch keyword
        case 'Damping Ratio'
            Constr.Format = 'damping';
        case 'Percent Overshoot'
            Constr.Format = 'overshoot';
    end
    % Attach to editor axes
    Constr.Parent = getaxes(Editor.Axes);
    out = Constr;
end



%-------------------- Local functions ---------------------------------

%%%%%%%%%%%%%%%%%
%% LocalUpdate %%
%%%%%%%%%%%%%%%%%
function LocalUpdate(eventSrc,eventData,Constr);
% Syncs constraint props with related Editor props
set(Constr,eventSrc.Name,eventData.NewValue);

