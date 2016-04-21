% CHEBY1 Chebyshev I �^�t�B���^�̐݌v(�ʉߑш惊�b�v��)
%
% [B,A] = CHEBY1(N,R,Wn)�́A�ʉߑш��R dB�̃s�[�N�ԃ��b�v��������N����
% ���[�p�X�f�B�W�^��Chebyshev�t�B���^��݌v���܂��B����́A�t�B���^�W��
% �𒷂�(N+1)�̍s�x�N�g��B(���q)�����A(����)�ɏo�͂��܂��B�܂��A�J�b�g
% �I�t���g��Wn�́A0��1�̊Ԃ̐��łȂ���΂Ȃ�܂���B�����ŁA1�̓T���v��
% ���O���g����1/2(Nyquist���g��)�ł��BR�̓f�t�H���g�� 0.5 dB�A�f�t�H���g
% �ȊO�̒l��ݒ肷��ꍇ�́A�V����R��ݒ肵�Ă��������B
%
% Wn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�ɂ́ACHEBY1 �́A�ʉߑш� W1 < W <
% W2������2*N���̃o���h�p�X�t�B���^���o�͂��܂��B
%
% [B,A] = CHEBY1(N,R,Wn,'high')�́A�J�b�g�I�t���g��Wn�����n�C�p�X�t�B
% ���^��݌v���܂��B
%
% [B,A] = CHEBY1(N,R,Wn,'stop')�́AWn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�A
% �Ւf�ш� W1 < W < W2 �����o���h�X�g�b�v�t�B���^��݌v���܂��B 
%
% [Z,P,K] = CHEBY1(...)�̂悤�ɁA3�̏o�͈�����^����ƁA��_�Ƌɂ𒷂�
% N�̗�x�N�g��Z��P�ɁA�܂��Q�C�����X�J��K�ɂ��ꂼ��o�͂��܂��B
%
% [A,B,C,D] = CHEBY1(...)�̂悤�ɁA4�̏o�͈�����^����ƁA��ԋ�ԍs��
% ���o�͂��܂��B
% 
% CHEBY1(N,R,Wn,'s'), CHEBY1(N,R,Wn,'high','s'), CHEBY1(N,R,Wn,'stop','s')
% �́A�A�i���OChebyshev I �^�t�B���^��݌v���܂��B �܂��AWn�́A[rad/s]��
% �P�ʂɂ����A1���傫���ݒ肷�邱�Ƃ��ł��܂��B
%
% �Q�l�F   CHEB1ORD, CHEBY2, BUTTER, ELLIP, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
