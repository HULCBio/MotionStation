function varargout=docblock(varargin)
%DOCBLOCK  Simulink documentation block
%   DOCBLOCK manages the Simulink documentation block
%
%   The DocBlock can edit HTML and RTF files as well as plain text.  Do
%   SET_PARAM(BLKH,'DocumentType','HTML') or use the "Mask Parameters"
%   dialog to change the type of document associated with the block.
%   
%   On PC systems, RTF and HTML files will be opened in Microsoft (TM)
%   Word.  Otherwise, the document content will be opened in the MATLAB
%   editor.  To change this behavior, use the commands:
%
%   DOCBLOCK('setEditorHTML',EDITCMD)
%   DOCBLOCK('setEditorDOC',EDITCMD)
%   DOCBLOCK('setEditorTXT',EDITCMD)
%
%   where EDITCMD is a string to be evaluated at the command line to launch
%   a custom application.  The special token %<FileName> will be replaced
%   with the full path to the file.  For example, to use Mozilla Composer
%   as your HTML editor, use the command:
%
%   docblock('setEditorHTML','system(''/usr/local/bin/mozilla -edit "%<FileName>" &'');')
%
%   To return to the default behavior, use an empty string ('') as EDITCMD
%
%   To get the current edit command settings, type:
%
%   EDITCMD = DOCBLOCK('getEditorHTML')
%   EDITCMD = DOCBLOCK('getEditorDOC')
%   EDITCMD = DOCBLOCK('getEditorTXT')
%
%   Custom editor commands persist between MATLAB sessions.
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.4 $

%DocBlock parameters:
%      DeleteFcn		  "docblock('close_document',gcb);"
%      PreSaveFcn	      "docblock('save_document',gcb);"
%      OpenFcn		      "docblock('edit_document',gcb);"

%Enhancements:
% Install listeners on the editor so that when document is saved, changes are pushed to model
% Put inports on block to allow it to be hooked to a signal

if nargin==0
	varargout{1} = addToSystem;
elseif nargout==0
    feval(varargin{:});
