function xpcsctriggerwin(flag, flag1)

% XPCSCTRIGGERWIN - XPCSCOPE Helper Function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/11 14:18:40 $

bgcolor = get(0, 'DefaultUIControlBackgroundColor');

if flag==0

  if flag1==0
    usrdata=get(gcbf,'UserData');
  else
    usrdata=get(flag1,'UserData');
  end

  usrdata.edit.subfigures.trigger = ...
      figure('Units','points', ...
             'Color', bgcolor, ...
             'Position',usrdata.edit.subfigure.trigger.position, ...
             'CloseRequestFcn', 'xpcsctriggerwin(-5);', ...
             'Color', bgcolor, ...
             'MenuBar', 'none', ....
             'Number', 'off', ...
             'HandleVisibility','off',...
             'IntegerHandle', 'off', ...
             'Name', ['xPC Target: Trigger for Scope ', num2str(usrdata.edit.scopenumber)], ...
             'Tag','Fig1');
  setxpcfont(usrdata.edit.subfigures.trigger,8,9);
  set(usrdata.edit.subfigures.trigger,'Userdata',usrdata.figures.scope);

  %------------------------------------------
  % Trigger Frame
  %------------------------------------------

  usrdata.subfigure.trigger.frm_trigger = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'Position',[.01 .7 .98 .27], ...
                'Style','frame', ...
                'Tag','Frame1');

  usrdata.subfigure.trigger.ftl_trigger = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','center', ...
                'Position',[0.05 .94 .18 .05], ...
                'String','TRIGGER', ...
                'Style','text', ...
                'Tag','StaticText1');

  usrdata.subfigure.trigger.txt_triggermode = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','left', ...
                'Position',[0.02 0.88 .1 0.05], ...
                'String','Mode:', ...
                'Style','text', ...
                'Tag','StaticText1');


  usrdata.subfigure.trigger.pop_triggermode = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'Position',[.13 .885 .3 .05], ...
                'BackgroundColor',[1 1 1], ...
                'String','FreeRun|Software|Signal|Scope', ...
                'Style','popupmenu', ...
                'CallBack', 'xpcsctriggerwin(-1,1)', ...
                'Tag','PopupMenu1', ...
                'Value', usrdata.edit.trigger.mode);

  usrdata.subfigure.trigger.txt_triggersignal1 = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','left', ...
                'Position',[0.02 0.8 0.1 0.05], ...
                'String', 'Signal:', ...
                'Style','text', ...
                'Tag','StaticText1');

  usrdata.subfigure.trigger.txt_triggersignal2 = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','left', ...
                'Position',[0.13 0.8 0.85 0.05], ...
                'String', '', ...
                'Style','text', ...
                'Tag','StaticText1');

  usrdata.subfigure.trigger.txt_triggerlevel = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','left', ...
                'Position',[0.02 0.72 0.1 0.05], ...
                'String','Level:', ...
                'Style','text', ...
                'Tag','StaticText1');

  usrdata.subfigure.trigger.ed_triggerlevel = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'BackgroundColor',[1 1 1], ...
                'Position',[.13 .725 .2 .06], ...
                'HorizontalAlignment','right', ...
                'CallBack', 'xpcsctriggerwin(-3)', ...
                'Style','edit', ...
                'String', num2str(usrdata.edit.trigger.level), ...
                'Tag','EditText1');

  usrdata.subfigure.trigger.txt_triggerslope = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','left', ...
                'Position',[0.5 0.88 0.1 0.05], ...
                'String','Slope:', ...
                'Style','text', ...
                'Tag','StaticText1');

  usrdata.subfigure.trigger.pop_triggerslope = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'Position',[.61 0.885 .3 .05], ...
                'BackgroundColor',[1 1 1], ...
                'String','EITHER|RISING|FALLING', ...
                'Style','popupmenu', ...
                'CallBack', 'xpcsctriggerwin(-2)', ...
                'Tag','PopupMenu2', ...
                'Value',usrdata.edit.trigger.slope);

  usrdata.subfigure.trigger.frm_signallist = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'Position',[.01 .01 .98 .64], ...
                'Style','frame', ...
                'Tag','Frame1');

  usrdata.subfigure.trigger.ftl_signallist = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'HorizontalAlignment','center', ...
                'Position',[0.05 0.63 0.22 0.04], ...
                'String','SIGNAL LIST', ...
                'Style','text', ...
                'Tag','StaticText1');

  usrdata.subfigure.trigger.lb_signallist = ...
      uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                'Units','normalized', ...
                'BackgroundColor',[1 1 1], ...
                'Position',[.03 .03 .94 .6], ...
                'String','', ...
                'Style','listbox', ...
                'Tag','Listbox1', ...
                'CallBack', 'xpcsctriggerwin(-4)', ...
                'Value',1);

  if usrdata.edit.trigger.mode == 1
    set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
    set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
    set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
    set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off');
  end

  if ~isempty(usrdata.edit.api.triggersignal)
    txt_add_signal=usrdata.edit.trigger.signal;
    txt_add_signal(find(txt_add_signal=='.'))='/';
    set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
  end

  txt_list_signals=usrdata.edit.signals2trace;
  for i=1:length(usrdata.edit.signals2trace)
    name=usrdata.edit.signals2trace{i};
    index=find(name=='.');
    name(index)='/';
    txt_list_signals{i}=name;
  end
  set(usrdata.subfigure.trigger.lb_signallist, 'String',txt_list_signals);

  set(usrdata.figures.scope, 'userdata', usrdata);

  if flag1==0
    xpcsctriggerwin(-1,0);
    %elseif flag~=-1
    %   xpcsctriggerwin(-1,usrdata.figures.scope);
  end

