function varargout = jpropeditutils(action,varargin) 
%JPROPEDITUTILS   a utility function for PropertyEditor.java 
%   JPROPEDITUTILS is a switchyard containing many different 
%   sub-functions. 
% 
%   'jinit'=============================== 
% 
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH]=JPROPEDITUTILS('jinit',H) 
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH]=JPROPEDITUTILS('jinit',H,PROPNAMES) 
% 
%   Calls jget , jset, and jpath, gets their return arguments, 
%   and returns everything in one call.j 
% 
%   Rather than trying to reconcile property names if the list of 
%   properties from get() and set() are different, JPROPEDITUTILS 
%   simply returns both sets of property names. 
% 
%   'jget'================================ 
%
%   [FIELDS,VALUES,ISMULTIPLE]=JPROPEDITUTILS('jget',H) 
%   [FIELDS,VALUES,ISMULTIPLE]=JPROPEDITUTILS('jget',H,PROPNAMES) 
% 
%   Where H is a 1xM array of HG handles 
%   Where PROPNAMES is a property name string or a 
%        1xN cell array of property names 
%        If PROPNAMES is omitted, JGET will get all 
%        property names 
%   Where FIELDS is a 1xN cell array of property names 
%   Where VALUES is a 1xN cell array of property values 
%        If H is longer than 1, each element is a 1xM 
%        cell array of values 
% 
%   'jset'================================ 
% 
%   [FIELDS,OPTION,ISMULTIPLE]=JPROPEDITUTILS('jset',H) 
%   [FIELDS,OPTION,ISMULTIPLE]=JPROPEDITUTILS('jset',H,PROPNAMES) 
% 
%   Where H is a 1xM array of HG handles 
%   Where PROPNAMES is a property name string or a 
%        1xN cell array of property names 
%        If PROPNAMES is omitted, JGET will get all 
%        property names 
%   Where FIELDS is a 1xN cell array of property names 
%   Where OPTION is a 1xN cell array of property enumerated 
%        option values. 
% 
%   'jpath'================================ j
% 
%   PATH = JPROPEDITUTILS('jpath',H) 
%  
%   H is a single handle or vector of handles to HG objects. 
%   If the types in H are mixed, the returned path will be 
%   '!MIXED'.  Otherwise, PATH will be a cell array containing 
%   the relative path to the object type's m file. 
%   (note that the path uses '.' instead of file separators and 
%    that the returned path contains a period at the beginning and 
%    end of the path) 
% 
%    If the path to the object can not be found, the function 
%    will return the following: 
% 
%    .toolbox.matlab.graphics. 
% 
%   'jhelp'================================ 
% 
%   MSG = JPROPEDITUTILS('jhelp',H) 
%   MSG = JPROPEDITUTILS('jhelp',TYPE) 
% 
%   H    is a handle to an object or a vector of handles to the same 
%   object type. 
%   TYPE is a string with an object type. 
%   MSG  is a status message 
% 
%   'jselect'================================ 
% 
%   MSG = JPROPEDITUTILS('jselect',H) 
% 
%   'japplyexpopts'=============================== 
% 
%   JPROPEDITUTILS('japplyexpopts',H) 
% 
%   H  is a vector of handles to figures 
% 
%   Saves current properties in appdata and Sets new ones.
%    
%   'jrestorefig'=============================== 
% 
%   JPROPEDITUTILS('jrestorefig',H) 
% 
%   H  is a vector of handles to figures 
% 
%   Restores properties that were set before japplyexopt function was called. 
% 
%   'jmeshcolor' ==================================== 
% 
%   C = JPROPEDITUTILS('jmeshcolor',H) 
% 
%   H is a handle to a surface or a patch object 
%   C is the FaceColor for the handle necessary to make the object appear 
%     as a hidden-line mesh 
% 
%   If H is a single object, C will be a number triple.  If H is a vector, 
%   C will be a cell array of colors. 
% 
%   In the event that the parent axis is visible "off" and the figure is  
%   color "none", the returned face color will be white [1 1 1] 
% 
%  'jinstrument' =================================== 
% 
%  H = JPROPEDITUTILS('jinstrument',H) 
% 
%  Adds listeners to the handles in H.  Returns a list of handles which had 
%  listeners added.  (Note: listeners are only added once.) 
% 


%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.53.4.8 $  $Date: 2004/04/10 23:33:58 $ 

