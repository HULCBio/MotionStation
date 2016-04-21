function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSLSYSLIST)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:07 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('System Hierarchy');
out.Type = 'SL';
out.Desc = xlate('Inserts a list of systems in the model.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.StartSys='FROMLOOP';
out.att.HighlightStartSys=logical(1);
out.att.DisplayAs='BULLETLIST';
out.att.isPeers=logical(1);
out.att.ParentDepth=1;
out.att.ChildDepth=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.DisplayAs.String = '';
out.attx.DisplayAs.enumValues={'BULLETLIST','NUMBEREDLIST'};
out.attx.DisplayAs.enumNames={'Bulleted list','Numbered list'};
out.attx.DisplayAs.UIcontrol='radiobutton';

out.attx.StartSys=struct('String','Build list from: ',...
   'enumValues',{{'FROMLOOP','TOP'}},...
   'enumNames',{{'Current system','Current model'}},...
   'UIcontrol','radiobutton');

out.attx.isPeers.String='Display peers of current system';
out.attx.ParentDepth.String='Show number of parents: ';
out.attx.ChildDepth.String='Show children to depth: ';
out.attx.HighlightStartSys.String='Emphasize current system';
