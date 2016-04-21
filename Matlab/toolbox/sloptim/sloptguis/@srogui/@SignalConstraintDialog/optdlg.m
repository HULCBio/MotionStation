function optdlg(this,tab)
% Creates and manages optimization and simulation options dialog

% Author(s): P. Gahinet, Bora Eryilmaz
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:25 $
Proj = this.Project;
Dlg = Proj.OptDialog;
if isempty(Dlg) || ~ishandle(Dlg)
   Dlg = slcontrol.OptionsDialog(Proj.Tests(1).SimOptions,Proj.OptimOptions,this.Figure);
   Proj.OptDialog = Dlg;
end

% Select appropriate tab
Dlg.setSelectedIndex(tab)

% Make frame visible
show(Dlg)

