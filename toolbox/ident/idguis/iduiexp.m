function exnr = iduiexp(arg,win,names)
% Controls the Experiment menu in windows 1,13 and 3

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:19:37 $
set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles','off')
XID = get(Xsum,'UserData');
switch arg
case 'set'
   Exp = XID.names.exp;
   if nargin<2
      win = [1 13 3];
   end
   
   for kwin = win
      % First check if menu exists
      if win==3
          vdato=iduigetd('v');
          if isa(vdato,'iddata')
          Exp = pvget(vdato,'ExperimentName');
      else
          Exp = [];
      end
  end
      if ~isempty(iduiwok(kwin))
         expm = findobj(get(XID.plotw(kwin,1),'children'),'Label','Experiment');
         if length(Exp)<2
             try
                 delete(expm)
             end
             return
         end
         if isempty(expm)
            expm = uimenu(XID.plotw(kwin,1),'Label','Experiment');
         end
         try
            oldsub = get(expm,'children');
         catch
            oldsub = [];
         end
         delete(idnonzer(oldsub))
         for kk = 1:length(Exp)
            mu = uimenu(expm,'Label',Exp{kk},'callback',...
               ['iduiexp(''check'',',int2str(kwin),')']);
            if kk==1
               set(mu,'checked','on');
            end
         end
      end
   end
case 'check'
   curo = gcbo;
   set(get(get(curo,'parent'),'children'),'checked','off')
   set(curo,'checked','on')
   iduiclpw(win);
case 'find'
   try
   men = findobj(get(XID.plotw(win,1),'children'),'flat','Label','Experiment');
   ch = findobj(get(men,'children'),'checked','on');
   exp = get(ch,'Label');
   exnr = find(strcmp(exp,names));
catch
   exnr = 1;
end
case 'merge'
   figname=idlaytab('figname',36);
   if ~figflag(figname,0)
      iduistat('Opening dialog box ...')
      layout
      CBWH = [1.8*mStdButtonWidth mStdButtonHeight];
PUWH = [1.8*mStdButtonWidth CBWH(2)];
Voff = 5*mEdgeToFrame;            % Uicontrol vertical/horizontal offset

