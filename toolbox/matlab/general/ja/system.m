% SYSTEM   �V�X�e���R�}���h�����s���A���ʂ�߂�
%
% [status,result] = SYSTEM('command') �́A�I�y���[�e�B���O�V�X�e����
% �R�[�����āA�^����ꂽ�R�}���h�����s���܂��B���ʂ̃X�e�[�^�X��W��
% �o�͂��߂���܂��B
%
% ���:
%
%       [s,w] = system('dir')
%
% �́A(���[�U�̃I�y���[�e�B���O�V�X�e���� "dir" �R�}���h�����ʂł���
% ���̂Ɖ��肵��)�As = 0 ��߂��Aw �ɃJ�����g�f�B���N�g�����̃t�@�C��
% �̃��X�g�Ɋ܂܂�Ă���MATLAB��������o�͂��܂��B"dir" �R�}���h���g�p
% �ł��Ȃ��V�X�e���̏ꍇ�A��[���̒l�� s �ɏo�͂���A��s�� w ��
% �߂���܂��B
%
%       [s,w] = system('ls')
%
% �́A(���[�U�̃I�y���[�e�B���O�V�X�e���� "ls" �R�}���h�����ʂł������
% �Ɖ��肵��)�As = 0 �Aw �ɃJ�����g�f�B���N�g���̒��̃t�@�C���̃��X�g��
% �܂܂�Ă��� MATLAB ��������o�͂��܂��B"ls" �R�}���h���g�p�ł��Ȃ�
% �V�X�e���̏ꍇ�A��[���̒l�� s �ɏo�͂���A��s�� w �ɖ߂���܂��B
%
% �Q�l : DOS, UNIX, PUNCT�̉��ł� ! (���Q��)


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:53:39 $
%   Built-in function.