%[varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end

% actions are prefaced by j to avoid conflict 
% with built-in functions. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function out=jinit_obsolete(varargin) 

jgetOut = jget(varargin{:}); 
jsetOut = jset(varargin{:}); 
jpathOut= jpath(varargin{1}); 

out=[jgetOut(1:2),jsetOut,jpathOut]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [fields,values,multiples]=jget(h,propFields)

%filter for bad handles and create a handle object
h=handle(h(ishandle(h)));

if nargin>1 
    %here we handle the provided propValue case 
    if ~iscell(propFields) 
        %here we handle the single-value string case 
        fields={propFields}; 
        values={get(h,propFields)}; 
    else
        %here we handle the multiple-value cell array 
        %propNames case 
        fields=propFields(:); 
        allValues = get(h,propFields); 
        if (length(h)>1 & length(propFields)>1)  
            for i=size(allValues,2):-1:1 
                values{i,1}=allValues(:,i);             
            end 
        else 
            values=allValues(:); 
        end 
    end 
elseif length(h)==1 
    [fields,values]=loc_get_same_type(h); 
else
    [uniqTypes,uniqTypeIndexA,uniqTypeIndexB] = unique(get(h,'Type'));
    %if the handles are all of the same type, we can 
    %safely return all of the values. 
    if length(uniqTypes)==1 
        [fields,values]=loc_get_same_type(h); 
    else 
        [fields,values,multiples]=jget(h,LocGObjectProperties); 
        return; 
    end 
end 

%find all fieldnames which end in "data" 
dataFieldIndices=locReverseStrmatch('Data',fields); 
otherIndices=find(ismember(fields,{'Faces','Vertices'})); 
dataFieldIndices=[dataFieldIndices;otherIndices]; 

if length(h)==1 
    multiples = false(1,length(fields));  
    for i=1:length(dataFieldIndices) 
        values{dataFieldIndices(i)}=locArrayRef(values{dataFieldIndices(i)}); 
    end 
else 
    multiples = true(1,length(fields)); 
    for i=1:length(dataFieldIndices) 
        %assume that all "data" is numeric.  If the data is equal, just send 
        %the single value through as a non-multiple value.  If the values are 
        %not equal, just send them through as zero and one.  Note that this does 
        %NOT preserve the original values of the data, but the DataComboboxWidget 
        %(the usual recipient of this information) does not use the original data 
        %anyway. 
        idx=dataFieldIndices(i); 
        dataValues=values{idx}; 
        allEqual=true; 
        j=2; 
        while allEqual & j<=length(dataValues) 
            try
                allEqual=isequal(dataValues{1},dataValues{j}); 
            catch 
                allEqual=false; 
            end 
            j=j+1; 
        end 
        
        if allEqual 
            values{idx}=locArrayRef(dataValues{1}); 
            multiples(idx)=0; 
        else 
            values{idx}=num2cell(zeros(length(h),1)); 
            values{idx}{1}=1; 
        end 
    end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function gProps = LocGObjectProperties 

gProps = {'Children' 
    'Clipping' 
    'CreateFcn' 
    'DeleteFcn' 
    'BusyAction' 
    'HandleVisibility' 
    'HitTest' 
    'Interruptible' 
    'Parent' 
    'Selected'
    'SelectionHighlight' 
    'Tag' 
    'Type' 
    'Visible'}; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [fields,values] = loc_get_same_type(h) 
%we assume that the handles are all of the same type 

s=get(h); 

fields=fieldnames(s); 
if length(h)==1; 
    values = struct2cell(s); 
else 
    allValues = struct2cell(s); 
    for i=size(allValues,1):-1:1 
        values{i,1}=allValues(i,:);       
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [optionFields,optionValues,multiples]=jset(h,propFields) 

%filter for bad handles and create a handle object
h=handle(h(ishandle(h)));

uniqTypes=get(h,'Type'); 
if length(h)>1 
    [uniqTypes,uniqTypeIndexA,uniqTypeIndexB]=unique(uniqTypes); 
    h=h(1); 
elseif isempty(h) 
    optionFields={};
    optionValues={};
    multiples=[];
    return; 
else 
    uniqTypes={uniqTypes}; 
    uniqTypeIndexA=1; 
    uniqTypeIndexB=1; 
end 

if nargin>1 
    if ischar(propFields) 
        optionFields={propFields}; 
    else 
        optionFields = propFields; 
    end 
     
    for i=length(optionFields):-1:1 
        try 
            optionValues{i,1}=set(h,optionFields{i}); 
        catch 
            optionValues{i,1}={}; 
        end 
    end 
else 
    %if no property names were given 
    if length(uniqTypes)==1 
        setResult = set(h); 
        optionFields = fieldnames(setResult); 
        optionValues = struct2cell(setResult); 
        optionValues = optionValues(:); 
    else 
        [optionFields,optionValues,multiples]=jset(h,LocGObjectProperties); 
        return; 
    end
end 

multiples=zeros(1,length(optionFields)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function pName=jpath(h) 

pName = ''; 

for i=1:length(h) 
    hHandle = handle(h(i)); 

    oldStatus=dbstatus;
    dbclear if error;
    oldError=lasterr;
    
    try 
	        thisPath = hHandle.getPropertyEditorPanelPath; 
    catch 
        className=class(hHandle); 
        dotLoc = findstr(className,'.'); 
        if ~isempty(dotLoc) 
            className(dotLoc+1)=upper(className(dotLoc+1)); 
        else
            className(1)=upper(className(1));
            className=['hg.',className];
        end 
        thisPath = ['com.mathworks.page.propertyeditor.panels.' className 'PropEdit']; 
    end 

    
    if any(strcmp({oldStatus.cond},'error'))
        dbstop if error;
    end
    lasterr(oldError);
    
    if isempty(pName) 
        pName = thisPath; 
    elseif ~strcmp(pName,thisPath) 
        pName = 'com.mathworks.page.propertyeditor.panels.hg.MixedPropEdit'; 
        break; 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fig] = locGetFigure(target)
% Traverse up HG hierarchy to get figure

h = handle(target);
fig = [];
if ~ishandle(target)
  return;
end

while ~isempty(h) & ishandle(h)
  if isa(h,'hg.figure')
    fig = h;
    return;
  end
  
  h = up(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jsetproperties(h,varargin)
%JSETPROPERTIES makes sure that properties are set on a handle object

% TBD: Add undo/redo support here
set(handle(h),varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function out=jhelp_obsolete(h,propName) 
%OBSOLETE - remove before the release!

if ischar(h) 
    type = h; 
else 
    hIndices = ishandle(h); 
    if any(hIndices) 
        h=h(hIndices); 
        type = get(h(1),'type'); 
    else 
        out={'Can not get object type from handles'}; 
        return; 
    end 
end 

fileName = fullfile(docroot,'techdoc','infotool','hgprop',[type '_frame.html']); 

if exist(fileName)==2 
    helpview(fileName); 
    out=sprintf('Help for object type "%s" displayed in help browser',type); 
else 
    out=sprintf('Could not find help file for object type "%s".  Verify that your DOCROOT setting is correct.',type); 
    helpwin(type); 
end 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% called by the PropertyEditor when the user jumps from 
% one object to another from within the PropertyEditor. 
% Switches the current selection in the figure 
function status=jselect(h) 

status = 'Select succeeded';
fig = ancestor(h(1),'figure')
if ~plotedit(fig,'isactive')
    plotedit(fig,'on'); 
end
deselectall(fig);
for k=1:length(h)
    if (h(k) ~= 0), selectobject(h(k),'on'), end;
end

% for i=1:length(h) 
%     aObj = getorcreateobj(h(i)); 
%     if ~isempty(aObj) 
%         try 
%             fig = get(aObj,'Figure'); 
%              
% 			if ~plotedit(fig,'isactive') 
% 	            plotedit(fig,'on');   %make sure plot editing is enabled on parent figure 
%             end 
%             figObjH = getobj(fig); 
%             if i==1 
%                 deselectall(fig);
%                 % clear the selection for the first object 
%                 aObj = doselect(aObj, 'normal', figObjH,'down'); 
%             else 
%                 % add to the selection for subsequent objects 
%                 aObj = doselect(aObj, 'extend', figObjH,'down'); 
%             end 
%             % do we need to set the figure's ScribeCurrentObject? 
%             ud = getscribeobjectdata(h(i)); 
%             % write current changes 
%             ud.ObjectStore = aObj; 
%             setscribeobjectdata(h(i),ud); 
%         catch 
%             status = 'Select failed'; 
%             break; 
%         end 
%     else 
%         %if the object was not created properly 
%         if i==1 
%             set(findobj(0,'selected','on'),'selected','off');           
%         end 
%     end 
% end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Called by property editor panels which create previews 
% 
function pCData=jpreview(sourcePanel,figColor,figSize,setArgs) 


if nargin<1
    sourcePanel = 'com.mathworks.page.propertyeditor.propeditwidgets.LightingPropsGroup$MaterialPreview';
    figColor = [.8 .8 .8];
    figSize = [200 200];
    setArgs = {'visible','on'};
end


hFig = findall(0,'type','figure','tag',sourcePanel); 
if length(hFig)>0 
    hFig = hFig(1); 
else 
    hFig = figure('Visible','off',... 
        'Color',figColor,... 
        'HandleVisibility','off',... 
        'Units','pixels',... 
        'DoubleBuffer','on',...
        'Position',[-1000,-1000,figSize(1),figSize(2)],... 
        'IntegerHandle','off',... 
        'InvertHardcopy','off',... 
        'MenuBar','none',... 
        'Name','Java Preview',... 
        'NumberTitle','off',... 
        'PaperPositionMode','auto',... 
        'Resize','off',... 
        'Tag',sourcePanel); 
end 

targetObj = findobj(hFig,'tag','targetObject'); 
if (isempty(targetObj)) 
    switch sourcePanel 
    case 'com.mathworks.page.propertyeditor.propeditwidgets.LightingPropsGroup$MaterialPreview' 
        %openGL doesn't support phong, so we need this to be zbuffer 
        set(hFig,'renderer','zbuffer'); 
         
        ax = axes('Parent',hFig,... 
            'Units','normalized',... 
            'position',[-.1 -.1 1.3 1.3],... 
            'Visible','off',... 
            'DataAspectRatio',[1 1 1],... 
            'View',[-100,28]); 
         
        [x,y,z]=sphere(15); 
        i = [1:16]; 
        j = [1:14]; 
         
        targetObj=surface('XData',x(i,j),... 
            'Ydata',y(i,j),... 
            'Zdata',z(i,j),... 
            'CData',z(i,j),... 
            'facecolor',[1,0,0],... 
            'edgecolor',[0 0 0 ],... 
            'parent',ax,... 
            'linewidth',[2],... 
            'tag','targetObject'); 
         
        light('Parent',ax,'Position',[-2.9046 -13.8007 10.0551],'Style','infinite'); 
        light('Parent',ax,'Position',[-2.9046 -13.8007 10.0551],'Style','infinite'); 
        light('Parent',ax,'Position',[1.5,-.5,0],'Style','local'); 
         
    case 'com.mathworks.page.propertyeditor.panels.hg.RectangleDataGroup$RectDataPreview' 
        ax = axes('Parent',hFig,... 
            'Units','normalized',... 
            'position',[.05 .05 .9 .9],... 
            'Visible','off',... 
            'DataAspectRatio',[1 1 1]); 
         
        targetObj = rectangle('Position',[0 0 1 1],... 
            'Curvature',[0 0],... 
            'FaceColor','Blue',... 
            'EdgeColor','Black',... 
            'LineWidth',1.5,... 
            'Parent',ax,... 
            'Clipping','off',... 
            'Tag','targetObject'); 
    case 'com.mathworks.page.propertyeditor.panels.hg.RectanglePropEdit$RectStylePreview' 
        ax = axes('Parent',hFig,... 
            'Units','normalized',... 
            'position',[0 0 1 1],... 
            'Visible','off',... 
            'Xlim',[0 1],... 
            'Ylim',[0 1],... 
            'DataAspectRatio',[1 1 1]); 
         
        targetObj = rectangle('Position',[.1 .1 .8 .8],... 
            'Curvature',[.1 .1],... 
            'Parent',ax,... 
            'Clipping','off',... 
            'Tag','targetObject'); 
    case 'com.mathworks.page.propertyeditor.panels.hg.LinePropEdit$LineStylePreview' 
        ax = axes('Parent',hFig,... 
            'Units','normalized',... 
            'position',[0 0 1 1],... 
            'Visible','off',... 
            'Xlim',[-1 1],... 
            'Ylim',[0 1]); 
         
        targetObj = line('XData',[-5 0 5],... 
            'YData',[.5 .5 .5],... 
            'Parent',ax,... 
            'Clipping','off',... 
            'Tag','targetObject'); 
         
    case 'com.mathworks.page.propertyeditor.panels.hg.AxesPropEdit$AspectExample' 
        targetObj = axes('Parent',hFig,... 
            'Units','Normalized',... 
            'Position',[.15 .15 .8 .8],... 
            'Visible','on',... 
            'Box','on',... 
            'Tag','targetObject'); 
         
        [x,y,z]=sphere(12); 
        surfObj = surface('Xdata',x,... 
            'Ydata',y,... 
            'Zdata',z,... 
            'Cdata',z,... 
            'Parent',targetObj); 
         
    otherwise 
        targetObj = hFig; 
    end 
end 

setArgs{1}=targetObj; 
try 
    set(setArgs{:}); 
end 

%post-set operations 
switch sourcePanel 
case 'com.mathworks.page.propertyeditor.propeditwidgets.LightingPropsGroup$MaterialPreview' 
    %do nothing for now 
case 'com.mathworks.page.propertyeditor.toolbox.matlab.graphics.RectangleDataGroup$RectDataPreview' 
    objPos = get(targetObj,'Position'); 
    objAx = ancestor(targetObj,'axes'); 
    set(objAx,'Xlim',[objPos(1) objPos(1)+objPos(3)],... 
        'Ylim',[objPos(2) objPos(2)+objPos(4)]); 
case 'com.mathworks.page.propertyeditor.toolbox.matlab.graphics.AxesPropEdit$AspectExample' 
     
otherwise 
     
end 

pCData = system_dependent(45,hardcopy(hFig,'-dzbuffer','-r0'));

% JPEG file backup option
%
%	pCData = hardcopy(hFig,'-dzbuffer','-r0');
%	fName = [tempname,'.jpg'];
%	imwrite(pCData,fName,'jpg');
%	pCData=fName;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [hList,nList,currIndex]=jnames(h) 
%[handleList, nameList, listIndex]=jnames(handle) 
%  Builds an object browser list from the given handle. 
%  Shows one generation of children and all ancestors. 
%  handleList is a cell array of handles 
%  nameList   is a list of all display names for the object 
%  listIndex is a zero-based index showing the location of the original handle 
% 

if isa(h,'handle') 
    hDouble = double(h); 
    hHandle = h; 
else 
    hDouble = h; 
    hHandle = handle(h); 
end 

if length(hDouble)==0 
    hList={[];0}; 
    nList={'No Selection';'root: 0'}; 
    currIndex = 0; 
elseif length(hDouble)>1
    [hList,nList]=locDescription(hDouble,false); 
    currIndex = 0; 
    
    if length(unique(get(hDouble,'Type')))==1 
        %if the objects are all of the same type 
        %we definitely want to use "type" and not "class" here 

        [childHandles,childNames]=locDescription(locChildren(hHandle)); 
         
        hList=[hList;childHandles]; 
        nList=[nList;locIndent(childNames, 1)]; 
    end 
     
    hParent = get(hDouble,'Parent'); 
    parentHandle = unique([hParent{:}]); 
    while length(parentHandle)==1 
        [pHandle,pName]=locDescription(parentHandle); 
        hList=[pHandle;hList]; 
        nList=[pName;locIndent(nList, 1)]; 
        currIndex = currIndex+1; 
        parentHandle=get(parentHandle,'Parent'); 
    end 
else %if there is only one handle 
    % Get the figure containing the object 
    if (strcmp(get(hDouble, 'type'), 'figure')) 
        figHandle = hDouble; 
    else 
        parentHandle = ancestor(hHandle, 'figure'); 
        if ~isempty(parentHandle) & (parentHandle ~= 0)
            figHandle = parentHandle; 
        else 
            figHandle = []; 
        end 
    end 
     
    [hList,nList]=locDescription(0);  % Initialize list with root. 

    sibFigures = locChildren(0,'type','figure');
     
    if isempty(sibFigures) 
        sibFigures = figHandle; 
        myFigureIndex = 1; 
    elseif isempty(figHandle) 
        myFigureIndex = 1; 
        figHandle = sibFigures(myFigureIndex);
    else 
        myFigureIndex = find(sibFigures == figHandle); 
        if isempty(myFigureIndex) 
            %this happens if the current object's handle visibility is off 
            sibFigures=[figHandle;sibFigures]; 
            myFigureIndex = 1; 
        end 
    end 
     
    % Add the figures to the list. 
    [hfList,nfList]=locDescription(sibFigures); 
    nfList = locIndent(nfList, 1); 
    hList = [hList; hfList]; 
    nList = [nList; nfList]; 
    
    % This call recursively expands all the children from the 
    % passed in figure handle. 
    [chList, cnList] = locDescribeChildren(figHandle); 
    
    % Put it in the middle of the list where the figure is. 
    hList=[hList(1:myFigureIndex);chList;hList(myFigureIndex+2:end)]; 
    nList=[nList(1:myFigureIndex);cnList;nList(myFigureIndex+2:end)]; 
    
    % Find the index from the values returned from locDescribeChildren. 
    dhList=cat(1,hList{:}); 
    currIndex = find(dhList == hDouble) - 1; 
     
    if isempty(currIndex) 
     %the current object is probably handlevisibility off 
        %display only this object and the minimum number of parents 
        %necessary to link it to the rest of the object hierarchy 

        iHandList={}; 
        iNameList={}; 
        parentHandle = h; 
        insertIndex=[]; %the index under which the inserted handles will be inserted 
        while isempty(insertIndex) 
            [tHand,tName]=locDescription(parentHandle); 
            iHandList=[tHand;iHandList]; 
            iNameList=locIndent([tName;iNameList],1); 
            parentHandle = get(parentHandle,'parent'); 
            insertIndex = find(dhList == parentHandle); 
            %if nothing else, this should find the parent figure 
        end 
         
        %need to find out how many spaces the parent is indented by 
        nonBlank = find(nList{insertIndex} ~= ' '); 
        iNameList = locIndent(iNameList,min(nonBlank)-1); 
         
        hList=[hList(1:insertIndex);iHandList;hList(insertIndex+1:end)]; 
        nList=[nList(1:insertIndex);iNameList;nList(insertIndex+1:end)]; 
		currIndex=insertIndex+length(iHandList)-1; 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=jforcenavbardisplay(h,forceValue)
%Force object(s) to appear or not appear in property editor nav bar,
%regardless of their HandleVisibility and HitTest settings.

if nargin<2
    forceValue=1;
end

for i=1:length(h)
    setappdata(double(h),'PropertyEditorNavBarDisplay',forceValue);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hOut = locChildren(hIn,varargin)
%returns a list of children which should be included in the property
%editor.  hIn can be a vector.

oldSHH = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
childList=double(find(handle(hIn),'-depth',1,'BeingDeleted','off',varargin{:}));
set(0,'ShowHiddenHandles',oldSHH);
hIn=double(hIn);
f = 'PropertyEditorNavBarDisplay';

hOut=[];
for i=1:length(childList)
    if any(hIn==childList(i))
        %noop
    elseif isappdata(childList(i),f)
        if getappdata(childList(i),f)
            hOut(end+1,1)=childList(i);
        end
    elseif strcmp(get(childList(i),'HandleVisibility'),'on') & ...
            strcmp(get(childList(i),'HitTest'),'on')
        hOut(end+1,1)=childList(i);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [hList, nList] = locDescribeChildren(h) 
%[handleList, nameList]=locDescribeChildren(h) 
%  Gives back ready-to-use handle/name cell arrays for one handle 
%  and its immediate children 
% 
% 
% 

if isempty(h) 
    h = []; 
end 
if iscell(h) 
    h = cat(1,h{:}); 
end 

hList={}; 
nList={}; 
for (i = 1:length(h)) 
    [phList, pnList] = locDescription(h(i)); 
    pnList = locIndent(pnList, 1); 
    hList=[hList;phList]; 
    nList=[nList;pnList]; 
     
    if isa (h(i),'handle') 
        hHandle = h(i); 
    else 
        hHandle = handle(h(i)); 
    end 
     
    ch = locChildren(hHandle);
     
    if ~isempty(ch) 
        %[chList, cnList] = locDescription(ch); 
        %cnList = locIndent(cnList); 
        [chList, cnList]=locDescribeChildren(ch); 
         
        cnList = locIndent(cnList, 1); 
        hList=[hList;chList]; 
        nList=[nList;cnList]; 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [hList,nList]=locDescription(h,isVertical) 
%Supports jnames.  Gets name descriptions for handles 
%returns two column cell arrays 

if nargin<2 
    isVertical = true; 
end 

if length(h)==0
    hList={}; 
    nList={}; 
    return; 
end 

if isVertical 
    for i=length(h):-1:1 
        [hList{i,1},nList{i,1}]=jname(h(i));
    end 
else 
    [hList{1},nList{1}]=jname(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hDouble,dStr] = jname(h)
%[HANDLES,NAME]=JPROPEDITUTILS('jname',H)
%  H can be a scalar or vector
%  NAME returns a string description of the objects in H.
%  HANDLES is guaranteed to be double

switch length(h)
case 0
    dStr='';
case 1
    if isa(h,'handle') 
        hDouble = double(h); 
        hHandle = h; 
    else 
        hDouble = h; 
        hHandle = handle(h); 
    end
    
    if ~ishandle(hDouble), dStr = ''; return, end
    
    className = hHandle.class; 
    %strip the package name out
    dotLoc = findstr(className,'.');
    if ~isempty(dotLoc)
        className = className(dotLoc(end)+1:end);    
    end
    
    
    hTag = get(hDouble,'tag'); 
    if isempty(hTag)
        if floor(hDouble)==hDouble 
            dStr=sprintf('%s: %0.7g',className,hDouble); 
        else 
            dStr=sprintf('%s:',className); 
        end 
    else 
        dStr = sprintf('%s: ''%s''',className,...
            strrep(strrep(hTag,char(10),' '),char(13),' ')); 
    end 
otherwise
    typeList=cell(length(h),1); 

    dStr = ''; 

    if isa(h,'handle') 
        hDouble = double(h); 
        hHandle = h; 
    else 
        hDouble = h; 
        hHandle = handle(h); 
    end 
    
    for i=1:length(hHandle) 
        className = hHandle(i).class; 
        %strip the package name out
        dotLoc = findstr(className,'.');
        if ~isempty(dotLoc)
            className = className(dotLoc(end)+1:end);    
        end
        typeList{i}=className; 
         
        hTag = get(hDouble(i),'tag'); 
         
        if isempty(hTag) 
            if floor(hDouble)==hDouble 
                dStr = sprintf('%s%0.7g, ',dStr,hDouble(i)); 
            else 
                dStr = sprintf('%s<no tag>, ',dStr);
            end 
        else 
            dStr = sprintf('%s''%s'', ',dStr,...
                strrep(strrep(hTag,char(10),' '),char(13),' ')); 
        end 
    end 

    if length(unique(typeList))==1 
        classType = [typeList{1} ' ']; 
    else 
        classType = ''; 
    end 
     
    dStr = sprintf('multiple %sobjects: %s',classType,dStr(1:end-2)); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function nIndent = locIndent(nOrig,numSpaces) 
%Indents strings 3 spaces by default 

if isempty(nOrig) 
    nIndent={}; 
else 
    if nargin<2 
        numSpaces=3; 
    end 
     
    spaces=cell(length(nOrig),1); 
    [spaces{:}]=deal(blanks(numSpaces)); 
    %we have to create a cell array here because strcat 
    %deblanks strings before catting 
     
    nIndent  = strcat(spaces,nOrig); 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function ok=jwaitcursor(newState) 

persistent prevHandles; 
persistent prevPointer; 

if strcmp(newState,'on') 
    prevHandles=findobj(0,'type','figure','visible','on','handlevisibility','on'); 
    prevPointer=get(prevHandles,'Pointer');
    if length(prevHandles)==1
        prevPointer={prevPointer};
    end
    set(prevHandles,'Pointer','watch'); 
else
    for i=1:length(prevHandles)
        try
            if strcmp(get(prevHandles(i),'Pointer'),'watch')
                %if another application has changed the pointer since
                %we started editing, honor the new setting and don't restore
                set(prevHandles(i),'Pointer',prevPointer{i});
            end
        end
    end
    prevHandles=[]; 
    prevPointer={};
end 

ok=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function japplyexpopts(h); 

for i = 1:length(h) 
    axesList = findall(h(i), 'type', 'axes'); 
    textList = findall(h(i), 'type', 'text'); 
    lineList = findall(h(i), 'type', 'line');
    uicontrolList = findall(h(i), 'type', 'uicontrol');
    hs = []; 
    ps = []; 
    vs = [];
    oldtextfontsize = zeros(length(textList),1); % for scaling font size
    oldaxesfontsize = zeros(length(axesList),1); 
    % save ALL properties first
    for j = 1:length(textList)
        oldtextfontsize(j) = get(textList(j),'fontsize');
        hs{end+1}=textList(j);  ps{end+1}='fontsize';    vs{end+1}=oldtextfontsize(j);
        hs{end+1}=textList(j);  ps{end+1}='fontweight';  vs{end+1}=get(textList(j),'fontweight');
        hs{end+1}=textList(j);  ps{end+1}='color';       vs{end+1}=get(textList(j),'color');
    end 
    for j = 1:length(axesList)
        oldaxesfontsize(j) = get(axesList(j),'fontsize');
        hs{end+1}=axesList(j);  ps{end+1}='fontsize';    vs{end+1}=oldaxesfontsize(j);
        hs{end+1}=axesList(j);  ps{end+1}='fontweight';  vs{end+1}=get(axesList(j),'fontweight');
        hs{end+1}=axesList(j);  ps{end+1}='color';       vs{end+1}=get(axesList(j),'color');
        hs{end+1}=axesList(j);  ps{end+1}='XLimMode';    vs{end+1}=get(axesList(j),'XLimMode');
        hs{end+1}=axesList(j);  ps{end+1}='XTickMode';   vs{end+1}=get(axesList(j),'XTickMode');
        hs{end+1}=axesList(j);  ps{end+1}='YLimMode';    vs{end+1}=get(axesList(j),'YLimMode');
        hs{end+1}=axesList(j);  ps{end+1}='YTickMode';   vs{end+1}=get(axesList(j),'YTickMode');
        hs{end+1}=axesList(j);  ps{end+1}='ZLimMode';    vs{end+1}=get(axesList(j),'ZLimMode');
        hs{end+1}=axesList(j);  ps{end+1}='ZTickMode';   vs{end+1}=get(axesList(j),'ZTickMode');
    end 
    for j = 1:length(lineList)
        hs{end+1}=lineList(j);  ps{end+1}='linewidth';   vs{end+1}=get(lineList(j),'linewidth');
        hs{end+1}=lineList(j);  ps{end+1}='linestyle';   vs{end+1}=get(lineList(j),'linestyle');
        hs{end+1}=lineList(j);  ps{end+1}='color';       vs{end+1}=get(lineList(j),'color');
    end 
    for j = 1:length(uicontrolList)
        hs{end+1}=uicontrolList(j); ps{end+1}='visible'; vs{end+1}=get(uicontrolList(j),'visible');
    end 
    
    eo.hSave = hs; 
    eo.propSave = ps; 
    eo.valSave = vs; 
    setappdata(h(i), 'eo_restore_info_080682', eo); 
    
    % then set the ones that need to be set
    %figfontbold = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.TextBold']); 
     figfontbold = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.TextBold']); 
    if (figfontbold) 
        for j = 1:length(textList) 
            set(textList(j), 'fontweight', 'bold'); 
        end 
        for j = 1:length(axesList) 
            set(axesList(j), 'fontweight', 'bold');  
        end 
    end 
    %figfonttextBW = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.TextBW']); 
     figfonttextBW = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.TextBW']); 

    if (figfonttextBW)   
        for j = 1:length(textList) 
            set(textList(j), 'color', 'black'); 
        end 
    end 
    %figfontchange = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeChange']); 
    figfontchange = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.TextSizeChange']);

    if (figfontchange) 
        %figfontsize = javaMethod('getIntegerPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeChangePref']);
        figfontsize = com.mathworks.services.Prefs.getIntegerPref(['CopyOptions.TextSizeChangePref']); 
        if (figfontsize == 0) 
            %strfontsize = javaMethod('getStringPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeChangeTo']); 
             strfontsize = com.mathworks.services.Prefs.getStringPref(['CopyOptions.TextSizeChangeTo']); 
             
            ifontsize = str2num(strfontsize);
            for j = 1:length(textList) 
                set(textList(j), 'fontsize', ifontsize); 
            end 
        	for j = 1:length(axesList) 
                set(axesList(j), 'fontsize', ifontsize); 
            end 
        elseif (figfontsize == 1)  
            %strfontincrease = javaMethod('getStringPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeIncrease']); 
             strfontincrease = com.mathworks.services.Prefs.getStringPref(['CopyOptions.TextSizeIncrease']); 

            ifontincrease = str2num(strfontincrease); 
            for j = 1:length(textList)
                set(textList(j), 'fontsize', round(oldtextfontsize(j)*(ifontincrease/100))); 
            end 
        	for j = 1:length(axesList)
                set(axesList(j), 'fontsize', round(oldaxesfontsize(j)*(ifontincrease/100))); 
            end 
        end 
    end 
     
    %figlineswidth = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.LinesWidthCustom']); 
    figlineswidth = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.LinesWidthCustom']); 

    if (figlineswidth)
        %strlineswidth = javaMethod('getStringPref','com.mathworks.services.Prefs', ['CopyOptions.LinesWidth']); 
         strlineswidth = com.mathworks.services.Prefs.getStringPref(['CopyOptions.LinesWidth']);
        ilineswidth = str2num(strlineswidth); 
        for j = 1:length(lineList) 
            set(lineList(j), 'linewidth', ilineswidth); 
        end 
    end 
     
    %figlinesstylechange = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.LinesStyleChange']); 
     figlinesstylechange = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.LinesStyleChange']); 

    if (figlinesstylechange) 
        styles = {'-', '--', '-.', ':'}; 
        for j = 1:length(lineList)
            linecolor = 'black'; 
            if isequal([0 0 0], get(ancestor(lineList(j),'axes'), 'color'))
                linecolor = 'white';
            else
                linecolor = 'black';
            end
            set(lineList(j), 'color', linecolor);
            %linesstylepref = javaMethod('getIntegerPref','com.mathworks.services.Prefs', ['CopyOptions.LinesStylePref']);
             linesstylepref = com.mathworks.services.Prefs.getIntegerPref(['CopyOptions.LinesStylePref']);

            if (linesstylepref == 1) 
                styleindex = mod(j, 4); 
                if (styleindex == 0) 
                    styleindex = 4; 
                end 
                set(lineList(j), 'linestyle', styles{styleindex});
            end 
        end 
    end   
     
    %figlocklabels = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.LockAxesAndTickLabels']);
     figlocklabels = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.LockAxesAndTickLabels']); 
    if (figlocklabels) 
        for j = 1:length(axesList) 
            set(axesList(j), 'XLimMode',    'manual'); 
            set(axesList(j), 'XTickMode',   'manual'); 
            set(axesList(j), 'YLimMode',    'manual'); 
            set(axesList(j), 'YTickMode',   'manual'); 
            set(axesList(j), 'ZLimMode',    'manual'); 
            set(axesList(j), 'ZTickMode',   'manual'); 
        end 
    end 
     
    %figshowuicontrols = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.ShowUiControls']);
     figshowuicontrols = com.mathworks.services.Prefs.getBooleanPref(['CopyOptions.ShowUiControls']);

    if (figshowuicontrols == 0)   %hide uicontrols 
        for j = 1:length(uicontrolList) 
            set(uicontrolList(j), 'visible', 'off'); 
        end 
    end 
    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jrestorefig(h); 

