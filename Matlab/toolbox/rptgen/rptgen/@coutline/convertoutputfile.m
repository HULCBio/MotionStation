function [reportName,errorMessages]=convertoutputfile(c)
%CONVERTOUTPUT  Transform SGML source to desired output format
%   RPTNAME=CONVERTOUTPUT(C) where C is a COUTLINE 
%   report generator component.
%
%   SEE ALSO: COUTLINE, RPTCONVERT

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:21 $

%--------1---------2---------3---------4---------5---------6---------7---------8

myFormat=LocFormatInfo(c);
mySheet=LocSheetInfo(c,myFormat);

mySheet.sourcename = c.ref.SourceFileName;
mySheet.reportname = c.ref.ReportFileName;
mySheet.Language   = c.rptcomponent.Language;

if isfield(c.ref,'XML')
	mySheet.XML = c.ref.XML;
else
	mySheet.XML = false;
end

%run JADE
switch lower(myFormat.Name)
case 'pdf'
   pdfName=mySheet.reportname;
   mySheet.reportname=LocChangeExt(pdfName,'rtf');
   
   [rtfName,errorMessages]=LocRunJade(...
      mySheet,...
      myFormat,...
      c.att.isDebug);
   
   if ~isempty(rtfName)
      [okConvert,pdfErrMsg]=docview(rtfName,...
         'UpdateFields',...
         'PrintPDF',...
         'CloseApp');
   else
      okConvert=0;
      pdfErrMsg='Error - RTF file not produced, can not convert to PDF';
   end
   
   if ~isempty(pdfErrMsg)
      errorMessages{end+1}=pdfErrMsg;
   end
   if okConvert
      reportName=pdfName;
   else
      reportName=rtfName;
   end
case 'tex'
   [texName,errorMessages]=LocRunJade(...
      mySheet,...
      myFormat,...
      c.att.isDebug);
   
   if ~isempty(texName)
      transformString=['tex "&jadetex" "' reportName '"'];
      [okConvert,texErrMsg]=LocSystemCall(transformString,'-echo');
   else
      okConvert=0;
      texErrMsg='Error - TeX file not produced, can not convert to DVI.';
   end
   
   if ~isempty(texErrMsg)
      errorMessages{end+1}=texErrMsg;
   end
   
   if okConvert
      reportName=LocChangeExt(texName,'dvi');
   else
      reportName=texName;
   end
otherwise
   [reportName,errorMessages]=LocRunJade(...
      mySheet,...
      myFormat,...
      c.att.isDebug);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [reportName,errorMessages]=LocRunJade(mySheet,myFormat,isDebug)

%isDebug=1;

if isempty(mySheet.Filename)
   reportName=mySheet.sourcename;
   errorMessages={'No target filename specified'};
   return
end

if strcmp(myFormat.JadeBackend,'sgml')
   chunkStr=mySheet.Variables';
   if isempty(findstr([chunkStr{:}],'nochunks#t'))
      %The stylesheets must redirect for nochunks #f and doctype="Sect1"
      %check mySheet.sourcename for the doctype
      isChunked=logical(1);
      snFID=fopen(mySheet.sourcename,'r');
      if snFID>0
         headerString=char(fread(snFID,32,'char'))';
         fclose(snFID);
         
         if ~isempty(findstr(headerString,'Sect1'))
            isChunked=logical(0);
         end
      end
      
      if isChunked
         callForm=3; %specified
      else
         callForm=2;
      end
   else
      callForm=2; %redirection
   end
else
   callForm=1; %-o call
end


jadeExecutable=LocJadeDir;
catalogFile=fullfile(matlabroot,'sys','jade','docbook','dtd','docbook.cat');
[rPath rFile rExt rVer]=fileparts(mySheet.sourcename);
%errorFile=fullfile(rPath,'JadeErrors.txt');

driverFile=LocMakeDriverFile(mySheet);
if isempty(driverFile)
   reportName='';
   errorMessages={
      'RPTGEN:E:Could not write driver file "rptdriver.dsl".'
      'RPTGEN:E:Check directory and file permissions.'
   };
   return;
end

JadeString=['"' jadeExecutable '"' ...
      ' -E 5000',... %increase number of returned errors
      ' -c "' catalogFile '"' ... %      ' -e "' errorFile '"' ...
      ' -t ' myFormat.JadeBackend ...
      ' -d "' driverFile '"'];

%if strcmpi(mySheet.sourcename(end-3:end),'.xml')
%	JadeString = [JadeString,...
%		' "',fullfile(matlabroot,'sys','jade','shared','xml.dcl'),'" '];
%end
  
