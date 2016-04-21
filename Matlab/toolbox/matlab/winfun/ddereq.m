%DDEREQ Request data from application.
%   DDEREQ requests data from a server application via an established DDE 
%   conversation.  DDEREQ returns a matrix containing the requested data 
%   or an empty matrix if the function is unsuccessful.
%
%   data = DDEREQ(channel,item,format,timeout)
%
%   data    Matrix containing requested data, empty if function fails.
%   channel Conversation channel from DDEINIT.
%   item    String specifying the server application's DDE item name 
%           for the data requested.
%   format  (optional) Two-element array specifying the format of the
%           data requested. The first element indicates a Windows
%           clipboard format to use for the request. The only format
%           currently supported is CF_TEXT, which corresponds to a
%           value of 1.  The second element of the format array
%           specifies the type of the resultant matrix. The valid
%           types are NUMERIC (the default, corresponding to a value
%           of 0) and STRING (corresponding to a value of 1). The
%           default format array is [1 0].
%   timeout (optional) Scalar specifying the time-out limit for this
%           operation.  Timeout is specified in milliseconds.
%           (1000 milliseconds = 1 second).  The default timeout is
%           three seconds.
%
%   For example,to request a matrix of cells from Excel
%       mymtx = ddereq(channel, 'r1c1:r10c10');
%
%   See also DDEINIT, DDETERM, DDEEXEC, DDEPOKE, DDEADV, DDEUNADV.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:19:21 $
%   Built-in function.
