function writetotarget(usrdata,action)

% WRITETOTARGET - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:21:55 $

targetmanager=get(usrdata.targetmanager.figure,'UserData');
pbhandle=findobj(usrdata.targetmanager.figure,'String',['Scope ',num2str(usrdata.edit.targetnumber)]);
pbtag=get(pbhandle,'Tag');
number=str2num(pbtag(end-1));
if ~isempty(number)
  	pbnum=str2num(pbtag(end))+10;
else
   pbnum=str2num(pbtag(end));
end;
state=get(targetmanager.menu(pbnum).startstop,'Label');
if strcmp(state,'Start')
   eval(action);
else
   xpcgate('scstop',usrdata.edit.targetnumber);
   eval(action);
   xpcgate('scstart',usrdata.edit.targetnumber);
end;           
