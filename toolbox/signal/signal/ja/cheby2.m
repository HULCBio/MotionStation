% CHEBY2 Chebyshev II �^�t�B���^�̐݌v(�Ւf�ш惊�b�v��)
%
% [B,A] = CHEBY2(N,R,Wn)�́A�J�b�g�I�t���g��Wn�ƒʉߑш�̃s�[�N�l����
% RdB�ȏ㌸������Ւf�ш�Ƀ��b�v��������N���̃��[�p�X�f�B�W�^��Chebys-
% hev�t�B���^��݌v���܂��B����́A�t�B���^�W�����A����(N+1)�̍s�x�N�g
% ��B(���q)�����A(����)�ɏo�͂��܂��B�܂��A�A�J�b�g�I�t���g��Wn�́A
% 0��1�̊Ԃ̐��łȂ���΂Ȃ�܂���B�����ŁA1�̓T���v�����O���g����1/2
% (Nyquist���g��)�ł��BR�̓f�t�H���g�� 20 dB�ŁA�f�t�H���g�ȊO�̒l��
% �ݒ肷��ꍇ�́A�V����R��ݒ肵�Ă��������B
%
% Wn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�ACHEBY2 �́A�ʉߑш� W1 < W < W2
% ������2*N���̃o���h�p�X�t�B���^���o�͂��܂��B
%
% [B,A] = CHEBY2(N,R,Wn,'high')�́A�J�b�g�I�t���g��Wn�����n�C�p�X�t�B
% ���^��݌v���܂��B
%
% [B,A] = CHEBY2(N,R,Wn,'stop')�́AWn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�A
% �Ւf�ш� W1 < W < W2 �����o���h�X�g�b�v�t�B���^��݌v���܂��B 
%
% [Z,P,K] = CHEBY2(...)�̂悤�ɁA3�̏o�͈�����^����ƁA��_�Ƌɂ�
% ����N�̗�x�N�g��Z��P�ɁA�܂��Q�C�����X�J��K�ɂ��ꂼ��o�͂��܂��B
% 
% [A,B,C,D] = CHEBY2(...)�̂悤�ɁA4�̏o�͈�����^����ƁA��ԋ��
% �s����o�͂��܂��B
% 
% CHEBY2(N,R,Wn,'s'), CHEBY2(N,R,Wn,'high','s'),CHEBY2(N,R,Wn,'stop','s')�́A
% �A�i���OChebyshev II �^�t�B���^��݌v���܂��B ���̏ꍇ�AWn�́A[rad/s]
% �̒P�ʂ������A1.0.���傫���ݒ肷�邱�Ƃ��ł��܂��B
%
% �Q�l�F   CHEB2ORD, CHEBY1, BUTTER, ELLIP, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
