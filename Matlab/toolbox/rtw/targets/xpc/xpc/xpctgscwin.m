function xpctgscwin(flag,targetnumber)

% XPCTGSCWIN - XPTGCSCOPE Helper Function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.4.1 $ $Date: 2004/04/08 21:05:19 $

colornorm=[0.752941,0.752941,0.752941];

if nargin~=1
  set(0,'ShowHiddenHandles','on');
  h_scope=get(0, 'Children');
  openscope=strmatch(['xPC Target: Target Scope ',num2str(targetnumber)], get(h_scope, 'Name'));
  set(0,'ShowHiddenHandles','off');
else
  openscope=[];
end;

scrsize=get(0,'ScreenSize');

if isempty(openscope) & flag == 0

  usrdata.edit.modelname=xpcgate('getname');
  usrdata.edit.targetnumber=targetnumber;

  set(0,'ShowHiddenHandles','on');
  h_main=get(0, 'Children');
  opened=strmatch('xPC Target: Target Manager', get(h_main, 'Name'));
  set(0,'ShowHiddenHandles','off');

  targetmanager=get(h_main(opened), 'UserData');
  usrdata.targetmanager.figure=targetmanager.figure;

  usrdata.edit.scrsize=scrsize;
  usrdata.figure.signalframes=[];

  usrdata.edit.subfigures.signals=-1;
  usrdata.edit.subfigures.trigger=-1;
  usrdata.figures.axis=-1;
  usrdata.figures.export=-1;
  usrdata.edit.subfigure.signals.position=[(scrsize(3)-500)*0.93,(scrsize(4)-360)*0.88 500 360];
  usrdata.edit.subfigure.trigger.position=[(scrsize(3)-260)*0.55,(scrsize(4)-260)*0.2,260,260];
  scNo = usrdata.edit.targetnumber;
  usrdata.edit.trigger.mode  = xpcgate('getsctriggermode',  scNo)+1;
  usrdata.edit.trigger.slope = xpcgate('getsctriggerslope', scNo)+1;
  usrdata.edit.trigger.level = xpcgate('getsctriggerlevel', scNo);
  usrdata.edit.mode.samples  = xpcgate('getscnosamples',    scNo);
  usrdata.edit.mode.prepostsamples = xpcgate('getscnoprepostsamples', scNo);
  usrdata.edit.mode.interleave = xpcgate('getscinterleave', scNo);
  usrdata.edit.target.axis.auto = 'on';
  usrdata.edit.target.axis.manual = 'off';
  usrdata.edit.target.yaxis.max = 1;
  usrdata.edit.target.yaxis.min = -1;
  usrdata.edit.target.dataplot=['target',num2str(usrdata.edit.targetnumber),'_data'];
  usrdata.edit.target.timeplot=['target',num2str(usrdata.edit.targetnumber),'_time'];

  limits=xpcgate('gettgscylimits',usrdata.edit.targetnumber);
  limits1=limits(1);
  limits2=limits(2);
  if (limits1==0) & (limits1==0)
    usrdata.edit.target.axis.auto='on';
    usrdata.edit.target.axis.manual='off';
  else
    usrdata.edit.target.axis.auto='off';
    usrdata.edit.target.axis.manual='on';
  end;
  usrdata.edit.target.yaxis.min=limits1;
  usrdata.edit.target.yaxis.max=limits2;

  if xpcgate('gettgscgrid',usrdata.edit.targetnumber)==1
    usrdata.edit.target.grid='on';
  else
    usrdata.edit.target.grid='off';
  end;

  if xpcgate('gettgscmode',usrdata.edit.targetnumber)==0
    usrdata.edit.target.num='on';
    usrdata.edit.target.graph.redraw='off';
    usrdata.edit.target.graph.sliding='off';
    usrdata.edit.target.graph.rolling='off';
  elseif xpcgate('gettgscmode',usrdata.edit.targetnumber)==1
    usrdata.edit.target.num='off';
    usrdata.edit.target.graph.redraw='on';
    usrdata.edit.target.graph.sliding='off';
    usrdata.edit.target.graph.rolling='off';
  elseif xpcgate('gettgscmode',usrdata.edit.targetnumber)==2
    usrdata.edit.target.num='off';
    usrdata.edit.target.graph.redraw='off';
    usrdata.edit.target.graph.sliding='on';
    usrdata.edit.target.graph.rolling='off';
  elseif xpcgate('gettgscmode',usrdata.edit.targetnumber)==3
    usrdata.edit.target.num='off';
    usrdata.edit.target.graph.redraw='off';
    usrdata.edit.target.graph.sliding='off';
    usrdata.edit.target.graph.rolling='on';
  end;

  %[xa,ya]=gettgscaxes(usrdata.edit.targetnumber);
  xa=1;
  if xa==0
    usrdata.edit.target.set_x_axis='off';
  else
    usrdata.edit.target.set_x_axis='on';
  end;
  ya=1;
  if ya==0
    usrdata.edit.target.set_y_axis='off';
  else
    usrdata.edit.target.set_y_axis='on';
  end;

