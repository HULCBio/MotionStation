% SHIFTDIM   �����̃V�t�g
%
% B = SHIFTDIM(X,N) �́AN �ɂ���� X �̎������V�t�g���܂��BN ������
% �Ƃ��ASHIFTDIM �́A���Ɏ������V�t�g���A�Ō�̎�����N�ɓ����悤��
% �܂��܂��BN �����̏ꍇ�ASHIFTDIM �́A�E�Ɏ������V�t�g���A�P���
% �������l�߂܂��B
%
% [B,NSHIFTS] = SHIFTDIM(X) �́AX �Ɠ����v�f���������A���̑O�Ɉʒu����
% ����1�̗v�f���폜�����z�� B ���o�͂��܂��BNSHIFTS �́A�폜���ꂽ����
% �̐��ł��BX ���X�J���̏ꍇ�ASHIFTDIM �͉����s���܂���B
%
% SHIFTDIM �́ASUM �� DIFF �̂悤�ɁA�ŏ���1�łȂ������ɑ΂��Ďg�p����
% �֐��̍쐬�ɖ𗧂��܂��B
%
% ���:
%       a = rand(1,1,3,1,2);
%       [b,n]  = shiftdim(a); % b �� 3�~1�~2 �ŁAn �� 2 �ł��B
%       c = shiftdim(b,-n);   % c == a.
%       d = shiftdim(a,3);    % d �� 1�~2�~1�~1�~3 �ł��B
%
% �Q�l:  CIRCSHIFT, RESHAPE, SQUEEZE.



%   Copyright 1984-2004 The MathWorks, Inc. 
