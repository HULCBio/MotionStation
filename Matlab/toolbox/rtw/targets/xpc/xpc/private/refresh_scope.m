function usrdata=refresh_scope(usrdata)

% REFRESH_SCOPE - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:21:31 $


set(0,'ShowHiddenHandles','on');
h_main=get(0, 'Children');
opened=strmatch('xPC Target: Scope', get(h_main, 'Name'));
set(0,'ShowHiddenHandles','off');

listboxstr={};
usrdata.T.scope=[];

j=1;
for i=1:length(opened)
   handles=get(h_main(opened(i)),'UserData');
   text=['Scope_',num2str(handles.edit.scopenumber)];
   if ~(handles.edit.scopenumber==usrdata.edit.scopenumber)
      listboxstr(j)={text};
      usrdata.T.scope=setfield(usrdata.T.scope,text,handles.edit.scopenumber);
      j=j+1;
   end;
end;	
usrdata.T.scopelist=listboxstr;
set(usrdata.subfigure.trigger.lb_signallist,'String',listboxstr);
