function out=getinfo(c)
%GETINFO returns a structure containing information about the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:17 $

out=getprotocomp(c);

out.Name = xlate('<if> Then');
out.Type = 'LO';
out.Desc = xlate('Acts as "then" if placed inside an "if" component');
out.ValidChildren={logical(1)};


out.att.TrueText='';

out.attx.TrueText=struct('String',...
   'If "then" has no subcomponents, display this string:',...
   'UIcontrol','multiedit');

