function iduiiter(arg)
%IDUIITER Handles all iteration control for parameter estimation methods.
%   Arguments
%   open     Opens the dialog box
%   interr   Sets the callback to be interruptible
%   continue Makes the iterations continue where stopped
%   stop     Stops the iterations
%   close    Closes the dialog window

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $ $Date: 2004/04/10 23:19:47 $

%global XIDparest XIDsumb XIDiter XIDlayout
 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if strcmp(arg,'open')
   FigName=idlaytab('figname',22);
   if ~figflag(FigName)
       layout
       butw=mStdButtonWidth;
       PW = iduilay2(5);
       XID.iter(1)=figure('NumberTitle','off',...
           'DockControls','off',...
       'Name',FigName,'HandleVisibility','callback','tag','sitb22',...
       'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off',...
	'Integerhandle','off');
       set(XID.iter(1),'Menubar','none');
       s1='iduipoin(1);';s3='iduipoin(2);';
% ******************
       % LEVEL 1
       pos = iduilay1(PW,5);
       uicontrol(XID.iter(1),'pos',pos(1,:),'style','frame');
       uicontrol(XID.iter(1),'pos',pos(4,:),'style','push','string',...
             'Options','callback',...
             [s1,'iduiopt(''dlg_ioopt'',''ioopt'',1,1:4);',s3]);
       uicontrol(XID.iter(1),'pos',pos(5,:),'string','Close',...
                'style','push','callback','iduiiter(''close'')');
       uicontrol(XID.iter(1),'pos',pos(6,:),'string','Help','style','push',...
                 'callback',...
                 'iduihelp(''iduiiter.hlp'',''Help: Iteration Control'');');
       XID.iter(7)=uicontrol(XID.iter(1),'pos',pos(2,:),...
                 'style','push','string','Stop',...
                 'callback',[s1,'iduiiter(''stop'');',s3],'enable','off');

       XID.iter(8)=uicontrol(XID.iter(1),'pos',pos(3,:),'string','Continue',...
                'style','push','callback',[s1,'iduiiter(''continue'');',s3]);


% ****************
        % LEVEL 2

       lev2 = pos(1,2)+pos(1,4);
       pos = iduilay1(PW,2,1,lev2,[],2.5);
       uicontrol(XID.iter(1),'pos',pos(1,:),'style','frame');
       XID.iter(2)=uicontrol(XID.iter(1),'pos',pos(2,:),'string',...
                 'Info to command line','style','check');
       XID.iter(3)=uicontrol(XID.iter(1),'pos',pos(3,:),'string',...
                 'Enable Interrupt',...
                 'style','check','callback',[s1,'iduiiter(''interr'');',s3]);

       % LEVEL 3

       lev3 = pos(1,2)+pos(1,4);
       pos = iduilay1(PW,8,2,lev3,[],[0.5 1.5 1.5 1.5]);
       uicontrol(XID.iter(1),'pos',pos(1,:),'style','frame');
       XID.iter(4)=uicontrol(XID.iter(1),'pos',pos(6,:),'style','text');
       XID.iter(5)=uicontrol(XID.iter(1),'pos',pos(7,:),'style','text');
      % XID.iter(9)=uicontrol(XID.iter(1),'pos',pos(8,:),'style','text');
       XID.iter(6)=uicontrol(XID.iter(1),'pos',pos(9,:),'style','text');
       uicontrol(XID.iter(1),'pos',pos(2,:),'style','text',...
                'string','Iter #');
       uicontrol(XID.iter(1),'pos',pos(3,:),'style',...
                'text','string','Current fit');
%        uicontrol(XID.iter(1),'pos',pos(4,:),'style',...
%                 'text','string','Previous fit');
       uicontrol(XID.iter(1),'pos',pos(5,:),'style','text',...
                'string','Improvement (%)');
       figpos = [50 40 PW pos(1,2)+pos(1,4)+mEdgeToFrame];
       set(XID.iter(1),'pos',figpos);
       set(get(XID.iter(1),'children'),'unit','norm');
       if length(XID.layout)>21,if XID.layout(22,3)
         eval('set(XID.iter(1),''pos'',XID.layout(22,1:4))','')
       end,end
  end

  set(XID.iter(1),'vis','on')
% ******************************
set(Xsum,'UserData',XID);
elseif strcmp(arg,'interr')
   if get(XID.iter(3),'value')
      onoff='on';
   else
      ;onoff='off';
   end
   set(XID.parest(2),'interruptible',onoff)
   set(XID.iter(8),'interruptible',onoff)
   set(XID.iter(7),'enable',onoff)
elseif strcmp(arg,'continue')
    mname=get(XID.parest(7),'string');
   % set(XID.parest(3),'string',mname);
    set(XID.parest(7),'string',[mname,'c']);
     sumb=findobj(get(0,'children'),'flat','tag','sitb30');
     modax=findobj([XID.sumb(1);sumb(:)],'type','axes',...
          'tag',get(XID.parest(3),'userdata'));
     % set(XID.parest(4),'value',6) %%%%
     if ~isempty(modax)
         modax=modax(1);
         modn=findobj(modax,'tag','name');
         mod_inf=get(modn,'userdata');
         modlin=findobj(modax,'tag','modelline');
         if ~isempty(modlin)
                  nn=iduicalc('unpack',get(modlin,'UserData'),1);
         else 
             nn=[];
         end
     else 
         nn=[];
     end
    if isempty(nn),
       errordlg(['Failed to capture last model.',...
                        '\nTo continue, drag-and-drop last estimated model to the',...
                        ' Orders: edit field in the Parametric Models dialog box',...
                        ' and then press the Estimate button.'],'Error Dialog','modal');
       iduistat('')
       return
    end
    iduistat(['Continuing using PEM from ',mname],1);
    iduiio('estimate',nn,mod_inf);
elseif strcmp(arg,'stop')
    set(XID.iter(7),'userdata',1);
    iduistat('Iterations will be stopped after the current one.')
elseif strcmp(arg,'close')
    set(XID.iter(1),'Visible','off')
    %set(XID.parest(5),'value',0)
end
