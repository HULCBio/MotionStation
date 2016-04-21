function xpctgsctriggerwin(flag, flag1)

% XPCTGSCTRIGGERWIN - XPTGCSCOPE Helper Function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/03/25 04:23:22 $

colornorm=[0.752941,0.752941,0.752941];   

if flag==0
   
   if flag1==0
      usrdata=get(gcbf,'UserData');
   else
      usrdata=get(flag1,'UserData');
   end;
   
   usrdata.edit.subfigures.trigger = figure('Units','points', ...
	                           'Color',colornorm, ...
                              'Position',usrdata.edit.subfigure.trigger.position, ...
                              'CloseRequestFcn', 'xpctgsctriggerwin(-5);', ...
                              'Color',colornorm, ...
                              'MenuBar', 'none', ....
                              'Number', 'off', ...
                              'HandleVis','off',...
                              'Name', ['xPC Target: Trigger for Target Scope ', num2str(usrdata.edit.targetnumber)], ...
                              'Tag','Fig1');
   setxpcfont(usrdata.edit.subfigures.trigger,8,9);                   
   set(usrdata.edit.subfigures.trigger,'Userdata',usrdata.target.figure);
                                          
   %------------------------------------------
   % Trigger Frame
   %------------------------------------------

   usrdata.subfigure.trigger.frm_trigger = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                         'Units','normalized', ...
	                         'Position',[.01 .7 .98 .27], ...
	                         'Style','frame', ...
	                         'Tag','Frame1');

   usrdata.subfigure.trigger.ftl_trigger = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                        'Units','normalized', ...
	                        'HorizontalAlignment','center', ...
	                        'Position',[0.05 .94 .18 .05], ...
	                        'String','TRIGGER', ...
	                        'Style','text', ...
                           'Tag','StaticText1');
                            
   usrdata.subfigure.trigger.txt_triggermode = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                            'Units','normalized', ...
	                            'HorizontalAlignment','left', ...
	                            'Position',[0.02 0.88 .1 0.05], ...
	                            'String','Mode:', ...
	                            'Style','text', ...
                               'Tag','StaticText1');
                            
                            
   usrdata.subfigure.trigger.pop_triggermode = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                                'Units','normalized', ...
                                'Position',[.13 .885 .3 .05], ...
                                'BackgroundColor',[1 1 1], ...
                                'String','FreeRun|Software|Signal|Scope', ...
                                'Style','popupmenu', ...
                                'CallBack', 'xpctgsctriggerwin(-1,1)', ...
                                'Tag','PopupMenu1', ...
                                'Value', usrdata.edit.trigger.mode);                            
           
   usrdata.subfigure.trigger.txt_triggersignal1 = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                                'Units','normalized', ...
	                                'HorizontalAlignment','left', ...
                                   'Position',[0.02 0.8 0.1 0.05], ...
                                   'String', 'Signal:', ...
                               	  'Style','text', ...
                                   'Tag','StaticText1');
                               
   usrdata.subfigure.trigger.txt_triggersignal2 = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                              'Units','normalized', ...
	                              'HorizontalAlignment','left', ...
                                	'Position',[0.13 0.8 0.85 0.05], ...
                                	'String', '', ...
                               	'Style','text', ...
                                 'Tag','StaticText1');
                              
   usrdata.subfigure.trigger.txt_triggerlevel = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                             'Units','normalized', ...
                                'HorizontalAlignment','left', ...
                                'Position',[0.02 0.72 0.1 0.05], ...
                                'String','Level:', ...
                                'Style','text', ...
                                'Tag','StaticText1');
                             
   usrdata.subfigure.trigger.ed_triggerlevel = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                            'Units','normalized', ...
	                            'BackgroundColor',[1 1 1], ...
	                            'Position',[.13 .725 .2 .06], ...
                               'HorizontalAlignment','right', ...
                               'CallBack', 'xpctgsctriggerwin(-3)', ...
                               'Style','edit', ...
                               'String', num2str(usrdata.edit.trigger.level), ...
                               'Tag','EditText1');                             
                             
   usrdata.subfigure.trigger.txt_triggerslope = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                                'Units','normalized', ...
                                'HorizontalAlignment','left', ...
                                'Position',[0.5 0.88 0.1 0.05], ...
                                'String','Slope:', ...
                                'Style','text', ...
                                'Tag','StaticText1');

   usrdata.subfigure.trigger.pop_triggerslope = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
										  'Units','normalized', ...
	                             'Position',[.61 0.885 .3 .05], ...
                                'BackgroundColor',[1 1 1], ...
	                             'String','EITHER|RISING|FALLING', ...
                                'Style','popupmenu', ...
                                'CallBack', 'xpctgsctriggerwin(-2)', ...
	                             'Tag','PopupMenu2', ...
                                'Value',usrdata.edit.trigger.slope);
                                                       
   usrdata.subfigure.trigger.frm_signallist = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                           'Units','normalized', ...
	                           'Position',[.01 .01 .98 .64], ...
	                           'Style','frame', ...
                              'Tag','Frame1');
                           
   usrdata.subfigure.trigger.ftl_signallist = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
                                'Units','normalized', ...
                                'HorizontalAlignment','center', ...
                                'Position',[0.05 0.63 0.22 0.04], ...
                                'String','SIGNAL LIST', ...
                                'Style','text', ...
                                'Tag','StaticText1');
                           
   usrdata.subfigure.trigger.lb_signallist = uicontrol('Parent',usrdata.edit.subfigures.trigger, ...
	                          'Units','normalized', ...
	                          'BackgroundColor',[1 1 1], ...
	                          'Position',[.03 .03 .94 .6], ...
	                          'String','', ...
	                          'Style','listbox', ...
                             'Tag','Listbox1', ...
                             'CallBack', 'xpctgsctriggerwin(-4)', ...
                             'Value',1);
                          
   if usrdata.edit.trigger.mode == 1
      set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
      set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
      set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
      set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off');
   end;
   
   if ~isempty(usrdata.edit.api.triggersignal)
      txt_add_signal=usrdata.edit.trigger.signal;
      txt_add_signal(find(txt_add_signal=='.'))='/';
	   set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal);
   end;
   
   txt_list_signals=usrdata.edit.signals2trace;
   for i=1:length(usrdata.edit.signals2trace)
      name=usrdata.edit.signals2trace{i};
      index=find(name=='.');
      name(index)='/';
      txt_list_signals{i}=name;
   end;
   set(usrdata.subfigure.trigger.lb_signallist, 'String',txt_list_signals);  
   
   set(usrdata.target.figure, 'userdata', usrdata);
   
   if flag1==0
      xpctgsctriggerwin(-1,0);
   %elseif flag~=-1
   %   xpctgsctriggerwin(-1,usrdata.figures.scope);
   end;
   
