% DARE   ���U���ԑ㐔Riccati �������������܂�
%
%
% [X,L,G,RR] = DARE(A,B,Q,R,S,E) �́A���U���ԑ㐔Riccati �������̃��j�[�N�ő�
% �̂Ȉ��艻�� X �����߂܂��B
%                                         -1 
%      E'XE = A'XA - (A'XB + S)(B'XB + R)  (A'XB + S)' + Q 
%
% �܂��́A(R ���A�����̏ꍇ)
%                                   -1             -1                 -1
%      E'XE = F'XF - F'XB(B'XB + R)  B'XF + Q - SR  S'  with  F:=A-BR  S'
%
% R, S, E �́A�ȗ������ƁA�f�t�H���g�l R = I, S = 0, E = I ���ݒ肳��܂��B
% �� X �̑��ɁA CARE �́A�Q�C���s�� 
%                         -1
%           G = (B'XB + R)  (B'XA + S'),
% �ƕ��[�v�̌ŗL�l�x�N�g�� L�@(���Ȃ킿�AEIG(A-B*G,E)) ���o�͂��܂��B
%
% [X,L,G,REPORT] = DARE(...) �́A���̒l�����f�f REPORT ���o�͂��܂��B
%   * �s�񂪋����ɔ��ɋ߂��ŗL�l�����ꍇ�A-1 
%   * �L�E�Ȉ��艻�� X �����݂��Ȃ��ꍇ�A-2 
%   *  X �����݂��ėL�E�ȏꍇ�A���Ύc����Frobenius �m�����B
% ���̍\���́A X �����݂��Ȃ��ꍇ�A�G���[���b�Z�[�W��\�����܂���B
%
% [X1,X2,D,L] = DARE(A,B,Q,...,'factor') �́A2�̍s�� X1, X2 �ƁA
% X = D*(X2/X1)*D �ł���悤�ȑΊp�̃X�P�[�����O�s��D��Ԃ��܂��B
% �x�N�g�� L �́A���[�v�ŗL�l���܂݂܂��B�֘A���� Hamiltonian �s�񂪁A
% ������ɌŗL�l�����ꍇ�A���ׂĂ̏o�͂͋�ł��B
%
% �Q�l : CARE.


% Copyright 1986-2002 The MathWorks, Inc.
