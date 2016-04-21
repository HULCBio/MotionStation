function dmiSelectBlockEnd_
%DMISELECTBLOCKEND Clean up block highlighting.
%  DMISELECTBLOCKEND() selects a block in a block diagram
%  and highlights (selects) it.  Return status from
%  REQMGR.  This function is part of the DOORS/MATLAB
%  INTERFACE (DMI).
%
%  See also REQMGR, REQMGRCTL, DMISELECTBLOCKSTART,
%  DMISELECTBLOCK
%

%  Author(s): M. Greenstein, 07/16/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2004/04/15 00:35:54 $

% Cleanup the context of the current model.
r = reqmgr('DisplayEnd');
