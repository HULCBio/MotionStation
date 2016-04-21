function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:37 $

myvar=[];
errMsg='';

if ~isempty(c.att.variable)
   varName=parsevartext(c.rptcomponent,c.att.variable);
   switch c.att.source
   case 'W' %from workspace
      try
         myvar=evalin('base',varName);
      catch
         errMsg=sprintf('Error - "%s" not found in workspace.',varName);
      end   
   case 'M' %from MAT file
      fileName=parsevartext(c.rptcomponent,c.att.filename);
      try
         mymat=load(fileName,'-mat');
         ok=1;
      catch
         errMsg=sprintf('Error - could not load file "%s".',fileName);
         ok=0;
      end
      
      if ok
         if isfield(mymat,varName)
            myvar=getfield(mymat,varName);
         else
            errMsg=sprintf('Error - "%s" not found in MAT file "%s".',varName, fileName);
         end
      end
      
   case 'G' %from Global workspace
      try
         eval(['global ' varName]);
         myvar=eval(varName);
      catch
         errMsg=sprintf('Error - "%s" not global.',varName);
      end
   end
else
   errMsg=sprintf('Error - no variable name defined');
end

if isempty(errMsg)
   if ~c.att.forceinline & ~strcmp(c.att.renderAs,'v')
      tableTitle=varName;
   else
      tableTitle='';
   end
   
   out=rendervariable(c,myvar,...
      c.att.forceinline,...
      abs(c.att.sizeLimit),... 
      tableTitle,...
      logical(0)); %do not extract variable from WS
   
   if ~isa(out,'sgmltag')
      switch c.att.renderAs
      case 'p: v'
         out={[varName ': '] out};
      case 'Pv'
         out={set(sgmltag,'tag','emphasis','data',[varName ' ']),...
               out};
      end
   end
else
   out='';
   status(c,errMsg,1);
end
