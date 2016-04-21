% LPC  ���`�\���W��
%
% A = LPC(X,N)�́A�덷(err(n) = X(n) - Xp(n))�̓����ŏ������� N ���̑O
% �������`�\���q�W�� A = [ 1 A(2) ... A(N+1) ]���o�͂��܂��BX�̓x�N�g��
% �ł��s��ł��\���܂���B
%
%   Xp(n) = -A(2)*X(n-1) - A(3)*X(n-2) - ... - A(N+1)*X(n-N)
%
% X���A��P�ʂɎ�X�̈قȂ�M�����܂񂾍s��̏ꍇ�ALPC�͊e��̃��f������
% �l��A�̊e�s�ɏo�͂��܂��BN �́A������ A(z) �̎����ł��B
%
% N ��ݒ肵�Ȃ��ƁALPC �́A�f�t�H���g�Ƃ��āAN = length(X)-1 ���g�p����
% ���B
%
% [A,E] = LPC(X,N)�́A�\���덷�̕��U(�ׂ�)���o�͂��܂��B
%
% LPC�́ALevinson-Durbin��A���g���āA�ŏ���掮���琶���鐳�K��������
% �����܂��B���̐��`�\���W���̌v�Z�́A���ȑ��֖@�Ƃ��ĎQ�Ƃ���܂��B
%
% �Q�l�F   LEVINSON, ARYULE, PRONY, STMCB.



%   Copyright 1988-2002 The MathWorks, Inc.
