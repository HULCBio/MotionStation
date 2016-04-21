% called by MAGSHAPE

% Author: P. Gahinet   10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $


function [hdl1,str1]=magreq(hdl,str,task,extra,dims)

if strcmp(task,'filname'),

   % extra -> filter names as typed
   % str: old names
   hdlfil=hdl(1:length(hdl)-2);
   hdldia=hdl(length(hdl)+(-1:0));

   if isempty(dblnk(extra)),   % no names specified
      set(hdldia(2),'str','Specify the filter names (5 maximum)');
      set(hdldia,'vis','on');
      hdl1=hdlfil; str1=str;
   else
      set(hdldia,'vis','off');
      [nbr,str1]=parstrg(extra);
      if nbr > 5, nbr=5; str1=str1(1:5,:); end

      % identify which names were kept and store corresp.
      % pointer to data/plots (user data)
      % default - -Inf
      tmp=zeros(nbr,1); for k=1:nbr, tmp(k)=-Inf; end
      usrdata=[tmp tmp tmp];

      if ~isempty(str),       % previous names existed
         for i=1:size(str,1),
            s_old=dblnk(str(i,:));  % old name
            del=1; j=1;
            while del & j<=size(str1,1),
              if strcmp(s_old,dblnk(str1(j,:))),
                 del=0;
                 usrdata(j,1:3)=get(hdlfil(i),'user'); %save ptrs
              end
              j=j+1;
            end
            if del,
              oldusr=get(hdlfil(i),'user');
              ind=find(oldusr~=-Inf);
              set(oldusr(ind),'erase','normal');
              delete(oldusr(ind));
            end
         end
      end

      delete(hdlfil);

      % create new buttons

      hdl1=[];

      for k=1:nbr,
        kstr=num2str(k);
        vec=['[1:' kstr '-1,' kstr '+1:' num2str(nbr) ']'];
        hdl1=[hdl1;...
             uicontrol('sty','radio','units','nor',...
                'pos',[.93  (1-(k+1)/10) .058 .058], ...
                'string',dblnk(str1(k,:)), ...
                'user',usrdata(k,:),'callb', ...
                ['set(HDL_filt(' vec '),''value'',0);'...
                 'magreq(HDL_filt,' kstr ',''foreg'');' ...
                 'Active_filt=' kstr ';' ...
                 'filtnam=dblnk(Filt_who(' kstr ',:));' ...
                 'if exist(filtnam),' ...
                 'magreq(HDL_filt(' kstr ...
                 '),eval(filtnam),''initplot'');end,' ...
                 'clear filtnam'])];

%   '),eval(filtnam),''initplot'',get(gca,''xlim''));end,' ...

      end
      set(hdl1(1),'value',1);


   end

elseif strcmp(task,'foreg'),

   for j=[1:str-1,str+1:size(hdl,1)],
     usrdata=get(hdl(j),'user');
     ind=find( usrdata~= -Inf);
     set(usrdata(ind),'col','r');
   end
   usrdata=get(hdl(str),'user');
   ind=find( usrdata~= -Inf);
   set(usrdata(ind),'col','b');

elseif strcmp(task,'setx'),

   [nbr,str]=parstrg(str);
   set(hdl,'xlim',[10^str2num(str(1,:)) 10^str2num(str(2,:))]);

elseif strcmp(task,'sety'),

   [nbr,str]=parstrg(str);
   set(hdl,'ylim',[str2num(str(1,:)) str2num(str(2,:))]);

elseif strcmp(task,'initplot'),

   usrdata=get(hdl,'user');

   % SYSTEM matrix for filter
   if ~islsys(str) & ~isempty(str), str=ltisys([],[],[],str); end  %gain
   [ns,ni,no]=sinfo(str);

   if ni+no==2,
     [n,d]=ltitf(str);
     w=[logspace(-3,3,50) logspace(3,6,10)];
%       w=logspace(log10(extra(1)),log10(extra(2)),30);
     fmag=20*log10(abs(freqresp(n,d,sqrt(-1)*w)));

     if usrdata(3)==-Inf,
        set(gcf,'HandleVisibility','callback');
        hp=semilogx(w,fmag,'color','b','linesty','-','erase','backg');
        usrdata(3)=hp;
        set(gcf,'HandleVisibility','callback');
        set(hdl,'user',usrdata);
     else
        set(usrdata(3),'Xdata',w,'Ydata',fmag);
     end

   elseif ns > 0,
     error('Cannot display MIMO filters!');
   end

