function varargout=docview(fileName,varargin)
%DOCVIEW opens an RTF/DOC viewer.
%    DOCVIEW(FILENAME) will launch an RTF/DOC file viewer for the
%    file in FILENAME.
%
%    If called with the syntax [STATUS,MESSAGE]=DOCVIEW(FILENAME), STATUS
%    will return a 1 if the file viewer was launched correctly.  If the
%    viewer was not launched, DOCVIEW will return a 0 in STATUS and a
%    description of the error in MESSAGE.
%
%    If the computer is a PC with Microsoft Word, the following commands
%    may be called in the form DOCVIEW(FILENAME,COMMAND1,COMMAND2)
%      'UpdateFields' - updates fields in the document
%      'PrintDoc'     - prints the document
%      'CloseApp'     - closes Word after all other commands are run
%   
%    You may need to configure this m-file to work with your file
%    viewer.  Go to line 62 in this file and read the instructions.
%
%    See also RPTVIEWFILE, DOCOPT, WEB
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:48 $


fileName=LocFullName(fileName,'doc','rtf','txt','sgml');
if isempty(fileName)
   isOK=0;
   errMsg='Warning - could not find file';
else
   isOK=1;
   errMsg='';
end

if isOK
   if strncmp(computer,'PC',2)
      try
         hWord = actxserver('word.application');
      catch
         isOK=0;
         errMsg='Warning - could not create Word activeX server';
         hWord=[];
      end
      
      if isOK
         %We have a Word ActiveX server running.
         [isOK,errMsg]=LocWordCommands(fileName,hWord,varargin{:});
      else
         %View the file using whatever program is registered to
         %the file's extension.
         dos(sprintf('%s &',fileName));
         
         if length(varargin)==0
            %if the user has not asked for any special commands,
            %failing to start an ActiveX server is not really an error
            isOK=1;
            errMsg='';
         end
      end
   elseif isunix
      %To configure a viewer for your UNIX system, comment out these two lines:
      isOK=0;
      errMsg='No RTF/DOC file viewer set. Type "help docview" to configure a viewer';
      
      %Decomment the next four lines.  Replace "APPNAME" with the name of your
      %RTF/DOC viewing application.  You may have to enter the full path
      %to the application.
      
      %launchString='APPNAME %s';
      %unix(sprintf(launchString,fileName));
      %isOK=1;
      %errMsg='';
      
   else
      %To configure a viewer for your system, comment out these two lines:
      isOK=0;
      errMsg='No RTF/DOC file viewer set. Type "help docview" to configure a viewer';
      
      %launchString='! APPNAME %s';
      %evalin('base',sprintf(launchString,fileName),'');
      %isOK=1;
      %errMsg='';
      
   end
end

switch nargout
case 0
   if ~isOK
      error(errMsg);
   end
case 1
   varargout={isOK};
   if ~isOK
      disp(errMsg);
   end
case 2
   varargout={isOK,errMsg};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isOK,errMsg]=LocWordCommands(fileName,hWord,varargin)

isOK=1;
errMsg='';

varargin=lower(varargin);

hDocs = hWord.documents;

try
   hDoc  = invoke(hDocs,'open',fileName);
catch
   isOK=0;
   errMsg=sprintf('Error - could not open file "%s"',fileName);
   hDoc= [];
end

if isOK
   try
      activateReturned=invoke(hDoc,'Activate');
   catch
      isOK=0;
      errMsg=sprintf('Error - could not activate file "%s"',fileName);
   end
end

i=1;
numCommands=length(varargin);
while i<=numCommands & isOK
   switch varargin{i} %note that varargin is all lowercased
   case 'updatefields'
      [isOK,errMsg]=updatefields(hDoc,fileName);
   case 'printpdf'
      [isOK,errMsg]=setprinter(hWord,'Acrobat PDFWriter');
      LocSetPdfName(LocChangeExt(fileName,'pdf'));
      if isOK
         [isOK,errMsg]=printdoc(hDoc,fileName);
      end
      while get(hWord,'BackgroundPrintingStatus')
         pause(.25);
      end
      LocSetPdfName('');
   case 'printdoc'
      [isOK,errMsg]=printdoc(hDoc,fileName);
   end
   i=i+1;
end

%Set the document as "saved" so that 
%word does not query when trying to close it.
try
   hDoc.Saved=1;
end

if any(strcmp(varargin,'closeapp'))
   %we don't want to quit if we are background printing or saving
   while get(hWord,'BackgroundPrintingStatus') | ...
         get(hWord,'BackgroundSavingStatus')
      pause(.25);
   end
   
   try
      invoke(hWord,'Quit');
   end
   %disp('Closing application');
elseif hWord.Visible==0
   %Make Word window visible
   try
      hWord.WindowState=0; %Word should not be maximized
      hWord.Visible=1;
   end
end

%%%%%% send variables to base workspace for debugging %%%%%%
%assignin('base','hWord',hWord);
%assignin('base','hDoc',hDoc);
%assignin('base','hDocs',hDocs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isOK,errMsg]=updatefields(hDoc,fileName);

%This pause needed due to timing issues.
pause(5);
try
   docRange=invoke(hDoc,'Range');
   rangeFields=docRange.Fields;
   invoke(rangeFields,'Update');
   isOK=1;
   errMsg='';
catch
   isOK=0;
   errMsg=sprintf('Error - could not update fields in file "%s"',fileName);
end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isOK,errMsg]=printdoc(hDoc,fileName);

try
   invoke(hDoc,'PrintOut');
   isOK=1;
   errMsg='';
catch
   isOK=0;
   errMsg=sprintf('Error - could not print document "%s"',fileName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isOK,errMsg]=setprinter(hWord,printerName)

try
   set(hWord,'ActivePrinter',printerName);
   isOK=1;
   errMsg='';
catch
   isOK=0;
   errMsg=sprintf('Error - printer "%s" is not available',printerName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newFile=LocChangeExt(oldFile,newExt)
%changes the .xxx extension on a filename

[fPath,fName,fExt,fVer]=fileparts(oldFile);
newFile=fullfile(fPath,[fName '.' newExt fVer]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetPdfName(fileName);

iniFile='c:\winnt40\system32\spool\drivers\w32x86\2\__PDF.INI';

fid=fopen(iniFile,'r');

propName='PDFFileName';

eol=char([13 10]);
writeStr='';
cont=1;
while cont
   line=fgets(fid);
   if ~ischar(line)
      cont=0;
   elseif strncmp(line,propName,length(propName))
      writeStr=sprintf('%s%s=%s%s',writeStr,propName,fileName,eol);
   else
      writeStr=sprintf('%s%s',writeStr,line);
   end
end

fclose(fid);

fid=fopen(iniFile,'w');

fwrite(fid,writeStr);

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName=LocFullName(fileName,varargin)

[path name ext ver]=fileparts(fileName);
if isempty(ext)
   for i=1:length(varargin)
      ext=sprintf('.%s',varargin{i});
      
      if isempty(path)
         fileName=which([name ext]);
      else   
         fileName=fullfile(path,[name ext ver]);
      end
      if ~isempty(fileName)
         break
      end
   end
elseif isempty(path)
   fileName=which(fileName);
end

