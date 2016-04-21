function dummy = disp_registerobj(mm)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/11/30 23:10:38 $

fprintf('  Word size                : %d bits\n', mm.wordsize);
fprintf('  Register units per value : %d ru\n', mm.storageunitspervalue);
fprintf('  Representation           : %s\n', mm.represent);
if mm.binarypt > 0,
fprintf('  Binary point position    : %d\n', mm.binarypt);
end
if mm.prepad > 0,
fprintf('  Bit padding (pre)        : %d\n', mm.prepad); 
elseif mm.postpad > 0,
fprintf('  Bit padding (post)       : %d\n', mm.postpad);
end

fprintf('  Size                     : [ ');
for i=1:length(mm.size)
fprintf('%d ',mm.size(i));
end
fprintf(']\n');

fprintf('  Total register units     : %d ru\n', mm.numberofstorageunits);
fprintf('  Array ordering           : %s\n', mm.arrayorder);

%[EOF] disp_registerobj.m