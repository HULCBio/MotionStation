function result = log_file_manager(cmd, targetId, varargin)
%LOG_FILE_MANAGER( CMD, TARGETID, VARARGIN )  Manages a target's logfile.

%   E.Mehran Mestchian, Jay R. Torgerson
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.19.2.4 $  $Date: 2004/04/15 00:58:38 $

persistent sLogFileInfo

if(isempty(sLogFileInfo))
   sLogFileInfo.logFileName = '';
   sLogFileInfo.memoryMode = 1;
   sLogFileInfo.logText = '';
   mlock;
end
persistent sActiveLogFile

result = '';
switch(cmd),
   case 'begin_log',           sLogFileInfo = begin_log_l(sLogFileInfo);
   case 'end_log',             sLogFileInfo = end_log_l(sLogFileInfo);
   case 'get_log',             result       = get_log_l(sLogFileInfo);
   case 'get_active_log_name', result       = sLogFileInfo.logFileName;
   case 'add_log',             sLogFileInfo = add_log_l(sLogFileInfo,varargin{1});
   otherwise,                  warning('bad parameter passed to log_file_manager');
end

%----------------------------------------------------------------------------------
function logFileInfo = begin_log_l(logFileInfo)
%
% Initiate logging
%
if(logFileInfo.memoryMode==0)
    if isempty(logFileInfo.logFileName) | exist(logFileInfo.logFileName, 'file') ~= 2,
        logFileInfo.logFileName = tempname;
    end
    fp = fopen(logFileInfo.logFileName,'w');
    if(fp==-1)
        logFileInfo.logFileName = '';
        logFileInfo.memoryMode = 1;
        logFileInfo.logText = '';
    else
        logFileInfo.memoryMode = 0;
        fclose(fp);
    end
else
    logFileInfo.logFileName = '';
    logFileInfo.memoryMode = 1;
    logFileInfo.logText = '';    
end

%----------------------------------------------------------------------------------
function logFileInfo = add_log_l(logFileInfo,msgString)
%
%
%
if(logFileInfo.memoryMode==0 & ~isempty(logFileInfo.logFileName))
   fp = fopen(logFileInfo.logFileName,'a');
   if(fp~=-1)
      fprintf(fp,'%s\n',msgString);
      fclose(fp);
   else
      %% switching to memory mode. extremely pathological.
      %% logfile became unwritable AFTER call to begin_log_l
      logFileInfo.logText = get_log_l(logFileInfo);
      logFileInfo = end_log_l(logFileInfo);
      logFileInfo.memoryMode = 1;
      logFileInfo.logText =[logFileInfo.logText,msgString,10];
   end
else
   logFileInfo.logText =[logFileInfo.logText,msgString,10];
end

	
%----------------------------------------------------------------------------------
function logFileInfo = end_log_l(logFileInfo),
%
% Terminate logging.
% 
%
   if(logFileInfo.memoryMode==0)
      if ~isempty(logFileInfo.logFileName), 
         try, sf_delete_file(logFileInfo.logFileName); end; 
      end;
      logFileInfo.logFileName = '';
   else
      logFileInfo.logText = '';
   end


%----------------------------------------------------------------------------------
function msg = get_log_l(logFileInfo),
%
% Returns the contents of the logfile or -1 if the log is too big.
%
	msg = '';
   if(logFileInfo.memoryMode==0 & ~isempty(logFileInfo.logFileName))
      fid = fopen(logFileInfo.logFileName,'rt');
      if(fid<=2)
         msg = '';
         return;
      end;
      msg = fread(fid,'*char')';
      fclose(fid);
   else
      msg = logFileInfo.logText;
   end

   