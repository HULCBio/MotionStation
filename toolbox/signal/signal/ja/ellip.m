% ELLIP �ȉ~�܂��� Cauer �f�B�W�^���A�A�i���O�t�B���^�̐݌v
%
% [B,A] = ELLIP(N,Rp,Rs,Wn)�́A�ʉߑш��Rp dB�̃s�[�N�ԃ��b�v���������A
% �܂��ʉߑш悩��Rs dB�Ⴂ�Ւf�ш������N���̃��[�p�X�f�B�W�^���ȉ~
% �t�B���^��݌v���܂��B����́A�t�B���^�W�����A����(N+1)�̍s�x�N�g��
% B(���q)�����A(����)�ɏo�͂��܂��B�J�b�g�I�t���g�� Wn�́A0��1�̊Ԃ̐�
% �ł��B�����ŁA1�̓T���v�����O���g����1/2(Nyquist���g��)�ł��B�ǂ̂悤��
% �l��Rp��Rs�ɐݒ肵�Ă悢��������Ȃ��ꍇ�́A�܂��A�ȉ��̒l�ɐݒ肵��
% ���������B
%
% Rp = 0.5 �A Rs = 20 
%
% Wn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�Aellip�͒ʉߑш� W1< W <W2 ������
% 2*N���̃o���h�p�X�t�B���^���o�͂��܂��B
% 
% [B,A] = ELLIP(N,Rp,Rs,Wn,'high')�́A�n�C�p�X�t�B���^��ݒ肵�܂��B[B,A] 
% = ELLIP(N,Rp,Rs,Wn,'stop')�́AWn��2�v�f�x�N�g��Wn = [W1 W2]�̏ꍇ�A2*N
% ���̃o���h�X�g�b�v�t�B���^�ŁA�Ւf�ш�́AW1< W <W2�ƂȂ�܂��B
%
% [Z,P,K] = ELLIP(...)�̂悤�ɁA3�̏o�͈�����^����ƁA��_�Ƌɂ𒷂�N
% �̗�x�N�g��Z��P�ɁA�܂��Q�C�����X�J��K�ɂ��ꂼ��o�͂��܂��B
%
% [A,B,C,D] = ELLIP(...)�̂悤�ɁA4�̏o�͈�����^����ƁA��ԋ�ԍs��
% ���o�͂��܂��B
%
% ELLIP(N,Rp,Rs,Wn,'s')�AELLIP(N,Rp,Rs,Wn,'high','s') �A�܂��́AELLIP
% (N,Rp,Rs,Wn,'stop','s')�́A�A�i���O�ȉ~�t�B���^��݌v���܂��B �܂��A
% Wn�́A[rad/s]�̒P�ʂ������A1���傫���ݒ肷�邱�Ƃ��ł��܂��B 
%
% �Q�l�F   ELLIPORD, CHEBY1, CHEBY2, BUTTER, BESSELF, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
