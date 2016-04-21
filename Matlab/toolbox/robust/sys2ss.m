function [a,b,c,d] = sys2ss(sys,x)
%SYS2SS Split state-space quadruple into regular form.
%
% [A,B,C,D] = SYS2SS(SYS,X) peels off the state-space from the
%    system matrix quadruple:
%
%             sys = |A  B|,         x : no. of states
%                   |C  D|
%

% R. Y. Chiang & M. G. Safonov 2/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
%
[rs,cs] = size(sys);
a = sys(1:x,1:x);
b = sys(1:x,x+1:cs);
c = sys(x+1:rs,1:x);
d = sys(x+1:rs,x+1:cs);
%
% ------ End of SYS2SS.M --- RYC/MGS %
