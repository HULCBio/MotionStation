% STREAMRIBBON �́A3�����̃X�g���[�����{�����쐬���܂��B
% 
% STREAMRIBBON(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) �́A�x�N�g���f�[�^ 
% U,V,W ����X�g���[�����{����`�悵�܂��B�z�� X,Y,Z �́AU,V,W �̍��W��
% �w�肷����̂ŁA�P����(MESHGRID ���g���č쐬����)3�����̊i�q�łȂ����
% �Ȃ�܂���BSTARTX,STARTY,STARTZ �́A���{���̒��S�ŁA�X�g���[�����C����
% �o���_���`���܂��B���{���̔P����(�c�C�X�g)�́A�x�N�g�����Curl ��
% �x�����ɔ�Ⴕ�܂��B���{���̕��́A�����I�Ɍv�Z����܂��B�ʏ�ASTREAMRIBBON 
% ���R�[������O�ɁADataAspectRatio ��ݒ肷�邱�Ƃ��]�܂�܂��B
% 
% STREAMRIBBON(U,V,W,STARTX,STARTY,STARTZ) �́A���̃X�e�[�g�����g��
% ���肵�Ă��܂��B 
% 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(U)�ł��B 
% 
% STREAMRIBBON(VERTICES,X,Y,Z,CAV,SPEED) �́A�X�g���[�����C���̒��_�A
% Curl �p���x�A������O�����Čv�Z���Ă��邱�Ƃ����肵�Ă��܂��BVERTICES
% �́A(�֐� stream3 �ō쐬����)�X�g���[�����C���̒��_�̃Z���z��ł��B
% X,Y,Z,CAV,SPEED �́A3�����z��ł��B
%
% STREAMRIBBON(VERTICES,CAV,SPEED) �́A���̃X�e�[�g�����g�����肵��
% ���܂��B
% 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(CAV)�ł��B
%
% STREAMRIBBON(VERTICES,TWISTANGLE) �́A�x�N�g�� TWISTANGLE �̃Z���z��
% ���g���āA���{���̔P����(���W�A���P��)��ݒ肵�܂��BVERTICES �� 
% TWISTANGLE �̊e�Ή�����v�f�̑傫���́A�����ł���K�v������܂��B
%
% STREAMRIBBON(...,WIDTH) �́A���{���̕��� WIDTH �Őݒ肵�܂��B 
%
% STREAMRIBBON(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B  
%
% H = STREAMRIBBON(...) �́ASURFACE �I�u�W�F�N�g��(�o���_�Ɋւ���1��)
% �n���h������Ȃ�x�N�g�����o�͂��܂��B
%
% ��� 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      h = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% ��� 2:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      cav = curl(x,y,z,u,v,w);
%      spd = sqrt(u.^2 + v.^2 + w.^2);
%      h = streamribbon(verts,x,y,z,cav,spd);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% ��� 3:
%      t = 0:.15:15;
%      verts = {[cos(t)' sin(t)' (t/3)']};
%      twistangle = {cos(t)'};
%      daspect([1 1 1])
%      h = streamribbon(verts,twistangle);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% ��� 4:
%     xmin = -7; xmax = 7;
%     ymin = -7; ymax = 7; 
%     zmin = -7; zmax = 7; 
%     x = linspace(xmin,xmax,30);
%     y = linspace(ymin,ymax,20);
%     z = linspace(zmin,zmax,20);
%     [x y z] = meshgrid(x,y,z);
%     u = y; v = -x; w = 0*x+1;
%     
%     daspect([1 1 1]); 
%     [cx cy cz] = meshgrid(linspace(xmin,xmax,30),....
%           linspace(ymin,ymax,30),[-3 4]);
%     h2 = coneplot(x,y,z,u,v,w,cx,cy,cz, 'q');
%     set(h2, 'color', 'k');
%     
%     [sx sy sz] = meshgrid([-1 0 1],[-1 0 1],-6);
%     p = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%     [sx sy sz] = meshgrid([1:6],[0],-6);
%     p2 = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%     shading interp
%     
%     view(-30,10) ; axis off tight
%     camproj p; camva(66); camlookat; camdolly(0,0,.5,'f')
%     camlight
%
% �Q�l�FCURL, STREAMTUBE, STREAMLINE, STREAM3.


%   Copyright 1984-2002 The MathWorks, Inc. 
