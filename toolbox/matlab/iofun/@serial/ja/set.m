% SET   serial port �I�u�W�F�N�g�v���p�e�B�̐ݒ�܂��͕\��
%
% SET(OBJ,'PropertyName',PropertyValue) �́Aserial port �I�u�W�F�N�g 
% OBJ �ɁA�w�肵���v���p�e�B PropertyName �ɒl PropertyValue ��ݒ�
% ���܂��B
%
% OBJ �́Aserial port �I�u�W�F�N�g�̃x�N�g���ŁA���̏ꍇ�ASET �́A
% ���ׂĂ� serial port �I�u�W�F�N�g�Ɏw�肳�ꂽ�v���p�e�B�l��ݒ肵�܂��B
%
% SET(OBJ,S) �́A�\���̂̒��Ɋ܂܂��l���g���āA�e�t�B�[���h���ɖ��t��
% ��ꂽ�v���p�e�B��ݒ肵�܂��B�����ŁAS �́A�I�u�W�F�N�g�v���p�e�B��
% �ł���\���̂̃t�B�[���h���ł��B
%
% SET(OBJ,PN,PV) �́A������̃Z���z�� PN �Ɏw�肵���v���p�e�B���AOBJ ��
% ���Ɏw�肵�����ׂẴI�u�W�F�N�g�ɑ΂��āA�Z���z�� PV �̒��̑Ή�����l
% �ɐݒ肵�܂��B�Z���z�� PN �̓x�N�g���ŁA�Z���z�� PV �́AM �s N ��ł��B
% �����ŁA M �́Alength(OBJ)�ŁAN �́Alength(PN) �ł��B����ŁA�e�I�u�W�F
% �N�g�́APN �̒��Ɋ܂܂��v���p�e�B���̃��X�g�ɑ΂��āA��X�̒l�ōX�V
% ����܂��B
%
% SET(OBJ,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
% �́A��̃X�e�[�g�����g�ŁA�����̃v���p�e�B�l��ݒ肵�܂��B�����ł́A
% SET �ւ̃R�[���Ɠ����悤�ɁA�v���p�e�B-�l�̕�����̑g�A�\���́A�v���p
% �e�B-�l�̃Z���z��̑g���g�����Ƃ�������Ă��邱�Ƃɒ��ӂ��Ă��������B
%
% SET(OBJ, 'PropertyName') 
% PROP = SET(OBJ,'PropertyName') �́Aserial port �I�u�W�F�N�g OBJ �̎w��
% �����v���p�e�B�APropertyName �ɐݒ�ł���\�Ȓl��\�����邩�A�o�͂�
% �܂��B�o�͂����z�� PROP �́A�v���p�e�B�́A�\�ȕ�����l�̗L���ȑg��
% �����Ă��Ȃ��ꍇ�A�\�Ȓl�̕�����A�܂��́A��Z���z��̂����ꂩ�̃Z��
% �z��ɂȂ�܂��B
%   
% SET(OBJ) 
% PROP = SET(OBJ) �́Aserial port �I�u�W�F�N�g OBJ �ɐݒ肵�����ׂĂ�
% �v���p�e�B���ƒl��\���A�܂��́A�o�͂��܂��B�o�͂����l�APROP �́A
% OBJ �̃v���p�e�B���A�܂��́A�v���p�e�B�l���A��蓾��\�Ȓl�̃Z���z��A
% �܂��́A��̃Z���z��̂����ꂩ���t�B�[���h���Ƃ���\���̂ł��B
%
% ���:
%       s = serial('COM1');
%       set(s, 'BaudRate', 9600, 'Parity', 'even');
%       set(s, {'StopBits', 'RecordName'}, {2, 'sydney.txt'});
%       set(s, 'Name', 'MySerialObject');
%       set(s, 'Parity')
%
% �Q�l : SERIAL/GET.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
