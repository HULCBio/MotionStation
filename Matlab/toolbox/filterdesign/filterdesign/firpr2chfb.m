function [h0,h1,g0,g1] = firpr2chfb(N,fp,varargin)
%FIRPR2CHFB   FIR perfect reconstruction 2 channel filter bank design.
%   [H0,H1,G0,G1] = FIRPR2CHFB(N,Fp) designs four FIR filters for the
%   analysis (H0 and H1) and synthesis (G0 and G1) sections of a
%   two-channel perfect reconstruction filter bank. The design corresponds
%   to so-called orthogonal filter banks also known as power-symmetric
%   filter banks.
%
%   N is the order of all four filters, and it must be an odd integer. Fp
%   is the passband-edge for the lowpass filters H0 and G0 it must be less
%   than 0.5. H1 and G1 are highpass filters with passband-edge given by
%   1-Fp.
%
%   [H0,H1,G0,G1] = FIRPR2CHFB(N,Dev,'dev') designs the four filters such
%   that the maximum stopband-ripple of H0 is given by the scalar Dev. The
%   stopband-ripple of H1 will also be given by Dev, while the maximum
%   stopband-ripple for both G0 and G1 will be 2*Dev.
%
%   [H0,H1,G0,G1] = FIRPR2CHFB('minorder',Fp,Dev) designs the four filters
%   such that H0 meets the passband-edge Fp and the stopband-ripple Dev
%   with minimum-order.
%
%   % EXAMPLE: Design a filter bank with filters of order 99 and passband
%   % edges of 0.45 and 0.55:
%      N = 99;
%      [h0,h1,g0,g1] = firpr2chfb(N,.45);
%      fvtool(h0,1,h1,1,g0,1,g1,1);
%
%   % The following plots can be used to verify perfect reconstruction:
%      stem(1/2*conv(g0,h0)+1/2*conv(g1,h1))
%      n=0:N;
%      stem(1/2*conv((-1).^n.*h0,g0)+1/2*conv((-1).^n.*h1,g1))
%      stem(1/2*conv((-1).^n.*g0,h0)+1/2*conv((-1).^n.*g1,h1))
%      stem(1/2*conv((-1).^n.*g0,(-1).^n.*h0)+1/2*conv((-1).^n.*g1,(-1).^n.*h1))
%      stem(conv((-1).^n.*h1,h0)-conv((-1).^n.*h0,h1))
%
%   See also FIRHALFBAND, FIRNYQUIST, FIRGR, FIRCEQRIP.

%   References: 
%     [1] S. K. Mitra, Digital Signal Processing. A Computer-Based
%          Approach. 2nd Ed. McGraw-Hill, N.Y., 2001, Chapter 10.
%     [2] N. Fliege, Multirate Digital Signal Processing, 
%          John Wiley & Sons, Chichester, 1994.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:25:33 $

error(nargchk(2,5,nargin));

if ~ischar(N) && ~rem(N,2),
    error(generatemsgid('oddOrd'),'The order must be odd.');
end

h0 = firhalfband(N,fp,varargin{:},'minphase');

% Use the filter length to compute the other filters
L = length(h0);

n = 0:L-1;

h1 = fliplr(((-1).^n).*h0);

g0 = 2*fliplr(h0);

g1 = 2*fliplr(h1);





