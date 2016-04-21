function dummy = disp_memoryobj(mm)
% Private. Display memoryobj-specific properties.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/11/30 23:09:20 $

fprintf('  Word size               : %d bits\n', mm.wordsize);
fprintf('  Address units per value : %d au\n', mm.storageunitspervalue);
fprintf('  Representation          : %s\n', mm.represent);
if mm.binarypt > 0,
fprintf('  Binary point position   : %d\n', mm.binarypt);
end
if mm.prepad > 0,
fprintf('  Bit padding (pre)       : %d\n', mm.prepad); 
elseif mm.postpad > 0,
fprintf('  Bit padding (post)      : %d\n', mm.postpad);
end

fprintf('  Size                    : [ ');
for i=1:length(mm.size)
fprintf('%d ',mm.size(i));
end
fprintf(']\n');

fprintf('  Total address units     : %d au\n', mm.numberofstorageunits);
fprintf('  Array ordering          : %s\n', mm.arrayorder);
fprintf('  Endianness              : %s\n',mm.endianness);

%[EOF] disp_memoryobj.m