function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CLOIF)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:09 $

out=getprotocomp(c);

out.Name = xlate('Logical If');
out.Type = 'LO';
out.Desc = xlate('Acts as logical if (contains then, elseif, else).');
out.ValidChildren={logical(1)};


out.att.ConditionalString='';
out.att.TrueText='';

out.attx.ConditionalString.String=...
   'Run subcomponents if this string is true in the base workspace:';

out.attx.TrueText=struct('String',...
   'If "if" has no subcomponents, display this string:',...
   'UIcontrol','multiedit');