function hw=idbuildw(number)
%IDBUILDW This function handles the creation of all the ident VIEW windows.
%       Twelve different windows are handled, with names corresponding to
%       the input argument NUMBER according to the table in idlaytab.

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/10 23:19:19 $

 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
 
s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
s3='iduipoin(2);';
fonts = idlayout('fonts',number);
fz=fonts{1}; % Fontsize for axes,title and labels
fw=fonts{2}; % Fontweight for ditto

map = idlayout('plotcol',number); % The colors associated with the plots
col = map(1,:); % frame around the axes
ftcol = map(2,:); % Titles and labels
fticol = map(3,:); % Color for tickmarks
AxesColor = map(4,:); % Axes color

title=iduigetp(number,'name');
iduistat(['Opening ',title,' window ...'])
if figflag(title,0)
   hw=gcf;return
end
posfig=[];
try
   if length(XID.layout)>=number,
      if XID.layout(number,3)
          posfig=XID.layout(number,1:4);
       end,
    end
 catch
    end
if isempty(posfig)
   pos1=get(0,'Screensize');
   if any(number==[3,9,10,14,15])
      posWH=min(pos1(3:4)*1/2,[360 300]);
   else
      posWH=min(pos1(3:4)*1/2,[330 290]);
   end
   posXY=max(pos1(3:4)-posWH-(number-1)*[40 40]-[0,40],[0 0]);
   posfig=[posXY posWH];
end
tag=['sitb',int2str(number)];

posWH=posfig(3:4);posXY=posfig(1:2);
clcb=['iduiedit(''clwin'',',int2str(number),');'];
hw=figure('pos',posfig,'NumberTitle','off','name',title,...
         'HandleVisibility','callback','Visible','off','tag',tag,...
                    'color',col,...
                    'DockControls','off',...
          'closerequestfcn',clcb,'Integerhandle','off');
set(hw,'menubar','none');
XID.plotw(number,1)=hw;
set(Xsum,'UserData',XID);
if number==8
   idbwtext(hw,posXY),return
