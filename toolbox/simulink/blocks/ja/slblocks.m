% SLBLOCKS   ����̃c�[���{�b�N�X�܂��̓u���b�N�Z�b�g�ɑ΂���u���b�N ���C�u
% �����̒�`
%
% SLBLOCKS �́ASimulink��Blockset�Ɋւ�������o�͂��܂��B
% �o�͂������́A���̃t�B�[���h������BlocksetStruct�̌`���ł��B
%
%  Name                Simulink�u���b�N���C�u������Blocksets & Toolboxes�T
% �u                    �V�X�e����Blockset�� OpenFcn      Blocksets &
% Toolboxes�T�u�V�X�e���Ńu���b�N���_�u��          �N���b�N�����Ƃ��ɌĂяo
% ��MATLAB�\��(�֐�) MaskDisplay  Blocksets & Toolbox�T�u�V�X�e�����̃u���b
% �N�ŗp����Mask Display�R�}���h���w�肷��I�v�V�����̃t�B�[���h
%  Browser      �ȉ��ɋL�q����Simulink���C�u�����u���E�U�\���̂̔z��
%
% Simulink���C�u�����u���E�U�́ABlockset���ɕ\�����郉�C�u�����A�܂��A������
% �^���Ă��閼�O��m���Ă���K�v������܂��B���̏���^���邽�߂ɂ́A
% Simulink Library Blowser�Ŋe���C�u�����ɑ΂���1�z��v�f������Blowser�f�[
% �^�\���̂̔z����`���Ă��������B�e�z��v�f�́A�t�B�[���h��2�����܂��B
%
%  Library      ���C�u�����u���E�U�Ɋ܂܂��郉�C�u�����̃t�@�C���� (mdl-�t�@
% �C��) Name         ���C�u�����u���E�U�E�B���h�E���̃��C�u�����ɑ΂��ĕ\��
% ����閼�O�B Name         ���C�u�����u���E�U�E�B���h�E���̃��C�u�����ɑ΂�
% �ĕ\������閼�O�BName�́Amdl-�t�@�C�����Ɠ����ł���K�v�͂���܂���B
%
% ��:
%
% %
% % Simulink�u���b�N���C�u�����ɑ΂��āABlocksetStruct���`
% % simulink_extras�݂̂�Blocksets & Toolboxes�ɕ\��
% %
% blkStruct.Name        = ['Simulink' sprintf('\n' Extras];
% blkStruct.OpenFcn     = simulink_extras;
% blkStruct.MaskDisplay = disp('Simulink\nExtras');
%
% %
% % simulink��simulink_extras��Library Browser�ɕ\��
% %
% blkStruct.Browser(1).Library = 'simulink';
% blkStruct.Browser(1).Name    = 'Simulink';
% blkStruct.Browser(2).Library = 'simulink_extras';
% blkStruct.Browser(2).Name    = 'Simulink Extras';
%
% �Q�l : FINDBLIB, LIBBROWSE.


% Copyright 1990-2002 The MathWorks, Inc.
