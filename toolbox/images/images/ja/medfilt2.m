% MEDFILT2   2�����̃��f�B�A���t�B���^�����O
%
% B = MEDFILT2(A,[M N]) �́A�s�� A ��2�����̃��f�B�A���t�B���^�����O
% �����s���܂��B�e�o�̓s�N�Z���ɂ́A���̓C���[�W�̑Ή�����s�N�Z����
% �͂� M �s N ��̋ߖT�̒����l��ݒ肵�܂��BMEDFILT2 �́A�G�b�W�̏�
% ��0��t������̂ŁA�G�b�W��[M N]/2�͈͓��̓_�ɑ΂��钆���l�͘c���
% �݂���\��������܂��B
%
% B = MEDFILT2(A) �́A�f�t�H���g��3�s3��̋ߖT���g���āA�s�� A �Ƀ�
% �f�B�A���t�B���^�����O���s���܂��B
%
% B = MEDFILT2(...,PADOPT) �́A�ǂ̂悤�ɍs��̋��E��t�����邩�𐧌�
% ���܂��BPADOPT �ɂ́A'zeros'(�f�t�H���g),'symmetric'�A�܂��́A
% 'indexed' ��ݒ�ł��܂��BPADOPT �� 'zeros' �̏ꍇ�AA �̋��E�ɂ�0
% ���t������܂��BPADOPT �� 'symmetric' �̏ꍇ�AA �̋��E�őΏ̓I�Ɋg��
% ����܂��BPADOPT �� 'indexed' �ŁA���AA �� double �̏ꍇ�A1���t��
% ����܂��Bdouble �ȊO�̏ꍇ�A0���t������܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W A �́Auint8�Auint16�A�܂��́Adouble �� logical �ł��B
% ('indexed' �\�����g���Ȃ��ꍇ�́AA �̓N���X uint16 ���T�|�[�g����
% ����)�B�o�̓C���[�W B �́AA �Ɠ����N���X�ł��B
%
% ����
% ----
% ���̓C���[�W A �������N���X�̏ꍇ�A�o�͒l�͂��ׂĐ����Ƃ��ĕԂ����
% ���B�ߖT���̃s�N�Z�����A���Ƃ��΁A(M*N)�������̏ꍇ�A�����l��������
% �Ȃ�Ȃ��\��������܂��B���̏ꍇ�A�����ȉ����؂�̂Ă��܂��B�_��
% �z������l�ɏ�������܂��B
%
% ���
% ----
%       I = imread('eight.tif');
%       J = imnoise(I,'salt & pepper',0.02);
%       K = medfilt2(J);
%       imshow(J), figure, imshow(K)
%
% �Q�l�FFILTER2, ORDFILT2, WIENER2



%   Copyright 1993-2002 The MathWorks, Inc.  
