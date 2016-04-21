% LYAPKR �́ALyapunov/Sylvester �������̃\���o (�N���l�b�J�ς��g�����A�v��
%        �[�`)
%
% [X] = LYAPKR(A,B,C) �́ALyapunov�A�܂��́ASylvester �������̉����Z�o����
% ���B
% 
% �A���S���Y���́A���ʂȎ�ނ̒P���ȃN���l�b�J�ς��g���܂��B
%
%        A1*X*B1 + A2*X*B2 + A3*X*B3 + ... = Ck
%
% ���́A���̂悤�ɂȂ�܂��B
%
%        [KRON(A1,B1') + KRON(A2,B2') + ... ] * S[X] = S(Ck)
%
% Lyapunov�A�܂��́ASylvester �������ɑ΂��āA���̌^�����Ă��܂��B
%
%            A1 = A,  B1 = I,  A2 = I, B2 = B,  Ck = -C.
%
% �����ŁA���̊֌W�����藧���Ă��܂��B  A * X + X * B + C = 0
%

% Copyright 1988-2002 The MathWorks, Inc. 
