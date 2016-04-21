function dmiSelectBlockStart_(ModelName, reqsys)
%DMISELECTBLOCKSTART opens a model for highlighting blocks.
%  DMISELECTBLOCKSTART(MODELNAME) opens MODELNAME
%  in preparation for highlighting blocks.  
%  DMISELECTBLOCKSTART(MODELNAME, REQSYS) uses REQSYS as
%  the requirements system.  If no REQSYS is specified,
%  it is supplied by reqmgropts.

%  Returns status
%  from REQMGR.  This function is part of the DOORS/MATLAB
%  INTERFACE (DMI).  
%
%  See also REQMGR, REQMGRCTL, DMISELECTBLOCK,
%  DMISELECTBLOCKEND
%

%  Author(s): M. Greenstein, 07/20/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2004/04/15 00:35:55 $

% Initialization
if (~nargin), r = -100; return; end

if (~exist('reqsys') | ~length(reqsys))
   reqsys = reqmgropts;
end
if (~length(reqsys)),
   error('No default requirements system has been configured.');
end

% Initialize DOORS as the requirements system and establish
% the mode of production.
r = reqmgr('Init', reqsys);
if (r), return; end

% Open and preprocess the model.
r = reqmgr('DisplayStart', ModelName);