reportName=mySheet.reportname;
[rptDir rptFile rptExt rptVer]=fileparts(mySheet.reportname);

if mySheet.XML
	xmlFile=fullfile(matlabroot,'sys','jade','docbook','dtds','decls','xml.dcl');
	xmlFile = [' "',xmlFile,'" '];
else
	xmlFile = '';
end

switch callForm
case 1 %standard JADE call: -o filename
   JadeString=[JadeString, ... 
	   ' -o "' mySheet.reportname '"', ...
	   xmlFile,...
         ' "' mySheet.sourcename '"'];   
case 2  %redirected SGML backend call:  > filename
   JadeString=[JadeString ...
	     xmlFile ...
         ' "' mySheet.sourcename '"' ...
         ' > "' mySheet.reportname '"'];
case 3  %specified SGML backend call: 
   JadeString=[JadeString ...
	     xmlFile ...
         ' "' mySheet.sourcename '"'];
   %reportName=fullfile(rptDir,'book1.htm');
   %This is no longer needed since chunked output 
   %honors filenames
end

%----------- run JADE ------------------------

%change directory to the directory in which the 
%report is being produced.  (Mainly for the benefit of
%Jade call case 3)
oldDir=pwd;
cd(rptDir);

%Delete the previously existing report to prevent
%problems with 'noclobber' on UNIX machines.
if (exist(mySheet.reportname,'file')==2)
    try
        delete(mySheet.reportname);
    catch
		clobberErrorMessage=sprintf('RPTGEN:W:Could not delete file %s prior to conversion',mySheet.reportname);        
    end
end

%Primary JADE transform system call
[error,result]=LocSystemCall(JadeString);

if error~=0 | LocIsResultError(result)
   reportName='';
end

cd(oldDir);

if ~isDebug
   try
      delete(driverFile);
   catch
      warning('Could not delete driver file "rptdriver.dsl".');
   end
else
   disp(JadeString);
end

errorMessages=LocWashErrors(result);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clean=LocWashErrors(messy)
%removes the beginning of JADE error messages
%and formats results into a cell array

%eol "end of line"
eol=findstr(messy,sprintf('\n'));
eol=[0,eol];

clean={};
if length(eol)>1
   for i=2:length(eol)
      line=messy(eol(i-1)+1:eol(i)-1);
      fileseps=findstr(line,filesep);
      if ~isempty(fileseps)
         line=line(fileseps(length(fileseps))+1:end);
      end
      clean{end+1}=line;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myFormat=LocFormatInfo(c,formatName);

if nargin<2
   formatName=c.att.Format;
end

prefs=preferences(c);

formatNames={prefs.format(:).Name};
formatIndex=find(strcmpi(formatNames,formatName));
if isempty(formatIndex)
   formatIndex=1;
else
   formatIndex=formatIndex(1);
end
myFormat=prefs.format(formatIndex);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mySheet=LocSheetInfo(c,myFormat,styleName);

if nargin<3
   styleName=c.att.Stylesheet;
end

sheets=stylesheets(c);

sheetIndex=find(strcmpi({sheets(:).ID},styleName));
if isempty(sheetIndex) | ...
      ~any(strcmpi(sheets(sheetIndex(1)).Formats,myFormat.Name))
   sheetIndex=[];
   i=1;
   while i<=length(sheets) & isempty(sheetIndex)
      if any(strcmpi(sheets(i).Formats,myFormat.Name))
         sheetIndex=i;
      else
         i=i+1;
      end
   end
end

if ~isempty(sheetIndex)
   mySheet=sheets(sheetIndex(1));
else
   mySheet=struct('Name','NoSheet',...
      'ID','',...
      'Formats',{{}},...
      'Description','',...
      'Filename','',...
      'Variables',{{}},...
      'Overlays',{{}});
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jd=LocJadeDir

archDir=lower(computer);
switch archDir(1:2)
    case 'pc'
        archDir='win32';
        %jadeFile='openjade.exe';
        jadeFile='jade.exe';
    case {'ma','gl'}
		%we use openjade for osx and linux
        jadeFile = 'openjade';
    otherwise
        jadeFile='jade';
end

%Search current directory first
jd=fullfile(pwd,jadeFile);
if exist(jd)==2
    jd=LocCheckNetwork(jd);
    return;
end

%Search in bin
jd=fullfile(matlabroot,'sys','jade','bin',jadeFile);
if exist(jd)==2
    jd=LocCheckNetwork(jd);
    return;
