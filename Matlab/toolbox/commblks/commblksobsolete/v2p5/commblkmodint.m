function [modu, init] = commblkmodint(block)
%Initialization for Modulo Integrator.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:30 $

setallfieldvalues(block);		% to get mask parameters

if (sum(maskModu<=abs(maskInit)) ~= 0)
    error('The absolute value of Initial condition parameter must be smaller than Absolute value bound parameter.');
end

maskModu(find(isinf(maskModu))) = realmax;
maskInit(find(isinf(maskInit))) = realmax;

modu = maskModu;
init = maskInit;

%[EOF]
