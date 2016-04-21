function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:01 $

if strcmp(c.att.LoopType,'$vector')
   loopVec=LocEval(c,c.att.LoopVector,[1 2],'index vector',0);
else
   startNum=LocEval(c,c.att.StartNumber,1,'start',1);
   incNum=LocEval(c,c.att.IncrementNumber,1,'increment',1);
   endNum=LocEval(c,c.att.EndNumber,2,'end',1);
   
   try
      loopVec=[startNum:incNum:endNum];
   catch
      loopVec='error';
      status(c,'Error - Could not construct loop indices',2);
   end
end

if ~isnumeric(loopVec)
   out='';
elseif isempty(loopVec)
   status(c,'Warning - Loop indices are empty.',2);
   out='';
elseif isnan(loopVec)
   status(c,'Warning - Loop indices are NaN or Inf',2);
   %Note that if someone tries to use -inf or +inf that the
   %resulting vector will have a NaN value.
   out='';
else
   out=sgmltag;
   
   if c.att.isUseVariable
      if evalin('base',sprintf('exist(''%s'')',c.att.VariableName))==1
         wasVariableInWorkspace=1;
         status(c,sprintf('Warning - FOR loop index "%s" exists in workspace.  Saving value.',...
            c.att.VariableName),2);
         prevVariableValue = evalin('base',c.att.VariableName);
      else
         wasVariableInWorkspace=0;
      end
      
      
      evalin('base',['clear ' c.att.VariableName],'');
   end
   
   for i=loopVec
      if c.att.isUseVariable
         evalin('base',[c.att.VariableName '=' num2str(i) ';'],'');
      end
      
      status(c,sprintf('Running FOR loop, %s = %g ',c.att.VariableName,i),3);
      
      if c.rptcomponent.HaltGenerate
         status(c,'Warning - FOR loop execution halted',2);
         break;
      end
      
      out=[out;runcomponent(children(c))];   
      
   end
   
   if c.att.isUseVariable & c.att.isCleanup
      if wasVariableInWorkspace
         assignin('base',c.att.VariableName,prevVariableValue);
			status(c,sprintf('FOR loop complete.  Restoring saved value of "%s".',...
            c.att.VariableName),2);

      else
         evalin('base',['clear ' c.att.VariableName],'');
      end
      
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rez=LocEval(c,evalStr,rez,name,isScalar);

varNum=str2num(evalStr);

if isempty(varNum)
   try
      varNum=evalin('base',evalStr);
      ok=logical(1);
   catch
      status(c,sprintf('Warning - Could not evaluate FOR loop "%s" number.',name),2);
      ok=logical(0);
   end
else
   ok=1;
end


if ok
   ok=0;
   
   if isnumeric(varNum)
      sz=size(varNum);
      if min(sz)==1 & ( ~isScalar | ( isScalar & max(sz)==1 ) )
         rez=varNum;
         ok=1;
      end
   end
   
   if ~ok
      if isScalar
         typeStr='scalar';
      else
         typeStr='vector';
      end
      
      status(c,sprintf('Warning - FOR loop "%s" is not a %s',...
         name,typeStr),2);
      ok=logical(0);
   end
end   

if ~ok
   status(c,sprintf('Warning - Substituting value [%s] for "%s" number.',...
      num2str(rez),name),2);
end
