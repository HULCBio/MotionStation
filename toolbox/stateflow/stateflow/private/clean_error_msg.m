%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newMsg = clean_error_msg(oldMsg)
%
% this function strips extraneous call stack info from error message
% Used by sfblk() function in fsm.c. 

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:56:16 $
%
newMsg = '';
if isempty( oldMsg )
	return;
end
newMsg = oldMsg;
newLines = find(oldMsg==sprintf('\n'));
newLines = [0,newLines,length(newMsg)];
junkStr = xlate('Error using ==>');
junkLen = length(junkStr);
for i=1:length(newLines)-1
   thisLine = oldMsg(newLines(i)+1:newLines(i+1)-1);
   if(strncmp(thisLine,junkStr,junkLen))
      % do nothing
   else
      % this line starts the real error message
      newMsg = oldMsg(newLines(i)+1:end);
      return;
   end
end

