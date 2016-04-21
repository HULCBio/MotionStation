function endval = end(obj,k,n);
%END Last index in an indexing expression of GF object array.
%
%    END(A,K,N) is called for indexing expressions involving the 
%    object A when END is part of the K-th index out of N indices.
%

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:15:07 $

% Determine the size of the object
objsize=size(obj);
[row,col] = size(obj);
 
% Switch based on where the "end" is located.
switch k
case 1
    % "end" is located in the first entry
    if n == 1
        endval = row*col;
    else
        endval = row;
    end
otherwise
    % "end" is not located in the first entry
    if n == k
        % "end" is located in the last entry    
        endval=1;
        for i=k:length(objsize)
            endval = endval*objsize(i);
        end
    else
        % "end" is not located in the last entry 
        endval=objsize(k);
    end
end
     