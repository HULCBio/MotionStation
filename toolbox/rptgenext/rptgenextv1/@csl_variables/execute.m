function out=execute(c)
%EXECUTE generates the report content
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:02 $

mdlName=c.zslmethods.Model;
if isempty(mdlName)
   out='';
   return
end

fnList=c.zslmethods.WordVariableList;

if c.att.isWorkspaceIO
   simVars=LocGetWorkspaceIO(mdlName);
   fnList=[fnList;simVars];
end

if isempty(fnList)
   out='';
   status(c,sprintf('Warning - no variables found in model.'),2);
else
   allVars=evalin('base','whos');
   
   %construct column 1 - variable names
   varTable=[{'Variable Name'} ; fnList(:,1)];
   cWid=1;
   
   if c.att.isShowParentBlock
      varTable(:,end+1) = [{'Parent Blocks'};  fnList(:,2)];      
      cWid=[cWid,3];
   end
   
   if c.att.isShowCallingString
      varTable(:,end+1) = [{'Calling string'};  fnList(:,3)];      
      cWid=[cWid,2];
   end

   if c.att.isShowVariableSize | ...
           c.att.isShowVariableMemory | ...
           c.att.isShowVariableClass

       for i=size(fnList,1):-1:1
           tempVar = fnList{i,5};
           if isa(tempVar,'Simulink.Parameter')
               tempVar = tempVar.Value;
           end
           
           whosInfo= whos('tempVar');
           
           if c.att.isShowVariableSize
               sizeCol{i+1,1}=locSizeString(whosInfo.size);
           end
           
           if c.att.isShowVariableMemory
               memCol{i+1,1}=whosInfo.bytes;
           end
           
           if c.att.isShowVariableClass
               classCol{i+1,1}=whosInfo.class;
           end
       end
       
       if c.att.isShowVariableSize
           sizeCol{1}=xlate('Size');
           varTable(:,end+1)=sizeCol;
           cWid=[cWid,.75];
           clear sizeCol;
       end
       
       if c.att.isShowVariableMemory
           memCol{1}=xlate('Bytes');
           varTable(:,end+1)=memCol;
           clear memCol;
           cWid=[cWid,.75];
       end
       
       if c.att.isShowVariableClass
           classCol{1}=xlate('Class');
           varTable(:,end+1)=classCol;
           clear classCol;
           cWid=[cWid,.75];
       end
   end

   if c.att.isShowVariableValue
       valCol={'Value'};
       for i=size(fnList,1):-1:1
           tempVar = fnList{i,5};
           if isa(tempVar,'Simulink.Parameter')
               tempVar = tempVar.Value;
           end
           valCol{i+1,1}=rendervariable(c,...
               tempVar,...
               logical(1)); %force inline
       end
       varTable(:,end+1)=valCol;
       clear valCol;
       cWid=[cWid,2];
   end
   
   if c.att.isShowTunableProps
       classCol=[{'Storage Class'};cell(size(fnList,1),1)];
       [tunableNames,tunableClasses,warnStr]=LocTunableProps(c.zslmethods);
       for i=size(fnList,1):-1:1
           if isa(fnList{i,5},'Simulink.Parameter')
               val=fnList{i,5}.RTWInfo.StorageClass;
           else
               listIndex=find(strcmp(tunableNames,fnList{i,1}));
               if isempty(listIndex)
                   val='Auto';
               elseif strcmpi(tunableClasses{listIndex(1)},'auto')
                   val='SimulinkGlobal';
               else
                   val=tunableClasses{listIndex(1)};
               end
           end
           classCol{i+1}=val;
       end
       varTable(:,end+1)=classCol;
       cWid=[cWid,2];
   end
   
   propNames=c.att.ParameterProps(find(~cellfun('isempty',c.att.ParameterProps)));
   if ~isempty(propNames)
       propNames=propNames(:)';
       paramCells=cell(size(fnList,1),length(propNames));
       for i=size(fnList,1):-1:1
           val=fnList{i,5};
           if isa(val,'Simulink.Parameter')
               for j=1:length(propNames)
                   try
                       paramCells{i,j}=subsref(val,locMakeSubsref(propNames{j}));
                       %note that the current implementation of getfield just
                       %does a string eval of val.fieldname  This allows ParameterProps
                       %to reference subfields like 'foo.bar.ho'
                   catch
                       paramCells{i,j}='N/A';
                   end
               end
           else
               [paramCells{i,:}]=deal('N/A');
           end
       end
       okCols=find(~all(strcmp(paramCells,'N/A')));
       
       if ~isempty(okCols)
           propNames=propNames(okCols);
           paramCells=paramCells(:,okCols);
           varTable=[varTable, [propNames;paramCells]];
           cWid=[cWid,2*ones(1,length(okCols))];
       end
   end
       
   tableComp=c.rptcomponent.comps.cfrcelltable;
   
   att=tableComp.att;
   att.TableTitle=c.att.TableTitle;
   att.TableCells=varTable;
   att.isPgwide=logical(1);
   att.ColumnWidths=cWid;
   att.isBorder=c.att.isBorder;
   att.numHeaderRows=1;
   att.Footer='NONE';
   tableComp.att=att;
   
   out=runcomponent(tableComp,0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sString=locSizeString(sInfo);
%changes [M N] to 'MxN'

sString = sprintf('%ix',sInfo);
sString = sString(1:end-1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ioVals=LocGetWorkspaceIO(vModel)

ioVals=cell(0,5);

simParams={'LoadExternalInput' 'ExternalInput' 'Sim:ExternalInput'
   'SaveTime' 'TimeSaveName' 'Sim: Save Time'
   'SaveState' 'StateSaveName' 'Sim: Save State'
   'SaveOutput' 'OutputSaveName' 'Sim: Save Output'
   'LoadInitialState' 'Initial State' 'Sim: Initial State'
   'SaveFinalState' 'FinalStateName' 'Sim: Final State'};

for i=1:size(simParams,1)
    if strcmp(get_param(vModel,simParams{i,1}),'on')
        try
            varName=get_param(vModel,simParams{i,2});
        catch
            varName='';
        end
        
        if ~isempty(varName)
            try
                varValue=evalin('base',varName);
            catch
                varValue=nan;
            end
            
            ioVals(end+1,:)={varName,...
                    simParams{i,3},...
                    'Workspace IO',...
                    vModel,...
                    varValue};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function logOnOff=LocLogOnOff(strOnOff)

logOnOff=strcmp(strOnOff,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tNames,tClasses,warnStr]=LocTunableProps(z);

tNames={};
tClasses={};
warnStr='';

hModel=z.Model;

tunableVarsName          = get_param(hModel, 'TunableVars');
tunableVarsStorageClass  = get_param(hModel, 'TunableVarsStorageClass');
tunableVarsTypeQualifier = get_param(hModel, 'TunableVarsTypeQualifier');

%
% Locate the separate symbol's position.
%
sep         = ',';
sepNameIndx = findstr(tunableVarsName, sep);
sepSCIndx   = findstr(tunableVarsStorageClass, sep);
sepTQIndx   = findstr(tunableVarsTypeQualifier, sep);

%
% Get the number of Tunable Variables
%
if ~isempty(tunableVarsName)
   numberVars = length(sepNameIndx) + 1;
else
   numberVars = 0;
end

if numberVars
   %
   % Error handling
   %
   if length(sepSCIndx)+1 ~= numberVars
      warnStr=...
	     'Warning - Tunable parameters name setting does not match its storage class setting.';
      return;
   elseif  length(sepTQIndx)+1 ~= numberVars
      warnStr=...
	      'Warning - Tunable parameters name setting does not match its type qualifier setting.';
      return;
   elseif  length(sepTQIndx) ~= length(sepSCIndx)
      warnStr=...
	      'Warning - Tunable parameters storage class setting does not match its type qualifier setting.';
      return;
   end
   
   %
   % Re-locate the separate symbol's position.
   %
   %sepNameIndx = findstr(tunableVarsName, sep);
   %sepSCIndx   = findstr(tunableVarsStorageClass, sep);
   %sepTQIndx   = findstr(tunableVarsTypeQualifier, sep);
   
   sepNameIndx = [0 sepNameIndx length(tunableVarsName)+1];
   sepSCIndx   = [0 sepSCIndx length(tunableVarsStorageClass)+1];
   sepTQIndx   = [0 sepTQIndx length(tunableVarsTypeQualifier)+1];
   
   
   for i = 1 : numberVars
      
      nameTmp = tunableVarsName(sepNameIndx(i)+1 : sepNameIndx(i+1)-1);
      nameTmp = deblankall(nameTmp);
      tNames{end+1}=nameTmp;
      
      scTmp = tunableVarsStorageClass(sepSCIndx(i)+1 : sepSCIndx(i+1)-1);
      scTmp = deblankall(scTmp);
      
      tqTmp = tunableVarsTypeQualifier(sepTQIndx(i)+1 : sepTQIndx(i+1)-1);
      tqTmp = deblankall(tqTmp);
      
      if isempty(tqTmp)
         tClasses{end+1}=scTmp;
      else
         tClasses{end+1}=[scTmp ' (' tqTmp ')'];
      end
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = deblankall(str)

if isempty(str)
   str='';
else
  % remove trailing and leading blanks
  [r,c] = find(str ~= ' ' & str ~= 0);
  if isempty(c)
     str='';
  else
     str=str(min(c):max(c));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sref=locMakeSubsref(propName)
%this throws an error if propName is not valid

sTerms={};
while ~isempty(propName)
    [sTerms{end+1},propName]=strtok(propName,'.');
end

sref=cell(1,length(sTerms)*2);

[sref{1:2:end-1}]=deal('.');
[sref{2:2:end}]=deal(sTerms{:});

sref=substruct(sref{:});
