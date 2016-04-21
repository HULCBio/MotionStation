function [e1,e2] = ematchk(e1,a1,e2,a2)
%EMATCHK  E matrix formatting for descriptor state space
%
%   E = EMATCHK(E) resets the E matrices to [] when they
%   are all equal to I.
%
%   [E1,E2] = EMATCHK(E1,A1,E2,A2) enforces consistency
%   of E1 and E2 by making all matrices nonempty if at
%   least one is nonempty.  The E matrix sizes are provided
%   by A1 and A2.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:03:04 $


if nargin==1,
   % E = EMATCHK(E)
   EmptyE = cellfun('isempty',e1);
   ArraySize = size(e1);
   if ~all(EmptyE(:)),
      % Determine if E=I for all models
      explicit = 1;
      for k=1:prod(ArraySize),
         explicit = explicit & isequal(e1{k},eye(size(e1{k})));
      end
      if explicit
         e1 = cell(ArraySize);
      end
   end
   
elseif isa(e1,'cell')
   % [E1,E2] = EMATCHK(E1,A1,E2,A2)
   EmptyE1 = cellfun('isempty',e1);   EmptyE1 = all(EmptyE1(:));
   EmptyE2 = cellfun('isempty',e2);   EmptyE2 = all(EmptyE2(:));
   if ~EmptyE1 | ~EmptyE2,
      if EmptyE1,
         % E1 is empty
         for k=1:prod(size(e1)),
            e1{k} = eye(size(a1{k}));
         end
      elseif EmptyE2,
         % E2 is empty
         for k=1:prod(size(e2)),
            e2{k} = eye(size(a2{k}));
         end
      end
   end
   
elseif ~isempty(e1) | ~isempty(e2),
   if isempty(e1),
      e1 = eye(size(a1));
   elseif isempty(e2),
      e2 = eye(size(a2));
   end
      
end



   