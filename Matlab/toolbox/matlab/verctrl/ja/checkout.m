% CHECKOUT   �o�[�W�����R���g���[���V�X�e���̃t�@�C���A�܂��́A�t�@�C���Q
%            �̃`�F�b�N
%
% CHECKOUT(FILENAME) �́A�o�[�W�����R���g���[���V�X�e������ FILENAME 
% ���`�F�b�N���܂��BFILENAME �́A�t�@�C���̐�΃p�X�ł���K�v������܂��B
% FILENAME �́A�t�@�C���̃Z���z��ł��\���܂���B�f�t�H���g�ł́A���ׂ�
% �̃t�@�C�����A�`�F�b�N�A�E�g�ɂȂ��Ă��܂��B
%
%   CHECKOUT(FILENAME, OPTION1, VALUE1, OPTION2, VALUE2, ...)
%
% OPTIONS �ɂ́A���̂��̂�ݒ肷�邱�Ƃ��ł��܂��B
%      lock - �t�@�C���̃`�F�b�N�A�E�g�Ɋւ����ԁB�f�t�H���g�̓I���ŁA
%             �ݒ�ł���l�́A���̂��̂ł��B
%          on(�I��)
%          off(�I�t)
%
%      revision - �`�F�b�N����t�@�C���̃o�[�W�������w��
%
% ���F
%      checkout('\filepath\file.ext')
%      Checks out \filepath\file.ext from the version control system.
%
%      checkout({'\filepath\file1.ext','\filepath\file2.ext'})
%      Checks out \filepath\file1.ext and \filepath\file2.ext from the
%      version control system.
%
% �Q�l�FCHECKIN, UNDOCHECKOUT, CMOPTS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/28 02:09:20 $

