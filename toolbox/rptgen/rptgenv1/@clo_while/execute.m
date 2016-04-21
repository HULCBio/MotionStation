function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:39 $

myChildren=children(c);
if isempty(myChildren)
   status(c,'Warning - WHILE loop has no children and will not be run',2);
   out='';
   return;
end


out=sgmltag;


numLoops=1;
while LocIsTrue(c,numLoops)
   status(c,...
      sprintf('Running while(%s) iteration #%d',c.att.ConditionalString, numLoops),...
      3); 
   out=[out;runcomponent(children(c))];   
   numLoops=numLoops+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=LocIsTrue(c,numLoops)

if c.rptcomponent.HaltGenerate
   tf=logical(0);
   status(c,'Warning - "While" loop execution stopped by user',2);
elseif (c.att.isMaxIterations & ...
      numLoops>c.att.MaxIterations)
   tf=logical(0);
   status(c,'Warning - "While" loop reached iteration limit',2);
else
   tf=logical(1);
end

if tf
   try
      evalTF=evalin('base',c.att.ConditionalString);
   catch
      evalTF=logical(0);
      status(c,sprintf('Error - could not evaluate WHILE (%s)',...
            c.att.ConditionalString ),1);
   end
   
   if isempty(evalTF)
      tf=logical(0);
      status(c,sprintf('Error - WHILE string "%s" did not return a value',...
            c.att.ConditionalString),1);
   elseif islogical(evalTF)
      tf=logical(evalTF);
   elseif isnumeric(evalTF)
      tf=logical(evalTF(1));
   else
      tf=logical(0);
      status(c,sprintf('Error - WHILE string "%s" did not return a logical value',...
            c.att.ConditionalString),1);   
   end
end