function xpcscope(flag,flag1)
% XPCSCOPE - xPC Target Host Scope GUI
%    XPCSETUP opens the xPC Target Host Scope window which allows you
%    to define scopes of type host, to choose signals and control the
%    acquisition process.
%
%    See also XPCTGSCOPE

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.21.6.1 $ $Date: 2004/04/22 01:36:35 $


h_main = withhiddenhandles('get', 0, 'Children');
opened = strmatch('xPC Target: Host Manager', get(h_main, 'Name'));

maxscopes=10;
modelname=xpcgate('getname');

if ~isempty(opened)
  scopemanager=get(h_main(opened), 'UserData');
else
  scopemanager.dispmsg=0;
end;

if scopemanager.dispmsg==0;
  if isempty(findstr(modelname,'Time Out'))
    if strcmp(modelname,'loader')
      stopxpctimer(3);
      errordlg('No Model on Target');
      if ~isempty(opened)
        set(0,'ShowHiddenHandles','on');
        scopemanager.dispmsg=1;
        set(scopemanager.figure, 'UserData', scopemanager);
        %delete scope windows
        h_main=get(0, 'Children');
        opened=strmatch('xPC Target: Scope', get(h_main, 'Name'));
        for i=1:length(opened)
          delete(h_main(opened(i)));
        end;

        %delete Add/Remove windows
        h_main=get(0, 'Children');
        opened=strmatch('xPC Target: Add/Remove Signals for Scope', get(h_main, 'Name'));
        for i=1:length(opened)
          delete(h_main(opened(i)));
        end;

        %delete trigger windows
        h_main=get(0, 'Children');
        opened=strmatch('xPC Target: Trigger for Scope', get(h_main, 'Name'));
        for i=1:length(opened)
          delete(h_main(opened(i)));
        end;

        %delete y-scaling window
        h_main=get(0, 'Children');
        opened=strmatch('Define Y-Axis Scaling', get(h_main, 'Name'));
        if ~isempty(opened)
          delete(h_main(opened));
        end;

        delete(scopemanager.figure);
        set(0,'ShowHiddenHandles','off');
        %scopemanager=get(scopemanager.figure, 'UserData');
        %scopemanager.dispmsg=0;
        %set(scopemanager.figure, 'UserData', scopemanager);
      end;
      return;
    end;
  else
    stopxpctimer(3);
    errordlg(modelname);
    if ~isempty(opened)
      set(0,'ShowHiddenHandles','on');
      scopemanager.dispmsg=1;
      set(scopemanager.figure, 'UserData', scopemanager);
      %delete scope windows
      h_main=get(0, 'Children');
      opened=strmatch('xPC Target: Scope', get(h_main, 'Name'));
      for i=1:length(opened)
        delete(h_main(opened(i)));
      end;

      %delete Add/Remove windows
      h_main=get(0, 'Children');
      opened=strmatch('xPC Target: Add/Remove Signals for Scope', get(h_main, 'Name'));
      for i=1:length(opened)
        delete(h_main(opened(i)));
      end;

      %delete trigger windows
      h_main=get(0, 'Children');
      opened=strmatch('xPC Target: Trigger for Scope', get(h_main, 'Name'));
      for i=1:length(opened)
        delete(h_main(opened(i)));
      end;

      %delete y-scaling window
      h_main=get(0, 'Children');
      opened=strmatch('Define Y-Axis Scaling', get(h_main, 'Name'));
      if ~isempty(opened)
        delete(h_main(opened));
      end;

      delete(scopemanager.figure);
      set(0,'ShowHiddenHandles','off');
      %scopemanager=get(scopemanager.figure, 'UserData');
      %scopemanager.dispmsg=0;
      %set(scopemanager.figure, 'UserData', scopemanager);
    end;
    return;
  end;
end;
scrsize=get(0,'ScreenSize');
position=[(scrsize(3)-50)*0.82,(scrsize(4)-50)*0.1,150,30+30];

