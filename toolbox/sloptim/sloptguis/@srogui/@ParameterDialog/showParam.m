function showParam(this,Selection)
% Updates parameter setting display area based on selected parameter

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:10 $
ud = this.Figure.UserData;
if isscalar(Selection) && Selection>0 && Selection<=length(this.ParamSpecs)
   % Get and format parameter data
   ParSpec   = this.ParamSpecs( Selection );
   set(ud.Settings(1),'String',ParSpec.Name,'Enable','on')
   set(ud.Settings(2),'String',ParSpec.Value,'Enable','on')
   set(ud.Settings(3),'String',ParSpec.InitialGuess,'Enable','on')
   set(ud.Settings(4),'String',ParSpec.Minimum,'Enable','on')
   set(ud.Settings(5),'String',ParSpec.Maximum,'Enable','on')
   set(ud.Settings(6),'String',ParSpec.TypicalValue,'Enable','on')
   set(ud.Tuned,'Value',evalin('base',ParSpec.Tuned),'Enable','on')
   ReferencedBy = regexprep( ParSpec.ReferencedBy, '\n|\n\r', ' ');
else
   set(ud.Settings,'String','','Enable','off')
   set(ud.Tuned,'Enable','off')
   ReferencedBy = '';
end
set(ud.Reference,'String',ReferencedBy);
