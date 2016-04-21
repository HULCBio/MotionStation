
%-----------------------------------------------------------------
function  dehiliteModelAncestors(h),
%  DEHILITE__ANCESTORS
%  This function will dehilit the anscestors of the model
%  associated with the Diagnosctiv Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:30 $
 
%

% dehilite the ancestors of the model
  sysH = h.modelH;
  if ishandle(sysH)
    set_param(sysH, 'HiliteAncestors', 'off');
  end;
%------------------------------------------------------------------------------
 
