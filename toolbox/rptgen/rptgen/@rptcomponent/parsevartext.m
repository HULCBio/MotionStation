function parsedText=parsevartext(r,rawText);
%PARSEVARTEXT parses text for matlab expressions %<varname>
%   PARSEDTEXT=PARSEVARTEXT(RPTCOMPONENT,RAWTEXT)
%   Looks for incidents of %<varname> in the raw
%   text.  Evaluates "varname" in the base workspace.
%   if the evaluation executes successfully and returns
%   a variable, will replace %<varname> with the result.
%
%   For example, if the only variable in the workspace
%   is "A" which equals "very" and RAWTEXT is 
%   "I am the %<A> model of %<B>", the PARSEDTEXT
%   will be returned as "I am the very model of %<B>"
%
%   It is also possible to include statements such as
%   %<help('magic')> or %<length([1 2 3 4 5])> in the
%   evaluation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:13 $

if isa(rawText,'sgmltag')
    parsedText=rawText;
    return;
end

rawText=singlelinetext(r,rawText,char(10));

beginIndex=findstr(rawText,'%<');
numBegin=length(beginIndex);

if length(beginIndex)==0
   parsedText=rawText;
else
   endIndex=findstr(rawText,'>');
   
   prevEnd=0;
   parsedText='';
   
   for i=1:numBegin
      plainText=rawText(prevEnd+1:beginIndex(i)-1);
      
      if i==numBegin
         nextBegin=length(rawText)+1;
      else
         nextBegin=beginIndex(i+1);
      end
      
      nextEnd=find(endIndex>beginIndex(i) & endIndex<nextBegin);
      if length(nextEnd)>0
         prevEnd=endIndex(nextEnd(1));
         varName=rawText(beginIndex(i)+2:prevEnd-1);
         
         if length(varName)>0
            try
               varValue=evalin('base',varName);
               ok=1;
            catch
               ok=0;
            end
         else
            ok=0;
         end
         
         if ~ok
            varText=sprintf('%%<%s>',varName);
         else
            varText=singlelinetext(r,...
               rendervariable(r,varValue,logical(1)),...
               char(10));
         end
      else
         varText=rawText(beginIndex(i):nextBegin-1);
         prevEnd=nextBegin-1;
      end
      parsedText=[parsedText plainText varText];
   end
   
   if prevEnd<length(rawText);
      parsedText=[parsedText rawText(prevEnd+1:end)];
   end
end

