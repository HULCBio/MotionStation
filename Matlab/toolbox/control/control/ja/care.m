% CARE   �A�����Ԃ̑㐔Riccati�������������܂��B
%
%
% [X,L,G,RR] = CARE(A,B,Q,R,S,E) �́A�A�����ԑ㐔Riccati�������̃��j�[�N��
% �Ώ̂Ȉ��艻��x�����߂܂��B 
%                                -1
%       A'XE + E'XA - (E'XB + S)R  (B'XE + S') + Q = 0 
%
% R, S, E �́A�ȗ������ƁA�f�t�H���g�l R = I, S = 0, E = I ���ݒ肳��܂��B
% �� X �̑��ɁACARE  �́A�Q�C���s��@
%                -1
%           G = R  (B'XE + S')
% �ƕ��[�v�ŗL�l�̃x�N�g�� L�@(���Ȃ킿�AEIG(A-B*G,E)) ���o�͂��܂��B
%
% [X,L,G,REPORT] = CARE(...) �́A���̒l�����f�f REPORT ���o�͂��܂��B
%    * Hamiltonian �s�񂪋����ɔ��ɋ߂��ŗL�l�����ꍇ�A-1
%    * �L���̈��艻�� X  �����݂��Ȃ��ꍇ�A-2
%    * X �����݂��L���̏ꍇ�A���Ύc���̃t���x�j�E�X�m�����B
% ���̍\���́AX �����݂��Ȃ��ꍇ�A�G���[���b�Z�[�W���o�͂��܂���B
%
% [X1,X2,D,L] = CARE(A,B,Q,...,'factor') �́A2�̍s�� X1, X2 �ƁA
% X = D*(X2/X1)*D �̑Ίp�^�X�P�[�����O�s�� D ���o�͂��܂��B�x�N�g�� L �́A
% ���[�v�ŗL�l���܂݂܂��B���ׂĂ̏o�͂́A�֘A���� Hamiltonian �s��
% ������ɌŗL�l�����ꍇ�A��ł��B
%
% [...] = CARE(A,B,Q,...,'nobalance') �́A�f�[�^�̃I�[�g�X�P�[�����O�@�\��
% �����ɂ��܂��B
%
% �Q�l : DARE.


% Copyright 1986-2002 The MathWorks, Inc.
