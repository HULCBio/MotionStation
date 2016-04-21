function RefreshModelSummary(this)

% Refresh the summary text in the MPCModels view

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2004/04/19 01:16:28 $


import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

%disp('In RefreshModelSummary')

TextArea = this.Handles.TextArea;
iModel = this.Handles.UDDtable.selectedRow;
if iModel < 1 || iModel > length(this.Models)
    Text = '';
    Notes = '';
else
    Model = this.Models(iModel);
    Text = newModel( Model.Model, Model.Name);
    Notes = Model.Notes;
end
setJavaLogical(TextArea,'setVisible',0);
this.Handles.SummaryText.setText(Text);
this.Handles.NotesArea.setText(Notes);

% SwingUtilities.invokeLater(MLthread(this.Handles.SummaryText,'setText',{Text}));
% SwingUtilities.invokeLater(MLthread(this.Handles.NotesArea,'setText',{Notes}));
SwingUtilities.invokeLater(MLthread(this.Handles.NotesArea, ...
    'setCaretPosition',{int32(0)},'int'));
setJavaLogical(TextArea,'setVisible',1);
% ------------------------------------------------------------------------

function Text = newModel(S,Name)

% Update the LTI model summary view based on the model, S, and the
% Struc containing its description.

% Author(s):   Larry Ricker

if isempty(S)
    Text = '';
else
    Order = [];
    switch class(S)
        case 'ss'
            Type = 'State space (ss)';
            Order = length(S.a);
        case 'tf'
            Type = 'Transfer function (tf)';
        case 'zpk'
            Type = 'Zero/Pole/Gain (zpk)';
        otherwise
            Type = 'Unknown';
    end
    if S.Ts == 0
        Sampling = ':  Continuous';
    else
        Sampling = [':  Discrete with period = ',num2str(S.Ts)];
    end
    Text = sprintf(['Model name = %s<BR>', ...
            'Type = %s<BR>','Number of inputs = %i<BR>', ...
            'Number of outputs = %i<BR>'],...
            Name,Type,length(S.InputName),...
            length(S.OutputName));
    if ~isempty(Order)
        Text = [Text, sprintf('Order = %i<BR>',Order)];
    end
    Text = [Text, sprintf('Sampling%s<BR>', Sampling)];
    if ~isempty(S.Notes)
        for k=1:length(S.Notes)
            Text = [Text, sprintf('%s<BR>',S.Notes{k})];
        end
    end
    Text = [Text, localDisplayNames(S.InputName, 'Input')];
    if isstruct(S.InputGroup)
        Text = [Text, localDisplayGroups(S.InputGroup, 'Input')];
    else
        if ~ isempty(S.InputGroup)
            [m,n]=size(S.InputGroup);
            Text = [Text, sprintf('Input group(s):<BR>')];
            for k=1:m
                Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;%s:  [%i', ...
                    S.InputGroup{k,2}, S.InputGroup{k,1}(1))];
                for j=2:length(S.InputGroup{k,1})
                    Text = [Text, sprintf(' %i',S.InputGroup{k,1}(j))];
                end
                Text = [Text, sprintf(']<BR>')];
            end
        end
    end
    Text = [Text, localDisplayNames(S.OutputName, 'Output')];
    if isstruct(S.OutputGroup)
        Text = [Text, localDisplayGroups(S.OutputGroup, 'Output')];
    else
        if ~ isempty(S.OutputGroup)
            [m,n]=size(S.OutputGroup);
            Text = [Text, sprintf('Output group(s):<BR>')];
            for k=1:m
                Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;%s:  [%i', ...
                    S.OutputGroup{k,2}, S.OutputGroup{k,1}(1))];
                for j=2:length(S.OutputGroup{k,1})
                    Text = [Text, sprintf(' %i',S.OutputGroup{k,1}(j))];
                end
                Text = [Text, sprintf(']<BR>')];
            end
        end
    end
    Text = [Text, sprintf('Maximum input delay:&nbsp;&nbsp;%i<BR>', ...
        max(S.InputDelay))];
    Text = [Text, sprintf('Maximum output delay:&nbsp;&nbsp;%i<BR>', ...
        max(S.OutputDelay))];
    Text = [Text, sprintf('Maximum i/o delay:&nbsp;&nbsp;%i<BR>', ...
        max(max(S.ioDelay)))];
end
Text = htmlText(Text);

% -------------------------------------------------------

function Text = localDisplayGroups(Group, Name)

Text = sprintf('%s group(s):<BR>', Name);
Fields = fieldnames(Group);
if isempty(Fields)
    Text = [Text, sprintf(' (none)  <BR>')];
else
    for k = 1:length(Fields)
        Channels = getfield(Group,Fields{k});
        Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;%s:  [%i', ...
            Fields{k}, Channels(1))];
        for j = 2:length(Channels)
            Text = [Text, sprintf(' %i',Channels(j))];
        end
        Text = [Text, sprintf(']<BR>')];
    end
end

% -------------------------------------------------------

function Text = localDisplayNames(Names, Type)

Text = sprintf('%s name(s):<BR>', Type);
isNone = true;
for i = 1:length(Names)
    if ~isempty(Names{i})
        isNone = false;
        break
    end
end
if isNone
    Text = [Text, sprintf('&nbsp;&nbsp;(none) <BR>')];
else
    Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;{''%s''', ...
        Names{1})];
    for i = 2:length(Names)
        Text = [Text, sprintf(', ''%s''', Names{i})];
    end
    Text = [Text, sprintf('}<BR>')];
end
