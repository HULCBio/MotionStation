% function sys = mfilter(fc,ord,type,psbndr)
%
% �P���́A�P�o�̓A�i���O�t�B���^��SYSTEM�s��Ƃ��Čv�Z���܂��B�J�b�g�I�t
% ���g��(Hertz)��FC�A�t�B���^�̎�����ORD�Ƃ��܂��B������ϐ�TYPE�́A��
% �̂悤�Ƀt�B���^�̃^�C�v���w�肵�܂��B
%
%  'butterw'     Butterworth
%  'cheby'       Chebyshev
%  'bessel'      Bessel
%  'rc'          resistor/capacitor�t�B���^
%
% �e�X�̃t�B���^��dc�Q�C��(����������Chebyshev������)��1�Ƃ��܂��B����
% PSBNDR �́AChebyshev�̒ʉߑш�Ń��b�v���̕ϓ��̋��e�͈͂��w�肵�܂�
% (�P�ʂ�dB)�B�J�b�g�I�t���g���ł́A�傫����-PSBNDR dB�ł��B����������
% Chebyshev�t�B���^�ł́ADC�Q�C���́A-PSBNDR dB�ł��B
%
% Bessel�t�B���^�́A���J�[�V�u�ȑ��������g���Čv�Z����܂��B����́A����
% �̃t�B���^(8���ȏ�)�ł́A�������������Ȃ�܂��B
%



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
