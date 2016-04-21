function restorepointers( pj )
%RESTOREPOINTERS Restore Pointers of all open Figures. 
%   PREPAREPOINTERS previously set all Figure Pointers to Watch.
%
%   See also PREPAREPOINTERS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:10:04 $

%Make sure we set pointer(s) back even if we are erroring out.
switch length(pj.AllFigures)
 case 0
    %NOP
 case 1
   if ishandle(pj.AllFigures), set( pj.AllFigures, 'pointer', pj.AllPointers ); end; 
 otherwise, 
  m = ishandle(pj.AllFigures); 
  pj.AllFigures  = pj.AllFigures(m); % remove bad handles 
  pj.AllPointers = pj.AllPointers(m); 
  set( pj.AllFigures, {'pointer'}, pj.AllPointers ); 
end
