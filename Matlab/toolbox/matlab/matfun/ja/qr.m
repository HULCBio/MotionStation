% QR   �����O�p����
% 
% [Q,R] = QR(A) �́AA = Q*R �ƂȂ�悤�ȁAA �Ɠ��������̏�O�p�s�� R ��
% ���j�^���s�� Q ���o�͂��܂��B
%
% [Q,R,E] = QR(A) �́AA*E = Q*R �ƂȂ�悤�Ȓu���s�� E�A��O�p�s�� R�A
% ���j�^���s�� Q ���o�͂��܂��Babs(diag(R)) ���~���ɂȂ�悤�ɁA�u���s�� E 
% �̗񂪑I������܂��B
%
% [Q,R] = QR(A,0) �́A�����������̗ǂ��������s���܂��BA ���Am > n �ł���
% m�sn��̍s��̏ꍇ�́AQ �̍ŏ���n��݂̂��v�Z����܂��B
%
% [Q,R,E] = QR(A,0) �́AQ*R = A(:,E) �ƂȂ�悤�ȁAE ��u���x�N�g���Ƃ���
% �����������̗ǂ��������s���܂��Babs(diag(R)) ���~���ɂȂ�悤�ɁA�u���s��
% E �̗񂪑I������܂��B
%
% QR(A) ���g�ł́ALAPACK��DGEDRF�܂���ZGEQRF���[�`���̌��ʂ��o�͂��܂��B
% TRIU(QR(A))�́AR �ɂȂ�܂��B
%
% �X�p�[�X�s��ɑ΂��āAQR��"Q-less QR����"���s�����Ƃ��ł��A���̌��
% �����́A�킸���ɈقȂ�܂��B
%
% R = QR(A) �́AR �݂̂��o�͂��܂��BR = chol(A'*A) �ł��邱�Ƃɒ��ӂ���
% ���������B
% [Q,R] = QR(A) �́AQ �� R �̗������o�͂��܂����AQ �̓t���ɋ߂����Ƃ�
% ����܂��B
% [C,R] = QR(A,B) �́AB �� A �Ɠ����s���̂Ƃ��AC = Q'*B ���o�͂��܂��B
% R = QR(A,0) �� [C,R] = QR(A,B,0) �́A�����������̗ǂ����ʂ��o�͂��܂��B
%
% QR �̃X�p�[�X�ȃo�[�W�����́A��̒u�����s���܂���B
% QR �̃t���o�[�W�����́AC ���o�͂��܂���B
%
% A*x = b �̍ŏ����ߎ����́AQ-less QR�������g���A1�̃X�e�b�v���J��
% �Ԃ����ǂ��ċ��߂邱�Ƃ��ł��܂��B
%
%       x = R\(R'\(A'*b))
%       r = b - A*x
%       e = R\(R'\(A'*r))
%       x = x + e;
%
% �Q�l�FLU, NULL, ORTH, QRDELETE, QRINSERT, QRUPDATE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:00:09 $
%   Built-in function.
