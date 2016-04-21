function val = isoverlap(S)
% ISOVERLAP Check for overlap between partitions
%   B=ISOVERLAP(A) returns true if any partition
%   shares a memory location.
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:42 $
if nargin ~= 1,
   error('unexpected parameter - isoverlap does not have arguments');
end
ns = numel(S);
val = boolean(0);  % default
if ns ~= 1,
    bases = base(S);
    sizes = sizeof(S);
    lastaddr = bases + sizes -1;
    basecheck = 0;
    lastcheck = 0;
    for inxS = 1:ns,
         basecheck = basecheck+((bases(inxS) >= bases) & (bases(inxS) <= lastaddr));
         lastcheck = lastcheck+((lastaddr(inxS) >= bases) & (lastaddr(inxS) <= lastaddr));
    end
    if any(basecheck+lastcheck ~= 2),
        val = boolean(1);
    end    
end


