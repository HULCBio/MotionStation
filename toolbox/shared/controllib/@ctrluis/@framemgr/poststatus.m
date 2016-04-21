function poststatus(h,Status)
%POSTSTATUS  Posts a status message.
%
%   The message is not stored in the Status property and is 
%   therefore transient in nature.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:02 $

set(h.StatusField,'String',Status)