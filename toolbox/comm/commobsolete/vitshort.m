function out = vitshort(fst_in, snd_in, n_sta, mima);
%VITSHORT makes two steps of transition expense into one step expense.
%
%WARNING: This is an obsolete function and may be removed in the future.

%    OUT = VITSHORT(FST_IN, SND_IN, N_STA, MIMA)
%
%     FST_IN    step one
%     SND_IN    step two
%     N_STA     number of state
%     MIMA      ==1 to find the minimum, == 0 to find the maximum
%     OUT, FST_IN, and SND_IN are size 2^N_STA row vectors of transition costs
%     [d00, d10, d20, ..., dn0, d01, d11, d21,..., dn1, ...., d0n, d1n, d2n, ...., dnn],
%     where dij is the cost of transition from state i to state j.
%     dij = NaN means that there is no possible transition between the two states.
%  
%     Used by VITERBI.

%       Wes Wang 12/10/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.13 $
