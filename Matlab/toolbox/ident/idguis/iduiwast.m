function stop=iduiwast(arg,arg2)
%IDUIWAST Shows the contents of the wastebasket.

%   L. Ljung 9-27-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $ $Date: 2004/04/10 23:20:02 $

 
 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

stop=0;
if nargin<2,arg2=0;end
wbas=findobj(get(XID.sumb(1),'children'),'flat','tag','waste');
handles=idnonzer(get(wbas,'userdata'));

if strcmp(arg,'show')
   figname=idlaytab('figname',34);
   [flag,wb]=figflag(figname);
   if flag
      newfigure=0;
   else
      newfigure=1;
   end
      Plotcolors=idlayout('plotcol');
      axescolor=Plotcolors(4,:);
      framecolor=Plotcolors(5,:);
      textcolor=Plotcolors(6,:);
      fz=idlayout('fonts',50);
   if newfigure
      layout
      butwh=[mStdButtonWidth mStdButtonHeight];
      butw=(1.8*0.7*mStdButtonWidth-5*mEdgeToFrame)/2;
      AWH = butw*[1 2/(1+sqrt(5))];
      butw=AWH(1);buth=AWH(2);
      ftb=2;  % Frame to button
      bb = 2; % between buttons
      etf = mEdgeToFrame;
      platecol=get(0,'DefaultUIcontrolBackgroundcolor');

      no_col=max(fix(length(handles)/4)+1,4);
      MWpos=get(XID.sumb(1),'pos');
      Figpos=[MWpos(1)+MWpos(3),MWpos(2),max(no_col,6)*butw,7.5*buth];
      wb=figure('pos',Figpos,'NumberTitle','off',...
            'DockControls','off',...
            'Name',figname,'visible','off','HandleVisibility','callback',...
            'color',platecol,'backingstore','off','windowbuttondownfcn',...
            'idmwwb;',...
            'DefaultAxesBox','on','DefaultAxesColor',platecol, ...
            'DefaultAxesDrawMode','fast','DefaultAxesUnit','pixel', ...
            'DefaultAxesYTick',[],'DefaultAxesYTickLabel',[], ...
            'DefaultAxesXTick',[],'DefaultAxesXTickLabel',[], ...
            'DefaultTextFontSize',fz,'Integerhandle','off', ...
            'DefaultTextHorizontalAlignment','center',...
            'DefaultAxesXColor',framecolor, 'DefaultAxesYColor',framecolor, ...
            'DefaultAxesZColor',framecolor,...
            'Defaulttextcolor',textcolor,...
            'tag','sitb34', ...
            'menubar','none');
      posd=iduilay(Figpos(3:4),AWH,ftb,bb,bb,etf,1.5*butwh(2),no_col*4,4);
      posd(:,2) = posd(:,2) + butwh(2);
      kk=1;
      uicontrol(wb,'pos',[0,Figpos(4)-butwh(2)-bb,Figpos(3),butwh(2)],...
        'style','text','string','Icons can be dragged back to ident.');
      uicontrol(wb,'pos',[0,Figpos(4)-2*butwh(2)-bb,Figpos(3),butwh(2)],...
        'style','text','string','Press Empty to permanently delete.');
      for ka=1:4*no_col
         h(ka)=axes('units','pixels','color',...
                platecol,'xtick',[],...
                'ytick',[],'xticklabel',[],'yticklabel',[],'box','on',...
                'drawmode','fast', 'vis','on',...
                'pos',posd(ka+1,:));
         ht=text('pos',[0.5 0],'units','norm','fontsize',10,'tag',...
                'name',...
                'horizontalalignment','center','verticalalignment','bottom');
         hl=line('vis','off','erasemode','normal',...
                 'tag','modelline0');
      end
      posd=iduilay1(Figpos(3:4),3);
      uicontrol(wb,'pos',posd(1,:),'style','frame');
      uicontrol(wb,'pos',posd(2,:),'style','push','string','Empty',...
          'callback','iduipoin(1);iduiwast(''kill'');iduipoin(2);');
      uicontrol(wb,'pos',posd(3,:),'style','push','string','Close',...
          'callback','iduiwast(''close'');');
      uicontrol(wb,'pos',posd(4,:),'style','push','string','Help',...
          'callback','iduihelp(''wast.hlp'',''Help: Trash'');');
      set(get(wb,'children'),'units','norm')
      if length(XID.layout)>33
         if XID.layout(34,3)
            eval('set(wb,''pos'',XID.layout(34,1:4))','')
         end
      end
      set(wb,'vis','on')
      set(wb,'userdata',h);axnr=h;
   end  % if newfigure
   if arg2>0
      wasthand=arg2;
   else
      wasthand=handles(:)';
   end
   for hand=wasthand
         axnr=get(wb,'userdata');
         if isempty(axnr)
            close(wb),iduiwast('show');return
         else
            h=axnr(1);
         end
         set(wb,'userdata',axnr(2:length(axnr)));
         ht=findobj(h,'tag','name');
         hl=findobj(h,'type','line');
         tag=get(hand,'tag');hands=findobj(hand,'tag','name');
         str=get(hands,'string');handl=findobj(hand,'type','line');
         handl=handl(1);% For MV systems with computed sd
                        % handl might be a vector
         set(ht,'string',str,'userdata',get(hands,'userdata'));
         set(hl,'xdata',get(handl,'xdata'),'ydata',get(handl,'ydata'),...
             'userdata',get(handl,'userdata'),'color',get(handl,'color'),...
              'tag',get(handl,'tag'));
         set(h,'ylim',get(hand,'ylim'),'xlim',get(hand,'xlim'), ...
                'userdata',get(hand,'userdata'), ...
                'tag',get(hand,'tag'),'color',axescolor);
         set(h,'vis','on'),set(get(h,'children'),'vis','on');
      end
