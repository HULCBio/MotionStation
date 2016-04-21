function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_SIG_LOOP)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:24 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Signal Loop');
out.Type = 'SL';
out.Desc = xlate('Applies all subcomponents to desired Simulink signals.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.SortBy='$alphabetical';

out.att.isBlockIncoming=logical(1);
out.att.isBlockOutgoing=logical(1);

out.att.isSystemIncoming=logical(1);
out.att.isSystemOutgoing=logical(1);
out.att.isSystemInternal=logical(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loopInfo=loopsignal(c.zslmethods);

out.attx.SortBy=struct('String','',...
   'enumValues',{loopInfo.sortCode},...
   'enumNames',{loopInfo.sortName},...
   'UIcontrol','radiobutton');

out.attx.isBlockIncoming.String='Block input signals  ';
out.attx.isBlockOutgoing.String='Block output signals  ';

out.attx.isSystemIncoming.String='System input signals  ';
out.attx.isSystemOutgoing.String='System output signals  ';
out.attx.isSystemInternal.String='System internal signals  ';
