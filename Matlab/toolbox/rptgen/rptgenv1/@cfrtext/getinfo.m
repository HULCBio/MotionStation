function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRTEXT)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:57 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Text');
out.Type = 'FR';
out.Desc = xlate('Inserts and formats text.');
out.ValidChildren={logical(0)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isParseContent=logical(1);
out.att.Content = {''};
out.att.isEmphasis = logical(0);
out.att.isLiteral  = logical(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.Content=struct('String','Text to include in report',...
   'UIcontrol','multiedit',...
   'isParsedText',logical(1));

out.attx.isEmphasis.String='Emphasize text';
out.attx.isLiteral.String='Retain spaces and carriage returns';
