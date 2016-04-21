function varargout=rptgenutil(action,varargin)
%RPTGENUTIL provides utility functionality for the report generator
%   RPTGENUTIL contains several small utility actions which are
%   used by non-object-oriented portions of the report generator.
%   RPTGENUTIL is called with the syntax RPTGENUTIL(ACTION,OPTIONS)
%
%   Actions:
%   S=RPTGENUTIL('EmptyComponentStructure',COMPONENTNAME)
%
%   N=RPTGENUTIL('SimulinkSystemReportName',SYSNAME)
%      SYSNAME is the name or handle of a Simulink system
%      N is the name of the ReportName associated with
%      the system.
%
%   [NUM,ERRORMSG]=RPTGENUTIL('str2numNxN',STRING,OLDNUMBER);
%      Converts over strings like "2.5x3" to numbers like [2.5 3]
%
%   [NUM,ERRORMSG]=RPTGENUTIL('str2numNxN',HANDLE,OLDNUMBER);
%      Acts like the previous function, but gets its string
%      value from HANDLE and sets HANDLE's string when done.
%
%   STR=RPTGENUTIL('num2strNxN',NUM,HANDLE);
%      Converts over vectors like [2.5 3] to '2.5x3'.
%      If HANDLE is supplied (optional), the string will be
%      set to HANDLE's current 'string' property.
%
%   SIZE=RPTGENUTIL('SizeUnitTransform',oldSize,oldUnits,newUnits,strHandle)
%      Changes MxN size arrays from old units to new units.  
%      Optional handle of uicontrol displays string representation
%      of new MxN value
%
%   [VNAME,ERRORMSG]=RPTGENUTIL('VariableNameCheck',NEWNAME,OLDNAME,ISPUNCTOK)   
%      Given a name for a variable (NEWNAME) and the previous
%      (assumed valid) name for a variable, checks to make sure
%      the new variable has a valid name.  If it is not valid, it
%      tries to force it to be valid.  Failing that, it will return
%      the old name.  If a handle (optional) is passed in, it will set
%      the 'String' property of the object to be the new variable name.
%
%      NEWNAME can also be a handle to an edit uicontrol, in which case NEWNAME
%      will be taken from the 'String' property.  The String property will be
%      set with the revised name afterwards.
% 
%      ISPUNCTOK is a boolean value telling whether or not punctuation characters
%      are allowed in the variable name.
% 
   

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:55 $

varargout=feval(action,varargin{:});


%note that all output arguments defined by the
%internal functions must be a 1xN cell array where
%N is the number of output argumens desired.  Use 
%the syntax out={argout1,argout2} instead of 
%[argout1,argout2]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EmptyComponentStructure                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=EmptyComponentStructure(cClass)

if nargin<1
   %we need to infer the calling class
   caller=dbstack('-completenames');
   caller=caller(3).file;
   slashLoc=findstr(filesep,caller);
   periodLoc=findstr('.',caller);   
   cClass=caller(slashLoc(end)+1:periodLoc(end)-1);
end

