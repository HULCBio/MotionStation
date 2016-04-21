function address = base(S,opt)
% BASE  Returns base address of partition(s)
%  AN = BASE(S) returns a vector of values that equal to the first address
%    for each partition of S.  
%  AN = BASE(S,'char') returns a cell array of values which equal the 
%    first address of each partition of S, formated as C-style hexidecimal
%    string.
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:37 $
  
address = [];
nS = numel(S);
for inxS = 1:nS,
    faddr = S(inxS).Address(1);
    address = horzcat(address,faddr);
end
if nargin == 2 && ischar(opt) && strcmpi(opt,'char')
    caddr = {};
    for elemaddr = address
        caddr = horzcat(caddr,{['0x' dec2hex(elemaddr)]});
    end
    if nS==1,
       address = caddr{1}; 
    else
       address = caddr;        
    end
end
