function [index,cindex,confq]=fiactham
%FIACTHA Finds the selected models.
%   confq contains the handles of the axes whose models may be
%   prepared for confidence interval computations.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:32 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
sumb=findobj(get(0,'children'),'flat','tag','sitb30');
models=findobj([XID.sumb(1);sumb(:)],'tag','modelline');
ind=findobj(models,'flat','linewidth',3);
cind=findobj(models,'flat','linewidth',0.5);
if isempty(ind)
  iduistat('No models selected. Click on model icons to select desired ones.')
end

confq=[];
index=[];
cindex=[];
for kh=ind(:)'
    hax=get(kh,'parent');
    tag=get(hax,'tag');
    if nargout==3,
       hc=findobj(hax,'tag','ny0');
       if ~isempty(hc),confq=[confq,hax];end
    end
    index=[index,eval(tag(6:length(tag)))];
end
for kh=cind(:)'
    tag=get(get(kh,'parent'),'tag');
    cindex=[cindex,eval(tag(6:length(tag)))];
end