out{1}=struct('comp',struct('Class',cClass,...
   'Active',logical(1)),...
   'att',[],...
   'ref',[],...
   'x',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SimulinkSystemReportName                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=SimulinkSystemReportName(currSys)

if nargin<1
   try
      currSys=gcs;
   catch
      currSys='';
   end
end

rName='';
while ~isempty(currSys) & isempty(rName)
   try
      rName=get_param(currSys,'ReportName');
   catch
      currSys='';
   end
   
   try
      currSys=get_param(currSys,'Parent');
   catch
      currSys='';
   end
end

if isempty(rName)
   rName='simulink-default.rpt';
end

out{1}=rName;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% str2numNxN                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=str2numNxN(numString,oldNum)

if ishandle(numString)
   editHandle=numString;
   numString=get(editHandle,'String');
else
   editHandle=[];
end

if length(numString)>0
   notNumeric=find((abs(numString)<abs('0') | ...
      abs(numString)>abs('9')) & ...
      abs(numString)~=abs('.'));
   
   [numString(notNumeric)]=deal(' ');
   nums=[];
   while ~all(isspace(numString))
      [thisNum,numString]=strtok(numString);
      nums=[nums str2double(thisNum)];
   end
   nums=nums(find(~isnan(nums)));
else
   nums=[];
end

   
errMsg=xlate('Please enter size values as NxN');
if length(nums)<1
   nums=oldNum;
elseif length(nums)==1
   nums=[nums nums];
elseif length(nums)>2
   nums=nums(1:2);
else
   errMsg='';
end

if length(editHandle)>0
   num2strNxN(nums,editHandle);      
end


out{1}=nums;
out{2}=errMsg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% num2strNxN                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function numStr=num2strNxN(nums,editHandle);      

if length(nums)>=2
   numStr=[num2str(nums(1)) 'x' num2str(nums(2))];
elseif length(nums==1)
   numStr=[num2str(nums(1)) 'x' num2str(nums(1))];
else
   numStr='Error! Size vector must be 1x2';
end

if nargin>1
   set(editHandle,'String',numStr);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SizeUnitTransform                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=SizeUnitTransform(oldSize,oldUnits,newUnits,strHandle)

strTable = {'inches','centimeters','points','normalized'};
oldIndex=find(strcmp(strTable,oldUnits));
newIndex=find(strcmp(strTable,newUnits));

unitsTable=[1     1      %inches
            2.54  2.54   %centimeters
            72    72     %points
            1/8.5 1/11]; %normalized

if length(oldSize)==2
    newSize = oldSize.*(unitsTable(newIndex,:)./unitsTable(oldIndex,:));
    if nargin>3
        num2strNxN(newSize,strHandle);
    end
else
    newSize = oldSize.*(unitsTable(newIndex,1)./unitsTable(oldIndex,1));
    if nargin>3
        set(strHandle,'String',num2str(newSize));
    end
end

out{1}=newSize;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VariableNameCheck                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=VariableNameCheck(newName,oldName,isPunctOk)
%newName name value to check
%oldName previous name.  Use this in case the new name is worthless
%isPunctOK - is punctuation allowed?  Good for expressions such as foo(1).bar{1,2}

if ishandle(newName)
   editHandle=newName;
   newName=get(editHandle,'String');
elseif ~ischar(newName)
   editHandle=[];
   newName='';
else
   editHandle=[];
end

if isempty(newName)
   okName=oldName;
   errMsg=xlate('Variable name can not be empty');
else
   errMsg='';
   %find all characters in newName which are not letters, numbers, or underscores
   absName=abs(newName);
   if isPunctOk
      invalidIndex=find(~(...
         (absName>=abs('0') & absName<=abs('9')) | ...
         (absName>=abs('a') & absName<=abs('z')) | ...
         (absName>=abs('A') & absName<=abs('Z')) | ...
         absName==abs('_') | ...
         absName==abs('.') | ...
         absName==abs('(') | ...
         absName==abs(')') | ...
         absName==abs('{') | ...
         absName==abs('}') | ...
         absName==abs(':') | ...
         absName==abs('[') | ...
         absName==abs(']') | ...
         absName==abs(',') ));
      punctString=' and punctuation marks.';
   else
      invalidIndex=find(~(...
         (absName>=abs('0') & absName<=abs('9')) | ...
         (absName>=abs('a') & absName<=abs('z')) | ...
         (absName>=abs('A') & absName<=abs('Z')) | ...
         absName==abs('_') ));
      punctString='.';
   end
   if ~isempty(invalidIndex)
      newName(invalidIndex)=ones(1,length(invalidIndex))*'_';
      errMsg=sprintf('Variable name should contain only alphanumeric characters%s', punctString);
   end
   
   %Search for non-alpha characters at beginning
   while ~isempty(newName) & ...
         ~((newName(1)>='a' & newName(1)<='z') | ...
         (newName(1)>='A' & newName(1)<='Z'))
      newName=newName(2:end);
      errMsg=sprintf('First character in variable names should contain only alpha characters.');
   end
   
   if isempty(newName)
      okName=oldName;
   else
      idLength = namelengthmax;
      if ~isPunctOk & length(newName)>idLength
         newName=newName(1:idLength);
         errMsg=sprintf('Variable names must be less than %i characters long',idLength+1);
      end
      okName=newName;
   end
end

out{1}=okName;
out{2}=errMsg;

if ~isempty(editHandle)
   set(editHandle,'String',okName);
end




