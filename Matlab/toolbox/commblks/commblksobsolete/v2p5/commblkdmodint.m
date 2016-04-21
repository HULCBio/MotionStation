function [modu, init] = commblkdmodint(block)
%Initialization for Discrete Modulo Integrator.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:28 $

setallfieldvalues(block);		% to get mask parameters

if (~isempty(maskTs))
    if(length(maskTs) ~= 1)
        error('Sample time parameter must be a real scalar.');
    end
end

if (sum(maskModu<=abs(maskInit))~=0)
    error('The absolute value of Initial condition parameter must be smaller than Absolute value bound parameter.');
end

maskModu(find(isinf(maskModu))) = realmax;
maskInit(find(isinf(maskInit))) = realmax;

modu = maskModu;
init = maskInit;

% We need to remove spaces for the mask method setting as Simulink built-in discrete time 
% integrator doesn't have spaces in the IntegrationMethod but our blocks do. For example,
% we have "Forward Euler" and the built-in block has "ForwardEuler". Don't change parameter
% in library as it would be backwards incompatible.

% comment out this part as Simulink builtin block uses space for Forward Euler as well
% should be cleaned by comm's people afterwards.
%maskMethod = strrep(maskMethod, ' ', '');

set_param([block, '/Discrete Modulo Integrator/Discrete-Time Integrator'], ...
          'IntegratorMethod', maskMethod);

%[EOF]
