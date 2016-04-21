% [X1,X2] = ricpen(H,L)
%       X = ricpen(H,L)
%
% �A������Riccati�������̈�ʉ�Schur�\���o�B
%
% �n�~���g�j�A���y���V��
%
%               [  A     F     S1 ]       [  E   0   0 ]
%   H - t L  =  [  G    -A'   -S2 ]  - t  [  0   E'  0 ]
%               [ S2'   S1'     R ]       [  0   0   0 ]
%
% �Ɋ֘A����Riccati�������̈��艻��X = X2/X1���v�Z���܂��B�u���b�NS1, S2
% R �́A���ׂċ�ł��B
%
% �O��:
%    * R��E�́A�t�ł��B
%    * �y���V��H - t L�́A��������ɗL���̈�ʉ��ŗL�l�������܂���B
%
% L���ȗ������ƁARICPEN�́A�n�~���g�j�A���s��H��Riccati��������������
% ��(L��R�́A�f�t�H���g�lL=I��R=[]�ɐݒ肳��܂�)�BH - t L���������ɌŗL
% �l�����Ȃ�΁AX, X1, X2�́A��ɂȂ�܂��B����ɁAX1�����ق̂Ƃ���X��
% ��ɂȂ�܂��B
%
% �Q�l�F     CARE.



% Copyright 1995-2002 The MathWorks, Inc. 
