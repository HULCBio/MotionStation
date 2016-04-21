function newModel(this,S,Struc)

% newModel(this,S,Struc)
%
% Update the LTI model summary view based on the model, S, and the
% Struc containing its description.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.5 $ $Date: 2003/12/04 01:35:47 $

if isempty(S)
    this.jText.setText('');
else
    Order = [];
    switch Struc.class
        case 'ss'
            Type = 'State space (ss)';
            Order = length(S.a);
        case 'tf'
            Type = 'Transfer function (tf)';
        case 'zpk'
            Type = 'Zero/Pole/Gain (zpk)';
        case 'mpc'
            Text = evalc('display(S)');
            Text = strrep(Text,sprintf('\n'),'<BR>');
            this.jText.setText(htmlText(Text));
            return
        case 'mpcobjects.project'
            Text = LocalProjectProperties(S);
            this.jText.setText(htmlText(Text));
            return
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
            Struc.name,Type,length(S.InputName),...
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
    this.jText.setText(htmlText(Text));
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

% -------------------------------------------------------

function Text = localDisplayGroups(Group, Name)

Text = sprintf('%s group(s):<BR>', Name);
Fields = fieldnames(Group);
if isempty(Fields)
    Text = [Text, sprintf('&nbsp;&nbsp;(none) <BR>')];
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

function Text = LocalProjectProperties(S)

Text = sprintf('Created:  %s<BR>', S.Root.Fields{1,2});
Text = [Text, sprintf('Updated:  %s<BR>', S.Root.Fields{2,2})];
Text = [Text, sprintf(['%i Input(s):  %i manipulated variables,', ...
    ' %i measured disturbances, %i unmeasured disturbances<BR>'], ...
    S.Root.Fields{4,2}([6,1:3]))];
Text = [Text, sprintf('%i Outputs:  %i measured, %i unmeasured<BR>', ...
    S.Root.Fields{4,2}([7, 4:5]))];
Text = [Text, sprintf('%i Controller(s):<BR>', length(S.Controllers))];
for i = 1:length(S.Controllers)
    Text = [Text, sprintf('%s<BR>', S.Controllers{i}.Label)];
end
Text = [Text, sprintf('%i Scenario(s):<BR>', length(S.Scenarios))];
for i = 1:length(S.Scenarios)
    Text = [Text, sprintf('%s<BR>', S.Scenarios{i}.Label)];
end
