% IDDATA/IFFT   ���g���̈� IDDATA �M���� IFFT �̌v�Z
%
% DATI = IFFT(DAT) �́A���g���̈�� IDDATA �M�����\�[�g���AIFFT ��p��
% �Ď��ԗ̈�f�[�^�ɕϊ����܂��B
%   
% ���̃��[�`���́A0����i�C�L�X�g���g���܂ł̓��Ԋu�Ȏ��g���̈�f�[�^
% ���K�v�ł��B
% ��萳�m�ɂ�:
% DAT.Frequency = [0:df:F] �ł��B�����ŁAN ����̏ꍇ�A
% df = 2*pi/(N*DAT.Ts) �ŁAF =  pi/DAT.Ts �ł��B�܂��AN �������̏ꍇ�A
% F = pi/DAT.Ts * (1- 1/N) �ł��B������ N �́A���g���̓_���ł��B
%
% �Q�l: FFT.  
 
 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 17:06:32 $

