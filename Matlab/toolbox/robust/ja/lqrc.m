% LQRC �́A�A���œK LQR ����n�̃V���Z�V�X���s���܂��B
%
% [K,P,P1,P2] = LQRC(A,B,QRN,ARETYPE)  �́A�S������ dx/dt = Ax + Bu �̊�ŁA
% Riccati �������������A�R�X�g�֐�
%
%       J = 1/2 Integral { [x' u'] | Q  N | |x| } dt ; ( QRN := |Q  N| )
%                                  | N' R | |u|        (        |N' R| )
% 
% ���ŏ��ɂ���t�B�[�h�o�b�N�� u = -Kx �𖞂����œK LQR �t�B�[�h�o�b�N�Q�C
% �� K �����߂܂��B
% 
% �o�͂���� P �́AARE
%                                     -1
%		0 = A'P + PA - (PB+N)R  (B'P+N') + Q
%
% �𖞑���������ɂȂ�܂��B�����āAARE �̎c�����v�Z�ł��܂��B�c�����傫
% ���Ȃ�悤�ȏ����̈�������Ajw ���ɋ߂����[�v�ɂ����݂���ꍇ�A���[
% �j���O���b�Z�[�W���\������܂��B
%
%          aretype = 'eigen' ---- �ŗL�\���A�v���[�`���g���� Riccati ����
%                                 ��(�f�t�H���g)
%          aretype = 'schur' ---- Schur�x�N�g���A�v���[�`���g���� Riccati 
%                                 ������
%

% Copyright 1988-2002 The MathWorks, Inc. 
