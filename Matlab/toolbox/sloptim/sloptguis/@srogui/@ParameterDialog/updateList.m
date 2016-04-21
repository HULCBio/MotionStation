function updateList(this)
% Updates contents of parameter list

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:44:11 $
hList = this.Figure.UserData.List;
if isempty(this.ParamSpecs)
   Selection = [];
else
   Selection = 1;
end
set(hList,'String',get(this.ParamSpecs,{'Name'}),'Value',Selection)
% Update panel
showParam(this,Selection)