for i=1:length(h) 
    if (isappdata(h(i), 'eo_restore_info_080682'))  
        eo = getappdata(h(i), 'eo_restore_info_080682'); 
        for j = 1:length(eo.hSave) 
            try   % in case a handle (or other value) is bad  
                set(eo.hSave{j}, eo.propSave{j}, eo.valSave{j}) 
            end 
        end 
        rmappdata(h(i), 'eo_restore_info_080682'); 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function colorArray=jmeshcolor(h) 

if length(h)==1 
    colorArray=loc_mesh_color(h); 
else 
    for i=length(h):-1:1 
        colorArray{i,1}=loc_mesh_color(h(i));
    end
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function c = loc_mesh_color(h) 

axHandle = ancestor(h,'axes'); 

if strcmp(get(axHandle,'visible'),'on') 
    c = get(axHandle,'Color'); 
else 
    figHandle = ancestor(axHandle,'figure'); 
    c = get(figHandle,'Color'); 
    if ischar(c) & strcmp(c,'none') 
        c = [1 1 1]; 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function lightHandles=jaddlight(h) 

if nargin<1 
    h=gca; 
end 

addedAxes=[0]; %do this to prevent an empty==scalar comparison 
lightHandles=[]; 
for i=1:length(h) 
    axH=h(i); 
     
    try 
        hType=get(axH,'type'); 
    catch 
        hType=''; 
    end 
     
    while ~(isempty(hType) | strcmp(hType,'axes')) 
        try 
            axH=get(axH,'parent'); 
            hType=get(axH,'type'); 
        catch 
            axH=[]; 
            hType=''; 
        end 
    end 
     
    if ~isempty(axH) & ~any(find(addedAxes==axH)) 
        %note: this is pretty much cut-and-paste from camlight 
         
        %place the light up and to the right of the camera 
        pos  = get(axH, 'cameraposition' ); 
        targ = get(axH, 'cameratarget'   ); 
        dar  = get(axH, 'dataaspectratio'); 
        up   = get(axH, 'cameraupvector' ); 
         
        %check to see if the axis is right-handed 
        dirs=get(axH, {'xdir' 'ydir' 'zdir'});  
        num=length(find(lower(cat(2,dirs{:}))=='n')); 
        isRightHanded = mod(num,2); 
         
        az=30; 
        el=30; 
        if isRightHanded 
            az=-az; 
        end 
         
        lightPos = camrotate(pos,targ,dar,up,az,el,'camera',[]); 
         
        %change the position because the light is infinite 
        lightPos=lightPos-targ; 
        lightPos=lightPos/norm(lightPos); 
         
         
         
        lightHandles(end+1,1)=light(... 
            'Parent',axH,... 
            'Position',lightPos,... 
            'style','infinite'); 
        addedAxes(end+1,1)=axH; 
    end 
