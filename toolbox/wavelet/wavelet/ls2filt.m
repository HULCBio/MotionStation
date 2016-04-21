function [LoD,HiD,LoR,HiR] = ls2filt(LS)
%LS2FILT Lifting scheme to filters.
%   [LoD,HiD,LoR,HiR] = LS2FILT(LS) returns the four
%   filters associated to the lifting scheme LS.
%
%   See also FILT2LS, LSINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jul-2003.
%   Last Revision: 09-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:50 $

[LoD,HiD,LoR,HiR] = ls2filters(LS,'d_num');
