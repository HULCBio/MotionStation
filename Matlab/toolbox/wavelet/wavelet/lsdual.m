function LSR = lsdual(LS)
%LSDUAL Dual lifting scheme.
%   LSD = LSDUAL(LS) returns the lifting scheme LSD 
%   associated to LS. LS and LSD are issued of the
%   same polyphase matrix factorisation PMF, where
%   PMF = LS2PMF(LS). So [LS,LSD] = PMF2LS(PMF,'t').
%
%   For more information about lifting schemes type: lsinfo.
%
%   N.B.: LS = LSDUAL(LSDUAL(LS)).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jun-2002.
%   Last Revision: 26-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:54 $

[PMF,dummy] = ls2pmf(LS,'t');
[dummy,LSR] = pmf2ls(PMF,'t');
