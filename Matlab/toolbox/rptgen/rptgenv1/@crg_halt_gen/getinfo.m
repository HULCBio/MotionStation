function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CRG_HALT_GEN)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:59 $

out=getprotocomp(c);

out.Name = xlate('Stop Report Generation');
out.Type = 'RG';
out.Desc = xlate('Stops the generation process - same as hitting the "Stop" button');

out.ValidChildren={logical(0)};

%--------1---------2---------3---------4---------5---------6---------7---------8

out.att.isPrompt     = logical(0);
out.att.PromptString = 'Stop generating the report?';

out.att.HaltString   = 'Halt Generation';
out.att.ContString   = 'Continue Generation';

%--------1---------2---------3---------4---------5---------6---------7---------8

out.attx.isPrompt.String='Confirm before stopping generation';

out.attx.PromptString.String=...
   'Confirmation question ';

out.attx.HaltString.String=...
   'Halt button';

out.attx.ContString.String=...
   'Continue button';
