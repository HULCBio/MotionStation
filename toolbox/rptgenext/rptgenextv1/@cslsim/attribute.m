function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:42 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

c.x.topFrame=controlsframe(c,'Time and I/O Options');
c.x.botFrame=controlsframe(c,'Simulation Parameters');

c=controlsmake(c);

set(c.x.simparam,'FontName',fixedwidthfont(c));

c.x.isSameSim=uicontrol(c.x.all,...
   'style','checkbox',...
   'Callback',[c.x.getobj, '''ChangeSimParamEdit'');'],...
   'String','Use model''s simulation setting');

c.x.editSim=uicontrol(c.x.all,...
   'Style','edit',...
   'HorizontalAlignment','left',...
   'Callback',[c.x.getobj,'''SimParamEdit'');'],...
   'BackgroundColor',[1 1 1]);

c.x.topFrame.FrameContent={c.x.useMDLioparam
   {'indent' c.x.timeOutTitle c.x.timeOut
      'indent' c.x.statesOutTitle c.x.statesOut
      'indent' c.x.matrixOutTitle c.x.matrixOut}
   [3]
   c.x.useMDLtimespan
   {'indent' c.x.startTimeTitle c.x.startTime
      'indent' c.x.endTimeTitle c.x.endTime}};

c.x.botFrame.FrameContent={c.x.simparam
   {c.x.isSameSim c.x.editSim}};

c.x.LayoutManager={c.x.topFrame
   [3]
   c.x.botFrame};

UpdateEnable(c);
UpdateSimParamList(c);
c=resize(c);

%mimic selecting the listbox
c=Update(c,'simparam',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

if strcmp(whichControl,'simparam')
   if length(varargin)>0
      selectIndex=varargin{1};
      set(c.x.simparam,'Value',selectIndex);
   else
      selectIndex=get(c.x.simparam,'Value');
   end 
   
   paramStruct=get(c.x.simparam,'UserData');
   paramNames=fieldnames(paramStruct);
   paramName=paramNames{selectIndex};
   paramValue=getfield(paramStruct,paramName);
   
   optionIndex=find(strcmp(c.att.simparam(1:2:end-1),paramName));
   if isempty(optionIndex)
      editEnable='off';
      checkValue=1;      
   else
      editEnable='on';
      checkValue=0;
   end
   set(c.x.editSim,'enable',editEnable,...
      'String',paramValue,...
      'UserData',paramName);
   set(c.x.isSameSim,'value',checkValue);   
else
   c=controlsupdate(c,whichControl,varargin{:});   
   if any(strcmp({'useMDLioparam','useMDLtimespan'},...
         whichControl))
      UpdateEnable(c);
   end      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateEnable(c)

if c.att.useMDLtimespan
   timeVals={'Model Tstart';'Model Tstop'};   
   timeEnable={'off';'off'};
else
   timeVals={c.att.startTime;
      c.att.endTime};
   timeEnable={'on';'on'};
end

set([c.x.startTime c.x.endTime],...
   {'enable'},timeEnable,...
   {'String'},timeVals);

if c.att.useMDLioparam
   iopEnable={'off';'off';'off'};
   iopVals={'Model Time';
      'Model States';
      'Model Output'};
else
   iopVals={c.att.timeOut;
      c.att.statesOut;
      c.att.matrixOut};
   iopEnable={'on';'on';'on'};      
end      

set([c.x.timeOut c.x.statesOut c.x.matrixOut],...
   {'Enable'},iopEnable,...
   {'String'},iopVals);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateSimParamList(c);

prevTop=get(c.x.simparam,'listboxtop');
rgtm=tempmodel(c);

oStruct=makeoptionstruct(c,c.att.simparam,rgtm);
set(c.x.simparam,...
   'listboxtop',prevTop,...
   'String',makepvstring(c,oStruct),...
   'UserData',oStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ChangeSimParamEdit(c);

currParam=get(c.x.editSim,'UserData');

if get(c.x.isSameSim,'Value')
   %if we are turning editing off
   editEnable='off';
   paramIndex=find(strcmp(c.att.simparam,currParam));
   c.att.simparam=c.att.simparam([1:paramIndex-1,...
         paramIndex+2:end]);   
else
   paramStruct=get(c.x.simparam,'UserData');
   
   paramVal=getfield(paramStruct,currParam);

   editEnable='on';
   c.att.simparam{end+1}=currParam;
   c.att.simparam{end+1}=paramVal;
end

UpdateSimParamList(c);
oStruct=get(c.x.simparam,'UserData');

set(c.x.editSim,...
   'Enable',editEnable,...
   'String',getfield(oStruct,currParam));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=SimParamEdit(c);

currParam=get(c.x.editSim,'UserData');
paramIndex=find(strcmp(c.att.simparam,currParam));
if ~isempty(paramIndex)
   simVal=get(c.x.editSim,'String');
   
   oStruct=makeoptionstruct(c,{},tempmodel(c));

   defaultVal=getfield(oStruct,currParam);
   
   errMsg='';
   if isnumeric(defaultVal) & ~isempty(defaultVal)
      simVal=str2num(simVal);
      if isempty(simVal)
         simVal=defaultVal;
         errMsg='Value must be numeric';
      end
   end
   statbar(c,errMsg,1);
   set(c.x.editSim,'String',simVal);
   c.att.simparam{paramIndex(1)+1}=simVal;
   
   
   UpdateSimParamList(c);
end



