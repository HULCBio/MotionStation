function schema
% Class for signal constraint block dialog.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:44:30 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('srogui'),'SignalConstraintDialog');

% Block name
schema.prop(c,'Block','string');

% Constraint currently associated with block (@SignalConstraint)
schema.prop(c,'Constraint','handle');
% Constraint editor (@SignalConstraintEditor)
schema.prop(c,'Editor','handle');
% Associated @SimProjectForm
schema.prop(c,'Project','handle');

% Figure
schema.prop(c,'Figure','handle');  

% Dialogs
p = schema.prop(c,'Dialogs','MATLAB array');  
p.FactoryValue = struct('Load',[],'Save',[],'Batch',[]);

% Listeners
p = schema.prop(c,'Listeners','MATLAB array');   
p.FactoryValue = struct('Fixed',[],'Project',[],'Source',[]);

% Runtime project (@SimProject)
schema.prop(c,'RunTimeProject','handle');


