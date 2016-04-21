function outv = sf_inject_event (cmd)
% SF_INJECT_EVENT  Inject an event into the Stateflow Icon Editor
%
% Use: sf_inject_event (ev), where ev can be one of
%    'BM'    Mouse motion
%    'NBD'   Normal (left) mouse button-down
%    'BU'    Mouse button-up
%    'ABD'   Alternate (right) mouse button-down


%
%   Tom Walsh August 2000
%
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5.2.1 $  $Date: 2004/04/15 00:53:04 $
%

% Keep a history of the "current" vector
persistent vec;

if (isempty(vec))
   vec = [0 0 0 0];		% Default vector at time=0
else
   
   if (nargin == 1)
      
      % If we get an event, toggle the correct vector element
      if (~isnumeric(cmd))
         switch cmd,
         case 'BM',
            vec(1) = ~vec(1);
         case 'NBD',
		      vec(2) = ~vec(2);
		   case 'BU',
		      vec(3) = ~vec(3);
         case 'ABD',
            vec(4) = ~vec(4);
         end
         
      end
      
   end
   
end

% Send the result to Stateflow
outv = vec;

   
   
      	
      
