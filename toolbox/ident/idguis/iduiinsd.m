function axh=iduiinsd(data,active,axinfo)
%IDUIINSD Inserts data into the Data Summary Board.
%   DATA: The data.
%   DATA_INFO: The associated information matrix.
%   DATA_N: The name of the data set.
%   ACTIVE: 1 to make icon selected at insert
%   AXINFO: [Board_no,position,color]
%   AXH: the handle number of the data's icon axis.

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $  $Date: 2004/04/10 23:19:43 $

sstat = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles',sstat)
XID = get(Xsum,'Userdata');

if nargin<2,active=1;end
if nargin<3
   axinfo =[];
end
[N,ny,nu]=size(data);
XID.counters(5)=1;
set(Xsum,'UserData',XID);
chanupd(data);
XID = get(Xsum,'UserData');
if isempty(axinfo)
   [axh,texh,linh]=idnextw('data');
else
   [axh,texh,linh]=idnextw('data',axinfo(1),axinfo(2:5),axinfo(6:8));
   if isempty(linh),  [axh,texh,linh]=idnextw('data');end
end
tagdat=get(axh,'tag');
datanr=eval(tagdat(6:length(tagdat)));
data_n = pvget(data,'Name');
set(linh,'UserData',data,'tag','dataline');
set(texh,'string',data_n);
dl=min(50,N(1));
if isa(data,'idfrd')
    [ny,nu] = size(data);
    if nu>0
    ll = pvget(data,'ResponseData');
else
    ll = pvget(data,'SpectrumData');
end
    ll = squeeze(ll(1,1,:));
    dl = 10;%%LL check this
    frdflag=1;
    tdflag = 0;
else
    ll=pvget(data,'OutputData');ll=ll{1};
    frdflag = 0;
    dom  = pvget(data,'Domain');
    if lower(dom(1))=='t'
        tdflag = 1;
    else 
        tdflag = 0;
    end
end
ll=real(ll(1:dl,1));
ylim = [2*min(ll)-max(ll) max(ll)];
if ylim(1)==ylim(2),
   ylim = [ylim(1)-1 ylim(2)+1];
end
if any(isnan(ylim))
    errordlg('Data contains NaN''s. No data inserted.','Error Dialog','Modal')
    return 
end

set(linh,'xdata',1:dl,'ydata',ll);
if active, set(linh,'linewidth',3);end
Plotcolors=idlayout('plotcol');
if tdflag
    nrf = 4;
elseif frdflag
    nrf = 8;
else
    nrf = 7;
end
axescolor=Plotcolors(nrf,:);
set(axh,'ylim',ylim,'xlim',[0 dl],'color',axescolor);
set([linh axh texh],'vis','on')
usde=get(XID.hw(3,1),'userdata'); % If working data is empty we fill it
if isempty(usde)&active
   idinseva(axh,'seles');idinseva(axh,'selva');
end
set(XID.plotw([1,13],2),'enable','on')
if nu>0
    set(XID.plotw(40,2),'enable','on')
end
if active,
   if  get(XID.plotw(1,2),'value'),wnr=1;else wnr=[];end
   if  get(XID.plotw(13,2),'value'),wnr=[wnr 13];end
   if  get(XID.plotw(40,2),'value'),wnr=[wnr 40];end
   if ~isempty(wnr),iduimod(wnr,datanr,[]);end
   set(XID.sbmen([3 5]),'enable','on')
   if strcmp(get(XID.sbmen(1),'tag'),'open')
      [label,acc]=menulabel('&Merge session... ^o');
      set(XID.sbmen(1),'label',label,'tag','merge');
   end
   iduistat(['Data set ',data_n,' inserted.',...
         '  Double click on icon (right mouse) for text information.'])
end
%%%%%%
