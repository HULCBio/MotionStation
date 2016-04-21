function prefs=preferences(obj)
%PREFERENCES sets up general preferences for the Report Generator
%   P=PREFERENCES(RPTPARENT) returns a structure containing
%   the following fields:
%
%   P.format is a 1xN structure with fields containing information
%      about default settings for each output format.  You can edit
%      this file to set the default image type for each format.
%
%   P.ExtViewCmd is a 1x1 structure with field names defined for many
%      common file format extensions.  The function RPTVIEWFILE uses
%      these commands to launch the viewer for the specified file.
%
%   See also RPTVIEWFILE, RPTCOMPONENT/GETIMGFORMAT

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:24 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prefs.format
% This section creates a structure which contains output
% format-specific information.  'format' is a 1xN structure
% in which each entry contains the following fields
%
% --- Non-User-Modifiable Fields
% .Name = a unique identifier for each format 
% .JadeBackend = a command used by the output transform engine
%
% --- User-Modifiable Fields
% .Ext = the file extension that should be used for the output file
% .Desc = a short description of the output format
% .ImageSL = the default image format for use with Simulink snapshots
% .ImageSF = the default image format for use with Stateflow snapshots
% .ImageHG = the default image format for use with Figure snapshots

% -Editing .Image fields
% The string in the various .ImageXX fields is a unique identifier
% used by the Report Generator to designate each image file type.
% The image type in this field is the output format that will be
% used if the unique identifier handed to RPTCOMPONENTS/GETIMGFORMAT
% is AUTOHG, AUTOSL, or AUTOSF.  To get a structure containing
% all valid image format unique identifiers, type
%   imgStruct=getimgformat(rptcomponent,'ALLHG') %for .ImageHG
%   imgStruct=getimgformat(rptcomponent,'ALLSL') %for .ImageSL
%   imgStruct=getimgformat(rptcomponent,'ALLSF') %for .ImageSF
%
% Any entries in imgStruct.ID are valid except for 'AUTOXX'.

i=0;

i=i+1;
format(i).Name='HTML';
format(i).JadeBackend='sgml';
format(i).Ext='html';
%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
format(i).Desc='web (HTML)';
format(i).ImageSL='png';
format(i).ImageSF='png';
format(i).ImageHG='png';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE -----

i=i+1;
format(i).Name='RTF95';
format(i).JadeBackend='rtf-95';
format(i).Ext='rtf';
%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
format(i).Desc='Rich Text Format 95 (RTF)';
format(i).ImageSL='eps2t';
format(i).ImageSF='eps2t';
format(i).ImageHG='eps2t';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE -----

i=i+1;
format(i).Name='RTF97';
format(i).JadeBackend='rtf';
format(i).Ext='rtf';
%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
format(i).Desc='Rich Text Format 97 (RTF)';
format(i).ImageSL='eps2t';
format(i).ImageSF='eps2t';
format(i).ImageHG='eps2t';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE -----

i=i+1;
format(i).Name='TEX';
format(i).JadeBackend='tex';
format(i).Ext='tex';
%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
format(i).Desc='LaTeX (TEX)';
format(i).ImageSL='eps2';
format(i).ImageSF='eps2';
format(i).ImageHG='eps2';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE -----

i=i+1;
format(i).Name='FOT';
format(i).JadeBackend='fot';
format(i).Ext='fot';
%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
format(i).Desc='Flow Object Tree (XML)';
format(i).ImageSL='eps2';
format(i).ImageSF='eps2';
format(i).ImageHG='eps2';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE -----

i=i+1;
format(i).Name='DB';
format(i).JadeBackend='';
format(i).Ext='sgml';
%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
format(i).Desc='DocBook (SGML)';
format(i).ImageSL='eps2';
format(i).ImageSF='eps2';
format(i).ImageHG='eps2';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE -----


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% These formats are not directly supported by       %
%%%%% the report generator.                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if logical(0)
    i=i+1;
    format(i).Name='TXT';
    format(i).JadeBackend='sgml';
    format(i).Ext='txt';
    %----YOU MAY EDIT FIELDS BELOW THIS LINE -----
    format(i).Desc='Plain Text (TXT)';
    format(i).ImageSL='eps2';
    format(i).ImageSF='eps2';
    format(i).ImageHG='eps2';
    %----YOU MAY EDIT FIELDS ABOVE THIS LINE -----
end
if logical(0)
    i=i+1;
    format(i).Name='MIF';
    format(i).JadeBackend='mif';
    format(i).Ext='mif';
    %----YOU MAY EDIT FIELDS BELOW THIS LINE -----
    format(i).Desc='Adobe Interchange (MIF)';
    format(i).ImageSL='tiffc';
    format(i).ImageSF='tiffc';
    format(i).ImageHG='tiffc';
    %----YOU MAY EDIT FIELDS ABOVE THIS LINE -----
end
if logical(0)
    i=i+1;
    format(i).Name='PDF';
    format(i).JadeBackend='rtf';
    format(i).Ext='pdf';
    %----YOU MAY EDIT FIELDS BELOW THIS LINE -----
    format(i).Desc='Adobe Acrobat (PDF)';
    format(i).ImageSL='eps2t';
    format(i).ImageSF='eps2t';
    format(i).ImageHG='epsc2t';
    %----YOU MAY EDIT FIELDS ABOVE THIS LINE ----
end
prefs.format=format;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prefs.ExtViewCmd
% This section allows you to specify how your files are
% viewed when called from RPTVIEWFILE or when using the
% "View report after generation" option in the Report Generator.
%
% Each view command is keyed off the extension of the file and 
% is not case-sensitive.  The filename is substituted
% for any occurrence of %<FileName> in the command.  The command is
% evaluated in the base workspace.
%
% It is recommended that you use the "&" character at the end of any
% system calls using the "!", "dos", or "unix" command.  Failure to
% include the "&" character will cause the system to wait for a 
% response from the triggered program and will make the process
% of launching a viewer hang MATLAB until the viewer is closed.
%
% The .EMPTY field is used for files with no extension.
%

%----YOU MAY EDIT FIELDS BELOW THIS LINE -----
ExtViewCmd.rtf  = 'docview(''%<FileName>'',''UpdateFields'');';

ExtViewCmd.dvi  = '! "%<FileName>" &';
ExtViewCmd.ps   = '! "%<FileName>" &';
ExtViewCmd.mif  = '! "%<FileName>" &';
ExtViewCmd.pdf  = '! "%<FileName>" &';

ExtViewCmd.htm  = 'web(rptgen.file2urn(''%<FileName>''),''-browser'');';
ExtViewCmd.html = 'web(rptgen.file2urn(''%<FileName>''),''-browser'');';

ExtViewCmd.txt  = 'edit(''%<FileName>'');';
ExtViewCmd.m    = 'edit(''%<FileName>'');';
ExtViewCmd.tex  = 'edit(''%<FileName>'');';
ExtViewCmd.sgml = 'edit(''%<FileName>'');';
ExtViewCmd.fot  = 'edit(''%<FileName>'');';

ExtViewCmd.EMPTY = 'edit(''%<FileName>'');';
%----YOU MAY EDIT FIELDS ABOVE THIS LINE ----

prefs.ExtViewCmd=ExtViewCmd;

