function wList=wordlist(z,action,varargin)
%WORDLIST stores a list of variables and functions used in parameters

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:59 $

wList=feval(action,varargin{:});
%LocGetWordList(reportedBlocks)
%LocGetVariableList(wordList)
%LocGetFunctionList(wordList,variableList)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wList=LocGetWordList(allBlocks)
%returns a 4 column cell array
%col 1 = name of variable (string)
%col 2 = list of linked parent blocks
%col 3 = cell array of expression strings in which word appears
%col 4 = list of parent blocks (no links, no gimmicks)


linkObj=unpoint(cfrlink('LinkType','Link'));
zObj=zslmethods;

isSubSystem=find(strcmp(get_param(allBlocks,'blocktype'),'SubSystem'));
isBlock=setxor(isSubSystem,[1:length(allBlocks)]);

valueList={};
parentList={};
sourceList={};
handleList={};
for i=1:length(isSubSystem);
   myValues=get_param(allBlocks{isSubSystem(i)},'MaskValueString');
   linkedSystem='';
   allValues=LocParseString(myValues);
   if length(allValues)>0
      valueList=[valueList;allValues];
      if isempty(linkedSystem)
         linkObj.att.LinkID=linkid(zObj,...
            allBlocks{isSubSystem(i)},'sys');
         linkObj.att.LinkText=strrep(get_param(allBlocks{isSubSystem(i)},'Name'),...
             char(10),' ');
         linkedSystem=execute(linkObj);
      end
      [parentList{end+1:end+length(allValues)}]=...
         deal(linkedSystem);
      [sourceList{end+1:end+length(allValues)}]=...
         deal(myValues);      
      [handleList{end+1:end+length(allValues)}]=...
         deal(allBlocks(isSubSystem(i)));      
   end
end

for i=1:length(isBlock)
   myBlock=allBlocks{isBlock(i)};
   linkedBlock='';
   myType=get_param(myBlock,'blocktype');
   switch myType
   case {'Scope' 'ToWorkspace' 'ToFile' 'Display'}
      dPara={};
   otherwise   
      dPara=get_param(myBlock,'dialogparameters');
      if isstruct(dPara)
         pNames=fieldnames(dPara);
         cleanNames={};
         for j=1:length(pNames)
            pInfo=getfield(dPara,pNames{j});
            if ~strcmp(pInfo.Type,'enum')
               cleanNames{end+1}=pNames{j};
            end
         end
         dPara=cleanNames;
      else
         dPara={};
      end      
   end
   
   for j=1:length(dPara)
      try
         myValue=get_param(myBlock,dPara{j});
      catch
         myValue=[];
      end
      if ischar(myValue)
         allValues=LocParseString(myValue);
         if length(allValues)>0
            valueList=[valueList;allValues];
            if isempty(linkedBlock)
               linkObj.att.LinkID=linkid(zObj,myBlock,'blk');
               linkObj.att.LinkText=strrep(get_param(myBlock,'Name'),char(10),' ');
               linkedBlock=execute(linkObj);
            end
            [parentList{end+1:end+length(allValues)}]=...
               deal(linkedBlock);
            [sourceList{end+1:end+length(allValues)}]=...
               deal(myValue);
            [handleList{end+1:end+length(allValues)}]=...
               deal(myBlock);
         end
      end
   end
end

%we now have a valueList and a parentList.  We need to collapse
%to having a unique valueList and put all corresponding parentList
%elements in a cell array

[wList,aIndex,bIndex]=unique(valueList);

if isempty(wList)
   wList=cell(0,4);
else
   for i=1:length(wList)
      origIndex=find(bIndex==bIndex(aIndex(i)));
      
      wList{i,4}=handleList(origIndex);
      wList{i,3}=sourceList(origIndex);
      wList{i,2}=parentList(origIndex);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vList=LocGetVariableList(wList)
%vList is a 5-column cell array.
%cols 1-4 are the same as wList
%col  5 contains the parameter value

if isempty(wList)
   vList=cell(0,4);
   return
end

valueList={};
valueIndex=[];

for i=1:size(wList,1)
    try
        valueList{end+1,1}=slResolve(wList{i,1},wList{i,4}{1});
        valueIndex(end+1,1)=i;
    catch
        if ~isempty(evalin('base',sprintf('whos(''%s'');',wList{i,1})))
            try
                valueList{end+1,1}=evalin('base',wList{i,1});
                valueIndex(end+1,1)=i;
            end
        end
    end
end

vList=[wList(valueIndex,:),valueList];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fList=LocGetFunctionList(wList,vList)

if isempty(wList)
   fList=cell(0,4);
   return
end

if nargin<2 | isempty(vList)
    %filter values out of valueList which are on a list of commonly
    %used strings
    filterStrings={'on' 'off' 'auto' 'inf' 'held'};
else
    %if we have a vList, add its strings to the filter list
    filterStrings={'on' 'off' 'auto' 'inf' 'held' vList{:,1}};
end

[checkWords,aIndex,bIndex]=setxor(wList(:,1),filterStrings);

fnIndex=[];
%debugCell={};
for i=1:length(aIndex)
   whichResult=which(wList{aIndex(i),1});
   switch whichResult
   case 'built-in'
      listInclude=logical(1);
   case {'' 'variable'}
      listInclude=logical(0);      
   otherwise
      [wPath wFile wExt wVer]=fileparts(whichResult);
      if any(strcmpi({'.m' '.p'},wExt))
         listInclude=logical(1);
      else
         listInclude=logical(0);
      end
   end
   
   %debugCell(end+1,1:2)={whichResult listInclude};
   if listInclude
      fnIndex=[fnIndex,aIndex(i)];
   end
end

fList=wList(fnIndex,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allWords=LocParseString(valStr)

allWords={};

if ~isempty(valStr)
   %convert valStr into a space-delimited string
   absStr=abs(valStr);
   alphanumericIndices=(...
      (absStr>=abs('0') & ...
      absStr<=abs('9')) | ...
      (absStr>=abs('a') & ...
      absStr<=abs('z')) | ...
      (absStr>=abs('A') & ...
      absStr<=abs('Z')) | ...
      absStr==abs('_') | ...
      absStr==abs('.'));
   
   valStr(~alphanumericIndices)=' ';
   
   while ~isempty(valStr)
      [wordToken,valStr]=strtok(valStr);
      if isempty(wordToken) | abs(wordToken(1))=='.' | ...
            (abs(wordToken(1))>=abs('0') & abs(wordToken(1))<=abs('9'))
         %wordToken='';
      else
         allWords{end+1,1}=strtok(wordToken,'.');
      end   
   end
end

allWords=unique(allWords);