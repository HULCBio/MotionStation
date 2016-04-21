% STREAMTUBE �́A3�����̃X�g���[���`���[�u��`�悵�܂��B
% 
% STREAMTUBE(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) �́A�x�N�g���f�[�^ U,V,W
% ����X�g���[���`���[�u��`�悵�܂��B�z�� X,Y,Z �́AU,V,W �̍��W�n��
% ��`������̂ŁA�P���֐���(MESHGRID �ō쐬����)3�����i�q�\���ł���
% �K�v������܂��BSTARTX,STARTY,STARTZ �́A�`���[�u�̒��S�ŁA�X�g���[��
% ���C���̏o���_���`���܂��B�`���[�u�̕��́A�x�N�g����̐��K�����ꂽ
% Divergence �ɔ�Ⴕ�܂��B�T�[�t�F�X��\���n���h���ԍ�����Ȃ�x�N�g�����A
% (�o���_�ɕt��1��)H �ɏo�͂���܂��B�ʏ�ASTREAMTUBE ���R�[������O�ɁA
% DataAspectRatio ��ݒ肷�邱�Ƃ������߂��܂��B
% 
% STREAMTUBE(U,V,W,STARTX,STARTY,STARTZ) �́A���̃X�e�[�g�����g��
% ���肵�Ă��܂��B
% 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(U) �ł��B 
%   
% STREAMTUBE(VERTICES,X,Y,Z,DIVERGENCE) �́A�X�g���[�����C���̒��_�� 
% Divergence ��O�����Čv�Z���Ă���Ɖ��肵�܂��BVERTICES �́A�X�g���[��
% ���C�� X,Y,Z �̃Z���z��ŁADIVERGENCE �́A3�����͔z��ł��B
%
% STREAMTUBE(VERTICES,DIVERGENCE) �́A���̃X�e�[�g�����g�����肵��
% ���܂��B
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(DIVERGENCE) �ł��B  
%
% STREAMTUBE(VERTICES,WIDTH) �́A�x�N�g�� WIDTH �̃Z���z����g���āA
% �`���[�u�̕���ݒ肵�܂��BVERTICES �� WIDTH �̊e�Ή�����v�f�̑傫��
% �́A�����łȂ���΂Ȃ�܂���B
%
% STREAMTUBE(VERTICES,WIDTH) �́A�X�J�� WIDTH ���g���āA���ׂẴX�g
% ���[���`���[�u�̕������ɂ��܂��B
%
% STREAMTUBE(VERTICES) �́A�����I�ɕ���ݒ肵�܂��B
%
% STREAMTUBE(...,[SCALE N]) �́ASCALE ���g���āA�`���[�u�̕���ݒ肵�܂��B
% �f�t�H���g�́ASCALE = 1 �ł��B�X�g���[���`���[�u���o���_�܂��� Divergence
% ���g���č쐬���ꂽ�ꍇ�́ASCALE = 0 �́A�����I�ȃX�P�[�����O���s���܂���B
% N �́A�`���[�u�̎����ݒ肷��ʒu�̐��ł��B�f�t�H���g�́AN = 20�ł��B
%
% STREAMTUBE(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = STREAMTUBE(...)) �́ASURFACE �I�u�W�F�N�g��(�J�n�_���Ƃ�1��)�n���h
% ���ԍ��̃x�N�g���Ƃ��ďo�͂��܂��B
%
% ��� 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      h = streamtube(x,y,z,u,v,w,sx,sy,sz);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% ��� 2:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      div = divergence(x,y,z,u,v,w);
%      daspect([1 1 1])
%      h = streamtube(verts,x,y,z,div);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
% 
% �Q�l�FDIVERGENCE, STREAMRIBBON, STREAMLINE, STREAM3.


%   Copyright 1984-2002 The MathWorks, Inc. 
