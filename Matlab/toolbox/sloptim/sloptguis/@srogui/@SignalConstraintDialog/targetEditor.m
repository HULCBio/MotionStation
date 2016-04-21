function targetEditor(this)
% Hooks up constraint editor to spec/project events.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:44:31 $
%   Copyright 1990-2004 The MathWorks, Inc.
Editor = this.Editor;
Proj = this.Project;
Tests = Proj.Tests;

% Edited constraint
Editor.Constraint = this.Constraint;

% Update vector of test views
LocalAdjustTestViews(Editor,length(Tests));

% Update editor view
update(Editor)
refplot(Editor)

% Callback for plotting current response
Editor.RespFcn = {@showCurrentResponse Proj};

% Listeners to Test events
Editor.Listeners.Project = ...
   [handle.listener(Proj,'SourceCreated',{@localSetRunTimeSource Editor Proj});...
    handle.listener(Proj,'OptimUndo',{@localUndoOptim Editor})];


%------------------- Local Functions --------------------------------

function localSetRunTimeSource(eventsrc,eventdata,Editor,ProjForm)
% Hooks up editors to runtime projects
% Installs listeners to runtime project events
RunTimeProj = eventdata.Data;
Tests = RunTimeProj.Tests;  % runnable tests
Editor.Listeners.Source = [...
   handle.listener(Tests,'ShowCurrent',{@localShowCurrent Editor});...
   handle.listener(Tests,'OptimStart',{@localInitTrace Editor});...
   handle.listener(Tests,'OptimUpdate',{@localUpdateTrace Editor});...
   handle.listener(Tests,'OptimStop',{@localShowCurrent Editor})];
% Set TestViews
for ct=1:length(Editor.TestViews)
   Editor.TestViews(ct).Test = Tests(ct);
end
% Update simulation interval
Editor.XFocus = getSimInterval(ProjForm);


function localShowCurrent(Test,eventdata,Editor)
% Plot current response
if strcmp(Test.Enable,'on')
   DataLog = eventdata.Data;
   simplot(Editor,Test,DataLog,Editor.Constraint.SignalSource.LogID)
end


function localInitTrace(Test,eventdata,Editor)
% Initialize optimization trace
% Clear current response and previous traces
idxt = find([Editor.TestViews.Test]==Test);
clearplot(Editor,idxt)


function localUpdateTrace(Test,eventdata,Editor)
% Update optimization trace
if strcmp(Test.Enable,'on') && strcmp(Test.Optimized,'on')
   DataLog = eventdata.Data;
   traceplot(Editor,Test,DataLog,Editor.Constraint.SignalSource.LogID)
end


function localFinishTrace(Test,eventdata,Editor)
% Destroy runtime listeners
delete(Editor.Listeners.Source)
% Plot current response
if strcmp(Test.Enable,'on')
   DataLog = eventdata.Data;
   simplot(Editor,Test,DataLog,Editor.Constraint.SignalSource.LogID)
end


function localUndoOptim(eventsrc,eventdata,Editor)
% Clean up when undoing optimization
for ct=1:length(Editor.TestViews)
   View = Editor.TestViews(ct);
   set(View.Response,'XData',[],'YData',[],'Zdata',[])
   delete(View.Optimization(:))
   Editor.TestViews(ct).Optimization = [];
end


function LocalAdjustTestViews(Editor,ntnew)
% Adjust test-related vectors
ntold = length(Editor.TestViews);
if ntold<ntnew
   % Add new test views
   for ct=ntold+1:ntnew
      Editor.TestViews(ct,1).Test = [];
      Editor.TestVisible(ct,1) = {'on'};
   end
elseif ntnew<ntold
   % Delete extra test views
   for ct=ntnew+1:ntold
      h = [Editor.TestViews(ct).Response(:);...
         Editor.TestViews(ct).Optimization(:)];
      delete(h(ishandle(h)))
   end
   Editor.TestViews = Editor.TestViews(1:ntnew,:);
   Editor.TestVisible = Editor.TestVisible(1:ntnew,:);
end   

