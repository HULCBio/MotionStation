%DDEADV Set up advisory link.
%   DDEADV sets up an advisory link (described in the "DDE Advisory Links"
%   section) between MATLAB and a server application.  When the data 
%   identified by the item argument changes, the string specified by the
%   callback argument is passed to the eval function and evaluated. If the
%   advisory link is a hot link, DDE modifies upmtx, the update matrix, to
%   reflect the data in item.  If item corresponds to a range of data 
%   values, a change to any value in the range causes callback to be 
%   evaluated.
%
%   rc = DDEADV(channel,item,callback,upmtx,format,timeout)
%
%   rc       Return code: 0 indicates failure, 1 indicates success.
%   channel  Conversation channel from DDEINIT.
%   item     String specifying the DDE item name for the advisory 
%            link. Changing the data identified by item at the server 
%            triggers the advisory link.
%   callback String specifying the callback that is evaluated on
%            update notification. Changing item at the server causes 
%            callback to get passed to the eval function to be evaluated.
%   upmtx    (optional) String specifying the name of a matrix that
%            holds data sent with update notification. If upmtx is 
%            included, changing item at the server causes upmtx to be 
%            updated with the revised data.
%            Specifying an update matrix creates a hot link. Omitting 
%            upmtx or specifying it as an empty string, creates a warm 
%            link. If upmtx exists in the workspace, its contents are 
%            overwritten. If upmtx does not exist, it is created.
%   format   (optional) Two-element array specifying the format of 
%            the data to be sent on update.
%            The first element specifies the Windows clipboard format to 
%            use for the data. The only currently supported format is 
%            CF_TEXT, which corresponds to a value of 1. The second element
%            specifies the type of the resultant matrix. Valid types are 
%            NUMERIC (the default, which corresponds to a value of 0) and 
%            STRING (which corresponds to a value of 1).
%            The default format array is [1 0].
%   timeout  (optional) Scalar specifying the time-out limit for 
%            this operation.  Timeout is specified in milliseconds. 
%            (1000 milliseconds = 1 second).  If advisory link is not 
%            established within timeout milliseconds, the function fails. 
%            The default value of timeout is three seconds.
%
%   For example, set up a hot link between a range of cells in Excel
%   and the matrix 'x'.  If successful, display the matrix:
%      rc = ddeadv(channel, 'r1c1:r5c5', 'disp(x)', 'x');
%
%   See also DDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEUNADV.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:19:34 $
%   Built-in function.
