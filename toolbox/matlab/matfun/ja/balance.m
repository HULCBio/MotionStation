% BALANCE   �ŗL�l�̐��x�̉��ǂ̂��߂̑Ίp�X�P�[�����O
% 
% [T,B] = BALANCE(A) �́AB = T\A*T �̍s�Ɨ�̃m�������ł�����蓙����
% ����悤�ȑ����ϊ��s�� T �����߂܂��BT �́A���t���ɂ���Ċۂߌ덷����
% �荞�܂Ȃ��悤�ȁA�Ίp�v�f��2�̐����x�L��ł���Ίp�s���u����������
% �ł��B
%
% B = BALANCE(A) �́A���t�����ꂽ�s�� B ���o�͂��܂��B
%
% [S,P,B] = BALANCE(A) �́A�X�P�[�����O�x�N�g�� S �� ���בւ��̃x�N�g�� P 
% ��ʂɏo�͂��܂��B�ϊ��s�� T �� ���t���s�� B �́A�����ɂ��AA,S,P ����
% �����܂��B
%      T(:,P) = diag(S),    B(P,P) = diag(1./S)*A*diag(S).
%   
% A ���s�Ɨ�� ���בւ����ɃX�P�[�����邽�߂ɂ́A�V���^�b�N�X
% BALANCE(A,'noperm') ���g�p���Ă��������B
%
% �Q�l EIG.

%   Copyright 1984-2002 The MathWorks, Inc. 
