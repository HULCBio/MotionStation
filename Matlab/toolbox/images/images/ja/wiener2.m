% WIENER2   2�����K���m�C�Y�����t�B���^�����O
%   WIENER2 �́A���̃p���[�������Z�I�ȃm�C�Y�ŗ򉻂��Ă��鋭�x�C
%   ���[�W�Ƀ��[�p�X�t�B���^��K�p���܂��BWIENER2 �́A�e�s�N�Z���̋Ǐ�
%   �I�ȋߖT���琄�肳��铝�v�ʂ���Ƀs�N�Z���P�ʂɍ�p����K�� 
%   Wiener �@���g���܂��B
%
%   J = WIENER2(I,[M N],NOISE) �́A�Ǐ��I�ȃC���[�W�̕��ςƕW���΍���
%   �v�Z���邽�߁AM �s N ��̃T�C�Y�̋ߖT���g���āA�s�N�Z���ɍ�p����
%   �K�� Wiener �t�B���^�ŃC���[�W I ���t�B���^�����O���܂��B[M N] ��
%   �ȗ�����ƁAM �� N �́A�f�t�H���g��3���g���܂��B���Z�I�ȃm�C�Y(�K
%   �E�X���F�m�C�Y)�̃G�l���M�[�́ANOISE �Őݒ肵�܂��B
%
%   [J,NOISE] = WIENER2(I,[M N]) �́A�t�B���^�����O�̑O�ɉ��Z�I�ȃm�C
%   �Y�̃G�l���M�[�𐄒肵�܂��BWIENER2 �́A���̐���l�� NOISE �ɏo��
%   ���܂��B
%
% �N���X�T�|�[�g
% -------------
%   ���̓C���[�W I �́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X
%   ���T�|�[�g���Ă��܂��B�o�̓C���[�W J �́AI �Ɠ����N���X�ł��B
%
% ���
% ----
%       I = imread('saturn.tif');
%       J = imnoise(I,'gaussian',0,0.005);
%       K = wiener2(J,[5 5]);
%       imshow(J), figure, imshow(K)
%
%   �Q�l�FFILTER2, MEDFILT2



%   Copyright 1993-2002 The MathWorks, Inc.  
