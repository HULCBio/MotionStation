% CHEB1ORD Chebyshev I �^�t�B���^�̎�������
%
% [N, Wn] = CHEB1ORD(Wp, Ws, Rp, Rs)�́A�ʉߑш�̕ϓ���Rp dB�ȉ��ŁA��
% �f�ш�ɏ��Ȃ��Ƃ�Rs dB�̌��������f�B�W�^�� Chebyshev I �^�t�B���^��
% �ŏ�����N���o�͂��܂��B�ʉߑш�Wp�ƎՒf�ш�Ws�́A0 ���� 1 �܂ł̒l�ŁA
% �ʉߑш�ƎՒf�ш�̃G�b�W���g���ŁA1�̓΃��W�A���ɑ������܂��B
% 
%�@  ��
%     ���[�p�X:       Wp = .1       Ws = .2
%     �n�C�p�X:       Wp = .2,      Ws = .1
%     �o���h�p�X:     Wp = [.2 .7], Ws = [.1 .8]
%     �o���h�X�g�b�v: Wp = [.1 .8], Ws = [.2 .7]
% 
% CHEB1ORD �́A�d�l�𖞑����� CHEBYSHEV �J�b�g�I�t���g�� Wn ���o�͂��܂��B
%
% [N, Wn] = CHEB1ORD(Wp, Ws, Rp, Rs, 's')�́A�A�i���O�t�B���^��݌v����
% ���B���̏ꍇ�AWp��Ws�̎��g���̓��W�A��/�b�P�ʂł��B
%
% �Q�l�F CHEBY1, CHEB2ORD, BUTTORD, ELLIPORD.



%   Copyright 1988-2002 The MathWorks, Inc.
