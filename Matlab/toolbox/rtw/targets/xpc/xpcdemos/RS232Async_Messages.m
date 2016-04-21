% This is the file that has the send and receive structures that will
% enable you to simulate the model. 

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.6.1 $  $Date: 2004/04/08 21:05:21 $

% Parameters for the send block.
RS232_Send(1).SendData = 'start,%f,stop;\r';
RS232_Send(1).InputPorts = [1];
RS232_Send(1).Timeout = 0.01;
RS232_Send(1).EOM =1;

% Parameters for the receive block.
RS232_Receive(1).RecData = 'start,%f,stop;\r';
RS232_Receive(1).OutputPorts = [1];
RS232_Receive(1).Timeout = 0.01;
RS232_Receive(1).EOM =1;