% Make axes have appealling "golden" ratio
AxisW = (CBWH(1)-Voff)/2;
AWH = AxisW*[1 2/(1+sqrt(5))];

      f=figure('HandleVisibility','callback',...
         'NumberTitle','off','Name',figname,'tag','sitb36',...
         'DockControls','off',...
         'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off');
      set(f,'Menubar','none');
      XID.sel(1,7)=f;
      FigW=iduilay2(2);
      cb1='iduipoin(1);iduistat(''Compiling...'');';
      cb2='iduipoin(1);';
      cb3='iduipoin(2);';
      
      % LEVEL 1
      
      pos = iduilay1(FigW,4,2);
      uicontrol(f,'pos',pos(1,:),'style','frame');
      uicontrol(f,'Pos',pos(2,:),'style','push','callback',...
         [cb2,'iduiexp(''insert'');',cb3],'string','Insert');
      uicontrol(f,'Pos',pos(3,:),'style','push','callback',...
         [cb2,'iduiexp(''revert'');',cb3],'string','Revert');
      uicontrol(f,'Pos',pos(4,:),'style','push','callback',...
         'set(gcf,''vis'',''off'');','string','Close');
      uicontrol(f,'Pos',pos(5,:),'style','push','callback',...
         'iduihelp(''idmergeexp.hlp'',''Help: Merge Experiments'');','string','Help');
      
      % LEVEL 2
      lev2=pos(1,2)+pos(1,4);
      pos = iduilay1(FigW,8,4,lev2);
      %uicontrol(f,'pos',pos(1,:),'style','frame');
      uicontrol(f,'pos',pos(2,:)+[0 0 0 20],'style',...
         'text','string','Drag data sets from data boards and...',...
         'horizontalalignment','left')
      uicontrol(f,'pos',pos(3,:),'style','text','tag','wdname',...
         'horizontalalignment','left','string','List of sets')
      
      uicontrol(f,'pos',pos(8,:),'style','text',...
         'string','Data name:','HorizontalAlignment','left');
      XID.sel(2,7)=uicontrol(f,'pos',pos(9,:),'style',...
         'edit',...
         'HorizontalAlignment','left',...
         'backgroundcolor','white');
      
      XID.sel(3,7)=axes('unit','pix','pos',[pos(6,1:2) 1.1*AWH],'tag','merge','color','white',...
         'Xtick',[],'Ytick',[],'box','on');
      text('pos',[0.1 0.5],'string',...
         str2mat('drop them here','to be merged'),'fontsize',8);
      XID.sel(3,8)=uicontrol(f,'pos',pos(7,:)+[0 0 0 30],'style','listbox',...
         'HorizontalAlignment','left',...
          'max',4,'min',1,'enable','inactive','value',[]);

      %uicontrol(f,'pos',pos(6,:),'style','text','string',...
        % str2mat('Experiments:'),'HorizontalAlignment','left','tag','lltest');
      %XID.sel(4,2)=uicontrol(f,'pos',pos(11,:)+[0 0 0 20],'style',...
      %   'listbox',...
      %   'HorizontalAlignment','left',...
      %   'backgroundcolor','white','max',4,'min',1);
      %uicontrol(f,'pos',pos(10,:),'style','text',...
      %   'string',str2mat('Outputs:'),'HorizontalAlignment',...
      %   'left');
      FigWH=[iduilay2(2) pos(1,2)+pos(1,4)+mEdgeToFrame+20];
      ScreenPos = get(0,'ScreenSize');
      FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
      set(f,'pos',FigPos);
      set(get(f,'children'),'unit','norm');
      if length(XID.layout)>34,if XID.layout(35,3)
            eval('set(f,''pos'',XID.layout(35,1:4))','');
         end,end
      set(f,'vis','on')
   end
   set(Xsum,'UserData',XID);
   iduiexp('revert')
   iduistat('Ready to select experiments.')
case 'merge_data'
   newmod = get(XID.sel(2,7),'user');
   if ~strcmp(class(newmod),'iddata')
      errordlg('Only Data sets can be dropped here.','Error Dialog','modal')
      return
      end
   if size(newmod,'Ne')==1
      newmod = pvset(newmod,'ExperimentName',pvget(newmod,'Name'));
      end
   oldmod = get(XID.sel(3,7),'user');
   str = get(XID.sel(3,8),'string');
      if isempty(oldmod)
      set(XID.sel(3,7),'user',newmod);
   else
      try
         mmod = merge(oldmod,newmod);
         mmod = iduiinfo('set',mmod,...
            str2mat(iduiinfo('get',oldmod),iduiinfo('get',newmod)));
         
               catch
         errordlg(lasterr,'Error Dialog','modal')
         return
      end
      set(XID.sel(3,7),'user',mmod);

   end
   set(XID.sel(3,8),'string',[str;{pvget(newmod,'Name')}]);

case 'revert'
   dat = iduigetd('e');
   nam = pvget(dat,'Name');
   modn = [nam,'m'];
   set(XID.sel(2,7),'string',modn);
   set(XID.sel(3,7),'user',[]);
   set(XID.sel(3,8),'string',[]);
case 'insert'
   mod = get(XID.sel(3,7),'user');
   if isempty(mod)
      errordlg('No data sets selected','Error Dialog','model');
      return
      end
   modn = get(XID.sel(2,7),'string');
   mod = pvset(mod,'Name',modn);
   names = get(XID.sel(3,8),'string');
   str = [' ',modn,' = merge('];
   for kk = 1:length(names)
      str = [str,names{kk},','];
   end
   str = [str(1:end-1),')'];
   mod = iduiinfo('add',mod,str);
   iduiinsd(mod); 


   end
  
   
   
