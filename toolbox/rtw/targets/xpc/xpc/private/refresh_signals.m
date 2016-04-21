function usrdata=refresh_signals(usrdata,h_listbox)

% REFRESH_SIGNALS - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:21:34 $


colornorm=[0.752941,0.752941,0.752941];

model=usrdata.S.model;
modelpath=usrdata.S.modelpath;
modelname=usrdata.S.modelname;
signals=usrdata.S.signals;
slist=[1];%xpcgate('getsig');     % API

fnames=fieldnames(eval(['model',modelpath]));
submodels=zeros(1,length(fnames));

if isempty(modelpath)
    startback=0;
else
    listboxstr(1)={'..'};
    startback=1;
end;
 
for i=1:length(fnames);
   fname=fnames{i};
   if isa(getfield(eval(['model',modelpath]),fname),'struct')
      submodels(i)=1;
      listboxstr(i+startback)={[fname,'...']};
   else
      listboxstr(i+startback)={fname};
      value=getfield(eval(['model',modelpath]),fname);
   end;
end;

set(h_listbox,'String',listboxstr);

usrdata.S.submodels=submodels;
usrdata.S.fnames=fnames;
usrdata.S.listboxstr=listboxstr;
usrdata.S.startback=startback;