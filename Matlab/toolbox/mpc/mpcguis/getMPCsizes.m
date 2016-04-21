function [NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S)

% Copyright 2003 The MathWorks, Inc.

% Convenience function gets signal size information from MPCGUI node

NumMV = S.Sizes(1);
NumMD = S.Sizes(2);
NumUD = S.Sizes(3);
NumMO = S.Sizes(4);
NumUO = S.Sizes(5);
NumIn = S.Sizes(6);
NumOut = S.Sizes(7);