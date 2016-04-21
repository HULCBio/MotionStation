% DIVERGENCE �́A�x�N�g����� Divergence ���v�Z���܂��B
% 
% DIV = DIVERGENCE(X,Y,Z,U,V,W) �́A3�����x�N�g���� U,V,W �� Divergence 
% ���v�Z���܂��B�z�� X,Y,Z �́AU,V,W �ɑ΂�����W���`���A�P���ŁA
% (MESHGRID �ō쐬����悤��)3�����i�q�łȂ���΂Ȃ�܂���B
% 
% DIV = DIVERGENCE(U,V,W) �́A���̃X�e�[�g�����g�����肵�Ă��܂��B
% 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N] = SIZE(U) �ł��B 
%
% DIV = DIVERGENCE(X,Y,U,V) �́A2�����̃x�N�g����AU,V �� Divergence ��
% �v�Z���܂��B�z�� X,Y �́AU,V �ɑ΂�����W���`���A�P���ŁA(MESHGRID 
% �ō쐬����悤��)2�����i�q�łȂ���΂Ȃ�܂���B
% 
% DIV = DIVERGENCE(U,V) �́A���̃X�e�[�g�����g�����肵�Ă��܂��B
% 
%         [X Y] = meshgrid(1:N, 1:M) 
% 
% �����ŁA[M,N,P] = SIZE(U) �ł��B 
% 
% ��� :
%      load wind
%      div = divergence(x,y,z,u,v,w);
%      slice(x,y,z,div,[90 134],[59],[0]); shading interp
%      daspect([1 1 1])
%      camlight
%
% �Q�l�FSTREAMTUBE, CURL, ISOSURFACE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:04:54 $
