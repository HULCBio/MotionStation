% FZMULT   ��{�k����Ԃ̊���p������Z
%
% W = FZMULT(A,V) �́A�s�� Z �ƍs�� V �� W = Z*V �ƂȂ�悤�ȏ�Z W ��
% �v�Z���܂��B�����ŁAZ �́A�s�� A �̃k����Ԃɑ΂����{�I�Ȋ��ł��B
% A �́Am < n �� rank(A) = m �� rank(A(1:m,1:m)) = m �ƂȂ�Am�~n ��
% �X�p�[�X�s��łȂ���΂Ȃ�܂���BV �́Ap = n-m �ƂȂ� p�~q �̍s���
% �Ȃ���΂Ȃ�܂���BV ���X�p�[�X�̏ꍇ�AW �̓X�p�[�X�ƂȂ�A������
% �Ȃ���΁A�t���ɂȂ�܂��B
%
% W = FZMULT(A,V,'transpose') �́AW = Z'*V �ƂȂ�悤�ɁA�]�u������{
% �I�Ȋ�� V �������ď�Z���s���܂��BV �� q = n-m �ƂȂ� p�~q �łȂ����
% �Ȃ�܂���BFZMULT(A,V) �́AFZMULT(A,V,[]) �Ɠ������Ȃ�܂��B
%
% [W,L,U,pcol,P]  = FZMULT(A,V) �́AA1 = A(1:m,1:m) �ƁAP*A1(:,pcol) = L*U
% �ƂȂ�A�s�� A(1:m,1:m) �̃X�p�[�X��LU������Ԃ��܂��B
%
% W = FZMULT(A,V,TRANSPOSE,L,U,pcol,P) �́AA1 = A(1:m,1:m) �ƁA
% P*A1(:,pcol) = L*U �Ƃ��Čv�Z���ꂽ�s�� A(1:m,1:m) �̃X�p�[�X��LU����
% ���g���܂��B
%
% �k����Ԃ̊��s�� Z �́A�����I�ɂ͌`������܂���B�ԐړI�ȕ\���Ƃ���
% A(1:m,1:m) �̃X�p�[�X��LU�����Ɋ�Â������̂��g���܂��B


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/03/26 16:58:01 $
