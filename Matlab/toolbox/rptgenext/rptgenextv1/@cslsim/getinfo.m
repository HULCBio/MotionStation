function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSLSIM)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:45 $

out=getprotocomp(c);

out.Name = xlate('Model Simulation');
out.Type = 'SL';
out.Desc = xlate('Simulates the current model');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.useMDLioparam=logical(1);
out.att.timeOut='T';
out.att.statesOut='X';
out.att.matrixOut='Y';

out.att.useMDLtimespan=logical(1);
out.att.startTime='0';
out.att.endTime='60';

out.att.simparam={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.useMDLioparam.String=...
   'Use model''s workspace I/O variable names';

out.attx.timeOut.String='Time ';
out.attx.statesOut.String='States ';
out.attx.matrixOut.String='Output ';


out.attx.useMDLtimespan.String=...
   'Use model''s timespan values';

out.attx.startTime.String='Start ';

out.attx.endTime.String='Stop ';

out.attx.simparam=struct('String','',...
   'UIcontrol','listbox');

