% SLDISCMDL   �A���u���b�N���܂�Simulink���f���̗��U��
%
% �g�p�@:
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,OPTIONS)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,CF)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,OPTIONS)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,CF,OPTIONS)
% ORIGBLKS     -- �A���u���b�N�̃I���W�i���̖��O
% NEWBLKS      -- ���U�����ꂽ�u���b�N�̐V�������O
% SYS               -- ���f����
% METHOD        -- 'zoh', 'foh', 'tustin','prewarp', 'matched'
% SAMPLETIME  -- �T���v�����ԁA�܂��� [sampletime offset]
% CF                  -- �ՊE���g��
% OPTIONS        -- �Z���z��: {target,ReplaceWith,PutInto,prompt},
%   target �́A�ȉ��̂��̂���I���\:
% 	 'all'          --���ׂĂ̘A���u���b�N�̗��U��
% 	 'selected' --SYS ���̃t���p�X���ł̂ݑI�����ꂽ�u���b�N�̗��U��
%   ReplaceWith �́A�ȉ��̂��̂���I���\:
%  	'parammask' --�p�����g���b�N�ȃ}�X�N�ł���A���u���b�N�̒u��
% 	'hardcoded' --�n�[�h�R�[�f�B���O���ꂽ���U�Ɠ����ȘA���u���b�N �̒u��
%   PutInto �́A�ȉ��̂��̂���I���\:
% 	 'current'       --�J�����g���f�����ɕύX�������̂�z�u 	'
% configurable' --configurable�T�u�V�X�e�����ɕύX�������̂�z�u 	'
% untitled'       --�V�K��untitled�E�B���h�E���ɕύX�������̂�z�u	'copy'
% --�I���W�i���̃��f���̃R�s�[���ɕύX�������̂�z�u  prompt �́A�ȉ��̂��̂�
% ��I���\:	 'on'   --���U�����̕\��
% 	 'off'  --���U�����̔�\��
%


% Copyright 1990-2002 The MathWorks, Inc.
