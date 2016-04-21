%DDETERM Terminate DDE conversation.  
%   DDETERM takes one argument, the channel handle returned by the previous
%   call to DDEINIT that established the DDE conversation.
%
%   rc = DDETERM(channel)
%
%   rc      Return code: 0 indicates failure, 1 indicates success.
%   channel Conversation channel from DDEINIT.
%
%   For example, to terminate the DDE conversation:
%      rc = ddeterm(channel);
%
%   See also DDEINIT, DDEEXEC, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:19:24 $
%   Built-in function.