end
% Main menu items:
try
   defaults = XID.styleprefs(:,number);
   catch
   %if isempty(XID.styleprefs)
      defaults=idlayout('figdefs');
      if number == 40
          defaults = defaults(:,2);
      else
      defaults=defaults(:,number);
  end
   %else
   %   defaults=XID.styleprefs(:,number);
   end
   [label,acc]=menulabel('&File');
   hf=uimenu(hw,'Label',label);
   [label,acc]=menulabel('&Options');
   ho=uimenu(hw,'Label',label);
   [label,acc]=menulabel('&Style');
   ha=uimenu(hw,'Label',label);
   if any(number==[1:7,13:15,40])
      [label,acc]=menulabel('&Channel');
      hch=uimenu(hw,'Label',label);
      XID.plotw(number,3)=hch;
   end
   [label,acc]=menulabel('&Help');
   hh=uimenu(hw,'Label',label);
   [label,acc]=menulabel('&View explanation');
   hhelp=uimenu(hh,'Label',label);
   [label,acc]=menulabel('&General menu help');
   uimenu(hh,'Label',label,'callback',...
           'iduihelp(''idgview.hlp'',''Help: General Menu Items'');');
  if any(number==[2:7,40]) 
      [label,acc]=menulabel('&Confidence intervals');
      uimenu(hh,'Label',label,'callback',...
           'iduihelp(''iduiconf.hlp'',''Help: Confidence Intervals'');');
  end
   if number==9
      help1='iduihelp(''selordax.hlp'',''Help: Choice of ARX Structure'');';
   elseif number==10
      help1='iduihelp(''selordss.hlp'',''Help: Choice of Model Order'');';
   elseif any(number==[2])
      help1='iduihelp(''bodeplot.hlp'',''Help: Frequency Response Plot'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idbodopt.hlp'',''Help: Options for Frequency Response'');');
       elseif any(number==[40])
      help1='iduihelp(''idyuff.hlp'',''Help: Frequency Function Plot'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idbodopt.hlp'',''Help: Options for Frequency Response'');');
   elseif number==3
      help1='iduihelp(''compare.hlp'',''Help: Model Output'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idcompop.hlp'',''Help: Options for Model Output'');');

   elseif number==4
      help1='iduihelp(''zpplot.hlp'',''Help: Zeros and Poles'');';
   elseif number== 5
      help1='iduihelp(''idtrresp.hlp'',''Help: Transient Response'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idtrropt.hlp'',''Help: Options for Transient Response'');');

   elseif number==6
      help1='iduihelp(''resid.hlp'',''Help: Residual Analysis'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idresopt.hlp'',''Help: Options for Residual Analysis'');');

   elseif number==7
      help1='iduihelp(''idspect.hlp'',''Help: Disturbance Spectrum'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idbodopt.hlp'',''Help: Options for Disturbance Spectrum'');');

   elseif number==11
      help1='iduihelp(''selauxo.hlp'',''Help: Choice of Auxiliary Order'');';
   elseif number==1
      help1='iduihelp(''idplot.hlp'',''Help: Input Output Time Plot'');';
      [label,acc]=menulabel('&Special options');
   uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''idplotop.hlp'',''Help: Options for Time Plots'');');

   elseif number==13
      help1='iduihelp(''iduyspe.hlp'',''Help: Input Output Spectra'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''iduyspop.hlp'',''Help: Options for Data Spectra'');');
   elseif number==14
      help1='iduihelp(''idsel.hlp'',''Help: Select Input Output Time Range'');';
   elseif number==15
      help1='iduihelp(''idfilt.hlp'',''Help: Prefilter Input Output Data'');';
      [label,acc]=menulabel('&Special options');
      uimenu(hh,'Label',label,'Callback',...
           'iduihelp(''iduyspop.hlp'',''Help: Options for Data Spectra'');');
   end
   set(hhelp,'callback',help1);   
   if any(number==[9 10])
      XID.plotw(number,3)=hhelp;
   end

   % Submenues for FILE
   [label,acc]=menulabel('Copy &figure');
   uimenu(hf,'Label',label,'callback',...
         [s1,'idunlink(',int2str(number),');',s3]);
   [label,acc]=menulabel('&Print');
   uimenu(hf,'Label',label,'callback', ...
    [s1,'printdlg;',s3]);
   [label,acc]=menulabel('&Close ^w');
   ht=uimenu(hf,'Label',label,'separator','off','Accelerator',acc,...
            'callback',[s1,'iduiaxes(''close'',',int2str(number),');',s3]);
   if number==14,set(ht,'callback',[s1,'iduisel(''done'');',s3]);end
   % Submenus for OPTIONS
   [label,acc]=menulabel('&Autorange ^a');
   uimenu(ho,'Label',label,'accelerator',acc,...
                 'callback',[s1,'iduiaxes(''auto'');',s3]);
   [label,acc]=menulabel('Set axes &limits... ^m');
   uimenu(ho,'Label',label,'accelerator',acc,...
                 'callback',[s1,'iduiaxis(''open'',gcf);',s3]);
   if any(number==[2:7,40])
      hco=ho;
      [label,acc]=menulabel('Show 99% confidence &intervals ^i');
      h1=uimenu(hco,'Label',...
          label,'accelerator',acc,'callback',[s1,'iduiconf(''onoff'');',s3],...
           'userdata',2.5758,'tag','confonoff','interruptible','On',...
           'separator','on');
      [label,acc]=menulabel('Set &confidence level');
      h2=uimenu(hco,'Label',label);
        [label,acc]=menulabel('9&5%');
        uimenu(h2,'label',label,'userdata',1.96,'callback',...
        [s1,'iduiconf(''set'');',s3]);
        [label,acc]=menulabel('9&7%');
        uimenu(h2,'label',label,'userdata',2.1701,'callback',...
        [s1,'iduiconf(''set'');',s3]);
        [label,acc]=menulabel('9&9%');
        uimenu(h2,'label',label,'userdata',2.5758,...
                     'callback',[s1,'iduiconf(''set'');',s3]);
        [label,acc]=menulabel('99&.9%');
        uimenu(h2,'label',label,'userdata',3.2905,...
                     'callback',[s1,'iduiconf(''set'');',s3]);
        [label,acc]=menulabel('&Other...');
        uimenu(h2,'label',label,...
                 'callback',[s1,'iduiconf(''conf'');',s3]);
      if defaults(5)
         set(h1,'checked','on')
      end
   end
   
   idvmenus(number,ho,'options');

   % SUBMENUS for Style
   [label,acc]=menulabel('&Grid ^g');
   h1=uimenu(ha,'Label',label,'accelerator',acc,'separator','off',...
                       'callback',[s1,'iduiaxes(''grid'');',s3],'tag','grid');
   if defaults(4)==0,set(h1,'checked','on'),end % will be toggled later
    hgrid=h1;
%   [label,acc]=menulabel('&Box');
%   h1=uimenu(ha,'Label',label,'vis','off',...
%                        'callback',[s1,'iduiaxes(''box'');',s3]);
%   if defaults(3)==1,set(h1,'checked','on'),end
   [label,acc]=menulabel('&Zoom');
   hz=uimenu(ha,'Label',label,'separator','on','callback',...
        [s1,'iduimbcb(''setzoom'',',int2str(number),');',s3],'tag','zoom');
   if defaults(6)==0
      set(hz,'checked','on') % Will be toggled later
   else
      set(hz,'checked','off')
   end
   idvmenus(number,ha,'style');
   if any(number==[1:3,5:7,13:15,40])
     [label,acc]=menulabel('S&eparate linestyles');
     h1=uimenu(ha,'Label',label,...
                  'callback',[s1,'iduiaxes(''sep_on'');',s3],...
                  'separator','on','tag','sepls');
     [label,acc]=menulabel('&All Solid Lines');
     h2=uimenu(ha,'Label',label,'callback',...
                [s1,'iduiaxes(''sep_off'');',s3],'userdata',h1,'tag','solls');
     set(h1,'userdata',h2);
     if defaults(2)==1, chn2=h2;else chn2=h1;end
     set(chn2,'checked','on')
   end
   [label,acc]=menulabel('Erasemode &xor');
   h1=uimenu(ha,'Label',label,'callback',...
                   'iduiaxes(''xor'')','separator','on','vis','on','tag','xor');
   [label,acc]=menulabel('Erasemode &normal');
   h2=uimenu(ha,'Label',label,'callback',...
                   'iduiaxes(''ernormal'')','userdata',h1,'vis','on','tag','xnormal');
   set(h1,'userdata',h2)
   if defaults(1)==1, chn1=h2;else chn1=h1;end
   set(chn1,'checked','on')
   if any(number == [1 3 13])
      set(Xsum,'UserData',XID);
   try
      Exp = XID.names.exp;
   catch
      Exp ={};
   end
   if length(Exp)>1
      iduiexp('set',number);
   end
