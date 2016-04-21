function varargout=getrptname(c,SetupFileName)
%GETRPTNAME returns the name of the current report
%   [DIR,FILE,EXT]=GETRPTNAME(C)
%        Returns the name of the report output directory, file, and extension
%   [DIR,FILE,EXT,C]=GETRPTNAME(C)
%        Returns the name of the report output directory, file, and extension
%        Also sets the following fields
%            c.ref.SourceFileName=DIR/FILE .sgml
%            c.ref.ReportFileName=DIR/FILE EXT;
%            c.rptcomponent.ReportDirectory=DIR;
%            c.rptcomponent.ReportFilename=FILE;
%            c.rptcomponent.ReportExt=EXT;
%
%   With either syntax, GETRPTNAME(C,SETFILENAME) specifies the name
%   of the current setup file.  This is useful when the report name 
%   or directory are inherited from the setup file.
%
%   See also COUTLINE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:25 $

if nargin<2
   SetupFileName=c.rptcomponent.SetfilePath;
end

[sPath sName sExt sVer]=fileparts(SetupFileName);
if isempty(sName)
   sName='Unnamed';
end
if isempty(sPath)
   sPath=pwd;
end

switch c.att.DirectoryType
case 'setfile'
   rDir=sPath;
case 'pwd'
   rDir=pwd;
otherwise
   rDir=parsevartext(c.rptcomponent,c.att.DirectoryName);
	rDir=strrep(rDir,'%<','');
   rDir=strrep(rDir,'>','');
   
   if isempty(rDir)
      rDir = pwd;
   elseif exist(rDir) ~= 7
		rDir = pwd;
   end
end

switch c.att.FilenameType
case 'setfile'
   rName=sName;
otherwise
   rName=parsevartext(c.rptcomponent,c.att.FilenameName);
   rName=strrep(rName,'%<','');
   rName=strrep(rName,'>','');
end

%%%%%%%%%% Get the appropriate extension %%%%%%%%%%%%%
fInfo=preferences(rptparent);
fInfo=fInfo.format;

formatIndex=find(strcmpi({fInfo.Name},c.att.Format));
if ~isempty(formatIndex)
   rExt=fInfo(formatIndex(1)).Ext;
else
   rExt='html';
end

if c.att.isIncrementFilename
   numSame=length(dir([fullfile(rDir,rName) '*' rExt]));
   rName=[rName num2str(numSame)];
end

%%%%%%%%%%% Set output arguments %%%%%%%%%%%%%%%%%%%%
if nargout<5
   if nargout>0
      varargout{1}=rDir;
      if nargout>1
         varargout{2}=rName;
         if nargout>2
            varargout{3}=rExt;
            if nargout>3            
               c.ref.SourceFileName=fullfile(rDir,[rName,'.sgml']);
               c.ref.ReportFileName=fullfile(rDir,[rName '.' rExt]);
               varargout{4}=c;
               
               c.rptcomponent.ReportDirectory=rDir;
               c.rptcomponent.ReportFilename=rName;
               c.rptcomponent.ReportExt=rExt;
            end
         end
      end
   end
else
   error('Invalid number of output arguments');
end