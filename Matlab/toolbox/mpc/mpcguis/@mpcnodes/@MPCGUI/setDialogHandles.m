
function setDialogHandles(this)

% SETDIALOGHANDLES
%
% Set handles in common dialogs to keep track of the active MPC task

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:36:26 $

Importer = this.Handles.ImportLTI;
Importer.SelectedRoot = this;
Importer = this.Handles.ImportMPC;
Importer.SelectedRoot = this;
Exporter = this.Handles.mpcExporter;
Exporter.SelectedRoot = this;
