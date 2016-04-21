% INTERPSTREAMSPEED  �X�s�[�h�̊ϓ_����X�g���[�����C���̒��_����}
% 
% INTERPSTREAMSPEED(X,Y,Z,U,V,W,VERTICES) �́A�x�N�g���f�[�^ U, V, W ��
% �X�s�[�h����ɁA�X�g���[�����C���̒��_����}���܂��B�z�� X, Y, Z �́A
% U, V, W �ɑ΂�����W�n���`���A(�֐� MESHGRID �ō쐬����)�P���ŁA
% 3�����i�q�łȂ���΂Ȃ�܂���B   
% 
% INTERPSTREAMSPEED(U,V,W,VERTICES) �́A���̃X�e�[�g�����g�����肵��
% ���܂��B
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(U) �ł��B
% 
% INTERPSTREAMSPEED(X,Y,Z,SPEED,VERTICES) �́A�x�N�g����̃X�s�[�h��
% 3�����z�� SPEED ���g���܂��B
% 
% INTERPSTREAMSPEED(SPEED,VERTICES) �́A���̃X�e�[�g�����g�����肵
% �Ă��܂��B
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(SPEED) �ł��B
% 
% INTERPSTREAMSPEED(X,Y,U,V,VERTICES) �́A�x�N�g���f�[�^ U, V �̃X�s�[�h
% ����ɃX�g���[�����C���̒��_����}���܂��B�z�� X, Y �́AU, V �̍��W��
% ��`���A(�֐� MESHGRID �ō쐬����悤��)�P���ŁA2�����i�q�łȂ����
% �Ȃ�܂���B
% 
% INTERPSTREAMSPEED(U,V,VERTICES)  �́A���̃X�e�[�g�����g�����肵��
% ���܂��B
% 
%   [X Y] = meshgrid(1:N, 1:M) 
% 
% �����ŁA[M,N] = SIZE(U) �ł��B
% 
% INTERPSTREAMSPEED(X,Y,SPEED,VERTICES) �́A�x�N�g����̃X�s�[�h�ɁA
% 2�����z�� SPEED ���g���܂��B
% 
% INTERPSTREAMSPEED(SPEED,VERTICES)  �́A���̃X�e�[�g�����g�����肵
% �Ă��܂��B
% 
%   [X Y] = meshgrid(1:N, 1:M) 
% 
% �����ŁA[M,N] = SIZE(SPEED) �ł��B
% 
% INTERPSTREAMSPEED(...SF) �́A�x�N�g���f�[�^�̃X�s�[�h�� SF ���g����
% �X�P�[�����O���܂��B���̂��߁A���}���ꂽ���_�̐����R���g���[�����܂��B
% ���Ƃ��΁ASF ��3�Ƃ���ƁA���_��1/3�ɂȂ�܂��B
% 
% VERTSOUT = INTERPSTREAMSPEED(...) �́A���_�̔z��̃Z���z����o�͂��܂��B
% 
% ��� 1�F
%        load wind
%        [sx sy sz] = meshgrid(80, 20:1:55, 5);
%        verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%        iverts = interpstreamspeed(x,y,z,u,v,w,verts,.2);
%        sl = streamline(iverts);
%        set(sl, 'marker', '.');
%        axis tight; view(2); daspect([1 1 1])
% 
% ��� 2�F
%        z = membrane(6,30);
%        [u v] = gradient(z);
%        [verts averts] = streamslice(u,v);
%        iverts = interpstreamspeed(u,v,verts,15);
%        sl = streamline(iverts);
%        set(sl, 'marker', '.');
%        hold on; pcolor(z); shading interp
%        axis tight; view(2); daspect([1 1 1])
% 
% �Q�l�FSTEAMPARTICLES, STREAMSLICE, STREAMLINE, STREAM3,
%       STREAM2. 


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:05:17 $