end 

lightHandles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function hAdded=jinstrument(h) 
%adds property changed and object deleted listeners to objects 

hAdded=[]; 
desiredPropNames={};

        ignorePropNames={ 
            'ApplicationData' %Gobject properties 
            'Selected' 
            'UserData' 
            'CreateFcn' 
            'DeleteFcn' 
            'ButtonDownFcn' 
            'WindowButtonDownFcn'  % figure-only properties 
            'WindowButtonMotionFcn' 
            'WindowButtonUpFcn' 
            'Pointer' 
            'PointerShapeCData' 
            'PointerShapeHotSpot' 
            'CurrentAxes' 
            'CurrentCharacter' 
            'CurrentObject' 
            'CurrentPoint' 
            'SelectionType' 
            'CallbackObject' %root-only properties 
            'CurrentFigure' 
            'PointerLocation' 
            'PointerWindow' 
            'ShowHiddenHandles' 
            'HideUndocumented' 
            'AutomaticFileUpdates'
            'RecursionLimit'
        }; 
desiredPropNames = fieldnames(get(h(1)));

for i = 2:length(h)
    if (ishandle(h(i)))
        uprops = get(h(i));
        upropnames = fieldnames(uprops)
        desiredPropNames = intersect(desiredPropNames, upropnames);
    end
