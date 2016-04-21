function idvmenus(k,hm,arg)
%IDVMENUS Sets the submenus for the different view windows.
%   K     the window number
%   HM    the handle of the main menu item
%   ARG  'options' Sets the options menus
%        'axis'    Sets the axis menus

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:20:03 $

%global XIDplotw
 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

s1='iduipoin(1);';s3='iduipoin(2);';
if strcmp(arg,'style')
   if any(k==[2,7,13,15,40]) % These are the frequency domain plots LL 3 added
        usd=get(XID.plotw(k,2),'userdata');
        [label,acc]=menulabel('Frequency (&rad/s)');
        h1=uimenu(hm,'Label',label,'callback',...
             [s1,'idopttog(''check'');',s3],'tag','rad/sec','separator','on');
        [label,acc]=menulabel('Frequency (&Hz)');
        h2=uimenu(hm,'Label',label,'callback',...
             [s1,'idopttog(''check'');',s3],'tag','hz','userdata',[h1 k 3 2]);
        set(h1,'userdata',[h2 k 3 1]);
        if eval(usd(3,:))==1,chn=h1;else chn=h2;end
        set(chn,'checked','on');
        [label,acc]=menulabel('L&inear frequency scale');
        h1=uimenu(hm,'Label',label,'separator','on',...
               'callback',[s1,'idopttog(''check'');',s3]);
        [label,acc]=menulabel('L&og frequency scale');
        h2=uimenu(hm,'Label',label,'separator','off',...
                'callback',[s1,'idopttog(''check'');',s3],'userdata',...
                [h1 k 1  2]);
        set(h1,'userdata',[h2 k 1 1]);
        if eval(usd(1,:))==1,chn=h1;else chn=h2;end
        set(chn,'checked','on');
        [label,acc]=menulabel('Li&near amplitude scale');
        h1=uimenu(hm,'Label',label,'separator','on',...
               'callback',[s1,'idopttog(''check'');',s3]);
        [label,acc]=menulabel('&Log amplitude scale');
        h2=uimenu(hm,'Label',label,'separator','off',...
                'callback',[s1,'idopttog(''check'');',s3],'userdata',...
                [h1 k 2 2]);
        set(h1,'userdata',[h2 k 2 1]);
        if eval(usd(2,:))==1,chn=h1;else chn=h2;end
        set(chn,'checked','on');
    elseif k==3&strcmp(pvget(iduigetd('v','me'),'Domain'),'Frequency')
        usd=get(XID.plotw(k,2),'userdata');
        [label,acc]=menulabel('Frequency (&rad/s)');
        h1=uimenu(hm,'Label',label,'callback',...
             'idoptcmp;','tag','rad/sec','separator','on','checked','on');
        [label,acc]=menulabel('Frequency (&Hz)');
        h2=uimenu(hm,'Label',label,'callback',...
             [s1,'idoptcmp;',s3],'tag','hz','userdata',[h1 k 3 2]);
        set(h1,'userdata',[h2 k 3 1]);
