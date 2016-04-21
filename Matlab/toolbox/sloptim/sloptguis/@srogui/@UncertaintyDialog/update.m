function update(this)
% Updates dialog contents.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:20 $
ActiveSpec = this.ActiveSpec;
USpec = this.Uncertainty(ActiveSpec);
Test = this.Test;
ud = this.Figure.UserData;

% Set global enable
set(ud.EnableCheck,'Value',strcmp(Test.Enable,'on'))

% Update Uncertain Parameter frame
set(ud.Distribution,'Value',ActiveSpec);
idxDeselect = 3-ActiveSpec;
set(ud.Table(idxDeselect),'Visible',0)
set(ud.NumSample(idxDeselect),'Visible','off')
set(ud.Table(ActiveSpec),'Visible',1)
set(ud.NumSample(ActiveSpec),'Visible','on')
updateTable(this)

% Update Optimized Responses frame
set(ud.OptimCheck(1),'Value',strcmp(this.Project.Test(1).Optimized,'on'))
switch USpec.Optimized
   case 'none'
      set(ud.OptimCheck(2),'Value',0)
      set(ud.OptimRadio,'Enable','off')
   case 'vertex'
      set(ud.OptimCheck(2),'Value',1)
      set(ud.OptimRadio,'Enable','on',{'Value'},{0;1})
   case 'all'
      set(ud.OptimCheck(2),'Value',1)
      set(ud.OptimRadio,'Enable','on',{'Value'},{1;0})
end
