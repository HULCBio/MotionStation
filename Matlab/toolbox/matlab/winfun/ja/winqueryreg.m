% WINQUERYREG   Microsoft Windows���W�X�g������A�C�e���̎擾
% 
% VALUE = WINQUERYREG(ROOTKEY, SUBKEY, VALNAME) �́A�w�肳�ꂽ�L�[�̒l
% ��Ԃ��܂��B
%
% VALUE = WINQUERYREG(ROOTKEY, SUBKEY) �́A���O�v���p�e�B�������Ȃ��l
% ��Ԃ��܂��B
%
% VALUE = WINQUERYREG('name',...) �́A�Z���z��� ROOTKEY\SUBKEY ����
% �L�[�̖��O��Ԃ��܂��B
%
% ���: 
% 
%     winqueryreg HKEY_CURRENT_USER Environment HOME
%     winqueryreg HKEY_CURRENT_USER Environment USER
%     winqueryreg HKEY_LOCAL_MACHINE SOFTWARE\Classes\.zip
%     winqueryreg HKEY_CURRENT_USER Environment path
%     winqueryreg name HKEY_CURRENT_USER Environment
%
% 
% ���̊֐��́A���̃��W�X�g���̒l�̃^�C�v�ɑ΂��Ă̂݋@�\���܂��B
%
%    ������ (REG_SZ)
%    �g�������� (REG_EXPAND_SZ)
%    32-bit ���� (REG_DWORD)
%
% �w�肳�ꂽ�l��������̏ꍇ�A�֐��͕������Ԃ��܂��B�l��32-bit ������
% �ꍇ�́AMATLAB��int32�^�C�v�̐�����Ԃ��܂��B


%   Copyright 1984-2002 The MathWorks, Inc. 