end

desiredPropNames = setdiff(desiredPropNames, ignorePropNames);

for i=1:length(h)
    if ~ishandle(h(i)), continue, end
    
    f = handle(h(i));  
    
    if isempty(findprop(f, 'PropEditListeners')) 
        
        c = classhandle(f);
        %disp(sprintf('instrumenting %g',h(i))); 

        cSchemaProps = find(c.properties, {'name'}, desiredPropNames);
         
        l(1) = handle.listener(f, cSchemaProps, 'PropertyPostSet', @PropertyChangedListener); 
        l(2) = handle.listener(f, 'ObjectBeingDestroyed', @ObjectDeletedListener); 
         
        %l(1) = handle.listener(f, c.properties, 'PropertyPostSet', 'disp property'); 
        %l(2) = handle.listener(f, 'ObjectBeingDestroyed', 'disp deleting'); 

        p = schema.prop(f, 'PropEditListeners', 'handle vector');
        p.AccessFlags.Serialize = 'off';
        p.AccessFlags.Copy = 'off';
        % p.AccessFlags.PublicGet='off'; %prevent this from showing up on get(handle(h))
        p.Visible='off'; %prevent this from showing up on get(handle(h))
        
        set(f, 'PropEditListeners', l);
        
        hAdded(end+1)=h(i);     
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function juninstrument(h)
%JUNINSTRUMENT(H)
% Removes property editor listeners from all objects in vector h

