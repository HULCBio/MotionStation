function dspblkmmult(numInputPorts)
% DSPBLKMMULT Mask help function for N-port matrix multiply block.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/08/26 19:49:11 $

blk = gcbh;

% Construct input port labels:
%
port_labels = '';
%disp_list = '';
if ((numInputPorts > 0)&&(numInputPorts <inf))
for i=1:numInputPorts,
    portChar = getPortChar(i);
    label = ['''' portChar ''''];
    new_label = ['port_label(''input'',' num2str(i), ', ' label '); '];
    port_labels = [port_labels new_label];
    
    % disp_list = [disp_list portChar];
end
end

% Construct output port label
%
switch numInputPorts
case 1
    disp_list = 'A';
case 2
    disp_list = 'A*B';
otherwise
    disp_list = 'A*B*..';
end
% disp_str = ['disp(''' disp_list ''');'];
disp_str = ['port_label(''output'', 1, ''' disp_list ''');'];


str = [port_labels disp_str];
set_param(blk,'maskdisplay',str);

% ---------------------------------------------------------
function y = getPortChar(i)

allIdx=[];
s = dec2base(i-1,26);
for i=1:length(s),
    si=s(i);
    if si < 'A',
        idx=si-'0'+1;
    else
        idx=si-'A'+11;
    end
    if i<length(s), idx=idx-1; end
    allIdx=[allIdx idx];
end

y = char('A'+allIdx-1);


% [EOF] dspblkmmult.m
