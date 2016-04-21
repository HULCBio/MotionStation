%DDEPOKE Send data to application.
%   DDEPOKE sends data to an application via an established DDE 
%   conversation.  DDEPOKE formats the data matrix as follows before
%   sending it to the server application:
%     * String matrices are converted, element by element, to characters
%       and the resulting character buffer is sent.
%     * Numeric matrices are sent as tab-delimited columns and 
%       carriage-return, line-feed delimited rows of numbers.  
%       Only the real part of non-sparse matrices are sent.
%
%   rc = DDEPOKE(channel,item,data,format,timeout)
%
%   rc      Return code: 0 indicates failure, 1 indicates success.
%   channel Conversation channel from DDEINIT.
%   item    String specifying the DDE item for the data sent. 
%           Item is the server data entity that is to contain the data 
%           sent in the data argument.
%   data    Matrix containing the data to send.
%   format  (optional) Scalar specifying the format of the data 
%           requested. The value indicates the Windows clipboard format to
%           use for the data transfer. The only format currently supported
%           is CF_TEXT, which corresponds to a value of 1.
%   timeout (optional) Scalar specifying the time-out limit for this
%           operation.  Timeout is specified in milliseconds.
%           (1000 milliseconds = 1 second). The default timeout is three
%           seconds.
%
%   For example, to send a 5x5 identity matrix to Excel:
%      rc = ddepoke(channel, 'r1c1:r5c5', eye(5));
%
%   See also DDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEADV, DDEUNADV.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:19:18 $
%   Built-in function.