else
   
   if flag~=-5 & flag~=-1
      usrdata=get(get(gcbf,'UserData'),'Userdata');
   end;
   
%-----------------------------------
% popup Trigger Mode
%-----------------------------------

	if flag==-1
   
      if flag1==0   
         usrdata=get(gcbf,'UserData');
      elseif flag1==1
         usrdata=get(get(gcbf,'Userdata'),'UserData');
      else
         usrdata=get(flag1,'UserData');   
      end;
      usrdata.edit.trigger.mode=get(usrdata.subfigure.trigger.pop_triggermode, 'Value');
            
      targetmanager=get(usrdata.targetmanager.figure,'UserData');
		pbhandle=findobj(usrdata.targetmanager.figure,'String',['Scope ',num2str(usrdata.edit.targetnumber)]);
		pbtag=get(pbhandle,'Tag');
		number=str2num(pbtag(end-1));
		if ~isempty(number)
  			pbnum=str2num(pbtag(end))+10;
		else
   		pbnum=str2num(pbtag(end));
		end;
		mode=get(targetmanager.menu(pbnum).softtrig,'Enable');
      if strcmp(mode,'on')
         xpcgate('softtrig',usrdata.edit.targetnumber);
      end;
      
      if usrdata.edit.trigger.mode==1
         set(targetmanager.menu(pbnum).softtrig, 'Enable','off');
         set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');	
         set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
         set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
         set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
         set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String', '', 'Value', 1);
                                    
         usrdata.edit.api.triggersignal={};
         usrdata.edit.trigger.signal='FreeRun';
         set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Signal:'); 
         set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
         set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
         set(usrdata.figure.target.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);         
         
         action='xpcgate(''setsctriggermode'',usrdata.edit.targetnumber,0);';
         writetotarget(usrdata,action);
      end;
      
      if usrdata.edit.trigger.mode==2
			state=get(targetmanager.menu(pbnum).startstop,'Label');
			if strcmp(state,'Start')
				set(targetmanager.menu(pbnum).softtrig, 'Enable','off');
			else
				set(targetmanager.menu(pbnum).softtrig, 'Enable','on');
			end;           
         set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');	
         set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
         set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
         set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
         set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String', '', 'Value', 1);
                                    
         usrdata.edit.api.triggersignal={};
         usrdata.edit.trigger.signal='Software';
         set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Signal:'); 
         set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
         set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
         set(usrdata.figure.target.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
         
         action='xpcgate(''setsctriggermode'',usrdata.edit.targetnumber,1);';
         writetotarget(usrdata,action);
      end;
      
      if usrdata.edit.trigger.mode == 3
         if ~isempty(usrdata.edit.signals2trace)
            if xpcgate('getsctriggermode',usrdata.edit.targetnumber)~=2
               set(targetmanager.menu(pbnum).softtrig, 'Enable','off');               
               set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'on');
            	set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'on');
            	set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
               set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
            	set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);
         
            	txt_add_signal=usrdata.edit.signals2trace{1};
               
         		usrdata.edit.trigger.signal=txt_add_signal;
            
            	usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.S.model',txt_add_signal]);
           
          		action='xpcgate(''setsctriggermode'',usrdata.edit.targetnumber,2);';
         		writetotarget(usrdata,action);
          		action='xpcgate(''setsctriggersignal'',usrdata.edit.targetnumber,usrdata.edit.api.triggersignal{1,1});';
               writetotarget(usrdata,action);
                
            	txt_list_signals=usrdata.edit.signals2trace;
            	for i=1:length(usrdata.edit.signals2trace)
               	name=usrdata.edit.signals2trace{i};
               	index=find(name=='.');
               	name(index)='/';
               	txt_list_signals{i}=name;
            	end;
            	set(usrdata.subfigure.trigger.lb_signallist, 'String',txt_list_signals);  
            	txt_add_signal(find(txt_add_signal=='.'))='/';
            	set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Signal:'); 
            	set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
	      		set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal);
               set(usrdata.figure.target.txt_triggersignal2, 'String', txt_add_signal);
            else
               set(targetmanager.menu(pbnum).softtrig, 'Enable','off');               
            	set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'on');
            	set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'on');
            	set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
               set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
            	set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);
            end;
         else
            set(targetmanager.menu(pbnum).softtrig, 'Enable','off');               
            set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');	
            set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
            set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
            set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
            set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String','', 'Value', 1);
            set(usrdata.subfigure.trigger.pop_triggermode, 'Value',1);
            usrdata.edit.trigger.mode=1;
         	usrdata.edit.api.triggersignal={};
         	usrdata.edit.trigger.signal='FreeRun';
            set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Signal:'); 
            set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
         	set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
         	set(usrdata.figure.target.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
          	action='xpcgate(''setsctriggermode'',usrdata.edit.targetnumber,0);';
         	writetotarget(usrdata,action);
         end;
      end;
      
      if usrdata.edit.trigger.mode==4
			usrdata=refresh_tgscope(usrdata);  
         if ~isempty(usrdata.T.scopelist)
            if xpcgate('getsctriggermode',usrdata.edit.targetnumber)~=3
               set(targetmanager.menu(pbnum).softtrig, 'Enable','off');               
         		set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
        			set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
         		set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
               set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SCOPE LIST');
         		set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);
         
         		txt_add_scopes=usrdata.T.scopelist;
            
         		txt_add_scope=txt_add_scopes{1};
      
      	   	txt_add_scope=[usrdata.S.modelpath,'.',txt_add_scope];
         		usrdata.edit.trigger.signal=txt_add_scope;
                     
      			usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.T.scope',txt_add_scope]);
         
          		action='xpcgate(''setsctriggermode'',usrdata.edit.targetnumber,3);';
         		writetotarget(usrdata,action);
          		action='xpcgate(''setsctriggerscope'',usrdata.edit.targetnumber,usrdata.edit.api.triggersignal{1,1});';
         		writetotarget(usrdata,action);
                  
            	txt_add_scope(find(txt_add_scope=='.'))='/';
            	set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Scope:'); 
            	set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Scope:');
            	set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_scope);
               set(usrdata.figure.target.txt_triggersignal2, 'String', txt_add_scope);
            else
               set(targetmanager.menu(pbnum).softtrig, 'Enable','off');               
         		set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');
        			set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
         		set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'on');
               set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SCOPE LIST');
        	   	set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'on', 'Value', 1);
            end;
         else
            set(targetmanager.menu(pbnum).softtrig, 'Enable','off');               
            set(usrdata.subfigure.trigger.ed_triggerlevel, 'Enable', 'off');	
            set(usrdata.subfigure.trigger.pop_triggerslope, 'Enable', 'off');
            set(usrdata.subfigure.trigger.txt_triggersignal2, 'Enable', 'off');
            set(usrdata.subfigure.trigger.ftl_signallist, 'String', 'SIGNAL LIST');
            set(usrdata.subfigure.trigger.lb_signallist, 'Enable', 'off','String','', 'Value', 1);
            set(usrdata.subfigure.trigger.pop_triggermode, 'Value',1);
            usrdata.edit.trigger.mode=1;
         	usrdata.edit.api.triggersignal={};
         	usrdata.edit.trigger.signal='FreeRun';
            set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Signal:'); 
            set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
         	set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
         	set(usrdata.figure.target.txt_triggersignal2, 'String', usrdata.edit.trigger.signal);
          	action='xpcgate(''setsctriggermode'',usrdata.edit.targetnumber,0);';
         	writetotarget(usrdata,action);
          	action='xpcgate(''setsctriggerscope'',usrdata.edit.targetnumber,usrdata.edit.targetnumber);';
         	writetotarget(usrdata,action);
      	end;
      end;
      set(usrdata.target.figure, 'userdata', usrdata);
   
   %-----------------------------------
   % popup Trigger Slope
   %-----------------------------------

   elseif flag == -2
   
      usrdata.edit.trigger.slope=get(usrdata.subfigure.trigger.pop_triggerslope, 'Value');
      action='xpcgate(''setsctriggerslope'',usrdata.edit.targetnumber,usrdata.edit.trigger.slope-1);';
     	writetotarget(usrdata,action);
      set(get(gcbf,'UserData'), 'userdata', usrdata);
   
   %-----------------------------------
   % Trigger Level
   %-----------------------------------

   elseif flag == -3
   
      if isempty(str2num(get(usrdata.subfigure.trigger.ed_triggerlevel, 'String')))
         errordlg('Trigger Level must be a number');
         set(usrdata.subfigure.trigger.ed_triggerlevel,'String', num2str(usrdata.edit.trigger.level));
      else
         level=str2num(get(usrdata.subfigure.trigger.ed_triggerlevel, 'String'));
         usrdata.edit.trigger.level=level;
         set(get(gcbf,'UserData'),'UserData',usrdata);         
      	action='xpcgate(''setsctriggerlevel'',usrdata.edit.targetnumber,usrdata.edit.trigger.level);';
     		writetotarget(usrdata,action);
      end;
   
   %-----------------------------------
   % Trigger Signal
   %-----------------------------------

   elseif flag == -4
      
      usrdata=get(usrdata.target.figure, 'UserData');
      
      if usrdata.edit.trigger.mode==3
               
         txt_add_signals=usrdata.edit.signals2trace;
     		num_add_signal=get(usrdata.subfigure.trigger.lb_signallist, 'Value');
   
       	txt_add_signal=txt_add_signals{num_add_signal};
            
      	usrdata.edit.trigger.signal=txt_add_signal;
                  
    	   usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.S.model',txt_add_signal]);
      	action='xpcgate(''setsctriggersignal'',usrdata.edit.targetnumber,usrdata.edit.api.triggersignal{1,1});';
     		writetotarget(usrdata,action);
                             
         txt_add_signal(find(txt_add_signal=='.'))='/';
         set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Signal:'); 
         set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Signal:');
	      set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_signal);
         set(usrdata.figure.target.txt_triggersignal2, 'String', txt_add_signal);
      end;
      
      if usrdata.edit.trigger.mode==4
         
         txt_add_scopes=usrdata.T.scopelist;
     		num_add_scope=get(usrdata.subfigure.trigger.lb_signallist, 'Value');
   
      	if ~isempty(usrdata.T.scopelist)
         	txt_add_scope=txt_add_scopes{num_add_scope};
      	else
         	return;
   	   end;
      
   	   txt_add_scope=[usrdata.S.modelpath,'.',txt_add_scope];
      	usrdata.edit.trigger.signal=txt_add_scope;
                     
      	usrdata.edit.api.triggersignal{1,1}=eval(['usrdata.T.scope',txt_add_scope]);
         
      	action='xpcgate(''setsctriggerscope'',usrdata.edit.targetnumber,usrdata.edit.api.triggersignal{1,1});';
     		writetotarget(usrdata,action);
         
         txt_add_scope(find(txt_add_scope=='.'))='/';
         set(usrdata.figure.target.txt_triggersignal1, 'String', 'Trigger Scope:'); 
         set(usrdata.subfigure.trigger.txt_triggersignal1, 'String', 'Scope:');
	      set(usrdata.subfigure.trigger.txt_triggersignal2, 'String', txt_add_scope);
         set(usrdata.figure.target.txt_triggersignal2, 'String', txt_add_scope);
     end;
      
      set(get(gcbf,'UserData'), 'userdata', usrdata);
     
   %----------------------------------------
   % close figure
   %----------------------------------------

   elseif flag == -5
      
      usrdata=get(get(gcbo,'UserData'),'Userdata');
      delete(usrdata.edit.subfigures.trigger);
      usrdata.edit.subfigures.trigger=-1;
      set(usrdata.target.figure, 'userdata', usrdata);
      
   end;                             

end;                           

function usrdata=callback_listbox(usrdata)

   value=get(usrdata.subfigure.trigger.lb_signallist,'Value');
   if ~isempty(usrdata.S.modelpath)
       value=value-1;
   end;
   
   if value==0 % .. pressed -> go up one step
      index=find(usrdata.S.modelpath=='.');
      usrdata.S.modelpath=usrdata.S.modelpath(1:index(end)-1);
      usrdata=refresh_trigger(usrdata);
   else
      if usrdata.S.submodels(value)
         usrdata.S.modelpath=[usrdata.S.modelpath,'.',usrdata.S.fnames{value}];
         set(usrdata.subfigure.trigger.lb_signallist,'Value',1);
         usrdata=refresh_trigger(usrdata);
      end;    
      
   end;