elseif strcmp(arg,'throw')
   ax1=arg2;
   tag1=get(ax1,'tag');
   if strcmp(tag1,get(get(XID.hw(3,1),'zlabel'),'userdata'))|...
      strcmp(tag1,get(get(XID.hw(4,1),'zlabel'),'userdata'))
      errordlg(['The data you want to throw away is',...
         ' Working Data or Validation Data. \nReplace these before',...
         ' you delete the data set.'],'Error Dialog','modal');
      stop=1;return
   end
   xlim=get(ax1,'xlim');
   if get(ax1,'parent')==XID.sumb(1)
      set(ax1,'vis','off','pos',[1,1,1,1])
      ax2=ax1;
   else
      figure(XID.sumb(1));
      ax2=axes('pos',[1,1,1,1],'vis','off');
      axes(ax2);hl2=line('vis','off','erasemode','normal');
      hstr2=text('pos',[0.5 0],'units','norm','tag','name',...
            'verticalalignment','bottom');
      hl1=findobj(ax1,'type','line');
      hstr1=findobj(ax1,'tag','name');
      set(ax2,'tag',get(ax1,'tag'),'userdata',get(ax1,'userdata'),...
            'xlim',get(ax1,'xlim'),'ylim',get(ax1,'ylim'),...
            'color',get(ax1,'color'));

      set(hstr2,'string',get(hstr1,'string'),'userdata',get(hstr1,...
           'userdata'),'vis',get(hstr1,'vis'));

      set(hl2,'xdata',get(hl1,'xdata'),'ydata',get(hl1,'ydata'),...
        'color',get(hl1,'color'),'userdata',get(hl1,'userdata'),...
	'vis','off',...
        'tag',get(hl1,'tag'),'linewidth',0.5)
     set(ax1,'pos',[1 1 1 1],'vis','off')
     set(get(ax1,'children'),'vis','off')
   end
   set(get(ax2,'children'),'vis','off')
   set(idnonzer(get(ax2,'userdata')),'vis','off')
   set(ax2,'xlim',xlim)
   namhd=findobj(ax2,'tag','name');
   lineth=findobj(ax2,'type','line','linewidth',3);
   set(lineth,'linewidth',0.5)
   axw=findobj(XID.sumb(1),'tag','waste');
   waste_cont=get(axw,'user');
   if isempty(waste_cont)
      hfull=findobj(axw,'tag','full');
      hemp=findobj(axw,'tag','empty');
      set(hemp,'vis','off');set(hfull,'vis','on')
      set(XID.sbmen(10),'enable','on')
   end
   waste_cont=[waste_cont(:)',ax2];
   set(axw,'user',waste_cont);
   hnr=findobj(get(0,'Children'),'flat','tag','sitb34','vis','on');
   if ~isempty(hnr)
      iduiwast('show',ax2);
   end
   iduistat(['The object ',get(namhd,'string'),' is now in the trash.'])
elseif strcmp(arg,'clexbo')
   wind = gcf;
   axnames=[findobj(wind,'tag','modelline','vis','on');...
            findobj(wind,'tag','dataline','vis','on')];
   for nam = axnames(:)'
       if ishandle(nam)
          ax=get(nam,'parent');
          stop=iduiwast('throw',ax);
          if stop,return,end
       end
   end
   delete(wind)
   if ~isempty(axnames)
     iduistat('Board closed. Contents now in trash can.')
   end
elseif strcmp(arg,'kill')

   for kh=handles'
       eval('usd=get(kh,''userdata'');','usd=0;')
       delete(idnonzer(usd))
   end
   delete(idnonzer(handles))
   set(wbas,'userdata',[]);
   hfull=findobj(wbas,'tag','full');
   hem=findobj(wbas,'tag','empty');
   set(hfull,'vis','off');set(hem,'vis','on');drawnow
   set(XID.sbmen(10),'enable','off')
   [flag,fig]=figflag(idlaytab('figname',34));
   if flag,close(fig),end
elseif strcmp(arg,'close')
   pos=get(gcf,'pos');
   XID.layout(34,:)=pos;
   set(Xsum,'UserData',XID);
   close(gcf)
end
