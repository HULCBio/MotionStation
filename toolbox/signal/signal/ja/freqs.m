% FREQS ���v���X�ϊ�(S-�̈�)�̎��g������
%
% H = FREQS(B,A,W)�́A�x�N�g��B �� A�ɁA���q�ƕ���̌W�����^����ꂽ�ꍇ�A
% �t�B���^B/A�̕��f���g������H���o�͂��܂��B
%
%                      nb-1      nb-2
%          B(s)   b(1)s  +  b(2)s   + ... +  b(nb)
%   H(s) = ---- = --------------------------------
%                      na-1      na-2
%          A(s)   a(1)s  +  a(2)s   + ... +  a(na)
%
% ���g�������́A�x�N�g��W�Ŏw�肳�����g���_��ݒ肵�܂��BFREQS(B,A,W)
% �ł́A�o�͈�����ݒ肵�Ȃ��ꍇ�A���g���ɑ΂���Q�C������шʑ��������J
% �����g��figure�E�B���h�E�Ƀv���b�g�\�����܂��B
%
% [H,W] = FREQS(B,A)�́A���g������H���v�Z����200�̎��g���_W�������I��
% �ݒ肵�܂��BFREQS(B,A,N)�́AN�_�̎��g���������v�Z���܂��B
%
% �Q�l�F   LOGSPACE, POLYVAL, INVFREQS, FREQZ.



%   Copyright 1988-2002 The MathWorks, Inc.
