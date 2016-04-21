% CONEPLOT   3�����~���v���b�g
% 
% CONEPLOT(X,Y,Z,U,V,W,Cx,Cy,Cz) �́AU,V,W �Œ�`���ꂽ�x�N�g���t�B�[���h
% ���̓_ (Cx,Cy,Cz) �ŁA���x�x�N�g�����~���`�Ƃ��ăv���b�g���܂��B�z�� 
% X,Y,Z �́AU,V,W �ɑ΂�����W���`���A(MESHGRID �ŏo�͂����悤��)
% �P����3�����i�q�`�łȂ���΂Ȃ�܂���BCONEPLOT �́A�~���`����ʂ�
% �����悤�Ɏ����I�ɃX�P�[�����O���܂��BCONEPLOT ���Ăяo���O�ɁA
% DataAspectRatio ��ݒ肷��̂��A�ʏ�ł��ǂ����ʂ𓾂܂��B
% 
% CONEPLOT(U,V,W,Cx,Cy,Cz) �́A[M,N,P] = SIZE(U) �̂Ƃ��A
% [X Y Z] = meshgrid(1:N,1:M,1:P) �Ɖ��肵�܂��B
% 
% CONEPLOT(...,S) �́A��ʂɍ����悤�Ɏ����I�ɉ~���`���X�P�[�����O���A
% ���̌��ʂ� S �����L�΂��܂��B�����X�P�[�����O���s�킸�ɉ~���`���v���b�g
% ����ɂ́AS = 0 ���g�p���Ă��������B
% 
% CONEPLOT(...,COLOR) �́A�z�� COLOR ���g���āA�~���ɐF�t�����܂��B
% COLOR��3�����z��ŁAU �Ɠ����T�C�Y�ł��B���̃I�v�V�����́A�~���Ƌ���
% �@�\���A�x�N�g�����������Ƃ͋@�\���܂���B
% 
% CONEPLOT(...,'quiver') �́A�~���`�̑���ɖ���`�悵�܂�(QUIVER3 ��
% �Q��)�B
%
% CONEPLOT(...,'method') �́A�g�p�����Ԗ@��ݒ肵�܂��B'method' �́A
% 'linear'�A'cubic'�A'nearest' �̂����ꂩ�ł��B'linear' �̓f�t�H���g�ł�
% (INTERP3 ���Q��)�B
% 
% CONEPLOT(X,Y,Z,U,V,W, 'nointerp') �́A�~���̈ʒu�𕨑̓��ɓ��}���܂���B
% �~���́AX, Y, Z �Œ�`�����ʒu�ɕ`�悳��AU, V, W �ɏ]����������
% �����Ă��܂��B�z�� X, Y, Z, U, V, W �́A�����T�C�Y�łȂ���΂Ȃ�܂���B
% 
% CONEPLOT(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = CONEPLOT(...) �́APATCH �̃n���h�����o�͂��܂��B
% 
% ���:
%      load wind
%      vel = sqrt(u.*u + v.*v + w.*w);
%      p = patch(isosurface(x,y,z,vel, 40));
%      isonormals(x,y,z,vel, p)
%      set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
%
%      daspect([1 1 1]);   % coneplot�́A�n�߂� DataAspectRatio ��ݒ肵��
%                          % �����ƁA�ǂ����ʂ������܂��B
%      [f verts] = reducepatch(isosurface(x,y,z,vel, 30), .2); 
%      h=coneplot(x,y,z,u,v,w,verts(:,1),verts(:,2),verts(:,3),2);
%      set(h, 'FaceColor', 'blue', 'EdgeColor', 'none');
%      [cx cy cz] = meshgrid(linspace(71,134,10),
%      linspace(18,59,10),3:4:15);
%      h2=coneplot(x,y,z,u,v,w,cx,cy,cz,v,2); 
%      set(h2, 'EdgeColor', 'none');
%
%      axis tight; box on
%      camproj p; camva(24); campos([185 2 102])
%      camlight left; lighting phong
%
% �Q�l�FSTREAMLINE, STREAM3, STREAM2, ISOSURFACE, SMOOTH3, SUBVOLUME,
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
