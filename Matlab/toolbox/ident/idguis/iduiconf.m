function err=iduiconf(arg,strr)
%IDUICONF Manages the confidence interval lines.
%   ARG:
%   onoff Checks the right menu item and toggles visibility of confidence lines
%   set   Sets the confidence according to the submenu
%   conf  Opens the dialog box
%   l1cb  Handles the info in the box when slider has changed
%   2     Ditto when # of standard deviations has changed
%   3     Ditto when desired confidence level has changed
%   apply Effectuates the new choice. The # of standard
%         deviations are put as UserData of XIDmen(figno,8)

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2001/04/06 14:22:36 $

set(0,'Showhiddenhandles','on');

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if strcmp(arg,'onoff')|strcmp(arg,'conf')|strcmp(arg,'set')
  hconf=findobj(gcf,'tag','confonoff');
  number=iduigetp(gcf);
  xusd=get(gcf,'UserData');[rxusd,cxusd]=size(xusd);
  xax=xusd(3:rxusd,1)';
  onoff=0;
  hm=gcbo;%get(gcf,'currentmenu');
end

if strcmp(arg,'onoff')
  offon=get(hm,'checked');
  if strcmp(offon,'off'),
     iduistat('Marking confidence intervals ...',0,number)
     onoff1='on';onoff2='off';
  else
     onoff2='on';onoff1='off';
  end
  [actmod,cacmod,confq]=fiactham;
  if strcmp(onoff1,'on'),if ~isempty(confq),idconfcp(confq),end,end
  for kk=xax
    if strcmp(get(kk,'visible'),'on')
       xusd=get(kk,'userData');[rxusd,cxusd]=size(xusd);
       indxv=2*actmod+2;
       iduivis(xusd(indxv,:),onoff1);
       if strcmp(onoff1,'on')
       if any(any(xusd(indxv,:)==-1))
          iduistat('No confidence region for this model.',0,number)
       elseif any(any(xusd(indxv,:)==-2))
          iduistat('No confidence region for ETFE models.',0,number)
       else
        iduistat('Confidence intervals marked by dash-dotted lines.',0,number)
       end % if anyany
       else % of onoff1
        iduistat('Confidence intervals removed.',0,number)
       end
    end
  end
  set(hm,'checked',onoff1)
elseif strcmp(arg,'set')
   lab=get(hm,'label');labb=lab(find(lab~='&'));
   ch=get(hconf,'checked');
   set(hconf,'label',menulabel(['Show ',labb,' confidence &intervals']));
   set(hconf,'checked',ch);
   set(hconf,'userdata',get(hm,'userdata'));
   iduiclpw(number);
   iduistat(['Confidence interval changed to ',lab '.'])
