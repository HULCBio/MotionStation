function figNumber = paramsel(h,varargin);
%PARAMSEL Opens and controls the Model Selector for LTI Arrays

%   Authors: Kelly Liu, 5-20-98
%   Revised: Adam DiVergilio, 11-99
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:38 $
%   $$  $ $

figNumber = [];
if isempty(h)
    return;
end
if nargin == 3,
   updataIndex = varargin{2};
end
if nargin >= 2
   figNumber = varargin{1};
end


responses=h.responses;
for k=1:length(responses)
   s=size(h.responses(k).datasrc.Model);
   if length(s)>=3
        repHndls{k}=reshape(strcmpi(get(h.responses(k).view,'Visible'),'on'),s(3:end));
    else
        repHndls{k}=strcmpi(get(h.responses(k).view,'Visible'),'on');
    end
end
DataSrcs=get(responses,'DataSrc');
dataInfo.obj=h;

if isempty(figNumber)
  %===================================
  % Information for all objects
  StdColor = get(0,'DefaultUicontrolBackgroundColor');
  StdUnit = 'character';
  
  %====================================
  % The FIGURE
  figNumber=figure( ...
     'Name',['Model Selector for LTI Arrays'], ...
     'NumberTitle','off', ...
     'Color',StdColor, ...
     'IntegerHandle','off',...
     'MenuBar','none', ...
     'Resize','on', ...
     'Visible','off', ...
     'Unit',StdUnit, ...
     'Position',[0.8 6.6154 90 20.153846], ...
     'Tag','LTIArraySelector', ...
     'HandleVisibility','off', ...
     'CloseRequestFcn', 'set(gcf, ''Visible'', ''off'')', ...
     'BackingStore','off',...
     'DockControls', 'off');
      
  rwInfo1(figNumber, dataInfo);

  %---Position figure within LTI Viewer bounds

  centerfig(figNumber,get(h.axesgrid,'parent'));

 
  
  
  %========================================================
  % The MAIN frame 
  %====================================
  
  ruleFrmHndl=uicontrol(figNumber, ...
     'Style','frame', ...
     'Units',StdUnit, ...
     'Position',[1.1 0.25 88 19], ...
     'BackgroundColor',StdColor);
  %------------------------------------
  
  helpHndl=uicontrol(figNumber, ...
     'Style','Text', ...
     'Units',StdUnit, ...
     'Position',[3.4 16.3 8 1.6], ...
     'HorizontalAlignment', 'left', ...
     'BackgroundColor',StdColor, ...
     'String','Arrays:');
  
  %---Initialize UserData
  modelSize = length(repHndls);
  arrayIndex=[];
  
  if length(DataSrcs)>1
      temp=get([DataSrcs{:}],'Name');
  else
      temp{1}=get(DataSrcs,'Name');
  end 

  k=1;
  for i=1:modelSize
     if prod(size(repHndls{i}))~=1
        if ~isempty(temp{i})
            str{k} = temp{i};
        else
            str{k} = responses(k).name; %'Untitled';
        end
        arrayIndex(k)=i;
        dimInfo{k}=size(repHndls{i});  
        k = k+1;
     end
  end
  %---Initialize selarray
  selarray=cell(1,k-1);
  selected=ones(1,k-1)*2; 
  actived=ones(1,k-1);
  for i=1:k-1 
     consInfo{i}={};
     consActive{i}=zeros(1,4);
     selarray{i} = ones(max(dimInfo{i}), length(dimInfo{i}));
  end  
  if k==1 %all the sysyems have dim <= 2
      return;
  end
  reponseH=size(repHndls{arrayIndex(1)});

  dataInfo.dimInfo=dimInfo;
  
  dataInfo.arrayIndex=arrayIndex;
  helpHndl=uicontrol(figNumber, ...
     'Style','Popupmenu', ...
     'Units',StdUnit, ...
     'Position',[14 16.3 20 1.6], ...
     'BackgroundColor',[1 1 1], ...
     'String',str, ...
     'Tag', 'Array',...
     'Callback',{@localArray h});
  helpHndl=uicontrol(figNumber, ...
     'Style','text', ...
     'HorizontalAlignment','left', ...
     'Units',StdUnit, ...
     'Position',[3.4 12 20 1.6], ...
     'BackgroundColor',StdColor, ...
     'String','Selection Criteria', ...
     'Tag', 'criterionlabel');
  helpHndl=uicontrol(figNumber, ...
     'Style','listbox', ...
     'Units',StdUnit, ...
     'Position',[3.4 5.6 31.7 6.5], ...
     'BackgroundColor',[1 1 1], ...
     'String',{'Index into Dimensions','Bound on Characteristics'}, ...
     'Tag', 'criterion',...
     'Value', 1,...
     'Callback',{@localCriterion});
  
  
  %====================================
  % The STATUS frame 
  mainFrmHndl=uicontrol(figNumber, ...
     'Style','frame', ...
     'Units',StdUnit, ...
     'Position',[3.4 2.5 84 2.6], ...
     'BackgroundColor',StdColor);
  
  
  %------------------------------------
  % The STATUS text window
  txtHndl=uicontrol(figNumber, ...
     'Style','text', ...
     'BackgroundColor',StdColor, ...
     'HorizontalAlignment','left', ...
     'Units',StdUnit, ...
     'Position',[4.4 2.65 82 2.25], ...
     'Tag','status', ...
     'String','Show selected plots');
  %------------------------------------
  %=========apply======================
  helpHndl=uicontrol(figNumber, ...
     'Style','pushbutton', ...
     'BackgroundColor',StdColor, ...
     'Units',StdUnit, ...
     'Position',[14.8 0.6 10 1.6], ...
     'String','OK',...
     'Callback', {@localGetSelection 'off'},...
     'Tag', 'OK');
  
  %========cancel=========
  helpHndl=uicontrol(figNumber, ...
     'Style','push', ...
     'Units',StdUnit, ...
     'Position',[31.8 .6 10 1.6], ...
     'BackgroundColor',StdColor, ...
     'String','Cancel', ...
     'Callback','set(gcbf, ''Visible'', ''off'')');
  
  %============help==========================
  helpHndl=uicontrol(figNumber, ...
     'Style','push', ...
     'Units',StdUnit, ...
     'Position',[48.8 0.6 10 1.6], ...
     'BackgroundColor',StdColor, ...
     'String','Help', ...
     'Callback','ctrlguihelp(''response_arrayselector'');');
  
  %================apply=======================
  closeHndl=uicontrol(figNumber, ...
     'Style','push', ...
     'Units',StdUnit, ...
     'Position',[65.7 0.6 10 1.6], ...
     'BackgroundColor',StdColor, ...
     'String','Apply', ...
     'Callback',{@localGetSelection});
  
  selarray{1}=localAddrulemake(figNumber,reponseH, 0, []);
  
  localAddCharact(figNumber,h);

  dataInfo.selected=selected;
  dataInfo.selarray=selarray;
  dataInfo.actived = actived;
  dataInfo.consInfo=consInfo;
  dataInfo.consActive=consActive;
  % Uncover the figure
  set(figNumber, ...
     'Visible','on', ...
     'HandleVisibility','callback');
  rwInfo1(figNumber, dataInfo);
  localsetallVisible(figNumber, 1);
  localsetallEnable(figNumber, reponseH, 2);
 
  dataInfo.Listener = [handle.listener(h,'ObjectBeingDestroyed',{@LocalDeleteFigure figNumber})
                       handle.listener(h,findprop(h,'visible'),'PropertyPostSet',{@LocalDeleteFigure figNumber}) 
                       handle.listener(h.responses,'ObjectBeingDestroyed',{@LocalDeleteResp figNumber})];
                       
  rwInfo1(figNumber, dataInfo);
