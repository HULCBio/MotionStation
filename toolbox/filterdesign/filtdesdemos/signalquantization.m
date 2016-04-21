%% Signal Quantization
% This is a demonstration of the statistics of the error when signals are
% quantized using various rounding methods.
% 
% First, a random signal is created that spans the range of the quantizer.
% 
% Next, the signal is quantized with roundmodes 'fix', 'floor', 'ceil'
% 'round', and 'convergent', and the statistics of the signal are estimated.
%
% Thomas A. Bryan, 15 September 1999
% Copyright 1999-2002 The MathWorks, Inc.
% $Revision: 1.9 $  $Date: 2002/04/14 15:19:09 $

%%
% Create uniformly distributed random input data

q = quantizer([16 15]);            % A 16-bit fixed-point quantizer
r = realmax(q);
u = r*(2*rand(5000,1) - 1);        % Uniformly distributed (-1,1)
plot(u,'.');
title('Uniformly distributed input signal')
xlabel('n'); ylabel('u')


%%

q = quantizer('fix',[16 15]);
x = u - quantize(q,u);
plot(x,'.');  xlabel('n'); ylabel('x = error')
v=10*log10(var(x));
title(['''fix'',  eps(q) = ', num2str(eps(q)),'  -eps(q)<x<eps(q)'])

%%

q = quantizer('floor',[16 15]);
x = u - quantize(q,u);
plot(x,'.');  xlabel('n'); ylabel('x = error')
10*log10(var(x));
title(['''floor'',  eps(q) = ', num2str(eps(q)),'  0<=x<eps(q)'])

%%

q = quantizer('ceil',[16 15]);
x = u - quantize(q,u);
plot(x,'.');  xlabel('n'); ylabel('x = error')
10*log10(var(x));
title(['''ceil'',  eps(q) = ', num2str(eps(q)),'  -eps(q)<=x<0'])



%%

q = quantizer('round',[16 15]);
x = u - quantize(q,u);
plot(x,'.');  xlabel('n'); ylabel('x = error')
10*log10(var(x));
title(['''round'',  eps(q)/2 = ', num2str(eps(q)/2),'  -eps(q)/2<=x<eps/2'])

%%

q = quantizer('convergent',[16 15]);
x = u - quantize(q,u);
plot(x,'.');  xlabel('n'); ylabel('x = error')
10*log10(var(x));
title(['''convergent'',  eps(q)/2 = ', num2str(eps(q)/2), ...
        '  -eps(q)/2<=x<=eps(q)/2'])
