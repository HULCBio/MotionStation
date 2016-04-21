function idmwwb(dum)
%function [dat,dat_n,dat_i,do_com]=idmwwb(dum)

%IDMWWB Handles the window button callback in the main ident window.

%   L. Ljung 9-27-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $ $Date: 2004/04/10 23:19:28 $

dat=[];dat_n=[];dat_i=[];do_com=[];

if nargin>0,return,end
 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

do_com='';dat=[];dat_n=[];dat_i=[];
seltyp=get(gcf,'Selectiontype');
curo=iduigco;
if strcmp(get(curo,'type'),'text')|strcmp(get(curo,'type'),'line')
   cura=get(curo,'parent');
elseif strcmp(get(curo,'type'),'axes')
   cura=curo;
else
   iduistat('Click acknowledged. No action invoked.');
   return
end
usd=get(cura,'tag');
if isempty(usd) 
   return
elseif  strcmp(usd,'expor')
   iduistat('Drag data/model icon here to export it to workspace.')
   return
elseif  strcmp(usd,'ltivi')
   iduistat('Drag model icon here to study it in a LTI Viewer.')
   return
elseif  strcmp(usd,'seles')
   iduistat('Drag data icon here to select it as working data.')
   return
elseif  strcmp(usd,'selva')
   iduistat('Drag data icon here to select it as validation data.')
   return
elseif  strcmp(usd,'waste')&strcmp(seltyp,'normal')
   iduistat(['Drag data/model icon here to delete it. Double click ',...
             '(right mouse button) to open can.'])
   return
end
line=findobj(cura,'type','line');
if strcmp(get(line(1),'vis'),'off')
  iduistat('Empty icon. No action invoked.')
  return
end
if length(usd)>5 kk=eval(usd(6:length(usd)));else kk=0;end
axtype=usd(1:5);

if strcmp(seltyp,'open')|strcmp(seltyp,'alt')
   if strcmp(axtype,'waste')
      iduistat('Opening trash can ...')
      iduiwast('show');
   elseif strcmp(axtype,'model')|strcmp(axtype,'data ')
      iduistat('Opening text info ...')
      iduiedit('pres',cura);
	  return
   else
      iduistat('Double click acknowledged.  No action invoked.'),return
   end
   iduistat('')
elseif strcmp(seltyp,'normal')
    if ~strcmp(axtype,'model')&~strcmp(axtype,'data ')
        return
    end
   
    set(cura,'units','pixels')
    axpos=get(cura,'pos');
    iduistat('Drag and drop on another icon.')
    dragrect(axpos)
      
    iduistat('')
    set(cura,'units','norm')
    new=idmhit('axes');
    if isempty(new)
        new=idmhit('uicontrol');
        if ~isempty(new),if ~strcmp(get(new,'tag'),'modst'),new=[];end,end
    end
    if isempty(new),iduistat('Not dropped on another icon.  No action invoked.'),return,end
    if cura~=new,
       [dat,dat_n,dat_i,do_com]=iduidrop(cura,new);
       return
    end
end
if strcmp(seltyp,'normal')|strcmp(seltyp,'extend')
    lineobj=[findobj(cura,'tag','modelline');findobj(cura,'tag','dataline')];
    if isempty(lineobj),return,end
    lw=get(lineobj,'linewidth');

    if lw>1,onoff='off';nlw=0.5;else onoff='on';nlw=3;end
    if strcmp(onoff,'off') 
        iduivis(get(cura,'userdata'),'off')
    else
        if strcmp(axtype,'model'),
           actfig=fiactha(XID.plotw(2:7,2))+1;
        else
           actfig=[];
           if get(XID.plotw(1,2),'value'),actfig=[actfig,1];end
           if get(XID.plotw(13,2),'value'),actfig=[actfig,13];end
           if get(XID.plotw(40,2),'value'),actfig=[actfig,40];end

        end
        iduimod(actfig,kk,[]);
    end
    set(lineobj,'linewidth',nlw);
else
   iduistat('Click acknowledged. No action invoked.')
end
