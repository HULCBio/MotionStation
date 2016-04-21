function stk = stack(bpnum)

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:12:46 $
 
stk = ccs.stack;

set(stk, 'stackobjects', struct([]));

if ~isa(bpnum,'double') & length(bpnum) ~= 2  ,
    error('Cannot create Stack object without board and proc number ');
end

set(stk, 'boardnum', bpnum(1));
set(stk, 'procnum',  bpnum(2));

% [EOF] stack.m