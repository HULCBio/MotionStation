% SS2ZP   ��ԋ�Ԃ����_-�ɂւ̕ϊ�
% 
% [Z,P,K] = SS2ZP(A,B,C,D,IU) �́A�P���� IU ����A�V�X�e��
%
%     x = Ax + Bu
%     y = Cx + Du
%
% �̓`�B�֐�
% 
%                  -1           (s-z1)(s-z2)...(s-zn)
%     H(s) = C(sI-A) B + D =  k ---------------------
%                               (s-p1)(s-p2)...(s-pn)
% 
% ���v�Z���܂��B�x�N�g�� P �́A�`�B�֐��̕���̋ɂ̈ʒu���܂�ł��܂��B
% ���q�̃[���́A�o�� y �Ɠ����̗񐔂����s�� Z �̗�ɏo�͂���܂��B
% �e���q�̓`�B�֐��̗����́A��x�N�g�� K �ɏo�͂���܂��B
%
% �Q�l�FZP2SS,PZMAP,TZERO, EIG.


%   J.N. Little 7-17-85
%   Revised 3-12-87 JNL, 8-10-90 CLT, 1-18-91 ACWG, 2-22-94 AFP.
%   Copyright 1984-2003 The MathWorks, Inc.