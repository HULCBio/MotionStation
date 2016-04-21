%DDEUNADV Release advisory link.
%   DDEUNADV releases the advisory link between MATLAB and the server 
%   application, established by an earlier DDEADV call. The channel, 
%   item, and format must be the same as those specified in the call 
%   to DDEADV that initiated the link. If you include the timeout 
%   argument but accept the default format, you must specify format 
%   as an empty matrix.
%
%   rc = DDEUNADV(channel,item,format,timeout)
%
%   rc      Return code: 0 indicates failure, 1 indicates success.
%   channel Conversation channel from DDEINIT.
%   item    String specifying the DDE item name associated with 
%           the advisory link.
%   format  (optional) Two-element array specifying the format of 
%           the data for the advisory link. If you specified a format 
%           argument on the DDEADV function call that defined the advisory
%           link, you must specify the same value on the DDEUNADV function
%           call. See DDEADV for a description of the format array.
%   timeout (optional) Scalar specifying the time-out limit for this
%           operation.  Timeout is specified in milliseconds.
%           (1000 milliseconds = 1 second). 
%           The default value of timeout is three seconds.
%
%   For example, to release the hot link established in the ddeadv
%   example use
%       rc = ddeunadv(channel, 'r1c1:r5c5');
%   
%   Release a hot link with default format and value for timeout
%   rc = ddeunadv(chan, 'r1c1:r5c5',[],6000);
%
%   See also DDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEADV.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:19:27 $
%   Built-in function.