for i=1:length(h)
    delete(findprop(handle(h(i)),'PropEditListeners'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function PropertyChangedListener(hProp,eventData) 

%disp('property changed!'); 

%currEdit = javaMethod('getDoubleHandle','com.mathworks.page.propertyeditor.PropertyEditor'); 
 currEdit = com.mathworks.page.propertyeditor.PropertyEditor.getDoubleHandle; 
     
%disp('current property editor handles:'); 
%disp(currEdit); 
     
if ~isempty(currEdit) 
    hDouble=double(eventData.affectedObject); 
     
    %disp('changed object:'); 
    %disp(hDouble); 
    %disp('changed property:'); 
    %disp(hProp.name);
    %disp('-------------');
     
    if any(currEdit==hDouble) 
        %disp('re-initializing!') 
         
        [propName, propVal, isMultiple]=jpropeditutils('jget',currEdit,hProp.name); 

        %javaMethod('initialize','com.mathworks.page.propertyeditor.PropertyEditor',currEdit,propName,propVal,isMultiple);
         com.mathworks.page.propertyeditor.PropertyEditor.initialize(currEdit,propName,propVal,isMultiple);
         
        %disp('new value:'); 
        %disp(propVal{1}); 
        %disp('is Multiple:'); 
        %disp(isMultiple); 

    end 
end 
     
%disp('-------------'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function ObjectDeletedListener(hHandle,eventData) 

%disp('object deleted'); 

%currEdit = javaMethod('getDoubleHandle','com.mathworks.page.propertyeditor.PropertyEditor'); 
 currEdit = com.mathworks.page.propertyeditor.PropertyEditor.getDoubleHandle; 
     
%disp('current property editor handles:'); 
%disp(currEdit); 
     
if ~isempty(currEdit)
    hDouble=double(hHandle); 
    
    if any(currEdit==hDouble) 
        %we are editing one or more of the deleted objects. 
        if length(currEdit)==1 
            hNew = locDeleteReselect(hDouble);             
        else 
            hNew = locDeleteReselectMultiple(currEdit); 
        end 
        propedit(hNew,'-noopen'); 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function h = locDeleteReselect(h) 

while (h>0 & ...
        ishandle(h) & ...
        (strcmp(get(h,'BeingDeleted'),'on') | ...
        ~strcmp(get(h,'HandleVisibility'),'on') ))
    h=get(h,'parent'); 
end 

if ~ishandle(h)
    h=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function hNew = locDeleteReselectMultiple(h) 

hReal=h(ishandle(h)); 
hNew = findobj(hReal,'BeingDeleted','off'); 
if isempty(hNew) 
    %I have been unable to force it into this case - here for safety 
    hNew=0; 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [h,foundType]=jnavbarfind(nbText)
%Looks for objects based on a string 
% 1) searches for objects with a tag of string 
% 2) converts string to numbers and looks for objects with that handle 
% 3) looks for objects with class of string 
% 4) looks for objects with class hg.string 