% names=getbio(usrdata.edit.modelname);
  names=xpcgate('getbio',usrdata.edit.modelname);
  names=regexprep(names,'^\s','');
  usrdata.S=getsignals(names,usrdata.edit.modelname);
  usrdata.S.modelpath='';

  hnew=xpctgscwinfig;

  usrdata.target.figure=findobj(hnew,'Tag','xpctgscwinfig');
  set(usrdata.target.figure,'Color',[0.752941,0.752941,0.752941],'CloseRequestFcn','xpctgscwin(-5,1)');

  targetsontarget=1;%gettargets;

  signalsontarget=xpcgate('getscsignals',usrdata.edit.targetnumber);
  if usrdata.edit.trigger.mode==3
    triggerontarget=xpcgate('getsctriggersignal',usrdata.edit.targetnumber);
  elseif usrdata.edit.trigger.mode==4
    triggerontarget=xpcgate('getsctriggerscope',usrdata.edit.targetnumber);
  else
    triggerontarget=[];
  end;

  trace=[];

  usrdata.edit.signals2trace={};
  usrdata.edit.api.signals2trace={[]};
  if xpcgate('getsctriggermode',usrdata.edit.targetnumber)==1
    usrdata.edit.trigger.signal='Software';
  else
    usrdata.edit.trigger.signal='FreeRun';
  end;
  usrdata.edit.api.triggersignal={};

  if ~isempty(signalsontarget)
    for j=1:length(signalsontarget)
      signalname=xpcgate('showsig',usrdata.edit.modelname,signalsontarget(j));
      signalname=getsignal(signalname);

      usrdata.edit.signals2trace{j}=signalname;

      trace(j)=signalsontarget(j);

      usrdata.edit.api.signals2trace{1,1}=trace;
    end;
  end;

  if ~isempty(triggerontarget) & ~isempty(signalsontarget)
    if usrdata.edit.trigger.mode==3
      triggername=xpcgate('showsig',usrdata.edit.modelname,triggerontarget);
      triggername=getsignal(triggername);

      usrdata.edit.trigger.signal=triggername;
      usrdata.edit.api.triggersignal{1,1}=triggerontarget;
    end;
    if usrdata.edit.trigger.mode==4

      usrdata.edit.trigger.signal=['.Scope_',num2str(triggerontarget)];
      usrdata.edit.api.triggersignal{1,1}=triggerontarget;
    end;
  end;

  usrdata.menu.y_axis_auto=findobj(hnew,'Tag','plotsubmenu1');
  usrdata.menu.y_axis_manual=findobj(hnew,'Tag','plotsubmenu2');
  usrdata.menu.grid=findobj(hnew,'Tag','plotmenu2');
  usrdata.menu.mode.graph.redraw=findobj(hnew,'Tag','plotsubmenu31');
  usrdata.menu.mode.graph.sliding=findobj(hnew,'Tag','plotsubmenu32');
  usrdata.menu.mode.graph.rolling=findobj(hnew,'Tag','plotsubmenu33');
  usrdata.menu.mode.num=findobj(hnew,'Tag','plotsubmenu30');
  usrdata.menu.set_x_axis=findobj(hnew,'Tag','plotmenu5');
  usrdata.menu.set_y_axis=findobj(hnew,'Tag','plotmenu6');
  usrdata.menu.y_axis_manual=findobj(hnew,'Tag','plotsubmenu2');
  usrdata.menu.close=findobj(hnew,'Tag','plotmenu3');
  usrdata.figure.target.frm_trigger=findobj(hnew,'Tag','frm_trigger');
  usrdata.figure.target.ftl_trigger=findobj(hnew,'Tag','ftl_trigger');
  usrdata.figure.target.txt_triggersignal1=findobj(hnew,'Tag','txt_triggersignal1');
  usrdata.figure.target.txt_triggersignal2=findobj(hnew,'Tag','txt_triggersignal2');
  usrdata.figure.target.pb_definetrigger=findobj(hnew,'Tag','pb_definetrigger');
  usrdata.figure.target.frm_mode=findobj(hnew,'Tag','frm_mode');
  usrdata.figure.target.ftl_mode=findobj(hnew,'Tag','ftl_mode');
  usrdata.figure.target.txt_interleave=findobj(hnew,'Tag','txt_interleave');
  usrdata.figure.target.txt_samples=findobj(hnew,'Tag','txt_samples');
  usrdata.figure.target.ed_interleave=findobj(hnew,'Tag','ed_interleave');
  usrdata.figure.target.ed_samples=findobj(hnew,'Tag','ed_samples');
  usrdata.figure.target.frm_signals=findobj(hnew,'Tag','frm_signal');
  usrdata.figure.target.ftl_signals=findobj(hnew,'Tag','ftl_signals');
  usrdata.figure.target.pb_add_remove=findobj(hnew,'Tag','pb_add_remove');

  scrsize=get(0,'ScreenSize');

  position=[(scrsize(3)-50)*0.1,(scrsize(4)-50)*0.1,250,200];
  set(usrdata.target.figure,'Position',position,'Name',['xPC Target: Target Scope ',num2str(usrdata.edit.targetnumber)]);

  set(usrdata.menu.y_axis_auto,'CallBack','xpctgscwin(-6)','Checked',usrdata.edit.target.axis.auto);
  set(usrdata.menu.y_axis_manual,'CallBack','xpctgscwin(-7)','Checked',usrdata.edit.target.axis.manual);
  set(usrdata.menu.grid,'CallBack','xpctgscwin(-8)','Checked',usrdata.edit.target.grid);
  set(usrdata.menu.close,'CallBack','xpctgscwin(-5,1)');
  set(usrdata.menu.mode.graph.redraw,'CallBack','xpctgscwin(-9)','Checked',usrdata.edit.target.graph.redraw);
  set(usrdata.menu.mode.graph.sliding,'CallBack','xpctgscwin(-20)','Checked',usrdata.edit.target.graph.sliding);
  set(usrdata.menu.mode.graph.rolling,'CallBack','xpctgscwin(-21)','Checked',usrdata.edit.target.graph.rolling);
  set(usrdata.menu.mode.num,'CallBack','xpctgscwin(-10)','Checked',usrdata.edit.target.num);
  set(usrdata.menu.set_x_axis,'CallBack','xpctgscwin(-11)','Checked',usrdata.edit.target.set_x_axis);
  set(usrdata.menu.set_y_axis,'CallBack','xpctgscwin(-12)','Checked',usrdata.edit.target.set_y_axis);

  set(usrdata.figure.target.ed_samples,'String',convsample(usrdata.edit.mode.prepostsamples,usrdata.edit.mode.samples));
  set(usrdata.figure.target.ed_interleave,'String',num2str(usrdata.edit.mode.interleave));

  trigger=usrdata.edit.trigger.signal;
  trigger(find(trigger=='.'))='/';
  set(usrdata.figure.target.txt_triggersignal2,'String',trigger);

  set(usrdata.figure.target.frm_trigger,'Position',[10,10,230,70]);
  set(usrdata.figure.target.ftl_trigger,'Position',[15,70,70,15]);
  set(usrdata.figure.target.pb_definetrigger,'Position',[(position(3)/2)-80/2,20,80,25],'CallBack','xpctgscwin(-4)');
  set(usrdata.figure.target.txt_triggersignal1,'Position',[15,50,70,15]);
  set(usrdata.figure.target.txt_triggersignal2,'Position',[90,50,145,15]);

  set(usrdata.figure.target.frm_mode,'Position',[120,100,120,80]);
  set(usrdata.figure.target.ftl_mode,'Position',[125,170,60,15]);
  set(usrdata.figure.target.txt_samples,'Position',[125,145,60,15]);
  set(usrdata.figure.target.txt_interleave,'Position',[125,115,60,15]);
  set(usrdata.figure.target.ed_samples,'Position',[170,145,60,18],'CallBack','xpctgscwin(-1)');
  set(usrdata.figure.target.ed_interleave,'Position',[180,115,50,18],'CallBack','xpctgscwin(-2)');

  set(usrdata.figure.target.frm_signals,'Position',[10,100,100,80]);
  set(usrdata.figure.target.ftl_signals,'Position',[15,170,60,15]);
  set(usrdata.figure.target.pb_add_remove,'Position',[20,127.5,80,25],'CallBack','xpctgscwin(-3)');

  targetmanager=get(usrdata.targetmanager.figure,'UserData');
  pbhandle=findobj(usrdata.targetmanager.figure,'String',['Scope ',num2str(usrdata.edit.targetnumber)]);
  pbtag=get(pbhandle,'Tag');
  number=str2num(pbtag(end-1));
  if ~isempty(number)
    pbnum=str2num(pbtag(end))+10;
  else
    pbnum=str2num(pbtag(end));
  end;
  if isempty(usrdata.edit.signals2trace)
    set(targetmanager.menu(pbnum).startstop, 'Enable','off');
  else
    set(targetmanager.menu(pbnum).startstop, 'Enable','on');
  end;

  targetmanager.handles.xpctgscwin(usrdata.edit.targetnumber)=usrdata.target.figure;
  set(targetmanager.figure,'UserData',targetmanager);
  set(usrdata.target.figure,'UserData',usrdata);

