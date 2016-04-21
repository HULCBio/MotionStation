% STREAMLINE   2�����܂���3�����x�N�g���f�[�^����X�g���[�����C�����쐬
% 
% H = STREAMLINE(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) �́A3�����x�N�g��
% �f�[�^ U,V,W ����X�g���[�����C�����쐬���܂��B�z�� X,Y,Z �́AU,V,W ��
% �΂�����W���`���A(MESHGRID �ŏo�͂����悤��)�P����3�����i�q�`��
% �Ȃ���΂Ȃ�܂���BSTARTX�ASTARTY�A����сASTARTZ �́A�X�g���[�����C��
% �̊J�n�ʒu���`���܂��B���C���̃n���h���̃x�N�g�����o�͂���܂��B
% 
% H = STREAMLINE(U,V,W,STARTX,STARTY,STARTZ) �́A[M,N,P] = SIZE(U) ��
% �Ƃ� [X Y Z] = meshgrid(1:N�A1:M�A1:P) �Ɖ��肵�܂��B
% 
% H = STREAMLINE(XYZ) �́AXYZ ��(STREAM3 �ŏo�͂����悤��)�O������
% �v�Z���ꂽ���_�̔z��̃Z���z��ł���Ɖ��肵�܂��B
% 
% H = STREAMLINE(X,Y,U,V,STARTX,STARTY) �́A2�����x�N�g���f�[�^ U,V 
% ����X�g���[�����C�����쐬���܂��B�z�� X,Y �́AU,V �ɑ΂�����W���`���A
% (MESHGRID �ŏo�͂����悤��)�P����2�����i�q�`�łȂ���΂Ȃ�܂���B
% STARTX ����� STARTY �́A�X�g���[�����C���̊J�n�ʒu���`���܂��B
% ���C���̃n���h���̃x�N�g�����o�͂���܂��B
% 
% H = STREAMLINE(U,V,STARTX,STARTY) �́A[M,N] = SIZE(U) �̂Ƃ��A
% [X Y] = meshgrid(1:N, 1:M) �Ɖ��肵�܂��B
% 
% H = STREAMLINE(XY) �́AXY ��(STREAM2 �ŏo�͂��ꂽ�悤��)�O�����Čv�Z
% ���ꂽ���_�̔z��̃Z���z��ł���Ɖ��肵�܂��B
% 
% STREAMLINE(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = STREAMLINE(...,OPTIONS) �́A�X�g���[�����C���̍쐬�Ɏg�p����I�v
% �V������ݒ肵�܂��BOPTIONS �́A�X�g���[�����C���̃X�e�b�v�T�C�Y�ƒ��_��
% �ő�����܂�1�v�f�܂���2�v�f�̃x�N�g���Ƃ��Đݒ肳��܂��BOPTIONS ��
% �w�肳��Ȃ��ƁA�f�t�H���g�̃X�e�b�v�T�C�Y��0.1(�Z����1/10)�ŁA
% �f�t�H���g�̒��_�̍ő����10000�ł��B
% OPTIONS �́A[stepsize] �܂��� [stepsize maxverts] �̂����ꂩ�ł��B
%
% H = STREAMLINE(...) �́Aline�I�u�W�F�N�g�̃n���h������Ȃ�x�N�g����
% �o�͂��܂��B
% 
% ���:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      h=streamline(x,y,z,u,v,w,sx,sy,sz);
%      set(h, 'Color', 'red');
%      view(3);
%
% �Q�l�FSTREAM3, STREAM2, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME,
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