%look for tag 

rootH=handle(0);

h = find(rootH,'tag',nbText); 
if ~isempty(h)
    foundType='tag';
    h=double(h);
    return;
end 

h = find(rootH,'type',nbText); 
if ~isempty(h) 
    foundType='type';
    h=double(h);
    return; 
end 

h = find(rootH,'-class',nbText);
if ~isempty(h) 
    h=double(h);
    foundType='class';
    return; 
end 

h = find(rootH,'-class',['hg.' nbText]);
if ~isempty(h) 
    h=double(h);
    foundType='class';
    return; 
end 


h = str2numsafe(nbText); 
h = h(ishandle(h)); 
foundType='handle';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function d=str2numsafe(t) 
%does a vectorized num2str without using eval. 
%note that this does not handle complex or negative numbers. 

nonNumeric = ((t<'0' | t>'9') &  t~='.'); 
t(nonNumeric)=blanks(length(find(nonNumeric))); 
t=['[' t ']']; 
d=str2num(t); 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function result=jeval(eString) 
% RESULT= jpropeditutils('jeval',EVALSTRING) 
% Evaluates the evalstring and returns the result as a MLArrayRef 

result=locArrayRef(evalin('base',eString)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function idx=locReverseStrmatch(str,strs) 

if iscellstr(strs) 
    strs=char(strs); 
end 
strs=strjust(strs(:,end:-1:1),'left'); 
idx=strmatch(str(end:-1:1),strs); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function ar=locArrayRef(data) 

try 
    ar=system_dependent(45,data); 
catch 
    ar=[]; 
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function wName=jwhos 
%NAME=jpropeditutils('jwhos'); 
%returns the output from whos in a preparsed java-friendly format 

%,wSize,wBytes,wClass]
%[NAME,SIZE,BYTES,CLASS]=jpropeditutils('jwhos'); 

