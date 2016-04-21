function out=getinfo(c)
%GETINFO returns a structure containing information about the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:47 $

out=getprotocomp(c);

out.Name = xlate('<if> Else');
out.Type = 'LO';
out.Desc = xlate('Acts as an "else" if inside an "if" component');
out.ValidChildren={logical(1)};

out.att.TrueText='';

out.attx.TrueText=struct('String',...
   'If "else" has no subcomponents, display this string:',...
   'UIcontrol','multiedit');

