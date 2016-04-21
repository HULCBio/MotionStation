function Mc = noisecnv(M,option)
% NOISECNV Converts noise channels to measured channels
%   Modc = NOISECNV(Model,Noise)
%
%   Model is any IDMODEL object (IDGREY, IDARX, IDPOLY, or IDSS)
%   Modc is a model of the same class as Model where both measured inputs
%   and noise sources are treated as measured inputs. 
%
%   There are two variants. If Noise = 'N(ormalize)', the noise sources are
%   first normalized to be independent and of unit variance. If 
%   Noise = 'I(nnovation)' no normalization takes place, and the noise
%   sources remain as the innovations process.
%
%   More precisely: Let Model represent the model
%   y = G u + H e;  
%   or in state space form 
%   x(t+1) = Ax(t) + Bu(t) + Ke(t)
%   y(t) = Cx(t) + Du(t) + e(t)
%   Here e are the innovations of the model. The variance of e is
%   Model.NoiseVariance = L*L'.
%   
%   With Noise = 'Innovations', (Default) Modc represents the model
%   y = [G H] [u;e] 
%   or in state space form
%   x(t+1) = Ax(t) + [B K][u(t);e(t)]
%   y(t) = Cx(t) + [D I][u(t);e(t)];
%   with Nu+Ny input channels. The input channels e are given InputNames
%   'e@yk', where 'yk' is the OutputName of the k:th channel. This gives the
%   "e-contribution at the k:th output channel." TFDATA, ZPKDATA etc, applied 
%   to Modc will in this case retrieve the transfer functions G and H.
%
%   With Noise = 'Normalize', first the normalization
%   e = L v is made, where v is white noise with independent channels and unit
%   variances. This makes e white noise with covariance matrix L*L'.
%   The Modc represents the model
%   y = [G HL][u;v]
%   or in state space form
%   x(t+1) = Ax(t) + [B KL][u(t);v(t)]
%   y(t) = Cx(t) +[D L][u(t);v(t)]
%   with Nu+Ny input channels. The input channels v are given InputNames
%   'v@yk', where 'yk' is the OutputName of the k:th channel. This gives the
%   "v-contribution at the k:th output channel." TFDATA, ZPKDATA etc, applied 
%   to Modc will in this case retrieve the transfer functions G and HL, so
%   the noise level will be reflected, e.g., when applying STEP to Modc.
%
%   The uncertainty information in G, H and in then noise variance is 
%   properly translated from Model to Modc.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2004/04/10 23:17:32 $

if nargin <2
   option = 'i';
end
if norm(pvget(M,'NoiseVariance'))==0
    Mc = M;
    return
end
option = lower(option(1));
if ~(option=='n'| option=='i')
   error('Normalization must be of of ''N(ormalize)'' or ''I(nnovation)''.')
end

if option=='i'
   Mc = setnoime(M);%M('both');
else
   Mc = M(:,'allx9');
end
