% SLUPDATE   ���o�[�W�����̃u���b�N�����o�[�W�����̃u���b�N�ɒu��
%
% SLUPDATE(SYS) �́A���f��SYS���̋��o�[�W�����̔p�~���ꂽ�u���b�N��
% Simulink 4�̃u���b�N�Œu�������܂��B���f���́ASLUPDATE���Ăяo���O�ɊJ����
% ���Ȃ���΂Ȃ�܂���B�A�b�v�f�[�g���ꂽ�u���b�N�͈ȉ��̂Ƃ���ł��B
%
% Pulse Generator             - �V�K�C���v�������e�[�V���� Hit Crossing
%  - �g�ݍ��݂ɂȂ��Ă��܂� S-function Memory           - Memory�u���b�N�͑g
%  �ݍ��݂ɂȂ��� ���܂� S-function Quantizer        - �g�ݍ��݂ɂȂ��Ă��܂� Gr
%  aph scope                 - �g�ݍ��݂�Scope�͂��̃u���b�N�� ���ǂ��Ă��܂�
%  S-function 2-D Table Lookup - �g�ݍ��݂ɂȂ��Ă��܂� Elementary Mat
%  h             - Trigonometry,Rounding, Math�u���b �N�� �u���������
%  �Ă��܂� To Workspace                - Maximum rows�p�����[�^��3�v�f
%   �o�[�W�����́A�X�̃t�B�[���h�� ��������Ă��܂� Outport                     -
%                                Initial output ��[] �Œu�������Ă��܂��B
%
% SLUPDATE(SYS, PROMPT) �́APROMPT �̒l��1�̏ꍇ�A�u���\�ȃu���b�N�ɂ���
% ���[�U�Ɏ��₵�܂��B����̓f�t�H���g�ł��B
% �l��0�Ȃ�Ύ��₵�܂���B
%
% ���₳�ꂽ�Ƃ��A���[�U��3��ނ̃I�v�V�����������܂��B
% - "y" : �u���b�N��u��(�f�t�H���g)- "n" : �u���b�N��u�����Ȃ�- "a" : ��
% �ׂẴu���b�N���m�F�����ɒu��
%
% �O�q�̕ύX�ɉ����āASLUPDATE �́AADDTERMS ���Ăяo���Ė��ڑ��̓��͂���яo
% �͒[�q�� Ground ����� Terminator �u���b�N�Ɛڑ����邱�Ƃɂ�茋�����܂��B
% SLUPDATE�́A�u���b�N��K�؂ȃu���b�N���C�u�����ɂ����郊���N�ɕϊ����܂��B
%
% SLUPDATE �́A�T�u�V�X�e���A���邢�́AS�t�@���N�V�����łȂ����ׂẴ}�X�N����
% ���g�ݍ��݂̃u���b�N���������A�u���b�N���T�u�V�X�e���ɒu���A�}�X�N�ƃu���b
% �N�̃R�[���o�b�N��V�����T�u�V�X�e���ɃR�s�[���܂��B
%
% �Q�l : FIND_SYSTEM, GET_PARAM, ADD_BLOCK, ADDTERMS, MOVEMASK.


% Copyright 1990-2002 The MathWorks, Inc.
