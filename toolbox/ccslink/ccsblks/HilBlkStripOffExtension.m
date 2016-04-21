function fName2 = HilBlkStripOffExtension(fName1)

if ~isequal(fName1(end-1),'.'),
    disp([mfilename, 'Error:  File does not have an extension'])
end
fName2 = fName1(1:end-2);


% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:32 $