end

%Search in bin/arch
jd=fullfile(matlabroot,'sys','jade','bin',archDir,jadeFile);
if exist(jd)==2
    jd=LocCheckNetwork(jd);
    return;
end

%couldn't find jade file
warning('Could not find document transform engine');
jd=jadeFile;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jd=LocCheckNetwork(jd)
%Jade 1.2.1 and Jade 1.3 do not like being called from
%PC network drives, unc or mapped.  Copy JADE executable
%files to a local tempdir

if ispc
    [ok,result]=dos(sprintf('"%s" -ver',jd));
    if isempty(result)
        %JADE is not working properly but the file exists.
        %this means we're working from a network drive
        [jDir,jFile,jExt]=fileparts(jd);

        
        [mStatus,mMsg]=mkdir(tempdir,'jade_temp');
        jdRoot=fullfile(tempdir,'jade_temp');
        
        jd=fullfile(jdRoot,[jFile,jExt]);

        persistent jadeCopiedYet
        
        if isempty(jadeCopiedYet) | exist(jd)~=2
            %if jade exists in the tempdir, expect sx,nsgmls, and
            %the other supporting files are there too.
            %This copyfile is an expensive operation, so we do not
            %clean up afterwards in the expectation that there
            %will be other reports generated which will also
            %need jade in temp.
            %
            %Always force copying JADE the first time in any session
            %to make sure we're dealing with the correct version.
            %
            jadeCopiedYet=logical(1);
            
            copyfile(fullfile(jDir,    'grove.dll'   ),jdRoot);
            copyfile(fullfile(jDir,    'groveoa.dll' ),jdRoot);
            copyfile(fullfile(jDir,    'jade.exe'    ),jdRoot);
            copyfile(fullfile(jDir,    'msvcrt.dll'  ),jdRoot);
            copyfile(fullfile(jDir,    'nsgmls.exe'  ),jdRoot);
            copyfile(fullfile(jDir,    'sgmlnorm.exe'),jdRoot);
            copyfile(fullfile(jDir,    'sp132.dll'   ),jdRoot);
            copyfile(fullfile(jDir,    'spam.exe'    ),jdRoot);
            copyfile(fullfile(jDir,    'spent.exe'   ),jdRoot);
            copyfile(fullfile(jDir,    'spgrove.dll' ),jdRoot);
            copyfile(fullfile(jDir,    'style.dll'   ),jdRoot);
            copyfile(fullfile(jDir,    'sx.exe'      ),jdRoot);
            copyfile(fullfile(jDir,    'sp133.dll'   ),jdRoot);
            %disp('Copying jade to temp dir');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function driverName=LocMakeDriverFile(sheetStruct);

