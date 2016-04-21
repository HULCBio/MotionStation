function [Yout,Xout] = ssfreqresp(A,B,C,D,U,w);
% function [Yout,Xout] = ssfreqresp(A,B,C,D,U,w);
% MIMO frequency response of state-space model (A,B,C,D)
%
% Yout(k,:).' = ( D + C(w(k)I-A)^{-1}B )U(k,:).'
% 

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:20:27 $
Xout = freqkern(A,B,U,w);
Yout  = (C*Xout).' + U*D.';

