% CURL �x�N�g�����Curl�Ɗp���x�x�N�g�����o�͂��܂��B
% 
% [CURLX, CURLY, CURLZ, CAV] = CURL(X,Y,Z,U,V,W) �́A3�����x�N�g����A
% U,V,W �̗���(�P�ʎ��Ԃ�����̃��W�A��)�ɒ�������Curl�Ɗp���x�x�N�g��
% ���v�Z���܂��B�z�� X,Y,Z �́AU,V,W �ɑ΂�����W���`���A�P���ŁA
% (MESHGRID �ō쐬����悤��)3�����i�q�łȂ���΂Ȃ�܂���B
% 
% [CURLX, CURLY, CURLZ, CAV] = CURL(U,V,W) �́A���̃X�e�[�g�����g��
% ���肵�Ă��܂��B
% 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(U) �ł��B 
%
% [CURLZ, CAV] =  CURL(X,Y,U,V) �́A2�����x�N�g���� U,V �� z �ɒ�������
% �p���x�x�N�g����Curl z �������v�Z���܂��B�z�� X,Y �́AU,V �ɑ΂�����W
% ���`���A�P���ŁA(MESHGRID �ō쐬����悤��)2�����i�q�łȂ���΂Ȃ�
% �܂���B
% 
% [CURLZ, CAV] = CURL(U,V) �́A���̃X�e�[�g�����g�����肵�Ă��܂��B
% 
%         [X Y] = meshgrid(1:N, 1:M) 
% 
% �����ŁA[M,N] = SIZE(U) �ł��B 
% 
% [CURLX, CURLY, CURLZ] = CURL(...) �܂��� [CURLX, CURLY] = CURL(...) 
% �́ACurl �݂̂��o�͂��܂��B
% 
%   CAV = CURL(...) �́Acurl �p���x�݂̂��o�͂��܂��B
%   
% ��� 1:
%      load wind
%      cav = curl(x,y,z,u,v,w);
%      slice(x,y,z,cav,[90 134],[59],[0]); shading interp
%      daspect([1 1 1])
%      camlight
%
% ��� 2:
%      load wind
%      k = 4; 
%      x = x(:,:,k); y = y(:,:,k); u = u(:,:,k); v = v(:,:,k); 
%      cav = curl(x,y,u,v);
%      pcolor(x,y,cav); shading interp
%      hold on; quiver(x,y,u,v)
%
% �Q�l�FSTREAMRIBBON, DIVERGENCE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:04:52 $
