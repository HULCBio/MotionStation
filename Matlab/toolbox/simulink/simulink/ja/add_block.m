% ADD_BLOCK   Simulink�V�X�e���Ƀu���b�N��t��
%
% ADD_BLOCK('SRC','DEST') �́A��΃p�X��'SRC'�̃u���b�N���΃p�X��'DEST'��
% �V�����u���b�N�ɃR�s�[���܂��B�V�����u���b�N�̃u���b�N�p�����[�^�́A�I���W�i
% ���̃u���b�N�p�����[�^�ƈ�v���܂��B���O'built-in'�́A���ׂĂ�Simulink�g�ݍ�
% �݃u���b�N�ɑ΂��āA�\�[�X�V�X�e�����Ƃ��Ďg�p���邱�Ƃ��ł��܂��B
%
% ADD_BLOCK('SRC','DEST','PARAMETER1',VALUE1,...) �́A���O���w�肳�ꂽ�p�����[
% �^���w��̒l�����A��L�̂悤�ȃR�s�[���쐬���܂��B�ǉ������͂��ׂāA�p�����[
% �^�ƒl�̑g�ݍ��킹�Ŏw�肵�Ȃ���΂Ȃ�܂���B
%
% ADD_BLOCK('SRC','DEST','MAKENAMEUNIQUE','ON','PARAMETER_NAME1',VALUE1,.
% ..)�́A��L�̂悤�ɃR�s�[���쐬���A��΃p�X��'DEST'�̃u���b�N�����ɑ��݂���
%
% ADD_BLOCK('SRC','DEST','COPYOPTION','DUPLICATE','PARAMETER_NAME1',
% VALUE1,...)�́AINPORT�u���b�N�ɑ΂��ē��삵�A'SRC'�u���b�N�Ɠ����[�q�ԍ���
%
% ���:
%
% add_block('simulink/Sinks/Scope','engine/timing/Scope1')
%
% �́AScope�u���b�N��Simulink�V�X�e����Sinks�T�u�V�X�e������Aengine�V�X
% �e���� timing �T�u�V�X�e������Scope1�Ƃ������O�̃u���b�N�ɃR�s�[���܂��B
%
% add_block('built-in/SubSystem','F14/controller')
%
% �́AF14�V�X�e������controller�Ƃ������O�̐V�����T�u�V�X�e�����쐬����
%
% ���B add_block('built-in/Gain','mymodel/volume','Gain','4')
%
% �́A�g�ݍ���Gain�u���b�N��mymodel�V�X�e����Volume�Ƃ������O�̃u���b�N
% �ɃR�s�[���AGain�p�����[�^�ɒl4�����蓖�Ă܂��B
%
% ���B�@block = add_block('vdp/Mu', 'vdp/Mu', 'MakeNameUnique', 'on')
%
% �́A�u���b�N��'Mu'��'Mu'�ɃR�s�[���āA�R�s�[���쐬���܂��B
% 'Mu'�u���b�N�͊��ɑ��݂���̂ŁA�V�K�u���b�N����'Mu1'�ł��B
% �f�t�H���g�� 'off' �ł��B
%
% add_block('vdp/Inport', 'vdp/Inport2', 'CopyOption', 'duplicate')
%
% �́A'vdp'��'Inport'�u���b�N�Ɠ����[�q�ԍ������L����V�K�u���b�N'Inport2'
% ���쐬���܂��B
% �f�t�H���g�� 'copy' �ł��B
%
% �Q�l : DELETE_BLOCK, SET_PARAM.


% Copyright 1990-2002 The MathWorks, Inc.
