% DFTMTX ���U�t�[���G�ϊ��s��
%
% DFTMTX(N)�́A�P�ʉ~����̒l����Ȃ�N�sN��̕��f���s����o�͂��܂��B��
% �̍s��ɒ���N�̗�x�N�g��X����Z����ƁA���̃x�N�g���̗��U���ԃt�[���G
% �ϊ����v�Z���邱�Ƃ��ł��܂��BDFTMTX(LENGTH(X))*X �́AFFT(X)�Ɠ�������
% ���o�͂��܂����AFFT(X)�����L���ł��B
%
% �t���U�t�[���G�ϊ��s��́A���̂悤�ɂȂ�܂��B
%
% CONJ(DFTMTX(N))/N 
%
% ���̗�ł́A
%
%     D = dftmtx(4)
%
% �o�͂́A���̂悤�ɂȂ�܂��B
%
%     D = [1   1   1   1
%          1  -i  -1   i     
%          1  -1   1  -1
%          1   i  -1  -i]
%
% ������A4-�_DFT�ɑ΂��āA��Z���K�v�ł͂Ȃ����Ƃ��킩��܂��B   
% 
% �Q�l�F   FFT, IFFT



%   Copyright 1988-2002 The MathWorks, Inc.
