% CHEB2ORD Chebyshev II �^�t�B���^�̎�������
%
% [N, Wn] = CHEB2ORD(Wp, Ws, Rp, Rs)�́A�ʉߑш�̕ϓ���Rp dB�ȉ��ŁA��
% �f�ш�ɏ��Ȃ��Ƃ�Rs dB�̌��������f�B�W�^�� Chebyshev II �^�t�B���^
% �̍ŏ�����N���o�͂��܂��B�ʉߑш�Wp�ƎՒf�ш�Ws�́A0 ���� 1 �܂ł̒l�ŁA
% �ʉߑш�ƎՒf�ш�̃G�b�W���g���ŁA1�̓΃��W�A���ɑ������܂��B
% 
% ���F 
%     ���[�p�X:       Wp = .1,      Ws = .2
%     �n�C�p�X:       Wp = .2,      Ws = .1
%     �o���h�p�X:     Wp = [.2 .7], Ws = [.1 .8]
%     �o���h�X�g�b�v: Wp = [.1 .8], Ws = [.2 .7]
%
% CHEB2ORD�́A�d�l�𖞑�����Chebyshev �J�b�g�I�t���g�� Wn ���o�͂��܂��B
% 
% [N, Wn] = CHEB2ORD(Wp, Ws, Rp, Rs, 's')�́A�A�i���O�t�B���^��݌v����
% ���B���̏ꍇ�AWp��Ws�̎��g���̓��W�A��/�b�P�ʂł��B
%
% �Q�l�F CHEBY2, CHEB1ORD, BUTTORD, ELLIPORD.



%   Copyright 1988-2002 The MathWorks, Inc.
