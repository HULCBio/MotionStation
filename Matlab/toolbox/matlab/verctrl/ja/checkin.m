% CHECKIN �o�[�W�����R���g���[���V�X�e���̒��̃t�@�C���܂��̓t�@�C��
% �Q���`�F�b�N
% 
%   CHECKIN(FILENAME, 'COMMENTS', COMMENT_TEXT) 
% 
% ������ COMMENT_TEXT ���̃R�}���h���g���āA�\�[�X�R���g���[���V�X�e��
% �̒��� FILENAME ���`�F�b�N���܂��BFILENAME �́A�t�@�C���̐�΃p�X��
% ����K�v������܂��BFILENAME �́A�t�@�C���̃Z���z��ł��\���܂���B
% �`�F�b�N����O�ɁA�t�@�C�����Z�[�u���܂��B
% 
%   CHECKIN(FILENAME, 'COMMENTS', COMMENT_TEXT, OPTION1, VALUE1, ...
%      OPTION2, VALUE2)
%
% OPTIONS �́A���̂��̂ł��B
%      lock - �t�@�C���̃`�F�b�N�A�E�g�Ɋւ����ԁB�f�t�H���g�̓I���ŁA
%             �ݒ�ł���l�́A���̂��̂ł��B
%          on(�I��)
%          off(�I�t)
%
% ���F
%      checkin('\filepath\file.ext','comments','A sample comment')
%      Checks \filepath\file.ext into the version control tool.
%
%      checkin({'\filepath\file1.ext','\filepath\file2.ext'},'comments',...
%         'A sample comment')
%      Checks \filepath\file1.ext and \filepath\file2.ext into the
%      version control system, using the same comments for both files.
%
% �Q�l�FCHECKOUT, UNDOCHECKOUT, CMOPTS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/28 02:09:19 $
