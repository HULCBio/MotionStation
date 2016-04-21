function iduipop(arg)
%IDUIPOP Manages the callbacks from ident's pop-up menus.

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $Date: 2004/04/10 23:19:53 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

curo=iduigco;
popv=get(curo,'value');

if strcmp(arg,'data')
   if popv==1,iduistat('');
   elseif popv==2, 
      iduifile('load_iodata','data_td');
  elseif popv==3
      iduifile('load_iodata','data_fd');
  elseif popv==4
      iduifile('load_iodata','object');
   elseif popv==5,
      iduifile('load_iodata','data_td');
      XID = get(Xsum,'Userdata');
      
      u2 = [];
      y2 = [];
      load dryer2
      set(XID.hload(1,21),'Value',1);
      iduifile('pop')
      set(XID.hload(1,8),'string','0');
      set(XID.hload(1,6),'string','0.08');
      set(XID.hload(1,4),'string','Dryer');
      set(XID.hload(1,11),'string','u2','userdata',u2);
      set(XID.hload(1,13),'string','y2','userdata',y2);
      info=str2mat('% This is the ''Hair Dryer'' data set. The',...
         '% input is the electric power and the',...
         '% output is the outlet air temperature.','',' load dryer2');
      set(XID.hload(1,12),'string',info);
      set(XID.hload(1,16),'string','inf');
      set(XID.hload(1,17),'string','^o C');
      set(XID.hload(1,18),'string','W');
      set(XID.hload(1,20),'string','temperature');
      set(XID.hload(1,19),'string','power');
      iduistat('Press the Import button.')
   elseif popv==4
      iduifile('load_data');
   end
elseif strcmp(arg,'model')
   if popv==1,iduistat('');
   elseif popv==2, iduifile('load_model');,end
elseif strcmp(arg,'preprocess')
       poph = findobj(get(Xsum,'children'),'flat','tag','sitbpreppop');
       popusd = XID.pop;
       nr = popusd{2};
       popv= nr(popv);
   if popv==1,iduistat('');return,end
   usd=get(XID.hw(3,1),'userdata');
   if isempty(usd)
      errordlg('You must first import a data set.','Error Dialog','modal');
      set(curo,'Value',1)
      return
   end
   dat = iduigetd('e'); %%LL
   fr = 0; fd = 0; td = 0;
   if isa(dat,'idfrd')
       fr = 1;
   elseif strcmp(pvget(dat,'Domain'),'Frequency')
       fd = 1;
   else
       td = 1;
   end
   
   if popv==2, iduisel('open_io');
   elseif popv==3, 
       if fr, 
           errordlg('Merging and selecting experiments is not applicable to IDFRD data',...
               'error dialog','modal')
       else
           iduisel('open_exp');
       end
   elseif popv==4  
       if fr, 
           errordlg('Merging and selecting experiments is not applicable to IDFRD data',...
               'Not Applicable','modal')
       else
           iduiexp('merge');
       end
   elseif popv==5, iduisel('open_portions');
   elseif popv==6,  
       if fr|fd
           errordlg(['Removing means and trends does not apply to frequency domain data'],...
               'Not Applicable','modal');
       else
           iduisel('dtrend',0);
       end
   elseif popv==7, 
       if fr|fd
           errordlg(['Removing means and trends does not apply to frequency domain data'],...
               'Not Applicable','modal');
       else
           iduisel('dtrend',1);
       end
   elseif popv==8, iduifilt('open');
   elseif popv==9, 
       if fr|fd
           errordlg(['Resampling does not apply to frequency domain data.'],...
               'Not Applicable','modal');
       else
           iduisel('open_dec');
       end
   elseif popv==10, iduitrf('open');
   elseif popv == 11
       if fr|fd
           errordlg('Quickstart is intended for time domain data only',...
               'No Quickstart','modal');
       else
      set(XID.plotw(1,2),'value',1),iduipw(1);
      hax=iduisel('dtrend',0,0);
      hnrdat=findobj(hax,'tag','dataline');
      %hnrstr=findobj(hax,'tag','name');
      data = get(hnrdat,'UserData');
      data_n = pvget(data,'Name');
      una = pvget(data,'InputName');
      yna = pvget(data,'OutputName');
      if length(una)>0
         nru = find(strcmp(una{1},XID.names.unames));
      else
         nru = 0;
      end
      nry = find(strcmp(yna{1},XID.names.ynames));
      iduiiono('update',nry,nru,1,1);%end % To select
      % existing channel
      [nl,ny,nu]=size(data);
      if length(nl)==1
         nlh=ceil(nl/2);
         name=[data_n,'e'];
         namv=[data_n,'v'];
         haxe=iduisel('insert',data,[],data_n,[1,nlh],name);
         haxv=iduisel('insert',data,[],data_n,[nlh+1,nl],namv);
         idinseva(haxe,'seles');
         idinseva(haxv,'selva');
         iduistat([data_n,': Detrended data. ',name,': First half. '...
               ,namv,': Second half.']);
      end
  end
   end
elseif strcmp(arg,'estimate')
   if popv==1,iduistat('');return,end
   usd=get(XID.hw(3,1),'userdata');
   if isempty(usd)
      errordlg('You must first import a data set.','Error Dialog','modal');
      set(curo,'Value',1);
      return
   end
   if popv==5, iduicra('open');%iduinpar('cra');%eval('iduicra(''open'');')
   elseif popv==4, eval('iduispa(''open'');')
   elseif popv==2, eval('idparest(''open'');')
   elseif popv==6, eval('iduiqs;')
   elseif popv==3, idprocest('open');
   end
end
set(curo,'value',1);
