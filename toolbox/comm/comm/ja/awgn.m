% AWGN  ���F�K�E�X�m�C�Y��M���ɕt��
% Y = AWGN(X,SNR) �́A���F�K�E�X�m�C�Y�� X �ɕt�����܂��BSNR �́AdB �P��
% �œ��͂��܂��BX �̃p���[�́A0 dBW �Ɖ��肵�Ă��܂��BX �����f���̏ꍇ�A
% AWGN �͕��f���m�C�Y��t�����܂��B
%
% Y = AWGN(X,SNR,SIGPOWER) �́ASIGPOWER �����l�̏ꍇ�A�M���̃p���[�� 
% dBW �P�ʂŕ\���ASIGPOWER �� 'measured'�̏ꍇ�AAWGN �́A�m�C�Y��t������
% �O�ɁA�M���̃p���[�𑪂�܂��B
%
% Y = AWGN(X,SNR,SIGPOWER,STATE) �́ARANDN �̏�Ԃ� STATE �Ƀ��Z�b�g���܂��B
%
% Y = AWGN(..., POWERTYPE) �́ASNR �� SIGPOWER�̒P�ʂ�ݒ肵�܂��B
% POWERTYPE �́A'db'�A�܂��́A'linear' �̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��B
% POWERTYPE ��'db'�̏ꍇ�ASNR�́AdB �ő��肳��ASIGPOWER�́AdBW �ő���
% ����܂��B POWERTYPE ��'linear'�̏ꍇ�ASNR�͔�Ƃ��đ��肳��ASIGPOWER  
% �́A���b�g�ő��肳��܂��B
%
% ���: X �̃p���[��0 dBW �Ƃ��A10dB ��SNR �����悤�Ƀm�C�Y��t�����܂��B
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,10,0);
%
% ���: X �̃p���[��0 dBW �Ƃ��ARANDN �̃V�[�h��1234�Ɛݒ肵�A10dB ��SNR ��
%       ���悤�Ƀm�C�Y��t�����܂��B
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,10,0,1234);
%
% ���: X �̃p���[��3���b�g�ɐݒ肵�A���` SNR ��4�ɂȂ�悤�Ƀm�C�Y��
%       �t�����܂��B
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,4,3,'linear');
%
% ���: AWGN ���g���āAX �̃p���[�𑪒肷�邽�߂ɁARANDN �̃V�[�h��1234�Ɛݒ�
%       ���A���` SNR ��4�ɂȂ�悤�Ƀm�C�Y��t�����܂��B
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,4,'measured',1234,'linear');
%
%   �Q�l WGN, RANDN.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:09 $ 
