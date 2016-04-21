function disp(stk)
% DISP (Private) Displays information about a scratch memory block.
%
% Example:
%  >> disp(cc.stack)
%  Stack Object: 
%    Stack area defined : start=0x400, length=0xA
%    Objects allocated  : 0
%    Top of stack       : 0x40A
% 
% See also DISPLAY.

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:12:43 $

fprintf('Stack Object: \n');
if isempty(stk.startaddress)
    isdefined=0;
else
    isdefined=1;
end 
fprintf('  Stack area defined : '); 
if isdefined
    fprintf('start=0x%s, end=0x%s, length=0x%s\n',dec2hex(stk.startaddress(1)),dec2hex(stk.endaddress(1)),dec2hex(stk.size));
else
    fprintf('Undefined\n');
end
fprintf('  Objects allocated  : %d\n',stk.numofstackobjs);
fprintf('  Top of stack       : ');
if isdefined
    fprintf('0x%s\n',dec2hex(stk.topofstack(1)));
else
    fprintf('Undefined\n');
end

% [EOF] disp.m