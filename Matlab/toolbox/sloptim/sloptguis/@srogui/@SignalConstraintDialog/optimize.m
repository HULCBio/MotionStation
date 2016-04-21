function optimize(this)
% Callback for Optimization:Start buttons

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:44:26 $
%   Copyright 1990-2004 The MathWorks, Inc.
ProjSpec = this.Project;

% Evaluate literal project spec
try
   Proj = evalForm(ProjSpec);
catch
   errordlg(utGetLastError,'Optimize Error','modal')
   return
end

% Check the set of tunable parameters is non empty
[hasTunedPar,hasCost,hasConstr] = checkSettings(Proj);
if ~hasTunedPar
   msg = sprintf('%s\n%s','No parameters to optimize.',...
      'Use the Optimization menu to specify the tuned parameters.');
   errordlg(msg,'Optimize Error','modal')
   return
elseif ~hasCost && ~hasConstr
   msg = sprintf('%s\n%s','Nothing to optimize.',...
      'Add or enable at least one constraint or objective.');
   errordlg(msg,'Optimize Error','modal')
   return
end

% Notify peers of runtime project creation
E = ctrluis.dataevent(ProjSpec,'SourceCreated',Proj);
ProjSpec.send('SourceCreated',E)

% Take snapshot of current parameter values
pv = utEvalParams(Proj.Model,get(ProjSpec.Parameters,{'Name'}));

% Associate transaction so that original parameter values can be restored
% RE: Adding to Undo stack changes Dirty state
Dirty = ProjSpec.Dirty;
T = ctrluis.ftransaction('Optimize Parameters');
T.Undo = {@localUndo this pv Dirty};
T.Redo = {@localRedo this Dirty};
this.Editor.Recorder.pushundo(T)
ProjSpec.Dirty = Dirty;   

% Create and initialize display window
if strcmp(Proj.OptimOptions.Display,'off')
   hText = [];
else
   hText = iterdlg(this);
   hText.setText(sprintf(' \n'));
end

% Start optimization
try
   optimize(Proj,hText);
catch
   % Clean up after error
   Proj.OptimStatus = 'error';
   % Post error
   if ~strcmp(lasterr,'Interrupt')
      errordlg(utGetLastError,'Optimize Error','modal')
   end
   % Return to idle (to reenable Start button)
   Proj.OptimStatus = 'idle';
end

%---------------- Local Functions ---------------------------------

function localUndo(this,pv,Dirty)
% Undoes optimization
ProjForm = this.Project;
ProjForm.Dirty = Dirty;
% Restore original parameter values
utAssignParams(ProjForm.Model,pv)
% Revert graphics
ProjForm.send('OptimUndo')
% Replot current response
showCurrentResponse(ProjForm)


function localRedo(this,Dirty)
% Redo optimization
this.Project.Dirty = Dirty;
optimize(this)
