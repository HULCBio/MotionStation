% HILBERT �́AHilbert �ϊ����g�����A���U���ԉ�͓I�M�����v�Z���܂��B
% X = HILBERT(Xr) �́A�����闣�U���ԉ�͐M�� X = Xr + i*Xi ���v�Z����
% ���B�����ŁAXi �͎����x�N�g�� Xr �� Hilbert �ϊ��ł��B���� Xr �����f��
% �̏ꍇ�A�������݂̂��g���܂��B���Ȃ킿�A Xr=real(Xr) �ł��BXr ���s��
% �̏ꍇ�AHILBERT �́AXr �̗�P�ʂɑ��삵�܂��B
%
% HILBERT(Xr,N) �́AN �_�� Hilbert �ϊ����v�Z���܂��BXr �́A������ N ��
% ��Z���ꍇ�A�[����t�����A�����ꍇ�͑ł��؂�܂��B 
%
% ���U���ԉ�͐M�� X �ɑ΂��āAfft(X) �̌㔼���̓[���ɂȂ�Afft(X) �̍�
% ��(DC)�ƒ���(Nyquist)�́A�����ɂȂ�܂��B
%
% ���F
%     Xr = [1 2 3 4];
%     X = hilbert(Xr)
% �́AX=[1+1i 2-1i 3-1i 4+1i] ���쐬���܂��B����́AXi = imag(X)=[1 -1 
% -1 1] ���AXr ��Hilbert �ϊ��ŁAXr = real(X)=[1 2 3 4] �ƂȂ�܂��B
% fft(X)=[10 -4+4i -2 0] �̌㔼���̓[���ɂȂ邱�Ƃɒ��ӂ��Ă��������B
% �܂��Afft(X) �� DC ������ Nyquist �v�f�́A���ꂼ��A10 �� -2 �̎�����
% �Ȃ��Ă��邱�Ƃɂ����ӂ��Ă��������B
%
% �Q�l�F FFT, IFFT.



%   Copyright 1988-2002 The MathWorks, Inc.
