function schema
%SCHEMA  Schema for SISO Tool GUI database.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:00:27 $


% Register class 
c = schema.class(findpackage('sisogui'),'sisotool');

% Define public properties
schema.prop(c,'AnalysisView','handle');         % LTI Viewer handle
p = schema.prop(c,'DataViews','MATLAB array');  % Data views (handles)
p.FactoryValue = zeros(0,1);
schema.prop(c,'EventManager','handle');         % Event coordinator (@framemgr object)
schema.prop(c,'Figure','handle');            % Handle of host figure XXX
schema.prop(c,'LoopData','handle');             % Model database
schema.prop(c,'PlotEditors','handle vector');   % Graphical editor handles
schema.prop(c,'TextEditors','handle vector');   % Text editor handles
schema.prop(c,'Preferences','handle');          % Tool-wide preferences

% Define private properties 
p = schema.prop(c,'GlobalMode','string');        % Global edit mode
set(p,'AccessFlags.Init','on','FactoryValue','off');
p = schema.prop(c,'HG','MATLAB array');          % HG objects (struct)
set(p,'AccessFlags.PublicSet','off');
p = schema.prop(c,'Listeners','handle vector');  % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

% Events
schema.event(c,'ShowData');           % Request to show data

