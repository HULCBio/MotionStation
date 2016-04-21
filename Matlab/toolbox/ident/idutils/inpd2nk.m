function mnk = inpd2nk(md)
%INPD2NK converts input delays to state space models with explicit delays
%
%   Modnk = INPD2NK(Mod)
%
%   Mod: any discrete time IDMODEL with specified Property InputDelay.
%   Modnk: A discrete time IDSS model in free parameteriztion with the
%      the input delays represented in the A, B, C - matrices. Thus
%      Modnk.InputDelay = 0, but Modnk.nk not zero.

%   L. Ljung 02-01-03
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2003/08/26 13:31:21 $

if pvget(md,'Ts')==0
    error('INPD2NK can only be used for discrete time systems')
end
mnk = idss(md);
mnk = pvset(mnk,'SSParameterization','Free');
inpd = pvget(mnk,'InputDelay');
nk = pvget(mnk,'nk');
nk = max(nk,1);
mnk = pvset(mnk,'InputDelay',zeros(size(inpd)));
mnk = pvset(mnk,'nk',nk+inpd');
