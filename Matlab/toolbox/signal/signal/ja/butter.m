% BUTTER Butterworth �A�i���O����уf�B�W�^���t�B���^�̐݌v
%
% [B,A] = BUTTER(N,Wn)�́AN���̃��[�p�X�f�W�B�^��Butterworth�t�B���^��
% �݌v���A�t�B���^�W���𒷂�(N+1)�̍s�x�N�g��B�����A�ɁAz�̎����̍~��
% �ɏo�͂��܂��B �܂��A�J�b�g�I�t���g��Wn�́A0��1�̊Ԃ̐��łȂ���΂Ȃ�
% �܂���B�����ŁA1�̓T���v�����O���g����1/2(Nyquist���g��)�ł��B
% 
% Wn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�ABUTTER�͒ʉߑш� W1 < W < W2 ��
% ����2*N���̃o���h�p�X�t�B���^���o�͂��܂��B
% 
% [B,A] = BUTTER(N,Wn,'high')�́A�J�b�g�I�t���g��Wn�����n�C�p�X�t�B��
% �^��݌v���܂��B
% 
% [B,A] = BUTTER(N,Wn,'stop')�́AWn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�A
% �Ւf�ш� W1 < W < W2 �����o���h�X�g�b�v�t�B���^��݌v���܂��B
% 
% [Z,P,K] = BUTTER(...)�̂悤�ɁA3�̏o�͈�����^����ƁA��_�Ƌɂ�
% ����N�̗�x�N�g��Z��P�ɁA�܂��Q�C�����X�J��K�ɂ��ꂼ��o�͂��܂��B
%
% [A,B,C,D] = BUTTER(...)�̂悤�ɁA4�̏o�͈�����^����ƁA��ԋ��
% �s����o�͂��܂��B
% 
% BUTTER(N,Wn,'s'), BUTTER(N,Wn,'high','s'), BUTTER(N,Wn,'stop','s')
% �́A�A�i���OButterworth�t�B���^��݌v���܂��B�܂��AWn�́A[rad/s]��
% �P�ʂƂ��A1���傫���ݒ肷�邱�Ƃ��ł��܂��B
%
% �Q�l�F   BUTTORD, BESSELF, CHEBY1, CHEBY2, ELLIP, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
