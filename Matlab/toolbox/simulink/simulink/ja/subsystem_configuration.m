% SUBSYSTEM_CONFIGURATION   configurable subsystem�̐ݒ�ƊǗ�
%
% ���̊֐��́ASimulink��Configurable Subsystem�u���b�N�̐U��܂����Ǘ�
% ���邽�߂ɗ��p���܂��B����́A5��(������)�����̂�����1�ɂ���ČĂ�
% �o�����Ƃ��ł��܂��B
%
% �V�Ksubsystem_configuration
% =========================== 
% �J�����g�u���b�N(gcb)�́A���C�u�������̂��ׂẴu���b�N��\������
% "shell"�Ƃ��Đ݌v����Ă��܂��B 
% GUI�́A���[�U�Ƀ��C�u��������q�˂܂��B����́A���͈������w�肵�Ȃ��ŁA
% �֐����Ăяo�����ꍇ�̃f�t�H���g�̋����ł��B
%
% subsystem_configuration�̍\�z
% ============================= 
% shell�ɑ΂���}�X�N�́A���̒i�K�Ńu���b�N���ƃp�����[�^���ݒ肳��܂��B
% �}�X�N�̉��ɂ���Q�ƃu���b�N���쐬����A���C�u�����Ɋ܂܂�邷�ׂĂ�
% ���o�͂� superset ��\�� inport �� outport �ɐڑ�����܂��B�u���b�N��
% �f�t�H���g�̎��ʎq�́A���X�g�̈�ԍŏ��ł��B�ʏ�AGUI��figure�E�B���h�E
% �́A���̒i�K�ō폜����܂��B������'apply'���p������ꍇ�́AGUI��
% �J�����܂܂ł��B���Ȃ킿�Asubsystem_configuration('establish','apply')
% �ł��B
%
% subsystem_configuration�̍č\�z
% ===============================
% �V�������C�u���������}�X�N�ϐ�LibraryName�ɓ��͂��ꂽ�̂ŁA���݂̓��e
% �͔j������A�V����configuration���쐬����܂��B��������p���āA�K�p
% ����configuration �u���b�N�������܂��B���Ȃ킿�A
% subsystem_configuration('reestablish', ConfigBlock)�ŁA�f�t�H���g��
% gcb �ł��B  
%
% subsystem_configuration�̍X�V
% ============================== 
% ����́A���[�U��configuration��ύX����Ƃ��ɌĂяo����܂��B
% ��ɂȂ�Q�ƃu���b�N�̎��ʎq���ύX����A�K�v�ȓ��͂Əo�͂̍Đڑ���
% �s���܂��B��������p���āA�K�p����configuration�u���b�N�������܂�
% (�f�t�H���g��gcb�ł�)�B���Ȃ킿�A
% subsystem_configuration('update', ConfigBlock) �ł��B
%
% �Ō��2�̊֐��́A'LibraryName' �܂��� 'Choice' �� set_param �ɂ���āA
% �R�}���h���C��������A�N�Z�X�ł��܂��B�܂�A���C�u������ύX
% (reestablish)����ɂ́A
%       set_param(configblk, 'LibraryName', 'newLib')
% �܂��́A�J�����g�̃u���b�N�̑I����ύX(update)����ɂ́A
%       set_param(configblk, 'Choice', 'newchoice')
% �ł��B
%
% subsystem_configuration�̃R�s�[
% ===============================
% ���̊֐��́A���[�U��configurable subsystem�u���b�N���R�s�[����Ƃ���
% �Ăяo����܂��B����́A�e�u���b�N�Ƃ̃����N���������ASimulink���C�u����
% �u���E�U�ɕ\�����邽�߂ɁA�u���b�N�Ɋ܂܂�Ă���Empty Subsystem���폜
% ���܂��B


%   Copyright 1990-2002 The MathWorks, Inc.
