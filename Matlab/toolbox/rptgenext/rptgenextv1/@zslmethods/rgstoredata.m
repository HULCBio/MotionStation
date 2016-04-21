function out=rgstoredata(z,in)
%RGSTOREDATA stores persistent data

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:50 $

persistent RPTGEN_STORED_SIMULINK_DATA

mlock

if nargin>1
   RPTGEN_STORED_SIMULINK_DATA=in;
end

out=RPTGEN_STORED_SIMULINK_DATA;
