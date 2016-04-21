function [b,a] = fir1(N,Wn,varargin)
%FIR1   �E�B���h�E�x�[�X�̗L���C���p���X�����t�B���^�̐݌v�|�W������
%   B = FIR1(N,Wn)�́AN���̃��[�p�X�f�B�W�^��FIR�t�B���^��݌v���A
%   �t�B���^�W���𒷂�(N+1)�̍s�x�N�g�� B �ɏo�͂��܂��B�J�b�g�I�t���g��
%   Wn�́A0��1�̊Ԃ̐��łȂ���΂Ȃ�܂���B
%   �����ŁA1�̓T���v�����O���g����1/2(Nyquist���g��)�ł��B
%   �W��B�͎����ŁA���`�ʑ�FIR�t�B���^�ł��B�t�B���^�́AWn�ł̐��K������
%   ���Q�C���́A-6 dB�ł��B
%
%   B = FIR1(N,Wn,'high')�́AN���̃n�C�p�X�t�B���^��݌v���܂��B
%   B = FIR1(N,Wn,'low') �́A���[�p�X�p�X�t�B���^��݌v���܂��B
%
%   Wn��2�v�f�x�N�g��Wn  = [W1 W2]�̏ꍇ�AFIR1�́A�ʉߑш�  W1 < W < W2��
%   ����N���̃o���h�p�X�t�B���^���o�͂��܂��BB = FIR1(N,Wn,'bandpass')��
%   �w�肷�邱�Ƃ��ł��܂��B Wn = [W1 W2]�̏ꍇ�AB = FIR1(N,Wn,'stop')�́A
%   �o���h�X�g�b�v�t�B���^��݌v���܂��B
%
%   Wn�����v�f�x�N�g��Wn  = [W1 W2 W3 W4 W5 ...Wn]�̏ꍇ�AFIR1�͑ш� 
%   0 < W < W1, W1 < W < W2, ..., WN < W < 1������N���̕����ш�t�B���^��
%   �o�͂��܂��B
%
%   B = FIR1(N,Wn,'DC-1')�́A�����ш�t�B���^�̍ŏ��̑ш��ʉߑш�Ƃ���
%   ���B
%   B = FIR1(N,Wn,'DC-0')�́A�����ш�t�B���^�̍ŏ��̑ш���Ւf�ш�Ƃ���
%   ���B
%
%   B = FIR1(N,Wn,WIN) �́A�C���p���X�����ɑ΂���E�B���h�E�̂��߂ɁA
%   ����N+1�̃x�N�g��WIN���g�p����N����FIR�t�B���^��݌v���܂��B
%   �󂠂邢�͏ȗ��̏ꍇ�AFIR1 �́A����N+1��Hamming �E�B���h�E���g�p
%   ���܂��B
%   ���p�\�ȃE�B���h�E�̊��S�ȃ��X�g�ɂ��ẮA�֐�WINDOW��
%   �w���v���Q�Ƃ��Ă��������B
%   KAISER ����� CHEBWIN �́A�I�v�V�����̌�ɑ��������ƂƂ��Ɏw�肳��
%   �܂��B���Ƃ��΁AB = FIR1(N,Wn,kaiser(N+1,4))  Kaiser�E�B���h�E
%   (beta = 4)���g�p���܂��BB = FIR1(N,Wn,'high',chebwin(N+1,R))�́Arelative
%   sidelobe attenuation��R db�Ƃ��āAChebyshev�E�B���h�E���g�p���܂��B
%
%   Fs/2�ŁA�Q�C����0�ƂȂ�Ȃ��t�B���^���Ȃ킿�A�n�C�p�X�ƃo���h�X�g�b�v
%   �t�B���^�ɑ΂��āA�t�B���^����N�͕K�������łȂ���΂Ȃ�܂���B
%   �����łȂ��ꍇ�AN �́A1���������܂��B���̏ꍇ�A�E�B���h�E�̒����́A
%   N+2�Ǝw�肳���K�v������܂��B
%   
%   �f�t�H���g�ŁAFIR1�́A�E�B���h�E�K�p��̐U�����ŏ��̒ʉߑш�̒��S��1
%   �ɂȂ�悤�ɃX�P�[������܂��B�܂��A�I�v�V�����̈����Ƃ��� 'noscale' 
%   ���w�肷��ƁA���̃X�P�[�����O���s���܂���B
%   ���Ƃ��΁AB = FIR1(N,Wn,'noscale'), B = FIR1(N,Wn,'high','noscale'), 
%   B = FIR1(N,Wn,wind,'noscale')�ł��B
%   �����I�ɃX�P�[�����O��ݒ肷��ɂ́A���̂悤�ɂ��܂��B
%
%   �Q�l�F   KAISERORD, FIRCLS1, FIR2, FIRLS, FIRCLS, CFIRPM,
%            FIRPM, FREQZ, FILTER, WINDOW.




%   Copyright 1988-2002 The MathWorks, Inc.