else

  if nargin==0
    return;
  end;
  usrdata=get(gcbf,'UserData');

  %-----------------------------------
  % CallBack Samples
  %-----------------------------------

  if flag==-1

    [prepostsamples,samples]=convsample(get(usrdata.figure.target.ed_samples, 'String'));
    if isempty(samples)
      errordlg('Samples must be a number');
      set(usrdata.figure.target.ed_samples,'String',convsample(usrdata.edit.mode.prepostsamples,usrdata.edit.mode.samples));
    elseif samples<=2
      errordlg('Samples must be greater than 2');
      set(usrdata.figure.target.ed_samples,'String', convsample(usrdata.edit.mode.prepostsamples,usrdata.edit.mode.samples));
    else
      samples=get(usrdata.figure.target.ed_samples, 'String');
      [prepostsamples,samples]=convsample(samples);
      usrdata.edit.mode.samples=samples;
      usrdata.edit.mode.prepostsamples=prepostsamples;
      set(gcbf,'UserData',usrdata);
      action='xpcgate(''setscnosamples'',usrdata.edit.targetnumber,usrdata.edit.mode.samples);';
      action=[action,'xpcgate(''setscnoprepostsamples'',usrdata.edit.targetnumber,usrdata.edit.mode.prepostsamples);'];
      writetotarget(usrdata,action);
    end;

    %-----------------------------------
    % CallBack Interleave
    %-----------------------------------

  elseif flag == -2

    if isempty(str2num(get(usrdata.figure.target.ed_interleave, 'String')))
      errordlg('Interleave must be a number');
      set(usrdata.figure.target.ed_interleave,'String', num2str(usrdata.edit.mode.interleave));
    elseif str2num(get(usrdata.figure.target.ed_interleave, 'String'))<=0
      errordlg('Interleave must be greater then 0');
      set(usrdata.figure.target.ed_interleave,'String', num2str(usrdata.edit.mode.interleave));
    else
      interleave=str2num(get(usrdata.figure.target.ed_interleave, 'String'));
      usrdata.edit.mode.interleave=interleave;
      set(gcbf,'UserData',usrdata);
      action='xpcgate(''setscinterleave'',usrdata.edit.targetnumber,usrdata.edit.mode.interleave);';
      writetotarget(usrdata,action);
    end;

    %-----------------------------------
    % push button Add/Remove Signal
    %-----------------------------------

  elseif flag == -3

    if usrdata.edit.subfigures.signals==-1
      xpctgscsignalwin(usrdata.target.figure);
    else
      figure(usrdata.edit.subfigures.signals);
    end;

    %-----------------------------------
    % push button Trigger Signal
    %-----------------------------------

  elseif flag == -4

    if usrdata.edit.subfigures.trigger==-1
      xpctgsctriggerwin(0,0);
    else
      figure(usrdata.edit.subfigures.trigger);
    end;

    %-----------------------------------
    % Deletefcn
    %-----------------------------------

  elseif flag==-5

    if targetnumber==1
      usrdata=get(gcbf, 'userdata');
      targetmanager=get(usrdata.targetmanager.figure, 'UserData');
    end;

    targetmanager.handles.xpctgscwin(usrdata.edit.targetnumber)=-1;
    set(targetmanager.figure,'UserData',targetmanager);

    if usrdata.edit.subfigures.trigger~=-1, delete(usrdata.edit.subfigures.trigger); end;
    if usrdata.edit.subfigures.signals~=-1, delete(usrdata.edit.subfigures.signals); end;
    if usrdata.figures.axis~=-1, delete(usrdata.figures.axis); end;
    delete(usrdata.target.figure);

    %-----------------------------------
    % Menu Y-Axis auto
    %-----------------------------------

  elseif flag == -6

    xpcgate('settgscylimits',usrdata.edit.targetnumber,[0,0]);
    set(usrdata.menu.y_axis_auto,'Checked','on');
    set(usrdata.menu.y_axis_manual,'Checked','off');
    usrdata.edit.target.axis.auto='on';
    usrdata.edit.target.axis.manual='off';

    set(gcbf,'UserData',usrdata);

    %-----------------------------------
    % Menu Y-Axis manual
    %-----------------------------------

  elseif flag == -7

    y=xpcgate('gettgscylimits',usrdata.edit.targetnumber);
    ymin=y(1);
    ymax=y(2);

    if usrdata.figures.axis==-1

      usrdata.figures.axis = ...
          figure('Color',[0.8 0.8 0.8], ...
                 'Name','Define Y-Axis Scaling', ...
                 'NumberTitle','off', ...
                 'MenuBar', 'none', ...
                 'Color',colornorm, ...
                 'Units','points',...
                 'HandleVis','off',...
                 'CloseRequestFcn', 'xpctgscwin(-14)', ...
                 'Position',[scrsize(3)/2-150,scrsize(4)/2-100,150,100], ...
                 'Tag','Fig1');
      setxpcfont(usrdata.figures.axis,8,9);
      set(usrdata.figures.axis,'Userdata',usrdata.target.figure);


      usrdata.figure.axis.txt_ymax = ...
          uicontrol('Parent',usrdata.figures.axis, ...
                    'Units','normalized', ...
                    'HorizontalAlignment','left', ...
                    'Position',[0.1 0.7 0.3 0.15], ...
                    'String','Y_max:', ...
                    'Style','text', ...
                    'Tag','StaticText3');

      usrdata.figure.axis.ed_ymax = ...
          uicontrol('Parent',usrdata.figures.axis, ...
                    'Units','normalized', ...
                    'BackgroundColor',[1 1 1], ...
                    'HorizontalAlignment','right', ...
                    'Position',[.5 .73 .4 .15], ...
                    'String', ymax, ...
                    'Style','edit', ...
                    'Callback', 'xpctgscwin(-13)', ...
                    'Tag','EditText1');

      usrdata.figure.axis.txt_ymin = ...
          uicontrol('Parent',usrdata.figures.axis, ...
                    'Units','normalized', ...
                    'HorizontalAlignment','left', ...
                    'Position',[0.1 0.45 0.3 0.15], ...
                    'String','Y_min:', ...
                    'Style','text', ...
                    'Tag','StaticText3');

      usrdata.figure.axis.ed_ymin = ...
          uicontrol('Parent',usrdata.figures.axis, ...
                    'Units','normalized', ...
                    'BackgroundColor',[1 1 1], ...
                    'HorizontalAlignment','right', ...
                    'Position',[.5 .48 .4 .15], ...
                    'String', ymin, ...
                    'Style','edit', ...
                    'Callback', 'xpctgscwin(-13)', ...
                    'Tag','EditText1');

      usrdata.figure.axis.pb_apply = ...
          uicontrol('Parent',usrdata.figures.axis, ...
                    'Units','normalized', ...
                    'Position',[0.1 0.05 0.35 0.25], ...
                    'String','Apply', ...
                    'CallBack', 'xpctgscwin(-13)', ...
                    'Tag','Pushbutton1');

      usrdata.figure.axis.pb_close = ...
          uicontrol('Parent',usrdata.figures.axis, ...
                    'Units','normalized', ...
                    'Position',[0.55 0.05 0.35 0.25], ...
                    'String','Close', ...
                    'CallBack', 'xpctgscwin(-14)', ...
                    'Tag','Pushbutton1');

      set(usrdata.target.figure,'UserData',usrdata);

    else
      figure(usrdata.figures.axis);
    end;

    %-----------------------------------
    % Menu Grid
    %-----------------------------------

  elseif flag == -8
    if xpcgate('gettgscgrid',usrdata.edit.targetnumber)==0
      set(usrdata.menu.grid,'Checked','on');
      xpcgate('settgscgrid',usrdata.edit.targetnumber,1);
      usrdata.edit.target.grid='on';
    else
      set(usrdata.menu.grid,'Checked','off');
      xpcgate('settgscgrid',usrdata.edit.targetnumber,0);
      usrdata.edit.target.grid='off';
    end;

    set(gcbf,'UserData',usrdata);

    %-----------------------------------
    % Menu Mode Graphical
    %-----------------------------------

  elseif flag == -9
    if xpcgate('gettgscmode',usrdata.edit.targetnumber)~=1
      set(usrdata.menu.grid,'Checked','on','Enable','on');
      set(usrdata.menu.mode.graph.redraw,'Checked','on');
      set(usrdata.menu.mode.graph.sliding,'Checked','off');
      set(usrdata.menu.mode.graph.rolling,'Checked','off');
      set(usrdata.menu.mode.num,'Checked','off');
      xpcgate('settgscmode',usrdata.edit.targetnumber,1)
      usrdata.edit.target.graph.redraw='on';
      usrdata.edit.target.graph.sliding='off';
      usrdata.edit.target.graph.rolling='off';
      usrdata.edit.target.num='off';
    end;

    set(gcbf,'UserData',usrdata);

  elseif flag == -20
    if xpcgate('gettgscmode',usrdata.edit.targetnumber)~=2
      set(usrdata.menu.grid,'Checked','on','Enable','on');
      set(usrdata.menu.mode.graph.redraw,'Checked','off');
      set(usrdata.menu.mode.graph.sliding,'Checked','on');
      set(usrdata.menu.mode.graph.rolling,'Checked','off');
      set(usrdata.menu.mode.num,'Checked','off');
      xpcgate('settgscmode',usrdata.edit.targetnumber,2)
      usrdata.edit.target.graph.redraw='off';
      usrdata.edit.target.graph.sliding='on';
      usrdata.edit.target.graph.rolling='off';
      usrdata.edit.target.num='off';
    end;

    set(gcbf,'UserData',usrdata);
  elseif flag == -21
    if xpcgate('gettgscmode',usrdata.edit.targetnumber)~=3
      set(usrdata.menu.grid,'Checked','on','Enable','on');
      set(usrdata.menu.mode.graph.redraw,'Checked','off');
      set(usrdata.menu.mode.graph.sliding,'Checked','off');
      set(usrdata.menu.mode.graph.rolling,'Checked','on');
      set(usrdata.menu.mode.num,'Checked','off');
      xpcgate('settgscmode',usrdata.edit.targetnumber,3)
      usrdata.edit.target.graph.redraw='off';
      usrdata.edit.target.graph.sliding='off';
      usrdata.edit.target.graph.rolling='on';
      usrdata.edit.target.num='off';
    end;

    set(gcbf,'UserData',usrdata);

    %-----------------------------------
    % Menu Mode Numerical
    %-----------------------------------

  elseif flag == -10
    if xpcgate('gettgscmode',usrdata.edit.targetnumber)~=0
      set(usrdata.menu.grid,'Checked','off','Enable','off');
      set(usrdata.menu.mode.graph.redraw,'Checked','off');
      set(usrdata.menu.mode.graph.sliding,'Checked','off');
      set(usrdata.menu.mode.graph.rolling,'Checked','off');
      set(usrdata.menu.mode.num,'Checked','on');
      xpcgate('settgscmode',usrdata.edit.targetnumber,0);
      usrdata.edit.target.graph.redraw='off';
      usrdata.edit.target.graph.sliding='off';
      usrdata.edit.target.graph.rolling='off';
      usrdata.edit.target.num='on';
    end;

    set(gcbf,'UserData',usrdata);

    %-----------------------------------
    % Menu Set X-Axis
    %-----------------------------------

  elseif flag == -11
    %[x,y]=gettgscaxes(usrdata.edit.targetnumber);
    x=1;
    if x==0
      set(usrdata.menu.set_x_axis,'Checked','on');
      settgscaxes(usrdata.edit.targetnumber,1,y);
      usrdata.edit.target.set_x_axis='on';
    else
      set(usrdata.menu.set_x_axis,'Checked','off');
      settgscaxes(usrdata.edit.targetnumber,0,y);
      usrdata.edit.target.set_x_axis='off';
    end;

    set(gcbf,'UserData',usrdata);

    %-----------------------------------
    % Menu Set Y-Axis
    %-----------------------------------

  elseif flag == -12
    %[x,y]=gettgscaxes(usrdata.edit.targetnumber);
    y=1;
    if y==0
      set(usrdata.menu.set_y_axis,'Checked','on');
      settgscaxes(usrdata.edit.targetnumber,x,1);
      usrdata.edit.target.set_y_axis='on';
    else
      set(usrdata.menu.set_y_axis,'Checked','off');
      settgscaxes(usrdata.edit.targetnumber,x,0);
      usrdata.edit.target.set_y_axis='off';
    end;

    set(gcbf,'UserData',usrdata);

    %-----------------------------------
    % Define-Axis Ymax Ymin
    %-----------------------------------

  elseif flag==-13

    usrdata=get(get(gcbf,'UserData'),'UserData');

    if str2num(get(usrdata.figure.axis.ed_ymax,'String')) <= str2num(get(usrdata.figure.axis.ed_ymin,'String'));
      errordlg('Ymax must be greater then Ymin');
      set(usrdata.figure.axis.ed_ymax,'String', num2str(usrdata.edit.target.yaxis.max));
      set(usrdata.figure.axis.ed_ymin,'String', num2str(usrdata.edit.target.yaxis.min));
      return;
    end;

    usrdata.edit.target.yaxis.max=str2num(get(usrdata.figure.axis.ed_ymax,'String'));
    usrdata.edit.target.yaxis.min=str2num(get(usrdata.figure.axis.ed_ymin,'String'));

    xpcgate('settgscylimits',usrdata.edit.targetnumber,[usrdata.edit.target.yaxis.min,usrdata.edit.target.yaxis.max]);
    set(usrdata.menu.y_axis_auto,'Checked','off');
    set(usrdata.menu.y_axis_manual,'Checked','on');
    usrdata.edit.target.axis.auto='off';
    usrdata.edit.target.axis.manual='on';

    set(get(gcbf,'UserData'),'UserData',usrdata);

    %-----------------------------------
    % Close Define-Axis Window
    %-----------------------------------

  elseif flag==-14

    usrdata=get(get(gcbf,'UserData'),'UserData');
    delete(usrdata.figures.axis);
    usrdata.figures.axis=-1;
    set(usrdata.target.figure,'UserData',usrdata);

  end;
end;
