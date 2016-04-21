function varargout=rptviewfile(varargin)
%RPTVIEWFILE launches a viewer for input files
%   RPTVIEWFILE <FILENAME.EXT> launches a viewer for the file.  Multiple
%   file names may be passed in.  Use the functional form of the 
%   command RPTVIEWFILE('FILENAME') if the name contains spaces.
%
%   OK=RPTVIEWFILE('FILENAME1.EXT','FILENAME2.EXT') will return a
%   logical vector showing whether the file was launched properly
%   or not.
%
%   [OK,MSG]=RPTVIEWFILE('FILENAME1.EXT','FILENAME2.EXT') will
%   return a logical array and a cell array containing error 
%   messages.  Errors will not be displayed to the screen and will
%   not halt execution of the function.

%   Viewer launch commands are defined in RPTPARENT/PREFERENCES 
%   and can be edited by the user.
%
%   See also RPTPARENT/PREFERENCES.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:54 $

prefs=preferences(rptparent);
allCommands=prefs.ExtViewCmd;

%if nargout==2, errors/warnings/messages are saved to a string and not
%written to screen.  
dispErrors=(nargout<2);

for i=1:length(varargin)
   origFileName=varargin{1};
   if length(findstr(origFileName,'.'))==0
      fileName=[origFileName '.'];
   else
      fileName=origFileName;
   end
   
   fullFile=which(fileName);
   if any(strcmp({'built-in','variable'},fullFile))
      fullFile='';
   elseif isempty(fullFile) & exist(fileName)==2
      fullFile=fileName;
   end
   
   if ~isempty(fullFile)
      dotIndex=findstr(fullFile,'.');
      extID='EMPTY';
      if length(dotIndex)>0
         dotlessExt=fullFile(dotIndex(end)+1:end);
         if length(dotlessExt)>0
            extID=lower(dotlessExt);
         end
      end
      
      if isfield(allCommands,extID)
         %get the execution string and substitute the file name in
         execString=getfield(allCommands,extID);
         execString=strrep(execString,'%<FileName>',fullFile);
         try
            %launch the viewer
            evalin('base',execString);
            ok(i)=logical(1);
         catch
            ok(i)=logical(0);
         end
         
         if ok(i)
            statusString=(sprintf('File viewer for "%s" launched.',fullFile));
         else
            statusString=(sprintf('File viewer for "%s" could not be launched.',fullFile));
         end
         
      else
         ok(i)=logical(0);
         statusString=(sprintf('Extension "%s" has no view command.',extID));
      end
   else %if which(fullFile) was empty
         ok(i)=logical(0);
         statusString=(sprintf('File "%s" not found.',origFileName));
   end
   
   %if we are not outputting status messages and the viewer was
   %not launched successfully, throw an error.  Otherwise, put the error
   %message into the errMsg cell array
   if dispErrors
      if ~ok(i)
         error(statusString);
      end
   else
      errMsg{i}=statusString;
   end
   
end

if nargout>0
   varargout{1}=ok;
   if ~dispErrors %dispErrors happens when varargou==2
      varargout{2}=errMsg;
   end
end