% BUTTORD Butterworth�t�B���^�̎�������
%
% [N, Wn] = BUTTORD(Wp, Ws, Rp, Rs)�́A�ʉߑш�̑�����Rp dB�ȉ��ŁA�Ւf
% �ш�ɏ��Ȃ��Ƃ�Rs dB�̌��������A�f�B�W�^��Butterworth�t�B���^�̍ŏ�
% ����N���o�͂��܂��B�ʉߑш�Wp �� �Ւf�ш�Ws�́A0 ���� 1 �܂ł̒l�ŁA��
% �ߑш�ƎՒf�ш�̃G�b�W���g���ł��B�����ŁA1�̓΃��W�A���ɑ������܂��B
%
% ���F
%     ���[�p�X:    �@ Wp = .1,      Ws = .2
%     �n�C�p�X:   �@�@Wp = .2,      Ws = .1
%     �o���h�p�X:     Wp = [.2 .7], Ws = [.1 .8]
%     �o���h�X�g�b�v: Wp = [.1 .8], Ws = [.2 .7]
%
% BUTTORD �́A�d�l�𖞑����邽�߂ɁA�֐� BUTTER ���g�����AButterworth�J
% �b�g�I�t���g��(���邢�́A"3 dB ���g��")Wn���o�͂��܂��B
%
% [N, Wn] = BUTTORD(Wp, Ws, Rp, Rs, 's')�́A�A�i���O�t�B���^��݌v���܂��B
% ���̏ꍇ�AWp��Ws�̎��g���̓��W�A��/�b�P�ʂł��B
% 
% �܂��ARp��3dB�̏ꍇ�A�֐� BUTTER ��Wn�Ɗ֐�BUTTORD��Wp�͓����ɂȂ�܂��B
%
% �Q�l�F   BUTTER, CHEB1ORD, CHEB2ORD, ELLIPORD.



%   Copyright 1988-2002 The MathWorks, Inc.
