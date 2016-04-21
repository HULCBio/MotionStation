function deletemem(cc)
% DELETEMEM (Private) Removes the scratch memory block created through
%  CREATEMEM, thereby preventing any further data allocations on that 
%  memory block.
%
% See also CREATEMEM.

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:07:00 $

if isempty(cc.stack.startaddress)
    warning('There is no defined memory block to be deleted.');
else
	cc.stack.stackobjects   = struct([]);
	cc.stack.startaddress   = [];
	cc.stack.endaddress     = [];
	cc.stack.size      = 0;
	cc.stack.numofstackobjs = 0;
	cc.stack.stacksplist    = [];
	cc.stack.topofstack     = [];
	cc.stack.toslist        = [];
	cc.stack.storageUnitsLeft = 0;
    disp(cc.stack);
end

% [EOF] deletemem.m