% CHOL   Cholesky����
% 
% CHOL(X) �́AX �̑Ίp�����Ə�O�p�����݂̂��g���܂��B���O�p�����́A
% ��O�p������(���f����)�]�u�ƍl�����܂��BX ������s��̂Ƃ��A
% R = CHOL(X) �� R'*R = X �ƂȂ��O�p�s�� R ���쐬���܂��BX ������s��
% �łȂ���΁A�G���[���b�Z�[�W���\������܂��B
%
% [R,p] = CHOL(X) �́A2�̏o�͈������g���āA�G���[���b�Z�[�W��\��
% ���܂���BX ������s��̏ꍇ�́Ap ��0�ŁAR �͏�L�Ɠ����ł��BX ��
% ����s��łȂ���΁Ap �͐��̐����ɂȂ�܂��B
% X ���t���̏ꍇ�́AR �� R'*R = X(1:q,1:q) �ƂȂ鎟�� q = p-1 �̏�O�p�s
% ��ł��BX ���X�p�[�X�̏ꍇ�́AR �� R'*R �̍ŏ��� q �s�� q ���L�^�̈�
% �� X �̂����ƈ�v����A�T�C�Y�� q �s n ��̏�O�p�s��ł��B
%
% �Q�l�FCHOLINC, CHOLUPDATE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:40 $
%   Built-in function.
