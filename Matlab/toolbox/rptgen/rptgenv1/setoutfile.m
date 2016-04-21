function varargout=setoutfile(SetupFileName,OutputFileName,isIncrement)
%SETOUTFILE changes the name of the report output file
%   SETOUTFILE(SETFILENAME,OUTFILENAME) changes the setup
%   file specified in SETFILENAME so that when it is run 
%   it will produce its output to the filename specified in
%   OUTFILENAME.  If a path is specified in OUTFILENAME, the
%   path will also be set to the specified directory, otherwise
%   the output directory will be set to the present working
%   directory.  File extensions in OUTFILENAME are ignored.
%
%   SETOUTFILE(SETFILENAME) changes the setup file so that
%   it will automatically write its output file to the same
%   filename and directory as SETFILENAME.
%
%   SETOUTFILE(SETFILENAME,OUTFILENAME,INCREMENT) where
%   INCREMENT is 'on' or 'off' changes the setup file
%   such that its "Increment report filename" option is
%   turned on or off.
%
%   S=SETOUTFILE(...) returns a handle to the setup file and
%   does not save the naming changes to the file.  Use
%   SAVESETFILE(S) to save the file and GENERATEREPORT(S) to
%   create your report.
%
%   See also REPORT, SETEDIT, RPTLIST, RPTCONVERT, COMPWIZ

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:56 $

[s,ok]=loadsetfile(rptparent,SetupFileName);

if ok
   c=children(s);
   if nargin>1
      [oPath oFile oExt oVer]=fileparts(OutputFileName);
      
      if ~isempty(oFile)
         c.att.FilenameType='other';
         c.att.FilenameName=oFile;
      else
         c.att.FilenameType='setfile';
      end
      
      if ~isempty(oPath)
         c.att.DirectoryType='other';
         c.att.DirectoryName=[oPath filesep];
      else
         c.att.DirectoryType='pwd';
      end
            
      if nargin>2
         if isnumeric(isIncrement)
            c.att.isIncrementFilename=isIncrement(1);
         elseif ischar(isIncrement) & strcmpi(isIncrement,'on')
            c.att.isIncrementFilename=logical(1);            
         elseif ischar(isIncrement) & strcmpi(isIncrement,'off')
            c.att.isIncrementFilename=logical(0);
         else
            error('Increment value must be ''on'' or ''off''.')
         end
      end
   else
      %the only argument in is the setfile name
      c.att.DirectoryType='setfile';
      c.att.FilenameType='setfile';
   end %if nargin>1
   
   if nargout>0
      varargout{1}=s;
   else
      savesetfile(s);
      delete(s);
   end
else
   error('Error - setup file not loaded properly');
end