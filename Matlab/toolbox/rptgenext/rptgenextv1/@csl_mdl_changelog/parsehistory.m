function hInfo=parsehistory(c,hString,numRevisions)
%PARSEHISTORY parses model history string into cell array

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:00 $

hInfo=cell(0,4);
currEntry=0;

dashStr=' -- ';
dashLen=length(dashStr);

verStr='Version ';
verLen=length(verStr);


while ~isempty(hString) & currEntry<numRevisions
   [currChunk,hString]=strtok(hString,sprintf('\n'));
      
   dashLoc=findstr(currChunk,dashStr);
   numDashes=length(dashLoc);
   if numDashes>0 & numDashes<=2 & LocIsNumber(currChunk(end))
      %If the current chunk contains a ' -- ' and the
      %last character is a number, we can be pretty sure
      %that it's a header row.
      currEntry=currEntry+1;
      
      authorString=currChunk(1:dashLoc);
      
      if numDashes==2
         dateString=currChunk(dashLoc(1)+dashLen:dashLoc(2)-1);
         verString=currChunk(dashLoc(2)+dashLen+verLen:end);
      else
         dateString=currChunk(dashLoc(1)+dashLen:end);
         verString='';
      end
      
      %dateString=datestr(dateString,c.att.DateFormat);
      
      
      hInfo(currEntry,:)={verString,authorString,dateString,''};
      
   elseif currEntry>0
      hInfo{currEntry,4}=[hInfo{currEntry,4} ' ' currChunk];
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=LocIsNumber(checkChar)

checkChar=abs(checkChar);

tf=(checkChar>=abs('0') & checkChar<=abs('9'));