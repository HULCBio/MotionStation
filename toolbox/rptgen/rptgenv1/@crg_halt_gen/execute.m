function out=execute(c)
%EXECUTE generate report output
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:58 $

isHalt=logical(1);

if c.att.isPrompt
   
   try
      %alert the user to the fact that we need
      %input
      beep
   end
   
   btnName=questdlg(c.att.PromptString,...
      'Component - Stop Report Generation',...
      c.att.HaltString,c.att.ContString,c.att.ContString);
   if strcmp(btnName,c.att.ContString)
      isHalt=logical(0);
   end
end

if isHalt
   c.rptcomponent.HaltGenerate=logical(1);
   
   out=set(sgmltag,...
      'issgml',1,...
      'data','<!-- Report generation halted by crg_halt_gen -->');
   status(c,'Generation halted by component',3);
else
   status(c,'Generation not halted by component',6);
   out='';
end