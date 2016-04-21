function endval = end(obj,k,n)
%END Last index in an indexing expression of device object array.
%
%    END(A,K,N) is called for indexing expressions involving the 
%    object A when END is part of the K-th index out of N indices.
%

%    MP 12-22-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:41:10 $

% Determine if the input is a column or row vector.
col = size(obj,2);

% Switch based on where the "end" is located.
% Ex. obj(end-1,1)  k = 1;
% Ex. obj(1,end-1)  k = 2;
switch k
case 1
   if col == 1
      % Column vector of objects - chan(2:end, 1);
      endval = length(obj);
   else
      % Row vector of objects - chan(1:end, 1);
      if n == 1
         % For the case: chan1(3:end) where chan1 is 1-by-10.
         endval = col;
      else
         endval = 1;
      end
   end
case 2
   if col == 1
      % Column vector of objects - chan(1,1:end);
      endval = 1;
   else
      % Row vector of objects - chan(1,4:end);
      endval = length(obj);
   end
otherwise
   endval = 1;
end