end

   
   % Now follows the basic AXES settings, with the axes handles
   % made userdata (3-- rd item) of the figure

   if any(number==[1 2 6 13,40]) % Two axes plots
      pos=idlayout('axes',number);
      xax(1,1)=axes('position',pos(1,:),'box','on',...
                  'drawmode','fast','xticklabel',[],'tag','axis1',...
                  'color',AxesColor,...
                  'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
      set(get(xax(1,1),'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(1,1),'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(1,1),'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      xax(2,1)=axes('position',pos(2,:),'box','on',...
                  'drawmode','fast','tag','axis2','color',AxesColor,...
                  'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
      set(get(xax(2,1),'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(2,1),'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(2,1),'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);

   elseif any(number==[14 15]) % Two axes plots with buttons
      pos = idlayout('axes',number);
      xax(1,1)=axes('position',pos(1,:),'box','on',...
                  'drawmode','fast','xticklabel',[],'tag','axis1',...
                  'color',AxesColor,...
                  'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
      set(get(xax(1,1),'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(1,1),'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(1,1),'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);

      xax(2,1)=axes('position',pos(2,:),'box','on',...
                  'drawmode','fast','tag','axis2','color',AxesColor,...
                   'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
      set(get(xax(2,1),'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(2,1),'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(2,1),'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
 
   elseif any(number==[3,9,10])   % Single plots with buttons
      pos = idlayout('axes',number);
      xax(1,1)=axes('position',pos(1,:),'box','on',...
                  'drawmode','fast','tag','axis1','color',AxesColor,...
                  'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
      set(get(xax(1,1),'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(1,1),'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax(1,1),'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      if number==3
%        xtab=axes('position',[0.72 0.15 0.27 0.75],'box','on',...
        xtab=axes('position',[pos(1,1)+pos(1,3)+0.025 pos(1,2) 1-pos(1,3)-pos(1,1)-0.05 pos(1,4)],'box','on',...
                  'drawmode','fast','tag','table','color',AxesColor,...
              'XColor',fticol,'YColor',fticol,'Ydir','reverse','fontsize',fz,...
              'ytick',[],'xtick',[],'xticklabel',[],'yticklabel',[]);
        axes(xtab)
        text(0.5,0.95,'Best Fits','color',ftcol,'units','norm',...
                 'fontsize',fz,'Horizontalalignment','center','tag','leader');
      end
   else                        % Single plots
      pos = idlayout('axes',number);
      xax=axes('position',pos,'box','on',...
                  'drawmode','fast','tag','axis1','color',AxesColor,...
                  'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
      set(get(xax,'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax,'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
      set(get(xax,'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
   end
   set(xax(:,1),'interruptible','On');
   layout
   pos=[0.9*mStdButtonWidth,3*mStdButtonHeight];
   uicontrol(hw,'pos',[0 0 pos],'vis','off','style','edit',...
      'max',2,'tag','infobox');
%   if any(number==[9 10 14 15])
   XID.status(number) = uicontrol(hw,'Style','text','String','', ...
 'Position',[mEdgeToFrame mEdgeToFrame posWH(1)...
   0.8*mStdButtonHeight]);
   set(XID.status(number),'unit','norm')
%   end

   set(hw,'interruptible','On','windowbuttonupfcn','1;');
   if number==3,fpos=posfig(4);else fpos=0;end
           %Model output uses userdata to detect resize
           set(hw,'Userdata',[fpos;0;xax]); 
            set(Xsum,'Userdata',XID);
   if any(number==[1 2 4 5 7 13]),iduiiono('set',[],number);end
   if number==40
       if isempty(XID.names.unames)
           warndlg('No Frequency Functions for Time Series data','Warning','modal')
           return
       else
           iduiiono('set',[],number);
       end
   end
   if any(number==[3 6]),iduiiono('set',get(XID.hw(4,1),'UserData'),number);end
   %get(XID.hw(4,1),'userdata'),number);end
   if any(number==[14 15]),iduiiono('set',get(XID.hw(3,1),'userdata'),number);end%get(XID.hw(3,1),'userdata'),number);end
   iduimbcb('setzoom',number);
   iduiaxes('grid',1,hgrid);
   iduital(number);
   set(hw,'vis','on');
  
