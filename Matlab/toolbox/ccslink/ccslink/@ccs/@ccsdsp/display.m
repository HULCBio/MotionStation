function display(cc)
%DISPLAY Display a Code Composer Studio(R) IDE object.
%   DISPLAY(CC) displays information about the CC object. 
%   Note: CC can be a single CCSDSP handle or vector of CCSDSP handles.
%
%   Example 1: disp output if CC is a single CCSDSP handle
% 	CCSDSP Object:
%       API version      : 1.2
%       Processor type   : TMS320C5500
%       Processor name   : CPU
%       Running?         : No
%       Board number     : 0
%       Processor number : 0
%       Default timeout  : 10.00 secs
% 	
%       RTDX channels    : 0
%    
%   Example 2: disp output if CC is an array of CCSDSP handles
%
% 	Array of CCSDSP Objects:
%       API version              : 1.2
%       Board name               : OMAP 3.0 Platform Simulator [Texas Instruments]
%       Board number             : 3
%       Processor 0  (element 1) : TMS470R2127 (MPU, Not Running)
%       Processor 1  (element 2) : TMS320C5500 (DSP, Not Running)
%
%   See also DISP.

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.10.4.3 $ $Date: 2004/04/08 20:45:46 $

% Suppress 'ans' display (UDD limitation, for now)
if 0,
    name = inputname(1);
    if isempty(name)
        name = 'ans';
    end
end

isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

% fprintf(newline);
% disp([name, ' = ']);
fprintf(newline);
disp(cc);
fprintf(newline)

% [EOF] display.m