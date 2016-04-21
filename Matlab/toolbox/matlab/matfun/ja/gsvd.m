% GSVD   ��ʉ����ْl����
% 
% [U,V,X,C,S] = GSVD(A,B) �́A���̂悤�Ȋ֌W�ł��郆�j�^���s�� U �����
% V�A(�ʏ�)�����s�� X�A�񕉑Ίp�s�� C ����� S ���o�͂��܂��B
%
%     A = U*C*X'
%     B = V*S*X'
%     C'*C + S'*S = I 
%
% A �� B �́A�����񐔂łȂ���΂Ȃ�܂��񂪁A�s���͈قȂ��Ă��\���܂���B
% A ��m�sp��ŁAB ��n�sp��̏ꍇ�́Aq = min(m+n,p) �̂Ƃ��� U��m�sm��
% �ŁAV ��n�sn��ŁAX ��p�sq��ł��B
%
% SIGMA = GSVD(A,B) �́A��ʉ����ْl sqrt(diag(C'*C)./diag(S'*S)) �̃x�N�g
% �����o�͂��܂��B
%
% S �̔�[���v�f�́A��Ɏ�Ίp��ɂ���܂��Bm > =  p �̏ꍇ�́AC �̔�[
% ���v�f����Ίp��ɂ���܂��B�������Am < p �̏ꍇ�́AC �̔�[���Ίp�́A
% diag(C,p-m) �ł��B����ɂ���āA ��ʉ����ْl���~���łȂ��悤�ɑΊp�v�f
% �����ׂ��܂��B
% 
% GSVD(A,B,0) �́A3�̓��͈����������Am > =  p �܂��� n > =  p �̂Ƃ��A
% ���ʂ� U �� V �����Xp��ŁAC �� S �����Xp�s�ł���悤�ȁA���������������
% �����������s���܂��B��ʉ����ْl�́Adiag(C)./diag(S) �ł��B
% 
% I = eye(size(A)) �̂Ƃ��A��ʉ����ْl gsvd(A,I) �͒ʏ�̓��ْl svd(A) ��
% �����ł����A�t�̏��ԂŃ\�[�g����܂��B�t�ɕ��ׂ����̂��Agsvd(I,A) �ł��B
%
% ���� GSVD �̎��ł́AA �܂��� B �̌X�̃����N�Ɋւ��鉼��͍s���܂�
% ��B�s�� X �́A�s�� [A; B] ���t�������N�ł���ꍇ�݂̂Ƀt�������N�ł��B��
% �ۂɁAsvd(X) �� cond(X) �́Asvd([A; B]) �� cond([A; B]) �Ɠ����ł��B
% G. Golub and C. Van Loan��"Matrix Computations"�̂悤�ȑ��̎��ł́A
% null(A) �� null(B) �̓I�[�o���b�v�����AX �� inv(X) �܂��� inv(X') �ɂ���Ēu��
% ��������K�v������܂��B�������Anull(A) �� null(B) ���I�[�o���b�v����Ƃ��A
% C �� S �̔�[���v�f�͈�ӓI�ɂ͌��肳��Ȃ����Ƃɒ��ӂ��Ă��������B
%
% �Q�l�FSVD.

%   P. C. Hansen and C. B. Moler, 12/13/97.
%   Copyright 1984-2003 The MathWorks, Inc. 