elseif strcmp(task,'addpt'),

   % str -> active_filt
   if str < 0, return; end
   xdims=get(gca,'xlim'); ydims=get(gca,'ylim');
   x=get(gca,'currentpoint'); y=x(1,2); x=x(1,1);
   if x < xdims(1) | x > xdims(2) | y < ydims(1) | y > ydims(2),return, end

   usrdata=get(hdl(str),'user');

   if usrdata(1)~=-Inf,      % data already stored
      freq=get(usrdata(1),'Xdata');
      ydb=get(usrdata(1),'Ydata');
      l=length(freq); freq=[freq x]; ydb=[ydb y];

      if x <= freq(l), [freq,ind]=sort(freq); ydb=ydb(ind); end

      set(usrdata(2),'erase','backg');
      set(usrdata(1:2),'Xdata',freq,'Ydata',ydb);
      set(usrdata(2),'erase','none');

   else
      set(gcf,'nextplot','add');
      usrdata(1)=plot(x,y,'erase','none','color','b','marker','o');
      usrdata(2)=plot(x,y,'erase','none','color','b','linesty','--');
      set(gcf,'HandleVisibility','callback');
      set(hdl(str),'user',usrdata);
   end


elseif strcmp(task,'delpt'),

   % str -> active_filt
   if str < 0, return; end
   xdims=get(gca,'xlim'); ydims=get(gca,'ylim');
   x=get(gca,'currentpoint'); y=x(1,2); x=x(1,1);
   if x < xdims(1) | x > xdims(2) | y < ydims(1) | y > ydims(2),return, end
   usrdata=get(hdl(str),'user');
   if usrdata(1) ==-Inf, return, end

   freq=get(usrdata(1),'Xdata');      l=length(freq);
   ydb=get(usrdata(1),'Ydata');
   [dist,i]=min(abs(freq-x)+abs(ydb-y));
   freq=[freq(1:i-1) freq(i+1:l)];
   ydb=[ydb(1:i-1) ydb(i+1:l)];
   set(usrdata(1:2),'erase','backg');
   set(usrdata(1:2),'Xdata',freq,'Ydata',ydb,'erase','none');

elseif strcmp(task,'movpt'),

   % str -> active_filt
   if str < 0, return; end
   xdims=get(gca,'xlim'); ydims=get(gca,'ylim');
   x=get(gca,'currentpoint'); y=x(1,2); x=x(1,1);
   if x < xdims(1) | x > xdims(2) | y < ydims(1) | y > ydims(2),return, end
   usrdata=get(hdl(str),'user');
   if usrdata(1) ==-Inf, return, end
   freq=get(usrdata(1),'Xdata'); ydb=get(usrdata(1),'Ydata');


   if nargin==3,  % click down
     [dist,j]=min(abs(log10(freq/x))+abs(ydb-y)/10);  % get point to be moved
      set(gcf,'WindowButtonMotionFcn', ...
              ['magreq(HDL_filt,Active_filt,''movpt'',' int2str(j) ');'],...
              'WindowButtonUp', ...
              'set(gcf,''WindowButtonMotionFcn'','''');');

   else           % redraw while moving
      freq(extra)=x; ydb(extra)=y;    % update coord. moved pt
      set(usrdata(1:2),'erase','backg');
      set(usrdata(1:2),'Xdata',freq,'Ydata',ydb,'erase','none');
   end


elseif strcmp(task,'fit'),

   % extra = order
   if str < 0,
     return
   else
     usrdata=get(hdl(str),'user');
     if usrdata(1) ==-Inf, return, end
     freq=get(usrdata(1),'Xdata'); ydb=get(usrdata(1),'Ydata');
     l=length(freq);
     if l <= 1, return, end

     mag=10.^(ydb/20);
     [num,den]=mrfit(freq(:),mag(:),extra);
     hdl1=sbalanc(ltisys('tf',num,den));

     % bode plot
     xlims=get(gca,'xlim');
     w=logspace(log10(xlims(1)),log10(xlims(2)),50);
     fmag=20*log10(abs(freqresp(num,den,sqrt(-1)*w)));

     if usrdata(3) ==-Inf,     % no pre-existing plot
        set(gcf,'nextplot','add');
        hp=plot(w,fmag,'color','b','linesty','-','erase','backg');
        usrdata(3)=hp;
        set(hdl(str),'user',usrdata);
        set(gcf,'HandleVisibility','callback');
     else
        set(usrdata(3),'Xdata',w,'Ydata',fmag);
     end
   end

elseif strcmp(task,'clear'),

   if ~isempty(hdl) & str>0,
     usrdata=get(hdl(str),'user');
     ind=find(usrdata(1:2) ~= -Inf);
     set(usrdata(ind),'erase','normal');
     delete(usrdata(ind));
     set(hdl(str),'user',[-Inf,-Inf,usrdata(3)]);
     set(findobj(gcf,'tag','MAGstatus'),'str',' ');
   end

end
