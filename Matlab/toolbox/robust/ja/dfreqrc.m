% DFREQRC  ���U���f���g������(MIMO)
%
% [G] = DFREQRC(SS_,W,TS)�A�܂��́A
% [G] = DFREQRC(A,B,C,D,W,TS) �́A��ԋ�ԃV�X�e��
% 
%             x(k+1) = Ax(k) + Bu(k)
%             y(k) = Cx(k) + Du(k)
% 
% �ŕ\�������`�V�X�e��
%                                  -1
%     G(z) = Y(z)/U(z) = C(zI - A)   B + D
% 
% ��(���f�x�N�g�� W �ɐݒ肳�ꂽ���g��)���f���g���������܂ލs�� G ���o��
% ���܂��B
% 
% G �ɏo�͂����s��́A�e�� W �̊e�v�f���\�����g���ɑΉ����A�e�s����
% �肵������ - �o�͂̑g�ɑΉ��������̂ł��B�ŏ��� ny(ny �́AY �̃T�C�Y) 
% �s�́A�ŏ��̓��͂���̂��̂ɑΉ����܂��B���̂悤�ɂ��āAny*nu �̑傫��
% �܂œW�J���܂��B�����ŁAnu �́A�x�N�g�� U �̃T�C�Y�ł��B

% Copyright 1988-2002 The MathWorks, Inc. 
