% SS2TF   ��ԋ�Ԃ���`�B�֐��ւ̕ϊ�
% 
% [NUM,DEN] = SS2TF(A,B,C,D,iu) �́Aiu�Ԗڂ̓��͂���V�X�e��
% 
%     x = Ax + Bu
%     y = Cx + Du
%
% �̓`�B�֐�
% 
%             NUM(s)          -1
%     H(s) = -------- = C(sI-A) B + D
%             DEN(s)
% 
% ���v�Z���܂��B�x�N�g�� DEN �ɂ́As �̍~�x�L���ɕ��ׂ�ꂽ����̌W����
% �܂܂�܂��B���q�̌W���́A�o�� y �Ɠ����̍s�������s�� NUM �ɏo�͂���
% �܂��B
%
% �Q�l�FTF2SS, ZP2TF, ZP2SS.


%   J.N. Little 4-21-85
%   Revised 7-25-90 Clay M. Thompson, 10-11-90 A.Grace
%   Copyright 1984-2003 The MathWorks, Inc. 