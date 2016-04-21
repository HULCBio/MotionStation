function out=rgstoredata(r,in)
%RGSTOREDATA stores persistent report generator information
%   I=RGSTOREDATA(RPTCOMPONENT) retrieves information
%   RGSTOREDATA(RPTCOMPONENT,I) stores information
%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:15 $

persistent RPTGEN_PERSISTENT_GENERAL_DATA

mlock

if nargin>1
   RPTGEN_PERSISTENT_GENERAL_DATA=in;
elseif ~isstruct(RPTGEN_PERSISTENT_GENERAL_DATA)
   RPTGEN_PERSISTENT_GENERAL_DATA=initialize(r);
end

out=RPTGEN_PERSISTENT_GENERAL_DATA;
