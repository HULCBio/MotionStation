function [z,gain] = zero(sys)
%ZERO  Transmission zeros of LTI systems.
% 
%   Z = ZERO(SYS) returns the transmission zeros of the LTI 
%   model SYS.
%
%   [Z,GAIN] = ZERO(SYS) also returns the transfer function gain
%   (in the zero-pole-gain sense) for SISO models SYS.
%   
%   If SYS is an array of LTI models with sizes [NY NU S1 ... Sp],
%   Z and K are arrays with as many dimensions as SYS such that 
%   Z(:,1,j1,...,jp) and K(1,1,j1,...,jp) give the zeros and gain 
%   of the LTI model SYS(:,:,j1,...,jp).  The vectors of zeros are 
%   padded with NaN values for models with relatively fewer zeros.
%
%   See also POLE, PZMAP, ZPK, LTIMODELS.

%   Clay M. Thompson  7-23-90, 
%   Revised:  P.Gahinet 5-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:16:14 $

error('ZERO is not supported for FRD models.')
