function usrdata=refresh_tgscope(usrdata)

% REFRESH_TGSCOPE - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:21:37 $


tgscopes=xpcgate('getscopes','target');	%(1);

listboxstr={};
usrdata.T.scope=[];

j=1;
for i=1:length(tgscopes)
   text=['Scope_',num2str(tgscopes(i))];
   if ~(tgscopes(i)==usrdata.edit.targetnumber)
      listboxstr(j)={text};
      usrdata.T.scope=setfield(usrdata.T.scope,text,tgscopes(i));
      j=j+1;
   end;
end;	
usrdata.T.scopelist=listboxstr;
if (usrdata.edit.subfigures.trigger~=-1) & (usrdata.edit.trigger.mode==4)
   set(usrdata.subfigure.trigger.lb_signallist,'String',listboxstr);
end;