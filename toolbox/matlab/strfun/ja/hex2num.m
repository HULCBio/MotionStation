% HEX2NUM   IEEE 16�i����{���x���l�ɕϊ�
% 
% HEX2NUM(S )�́AS ��16�i�����܂�16�L�����N�^�̕�����̂Ƃ��A����IEEE
% �{���x���������_���\�����o�͂��܂��B16�L�����N�^�������Ȃ��Ƃ��́A
% �E���Ƀ[����t�������܂��B
%
% S ���L�����N�^�z��̏ꍇ�A�e�X�̍s�͔{���x���l�Ƃ��ĉ��߂���܂��B
%
% NaN�A������A����ѕW���łȂ��������A��������舵���܂��B  
%
% ���
% 
%     hex2num('400921fb54442d18') �́APi ���o�͂��܂��B
%     hex2num('bff') �́A-1���o�͂��܂��B
%
% �Q�l�FNUM2HEX, HEX2DEC, SPRINTF, FORMAT HEX.


%   C.B. Moler 12-18-87, 1-5-88, 9-17-91.
%   Copyright 1984-2002 The MathWorks, Inc.
