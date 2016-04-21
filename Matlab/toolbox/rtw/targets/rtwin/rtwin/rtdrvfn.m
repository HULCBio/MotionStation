function rtdrvfn
%RTDRVFN Get hardware driver file properties.
%
%   RTDRVFN(SUBFN,DRVNAME) retrieves hardware driver property specified by SUBFN.
%   SUBFN can be one of the following:
%     'GetInterfaceVersion'
%     'GetFileRevision'
%     'GetDefaultParameters'
%     'GetGUIControls'
%     'GetIOCaps'
%
%   Do not call directly. The interface is likely to change in future.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2004/04/15 00:29:57 $  $Author: batserve $

% implemented as MEX-file
