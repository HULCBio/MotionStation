% STCOL   �_�݂���ϊ��I�_�s��
%
% COLMAT = STCOL(CENTERS, X, TYPE) �́Apsi_j �� n ���ASTMAK �ŋL�q�����
% ����悤�ɁACENTERS �ƕ����� TYPE �Ɉˑ�����A(i,j) �̗v�f��
%
%      psi_j( X(:,i) ),   i=1:size(X,2),  j=1:n ,
%
% �ƂȂ�s����o�͂��܂��B
%
% CENTERS �� X �́A�����s�������s��łȂ���΂Ȃ�܂���B
%
% TYPE �̃f�t�H���g�� 'tp' �ŁA���̃f�t�H���g�ɑ΂��āAn �� size(CENTERS,2) 
% �ŁA�֐� psi_j �́A���̂悤�ɗ^�����Ă��܂��B
%
%      psi_j(x) := psi( x - CENTERS(:,j) ),   j=1:n,
%
% �����ŁApsi �́Athin-plate�X�v���C�����֐��ł���A
%
%      psi(x) := |x|^2 log |x|^2 
%
% �ł��B�������A|x| �́A�x�N�g�� x �̃��[�N���b�h(Euclidean)�m������
% �����Ă��܂��B
%
% COLMAT = STCOL(..., 'tr') �́ASTCOL(...) �̓]�u���o�͂��܂��B
%
% �s�� COLMAT �́A���`�V�X�e��
%
%      sum_j a_j psi_j(X(:,i))  =  y_i,    i=1:size(X,2)
% 
% �̌W���s��ł��B�֐� f := sum_j a_j psi_j ���A���ׂĂ� i �ɂ���
% �T�C�g X(:,i) �Œl _i ���Ԃ���ɂ́Af �̌W�� a_j �����̎��𖞑�����
% ���Ȃ���΂Ȃ�܂���B
%
% ���
%      a = [0,2/3*pi,4/3*pi]; centers = [cos(a), 0; sin(a), 0];
%      [x1,x2] = ndgrid(linspace(-2,2,45)); 
%      xx = [x1(:) x2(:)].';
%      coefs = [1 1 1 -3.5];
%      y = reshape( coefs*stcol(centers,xx,'tr'), size(x1));
%      surf(x1,x2,y), view([240,15]), axis off
%   �́Athin-plate�X�v���C�����֐���4�̓_�݂���ϊ� 
%   psi(x-centers(:,j))�Cj=1:4, �̏d�ݕt���̘a��]�����A�v���b�g���܂��B
%
% �Q�l : STMAK, STBRK, STVAL, SPCOL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