if isempty(opened) & nargin == 0

  if ~exist([modelname,'bio.m'])
    errordlg('Current Directory is not Project Directory');
    return;
  end;
  scopemanager.handles.scopestart=[];
  for a=1:30
    scopemanager.scopes(a)=-1;
  end;
  scopemanager.numofpb=0;
  scopemanager.pb_scope=[];

  scopemanager.figure = ...
      figure('Color',[0.8 0.8 0.8], ...
             'MenuBar','none', ...
             'Name','xPC Target: Host Manager', ...
             'NumberTitle','off', ...
             'CloseRequestFcn', 'xpcscope(-5,0)', ...
             'IntegerHandle', 'off', ...
             'HandleVis','off',...
             'Position',position, ...
             'Tag','xPCTargetHostScopeManager');

  setxpcfont(scopemanager.figure,8,9);

  scopemanager.menu.file = ...
      uimenu('Parent',scopemanager.figure, ...
             'Label','File', ...
             'Tag','uimenu1');

  scopemanager.menu.new_scope = ...
      uimenu('Parent',scopemanager.menu.file, ...
             'Label','New Scope', ...
             'CallBack', 'xpcscope(-1)', ...
             'Tag','Subuimenu1');

  scopemanager.menu.load_scope = ...
      uimenu('Parent',scopemanager.menu.file, ...
             'Label','Load Scope', ...
             'Separator','on', ...
             'CallBack', 'xpcscope(-2)', ...
             'Tag','Subuimenu1');

  scopemanager.menu.save_scope = ...
      uimenu('Parent',scopemanager.menu.file, ...
             'Label','Save Scope', ...
             'CallBack', 'xpcscope(-3)', ...
             'Tag','Subuimenu1');

  scopemanager.menu.close_all_scope = ...
      uimenu('Parent',scopemanager.menu.file, ...
             'Label','Close all Scopes', ...
             'Separator','on', ...
             'CallBack', 'xpcscope(-4,0)', ...
             'Enable', 'off', ...
             'Tag','Subuimenu1');

  scopemanager.menu.close_scopemanager = ...
      uimenu('Parent',scopemanager.menu.file, ...
             'Label','Close Scope Manager', ...
             'Separator','on', ...
             'CallBack', 'xpcscope(-5,0)', ...
             'Tag','Subuimenu1');

  set(scopemanager.figure, 'UserData', scopemanager);
  setappdata(scopemanager.figure, 'RefreshFunction', @refreshScopeGUI);
  xpcscope(-12);

