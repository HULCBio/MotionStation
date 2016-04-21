function uncdlg(this)
% Creates and manages uncertainty editor

% Author(s): P. Gahinet
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:33 $
Proj = this.Project;

% Find or create uncertainty test (REVISIT)
Test = find(Proj.Tests,'-not','Runs',[]);
if isempty(Test)
   % Create new test
   Test = copy(Proj.Tests(1));
   Test.Specs = Proj.Tests(1).Specs;
   % REVISIT: Current options dialog requires shared sim options
   Test.SimOptions = Proj.Tests(1).SimOptions;
end

% Open/create dialog
Dlg = Proj.UncDialog;
if isempty(Dlg) || ~ishandle(Dlg)
   Dlg = srogui.UncertaintyDialog(Proj,Test,this);
   Proj.UncDialog = Dlg;
end

% Sync up uncertainty description
if isa(Test.Runs,'srogui.RandSetForm')
   Dlg.ActiveSpec = 1;
   Dlg.Uncertainty(1) = copy(Test.Runs);
elseif isa(Test.Runs,'srogui.GridSetForm')
   Dlg.ActiveSpec = 2;
   Dlg.Uncertainty(2) = copy(Test.Runs);
end

% Update contents
update(Dlg)

% Make frame visible
Dlg.Figure.Visible = 'on';