else

  if flag~=-5 & flag~=-1
    usrdata=get(get(gcbf,'UserData'),'Userdata');
  end

  %-----------------------------------
  % popup Trigger Mode
  %-----------------------------------

  if flag==-1

    if flag1==0
      usrdata=get(gcbf,'UserData');
    elseif flag1==1
      usrdata=get(get(gcbf,'Userdata'),'UserData');
      %else
      %   usrdata=get(flag1,'UserData');
    end
    usrdata.edit.trigger.mode=get(usrdata.subfigure.trigger.pop_triggermode, 'Value');

    %delete old color
    if ~isempty(usrdata.edit.api.triggersignal) & xpcgate('getsctriggermode',usrdata.edit.scopenumber)==3
      usrdata.edit.color.used(usrdata.edit.api.triggersignal{1,3})=0;
    end

    mode=get(usrdata.figure.scope.pb_softtrig, 'Enable');
    if strcmp(mode,'on')
      xpcgate('softtrig',usrdata.edit.scopenumber);
    end

    if usrdata.edit.trigger.mode==1
      set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
      set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
      set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
      set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
      set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String', '', 'Value', 1);

      if ~isempty(usrdata.edit.api.signals2trace) & ~isempty(usrdata.edit.api.triggersignal)
        signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
        delcolor=usrdata.edit.api.signals2trace{1,3};
        usrdata.edit.color.used(delcolor(signalnum))=1;
      end
      usrdata=setcolorframe(usrdata);

      usrdata.edit.api.triggersignal={};
      usrdata.edit.trigger.signal='FreeRun';
      set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
      set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
      set(usrdata.figure.scope.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
      usrdata=setcolorframe(usrdata);

      usrdata=add_queue(usrdata,'xpcgate(''setsctriggermode'',usrdata.edit.scopenumber,0)');
      usrdata=exec_queue(usrdata);
    end

    if usrdata.edit.trigger.mode==2
      set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
      set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
      set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
      set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String', '', 'Value', 1);

      if ~isempty(usrdata.edit.api.signals2trace) & ~isempty(usrdata.edit.api.triggersignal)
        signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
        delcolor=usrdata.edit.api.signals2trace{1,3};
        usrdata.edit.color.used(delcolor(signalnum))=1;
      end
      usrdata=setcolorframe(usrdata);

      usrdata.edit.api.triggersignal={};
      usrdata.edit.trigger.signal='Software';
      set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
      set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
      set(usrdata.figure.scope.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
      usrdata=setcolorframe(usrdata);

      usrdata=add_queue(usrdata,'xpcgate(''setsctriggermode'',usrdata.edit.scopenumber,1)');
      usrdata=exec_queue(usrdata);
    end

    if usrdata.edit.trigger.mode == 3
      if ~isempty(usrdata.edit.signals2trace)
        if xpcgate('getsctriggermode',usrdata.edit.scopenumber)~=2
          set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
          set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'on');
          set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'on');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
          set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
          set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);

          txt_add_signal=usrdata.edit.signals2trace{1};

          usrdata.edit.trigger.signal=txt_add_signal;

          usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.S.model',txt_add_signal]);

          if ~isempty(usrdata.edit.api.signals2trace)
            signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
            delcolor=usrdata.edit.api.signals2trace{1,3};
            usrdata.edit.color.used(delcolor(signalnum))=0;
          end

          usrdata=add_queue(usrdata,'xpcgate(''setsctriggermode'',usrdata.edit.scopenumber,2)');
          usrdata=add_queue(usrdata,'xpcgate(''setsctriggersignal'',usrdata.edit.scopenumber,usrdata.edit.api.triggersignal{1,1})');
          usrdata=exec_queue(usrdata);

          [usrdata,newcolor,newcolornum]=getcolor(usrdata);

          usrdata.edit.api.triggersignal{1,2}=newcolor;
          usrdata.edit.api.triggersignal{1,3}=newcolornum;

          usrdata=setcolorframe(usrdata);

          txt_list_signals=usrdata.edit.signals2trace;
          for i=1:length(usrdata.edit.signals2trace)
            name=usrdata.edit.signals2trace{i};
            index=find(name=='.');
            name(index)='/';
            txt_list_signals{i}=name;
          end
          set(usrdata.subfigure.trigger.lb_signallist, 'String',txt_list_signals);
          txt_add_signal(find(txt_add_signal=='.'))='/';
          set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
          set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
          set(usrdata.figure.scope.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
        else
          set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
          set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'on');
          set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'on');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
          set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
          set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);
        end
      else
        set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
        set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
        set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
        set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
        set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
        set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String','', 'Value', 1);
        set(usrdata.subfigure.trigger.pop_triggermode, 'Value',1);
        usrdata.edit.trigger.mode=1;
        usrdata.edit.api.triggersignal={};
        usrdata.edit.trigger.signal='FreeRun';
        set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
        set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
        set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
        set(usrdata.figure.scope.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
        usrdata=add_queue(usrdata,'xpcgate(''setsctriggermode'',usrdata.edit.scopenumber,0)');
        usrdata=exec_queue(usrdata);
      end
    end

    if usrdata.edit.trigger.mode==4
      usrdata=refresh_scope(usrdata);
      if ~isempty(usrdata.T.scopelist)
        if xpcgate('getsctriggermode',usrdata.edit.scopenumber)~=3
          set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
          set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
          set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
          set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SCOPE LIST');
          set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);

          txt_add_scopes=usrdata.T.scopelist;

          txt_add_scope=['.' txt_add_scopes{1}];

          %txt_add_scope=[usrdata.S.modelpath,'.',txt_add_scope];
          usrdata.edit.trigger.signal=txt_add_scope;

          usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.T.scope',txt_add_scope]);

          usrdata=add_queue(usrdata,'xpcgate(''setsctriggermode'',usrdata.edit.scopenumber,3)');
          usrdata=add_queue(usrdata,'xpcgate(''setsctriggerscope'',usrdata.edit.scopenumber,usrdata.edit.api.triggersignal{1,1})');
          usrdata=exec_queue(usrdata);

          [usrdata,newcolor,newcolornum]=getcolor(usrdata);

          usrdata.edit.api.triggersignal{1,2}=newcolor;
          usrdata.edit.api.triggersignal{1,3}=newcolornum;

          txt_add_scope(find(txt_add_scope=='.'))='/';
          set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Scope:');
          set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Scope:');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_scope,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
          set(usrdata.figure.scope.txt_triggersignal2, 'String', txt_add_scope,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
        else
          set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
          set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
          set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
          set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SCOPE LIST');
          set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);
        end
      else
        set(usrdata.figure.scope.pb_softtrig, 'Enable','off');
        set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
        set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
        set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
        set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
        set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String','', 'Value', 1);
        set(usrdata.subfigure.trigger.pop_triggermode, 'Value',1);
        usrdata.edit.trigger.mode=1;
        usrdata.edit.api.triggersignal={};
        usrdata.edit.trigger.signal='FreeRun';
        set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
        set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
        set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
        set(usrdata.figure.scope.txt_triggersignal2, 'String', usrdata.edit.trigger.signal,'ForegroundColor',[0 0 0]);
        usrdata=add_queue(usrdata,'xpcgate(''setsctriggermode'',usrdata.edit.scopenumber,0)');
        usrdata=add_queue(usrdata,'xpcgate(''setsctriggerscope'',usrdata.edit.scopenumber,usrdata.edit.scopenumber)');
        usrdata=exec_queue(usrdata);
      end
    end
    set(usrdata.figures.scope, 'userdata', usrdata);

    %-----------------------------------
    % popup Trigger Slope
    %-----------------------------------

  elseif flag == -2

    usrdata.edit.trigger.slope=get(usrdata.subfigure.trigger.pop_triggerslope, 'Value');
    usrdata=add_queue(usrdata,'xpcgate(''setsctriggerslope'',usrdata.edit.scopenumber,usrdata.edit.trigger.slope-1)');
    usrdata=exec_queue(usrdata);
    set(get(gcbf,'UserData'), 'userdata', usrdata);

    %-----------------------------------
    % Trigger Level
    %-----------------------------------

  elseif flag == -3

    if isempty(str2num(get(usrdata.subfigure.trigger.ed_triggerlevel, 'String')))
      errordlg('Trigger Level must be a number');
      set(usrdata.subfigure.trigger.ed_triggerlevel,'String', num2str(usrdata.edit.trigger.level));
    else
      state=get(usrdata.figure.scope.pb_start,'String');
      if strcmp(state,'Start')
        level=str2num(get(usrdata.subfigure.trigger.ed_triggerlevel, 'String'));
        usrdata.edit.trigger.level=level;
        set(get(gcbf,'UserData'),'UserData',usrdata);
        xpcgate('setsctriggerlevel',usrdata.edit.scopenumber,usrdata.edit.trigger.level);
      end
    end

    %-----------------------------------
    % Trigger Signal
    %-----------------------------------

  elseif flag == -4

    usrdata=get(usrdata.figures.scope, 'UserData');

    if usrdata.edit.trigger.mode==3

      txt_add_signals=usrdata.edit.signals2trace;
      num_add_signal=get(usrdata.subfigure.trigger.lb_signallist, 'Value');

      txt_add_signal=txt_add_signals{num_add_signal};

      usrdata.edit.trigger.signal=txt_add_signal;

      usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.S.model',txt_add_signal]);
      usrdata=add_queue(usrdata,'xpcgate(''setsctriggersignal'',usrdata.edit.scopenumber,usrdata.edit.api.triggersignal{1,1})');
      usrdata=exec_queue(usrdata);

      if ~isempty(usrdata.edit.api.signals2trace)
        signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
        delcolor=usrdata.edit.api.signals2trace{1,3};
        usrdata.edit.color.used(delcolor(signalnum))=0;
      end

      [usrdata,newcolor,newcolornum]=getcolor(usrdata);

      usrdata.edit.api.triggersignal{1,2}=newcolor;
      usrdata.edit.api.triggersignal{1,3}=newcolornum;

      usrdata=setcolorframe(usrdata);

      txt_add_signal(find(txt_add_signal=='.'))='/';
      set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
      set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
      set(usrdata.figure.scope.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
    end

    if usrdata.edit.trigger.mode==4

      txt_add_scopes=usrdata.T.scopelist;
      num_add_scope=get(usrdata.subfigure.trigger.lb_signallist, 'Value');

      if ~isempty(usrdata.T.scopelist)
        txt_add_scope=txt_add_scopes{num_add_scope};
      else
        return
      end

      txt_add_scope=[usrdata.S.modelpath,'.',txt_add_scope];
      usrdata.edit.trigger.signal=txt_add_scope;

      usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.T.scope',txt_add_scope]);

      %delete old color
      if ~isempty(usrdata.edit.api.triggersignal) & xpcgate('getsctriggermode',usrdata.edit.scopenumber)==3
        usrdata.edit.color.used(usrdata.edit.api.triggersignal{1,3})=0;
      end

      usrdata=add_queue(usrdata,'xpcgate(''setsctriggerscope'',usrdata.edit.scopenumber,usrdata.edit.api.triggersignal{1,1})');
      usrdata=exec_queue(usrdata);

      [usrdata,newcolor,newcolornum]=getcolor(usrdata);

      usrdata.edit.api.triggersignal{1,2}=newcolor;
      usrdata.edit.api.triggersignal{1,3}=newcolornum;

      txt_add_scope(find(txt_add_scope=='.'))='/';
      set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Scope:');
      set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Scope:');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_scope,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
      set(usrdata.figure.scope.txt_triggersignal2, 'String', txt_add_scope,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
    end

    set(get(gcbf,'UserData'), 'userdata', usrdata);

    %----------------------------------------
    % close figure
    %----------------------------------------

  elseif flag == -5

    usrdata=get(get(gcbo,'UserData'),'Userdata');
    delete(usrdata.edit.subfigures.trigger);
    usrdata.edit.subfigures.trigger=-1;
    set(usrdata.figures.scope, 'userdata', usrdata);

  end

end

function usrdata=callback_listbox(usrdata)

value=get(usrdata.subfigure.trigger.lb_signallist,'Value');
if ~isempty(usrdata.S.modelpath)
  value=value-1;
end

if value==0 % .. pressed -> go up one step
  index=find(usrdata.S.modelpath=='.');
  usrdata.S.modelpath=usrdata.S.modelpath(1:index(end)-1);
  usrdata=refresh_trigger(usrdata);
else
  if usrdata.S.submodels(value)
    usrdata.S.modelpath=[usrdata.S.modelpath,'.',usrdata.S.fnames{value}];
    set(usrdata.subfigure.trigger.lb_signallist,'Value',1);
    usrdata=refresh_trigger(usrdata);
  end

end
