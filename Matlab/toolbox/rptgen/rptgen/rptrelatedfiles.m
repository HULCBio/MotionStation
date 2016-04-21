function files=rptrelatedifles(fileName)
%RPTRELATEDFILES finds all files related to a file
%   RELATEDFILES=RPTRELATEDFILES(SOURCEFILE) 
%   
%   RELATEDFILES is a cell array of files "related" to the source file. 
%   All file names are returned as full file paths.  The definition of
%   related differs according to the file type of the source:
%
%   (.rpt) Report Generator Setup File
%        * the setup file
%        * the SGML file the setup file would produce given the pwd
%        * the report file the setup file would produce given the pwd
%        * any files related to the report file
%   (.sgml) SGML Intermediate Files
%        * The SGML file
%        * Any report document files with the same name as the SGML file
%        * Any files related to the report document files
%   (.html, .rtf, etc) Report Document Files
%        * The document file
%        * Related image files in /docfile_ext_files/

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:53 $

if nargin<1
   error('File name not specified');
   return;
end

[fDir,fFile,fExt,fOther]=fileparts(fileName);

if isempty(fDir)
   newFileName=which(fileName);
   if isempty(newFileName)
      files={};
      return;
   else
      [fDir,fFile,fExt,fOther]=fileparts(newFileName);
   end
end

files=LocRelated(fDir,fFile,fExt);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function relFiles=LocRelated(fDir,fFile,fExt)

switch fExt
case '.rpt'
   rptName=fullfile(fDir,[fFile,fExt]);
   if exist(rptName)==2
      [s,ok]=loadsetfile(rptparent,rptName);
      if ~ok
         relFiles={};
         return;
      else
         relFiles={rptName};
      end
      
      olComp=get(children(s),'UserData');
      %children(s) returns the setup file's "coutline" component.
      [fDir,fFile,fExt]=getrptname(olComp,rptName);
		sgmlFile=fullfile(fDir,[fFile,'.sgml']);
      if exist(sgmlFile)==2
         relFiles{end+1,1}=sgmlFile;
      end
      
      relFiles=[relFiles;LocRelated(fDir,fFile,['.' fExt])];
      
      delete(s);
      
   else
      relFiles={};
   end
case '.sgml'
   sameName=dir(fullfile(fDir,[fFile,'.*']));
   relFiles={};
   
   for i=1:length(sameName)
      if isExtension(sameName(i).name,'.sgml');
			relFiles{end+1,1}=fullfile(fDir,sameName(i).name);
      elseif ~isExtension(sameName(i).name,'.rpt');
         [sDir,sFile,sExt,sOther]=fileparts(sameName(i).name);
         relFiles=[relFiles;LocRelated(fDir,sFile,sExt)];
      end
   end
case {'.m','.mat'}
   %do nothing
   relFiles={};
otherwise
   %we assume all other extensions are possible document formats
   fullName=fullfile(fDir,[fFile,fExt]);
   if exist(fullName)
      if length(fExt)>1
         dotlessExtension=lower(fExt(2:end));
      else
         dotlessExtension='';
      end
      
      extraFileDir=fullfile(fDir,...
         [fFile '_' dotlessExtension '_files']);
      
      extraFiles=dir(fullfile(extraFileDir,...
         '*.*'));
      extraFileNames={extraFiles.name};
      extraFileNames=extraFileNames(~[extraFiles.isdir]);
      if ~isempty(extraFileNames)
         
         extraFileNames=strcat([extraFileDir filesep],...
            extraFileNames);
         relFiles=[{fullName};extraFileNames(:)];
      else
         relFiles={fullName};
      end
   else
      relFiles={};
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=isExtension(file,ext)

lExt=length(ext);

tf= (length(file)>=length(ext) & ...
	strcmpi(file(end-lExt+1:end),ext));


