function out=execute(c)
%EXECUTE generates report contents
%   OUT=EXECUTE(CSLSIM)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:44 $

out='';

mdlName=c.zslmethods.Model;

if ~isempty(mdlName)
   if c.att.useMDLioparam
      outStr='';
   else
      if isempty(c.att.timeOut) | isempty(c.att.statesOut) ...
            isempty(c.att.matrixOut)
         status(c,...
		     'Warning - I/O Parameter empty.  Using model defaults instead.',2);
         outStr='';
      else
         outStr=['[',c.att.timeOut,','...
               ,c.att.statesOut,',',c.att.matrixOut,']='];
      end
   end
   
   %Get sim time string
   timeStr=LocSimTime(c,mdlName);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%% SET UP SIMULATION PARAMETERS STRUCTURE %%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
   if ~isempty(c.att.simparam)
      options=makeoptionstruct(c,c.att.simparam,mdlName);
      
      un=LocUniqName;
      assignin('base',un,options);
      
      postString=[',' un ');clear(''' un ''');'];
   else
      postString=');';
   end
   
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%% CREATE STRING TO BE EVALUATED IN WORKSPACE %%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   evalStr=sprintf('%ssim(''%s'',%s%s',...
      outStr,...
      mdlName,...
      timeStr,...
      postString);
  
   %force an RTW compile before simulation so that later
   %compiles do not clear out scopes
   fid = get_rtw_fid(c.zslmethods,mdlName);
   if fid>0
       fclose(fid);
   end

   %disable graphical debugging in SF
   machineID=sf_model_2_machine(mdlName);
   if ~isempty(machineID)
       oldAnimation=sf('get',machineID,'.debug.animation.enabled');
       sf('set',machineID,'.debug.animation.enabled',0);
   else
       oldAnimation = 0;
   end
   
   try
      evalin('base',evalStr);
   catch
      status(c,{sprintf(...
	        'Error - Could not simulate model.        Reason:  %s',...
			 strrep(lasterr,sprintf('\n'),' '))},1);
   end
   
   if oldAnimation
       sf('set',machineID,'.debug.animation.enabled',oldAnimation);
   end
   
   if c.rptcomponent.DebugMode
      status(c,evalStr,4);
   end
else
   status(c,'Warning - could not find Model to simulate',2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function un=LocUniqName(c)
%finds a unique name in the MATLAB workspace

basevars=evalin('base','whos');
basevars={basevars.name};

un='TEMP_RPTGEN_SIMPARAMS';

while ismember(un,basevars);
   un=[un,'x'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% GET START AND END TIME PARAMETERS %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timeStr=LocSimTime(c,mdlName)

if c.att.useMDLtimespan
   isUseStrings=logical(0);
   try
      tStart=get_param(mdlName,'StartTime');
   catch
      tStart='';
      isUseStrings=logical(1);
   end
   try
      tEnd=get_param(mdlName,'StopTime');
   catch
      tEnd='';
      isUseStrings=logical(1);
   end
else
   tStart=c.att.startTime;
   tEnd=c.att.endTime;
   isUseStrings=logical(1);
end

varList=evalin('base','whos');
varList={varList.name};

%------Test start number ----------
[tStartNumber,tStart,isUseStrings]=...
   LocNumericValue(tStart,isUseStrings,varList);

if isempty(tStartNumber)
   startWarn='Empty';
elseif any(isinf(tStartNumber))
   startWarn='Infinite';
else
   startWarn='';
end

if ~isempty(startWarn)
   status(c,sprintf(...
      'Warning - %s start time.  Starting at 0 seconds.',startWarn),...
      2);
   isUseStrings=logical(1);
   tStart='0';
end

%------Test end number ----------
[tEndNumber,  tEnd,  isUseStrings]=...
   LocNumericValue(tEnd  ,isUseStrings,varList);

if isempty(tEndNumber)
   endWarn='Empty';
elseif any(isinf(tEndNumber))
   endWarn='Infinite';
else
   endWarn='';
end

if ~isempty(endWarn)
   status(c,sprintf(...
      'Warning - %s end time.  Running for 60 seconds.',endWarn),...
      2);
   isUseStrings=logical(1);
   tEnd=[tStart '+60'];
end

if isUseStrings
   timeStr=['[' tStart ' ' tEnd ']'];
else
   timeStr='[]';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tNumber,tString,isError]=LocNumericValue(tString,isError,varList);

if isempty(tString)
   tNumber=[];
elseif isnumeric(tString)
   tNumber=tString;
   tString=num2str(tNumber);
elseif ischar(tString)
   tNumber=str2num(tString);
   if isempty(tNumber)
      tNumber=nan;
      if LocSecurityCheck(tString,varList)
         %if the string does not evaluate directly to a string, try evaluating
         %it in the base workspace to make sure it's not inf
         try
            tNumber=evalin('base',tString);
         end
      end
   end
else
   tNumber=[];
   tString='';
   isError=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isOK=LocSecurityCheck(tString,varList)
%this function checks a string to see if it is OK to
%evaluate it in the workspace.

%assume that if the "words" contained in the string are all
%workspace variables that it is OK to eval the string and
%check for infs.

stringWords=LocFindWords(tString);
notVariableWords=setdiff(stringWords,varList);
isOK=isempty(intersect(notVariableWords,...
   {'clear','delete','close','error'}));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allWords=LocFindWords(valStr)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineID=sf_model_2_machine(mdlName)
%MODEL_2_MACHINE returns the machine ID for a Simulink model
%    MACHINEID=MODEL_2_MACHINE(MDLNAME)
%
%    MDLNAME can be a handle or single model name.


machineID = [];

try
    searchMachines=sf('get','all','machine.id');
    mdlHandle = get_param(mdlName,'Handle');
    machineID = sf('find',searchMachines,'.simulinkModel',mdlHandle);
end
    