[sourcePath sourceFile sourceExt sourceVer]=fileparts(sheetStruct.sourcename);
driverName=fullfile(sourcePath,'rptdriver.dsl');
myFid=fopen(driverName,'w');
if myFid>0
   if ~isempty(sheetStruct.Language)
      [stylePath styleFile styleExt styleVer]=fileparts(sheetStruct.Filename);
      locEntityString=['<!ENTITY l10n SYSTEM    "',...
            fullfile(stylePath,['dbl1' sheetStruct.Language '.dsl']),...
            '" CDATA DSSSL>$CR'];
      locUseString='l10n ';
      locExternalSpecification=...
         '<external-specification id="l10n" document="l10n">$CR';
      sheetStruct.Variables(end+1,:)=...
         {'%default-language%' ['"' sheetStruct.Language '"']};
   else
      locEntityString='';
      locUseString='';
      locExternalSpecification='';
   end
   
   fileName=sheetStruct.Filename;
   entityImports='';
   htmlString=['html',filesep,'docbook.dsl'];
   htmlStringLength=length(htmlString);
   if strcmp(htmlString,fileName(end-htmlStringLength+1:end))
       fileName=[fileName(1:end-htmlStringLength-1),filesep,...
               'contrib',filesep,'imagemap',filesep,'imagemap.dsl'];
       
       %if we are producing to HTML, make sure that the parameter
       %  '%callout-graphics%' is #f
       sheetStruct.Variables(end+1,:)={'%callout-graphics%','#f'};
   else
       %we are using the print backend.  Be sure to use my textlink
       %customization.
       locEntityString = sprintf('%s<!ENTITY tmwlink SYSTEM "%s">',...
           locEntityString,...
           fullfile(matlabroot,'sys','jade','docbook','contrib','textlink','textlink.dsl'));
       entityImports = '$CR&tmwlink;$CR';
       %sheetStruct.Overlays{end+1}=fullfile(matlabroot,'sys','jade','docbook','contrib','textlink','textlink.dsl');
   end
   
   %if ispc
       %We are using OpenJade 1.3 on PC, which requires a different style sheet owner
   %    styleOwner='OpenJade';
   %else
       styleOwner='James Clark';
   %end
      
   drvHeader=['<!DOCTYPE style-sheet PUBLIC ',...
         '"-//' styleOwner '//DTD DSSSL Style Sheet//EN" [$CR',...
         '<!ENTITY dbstyle SYSTEM "' fileName '" CDATA DSSSL>$CR',...
         locEntityString,...
         ']>$CR',...
         '$CR',...
         '<style-sheet>$CR',...
         '<style-specification use="',locUseString,'docbook">$CR',...
         '<style-specification-body>$CR',...
         entityImports,...
         '$CR'];
   
   %Define global variables
   drvVariables='';
   for i=1:size(sheetStruct.Variables,1)
      drvVariables=[drvVariables,...
            '(define ' sheetStruct.Variables{i,1} ' $CR '...
            '$TAB' sheetStruct.Variables{i,2} ')$CR'];   
   end
   
   %import DSSSL script fragments
   drvDSSSL='';
   for i=1:length(sheetStruct.Overlays)
      [oPath oFile oExt oVer]=fileparts(sheetStruct.Overlays{i});
      if strcmpi(oExt,'.m')
         %run the specified m-file to produce a DSSSL fragment
         
      elseif strcmpi(oExt,'.dsl')
         %import the specified DSSSL fragment
         dslFID=fopen(sheetStruct.Overlays{i},'r');
         if dslFID>0
            drvDSSSL=[drvDSSSL,char(fread(dslFID)')];
            fclose(dslFID);
         end
      end
   end
   
   
   drvFooter=['$CR'...
         '</style-specification-body>$CR'....
         '</style-specification>$CR'...
         '<external-specification id="docbook" document="dbstyle">$CR'...
         locExternalSpecification,...
         '</style-sheet>$CR'];
   
   drvString=[drvHeader '$CR' drvVariables '$CR' drvDSSSL '$CR' drvFooter];
   drvString=strrep(drvString,'\','\\');
   drvString=strrep(drvString,'%','%%');
   drvString=strrep(drvString,'$CR','\n');
   drvString=strrep(drvString,'$TAB','\t');
   
   fprintf(myFid,drvString);
   fclose(myFid);
else
   driverName='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [error,result]=LocSystemCall(varargin)

switch computer
case 'PCWIN'
   %JadeString=['"' JadeString '"'];
   
   if length(varargin{1})>120
       %Command is long and may bump against the DOS character limit.
       %create a temporary batch file 
       batFileName = [tempname,'.bat'];
       fid = fopen(batFileName,'w');
       fwrite(fid,'@ECHO OFF'); %don't echo the calling string back to RESULT
       fwrite(fid,[char(13) char(10)]);  %using DOS-style linebreaks is significant here
       fwrite(fid,varargin{1});
       fclose(fid);
       varargin{1}=['"',batFileName,'"'];
   else
       batFileName = '';
   end
   
   [error,result] = dos(varargin{:});
   %The DOS command will sometimes return a 1 if JADE
   %outputs warnings or status messages.  We set an error
   %state to 0 to prevent false negatives.
   error = 0;
   
   if ~isempty(batFileName)
       delete(batFileName);
   end
   
otherwise
   %note that the UNIX command does not support a '-echo' option.
   [error,result] = unix(varargin{1});
   %JADE on UNIX sometimes returns error=1 when in fact
   %there was no error present.  We set the error state to 0 
   %to prevent false negatives.
   error=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=LocIsResultError(result)
%checks through the result string to see if certain
%"catastrophic failure" strings are present.  These
%failure strings imply that the transform was
%not successful.

tf=logical(0);

errStrings={
   'internal or external command, operable program or batch file'
   'document does not have the DSSSL architecture as a base'
   'jade: Command not found'
   'cannot continue because of previous errors'
};

for i=1:length(errStrings)
   if ~isempty(findstr(result,errStrings{i}))
      tf=logical(1);
      break;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newFile=LocChangeExt(oldFile,newExt)
%changes the .xxx extension on a filename

[fPath,fName,fExt,fVer]=fileparts(oldFile);
newFile=fullfile(fPath,[fName '.' newExt fVer]);


