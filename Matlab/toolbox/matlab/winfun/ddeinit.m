%DDEINIT Initiate DDE conversation.
%   DDEINIT requires two arguments: a service or application name and a 
%   topic for that service.  The function returns a channel handle, which 
%   is used with other MATLAB DDE functions.
%
%   channel = DDEINIT(service,topic)
%
%   channel Channel assigned to the conversation.
%   service String specifying the service or application name 
%           for the conversation.
%   topic   String specifying the topic for the conversation.
%
%   For example, to initiate a conversation with Microsoft Excel
%   for the spreadsheet 'forecast.xls':
%      channel = ddeinit('excel','forecast.xls');
%
%   See also DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:19:31 $
%   Built-in function.
