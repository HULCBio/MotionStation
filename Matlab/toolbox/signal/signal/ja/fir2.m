% FIR2  �E�B���h�E�x�[�X�̗L���C���p���X�����t�B���^�̐݌v�|�C�Ӊ���
%
% B = FIR2(N,F,M)�́A�x�N�g��F�����M�ɂ���ė^��������g�����������A
% N����FIR�f�B�W�^���t�B���^��(N+1)�̌W�����܂񂾍s�x�N�g��B���o�͂���
% ���BPLOT(F,M)��F�ɐݒ肵���_�ł̊�]�̃Q�C��������\���܂��BF�́A0.0 <
% F < 1.0�̎��g���_�̃x�N�g���ŁA1�̓T���v�����O���g����1/2(Nyquist���g
% ��)�ł��BF�̍ŏ��̓_��0�A�Ō�̓_��1�łȂ���΂Ȃ�܂���B
%
% �t�B���^B�́A�����ŁA���`�ʑ��A���Ȃ킿�A�t�B���^�W���́A���̑Ώ̐�
% ������FIR�t�B���^�ł��B 
%
%   B(k) = B(N+2-k), k = 1,2,...,N+1.
%
% �f�t�H���g�ŁAFIR2�� Hamming �E�B���h�E���g�p���܂��B���̑��A���̃E
% �B���h�E���g�p���邱�Ƃ��ł��܂��B
% 
% Boxcar, Hann, Bartlett, Blackman, Kaiser, Chebwin
%
% ���Ƃ��΁AB = FIR2(N,F,M,bartlett(N+1))�́A Bartlett�E�B���h�E���g�p��
% �܂��BB = FIR2(N,F,M,chebwin(N+1,R))�́AChebyshev�E�B���h�E���g�p����
% ���B
%
%  �n�C�p�X��o���h�X�g�b�v�t�B���^�̂悤�ɁAFs/2�ɂ����ă[���ȊO�̃Q�C����
%  ���t�B���^�ɑ΂��ẮAN�͋����łȂ���΂Ȃ�܂���B�����łȂ��ꍇ�́A
%  N��1���������܂��B���̏ꍇ�A�E�B���h�E�̒����́AN+2�Ǝw�肳��܂��B
%
% �Q�l�F   FIR1, FIRLS, CFIRPM, FIRPM, BUTTER, CHEBY1, CHEBY2, 
%          YULEWALK, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
