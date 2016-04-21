function [L1,L2] = simpdelay(L1,L2)
%SIMPDELAY  Simplify delays in division SYS1\SYS2 or SYS2/SYS1.
%
%   Called by MRDIVIDE and MLDIVIDE.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 05:48:09 $

if issiso(L1) & hasdelay(L1),
   % SYS1 is SISO and has delays: SYS1\SYS2 will be causal if SYS2
   % has an excess of delays compared to SYS1
   % Compute total I/O delays TD1 and TD2   
   Td1 = totaldelay(L1);
   Td2 = totaldelay(L2);
   std2 = size(Td2);
   
   % Eliminate all input and output delays
   L1.InputDelay = 0;
   L1.OutputDelay = 0;
   L2.InputDelay = zeros(std2(2),1);
   L2.OutputDelay = zeros(std2(1),1);
   
   % Subtract min(TD1,TD2) from both TD1 and TD2 (delays simplified 
   % in the division) and reset I/O delay matrices
   Tdmin = min(Td1,min(min(Td2,[],1),[],2));
   stdm = size(Tdmin);
   Td1 = Td1 - Tdmin;
   Td2 = repmat(Td2,[1 1 stdm(3:2+length(stdm)-length(std2))]) - ...
         repmat(Tdmin,std2(1:2));
   L1.ioDelay = tdcheck(Td1);
   L2.ioDelay = tdcheck(Td2);
end

% RE: Do nothing in MIMO case (will cause an error in MLDIVIDE except for FRDs)
