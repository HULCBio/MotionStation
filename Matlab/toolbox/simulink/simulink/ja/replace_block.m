% REPLACE_BLOCK   ���f�����̃u���b�N�̒u������
%
% REPLACE_BLOCK(System,BlockType,NewBlock) �́A�u���b�N�^�C�v�� BlockType��
% ���� System �Ƃ������f�����̂��ׂẴu���b�N��NewBlock�Œu�������܂��B����
% ���΁A���̃R�}���h�́Af14�Ƃ������f�����̂��ׂĂ� Gain �u���b�N��
% Integrator �u���b�N�Œu�������A�ύX���ꂽ�u���b�N�̃p�X��ϐ�
% ReplaceNames �Ɋi�[���܂��B
%
%  ReplaceNames  =  replace_block('f14','Gain','Integrator');
%
% REPLACE_BLOCK(System,BlockParameter,BlockParamValue,NewBlock) �́A�p�����[
% �^�l�� BlockParameter �� BlockParamValue �Ɉ�v���� System �Ƃ������f����
% �̂��ׂẴu���b�N��NewBlock�Œu�������܂��B�C�Ӑ��̃p�����[�^/�l�̑g��ݒ�
% ���邱�Ƃ��ł��܂��B���Ƃ��΁A���̃R�}���h�́AClutch �Ƃ������f������
% Unlocked �Ƃ����T�u�V�X�e������ Gain �p�����[�^�ɑ΂��Ēl 'bv' ��������
% �Ẵu���b�N���AIntegrator �u���b�N�Œu�������܂��B
%
%  ReplaceNames  =  ... replace_block('clutch/Unlocked','Gain','bv','
% Integrator');
%
% �����̃R�}���h�́A�u���������s���O�ɁA��v����u���b�N��I������悤�q��
% ��_�C�A���O�{�b�N�X��\�����܂��B���̃_�C�A���O�{�b�N�X��\�����Ȃ��悤��
% ����ɂ́A���̃R�}���h�̍Ō�̈����Ƃ���'noprompt'������ǉ����Ă��������B
% ���Ƃ��΁A���̃R�}���h�́AGain �u���b�N�� Integrator�u���b�N�ɕύX���܂�
% ���A�_�C�A���O�{�b�N�X�͕\�������A���ӈ����Ɍ��ʂ��o�͂��܂���B
%
%  replace_block('f14','Gain','Integrator','noprompt')
%
% ���̃R�}���h���s���ύX�����ɖ߂��͍̂���ȉ\��������̂ŁA���ӂ��Ďg����
% ���������B�܂����f����ۑ����邱�Ƃ����E�߂��܂��B
%
% �Q�l : FIND_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
