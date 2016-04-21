% ADDSS は、2つの状態空間システムを加えます。
%
% [SS_] = ADDSS(SS_1,SS_2)、または、
% [A,B,C,D] = ADDSS(A1,B1,C1,D1,A2,B2,C2,D2) は、2つの状態空間実現を加えます。
%
%                                           -1
%             G(s) = G1(s) + G2(s) = C(Is-A)  B + D
% ここで、
%                              -1
%             G1(s) = C1(Is-A1)  B1 + D1,  SS_1 = MKSYS(A1,B1,C1,D1)
%
%                              -1
%             G2(s) = C2(Is-A2)  B2 + D2,  SS_2 = MKSYS(A2,B2,C2,D2);
% と表しています。

% Copyright 1988-2002 The MathWorks, Inc. 
