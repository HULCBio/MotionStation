% STREAM2   2�����X�g���[�����C��
% 
% XY = STREAM2(X,Y,U,V,STARTX,STARTY) �́A�x�N�g���f�[�^ U,V ����X�g
% ���[�����C�����v�Z���܂��B�z�� X,Y �́AU,V �ɑ΂�����W���`���A
% (MESHGRID �ŏo�͂����悤��)�P����2�����i�q�`�łȂ���΂Ȃ�܂���B
% STARTX ����� STARTY �́A�X�g���[�����C���̊J�n�ʒu���`���܂��B���_
% �z��̃Z���z��́AXY �ɏo�͂���܂��B
% 
% XY = STREAM2(U,V,STARTX,STARTY )�́A[M,N] = SIZE(U) �̂Ƃ��A
% [X Y]  = meshgrid(1:N,1:M) �Ɖ��肵�܂��B  
%
% XY = STREAM2(...,OPTIONS) �́A�X�g���[�����C���̍쐬�Ŏg�p�����I�v
% �V������ݒ肵�܂��BOPTIONS �́A�X�g���[�����C���̃X�e�b�v�T�C�Y�ƒ��_
% �̍ő�����܂�1�v�f�܂���2�v�f�x�N�g���Ƃ��Ďw�肳��܂��BOPTIONS ��
% �w�肳��Ȃ��ƁA�f�t�H���g�̃X�e�b�v�T�C�Y��0.1(�Z����1/10)�ŁA�f�t�H��
% �g�̒��_�̍ő����10000�ł��BOPTIONS �́A[stepsize] �܂���
% [stepsize maxverts] �̂����ꂩ�ł��B
% 
% ���:
%      load wind
%      [sx sy] = meshgrid(80, 20:10:50);
%      streamline(stream2(x(:,:,5),y(:,:,5),u(:,:,5),v(:,:,5),sx,sy));
%
% �Q�l�FSTREAMLINE, STREAM3, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME, 
%       REDUCEVOLUME. 


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:20 $