%         if eval(usd(3,:))==1,chn=h1;else chn=h2;end
%         set(chn,'checked','on');
        [label,acc]=menulabel('L&inear frequency scale');
        h1=uimenu(hm,'Label',label,'separator','on',...
               'callback',[s1,'idoptcmp;',s3],'tag','linfreq');
        [label,acc]=menulabel('L&og frequency scale');
        h2=uimenu(hm,'Label',label,'separator','off',...
                'callback',[s1,'idoptcmp;',s3],'userdata',...
                [h1 k 1  2]);
        set(h1,'userdata',[h2 k 1 1]);
        if eval(usd(1,:))==1,chn=h1;else chn=h2;end
        set(chn,'checked','on');
        [label,acc]=menulabel('Li&near amplitude scale');
        h1=uimenu(hm,'Label',label,'separator','on',...
               'callback',[s1,'idoptcmp;',s3],'tag','linamp');
        [label,acc]=menulabel('&Log amplitude scale');
        h2=uimenu(hm,'Label',label,'separator','off',...
                'callback',[s1,'idoptcmp;',s3],'userdata',...
                [h1 k 2 2]);
        set(h1,'userdata',[h2 k 2 1]);
        if eval(usd(2,:))==2,chn=h1;else chn=h2;end
        set(chn,'checked','on');
        
   elseif k==4  % Zeros and poles
       [label,acc]=menulabel('&Unit circle');
       h1=uimenu(hm,'Label',label,'separator','on','tag','zpuc','callback',...
          [s1,'idopttog(''unit_circle'');',s3],'checked','on');
       [label,acc]=menulabel('&Re/Im-axes');
      h2=uimenu(hm,'Label',label,'separator','off','tag','zpax','callback',...
          [s1,'idopttog(''reimaxes'');',s3]);
   elseif k==5  % Transient response
       usd=get(XID.plotw(5,2),'UserData');
       [label,acc]=menulabel('&Line plot');
       h1=uimenu(hm,'Label',label,'separator','on',...
             'callback',...
             [s1,'idopttog(''check'');',s3]);
       [label,acc]=menulabel('Ste&m plot');
       h2=uimenu(hm,'Label',label,'callback',...
             [s1,'idopttog(''check'');',s3],'userdata',[h1 k 1 2]);
       set(h1,'userdata',[h2 k 1 1]);
       if eval(usd(1))==1,chn=h1;else chn=h2;end
       set(chn,'checked','on')


    elseif any(k==[1 14]) % These are data plots
       [label,acc]=menulabel('&Staircase input');
       h1=uimenu(hm,'label',label,'callback',...
           [s1,'idopttog(''check'');',s3],'separator','on');
       [label,acc]=menulabel('&Regular input');
       h2=uimenu(hm,'label',label,'callback',...
           [s1,'idopttog(''check'');',s3],'userdata',[h1 k 1 2]);
       set(h1,'userdata',[h2 k 1 1]);
       usd=get(XID.plotw(1,2),'UserData');
       if eval(usd(1))==1,chn=h1;else chn=h2;end
       set(chn,'checked','on');
    end