w=evalin('base','whos'); 
wName = {w.name};
%wSize = w.size;
%wBytes = w.bytes;
%wClass = w.class;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=getUndoStack(h)
%Each figure and root maintain their own undo stacks in
%app data.  Assume that all handles passed in are in the
%same figure.

if length(h)>1
    h=h(1);
end

while ~isempty(h) & ...
        ~any(strcmp({'root','figure'},get(h,'type')))
    h=get(h,'parent');
end

if isempty(h)
    h=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stackSize=jundo(cmd,figH,overridePropertyEditorUndoButtonUpdate)
%stub for future functionality
stackSize=0;


%STACKSIZE=JPROPEDITUTILS('jundo','START',H) begins a new undo log
%STACKSIZE=JPROPEDITUTILS('jundo','STOP',H) closes an undo log
%STACKSIZE=JPROPEDITUTILS('jundo','UNDO',H) undoes the log at the top of the stack
%STACKSIZE=JPROPEDITUTILS('jundo','QUERYSIZE',H) does nothing but return the stack size
%  If H is omitted or empty, the current figure's stack will be used
%  Note that root also maintains a stack

% stackSize=5;
% 
% if nargin<3
%     overridePropertyEditorUndoButtonUpdate=0;
% end
% 
% if nargin<2 | isempty(figH)
%     figH=get(0,'currentfigure');
% end
% figH=getUndoStack(figH);
% 
% appDataName='PropEditUndoStack';
% 
% if isappdata(figH,appDataName)
%     undoStack=getappdata(figH,appDataName);
% else
%     undoStack={};
% end
% 
% switch lower(cmd)
% case 'start'
%     overridePropertyEditorUndoButtonUpdate=1;
%     
%     t = handle.transaction(handle(0));
%     t.OperationStore = 'off';
%     t.InverseOperationStore = 'on';    
%     
%     undoStack{end+1}=t;
% case 'stop'
%     if length(undoStack)>0
%         t=undoStack{end};
%         
%         if ~isempty(t.Operations)
%             ok=1;
%             try
%                 %t might have already been committed
%                 commit(t);
%             end
%         else
%             ok=0;
%             clear t;
%         end
%         
%         if ~ok
%             undoStack=undoStack(1:end-1);
%             %remove the current transaction from the stack
%         elseif length(undoStack)>stackSize
%             %shrink the stack to its minimum size
%             undoStack=undoStack(end-stackSize+1:end);
%         else
%             %do nothing - we're fine
%         end
%     end
% case 'undo'
%     if length(undoStack)>0
%         t=undoStack{end};
%         undoStack=undoStack(1:end-1);
%         try
%             undo(t);
%         end
%         drawnow;
%     end
% end
% 
% setappdata(figH,appDataName,undoStack);
% stackSize = length(undoStack);
% 
% if ~overridePropertyEditorUndoButtonUpdate & ...
%         figH==getUndoStack(com.mathworks.page.propertyeditor.PropertyEditor.getDoubleHandle)
%     com.mathworks.page.propertyeditor.PropertyEditor.updateUndoButton(stackSize);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=jobjectchangeddlg(dlgTitle,dlgString,objHandle)

%note that we only want to throw the dialog up if the object
%still exists.
if ~all(ishandle(objHandle)) | isempty(findall(objHandle,'flat','BeingDeleted','off'))
    result = 'no';
else
    result=uigetpref('graphics','propeditapplychanges',...
        dlgTitle,...
        dlgString,...
        {'Yes','No'},...
        'ExtraOptions','Cancel',...
        'DefaultButton','Cancel');
end

    
