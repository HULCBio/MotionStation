% ELLIPORD �ȉ~�t�B���^�̎�������
%
% [N, Wn] = ELLIPORD(Wp, Ws, Rp, Rs)�́A�ʉߑш�̕ϓ���Rp dB�ȉ��ŁA��
% �f�ш�ɏ��Ȃ��Ƃ�Rs dB�̌��������ŏ������̑ȉ~�t�B���^�̎���N���o��
% ���܂��B�ʉߑш�Wp�A�Ւf�ш�Ws�́A0 ���� 1 �܂ł̐��K�����ꂽ�l�ł��B 
% �����ŁA1�̓΃��W�A���ɑ������܂��B
%
% ���F
%     ���[�p�X:    �@ Wp = .1,      Ws = .2
%     �n�C�p�X:   �@�@Wp = .2,      Ws = .1
%     �o���h�p�X:     Wp = [.2 .7], Ws = [.1 .8]
%     �o���h�X�g�b�v: Wp = [.1 .8], Ws = [.2 .7]
%
% ELLIPORD �́A�J�b�g�I�t���g��Wn���o�͂��A������AELLIP�Ƌ��Ɏg���āA�^
% ����ꂽ�d�l�𖞂������Ƃ��ł��܂��B
%
% [N, Wn] = ELLIPORD(Wp, Ws, Rp, Rs, 's')�́A�A�i���O�t�B���^��݌v����
% ���B���̏ꍇ�AWp��Ws�̎��g���̓��W�A��/�b�P�ʂł��B
%
% ����:�@
% Rs��Rp�ɔ�ׂĂ��Ȃ�傫���ꍇ��AWp��Ws�����Ȃ�߂��l�̏ꍇ�A���l���x
% �̌��E�𖞂����������𐄒肵�܂��B
% 
% �Q�l�F   ELLIP, BUTTORD, CHEB1ORD, CHEB2ORD.



%   Copyright 1988-2002 The MathWorks, Inc.
