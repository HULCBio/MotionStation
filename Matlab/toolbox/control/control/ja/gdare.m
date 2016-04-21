% GDARE  ���U���Ԃ̑㐔Riccati�������ɑ΂����ʉ����ꂽ�\���o
%
%
% [X,L,REPORT] = GDARE(H,J,NS) �́A���̌`��Symplectic pencil �Ɋ֘A����
% ���U���ԑ㐔Riccati�������̃��j�[�N�őΏ̂Ȉ��艻�� X �����߂܂��B
%
%                     [  A   F   B  ]       [ E   0   0 ]
%         H - t J  =  [ -Q   E' -S  ]  - t  [ 0   A'  0 ]
%                     [  S'  0   R  ]       [ 0  -B'  0 ]
%
% 3�Ԗڂ̓��� NS �́A�s�� A �̍s�̃T�C�Y�ł��B
%
% �I�v�V�����ŁAGDARE �́A���[�v�ŗL�l�̃x�N�g�� L �ƁA���̒l�����f�f
% REPORT ���o�͂��܂��B 
%    * Symplectic pencil �������ɒP�ʉ~��ɌŗL�l�����ꍇ�A-1
%    * �L���̈��艻�� X �����݂��Ȃ��ꍇ�A-2 
%    * �L���Ȉ��艻�� X �����݂���ꍇ�A0 
% ���̍\���́AX �����݂��Ȃ��ꍇ�A�G���[���b�Z�[�W���o�͂��܂���B
%
% [X1,X2,D,L] = GDARE(H,J,NS,'factor') �́A2�̍s�� X1, X2 �ƁA
% X = D*(X2/X1)*D �ł���悤�ȑΊp�̃X�P�[�����O�s��D��Ԃ��܂��B�x�N�g�� L �́A
% ���[�v�ŗL�l���܂݂܂��BSymplectic pencil ���A�P�ʉ~��ɌŗL�l�����ꍇ�A
% ���ׂĂ̏o�͂͋�ł��B
%
% [...] = GDARE(H,...,'nobalance') �ł́A�f�[�^�̃I�[�g�X�P�[�����O�@�\��
% �����ɂ��܂��B
%
% �Q�l : DARE, GCARE.


% Copyright 1986-2002 The MathWorks, Inc.
