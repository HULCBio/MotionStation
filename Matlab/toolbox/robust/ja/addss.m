% ADDSS �́A2�̏�ԋ�ԃV�X�e���������܂��B
%
% [SS_] = ADDSS(SS_1,SS_2)�A�܂��́A
% [A,B,C,D] = ADDSS(A1,B1,C1,D1,A2,B2,C2,D2) �́A2�̏�ԋ�Ԏ����������܂��B
%
%                                           -1
%             G(s) = G1(s) + G2(s) = C(Is-A)  B + D
% �����ŁA
%                              -1
%             G1(s) = C1(Is-A1)  B1 + D1,  SS_1 = MKSYS(A1,B1,C1,D1)
%
%                              -1
%             G2(s) = C2(Is-A2)  B2 + D2,  SS_2 = MKSYS(A2,B2,C2,D2);
% �ƕ\���Ă��܂��B

% Copyright 1988-2002 The MathWorks, Inc. 
