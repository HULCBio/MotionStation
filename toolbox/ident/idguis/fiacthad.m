function [index,cindex]=fiacthad
%FIACTHAD Finds the selected data sets.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:32 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
sumb=findobj(get(0,'children'),'flat','tag','sitb30');
models=findobj([XID.sumb(1);sumb(:)],'tag','dataline');

ind=findobj(models,'flat','linewidth',3);
cind=findobj(models,'flat','linewidth',0.5);
if isempty(ind)
   iduistat('No data sets selected. Click on data icons to select desired ones.')
end
index=[];
cindex=[];
for kh=ind(:)'
    tag=get(get(kh,'parent'),'tag');
    index=[index,eval(tag(6:length(tag)))];
end
for kh=cind(:)'
    tag=get(get(kh,'parent'),'tag');
    cindex=[cindex,eval(tag(6:length(tag)))];
end
