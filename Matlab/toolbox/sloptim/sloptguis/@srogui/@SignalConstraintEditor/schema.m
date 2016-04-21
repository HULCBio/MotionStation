function schema
%SCHEMA  Schema for constraint editor object

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('srogui'),'SignalConstraintEditor');

% Constraint
schema.prop(c,'Constraint','handle');                % @SignalConstraint object
p = schema.prop(c,'LowerBound','MATLAB array');      % Struct of Surfaces and Lines
p.FactoryValue = struct('Surf',cell(0,1),'Line',[]);
p = schema.prop(c,'UpperBound','MATLAB array');      % Struct of Surfaces and Lines
p.FactoryValue = struct('Surf',cell(0,1),'Line',[]);

% Reference signal (desired response)
% Mx1 if M channels
schema.prop(c,'Reference','handle vector');  

% Callback for "Plot Current Response" menu
p = schema.prop(c,'RespFcn','MATLAB array');     

% Test views
p = schema.prop(c,'TestViews','MATLAB array');  
p.FactoryValue = struct('Test',cell(0,1),'Response',[],'Optimization',[]);
% Response: Current response (MxR line vector if M channels and R runs)
% Optimization: Optimization trace (MxRxN line array if M channels, R runs,
%               and N intermediate steps are logged, N=1->initial response)

% Plot visibility
p = schema.prop(c,'InitVisible','on/off');   
p.FactoryValue = 'on';
p.SetFunction = @localToggleInit;
p = schema.prop(c,'OptimVisible','on/off');   
p.FactoryValue = 'on';
p.SetFunction = @localToggleTrace;
p = schema.prop(c,'RefVisible','on/off');     
p.FactoryValue = 'on';
p.SetFunction = @localToggleRef;
p = schema.prop(c,'TestVisible','string vector');     
p.SetFunction = @localToggleTestVis;


% Background
schema.prop(c,'Axes','handle');        % @axes object
schema.prop(c,'Parent','handle');      % Store handle for parent figure
schema.prop(c,'Recorder','handle');    % Action recorder (for undo/redo)
schema.prop(c,'EditDialog','handle');  % Edit constraint dialog
schema.prop(c,'SpecDialog','handle');  % Desired response dialog

% Limits
schema.prop(c,'XFocus','MATLAB array'); % Response time range

% Listeners
p = schema.prop(c,'Listeners','MATLAB array');   
p.FactoryValue = struct('Fixed',[],'Project',[],'Source',[]);


%--------------- Local Functions -------------------------

function Vis = localToggleRef(this,Vis)
% Shows/hide reference signal
if ~isempty(this.Reference)
   set(this.Reference,'Visible',Vis)
   this.Axes.send('ViewChanged')
end


function Vis = localToggleInit(this,Vis)
% Shows/hide initial response
NeedRefresh = false;
for ct=1:length(this.TestViews)
   OptimTrace = this.TestViews(ct).Optimization;
   if ~isempty(OptimTrace) && strcmp(this.TestVisible{ct},'on')
      set(OptimTrace(:,:,1),'Visible',Vis)
      NeedRefresh = true;
   end
end
if NeedRefresh
   this.Axes.send('ViewChanged')
end


function Vis = localToggleTrace(this,Vis)
% Shows/hide optimization trace
NeedRefresh = false;
for ct=1:length(this.TestViews)
   OptimTrace = this.TestViews(ct).Optimization;
   if size(OptimTrace,3)>1 && strcmp(this.TestVisible{ct},'on')
      set(OptimTrace(:,:,2:end),'Visible',Vis)
      NeedRefresh = true;
   end
end
if NeedRefresh
   this.Axes.send('ViewChanged')
end


function Vis = localToggleTestVis(this,Vis)
% Shows/hide individual tests
for ct=1:length(Vis)
   % Response
   set(this.TestViews(ct).Response,'Visible',Vis{ct})
   % Optimization trace
   Trace = this.TestViews(ct).Optimization;
   set(Trace,'Visible',Vis{ct})
   if strcmp(Vis{ct},'on') && ~isempty(Trace)
      % Reapply InitVisible/OptimVisible seetings
      set(Trace(:,:,1),'Visible',this.InitVisible)
      set(Trace(:,:,2:end),'Visible',this.OptimVisible)
   end
end
this.Axes.send('ViewChanged')   
