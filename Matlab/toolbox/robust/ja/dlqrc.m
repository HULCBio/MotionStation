% DLQRC �́A���U�œK LQR ����n�̃V���Z�V�X���s���܂��B
%
% [K,P,PERR] = DLQRC(A,B,QRN,ARETYPE) �́A�S������ x(k+1) = A(k)x(k) + 
% B(k)u(k) �̊�ŁA���U�� Riccati �������������A���ԊԊu [i,n]�ŁA�R�X�g
% �֐�
%             n-1
%  J(i) = 1/2 SUM { [x(k)' u(k)'] | Q  N | |x(k)| }; ( QRN := |Q  N| )
%             k=i                 | N' R | |u(k)|    (        |N' R| )
%
% ���ŏ��ɂ���t�B�[�h�o�b�N�� u = -Kx �𖞂������U�œK LQR �t�B�[�h�o�b
% �N�Q�C�� K �����߂܂��B
% 
% �o�͂���� P �́A���U�� ARE 
%				           -1
%		0 = A'PA - P - A'PB(R+B'PB)  B'P'A + Q
%
% �𖞑���������ɂȂ�܂��B�����āAARE �̎c�����v�Z�ł��܂��B�c������
% �����Ȃ�悤�ȏ����̈�������A1�ɋ߂����[�v�ɂ����݂���ꍇ�A���[
% �j���O���b�Z�[�W���\������܂��B
%
%          aretype = 'eigen' ---- �ŗL�\���A�v���[�`���g���� Riccati ��
%                                 ����(�f�t�H���g)
%          aretype = 'schur' ---- Schur�x�N�g���A�v���[�`���g���� Ricc-
%                                 ati ������
%

% Copyright 1988-2002 The MathWorks, Inc. 