else

  scopemanager=get(h_main(opened), 'UserData');
  position=get(h_main(opened),'Position');

  if nargin==0

    figure(h_main(opened));

    %----------------------------------
    % Menu: File->New Scope
    %----------------------------------

  elseif flag==-1

    if ~exist([modelname,'bio.m'])
      errordlg('Current Directory is not Project Directory');
      return;
    end;

    [nop, numofscopes]=size(scopemanager.scopes);

    allscopes=xpcgate('getscopes');
    numxpcschost=0;
    for ii=1:length(allscopes)
        if (xpcgate('getsctype',allscopes(ii)) == 1)
             numxpcschost=numxpcschost+1;
        end           
    end
   
    if numxpcschost>maxscopes
      errordlg('Scope structure full');
      return;
    end;

    %delete old pushbuttons
    for i=1:numofscopes
      if scopemanager.scopes(i) ~= -1 & scopemanager.scopes(i) ~= 0
        delete(scopemanager.pb_scope(i));
      end;
    end;

    %create new scope
    xpcscope(-6);
    scopemanager=get(h_main(opened), 'UserData');

    [nop, numofscopes]=size(scopemanager.scopes);

    scopemanager.numofpb=scopemanager.numofpb+1;
    j=1;
    for i=1:numofscopes
      if scopemanager.scopes(i) ~= -1 & scopemanager.scopes(i) ~= 0
        scopemanager.pb_scope(i) = ...
            uicontrol('Parent',scopemanager.figure, ...
                      'Units','normalized', ...
                      'String', ['View Scope ', num2str(i)], ...
                      'Position', buttonPos(j, scopemanager.numofpb), ...
                      'CallBack', 'xpcscope(-7)', ...
                      'Tag','Pushbutton1');

        set(scopemanager.pb_scope(i),'UserData', i);
        j=j+1;
      end;
    end;

    for i=1:numofscopes
      if scopemanager.scopes(i)~=-1 & scopemanager.scopes(i) ~= 0
        usrdata=get(scopemanager.scopes(i), 'UserData');
        if usrdata.edit.subfigures.trigger~=-1 & usrdata.edit.trigger.mode==4
          usrdata=refresh_scope(usrdata);
          set(scopemanager.scopes(i),'UserData',usrdata);
        end;
      end;
    end;
    
   % set(scopemanager.figure, 'Position', [position(1),position(2),position(3),30+30*scopemanager.numofpb]);
    ydelta=30+30*scopemanager.numofpb;
    scdata=get(0,'Screensize');
    yscmax=scdata(4);
    scopedata=get(h_main(opened),'Position');
    scmngrypos=position(2)+ ydelta;
    if (scmngrypos > yscmax)
        set(h_main(opened),'Position',[position(1) yscmax-ydelta-40 position(3) ydelta]);
    end
    
    
    set(scopemanager.menu.close_all_scope, 'Enable', 'on');
    set(scopemanager.figure, 'UserData', scopemanager);

    %----------------------------------
    % load
    %----------------------------------

  elseif flag==-2

    xpcscope(-5,0);
    xpcscope;
    h_main = withhiddenhandles('get', 0, 'Children');
    opened = strmatch('xPC Target: Host Manager', get(h_main, 'Name'));
    scopemanager=get(h_main(opened), 'UserData');

    [filename, path] = uigetfile('*.mat', 'Load Scope Windows');

    if filename ~= 0
      load([path, filename]);
    else
      return;
    end;

    for i=1:length(data)

      usrdata.edit=data{i};

      if ~exist([modelname,'bio.m'])
        errordlg('Current Directory is not Project Directory');
        return;
      end;

      [nop, numofscopes]=size(scopemanager.scopes);

      %delete old pushbuttons
      for m=1:numofscopes
        if scopemanager.scopes(m) ~= -1 & scopemanager.scopes(i) ~= 0
          delete(scopemanager.pb_scope(m));
        end;
      end;

      %create new scope
      if ~isempty(xpcgate('getscopes'))
        if isempty(find(usrdata.edit.scopenumber==xpcgate('getscopes')))
          xpcgate('defscope','host',usrdata.edit.scopenumber);
        end;
        if isempty(find(usrdata.edit.state.triggerscope==xpcgate('getscopes')))
          xpcgate('defscope','host',usrdata.edit.state.triggerscope);
        end;
      else
        xpcgate('defscope','host',usrdata.edit.scopenumber);
        if usrdata.edit.state.triggerscope~=usrdata.edit.scopenumber
          xpcgate('defscope','host',usrdata.edit.state.triggerscope);
        end;
      end;
      xpcscwin(0,usrdata.edit.scopenumber);

      scopemanager=get(h_main(opened), 'UserData');

      [nop, numofscopes]=size(scopemanager.scopes);

      scopemanager.numofpb=scopemanager.numofpb+1;
      j=1;
      for l=1:numofscopes
        if scopemanager.scopes(l) ~= -1 & scopemanager.scopes(i) ~= 0
          scopemanager.pb_scope(l) = ...
              uicontrol('Parent',scopemanager.figure, ...
                        'Units','normalized', ...
                        'String', ['View Scope ', num2str(l)], ...
                        'Position',buttonPos(j, scopemanager.numofpb), ...
                        'CallBack', 'xpcscope(-7)', ...
                        'Tag','Pushbutton1');

          set(scopemanager.pb_scope(l),'UserData', l);
          j=j+1;
        end;
      end;

      set(scopemanager.figure, 'Position', [position(1),position(2),position(3),30+30*scopemanager.numofpb]);
      set(scopemanager.menu.close_all_scope, 'Enable', 'on');
      set(scopemanager.figure, 'UserData', scopemanager);

      usrdata=get(scopemanager.scopes(usrdata.edit.scopenumber), 'UserData');
      usrdata.edit=data{i};
      scopemanager=get(h_main(opened), 'UserData');

      xpcgate('setscope',usrdata.edit.state);

      %New position ScopeWindow
      usrdata.edit.figure.scope.position(1)=usrdata.edit.figure.scope.position(1)/(usrdata.edit.scrsize(3)-usrdata.edit.figure.scope.position(3))*(scrsize(3)-usrdata.edit.figure.scope.position(3));
      usrdata.edit.figure.scope.position(2)=usrdata.edit.figure.scope.position(2)/(usrdata.edit.scrsize(4)-usrdata.edit.figure.scope.position(4))*(scrsize(4)-usrdata.edit.figure.scope.position(4));
      %New position TriggerWindow
      usrdata.edit.subfigure.trigger.position(1)=usrdata.edit.subfigure.trigger.position(1)/(usrdata.edit.scrsize(3)-usrdata.edit.subfigure.trigger.position(3))*(scrsize(3)-usrdata.edit.subfigure.trigger.position(3));
      usrdata.edit.subfigure.trigger.position(2)=usrdata.edit.subfigure.trigger.position(2)/(usrdata.edit.scrsize(4)-usrdata.edit.subfigure.trigger.position(4))*(scrsize(4)-usrdata.edit.subfigure.trigger.position(4));
      %New position SignalWindow
      usrdata.edit.subfigure.signals.position(1)=usrdata.edit.subfigure.signals.position(1)/(usrdata.edit.scrsize(3)-usrdata.edit.subfigure.signals.position(3))*(scrsize(3)-usrdata.edit.subfigure.signals.position(3));
      usrdata.edit.subfigure.signals.position(2)=usrdata.edit.subfigure.signals.position(2)/(usrdata.edit.scrsize(4)-usrdata.edit.subfigure.signals.position(4))*(scrsize(4)-usrdata.edit.subfigure.signals.position(4));

      set(scopemanager.scopes(usrdata.edit.scopenumber), 'UserData',usrdata);
      set(usrdata.figures.scope, 'Position', usrdata.edit.figure.scope.position);
      if strcmp(usrdata.edit.scope.axis.auto,'off')
        set(usrdata.figure.scope.plot,'YLimMode','manual');
        set(usrdata.figure.scope.plot,'YLim',[usrdata.edit.scope.yaxis.min,usrdata.edit.scope.yaxis.max]);
        set(usrdata.figure.scope.menu_axis_auto,'Checked','off');
        set(usrdata.figure.scope.menu_axis_manual,'Checked','on');
      else
        set(usrdata.figure.scope.plot,'YLimMode','auto');
        set(usrdata.figure.scope.menu_axis_auto,'Checked','on');
        set(usrdata.figure.scope.menu_axis_manual,'Checked','off');
      end;

      if strcmp(usrdata.edit.scope.viewmode.graphical,'on')
        set(usrdata.figure.scope.menu_viewmode_graphical,'Checked','on');
        set(usrdata.figure.scope.menu_viewmode_numerical,'Checked','off');
      else
        set(usrdata.figure.scope.menu_y_axis,'Enable','off');
        set(usrdata.figure.scope.menu_grid,'Enable','off');
        set(usrdata.figure.scope.menu_grid,'Checked','off');
        set(usrdata.figure.scope.plot,'XGrid','off','YGrid','off');
        usrdata.edit.scope.grid='off';
        set(usrdata.figure.scope.menu_viewmode_graphical,'Checked','off');
        set(usrdata.figure.scope.menu_viewmode_numerical,'Checked','on');
        usrdata.edit.scope.viewmode.graphical='off';
        usrdata.edit.scope.viewmode.numerical='on';
        set(usrdata.figure.scope.menu_viewmode_graphical,'Checked','off');
        set(usrdata.figure.scope.menu_viewmode_numerical,'Checked','on');
      end;

      set(usrdata.figure.scope.plot, 'XGrid', usrdata.edit.scope.grid,'YGrid', usrdata.edit.scope.grid);
      set(usrdata.figure.scope.menu_grid, 'Checked', usrdata.edit.scope.grid);
      set(usrdata.figure.scope.ed_samples, 'String', convsample(usrdata.edit.mode.prepostsamples,usrdata.edit.mode.samples));
      set(usrdata.figure.scope.ed_interleave, 'String', num2str(usrdata.edit.mode.interleave));
      txt_add_signal=usrdata.edit.trigger.signal;
      txt_add_signal(find(txt_add_signal=='.'))='/';
      set(usrdata.figure.scope.txt_triggersignal2,'String',txt_add_signal);
      usrdata=setcolorframe(usrdata);

      if usrdata.edit.subfigures.signals~=-1
        figure(usrdata.figures.scope);
        xpcscsignalwin(scopemanager.scopes(usrdata.edit.scopenumber));
        usrdata=get(scopemanager.scopes(usrdata.edit.scopenumber), 'UserData');
        set(usrdata.edit.subfigures.signals, 'Position', usrdata.edit.subfigure.signals.position);
      end;

      if usrdata.edit.subfigures.trigger~=-1
        figure(usrdata.figures.scope);
        xpcsctriggerwin(0,scopemanager.scopes(usrdata.edit.scopenumber));
        usrdata=get(scopemanager.scopes(usrdata.edit.scopenumber), 'UserData');

        %delete old color
        if ~isempty(usrdata.edit.api.triggersignal) & xpcgate('getsctriggermode',usrdata.edit.scopenumber)==3
          usrdata.edit.color.used(usrdata.edit.api.triggersignal{1,3})=0;
        end;

        if usrdata.edit.trigger.mode==1
          set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
          set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
          set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String', '');

          if ~isempty(usrdata.edit.api.signals2trace) & ~isempty(usrdata.edit.api.triggersignal)
            signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
            delcolor=usrdata.edit.api.signals2trace{1,3};
            usrdata.edit.color.used(delcolor(signalnum))=1;
          end;
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
        end;

        if usrdata.edit.trigger.mode==2
          set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
          set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
          set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String', '');

          if ~isempty(usrdata.edit.api.signals2trace) & ~isempty(usrdata.edit.api.triggersignal)
            signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
            delcolor=usrdata.edit.api.signals2trace{1,3};
            usrdata.edit.color.used(delcolor(signalnum))=1;
          end;
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
        end;

        if usrdata.edit.trigger.mode==3

          txt_add_signal=usrdata.edit.trigger.signal;
          usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.S.model',usrdata.edit.trigger.signal]);
          usrdata=add_queue(usrdata,'xpcgate(''setsctriggersignal'',usrdata.edit.scopenumber,usrdata.edit.api.triggersignal{1,1})');
          usrdata=exec_queue(usrdata);

          if ~isempty(usrdata.edit.api.signals2trace)
            signalnum=find(usrdata.edit.api.triggersignal{1,1}==usrdata.edit.api.signals2trace{1,1});
            delcolor=usrdata.edit.api.signals2trace{1,3};
            usrdata.edit.color.used(delcolor(signalnum))=0;
          end;

          [usrdata,newcolor,newcolornum]=getcolor(usrdata);

          usrdata.edit.api.triggersignal{1,2}=newcolor;
          usrdata.edit.api.triggersignal{1,3}=newcolornum;

          usrdata=setcolorframe(usrdata);

          txt_add_signal(find(txt_add_signal=='.'))='/';
          set(usrdata.figure.scope.txt_triggersignal1, 'String', 'Trigger Signal:');
          set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
          set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
          set(usrdata.figure.scope.txt_triggersignal2, 'String', txt_add_signal,'ForegroundColor',usrdata.edit.api.triggersignal{1,2});
        end;

        if usrdata.edit.trigger.mode==4
          usrdata=refresh_scope(usrdata);
          txt_add_scope=usrdata.edit.trigger.signal;

          usrdata.edit.api.triggersignal{1,1}=usrdata.edit.state.triggerscope;%eval(['usrdata.T.scope',txt_add_scope]);

          %delete old color
          if ~isempty(usrdata.edit.api.triggersignal) & xpcgate('getsctriggermode',usrdata.edit.scopenumber)==3
            usrdata.edit.color.used(usrdata.edit.api.triggersignal{1,3})=0;
          end;

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
        end;

        set(usrdata.edit.subfigures.trigger, 'Position', usrdata.edit.subfigure.trigger.position);
      end;
      usrdata=setcolorframe(usrdata);

      set(h_main(opened), 'UserData', scopemanager);
      set(scopemanager.scopes(usrdata.edit.scopenumber), 'UserData', usrdata);

    end;

    %----------------------------------
    % save
    %----------------------------------

  elseif flag==-3

    [filename, path] = uiputfile('*.mat', 'Save Scope Windows');

    j=1;
    if filename ~= 0
      for i=1:length(scopemanager.scopes)
        if scopemanager.scopes(i)~=-1 & scopemanager.scopes(i) ~= 0
          usrdata=get(scopemanager.scopes(i), 'UserData');
          usrdata.edit.figure.scope.position=get(usrdata.figures.scope, 'Position');
          if usrdata.edit.subfigures.signals~=-1
            usrdata.edit.subfigure.signals.position=get(usrdata.edit.subfigures.signals, 'Position');
          end;
          if usrdata.edit.subfigures.trigger~=-1
            usrdata.edit.subfigure.trigger.position=get(usrdata.edit.subfigures.trigger, 'Position');
          end;
          usrdata.edit.state=xpcgate('getscope',i);
          data{j}=usrdata.edit;
          j=j+1;
        end;
      end;
      save([path, filename], 'data');
    end;

    %----------------------------------
    % Close all Scopes
    %----------------------------------

  elseif flag==-4

    if ~isempty(scopemanager.scopes)
      if strcmp(get(scopemanager.menu.close_all_scope,'Enable'),'on')
        answer = questdlg('Save scopes before closing?', ...
                        'Save ?', ...
                        'Yes','No','Yes');

        switch answer,
         case 'Yes',
          xpcscope(-3);
        end % switch
      end;
    end;

    [nop, numofscopes]=size(scopemanager.scopes);

    for i=1:numofscopes
      if scopemanager.scopes(i) ~= -1 & scopemanager.scopes(i) ~= 0
        scopemanager=get(scopemanager.figure,'UserData');
        scopemanager.scopetodelete=scopemanager.scopes(i);
        set(scopemanager.figure,'UserData',scopemanager);
        if flag1==1
          xpcscwin(-3,2);
        else
          xpcscwin(-3,0);
        end;
      end;
    end;
    scopemanager.numofpb=0;
    scopemanager.scopes=[];
    scopemanager.handles.scopestart=[];
    stopxpctimer(3);
    scopemanager.scopes(1)=-1;
    set(scopemanager.figure, 'Position', [position(1),position(2),position(3),30+30]);
    set(scopemanager.menu.close_all_scope, 'Enable', 'off');
    set(scopemanager.figure, 'UserData', scopemanager);

    %----------------------------------
    % New Scope
    %----------------------------------

  elseif flag==-6

    %[nop, numofscopes]=size(scopemanager.scopes);

    %for i=1:numofscopes
    %if scopemanager.scopes(i)==-1
    %xpcscwin(0, i);
    %scopemanager=get(h_main(opened), 'UserData');
    %set(h_main(opened), 'UserData', scopemanager);
    %return;
    %end;
    %end;
    scopenumber=xpcgate('defscope');
    xpcscwin(0, scopenumber);
    scopemanager=get(h_main(opened), 'UserData');
    set(h_main(opened), 'UserData', scopemanager);

    %----------------------------------
    % View Scope
    %----------------------------------

  elseif flag==-7

    scopenum=get(gcbo, 'UserData');
    usrdata=get(scopemanager.scopes(scopenum), 'UserData');

    if usrdata.edit.subfigures.trigger~=-1, figure(usrdata.edit.subfigures.trigger); end;
    if usrdata.edit.subfigures.signals~=-1, figure(usrdata.edit.subfigures.signals); end;
    figure(usrdata.figures.scope);

    %----------------------------------
    % Close one Scope
    %----------------------------------

  elseif flag==-8

    usrdata=get(scopemanager.scopetodelete, 'UserData');

    [nop, numofscopes]=size(scopemanager.scopes);

    %delete old pushbuttons
    for i=1:numofscopes
      if scopemanager.scopes(i)~=-1 & scopemanager.scopes(i) ~= 0
        delete(scopemanager.pb_scope(i));
      end;
    end;

    scopemanager.numofpb=scopemanager.numofpb-1;
    if scopemanager.numofpb==0
      scopemanager.scopes(usrdata.edit.scopenumber)=[];
      scopemanager.scopes(1)=-1;
      [nop, numofscopes]=size(scopemanager.scopes);
    else
      scopemanager.scopes(usrdata.edit.scopenumber)=-1;
    end;

    j=1;
    for i=1:numofscopes
      if scopemanager.scopes(i) ~= -1 & scopemanager.scopes(i) ~= 0
        scopemanager.pb_scope(i) = ...
            uicontrol('Parent',scopemanager.figure, ...
                      'Units','normalized', ...
                      'String', ['View Scope ', num2str(i)], ...
                      'Position', buttonPos(j, scopemanager.numofpb), ...
                      'CallBack', 'xpcscope(-7)', ...
                      'Tag','Pushbutton1');

        set(scopemanager.pb_scope(i),'UserData', i);
        j=j+1;
      end;
    end;
    set(scopemanager.figure, 'Position', [position(1),position(2),position(3),30+30*scopemanager.numofpb]);
    if scopemanager.numofpb == 0
      set(scopemanager.menu.close_all_scope, 'Enable', 'off');
      scopemanager.scopes=[];
      set(scopemanager.figure, 'Position', position);
    else
      set(scopemanager.menu.close_all_scope, 'Enable', 'on');
    end;
    if length(scopemanager.handles.scopestart)==1
      scopemanager.handles.scopestart=[];
      stopxpctimer(3);
    else
      if ~isempty(scopemanager.handles.scopestart)
        findscope=find(scopemanager.handles.scopestart==usrdata.figures.scope);
        scopemanager.handles.scopestart(findscope)=[];
      end;
    end;

    set(scopemanager.figure, 'UserData', scopemanager);

    %----------------------------------
    % close manager
    %----------------------------------

  elseif flag==-5

    xpcscope(-4,flag1);
    scopemanager.handles.scopestart=[];
    stopxpctimer(3);
    delete(scopemanager.figure);

    %----------------------------------
    % push button Start Scope
    %----------------------------------

  elseif flag==-9
    if isempty(flag1), figH = gcbf; else figH = flag1; end
    usrdata=get(figH, 'UserData');
    if isempty(scopemanager.handles.scopestart)
      scopemanager.handles.scopestart(1)=usrdata.figures.scope;
    else
      if isempty(find(scopemanager.handles.scopestart==usrdata.figures.scope))
        scopemanager.handles.scopestart(length(scopemanager.handles.scopestart)+1)=usrdata.figures.scope;
      end;
    end;

    usrdata=exec_queue(usrdata);

    xpcgate('scstart',usrdata.edit.scopenumber);
    if usrdata.edit.trigger.mode==2
      xpcgate('softtrig',usrdata.edit.scopenumber);
    end;

    set(usrdata.scopemanager.figure, 'UserData', scopemanager);
    set(usrdata.figures.scope, 'UserData', usrdata);

    defxpctimer(3, 100, 'xpcscope');

    %----------------------------------
    % push button Stop Scope
    %----------------------------------

  elseif flag==-10
    if isempty(flag1), figH = gcbf; else figH = flag1; end

    usrdata=get(figH, 'UserData');

    xpcgate('scstop',usrdata.edit.scopenumber);

    if length(scopemanager.handles.scopestart)==1
      scopemanager.handles.scopestart=[];
      stopxpctimer(3);
    else
      if ~isempty(scopemanager.handles.scopestart)
        findscope=find(scopemanager.handles.scopestart==usrdata.figures.scope);
        scopemanager.handles.scopestart(findscope)=[];
      else
        stopxpctimer(3);
      end;
    end;

    set(scopemanager.figure, 'UserData', scopemanager);

    %----------------------------------
    % Timer callback
    %----------------------------------

  elseif flag==3
    %disp('timer on');
    %stopxpctimer(3);
    if isempty(scopemanager)
      return
    end
    refreshScopeGUI(scopemanager.figure);
    %defxpctimer(3,100,'xpcscope');

    %----------------------------------
    % update scopelist in TriggerWindow
    %----------------------------------

  elseif flag==-11

    for i=1:length(scopemanager.scopes)
      if scopemanager.scopes(i)~=-1 & scopemanager.scopes(i) ~= 0
        usrdata=get(scopemanager.scopes(i), 'UserData');
        if usrdata.edit.subfigures.trigger~=-1 & usrdata.edit.trigger.mode==4
          usrdata=refresh_scope(usrdata);
          set(scopemanager.scopes(i),'UserData',usrdata);
        end;
      end;
    end;

    %----------------------------------
    % Create Scopes who are on Target
    %----------------------------------

  elseif flag==-12
    scopesontarget=xpcgate('getscopes','host');
    for a=1:30
      scopemanager.scopes(a)=-1;
    end;
    if ~isempty(scopesontarget)
      for n=1:length(scopesontarget)
        if ~exist([modelname,'bio.m'])
          errordlg('Current Directory is not Project Directory');
          return;
        end;
        [nop, numofscopes]=size(scopemanager.scopes);

        %delete old pushbuttons
        for i=1:numofscopes
          if scopemanager.scopes(i) ~= -1 & scopemanager.scopes(i) ~= 0
            delete(scopemanager.pb_scope(i));
          end;
        end;

        %create new scope
        set(h_main(opened), 'UserData', scopemanager);
        xpcscwin(0,scopesontarget(n));
        scopemanager=get(h_main(opened), 'UserData');

        [nop, numofscopes]=size(scopemanager.scopes);

        scopemanager.numofpb=scopemanager.numofpb+1;
        j=1;
        for i=1:numofscopes
          if scopemanager.scopes(i) ~= -1 & scopemanager.scopes(i) ~= 0
            scopemanager.pb_scope(i) = ...
                uicontrol('Parent',scopemanager.figure, ...
                          'Units','normalized', ...
                          'String', ['View Scope ', num2str(i)], ...
                          'Position',buttonPos(j, scopemanager.numofpb), ...
                          'CallBack', 'xpcscope(-7)', ...
                          'Tag','Pushbutton1');

            set(scopemanager.pb_scope(i),'UserData', i);
            j=j+1;
          end;
        end;

        set(scopemanager.figure, 'Position', [position(1),position(2),position(3),30+30*scopemanager.numofpb]);
        set(scopemanager.menu.close_all_scope, 'Enable', 'on');
        set(scopemanager.figure, 'UserData', scopemanager);
      end;
    end;
  end;
