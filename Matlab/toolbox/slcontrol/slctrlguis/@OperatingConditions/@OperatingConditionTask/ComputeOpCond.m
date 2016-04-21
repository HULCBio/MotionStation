function ComputeOpCond(this)
%% Method to compute the operating conditions of a Simulink model.

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.

import java.lang.*;

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Evaluate the optmization parameters
options = this.Options;
optimoptions = options.OptimizationOptions;

%% Get the last value for the error
lsterr = lasterror;
lasterr('')
optimoptions.DiffMaxChange = LocalCheckValidScalar(this.OptimChars.DiffMaxChange,...
                                            'Maximum change');
optimoptions.DiffMinChange = LocalCheckValidScalar(this.OptimChars.DiffMinChange,...
                                            'Minimum change');
optimoptions.MaxFunEvals = LocalCheckValidScalar(this.OptimChars.MaxFunEvals,...
                                            'Maximum fcn evals');
optimoptions.MaxIter = LocalCheckValidScalar(this.OptimChars.MaxIter,...
                                            'Maximum iterations');
optimoptions.TolFun = LocalCheckValidScalar(this.OptimChars.TolFun,...
                                            'Function tolerance');
optimoptions.TolX = LocalCheckValidScalar(this.OptimChars.TolX,...
                                            'Parameter tolerance');
lsterror = lasterror;
if ~isempty(lsterror.message)
    errordlg(lsterror.message,'Simulink Control Design')
    return
end
lasterror(lsterr)

%% Store the updated structure
options.OptimizationOptions = optimoptions;

%% Get the settings node and its dialog interface
di = this.OpCondSpecPanelUDD;

%% Trim the model first
ExplorerFrame.postText(sprintf(' - Computing operating point for the model: %s.',this.Model))
%% Update the operating condition object
try
    lasterr('');
    opcopy = updateopcond(this);
catch
    errordlg(lasterr,'Simulink Control Design');
    return
end
try
    if strcmp(this.Options.DisplayReport,'iter')
        %% Get the handle to the status area
        StatusArea = this.OpCondSpecPanelUDD.getStatus;
        StatusArea.clearText
        %% Select the optimization output panel
        awtinvoke(this.OpCondSpecPanelUDD.OpConstrPanel,'setSelectedIndex',3);
        %% Run the optimization
        [oppoint,opreport] = findop(opcopy.Model,opcopy,this.options,...
            {@LocalDisplayIteration,this,StatusArea},...
            {@LocalStopOptimization, this.ComputeOpCondButtonUDD});
    else
        %% Get the handle to the status area
        StatusArea = this.OpCondSpecPanelUDD.getStatus;
        StatusArea.clearText
        %% Run the optimization
        [oppoint,opreport] = findop(opcopy.Model,opcopy,this.options);
    end

                                        
    %% Create the operating conditions result node
    Label = this.createDefaultName('Operating Point', this);
    node = OperatingConditions.OperConditionResultPanel(Label);
    %% Post the summary
    if strcmp(this.Options.DisplayReport,'iter')
        LocalDisplayIteration(this,StatusArea,{''})
        LocalDisplayIteration(this,StatusArea,{opreport.TerminationString})
        LocalDisplayIteration(this,StatusArea,{''})
        %% Create the string to display the new node
        str = sprintf('An operating point <a href="childnode:%s">%s</a> has been added to the node Operating Points.', Label, Label);
        LocalDisplayIteration(this,StatusArea,{str})
        %% Clear the display buffer since the optimizatio is finished
        this.StatusAreaText = {};    
    end
catch
    lsterror = lasterror;
    if strcmp(lsterror.identifier,'slcontrol:operspec:NeedsUpdate')
        str = sprintf(['Your Simulink model %s is out of sync with your operating ',...
            'point specifications.  Please sync before computing.'],...
            this.Model);
        errordlg(str, 'Simulink Control Design')
        return
    else
        str = sprintf(['An error occured during the search for your operating  ',...
            'point: \n\n %s'],lsterror.message);
        errordlg(str, 'Simulink Control Design')
        return
    end
end

%% Store the operating point
node.OpPoint = oppoint;

%% Store the operating point report
node.OpReport = opreport;
node.Description = opreport.TerminationString;

%% Add it to the node
this.addNode(node);

%% Set the dirty flag
this.setDirty

%% Expand the analysis nodes so the user sees the new result
ExplorerFrame.expandNode(this.getTreeNodeInterface);

%% Send update to tell the user that a node has been added
ExplorerFrame.postText(sprintf(' - An operating point called "%s" has been added to the node Operating Points.', Label))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCheckValidScalar Check for valid workspace scalar variable
function value = LocalCheckValidScalar(str,property)

try
    value = evalin('base',str);
catch
    lastmsg = lasterr;
    err = sprintf(['Error evaluating the property %s in the operating ',...
                    'point search dialog. %s'],property,lastmsg);
    lasterr(err);
    value = [];
    return
end

if (~isa(value,'double') || length(value) ~= 1)
    lasterr(sprintf(['The variable %s for the property %s must be ',...
                'a double of length 1'],str,property),...
            'slcontrol:OptimizationOptions:InvalidLength');
    value = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDisplayIteration
function LocalDisplayIteration(this,StatusArea,str)

for ct = 1:length(str)
    this.StatusAreaText{end+1} = str{ct};
end
StatusArea.setContent(this.StatusAreaText);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalStopOptimization
function stop = LocalStopOptimization(button)

if button.isSelected
    stop = false;
else
    stop = true;
end
