function endval = end(obj,k,n)
%END Last index in an indexing expression of instrument object array.
%
%   END(A,K,N) is called for indexing expressions involving the 
%   object A when END is part of the K-th index out of N indices.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/16 20:04:08 $

% Determine if the input is a column or row vector.
col = size(obj,2);

% Switch based on where the "end" is located.
% Ex. obj(end-1,1)  k = 1;
% Ex. obj(1,end-1)  k = 2;
switch k
case 1
   if col == 1
      % Column vector of objects - obj(2:end, 1);
      endval = length(obj);
   else
      % Row vector of objects - obj(1:end, 1);
      if n == 1
         % For the case: obj(3:end) where obj is 1-by-10.
         endval = col;
      else
         endval = 1;
      end
   end
case 2
   if col == 1
      % Column vector of objects - obj(1,1:end);
      endval = 1;
   else
      % Row vector of objects - obj(1,4:end);
      endval = length(obj);
   end
otherwise
   endval = 1;
end
