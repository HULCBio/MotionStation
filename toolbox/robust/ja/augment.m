% AUGMENT �́A(��ԋ�Ԍ^��)W1, W2, W3 ���g�債�āA2�|�[�g�v�����g���쐬
% ���܂��B
% [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGMENT(SYSG,SYSW1,SYSW2,SYSW3,DIM) 
% �́A���̂悤�ȏd�ݕt���������g��v�����g�̏�ԋ�ԃ��f�����v�Z���܂��B
%
%       W1 = sysw1:=[aw1 bw1;cw1 dw1] ---- �덷�M��'e'�ɑ΂���d��
%       W2 = sysw2:=[aw2 bw2;cw2 dw2] ---- ����M��'u'�ɑ΂���d��
%       W3 = sysw3:=[aw3 bw3;cw3 dw3] ---- �o�͐M��'y'�ɑ΂���d��
%
% (��̏d�݂��Asysw1, sysw2, sysw3 �������̂Ȃ���ԋ�Ԍ^[]�Ɛݒ肷�邱
% �ƂŁA�K�p���Ȃ��悤�ɂł��܂�)
%
%       dim = [xg xw1 xw2 xw3]
% �����ŁAxg  : G(s) �̏�Ԃ̐�
%                  xw1 : W1(s) �̏�Ԃ̐� (sysw1 = [] �̏ꍇ�A�[��)
%                  xw2 : W2(s) .... ���̏�Ԑ�
%
% �g�傳�ꂽ�V�X�e���́AP(s):= (a,b1,b2,c1,c2,d11,d12,d21,d22) �ƂȂ�܂��B

% Copyright 1988-2002 The MathWorks, Inc. 
