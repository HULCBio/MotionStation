%COMCLIENT Switch between old and new implementations of automation client.
%   MSG = COMCLIENT(STATE) sets the automation client interface to either
%   the new or old implementations depending on the value of the char
%   array STATE.  STATE can be one of 'on', 'off', or 'getpath'.  Choosing
%   'on' turns on the new automation client interface and 'off' reverts back
%   to the old automation client interface.  By default, i.e., without the 
%   explicit invocation of this function, the old automation interface is
%   available.  Choosing 'getpath' returns the currently executing automation
%   client interface.  MSG is a char array that contains the status of the 
%   execution of the function.

%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.1 $ $Date: 2001/08/31 15:48:09 $


