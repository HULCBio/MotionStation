function LinearAnalysis = LinearizeModel(this)
%% Method to linearize the simulink model and return a linearization node.

%  Author(s): John Glass
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/10 23:36:29 $

import java.lang.*;

%% Get the linearization IO
io = this.IOData;

%% Create a new analysis result node
LinearAnalysis = mpcnodes.LinearAnalysisResultNode('1');
LinearAnalysis.Model = this.Model;

%% Get the operating point object
op = this.OPPoint;

%% Linearize the model
[sys,J] = linearize(this.Model,op,io);

%% Store operating condition note
sys.Notes = 'Operating Condition';

%% Create the new operating conditions results or value panel depending
%% on whether a opreport is available. Note that the getDialogSchema method
%% of a OperConditionResultPanel will fail if the OPReport is empty
if ~isempty(this.OPReport)
   node = OperatingConditions.OperConditionResultPanel('Operating Point'); 
   set(node,'OpReport',copy(this.OPReport),'OpPoint', copy(this.OPPoint));
else
   node = OperatingConditions.OperConditionValuePanel(copy(this.OPPoint),'Operating Point'); 
end


%% Add it to the Linearization Result node
LinearAnalysis.addNode(node);

%% Add the data the linearization results node
LinearAnalysis.LinearizedModel = sys;
LinearAnalysis.ModelJacobian = J;
LinearAnalysis.getInspectorPanelData;