else
  set(figNumber, ...
     'Visible','on');
  figure(figNumber);
  localUpdata(figNumber, h,repHndls, DataSrcs);
  localArray([],[],h, figNumber);
end


function localUpdata(figNumber, RespObj,repHndls, DataSrcs)


dataInfo=rwInfo1(figNumber);
OldNames = get(findobj(figNumber, 'Tag', 'Array'),'String');
arrayIndex=[];

if length(DataSrcs)>1
  temp=get([DataSrcs{:}],'Name');
else
  temp{1}=get(DataSrcs,'Name');
end 

k=1;
modelSize = length(repHndls);

for i=1:modelSize
 if prod(size(repHndls{i}))~=1
    if ~isempty(temp{i})%newcode
        str{k} = temp{i};
    else
        str{k} = RespObj.responses(k).name; %'Untitled';
        temp{i} = str{k}; %'Untitled';
    end
    arrayIndex(k)=i;
    dimInfo{k}=size(repHndls{i});  
    k = k+1;
 end
end

NewNames = temp(arrayIndex);

%---Initialize selarray
selarray=cell(1,k-1);
selected=ones(1,k-1)*2; 
actived=ones(1,k-1);
for i=1:k-1 
   consInfo{i}={};
   consActive{i}=zeros(1,4);
   selarray{i} = ones(max(dimInfo{i}), length(dimInfo{i}));
end  

dataInfoNew.dimInfo=dimInfo;
dataInfoNew.arrayIndex=arrayIndex;
dataInfoNew.selected=selected;
dataInfoNew.selarray=selarray;
dataInfoNew.actived = actived;
dataInfoNew.consInfo=consInfo;
dataInfoNew.consActive=consActive;

%---Update models already in the list, based on SystemNames
[garb,refreshIndex,refreshFromIndex]=intersect(NewNames,OldNames);