elseif strcmp(arg,'conf')
   figname=idlaytab('figname',29);
   iduistat('Opening confidence dialog box ...')
   if ~figflag(figname,0)
       iduistat('Opening confidence dialog box ...')
       layout
       butwh=[mStdButtonWidth mStdButtonHeight];%butw=55;buth=25;
       butw=butwh(1);buth=butwh(2);
       ftb=mFrameToText;  % Frame to button
       bb = 2; % between buttons
       etf = mEdgeToFrame;
       FigW = iduilay2(3);

       XID.cf(1)=figure('HandleVisibility','callback',...
             'NumberTitle','off','Name',figname,'vis','off','tag','sitb29',...
             'Color',get(0,'DefaultUIControlBackgroundColor'));
       set(XID.cf(1),'Menubar','none');
       s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
       s3='iduipoin(3);';

       % LEVEL 1
       pos = iduilay1(FigW,3);
       uicontrol(XID.cf(1),'pos',pos(1,:),'style','frame');
       uicontrol(XID.cf(1),'Pos',pos(2,:),'style','push',...
                  'string','Apply','callback',[s1,'iduiconf(''apply'');',s3]);
       uicontrol(XID.cf(1),'Pos',pos(3,:),'style','push',...
          'callback','set(gcf,''visible'',''off'')','string','Close');
       uicontrol(XID.cf(1),'Pos',pos(4,:),'style','push',...
          'string','Help','callback','iduihelp(''idsetcon.hlp'',''Setting the Confidence Interval'');');

       % LEVEL2
       lev2 = pos(1,2)+pos(1,4)+mStdButtonHeight/2;

      XID.cf(2)=uicontrol(XID.cf(1),'pos',...
               [etf+ftb lev2 FigW-2*(etf+ftb) buth],'style','slider',...
               'max',10,'min',0,'callback',[s1,'iduiconf(''l1cb'');',s3]);

       % LEVEL 3

       lev3 = lev2+buth+mStdButtonHeight/2;
       pos = iduilay1(FigW,4,2,lev3,4,1.5);
       uicontrol(XID.cf(1),'pos',pos(1,:),'style','frame');
       XID.cf(3)=uicontrol(XID.cf(1),'pos',pos(4,:),'style','edit',...
           'callback',[s1,'iduiconf(''2'');',s3],'backgroundcolor','white',...
             'HorizontalAlignment','left');
      uicontrol(XID.cf(1),'pos',pos(2,:),'style','text','string',...
              'Number of std dev''s','HorizontalAlignment','left');
      XID.cf(4)=uicontrol(XID.cf(1),'pos',pos(5,:),'style','edit',...
           'callback',[s1,'iduiconf(''3'');',s3],'backgroundcolor','white',...
             'HorizontalAlignment','left');
      uicontrol(XID.cf(1),'pos',pos(3,:),'style','text','string',...
             'Confidence level','HorizontalAlignment','left');
       FigWH=[FigW pos(1,2)+pos(1,4)+etf];
       ScreenPos = get(0,'ScreenSize');
       FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
       set(XID.cf(1),'pos',FigPos);
      set(get(XID.cf(1),'children'),'unit','norm');
      if length(XID.layout)>28
       if XID.layout(29,3)
          eval('set(XID.cf(1),''pos'',XID.layout(29,1:4))','')
       end
     end
      set(XID.cf(1),'vis','on')
  end
  iduistat('Ready to set confidence level.')
  set(XID.cf(1),'userdata',number);
  sd=get(hconf,'userdata');
  set(XID.cf(3),'string',num2str(sd));
  set(Xsum,'UserData',XID);
  iduiconf('2');
elseif strcmp(arg,'l1cb')
    val=get(XID.cf(2),'value');
    set(XID.cf(3),'string',num2str(val))
    numv=erf(val/sqrt(2));
    if numv<0.999
        str=num2str(numv);
    else
        str=['1-',num2str(erfc(val/sqrt(2)))];
    end
    set(XID.cf(4),'string',str);

elseif strcmp(arg,'2')
    strr=get(XID.cf(3),'string');
    if iduiconf('test',strr),
      set(0,'Showhiddenhandles','off');
      return
    end
    val=eval(strr);
    numv=erf(val/sqrt(2));
    if numv<0.999
            str=num2str(numv);
    else
            str=['1-',num2str(erfc(val/sqrt(2)))];
    end
    set(XID.cf(4),'string',str);

    set(XID.cf(2),'value',val)

elseif strcmp(arg,'3')
    strr=get(XID.cf(4),'string');
    if iduiconf('test',strr),
      set(0,'Showhiddenhandles','off');
      return
    end
    val1=eval(strr);
    val=erfinv(val1)*sqrt(2);
    set(XID.cf(2),'value',val)
    set(XID.cf(3),'string',num2str(val))
elseif strcmp(arg,'apply')
   number=get(XID.cf(1),'userdata');
   val=get(XID.cf(4),'string');
   ssd=get(XID.cf(3),'string');
   if iduiconf('test',val)|iduiconf('test',ssd),
     set(0,'Showhiddenhandles','off');
     return
   end
   nval=eval(val);strval=[num2str(nval*100),'%'];sd=eval(ssd);
   hconf=findobj(XID.plotw(number,1),'tag','confonoff');
   ch=get(hconf,'checked');
   set(hconf,'Label',menulabel(['Show ',strval,' confidence &intervals']),'userdata',sd);
   iduiclpw(number);
   iduistat(['Confidence interval changed to ',strval '.'])
elseif strcmp(arg,'test')
   err=0;
   eval('val=eval(strr);','err=1;')
   msg=['The entry must be a positive real number.'];
   if err,
      errordlg(msg,'Error Dialog','modal');
      set(0,'Showhiddenhandles','off');
      return
    end
   if length(val)>1|length(val)<1,
      errordlg(msg,'Error Dialog','modal');
      set(0,'Showhiddenhandles','off');
      return
   end
   if val<0|isstr(val),
     errordlg(msg,'Error Dialog','modal');
     set(0,'Showhiddenhandles','off');
     return
   end
end

set(0,'Showhiddenhandles','off');
set(Xsum,'UserData',XID);
