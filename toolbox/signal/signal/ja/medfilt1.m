% MEDFILT1  1�������f�B�A���t�B���^�����O
%
% Y = MEDFILT1(X,N)�́A���� N ��1�������f�B�A���t�B���^���x�N�g�� X �ɓK
% �p���܂��BY �́AX �Ɠ��������ł��B���̊֐��́A�x�N�g�� X �͈̔͊O�ł�0
% �Ɖ��肵�܂��BX ���s��̏ꍇ�AMEDFILT1�́AX �̗�ɏ]���ē��삵�܂��B
%
% N����̏ꍇ�AY(k) �́AX( k-(N-1)/2 : k+(N-1)/2) �̒����l�ɂȂ�܂��B
% N�������̏ꍇ�AY(k) �́AX( k-N/2 : k+N/2-1) �̒����l�ɂȂ�܂��B
%
% N ���w�肵�Ȃ��ꍇ�A�f�t�H���g�� N = 3 �ɐݒ肳��܂��B
%
% MEDFILT1(X,N,BLKSZ) �́Afor ���[�v���g���āA������ BLKSZ ("�u���b�N�T
% �C�Y")�̏o�̓T���v�����v�Z���܂��BMEDFILT1�́AN�sBLKSZ ��̍�Ɨp�s
% ����g�p���邽�߁A�v�Z�@�̃����������Ȃ��ꍇ�ɂ́ABLKSZ << LENGTH(X)��
% �g�p���Ă��������B�f�t�H���g�ł́ABLKSZ ==  LENGTH(X)�ł��B����́A��
% �������\���ɂ���ꍇ�Ɏ��s���Ԃ��ł������Ȃ�ݒ�ł��B
%
% N�����̍s��̏ꍇ�AY = MEDFILT1(X,N,[],DIM)�A���邢�́AY = MEDFILT(X,N,
% BLKSZ,DIM)�́A����DIM�ɏ]���ē��삵�܂��B
%
% �Q�l�F   MEDIAN, FILTER, SGOLAYFILT, MEDFILT2(Image Processing Toolbox
%          �̊֐�)



%   Copyright 1988-2002 The MathWorks, Inc.
