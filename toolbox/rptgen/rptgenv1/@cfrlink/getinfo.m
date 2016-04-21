function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRLINK)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:28 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Link');
out.Type = 'FR';
out.Desc = xlate('Inserts a link or anchor');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.LinkType='Link';
out.att.LinkID='';
out.att.LinkText='';
out.att.isEmphasizeText=logical(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.LinkType.String='Link type';
out.attx.LinkType.enumValues={'Anchor' 'Link' 'Ulink'};
out.attx.LinkType.enumNames={'Anchor'
   'Link'
   'External link (Web URL)'};
out.attx.LinkType.UIcontrol='radiobutton';

out.attx.LinkID.String='Link identifier';
out.attx.LinkID.isParsedText = logical(1);

out.attx.LinkText.String='Link text';
out.attx.LinkText.isParsedText = logical(1);

out.attx.isEmphasizeText.String='Emphasize link text';
