function out=execute(c)
%EXECUTE generate report output
%   OUTPUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:30 $

if c.att.isInsertString
   
   %textComp=c.rptcomponent.comps.cfrtext;
   
   %textComp.att.isParseContent=logical(0);
   %textComp.att.Content=c.att.EvalString;
   %textComp.att.isLiteral=logical(1);
   
   pString={LocFormatText(c.att.EvalString)};
else
   pString={};
end

try
   dString=LocEval(c.att.EvalString,c.att.isDiary);
catch
   if c.att.isInsertString
      pString{end+1}=LocFormatText(sprintf('Error - %s', lasterr));
   end
      
   if c.att.isCatch
      if c.att.isInsertString
         pString={pString{:},...
               LocFormatText('Running alternate code:'),...
               LocFormatText(c.att.CatchString)};
      end
      
      try
         dString=LocEval(c.att.CatchString,c.att.isDiary);
      catch
         dString={};;
      end
   else
      dString={};
   end
end

out={pString{:} dString{:}};


%%%%%%%%%%%%%%%%%%%%%
function outString=LocEval(eString,isDiary);

%convert to a cell
if ischar(eString);
   eString=cellstr(eString);
   eString=eString(:);
elseif iscell(eString)
   eString=eString(:);
else
   eString={};
end

%set the carriage return and replace characters if necessary
if isDiary
   CR='\n';
   eString=strrep(strrep(strrep(strrep(eString,...
      '\','\\'),...
      '%','%%'),...
      sprintf('\n'),'\n'),...
      '''','''''');
else
   CR=sprintf('\n');
end

%convert cell to string with appropriate carriage returns
[carriageReturns{1:size(eString,1),1}]=deal(CR);
eString=[eString carriageReturns]';
eString=[eString{:}];   

if ~isempty(eString)
   r=rptparent;
   if isDiary
      %tempVar=LocTempVarName;
      %assignin('base',tempVar,eString);
      evaledString=evalin('base',['evalc(sprintf(''' eString '''))']);
      %clear(tempVar);
      disp(evaledString);
      outString={LocFormatText(evaledString)};
   else
      evalin('base',eString);
      outString={};
   end
else
   outString={};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outTag=LocFormatText(inString)

outTag=set(sgmltag,...
   'tag','ProgramListing',...
   'data',inString,...
   'indent',logical(0));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tempVar=LocTempVarName

tempVar='RPTGEN_TEMPORARY_VARIABLE_NAME';


