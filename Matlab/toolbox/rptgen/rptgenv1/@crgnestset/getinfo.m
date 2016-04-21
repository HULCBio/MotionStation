function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(C)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:20 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Nest Setup File');
out.Type = 'RG';
out.Desc = xlate('Runs a setup file');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.att.FileName='';
out.att.Inline=logical(1);

out.att.RecursionLimit=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.FileName.String='';
out.attx.FileName.Ext='rpt';
out.attx.FileName.isParsedText=logical(1);

out.attx.Inline.String='Run mode ';
out.attx.Inline.enumValues={logical(1) logical(0)};
out.attx.Inline.enumNames={
   'Embed new setup file''s report in current report';
   'Create a separate report file'
};
out.attx.Inline.UIcontrol='radiobutton';

out.attx.RecursionLimit=struct('String','Recursion limit  ',...
   'Type','NUMBER',...
   'numberRange',[0 get(0,'recursionlimit')]);
