% FFT  ���U�t�[���G�ϊ�
% 
% FFT(X)�́A�x�N�g��X�̗��U�t�[���G�ϊ�(DFT)���o�͂��܂��BFFT �́A�s���
% �΂��Ă͗�P�ʂő�����s���܂��BFFT�́AN�����z��ɑ΂��ẮA�ŏ���1��
% �Ȃ������ɑ΂��đ�����s���܂��B
%
% FFT(X,N)�́AN�_��FFT���o�͂��܂��BX�̒�����N��菬�����ꍇ�́AN�ɂȂ�
% �܂Ō���0�������܂��BX�̒�����N���傫���ꍇ�́AX��N��蒷�������́A
% �ł��؂��܂��B
%
% FFT(X,[],DIM)��FFT(X,N,DIM)�́A����DIM���FFT���Z��K�p���܂��B
% 
% ����N�̓��̓x�N�g��x�ɑ΂��āADFT�́A���̗v�f��������N�̃x�N�g��X
% �ɂȂ�܂��B
%                  N
%    X(k) =       sum  x(n)*exp(-j*2*pi*(k-1)*(n-1)/N)�A1 < =  k < =  N.
%                 n = 1
% 
% �tDFT(IFFT�ɂ��v�Z�����)�́A���̎��ŗ^�����܂��B
% 
%                  N
%    x(n) = (1/N) sum  X(k)*exp( j*2*pi*(k-1)*(n-1)/N)�A1 < =  n < =  N.
%                 k = 1
% 
%
% �Q�l FFT2, FFTN, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.


%   Copyright 1984-2002 The MathWorks, Inc. 