else    
	[varargout{1:nargout}]=feval(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function fName=getBlockFileName(blkName)
%Every block has a unique file name associated with it.
%This function returns that file.
%
% PRIVATE: This function is not guaranteed to remain stable

blkHandle = get_param(blkName,'handle');

try
	docExt = lower(get_param(blkName,'DocumentType'));
catch
	%This probably means that we have an old-style block which needs to be
	%upgraded.
	convert_legacy_block(blkName);
	docExt = 'txt';
end

if strcmp(docExt,'text')
	docExt = 'txt';
end

%todo: write file name by parent system and block name
%Be sure to strrep invalid characters from the filename
%(customer requested enhancement)

fName = fullfile(tempdir,['docblock-',...
        strrep(sprintf('%0.12g',blkHandle),'.','-'),...
        '.',docExt]);
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function breaklink(blkName)
%This is not used anymore.  Left around for legacy DocBlocks which still
%call docblock('breaklink') with their CopyFcn

%noop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName=edit_document(blkName)
%Called on a double-click of the block
%Creates the text file and opens it in the user's selected text editor

if nargin<1
    blkName = gcb;
end

fileName = getBlockFileName(blkName);

if exist(fileName,'file')
    %the file is already open - update the block
	file2blk(blkName,fileName);
else
	blk2file(blkName,fileName);
    %the file does not exist - create it
	%Dirty the model in order to encourage saving later on
	try
		set_param(bdroot(blkName),'Dirty','on');
	catch
		warning('docblock:SetDirty','Unable to change root model');
	end
end

open_document(fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errMsg = open_document(fileName)


errMsg = '';
switch fileName(end-2:end)
	case {'rtf','doc'}
		docViewer = getEditorDOC;
		
        if ~isempty(docViewer)
			docViewer = strrep(docViewer,'%<FileName>',strrep(fileName,'''',''''''));
			try
				evalin('base',docViewer);
			catch
				errMsg = sprintf('Unable to launch DOC editor (command: "%s")',docViewer);
			end
		elseif ispc
			errMsg = open_word(fileName);
		else
			edit(fileName);
		end
	case {'tml','htm'}
		htmlViewer = getEditorHTML;
		
        if ~isempty(htmlViewer)
			htmlViewer = strrep(htmlViewer,'%<FileName>',strrep(fileName,'''',''''''));
			try
				evalin('base',htmlViewer);
			catch
				errMsg = sprintf('Unable to launch HTML viewer (command: "%s")',htmlViewer);
			end
		elseif ispc
			errMsg = open_word(fileName);
		else
			edit(fileName);
		end
	otherwise
		txtViewer = getEditorTXT;
		
        if ~isempty(txtViewer)
			txtViewer = strrep(txtViewer,'%<FileName>',strrep(fileName,'''',''''''));
			try
				evalin('base',txtViewer);
			catch
				errMsg = sprintf('Unable to launch text viewer (command: "%s")',txtViewer);
			end
		else
			edit(fileName);
		end
end

if ~isempty(errMsg)
	edit(fileName)
	error('docblock:EditDocument',errMsg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function errMsg = open_word(fileName)

%this is largely cribbbed from rptgen/docview.  It is here because we want
%to be able to open Word without having the Report Generator

errMsg = '';
try
	hWord = actxserver('word.application');
catch
	errMsg='Could not create Word activeX server';
	return;
end

hDocs = hWord.documents;

try
   hDoc  = invoke(hDocs,'open',fileName);
catch
   errMsg=sprintf('Could not open file "%s"',fileName);
   return;
end

try
	invoke(hDoc,'Activate');
catch
	errMsg=sprintf('Could not activate file "%s"',fileName);
	return;
end

%Turn dirty flag off so Word doesn't query when closing
try
   hDoc.Saved=1;
%catch - this is not a critical error.  don't report it.
end

if hWord.Visible==0
	%Make Word window visible
	try
		hWord.WindowState=0; %Word should not be maximized
		hWord.Visible=1;
	catch
		errMsg = 'Could not open Word';
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setEditorTXT(editorCmd)
%Sets the command used to edit text pages.
%The substring "%<FileName>" will be replaced with the full path name

%Direct M-code access to the java prefs mechanism is undocumented and may 
%change in the future.  Beware!
com.mathworks.services.Prefs.setStringPref('docblock.editor.txt',editorCmd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editorCmd = getEditorTXT
%Returns the command used to edit text files.  See also getEditorTXT

%Direct M-code access to the java prefs mechanism is undocumented and may 
%change in the future.  Beware!
editorCmd = char(com.mathworks.services.Prefs.getStringPref('docblock.editor.txt'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function setEditorHTML(editorCmd)
%Sets the command used to edit HTML pages.
%The substring "%<FileName>" will be replaced with the full path name

%Direct M-code access to the java prefs mechanism is undocumented and may 
%change in the future.  Beware!
com.mathworks.services.Prefs.setStringPref('docblock.editor.html',editorCmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function editorCmd = getEditorHTML
%Returns the command used to edit HTML files.  See also getEditorHTML

%Direct M-code access to the java prefs mechanism is undocumented and may 
%change in the future.  Beware!
editorCmd = char(com.mathworks.services.Prefs.getStringPref('docblock.editor.html'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function setEditorDOC(editorCmd)
%Sets the command used to edit .doc and .rtf pages.
%The substring "%<FileName>" will be replaced with the full path name

%Direct M-code access to the java prefs mechanism is undocumented and may 
%change in the future.  Beware!
com.mathworks.services.Prefs.setStringPref('docblock.editor.doc',editorCmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function editorCmd = getEditorDOC
%Returns the command used to edit .doc and .rtf files.
%See also getEditorDOC

%Direct M-code access to the java prefs mechanism is undocumented and may 
%change in the future.  Beware!

editorCmd = char(com.mathworks.services.Prefs.getStringPref('docblock.editor.doc'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function save_documents(mdlRoot)
%Saves all documents in a model
%Utility function - not called by the block

%disp('Saving docblock documents!');
if nargin<1
    mdlRoot = bdroot(gcs);
end

%find all subsystems
list = find_system(mdlRoot,'MaskType','DocBlock');

for i=1:length(list)
    save_document(list{i});   %perform potential save operation
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function unique_file = save_document(blkName)

unique_file = getBlockFileName(blkName);

if exist(unique_file,'file')
    %if the file is being edited in the editor and is dirty, we save it first
    if isempty(javachk('mwt', 'The MATLAB Editor'))
        ea = 'com.mathworks.mlservices.MLEditorServices';
        saveResult = javaMethod('saveDocument',ea,unique_file);
    end
    
	file2blk(blkName,unique_file);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function close_documents(mdlRoot)
%Closes all documents in the model
%Utility function - not called by the block


if nargin<1
    mdlRoot = bdroot(gcs);
end

%was the model dirty prior to close_documents
wasDirty = strcmp(get_param(mdlRoot,'dirty'),'on');

%find all subsystems
list = find_system(mdlRoot,'MaskType','DocBlock');


modelDirtied = logical(0);
for i=1:length(list)
    modelDirtied = max(modelDirtied,close_document(list{i}));
end

if modelDirtied
    %@ENHANCEMENT: should turn off save listeners
    save_system(mdlRoot);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelDirtied = close_document(blkName,ea)
%closes documents if they are open in the editor
%deletes documents
%called by the block's DeleteFcn (called at model close time)

modelDirtied = logical(0);
if nargin<2
    if isempty(javachk('mwt', 'The MATLAB Editor'))
        ea = 'com.mathworks.mlservices.MLEditorServices';
    else
        ea = [];
    end
    if nargin<1
        blkName = gcb;
    end
end

fName = getBlockFileName(blkName);

if ~isempty(ea)
    %Note: isDocumentDirty and closeDocument check to see if the
    %document is open, so we don't have to do the check
    if javaMethod('isDocumentDirty',ea,fName)
        saveResult = javaMethod('saveDocument',ea,fName);
		%should we save outstanding changes to the model
		%file2blk(blkName,fName);
        %modelDirtied = logical(1);
    end
    javaMethod('closeDocument',ea,fName);
end

if exist(fName,'file')
    try
        delete(fName);
    catch
        warning(sprintf('Could not delete doc block temporary file "%s"',fName));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName = blk2file(blkName,fileName)
%   DOCBLOCK('blk2file',BLKNAME)
%   Writes block contents to a file without creating listeners.  
%  DOCBLOCK('blk2file',BLKNAME,FILENAME)
%   File name can optionally be specified.
%%

if nargin<2
    fileName = getBlockFileName(blkName);
end

ud = get_param(blkName,'UserData');
if isempty(ud)
	rd = get_param(blkName,'RTWdata');
	if ~isempty(rd)
		%struct2string - LEGACY SUPPORT
		sFields = fieldnames(rd);
		for i=1:length(sFields)
			if strncmp(sFields{i},'document_text',13)
				ud = [ud,getfield(rd,sFields{i})];
			end
		end
	else
		ud = xlate('Type your documentation here');
    end
else
    ud = ud(:)';
end

[wfid,errMsg] = fopen(fileName,'w');

if wfid<0
	warning(errMsg);
	return;
end

footerType = 0;
switch fileName(end-2:end)
	case {'rtf'}
		if isempty(findstr(ud(1:min(128,length(ud))),'{\rtf'))
			fwrite(wfid,['{\rtf\ansi\deff0',char(10),...
				'{\fonttbl{\f0\froman Tms Rmn;}}',char(10),...
				'{\stylesheet{\fs20 \snext0Normal;}}',char(10),...
				'\widoctrl\ftnbj \sectd\linex0\endnhere \pard\plain \fs20 '],...
				'char*1');
			footerType = 2;
		end
	case {'tml','htm'}
        %Word expects an HTML header and will treat the file as plain text
        %if it doesn't have one
		if isempty(findstr(ud(1:min(128,length(ud))),'<html'))
			fwrite(wfid,['<html><head></head><body>',char(10)],'char*1');
			footerType = 1;
		end
	%otherwise
		%Text file - no special formatting needed
end

%deliver the payload
fwrite(wfid,ud,'char*1');

%write a special footer for the doctype if necessary
switch footerType
	case 2 %RTF
		fwrite(wfid,'}','char*1');
	case 1 %HTML
		fwrite(wfid,'</body></html>','char*1');
end

fclose(wfid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file2blk(blkName,fileName)
%Writes the contents of a file to the block

if nargin<2
    fileName = getBlockFileName(blkName);
end

[rfid, message] = fopen(fileName,'r');
if rfid<0
	ud = '';
    warning(message);
    return;
else
	ud = fread(rfid,inf,'char*1=>char')';
	fclose(rfid);
end

set_param(blkName,'RTWdata',[],...  %provided to clear out legacy docblocks
	'UserDataPersistent','on',...   %provided to clear out legacy docblocks
	'UserData',ud);
	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function convert_legacy(mdlName)
%Convert classic docblocks to new-style

if nargin<1
    mdlName = bdroot(gcb);
end

sysList = find_system(mdlName,'BlockType','SubSystem');

% from the subsystem list, find the subsystems that have a pspec_txt field
% associated with it. If present, determine if a save operation is needed.
for i=1:length(sysList)
    s = get_param(sysList{i},'RTWDATA');
    if isfield(s,'document_text')
		%@BUG: DO THIS RIGHT!
		convert_legacy_block(sysList{i});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function convert_legacy_block(blkName)

if nargin<1
	blkName = gcb;
end

try
	oldECoderFlag = get_param(blkName,'ECoderFlag');
catch
	oldECoderFlag = '';
end

try
	oldDocumentType = get_param(blkName,'DocumentType');
catch
	oldDocumentType = 'Text';
end

set_param(blkName,...
	'MaskType','DocBlock',... 
	'ShowName','off',...
	'CopyFcn','',...
	'OpenFcn','docblock(''edit_document'',gcb);',...
	'PreSaveFcn','docblock(''save_document'',gcb);',...
	'DeleteFcn','docblock(''close_document'',gcb);',...
    'UserDataPersistent','on',...
	'MaskDescription','Use this block to save long descriptive text with the model.  Double-clicking the block will open an editor.',...
	'MaskPromptString','RTW Embedded Coder Flag|Editor Type',...
	'MaskStyleString','edit,popup(Text|RTF|HTML)',...
	'MaskTunableValueString','off,on',...
	'MaskEnableString','on,on',...
	'MaskVisibilityString','on,on',...
	'MaskToolTipString','on,on',...  	
	'MaskValueString','|Text',...
	'MaskVariables','ECoderFlag=@1;DocumentType=&2;',... 	
	'MaskDisplay','plot([.8 0 0 1 1 .8 .8 1],[1 1 0 0 .8 1 .8 .8]);text(.5,.6,''DOC'',''horizontalalignment'',''center'');text(.95,.05,get_param(gcb,''DocumentType''),''verticalalignment'',''bottom'',''horizontalalignment'',''right'');',...
	'MaskIconFrame','off',...
	'MaskIconOpaque','on',...
	'MaskIconRotate','none',...
	'MaskIconUnits','autoscale');

set_param(blkName,'ECoderFlag',oldECoderFlag);
set_param(blkName,'DocumentType',oldDocumentType);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function blkName = addToSystem(sysName)

if nargin<1
	sysName = gcs;
end

if isempty(sysName)
	sysName = new_system;
	open_system(sysName);
	sysName = get_param(sysName,'name');
end

libName = 'simulink';
libH = find_system(0,...
	'searchdepth',1,...
	'type','block_diagram',...
	'blockdiagramtype','library',...
	'Name','simulink');
if isempty(libH)
	load_system(libName);
end

dBlk = find_system(libName,...
	'MaskType','DocBlock');

if isempty(dBlk)
	blkName = '';
	warning('Could not find Doc block - not added');
	return;
else
	dv = datevec(now);
	blkName = sprintf('%s/DocBlock-%0.4i-%0.2i-%0.2i:%0.2i-%0.2i-%0.2f',...
		sysName,...
		dv(1),dv(2),dv(3),dv(4),dv(5),dv(6));
	add_block(dBlk{1},blkName);
end

if isempty(libH)
	close_system(libH);
end
set_param(0,'CurrentSystem',sysName);

