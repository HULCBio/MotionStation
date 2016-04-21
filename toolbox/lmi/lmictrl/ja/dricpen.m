% [X1,X2] = dricpen(H,L,n)
%       X = dricpen(H,L,n)
%
% ���U����Riccati�������ɑ΂����ʉ�Schur�������߂܂��B
%
% ���̃V���v���e�B�b�N�y���V���Ɋ֘A����Riccati�������̈��艻��
% X = X2/X1���v�Z���܂��B
%
%                   [  A   F   B  ]       [ E   0   0 ]
%       H - t L  =  [ -Q   E' -S  ]  - t  [ 0   A'  0 ]
%                   [  S'  0   R  ]       [ 0  -B'  0 ]
%
% �u���b�NB, S, R�́A���ׂċ�ł��BA�̃T�C�Y�́AN(A�����قłȂ���΃I�v
% �V����)�ɂ���Đݒ肳��܂��B
%
% �O��:
% 
%    * R��E�́A�t�ł��B
%    * �y���V��H - t L�́A�P�ʉ~��ɗL���̈�ʉ��ŗL�l�������܂���B
%
% L���ȗ������ƁADRICPEN�́A�V���v���e�B�b�N�s��H��Riccati������������
% �܂�(L��R�́A�f�t�H���g�lL = I��R = []�ɐݒ肳��܂�)�B
% �o��X, X1, X2�́AH - t L���P�ʉ~��ɌŗL�l�����ꍇ�͋�ł��B����ɁA
% X�́AX1�����ق̂Ƃ��͋�ł��B
%
% �Q�l�F     DARE.



% Copyright 1995-2002 The MathWorks, Inc. 
