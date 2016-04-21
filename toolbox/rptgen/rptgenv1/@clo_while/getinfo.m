function out=getinfo(c)
%GETINFO returns a structure containing information about the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:40 $

out=getprotocomp(c);

out.Name = xlate('While loop');
out.Type = 'LO';
out.Desc = xlate('Loops while a workspace expression is true.');
out.ValidChildren={logical(1)};

out.att.ConditionalString='';
out.att.isMaxIterations=logical(1);
out.att.MaxIterations=100;


out.attx.ConditionalString.String='';
out.attx.isMaxIterations.String=...
   'Limit number of loops to: ';
out.attx.MaxIterations=struct('UIcontrol','slider',...
   'numberRange',[1 256],...
   'String','');