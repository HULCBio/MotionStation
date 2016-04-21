function disp(bb)
%DISP Display properties of Link to Code Composer Studio(R) IDE.
%   DISPLAY(CC) displays a formatted list of values that describe 
%   the CC object.  

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/08 20:45:39 $

fprintf('\nBITFIELD Object stored in memory: \n')
fprintf('  Symbol name             : %s\n',bb.name);
fprintf('  Address                 : [ %.0f %1.0f]\n', bb.address(1), bb.address(2) );
disp_memoryobj(bb); % display memoryobj properties
disp_bitfield(bb);  % display bitfield properties
fprintf('\n');

%[EOF] disp.m