elseif strcmp(arg,'options')
   if any(k==[2,7,13,15,40]) % These are the frequency domain plots
        usd=get(XID.plotw(k,2),'userdata');
        if any(k==[13,15])
           [label,acc]=menulabel('&Periodograms');
           h1=uimenu(hm,'Label',label,'callback',...
             [s1,'idopttog(''check'');',s3],'separator','on');
           [label,acc]=menulabel('&Spectral analysis');
           h2=uimenu(hm,'Label',label,'callback',...
              [s1,'idopttog(''check'');',s3],'userdata',[h1 k 5 1]);
           set(h1,'userdata',[h2 k 5 2]);
           if eval(deblank(usd(5,:)))==1,chn1=h2;else chn1=h1;end
           set(chn1,'checked','on')
       end
       [label,acc]=menulabel('&Frequency range...');
       uimenu(hm,'Label',label,'callback',...
         [s1,'iduiopt(''dlg_freq'',''plotw'',',int2str(k),',4);',s3],...
           'separator','on');
    elseif any(k==[5,6]) % This is transient response and residual plot
         if k==5  % Transient response
              usd=get(XID.plotw(5,2),'UserData');
              [label,acc]=menulabel('S&tep response');
              h1=uimenu(hm,'Label',label,'callback',...
                        [s1,'idopttog(''check'');',s3],'separator','on');
              [label,acc]=menulabel('Im&pulse response');
              h2=uimenu(hm,'Label',label,'callback',...
                    [s1,'idopttog(''check'');',s3],...
                    'userdata',[h1 k 3 2]);
             set(h1,'userdata',[h2 k  3 1]);
             if eval(usd(3))==1,chn=h1;else chn=h2;end
             set(chn,'checked','on')
        end
        if k==5,
              cb='iduiopt(''dlg_nos'',''plotw'',5,2);';optno=2;
              [label,acc]=menulabel('Time &span (samples)');
        else
              cb='iduiopt(''dlg_lgs'',''plotw'',6,1);';optno=1;
              [label,acc]=menulabel('Number of &lags');
        end
        h1=uimenu(hm,'Label',label,'separator','on');
           [label,acc]=menulabel('&5');
           hh(1)=uimenu(h1,'Label',label,'userdata',[k optno 5]);
           [label,acc]=menulabel('&10');
           hh(2)=uimenu(h1,'Label',label,'userdata',[k optno 10]);
           [label,acc]=menulabel('&20');
           hh(3)=uimenu(h1,'Label',label,'userdata',[k optno 20]);
           [label,acc]=menulabel('&40');
           hh(4)=uimenu(h1,'Label',label,'userdata',[k optno 40]);
           [label,acc]=menulabel('1&00');
           hh(5)=uimenu(h1,'Label',label,'userdata',[k optno 100]);
           set(hh,'callback',[s1,'idopttog(''set'');',s3])
           [label,acc]=menulabel('&Other...');
           uimenu(h1,'Label',label,'callback',[s1,cb,s3],'separator','on');
    elseif k==3 % This is Model output
       usd=get(XID.plotw(3,2),'UserData');
       kstep=deblank(usd(1));
       [label,acc]=menulabel('&Simulated output ^s');
       h1=uimenu(hm,'Label',label,'accelerator',acc,'tag','simul','callback',...
             [s1,'idopttog(''check'');',s3],'separator','on');
       [label,acc]=menulabel([kstep,' step ahead &predicted output ^p']);
       h2=uimenu(hm,'Label',label,'tag','predict','accelerator',acc,...
             'callback',...
             [s1,'idopttog(''check'');',s3],'userdata',[h1 k 2 2]);
       set(h1,'userdata',[h2 k 2 1]);
       if eval(usd(2))==1,hn=h1;else hn=h2;end
       set(hn,'checked','on');
       [label,acc]=menulabel('Set prediction &horizon');
       h1=uimenu(hm,'Label',label,...
             'separator','on');
       [label,acc]=menulabel('&1^1');
       hh(1)=uimenu(h1,'Label',label,'userdata',[k 1 1],'Accelerator',acc);
       [label,acc]=menulabel('&3^3');
       hh(2)=uimenu(h1,'Label',label,'userdata',[k 1 3],'Accelerator',acc);
       [label,acc]=menulabel('&5^5');
       hh(3)=uimenu(h1,'Label',label,'userdata',[k 1 5],'Accelerator',acc);
       [label,acc]=menulabel('1&0^0');
       hh(4)=uimenu(h1,'Label',label,'userdata',[k 1 10],'Accelerator',acc);
       [label,acc]=menulabel('&20^2');
       hh(5)=uimenu(h1,'Label',label,'userdata',[k 1 20],'Accelerator',acc);
       set(hh,'callback',[s1,'idopttog(''set'');',s3]);
       [label,acc]=menulabel('&Other...');
       uimenu(h1,'Label',label,'callback',...
             [s1,'iduiopt(''dlg_ph'',''plotw'',3,1);',s3],'separator','on');
       [label,acc]=menulabel('Si&gnal plot');
       h1=uimenu(hm,'Label',label,'separator','on','callback',...
            [s1,'idopttog(''check'');',s3]);
       [label,acc]=menulabel('&Error plot');
       h2=uimenu(hm,'Label',...
            label,'userdata',h1,'callback',...
            [s1,'idopttog(''check'');',s3],'userdata',[h1 k 4 1]);
       set(h1,'userdata',[h2 k 4 0]);
       if eval(usd(4))==0,chn=h1;else chn=h2;end
       set(chn,'checked','on')
       [label,acc]=menulabel('Customized time span for &fit...');
       uimenu(hm,'Label',label,...
             'callback',...
           [s1,'iduiopt(''dlg_sampff'',''plotw'',3,3);',s3],'separator','on');
  end
end
