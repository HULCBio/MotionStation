% STREAM3   3�����X�g���[�����C��
% 
% XYZ = STREAM3(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) �́A�x�N�g���f�[�^
% U,V,W ����X�g���[�����C�����v�Z���܂��B�z�� X,Y,Z �́AU,V,W �ɑ΂���
% ���W���`���A(MESHGRID �ŏo�͂����悤��)�P����3�����i�q�`�łȂ����
% �Ȃ�܂���BSTARTX�ASTARTY ����� STARTZ �́A�X�g���[�����C���̊J�n
% �ʒu���`���܂��B���_�̔z��̃Z���z��́AXYZ �ɏo�͂���܂��B  
% 
% XYZ = STREAM3(U,V,W,STARTX,STARTY,STARTZ) �́A[M,N,P] = SIZE(U) ��
% �Ƃ� [X Y Z] = meshgrid(1:N�A1:M�A1:P) �Ɖ��肵�܂��B
% 
% XYZ = STREAM3(...,OPTIONS) �́A�X�g���[�����C���̍쐬�Ŏg�p�����
% �I�v�V������ݒ肵�܂��BOPTIONS �́A�X�g���[�����C���̃X�e�b�v�T�C�Y��
% ���_�̍ő�����܂�1�v�f�܂���2�v�f�x�N�g���Ƃ��Ďw�肳��܂��BOPTIONS 
% ���w�肳��Ȃ��ƁA�f�t�H���g�̃X�e�b�v�T�C�Y��0.1(�Z����1/10)�ŁA
% �f�t�H���g�̒��_�̍ő����10000�ł��BOPTIONS �́A[stepsize] �܂���
% [stepsize maxverts] �̂����ꂩ�ł��B
% 
% ���:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      streamline(stream3(x,y,z,u,v,w,sx,sy,sz));
%      view(3);
%
% �Q�l�FSTREAMLINE, STREAM2, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME, 
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:21 $
