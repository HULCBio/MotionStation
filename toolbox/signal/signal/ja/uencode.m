% UENCODE �́A���͂� N �r�b�g�ň�l�ʎq���A���������s���܂��B
% Y = UENCODE(U,N) �́A�s�[�N�l +/- 1�œ��͒l��O�a�����Ă���z�� U �̃f
% �[�^����l�ɗʎq���╄�������܂��B�o�͂́A[0  2^N-1] �͈̔͂ɓ���܂��B
% �o�͂̃f�[�^�^�C�v�́A�K�v�ȃr�b�g���̍ŏ������x�[�X�ɂ��Č��肵��8, 
% 16, 32-�r�b�g�̕����Ȃ������ł��B
%
% Y = UENCODE(U,N,V) �́A�s�[�N�l +/- V�œ��͂�O�a���܂��B
% 
% Y = UENCODE(U,N,V,'unsigned') �́A�͈� [0  2^N-1] �ŁA�����Ȃ��������o
% �͂��܂��B
%
% Y = UENCODE(U,N,V,'signed') �́A�͈� [-2^(N-1)  2^(N-1)-1] �ŁA�����t
% ���������o�͂��܂��B
%
% �Q�l�F   UDECODE, SIGN, FIX, FLOOR, CEIL, ROUND.



%   Copyright 1988-2002 The MathWorks, Inc.
