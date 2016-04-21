function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CMLEVAL)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:31 $

out=getprotocomp(c);

%%%%%%%%%%%% COMPONENT INFORMATION %%%%%%%%%%%%%%%%%%

out.Name = xlate('Evaluate MATLAB Expression');
out.Type = 'ML';
out.Desc = xlate('Evaluates a string as a MATLAB expression in the base workspace');

%%%%%%%%%%%%% ATTRIBUTES %%%%%%%%%%%%%%%%%%%%


out.att.EvalString={'%Evaluate this string in the base workspace',''};

out.att.isCatch=logical(1);
out.att.CatchString={'disp(sprintf(''Error during eval: %s'', lasterr))'};

out.att.isDiary=logical(0);
out.att.isInsertString=logical(0);

%%%%%%%%%%%%% GUI INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isInsertString.String='Insert MATLAB expression string in report';

out.attx.EvalString.String=...
   'Expression to evaluate in the base workspace: ';
out.attx.EvalString.UIcontrol='multiedit';

out.attx.isCatch.String=...
   'Evaluate this expression if there is an error: ';

out.attx.isDiary.String='Display command window output in report';

out.attx.CatchString.String='';
out.attx.CatchString.UIcontrol='multiedit';