for i=1:length(refreshIndex)
   if isequal(dataInfoNew.dimInfo{refreshIndex(i)},dataInfo.dimInfo{refreshFromIndex(i)}),
      dataInfoNew.selected(refreshIndex(i))=dataInfo.selected(refreshFromIndex(i));
      dataInfoNew.selarray{refreshIndex(i)}=dataInfo.selarray{refreshFromIndex(i)};
      dataInfoNew.actived(refreshIndex(i)) = dataInfo.actived(refreshFromIndex(i));
      dataInfoNew.consInfo{refreshIndex(i)}=dataInfo.consInfo{refreshFromIndex(i)};
      dataInfoNew.consActive{refreshIndex(i)}=dataInfo.consActive{refreshFromIndex(i)};
   end % if isequal(array dimensions of previous and current model
end % for i

arrayHndl=findobj(figNumber, 'Tag', 'Array');
CurrentArray = popupstr(arrayHndl);
ArrayVal = strmatch(CurrentArray,NewNames,'exact');
if isempty(ArrayVal),
   ArrayVal=1;
end
if length(ArrayVal)>1 %more than one untitled
    ArrayVal=ArrayVal(1);
end
set(arrayHndl,'String',NewNames,'Value',ArrayVal);
dataInfoNew.Listener = dataInfo.Listener;
dataInfoNew.obj = dataInfo.obj;
rwInfo1(figNumber,dataInfoNew);


function localDelete(figNumber, RespObj, index)
%========== by Karen Gondoly


dataInfo = rwInfo1(figNumber);


arrayIndex=dataInfo.arrayIndex;
arrayHndl=findobj(figNumber, 'Tag', 'Array');
ArrayStr = get(arrayHndl,'String');
ArrayVal = get(arrayHndl,'Value');
CurrentArray = ArrayStr{ArrayVal};
[DupInds,indold,indnew]=intersect(arrayIndex,index);

%---Remove appropriate Arrays from the popupmenu
ArrayStr(indold)=[];

if isempty(ArrayStr)
   %---No arrays left, close the Selector and turn the ArrayMenu off
   set(RespObj,'ArraySelector','off')
   delete(figNumber)
   ContextMenu = get(RespObj,'UIcontextMenu');
   set(ContextMenu.ArrayMenu,'visible','off')
else
   %---Remove the appropriate data from the Figure's UserData
   
   SystemNames = get(RespObj,'SystemNames');
   [garb,arrayIndex,garb2]=intersect(SystemNames,ArrayStr);

   dataInfo.dimInfo(indold)=[];
   dataInfo.arrayIndex = sort(arrayIndex)';
   dataInfo.consInfo(indold)=[];
   dataInfo.selarray(indold)=[];
   dataInfo.consActive(indold)=[];
	dataInfo.obj=RespObj;
   rwInfo1(figNumber, dataInfo); 
   ArrayVal = strmatch(CurrentArray,ArrayStr);
   if isempty(ArrayVal),
      ArrayVal=1;
   end
   set(arrayHndl, 'String', ArrayStr,'Value',ArrayVal);
   localArray([],[],h);

end % if/else isempty(ArrayStr)

function localAddCharact(figNumber,h)
dispStr={'Peak Response', 'Settling Time (Sec)', 'Rise Time (Sec)', 'Steady State'};

StdUnit = 'character';
StdColor = get(0,'DefaultUicontrolBackgroundColor');

for i=1:4
   dimHndl=uicontrol(figNumber, ...
      'Style','checkbox', ...
      'Units',StdUnit, ...
      'Position',[38.5 15-((i-1)*2) 27 1.6], ...
      'BackgroundColor',StdColor, ...
      'HorizontalAlignment','left', ...
      'String', dispStr{i},...
      'Visible', 'off', ...
      'Tag',['critecheck' num2str(i)], ...
      'Callback', {@localCheck});
    
   helpHndl=uicontrol(figNumber, ...
      'Style','edit', ...
      'Units',StdUnit, ...
      'Position',[66.5 15-((i-1)*2) 17 1.6], ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment', 'left',...
      'String',' ', ...
      'Tag', ['criteedit' num2str(i)],...
      'Visible', 'off', ...
      'Enable', 'off', ...
      'Max', 1);
   
end


function out=localAddrulemake(figNumber,Hinfo, flag, selarray)
%flag ==0 is for initialization
% Information for all objects

StdUnit = 'character';
StdColor = get(0,'DefaultUicontrolBackgroundColor');

if flag == 0  %called in init, set up frames
   
   mainFrmHndl=uicontrol(figNumber, ...
      'Style','frame', ...
      'Units',StdUnit, ...
      'Position',[37.3 5.5 50 12.7], ...
      'BackgroundColor',StdColor);
   mainFrmHndl=uicontrol(figNumber, ...
      'Style','text', ...
      'Units',StdUnit, ...
      'Position',[47.3 17.1 30 1.6], ...
      'String', 'Selection Criterion Setup', ...
      'Tag', 'criterionlabel', ...
      'BackgroundColor',StdColor);
   helpHndl=uicontrol(figNumber, ...
      'Style','popupmenu', ...
      'Units',StdUnit, ...
      'Position',[38.5 5.9 21 1.6], ...
      'BackgroundColor',[1 1 1], ...
      'String',{'show all','show selected', 'hide selected'}, ...
      'Tag', 'showpopup',...
      'Value', 2,...
      'Callback',{@localShow});
end %flag==0
%------------------------------------
% The listboxes
boxHeight = 5.5;
boxWidth = 14;
boxBottom = 10;
boxStart = 38.5;
boxDx = boxWidth + 1.87;
numInputs=size(Hinfo, 2);    
% set up selected array
if isempty(selarray)
   out = ones(max(Hinfo), length(Hinfo));
else
   out = selarray;
end

%---Add the Dimension list boxes
for i=0:numInputs-1
   visibility='off';
   enable='on';
   if i>2
      visibility = 'off';
      enable='off';
   end
   thisvalue=find(out(1:Hinfo(i+1), i+1)==1);
   dimHndl=uicontrol(figNumber, ...
      'Style','listbox', ...
      'Units',StdUnit, ...
      'Position',[boxStart+(i*boxDx) boxBottom boxWidth boxHeight], ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'String',num2str((1:Hinfo(i+1))'),...
      'Max', Hinfo(i+1), ...
      'Value', thisvalue, ...
      'Visible', visibility, ...
      'Enable', enable, ...
      'Tag',['dim' num2str(i+1)], ...
      'Callback', {@localClearEdit});

   textHndl=uicontrol(figNumber, ...
      'Style','text', ...
      'Units',StdUnit, ...
      'Position',[boxStart+(i*boxDx) 15.8 boxWidth 1.6], ...
      'BackgroundColor',StdColor, ...
      'String', num2str(i+1),...
      'Visible', visibility, ...
      'HorizontalAlignment','center', ...
      'Tag',['dimlabel' num2str(i+1)]);
   
   helpHndl=uicontrol(figNumber, ...
      'Style','edit', ...
      'Units',StdUnit, ...
      'Position',[boxStart+(i*boxDx) 8.1 boxWidth 1.6], ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment', 'left',...
      'String',' ', ...
      'Tag', ['constrain' num2str(i+1)],...
      'Visible', visibility, ...
      'Max', 1,...
      'Callback', {@localConstrain});
   
end
if flag ==0  %call by init, set up shift buttons
   %=======buttons for shift=============
   shiftEnable='off';
   shiftVisible='off';
   if size(Hinfo,2)>3
      shiftEnable = 'on';
      shiftVisible = 'on';
   end
   helpHndl=uicontrol(figNumber, ...
      'Style','push', ...
      'Units',StdUnit, ...
      'Position',[75 5.9 5 1.6], ...
      'BackgroundColor',StdColor, ...
      'Tag', 'shiftleft',...
      'String','<<', ...
      'Enable', shiftEnable, ...
      'Visible', shiftVisible, ...
      'Callback',{@localShiftLeft});
   helpHndl=uicontrol(figNumber, ...
      'Style','push', ...
      'Units',StdUnit, ...
      'Position',[81 5.9 5 1.6], ...
      'BackgroundColor',StdColor, ...
      'Tag', 'shiftright',...
      'String','>>', ...
      'Enable', 'off', ...
      'Visible', shiftVisible, ...
      'Callback',{@localShiftRight});
   
end %if flag == 0


function [out, out1]=localgetselection(figNumber, dimInfo, arrayvalue)

%dimInfo dim of local MIMO
%arrayvalue pos of local MIMo

errflag = 0;
out=ones(dimInfo);
out1=zeros(max(dimInfo), length(dimInfo));
cnstrnHndl=findobj(figNumber, 'Tag', 'criterion');
cntsStr=get(cnstrnHndl, 'String');
indexStr=cntsStr{1};
boundStr=cntsStr{2};
numInputs=size(dimInfo, 2);
showHndl=findobj(figNumber, 'Tag', 'showpopup');
showvalue = get(showHndl, 'value');
warnStr='';
if showvalue == 1
   out=ones(dimInfo);
else 
   for i=1:numInputs
      tempout=zeros(dimInfo);
      Hndl=findobj(figNumber, 'Tag', ['dim' num2str(i)]);
      
      onIndex=get(Hndl, 'Value');
      out1(onIndex,i)=1;
      t1=repmat(':,',1,i-1);
      t2=repmat(', :',1,numInputs-i);
      t=[t1 '[' num2str(onIndex) ']' t2];
      outstr=['tempout(' t ')=1;'];
      eval(outstr);
      out=out&tempout;
   end
   
   if showvalue==3, % Get inverse of what is selected
      out=~out;
   end
end
info = rwInfo1(figNumber);
thisout=ones(dimInfo);
h=info.obj;

[input, output] = size(h);
plotType = h.Tag; %dataFcn{3};


% *************************************************************

switch class(h)
case 'resppack.timeplot'
    switch plotType  
	case 'step'
		boundName={'Peak Response','Settling Time','Rise Time','Steady State'}; %charIds and string used by warnings and errors to identify characteristics
		timeName={'Peak','Time','Time','Value'}; %name of $ variable for each characteristic - used in a wanring string
		characteristicName={'resppack.StepPeakRespData','resppack.StepSettleTimeData','resppack.StepRiseTimeData','resppack.TimeFinalValueData'}; %class name of characteristic data object
		characteristicViewName={'resppack.StepPeakRespView','resppack.SettleTimeView','resppack.StepRiseTimeView','resppack.StepSteadyStateView'}; %class name of characteristic view object
		valueName={'PeakResponse','Time','THigh','FinalValue'}; %characteristic data property to be used for filtering
	case 'impulse'
		boundName={'Peak Response','Settling Time'}; %string used by warnings and errors to identify characteristics
		timeName={'Peak','Time'}; %name of $ variable for each characteristic - used in a wanring string
		%characteristicName={'resppack.ImpulsePeakRespData','resppack.SettleTimeData'}; %class name of characteristic data object  
        characteristicName={'wavepack.TimePeakAmpData','resppack.SettleTimeData'}; %class name of characteristic data object
        characteristicViewName={'wavepack.TimePeakAmpView','resppack.SettleTimeView'}; %class name of characteristic view object
		valueName={'PeakResponse','Time'}; %characteristic data property to be used for filtering    
	end 
case 'resppack.simplot'
    boundName={'Peak Response'}; %string used by warnings and errors to identify characteristics
    timeName={'Peak'}; %name of $ variable for each characteristic - used in a wanring string
    characteristicName={'wavepack.TimePeakAmpData'};
    characteristicViewName={'wavepack.TimePeakAmpView'}; %class name of characteristic view object
    valueName={'PeakResponse'}; %characteristic data property to be used for filtering
case 'resppack.bodeplot'
    if prod(h.axesgrid.size) == 2 %all SISO systems
        boundName={'Peak Response','Gain Margin','Phase Margin'}; %string used by warnings and errors to identify characteristics
        timeName={'Peak','Gain margin', 'Phase margin'}; %name of $ variable for each characteristic - used in a wanring string
        characteristicName={'wavepack.FreqPeakGainData','resppack.MinStabilityMarginData','resppack.MinStabilityMarginData'}; %class name of characteristic data object
        characteristicViewName={'wavepack.FreqPeakGainView','resppack.BodeStabilityMarginView','resppack.BodeStabilityMarginView'}; %class name of characteristic view object
        valueName={'PeakGain','GainMargin','PhaseMargin'}; %characteristic data property to be used for filtering        
    else
        boundName={'Peak Response'}; %string used by warnings and errors to identify characteristics
        timeName={'Peak'}; %name of $ variable for each characteristic - used in a wanring string
        characteristicName={'wavepack.FreqPeakGainData'}; %class name of characteristic data object
        characteristicViewName={'wavepack.FreqPeakGainView'}; %class name of characteristic view object
        valueName={'PeakGain'}; %characteristic data property to be used for filtering
    end
case 'resppack.sigmaplot'
    boundName={'Peak Response'}; %string used by warnings and errors to identify characteristics
    timeName={'Peak'}; %name of $ variable for each characteristic - used in a wanring string
    characteristicName={'resppack.SigmaPeakRespData'}; %class name of characteristic data object
    characteristicViewName={'resppack.SigmaPeakRespView'}; %class name of characteristic view object
    valueName={'PeakGain'}; %characteristic data property to be used for filtering
case 'resppack.nyquistplot'   
   if prod(h.axesgrid.size) == 1 %all SISO systems 
        boundName={'Gain Margin','Phase Margin'}; %string used by warnings and errors to identify characteristics
        timeName={'Gain margin', 'Phase margin'}; %name of $ variable for each characteristic - used in a wanring string
        characteristicName={'resppack.MinStabilityMarginData','resppack.MinStabilityMarginData'}; %class name of characteristic data object
        characteristicViewName={'resppack.NyquistStabilityMarginView','resppack.NyquistStabilityMarginView'}; %class name of characteristic view object
        valueName={'GainMargin','PhaseMargin'}; %characteristic data property to be used for filtering
    else 
        boundName={''}; %string used by warnings and errors to identify characteristics
        timeName={''}; %name of $ variable for each characteristic - used in a wanring string
        characteristicName={''}; %class name of characteristic data object
        characteristicViewName={''}; %class name of characteristic view object
        valueName={''}; %characteristic data property to be used for filtering
    end
case 'resppack.nicholsplot'   
   if prod(h.axesgrid.size) == 1 %all SISO systems 
        boundName={'Gain Margin','Phase Margin'}; %string used by warnings and errors to identify characteristics
        timeName={'Gain margin', 'Phase margin'}; %name of $ variable for each characteristic - used in a wanring string
        characteristicName={'resppack.MinStabilityMarginData','resppack.MinStabilityMarginData'}; %class name of characteristic data object
        characteristicViewName={'resppack.NicholsStabilityMarginView','resppack.NicholsStabilityMarginView'}; %class name of characteristic view object
        valueName={'GainMargin','PhaseMargin'}; %characteristic data property to be used for filtering
    else 
        boundName={''}; %string used by warnings and errors to identify characteristics
        timeName={''}; %name of $ variable for each characteristic - used in a wanring string
        characteristicName={''}; %class name of characteristic data object
        characteristicViewName={''}; %class name of characteristic view object
        valueName={''}; %characteristic data property to be used for filtering
    end
otherwise
    boundName={''}; %string used by warnings and errors to identify characteristics
    timeName={''}; %name of $ variable for each characteristic - used in a wanring string
    characteristicName={''}; %class name of characteristic data object
    characteristicViewName={''}; %class name of characteristic view object
    valueName={''}; %characteristic data property to be used for filtering
end
    
    
    
% ************************************************************
   
checkHndl=findobj(figNumber, 'Style', 'checkbox');
checkTag=get(checkHndl, 'Tag');
for i=1:length(checkTag)
  tempStr=checkTag{i};
  if get(checkHndl(i), 'Value') == 1
    editHndl=findobj(figNumber,'Tag', ['criteedit' tempStr(end)]);
    editStr=get(editHndl, 'String');
    thisCharacteristicName=characteristicName{str2num(tempStr(end))};
    thisCharacteristicViewName=characteristicViewName{str2num(tempStr(end))};
    thisCharacteristicValueStr=valueName{str2num(tempStr(end))};    
    thisCharID = boundName{str2num(tempStr(end))}; 
    
    
    
    existingChars=get(h.responses(arrayvalue).characteristics,'data'); %array length = product of extra dims
    if ~isempty(existingChars) & ~strcmp(class(existingChars),'cell')
        existingChars1{1}=existingChars;
        existingChars=existingChars1;
    end
   
    %this is a cell array of n (the number of defined chars) vectors of @respdata handles each of
    %length = numInputs, the number of systems in this array   
    
    %if the desired characteristic does not exist thencreate it
    thisSysChars{1}='';
    for j=size(existingChars,1):-1:1
        thisSysChars{j}=class(existingChars{j}(1));
    end
    I=strcmpi(thisSysChars,thisCharacteristicName);
    if isempty(thisSysChars) | ~any(I) %none of this char exists for one system
        %no need to handle simplot addchar method since this cant be a simplot
        c_old = get(h.responses,'characteristics');
        if strcmpi(class(c_old),'cell')
            c_old  = reshape([c_old{:}],[prod(size([c_old{:}])) 1]);
        end
        if strcmpi(class(h),'resppack.simplot') %simplot requires xtra arg due to input chars
            h.addchar(thisCharID,thisCharacteristicName,thisCharacteristicViewName,'','visible','off');
        else
            h.addchar(thisCharID,thisCharacteristicName,thisCharacteristicViewName,'visible','off');
        end
        c_new = get(h.responses,'characteristics');
        if strcmpi(class(c_new),'cell')
            c_new  = reshape([c_new{:}],[prod(size([c_new{:}])) 1]);
        end
        deltaC = setdiff(c_new',c_old');
        for j=1:length(deltaC)
            if ~isempty(deltaC(j).DataFcn)
               feval(deltaC(j).DataFcn{:});
            end
        end
        %set(setdiff(c_new,c_old),'visible','off');
        thisSysChars{1}=thisCharacteristicName;
    end  
    existingChars=get(h.responses(arrayvalue).characteristics,'data'); %repeat in case any new chars created
    if strcmpi(class(existingChars),'cell') %xxx
        for j=size(existingChars,1):-1:1
                thisSysChars{j}=class(existingChars{j}(1));
        end
    else %xxx
         thisSysChars{1}=class(existingChars); %xxx
         existingChars1{1}=existingChars; %xxx
         existingChars=existingChars1;  %xxx     
    end %xxx
    s=size(h.responses(arrayvalue).datasrc.Model);
    if strcmpi(plotType,'sigma') 
        s = s(3:end); %there are only s(3:end)peak responses for a sigma plot
    elseif strcmpi(plotType,'initial') 
        s = [s(1) s(3:end)]; %there are only [s(1) s(3:end)] views for a sigma plot
    end
        
         
    cellvalue=zeros(s);
    I=find(strcmpi(thisSysChars,thisCharacteristicName));
    thisChars=get(existingChars{I},thisCharacteristicValueStr);
    if strcmpi(class(thisChars),'cell')
        thisChars=[thisChars{:}];
    end
    

    if ~isempty(thisChars)
        cellvalue=reshape(thisChars,s);
        charStr=timeName{str2num(tempStr(end))}; %selected charName substring        
        %thisvalue=cellvalue(arrayvalue);

          if ~strcmp(deblank(editStr), '')  
        
          %----By Greg
          % find a unique variable name for use in base workspace
          % use it to replace $ token
          %
          nonuniq=1;
          while nonuniq
             varnm=char(floor(rand(1,24)*25+65));
             eStr=['exist(''' varnm ''',''var'')'];
             nonuniq=evalin('base', eStr);
          end
          hasDollar=findstr(editStr, '$');
          if isempty(hasDollar)
             warndlg(['Error while evaluating ',...
                   boundName{str2num(tempStr(end))}(1:end-5),...
                   ' constraint.. no selection was applied.'...
                   '  Expression must use $ to reference ' charStr '.'], ...
                'Model Selector Warning');
             errflag = 1;
             thisout = logical(ones(dimInfo));
          else
             [editStr,errmsg]=LocalArrayIndexingParser(editStr);
             if ~isempty(errmsg)
                newlines = sprintf('\n\n');
                warndlg(['Error while evaluating ', ...
                      boundName{str2num(tempStr(end))}(1:end-5), ...
                      ' constraint.. no selection was applied.', ...
                      newlines errmsg], ... 
                   'Model Selector Warning');
                 errflag = 1;
                 thisout = logical(ones(dimInfo));
             else
                editStr=strrep(editStr, '$', varnm);
                
                % Assign the response data into the workspace
                % and try to evaluate the string
                %
                
                % bode/Nyquist/Nichols plot characteristic unit conversion
                %**********************************************************
                if strcmpi(plotType, 'bode') 
                    if (strcmpi(thisCharacteristicValueStr,'GainMargin') | strcmpi(thisCharacteristicValueStr,'PeakGain'))...
                            & strcmpi(h.axesgrid.Yunits(1),'dB')
                        cellvalue = unitconv(cellvalue,'abs','dB');
                    elseif strcmpi(thisCharacteristicValueStr,'PhaseMargin')& strcmpi(h.axesgrid.Yunits(2),'rad')
                        cellvalue = unitconv(cellvalue,'deg','rad');
                    end              
                elseif  strcmpi(plotType, 'nichols')
                    if strcmpi(thisCharacteristicValueStr,'GainMargin') %Y axis is always dB
                        cellvalue = unitconv(cellvalue,'abs','dB');
                    elseif strcmpi(thisCharacteristicValueStr,'PhaseMargin') & strcmpi(h.axesgrid.Xunits,'rad')
                        cellvalue = unitconv(cellvalue,'deg','rad');
                    end        
                elseif  strcmpi(plotType, 'nyquist') & strcmpi(thisCharacteristicValueStr,'GainMargin') 
                     cellvalue = unitconv(cellvalue,'abs','dB'); %always convert to dB
                elseif strcmpi(plotType, 'sigma') & strcmpi(thisCharacteristicValueStr,'PeakGain')...
                        & strcmpi(h.axesgrid.Yunits,'dB')
                    cellvalue = unitconv(cellvalue,'abs','dB');
                end
                
                assignin('base', varnm, cellvalue); 

                try
                   thisout = evalin('base', editStr);
                catch
                   newlines = sprintf('\n\n');
                   errmsg=strrep(lasterr, varnm, '$');
                   warndlg(['Error while evaluating ', ...
                         boundName{str2num(tempStr(end))}(1:end-5), ...
                         ' constraint.. no selection was applied.', ...
                         newlines errmsg], ... 
                      'Model Selector Warning');
                   errflag = 1;
                   thisout = logical(ones(dimInfo));
                end % t ry/catch
                evalin('base', ['clear ' varnm]);
	
                % use ALL to squash down IO dimensions.. some
                % may have been squashed by indexing already
                %
                while prod(size(thisout)) > prod(dimInfo)
                   thisout=shiftdim(all(thisout,1),1);
                end
                
                % reshape to recover from $(:) type operations
                %
                if prod(size(thisout)) == prod(dimInfo)
                   thisout = reshape(thisout,dimInfo);
                else         
                   newline = sprintf('\n');
                   warndlg(['Error while evaluating ',...
                            boundName{str2num(tempStr(end))}(1:end-5),...
                            ' constraint.. no selection was applied.' newline,... 
                        'Size of expression does not match array dimensions.'], ...
                            'Model Selector Warning');
                   errflag = 1;
                   thisout = logical(ones(dimInfo));
                end % if/else prod(size...
             end % if/else isempty(hasDollar)
            end % if/else ~isempty(errmsg)
          %----
           end % if ~strcmp(delank
          else
           warnStr = ' Stability margins are not calculated for FRD''s.';
    end %if noCharExists
 end % if get(checkHndl(i)
   out=out&thisout;
end % for i

% TEMPORARY CODE
if ~errflag
   numvis = sum(out(:));
   statusHndl=findobj(figNumber, 'Tag', 'status');
   %---Set status string based on SystemVisibility
   switch info.obj.responses(arrayvalue).visible
   case 'on', 
      set(statusHndl, 'String', sprintf('Selection resulted in %d visible model(s).%s',numvis, warnStr));
   case 'off',
      set(statusHndl,'String', ...
         {sprintf('To view the %d selected model(s), check the system''s name ',numvis); ...
         'in the response axes'' right-click menu. '});
   end % switch SystemVisibility
end
% END TEMPORARY CODE


function localsetallVisible(figNumber, flag)

info = rwInfo1(figNumber);
h = info.obj;
listHndl=findobj(figNumber, 'Style', 'listbox');
shiftlHndl=findobj(figNumber, 'Tag', 'shiftleft');
shiftrHndl=findobj(figNumber, 'Tag', 'shiftright');
editHndl=findobj(figNumber, 'Style', 'edit');
checkHndl=findobj(figNumber, 'Style', 'checkbox');
showHndl=findobj(figNumber, 'Tag', 'showpopup');
for i=1:length(listHndl)-1
   textHndl(i)=findobj(figNumber, 'Tag', ['dimlabel' num2str(i)]);
   editHndl1(i)=findobj(figNumber, 'Tag', ['constrain' num2str(i)]);
   listHndl1(i)=findobj(figNumber, 'Tag', ['dim' num2str(i)]);       
end
if flag == 1
   visibility = 'on';
   visibility1='off';
else
   visibility = 'off';
   visibility1='on';
end
set(showHndl,  'Visible', visibility);
listTag=get(listHndl,'Tag');
firstpos=get(listHndl1(1), 'position');
for i=2:length(listHndl1)
   beginpos=get(listHndl1(i), 'position');
   if beginpos(1)~=firstpos(1)
      begin=i-1;
      break;
   end
end
for i=1:length(listHndl1)
   if i>=begin & i < begin+3
      thisvisible=visibility;
   else
      thisvisible='off';
   end
   set(listHndl1(i), 'Visible', thisvisible);
   set(editHndl1(i), 'Visible', thisvisible);
   set(textHndl(i), 'Visible', thisvisible);
   
end



  %revisit, use @respplot to determine the mag phase units

magStr = '';
phaseStr = '';
RespObj=info.obj;

plotType = RespObj.Tag;
%******************************************************************************

CharStr{1} = xlate('Steady State');
CharStr{2} = xlate('Rise Time (sec)');
CharStr{3} = xlate('Settling Time (sec)');
CharStr{4} = sprintf('Peak Response%s',xlate(magStr));



switch plotType
case 'impulse'
	NumActive = [3 4];
case 'step'
    NumActive = [1 2 3 4];
case 'sigma'
    if strcmpi(h.axesgrid.Yunits,'dB')
        magStr = ' (dB)';
    end
    NumActive = [4];
    CharStr{4} = sprintf('Peak Response%s',xlate(magStr));
case 'initial'
	NumActive = [4];
case 'bode'
    if strcmpi(h.axesgrid.Yunits(1),'dB')
        magStr = ' (dB)';
    end
    if strcmpi(h.axesgrid.Yunits(2),'rad')
        phaseStr = ' (rad)';
    elseif strcmpi(h.axesgrid.Yunits(2),'deg')
        phaseStr = ' (deg)';
    end
    %magStr = ' (dB)';
    CharStr{4} = sprintf('Peak Response%s',xlate(magStr));
    NumActive = [4];
    if prod(RespObj.axesgrid.size) == 2 %all SISO systems
		NumActive = [2 3 4];		
        CharStr{3} = sprintf('Gain Margin%s',xlate(magStr));
        CharStr{2} = sprintf('Phase Margin%s',xlate(phaseStr));
    end  
case 'nichols'
    magStr = ' (dB)'; %Nichols Y is always DB
    phaseStr = ' (deg)';
    if strcmpi(h.axesgrid.Xunits,'rad')
        phaseStr = ' (rad)';
    end
    NumActive = [];
    CharStr{4} = '';
    if prod(RespObj.axesgrid.size) == 1 %all SISO systems
		NumActive = [3 4];		
        CharStr{4} = sprintf('Gain Margin%s',xlate(magStr));
        CharStr{3} = sprintf('Phase Margin%s',xlate(phaseStr));
    end
case 'nyquist'
    phaseStr = ' (deg)'; %Nyq is always abs and deg
    magStr = ' (dB)';
    NumActive = [];
    CharStr{4} = '';
    if prod(RespObj.axesgrid.size) == 1 %all SISO systems
		NumActive = [3 4];		
        CharStr{4} = sprintf('Gain Margin%s',xlate(magStr));
        CharStr{3} = sprintf('Phase Margin%s',xlate(phaseStr));
    end  
otherwise
    NumActive=[];
    CharStr{4} = '';
end
%******************************************************************************

% reset check box's string

parentH =info.obj.axesgrid.parent; %@respplot figure

%checkbox
set(checkHndl,'visible','off');

for i=NumActive
  set(checkHndl(i), 'Visible', visibility1);
end

%---Reset string of Peak Response Characteristic
for i=1:length(CharStr)
	set(checkHndl(i), 'String', CharStr{i});
end
%edit
editTag=get(editHndl,'Tag');
editCritInd = strmatch('cri',editTag);
editHndl=editHndl(editCritInd);
set(editHndl,'visible','off')
for i=NumActive
   set(editHndl(i), 'Visible', visibility1);
end

%shift button
if length(listHndl)<5
   visibility='off';
end
set(shiftlHndl, 'Visible', visibility);
set(shiftrHndl, 'Visible', visibility);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalArrayIndexingParser %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s1,errmsg]=LocalArrayIndexingParser(s0)
% $ is a placeholder for an ND array
% Fix indexing to work like LTI arrays, in which
% the first two dimensions are special.  Specifically:
%
%  1. $(1,2,:) is fine as it is.
%  2. $(1,2)   is mapped to       $(1,2,:)
%  3. $(1)     is an error.
%  4. $        is mapped to       $(:,:,:)
%
% Greg

s0 = [s0 ' '];

% Handle case 4. first
ix = findstr(s0,'$');
for k=length(ix):-1:1
  if s0(ix(k)+1) ~= '('
    s0 = [s0(1:ix(k)) '(:,:,:)' s0(ix(k)+1:end)];
  end
end 

s1 = s0;
ix = findstr(s0,'$(');
errmsg = [];

if ~isempty(ix)
  jx = findstr(s0,'(');
  kx = findstr(s0,')');
  if length(jx) ~= length(kx)
    errmsg = 'Mismatched parentheses.';
    return
  end
  for n=length(ix):-1:1			% work backwards..
    bp = ix(n);				% start of $(
    ep = min(kx(kx>bp));		% first closing )
    innerp = findstr(s0(bp+2:ep),'(');
    while ~isempty(innerp)		% find the right closing )
      s0(bp+1+max(innerp):ep) = 32;	% don't be fooled by commas in between
      ep = min(kx(kx>ep));
      innerp = findstr(s0(bp+2:ep),'(');
    end
    lx = findstr(s0,',');
    cl = lx(lx>bp & lx<ep);		% all commas in between
    switch length(cl)
    case 0
      errmsg='Use multiple indexing for MIMO models or LTI arrays, as in $(i,j).'; 
    case 1
      s1 = [s1(1:ep-1) ',:' s1(ep:end)];	% add the colon
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function localsetallEnable(figNumber, dimInfo, flag)
statusHndl=findobj(figNumber, 'Tag', 'status');
if flag == 1
   thisenable = 'off';
   %set(statusHndl, 'String', 'Show all plots');
else
   thisenable = 'on';
   if flag == 2
      set(statusHndl, 'String', 'Show selected plot(s)');
   else
      set(statusHndl, 'String', 'Show unselected plot(s)');
   end
end
listlength=size(dimInfo, 2);
for i=1:listlength
   listHndl = findobj(figNumber, 'Tag', ['dim' num2str(i)]);
   textHndl = findobj(figNumber, 'Tag', ['constrain' num2str(i)]);
   labelHndl= findobj(figNumber, 'Tag', ['dimlabel' num2str(i)]);
   Hndl = [listHndl, textHndl, labelHndl];
   set(Hndl, 'Enable', thisenable);
end
sellabelHndl = findobj(figNumber, 'Tag', 'criterion');
if listlength > 3
   if flag == 1
      shiftHndl = findobj(figNumber, 'Tag', 'shiftleft');
      set(shiftHndl, 'Enable', thisenable);
      shiftHndl = findobj(figNumber, 'Tag', 'shiftright');
      set(shiftHndl, 'Enable', thisenable);
   else
      listHndl = findobj(figNumber, 'Tag', ['dim' num2str(4)]);
      visibility = get(listHndl, 'Visible');
      if strcmp(visibility, 'on')
         shiftHndl = findobj(figNumber, 'Tag', 'shiftright');
         set(shiftHndl, 'Enable', 'on');
      end
      % to check whether the last one is visible to set left shift button
      listHndl = findobj(figNumber, 'Tag', ['dim' num2str(listlength)]);
      visibility = get(listHndl, 'Visible');
      shiftHndl = findobj(figNumber, 'Tag', 'shiftleft');
      if strcmp(visibility, 'off')
         set(shiftHndl, 'Enable', 'on');
      else
         set(shiftHndl, 'Enable', 'off');
      end
   end 
end
info = rwInfo1(figNumber);
arrayHndl=findobj(figNumber, 'Tag', 'Array');
arrayIndex=get(arrayHndl, 'value');
consActiveAll=info.consActive;
consEditAll=info.consInfo;
consActive=consActiveAll{arrayIndex};
if isempty(arrayIndex)
  consEdit = [];
else  
  consEdit=consEditAll{arrayIndex};
end
for i=1:length(consEdit);
   checkHndl=findobj(figNumber, 'Tag', ['critecheck' num2str(i)]);
   editHndl=findobj(figNumber, 'Tag', ['criteedit' num2str(i)]);
   if ~isempty(checkHndl)
      set(checkHndl, 'Value', consActive(i));
      if isempty(consEdit)
         set(editHndl, 'String', '');
      else
         set(editHndl, 'String', consEdit{i});
      end
      if consActive(i)==1
         set(editHndl, 'Enable', 'on');
      else
         set(editHndl, 'Enable', 'off');
      end
   else
      break;
   end
end

function localArray(eventSrc, eventData,h,varargin)

if isempty(varargin)
   figNumber=gcbf;
else 
   figNumber=varargin{1};
end
thispopup=findobj(figNumber, 'Tag', 'Array');
newvalue=get(thispopup, 'value');
showHndl=findobj(figNumber, 'Tag', 'showpopup');
info = rwInfo1(figNumber);
selected=info.selected;
selarray=info.selarray;
actived=info.actived;
arrayIndex=info.arrayIndex;
consInfo=info.consInfo;
consActiveAll=info.consActive;
consActive=consActiveAll{newvalue};
if selected(newvalue)~=1 & length(selarray)>=newvalue
  oldsel=selarray{newvalue};
else
  oldsel =  [];
end  


h=info.obj;
for k=1:length(arrayIndex)
   views=get(h.responses(arrayIndex(k)),'view');
   s=size(h.responses(arrayIndex(k)).datasrc.Model);
   if length(s)>=3
      newy{arrayIndex(k)}=reshape(strcmpi(get(views,'Visible'),'on'),s(3:end));
   else
      newy{arrayIndex(k)}=strcmpi(get(views,'Visible'),'on');
   end
   %newy{k}=strcmpi(get(views,'visible'),'on');
end


dimInfoIndex = newy{arrayIndex(newvalue)};
diminfo=size(dimInfoIndex);
% delete old listboxes

listHndl = findobj(figNumber, 'style', 'listbox');
k=1;
for i=1:length(listHndl)
  tag=get(listHndl(i), 'Tag');
  if strcmp(tag(1:3), 'dim')
     delete(listHndl(i));
     % count how may of them are there
     k=k+1;  
  end
end
for i=1:k-1;
  labelHndl=findobj(figNumber, 'Tag', ['dimlabel' num2str(i)]);
  delete(labelHndl);
  labelHndl=findobj(figNumber, 'Tag', ['constrain' num2str(i)]);
  delete(labelHndl);
end

thisselarray=localAddrulemake(figNumber,diminfo, 1, oldsel);
selarray{newvalue}=thisselarray;
info.selarray=selarray;
rwInfo1(figNumber, info);

%turn off right arrow
shiftHndr = findobj(figNumber, 'Tag', 'shiftright');
set(shiftHndr, 'Enable', 'off');


if size(diminfo,2)>3
  shiftHndl=findobj(figNumber, 'Tag', 'shiftleft');
  set(shiftHndl, 'Enable', 'on');
end


set(showHndl, 'Value', selected(newvalue));
localsetallEnable(figNumber, diminfo, selected(newvalue));
crtHndl=findobj(figNumber, 'Tag', 'criterion');
crtValue=get(crtHndl, 'Value');
str=get(crtHndl, 'String');      
thisStr=str{crtValue};
%set contrains
ConsStr=consInfo{newvalue};
%if ~isempty(ConsStr)
  for i=1:4, %length(fieldnames(u.PlotOptions))-1
     editHndl=findobj(figNumber, 'Tag', ['criteedit' num2str(i)]);
     checkHndl=findobj(figNumber, 'Tag', ['critecheck' num2str(i)]);
     if ~isempty(ConsStr) & i<=length(ConsStr)
        str=ConsStr{i};
     else
        str='';
     end
     set(editHndl, 'String', str);
     if consActive(i)==1
        set(editHndl, 'Enable', 'on');
     else
        set(editHndl, 'Enable', 'off');
     end
     set(checkHndl, 'Value', consActive(i));
  end      
%end
localsetallVisible(figNumber, crtValue);  

function localShiftLeft(eventSrc, eventData)

figNumber=gcbf;
dataInfo = rwInfo1(figNumber);
arrayHndl=findobj(gcbf, 'Tag', 'Array');
arrayIndex=get(arrayHndl, 'value');
dimInfo=dataInfo.dimInfo;
dimLenght=size(dimInfo{arrayIndex}, 2);
for i=dimLenght:-1:3    % i should be > 3 for shift to be active
  rightHndl=findobj(gcbf, 'Tag', ['dim' num2str(i)]);
  visibility = get(rightHndl, 'Visible');
  if strcmp(visibility, 'on')
     break;
  end 
end
lastone=i+1;
rightHndl=findobj(gcbf, 'Tag', ['dim' num2str(lastone)]);
righttextHndl=findobj(gcbf, 'Tag', ['constrain', num2str(lastone)]);
rightlabelHndl=findobj(gcbf, 'Tag', ['dimlabel', num2str(lastone)]);
set(rightHndl, 'Unit', 'normal', 'Visible', 'on', 'Enable', 'on');
set(righttextHndl, 'Unit', 'normal', 'Visible', 'on', 'Enable', 'on');
set(rightlabelHndl, 'Unit', 'normal', 'Visible', 'on', 'Enable', 'on');
if lastone == dimLenght
  lshiftHndl=findobj(gcbf, 'Tag', 'shiftleft');
  set(lshiftHndl, 'Enable', 'off');
end

for i=lastone-1:-1:1
  Hndl=findobj(gcbf, 'Tag', ['dim' num2str(i)]);
  textHndl=findobj(gcbf, 'Tag', ['constrain', num2str(i)]);
  labelHndl=findobj(gcbf, 'Tag', ['dimlabel', num2str(i)]);
  set(Hndl, 'Unit', 'normal');
  set(textHndl, 'Unit', 'normal');
  set(labelHndl, 'Unit', 'normal');
  pos=get(Hndl, 'Position');
  poslabel=get(labelHndl, 'Position');
  postext=get(textHndl, 'Position');
  set(rightHndl, 'Position', pos);
  set(righttextHndl, 'Position', postext);
  set(rightlabelHndl, 'Position', poslabel);
  rightHndl=Hndl;
  righttextHndl=textHndl;
  rightlabelHndl=labelHndl;
end
rshiftHndl=findobj(gcbf, 'Tag', 'shiftright');
set(rshiftHndl, 'Enable', 'on');



function localClearEdit(eventSrc, eventData)

figNumber=gcbf;
thislist=gcbo;
tag=get(thislist, 'Tag');
tagNum=str2num(tag(4:end));
ebox=findobj(figNumber, 'Tag', ['constrain' num2str(tagNum)]);
set(ebox, 'String', []);

function localConstrain(eventSrc, eventData)

figNumber=gcbf;
thisedit=gcbo;
str=get(thisedit, 'String');
tag=get(thisedit, 'Tag');
tagNum=str2num(tag(10:end));
list=findobj(figNumber, 'Tag', ['dim' num2str(tagNum)]);

try
  if isempty(str)
     selvalue= get(list,'Value');     % do nothing..
  else
     selvalue=evalin('base',str);
     if islogical(selvalue)
        ix=1:length(get(list,'String'));
        selvalue = ix(selvalue);
     end
  end
catch
  warndlg('Please enter a valid MATLAB expression for range', ...
     'Model Selector Warning');
  selvalue = 1:length(get(list,'String'));
end

maxvalue=max(selvalue);
minvalue=min(selvalue);
if maxvalue>length(get(list, 'String'))|minvalue<1
  selvalue = 1:length(get(list,'String'));
  warndlg(['Values must be between 1 and '...
        num2str(length(get(list, 'String')))], ...
     'Model Selector Warning');
end
set(list, 'Value', selvalue);

function localCriterion(eventSrc, eventData)

figNumber=gcbf;
thisHndl=findobj(figNumber, 'Tag', 'criterion');
value=get(thisHndl, 'Value');
str=get(thisHndl, 'String');      
localsetallVisible(figNumber, value);  
statueHndl=findobj(figNumber, 'Tag', 'status');
if value==2
  set(statueHndl, 'String', [sprintf('Enter a MATLAB expression using ''$'' to refer to the '), ...
        sprintf('variable of  interest (steady-state, rise time, ...). For example: $>2 & $ <5.'),...
        sprintf(' See help for more examples.')]);
else
  set(statueHndl, 'String', 'Show selected plot(s)');
end


function localShow(eventSrc, eventData)

figNumber=gcbf;
thispopup=gcbo;
info = rwInfo1(figNumber);
arrayIndex=info.arrayIndex;

h=info.obj;
for k=1:length(arrayIndex)
    
   views=get(h.responses(arrayIndex(k)),'view');
   s=size(h.responses(arrayIndex(k)).datasrc.Model);
   if length(s)>=3
      newy{arrayIndex(k)}=reshape(strcmpi(get(views,'Visible'),'on'),s(3:end));
   else
      newy{arrayIndex(k)}=strcmpi(get(views,'Visible'),'on');
   end
    
    
%    views=get(h.responses(arrayIndex(k)),'view');
%    newy{k}=strcmpi(get(views,'visible'),'on');
end

arrayHndl=findobj(figNumber, 'Tag', 'Array');
arrayvalue=get(arrayHndl, 'Value');
dimInfoIndex = newy{arrayIndex(arrayvalue)};
diminfo=size(dimInfoIndex);
thisvalue=get(thispopup, 'Value');
localsetallEnable(figNumber, diminfo, thisvalue);

%---Store the new popupmenu value
info.selected(arrayvalue) = thisvalue;
rwInfo1(figNumber, info);



function localGetSelection(eventSrc, eventData, varargin)
      
figNumber=gcbf; 
if nargin==3
    set(gcbf, 'Visible', varargin{1});
end
    
    
showHndl=findobj(figNumber, 'Tag', 'showpopup');
arrayHndl=findobj(figNumber, 'Tag', 'Array'); %selects systems
info = rwInfo1(figNumber);
selected=info.selected;
actived = info.actived;
arrayIndex=info.arrayIndex;
selarray=info.selarray;
arrayvalue=get(arrayHndl, 'value');

h=info.obj;
for k=1:length(arrayIndex)
   views=get(h.responses(arrayIndex(k)),'view');
   s=size(h.responses(arrayIndex(k)).datasrc.Model);
   if length(s)>=3
      newy{arrayIndex(k)}=reshape(strcmpi(get(views,'Visible'),'on'),s(3:end));
   else
      newy{arrayIndex(k)}=strcmpi(get(views,'Visible'),'on');
   end
end
dimInfoIndex = newy{arrayIndex(arrayvalue)};
diminfo=size(dimInfoIndex);
showvalue=get(showHndl, 'Value');

%dimInfo provides info on the number of subsystems within the selected system

[y, array]=localgetselection(figNumber, diminfo, arrayIndex(arrayvalue));

selarray{arrayvalue}=array;
arrayIndex=info.arrayIndex;
yCol=reshape(y,[prod(size(y)) 1]);
y=yCol;

for k=1:length(h.responses(arrayIndex(arrayvalue)).view)
   if k<=length(y) & y(k)==1
      h.responses(arrayIndex(arrayvalue)).view(k).Visible = 'on';
      c=h.responses(arrayIndex(arrayvalue)).characteristics;
      for i=1:length(c)
          if strcmpi(c(i).Visible,'on') %new-x
               c(i).View(k).Visible = 'on';
          end
      end
  else
      h.responses(arrayIndex(arrayvalue)).view(k).Visible = 'off';
      c=h.responses(arrayIndex(arrayvalue)).characteristics;
      for i=1:length(c)
          if strcmpi(c(i).Visible,'on') %new-x
              c(i).View(k).Visible = 'off';
          end
      end    
  end
end    
h.draw;

%update selected infomation
selected(arrayvalue)=showvalue;
info.selected=selected;
info.selarray=selarray;

%save constrain
consInfo=info.consInfo;
consStr{1}='';
for i=1:4 %length(fieldnames(u.PlotOptions))-1 %one item for each characteristic
  name=['criteedit' num2str(i)];
  editHndl=findobj(figNumber, 'Tag', name);
  consStr{i}=get(editHndl, 'String');
end
consInfo{arrayvalue}=consStr;
info.consInfo=consInfo;
rwInfo1(figNumber, info);


function localCheck(eventSrc,eventData)

figNumber=gcbf; 
chkHndl=gcbo;
info = rwInfo1(figNumber);

thisTag=get(chkHndl, 'Tag');
arrayHndl=findobj(figNumber, 'Tag', 'Array');
value=get(arrayHndl, 'Value');
consActiveAll=info.consActive;
consActive=consActiveAll{value};
numstr=thisTag(end);
editHndl=findobj(gcbf, 'Tag', ['criteedit', numstr]);
checkvalue=get(chkHndl, 'Value');
if checkvalue==1
  set(editHndl, 'Enable', 'on');
else
  set(editHndl, 'Enable', 'off');
end
consActive(str2num(numstr))=checkvalue;
consActiveAll{value}=consActive;
info.consActive=consActiveAll;
rwInfo1(figNumber, info);
statusHndl=findobj(figNumber, 'Tag', 'status');
set(statusHndl, 'String', [sprintf('Enter a MATLAB expression using ''$'' to refer to the'), ...
     sprintf('variable of  interest (steady-state, rise time, ...). Example: $>2 & $ <5.'), ...
  sprintf('See Help for more examples.')]);



function localRefresh(figNumber)


if ~isempty(figNumber)
  localUpdata(figNumber, h);
  localArray([],[],h);
end

function localDeleteCallback(eventSrc,eventData)

figNumber=gcbf; 


if ~isempty(figNumber)
  localDelete(figNumber, RespObj, updataIndex);
end


function localSetArraySelVisible(eventSrc, eventData, figNumber)

%toggle array selector visibility
set(figNumber,'visible','on');

function LocalDeleteResp(eventSrc, eventData, fig)

infoData = get(fig,'userdata');
arrayCombo = findobj(fig,'tag','Array');
arrayComboValue = get(arrayCombo,'Value'); %current combo box value
deletedResps = find(eventSrc == infoData.obj.responses); %deleted reponse positions
[junk,I] = intersect(infoData.arrayIndex, deletedResps); %I are the positions of deleted resps in the combo

if ~isempty(I) %a multi-dimensional system response has been deleted
	if any(arrayComboValue == I) %the currently selected has been deleted
        undeletedArrayVals = setdiff(1:length(infoData.arrayIndex),I);
        if ~isempty(undeletedArrayVals) %if one or more displayed resps are not deleted show them propr to closing
            set(arrayCombo,'Value',min(undeletedArrayVals));
        end
	end   
	delete(fig); %close    
else %re-index infoData
    IarrayIndex = zeros(1,infoData.arrayIndex(end));
    IarrayIndex(infoData.arrayIndex) = 1;
    IarrayIndex(deletedResps) = [];
    infoData.arrayIndex = find(IarrayIndex);
    set(fig,'userdata',infoData);
end

function LocalDeleteFigure(eventSrc, eventData, fig)

delete(fig);

function info1=rwInfo1(figNum, varargin)

if length(varargin)==1 %this is a write
    info=varargin{1};
    set(figNum, 'UserData', info);
    info1=[];
else %this is a read
    info1 = get(figNum, 'UserData');
end

function localShiftRight(eventSrc, eventData)

figNumber=gcbf;
dataInfo = rwInfo1(figNumber);
arrayHndl=findobj(gcbf, 'Tag', 'Array');
arrayindex=get(arrayHndl, 'value');
dimInfo=dataInfo.dimInfo;
dimLength=size(dimInfo{arrayindex}, 2);
for i=dimLength:-1:4    % i should be > 3 for shift to be active
  rightHndl=findobj(gcbf, 'Tag', ['dim' num2str(i)]);
  visibility = get(rightHndl, 'Visible');
  if strcmp(visibility, 'on')
     lastone=i;
     break;
  end 
end
righttextHndl=findobj(gcbf, 'Tag', ['constrain', num2str(lastone)]);
rightlabelHndl=findobj(gcbf, 'Tag', ['dimlabel', num2str(lastone)]);
set(rightHndl, 'Unit', 'normal');
set(righttextHndl, 'Unit', 'normal');
set(rightlabelHndl, 'Unit', 'normal');
set(rightHndl, 'Visible', 'off', 'Enable', 'off');
set(righttextHndl, 'Visible', 'off', 'Enable', 'off');
set(rightlabelHndl, 'Visible', 'off', 'Enable', 'off');
lshiftHndl=findobj(gcbf, 'Tag', 'shiftleft');
set(lshiftHndl, 'Enable', 'on');
if lastone==4
  rshiftHndl=findobj(gcbf, 'Tag', 'shiftright');
  set(rshiftHndl, 'Enable', 'off');
end
pos=get(rightHndl, 'Position');
poslabel=get(rightlabelHndl, 'Position');
postext=get(righttextHndl, 'Position');

for i=lastone-1:-1:lastone-2   % i should be > 3 for shift to be active
  Hndl=findobj(gcbf, 'Tag', ['dim' num2str(i)]);
  textHndl=findobj(gcbf, 'Tag', ['constrain', num2str(i)]);
  labelHndl=findobj(gcbf, 'Tag', ['dimlabel', num2str(i)]);
  set(Hndl, 'Unit', 'normal');
  set(textHndl, 'Unit', 'normal');
  set(labelHndl, 'Unit', 'normal');
  thispos=get(Hndl, 'Position');
  thisposlabel=get(labelHndl, 'Position');
  thispostext=get(textHndl, 'Position');
  set(Hndl, 'Position', pos, 'Visible', 'on');
  set(textHndl, 'Position', postext, 'Visible', 'on');
  set(labelHndl, 'Position', poslabel, 'Visible', 'on');
  pos=thispos;
  postext=thispostext;
  poslabel=thisposlabel;
end
Hndl=findobj(gcbf, 'Tag', ['dim' num2str(lastone-3)]);
textHndl=findobj(gcbf, 'Tag', ['constrain', num2str(lastone-3)]);
labelHndl=findobj(gcbf, 'Tag', ['dimlabel', num2str(lastone-3)]);
set(Hndl, 'Visible', 'on');
set(textHndl,'Visible', 'on');
set(labelHndl,'Visible', 'on');
