function p = privateIvIMasterLocation
%PRIVATEIVIMASTERLOCATION Find the IVI config store master location.
%
%   PRIVATEIVIMASTERLOCATION finds the IVI config store master loation.  It
%   can also be used to determine whether the shared IVI components have
%   been successfully installed as it returns and empty string if they are
%   not.
%
%   This is a helper function used by functions in the Instrument
%   Control Toolbox. This function should not be called directly
%   by users.

%   PE 10-10-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:49 $

try
    h = actxserver('IviConfigServer.IviConfigStore');
    p = get(h, 'MasterLocation');
catch
    p = '';
end
