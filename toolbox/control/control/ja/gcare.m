% GCARE  �A�����Ԃ̑㐔Riccati�������ɑ΂����ʉ����ꂽ�\���o
%
%
% [X,L,REPORT] = GCARE(H,J,NS) �́A���̌`��Hamiltonian pencil �Ɋ֘A����
% �A�����ԑ㐔Riccati�������̃��j�[�N�őΏ̂Ȉ��艻�� X �����߂܂��B
%
%                   [  A     F     S1 ]       [  E   0   0 ]
%       H - t J  =  [  G    -A'   -S2 ]  - t  [  0   E'  0 ]
%                   [ S2'   S1'     R ]       [  0   0   0 ]
%
% �I�v�V�����̓��� NS �́A�s�� A �̍s�̃T�C�Y�ł��B
% J �� NS �ɑ΂���f�t�H���g�l�́AE=I �� R=[] �ɑΉ����܂��B
%
% �I�v�V�����ŁAGCARE �́A���[�v�ŗL�l�̃x�N�g�� L �ƁA���̒l�����f�f
% REPORT ���o�͂��܂��B 
%   * Hamiltonian pencil �������ɔ��ɋ߂��ŗL�l�����ꍇ�A-1
%   * �L���̈��艻�� X  �����݂��Ȃ��ꍇ�A-2 
%   * �L���Ȉ��艻�� X �����݂���ꍇ�A0 �B 
% ���̍\���́AX �����݂��Ȃ��ꍇ�A�G���[���b�Z�[�W���o�͂��܂���B
%
% [X1,X2,D,L] = GCARE(H,...,'factor') �́A2�̍s�� X1, X2 �ƁA
% X = D*(X2/X1)*D �ł���悤�ȑΊp�̃X�P�[�����O�s��D��Ԃ��܂��B�x�N�g�� L �́A
% ���[�v�ŗL�l���܂݂܂��B�֘A���� Hamiltonian �s�񂪁A������ɌŗL�l�����ꍇ�A
% ���ׂĂ̏o�͂͋�ł��B
%
% [...] = GCARE(H,...,'nobalance') �ł́A�f�[�^�̃I�[�g�X�P�[�����O�@�\��
% �����ɂ��܂��B
%
% �Q�l : CARE, GDARE.


% Copyright 1986-2002 The MathWorks, Inc.