end;

function refreshScopeGUI(h)
if checkForFeature &&  srcblksopen > 0
  return
end

scopemanager = get(h, 'UserData');

for i = 1 : length(scopemanager.handles.scopestart)
  usrdata = get(scopemanager.handles.scopestart(i), 'UserData');
  if ~isempty(usrdata.edit.api.signals2trace)
    trace = usrdata.edit.api.signals2trace{1,1};
    color = usrdata.edit.api.signals2trace{1,2};
  end;
  if xpcgate('getscstate',usrdata.edit.scopenumber) == 3 % finished
    usrdata          = exec_queue(usrdata,1);
    scnum            = usrdata.edit.scopenumber;
    samples          = xpcgate('getscnosamples',  scnum);
    interleave       = xpcgate('getscinterleave', scnum);
    usrdata.timeplot = xpcgate('getscstarttime',  scnum) + ...
                       (0:(samples-1)) * xpcgate('getts') * interleave;

    yexport          = zeros(samples,length(trace));
    texport          = (usrdata.timeplot)';
    for a = 1 : 15
      set(usrdata.figure.scope.txt_numerical(a), 'Visible', 'off');
      set(usrdata.line_plot(a), 'Visible', 'off');
    end
    for j = 1 : length(trace)
      y = xpcgate('getscdata', usrdata.edit.scopenumber, trace(j));
      yexport(:,j) = y;
      if (length(usrdata.timeplot) == length(y))
        for k = length(trace) : length(usrdata.line_plot)
          set(usrdata.line_plot(k), 'visible', 'off');
        end
        if (strcmp(usrdata.edit.scope.viewmode.graphical,'on'))
          set(usrdata.figure.scope.plot, 'XLim', ...
                            [usrdata.timeplot(1), usrdata.timeplot(end)]);
          set(usrdata.line_plot(j), 'XData',  usrdata.timeplot', ...
                                    'YData',  y',                ...
                                    'color',  color(j,:),        ...
                                    'visible','on');
        else
          set(usrdata.figure.scope.txt_numerical(j), ...
              'Position', [0.25 j*0.09 0], ...
              'Visible',  'on',            ...
              'String',   num2str(y(1)),   ...
              'Color',    color(j,:));
        end
      end
    end
    % special case for samples and interleave and triggerlevel
    samples = get(usrdata.figure.scope.ed_samples, 'String');
    [prepostsamples,samples] = convsample(samples);
    usrdata.edit.mode.samples        = samples;
    usrdata.edit.mode.prepostsamples = prepostsamples;
    xpcgate('setscnosamples',        usrdata.edit.scopenumber, ...
                                     usrdata.edit.mode.samples);
    xpcgate('setscnoprepostsamples', usrdata.edit.scopenumber, ...
                                     usrdata.edit.mode.prepostsamples);
    %
    interleave = str2num(get(usrdata.figure.scope.ed_interleave, 'String'));
    usrdata.edit.mode.interleave = interleave;
    xpcgate('setscinterleave', usrdata.edit.scopenumber, ...
                               usrdata.edit.mode.interleave);
    %
    if usrdata.edit.subfigures.trigger ~= -1
      level=str2num(get(usrdata.subfigure.trigger.ed_triggerlevel, 'String'));
    else
      level=[];
    end;
    if ~isempty(level)
      if usrdata.edit.trigger.level ~= level
        usrdata.edit.trigger.level = level;
        xpcgate('setsctriggerlevel', usrdata.edit.scopenumber, ...
                                     usrdata.edit.trigger.level);
      end
    end
    %
    xpcgate('scstart',usrdata.edit.scopenumber);
    if usrdata.export
      assignin('base', usrdata.edit.scope.dataplot, yexport);
      assignin('base', usrdata.edit.scope.timeplot, texport);
      usrdata.export = 0;
    end;
    set(usrdata.figures.scope, 'UserData', usrdata);
    %disp('xpcgate('scstart')');
  end;
  if xpcgate('getscstate',usrdata.edit.scopenumber) == 1 % ready
    if usrdata.edit.trigger.mode == 2
      set(usrdata.figure.scope.pb_softtrig, 'Enable', 'on');
      %xpcgate('softtrig',usrdata.edit.scopenumber);
      %disp('xpcgate('softtrig')');
    end
  end
end


function position = buttonPos(i, n)
% i: which pushButton
% n: total number of buttons
S = 0.01;                               % space_between_pushbuttons
position = [0.05, ...                           % x-coord
            0.05 + (i - 1) * (0.9 - S) / n, ... % y-coord
            0.9, ...                            % width
            (0.9 - ((n - 1) * S)) / n];         % height

function srcBlks = srcblksopen
% Are source blocks open?
srcBlks = getappdata(0, 'xPCTargetSourceBlocksOpen');
if isempty(srcBlks)
  srcBlks = 0;
end

if (srcBlks > 0)
  return
end

mdl   = xpcgate('getname');
ismdl = ~isempty(strmatch(mdl, ...
                          find_system('Type', 'block_diagram'), 'exact'));

srcBlks = double(ismdl                                                  && ...
                 strcmp(get_param(mdl, 'SimulationMode'),   'external') && ...
                 strcmp(get_param(mdl, 'SimulationStatus'), 'paused'  ));