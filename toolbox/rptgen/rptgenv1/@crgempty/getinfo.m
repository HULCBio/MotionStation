function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CRGEMPTY)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:13 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Empty Component');
out.Type = 'RG';
out.Desc = xlate('Groups components together, does not insert anything in the report.');

out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.DescString='';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.DescString.String='';
out.attx.DescString.UIcontrol='edit';