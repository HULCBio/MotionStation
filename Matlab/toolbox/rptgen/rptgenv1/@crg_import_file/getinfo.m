function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CRG_IMPORT_FILE)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:06 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Import File');
out.Type = 'RG';
out.Desc = xlate('Imports an ASCII text file.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.FileName='';

out.att.ImportType='honorspaces';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.attx.FileName.String='';
out.attx.FileName.UIcontrol='filebrowse';
out.attx.FileName.isParsedText=logical(1);
out.attx.FileName.Ext='txt';

out.attx.ImportType.String='Import file as ';
out.attx.ImportType.UIcontrol='radiobutton';
out.attx.ImportType.enumValues={
   'text'
   'para-lb'
   'para-emptyrow'
   'honorspaces'
   'fixedwidth'
   'docbook'
   'external'
};

out.attx.ImportType.enumNames={
   'Plain text (ignore line breaks)'
   'Paragraphs defined by line breaks'
   'Paragraphs defined by empty rows'
   'Text (retain line breaks)'
   'Fixed-width text (retain line breaks)'
   'DocBook SGML'
   'Formatted text (RTF/HTML)'
};