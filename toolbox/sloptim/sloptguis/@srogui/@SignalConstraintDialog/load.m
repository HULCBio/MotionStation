function load(this,Proj)
% Reacts to change in active project

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:44:23 $
%   Copyright 1990-2004 The MathWorks, Inc.
Block = this.Block;
if ~strcmp(bdroot(Block),Proj.Model)
   % Project targets a different model
   return
end
Test = Proj.Tests(1);
Editor = this.Editor;

% Find constraint associated with block in modified project
% REVISIT: Looking only at first spec....
C = Test.findspec(get_param(Block,'LogID'));
if isempty(C)
   % No change
   return
end
   
% Retarget dialog
this.Constraint = C;
this.Project = Proj;

% Update editor focus
this.Editor.XFocus = getSimInterval(Proj);

% Retarget editor to loaded constraint
targetEditor(this)

% Flush undo/redo stack
% REVISIT
Recorder = this.Editor.Recorder;
Recorder.Undo = [];
Recorder.Redo = [];
