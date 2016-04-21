function iduiaxes(arg,ifopt,hm)
%IDUIAXES Handles the axes options.
%   The argument ARG takes the following values
%   'close': closes figure
%   'auto': Effectuates autoscaling
%   'grid': Toggles grid
%   'box': Toggles box
%   'square': Toggles square (currently not in use)
%   'equal': Toggles equal (currently not in use)
%   'xor': makes erasemode equal to xor
%   'ernormal': makes erasemode equal to normal
%   'sep_on': Invokes separate linestyles
%   'sep_off': Makes all lines solid

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/04/06 14:22:36 $

%global XIDmen XIDmview XIDmzp XIDplotw
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if strcmp(arg,'close')
   number=ifopt;
   set(XID.plotw(number,1),'Visible','off')
   if any(number==[1:7,13]),set(XID.plotw(number,2),'value',0),end
   return
end

if nargin < 3 ,hm=gcbo;end%get(gcf,'currentmenu');end
if strcmp(arg,'talcmp')
  number=3;
  if nargin<2,ifopt=0;end
else
  number=iduigetp(gcf);
end
 usd=get(XID.plotw(number,1),'userdata');
[rusd,cusd]=size(usd);
if rusd>0,kax=idnonzer(usd(3:rusd,1))';end

if strcmp(arg,'auto')
   for kk=kax,
      axes(kk),axis(axis),axis('auto'),
      set(get(kk,'zlabel'),'userdata',[]); % To reset the zoom limits
   end

elseif strcmp(arg,'grid')
   onoff=get(hm,'checked');
   if strcmp(onoff,'off'),onoff1='on';else onoff1='off';end
   for kk=kax,set(kk,'Xgrid',onoff1);set(kk,'Ygrid',onoff1);end
   set(hm,'checked',onoff1);

elseif strcmp(arg,'box')

   onoff=get(hm,'checked');
   if strcmp(onoff,'off'),onoff1='on';else onoff1='off';end
   for kk=kax,set(kk,'box',onoff1);end
   set(hm,'checked',onoff1);

elseif strcmp(arg,'xor')
   set(hm,'checked','on')
   set(get(hm,'userdata'),'checked','off')
   for kk=kax,
     xusd=get(kk,'Userdata');[rxusd,cxusd]=size(xusd);
     set(idnonzer(xusd(3:rxusd,:)),'Erasemode','xor')
   end
end
if strcmp(arg,'ernormal')
   set(hm,'checked','on')
   set(get(hm,'userdata'),'checked','off')
   for kk=kax,
     xusd=get(kk,'Userdata');[rxusd,cxusd]=size(xusd);
     set(idnonzer(xusd(3:rxusd,:)),'Erasemode','normal')
   end
end

if strcmp(arg,'sep_on')
   set(hm,'checked','on')
   set(get(hm,'userdata'),'checked','off')
   for kk=kax,
     xusd=get(kk,'Userdata');[rxusd,cxusd]=size(xusd);
     kcount=1;
     ls=str2mat('-','--',':','-.'); %% Special treatment will be required for
                                    %%  zpplots
     if number==3,if xusd(2,2)~=0
        set(xusd(2,2),'Linestyle','-.')
     end,end
     ISstem=0;
     if number==5
        opt=get(XID.plotw(5,2),'UserData');
        if eval(opt(1,:))==2      %This is a stem plot
           ISstem=1;
           ls=str2mat('o','+','*','x');
        end
     end
     for kline=3:2:rxusd
        if xusd(kline,1)>0,if strcmp(get(xusd(kline,1),'visible'),'on')
          if ISstem|number==3, coln=1;else coln=1:cxusd;end
          set(idnonzer(xusd(kline,coln)),'Linestyle',deblank(ls(kcount,:)))
          kcount=kcount+1;if kcount==5,kcount=1;end
        end,end
     end
   end
end
if strcmp(arg,'sep_off')
   set(hm,'checked','on')
   set(get(hm,'userdata'),'checked','off')
   for kk=kax,
     xusd=get(kk,'Userdata');[rxusd,cxusd]=size(xusd);
     ls='-';coln=1:cxusd;
     if number==3,
        coln=1;
        if xusd(2,2)>0
           set(xusd(2,2),'Linestyle','-')
        end
     end
     if number==5
        opt=get(XID.plotw(5,2),'UserData');
        if eval(opt(1,:))==2  % This is a stem plot
           ls='o';coln=1;
        end
     end
     set(idnonzer(xusd(3:2:rxusd,coln)),'Linestyle',ls)
   end
end
