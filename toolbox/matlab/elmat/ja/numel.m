% NUMEL   �z��܂��́A�T�u�X�N���v�g�����ꂽ�z��\���̒��̗v�f��
%
% N = NUMEL(A) �́A�z�� A �̒��̗v�f��N ���o�͂��܂��B
%
% N = NUMEL(A, VARARGIN) �́AA(index1, index2, ..., indexN) �̒��̃T�u�X
% �N���v�g�����ꂽ�v�f����N �ɏo�͂��܂��B�����ŁAVARARGIN �̓Z���z��
% �v�f�Aindex1, index2, ... indexN �ł��B
%
% �g�ݍ��݊֐� NUMEL �́A�J���}�ŕ������ꂽ�\���A���Ƃ��΁AA{index1, 
% index2, ..., indexN} �܂���A.fieldname �ō쐬���ꂽ�ꍇ�́AMATLAB 
% �ɂ��C���v���V�b�g�ɃR�[������܂��B 
%
% ���d��`�����֐� SUBREF �� SUBSASGN �Ɋւ��āANUMEL �̈Ӗ����L�q���邱
% �Ƃ͏d�v�ł��B�����ŁANUMEL �́ASUBSREF ����߂������҂����o�͐�
% (NARGOUT)���v�Z���邽�߂Ɏg�p���܂��B���d��`�֐� SUBSASGN �ɑ΂��āA
% NUMEL ��SUBSASGN ���g���Ċ��蓖�Ă�����҂������͐�(NARGIN)���v
% �Z���邽�߂Ɏg���܂��B���d��`�֐� SUBSASGN �ɑ΂��� NARGIN �l�́A
% NUMEL �ɂ��߂����l�A�X�N���v�g�̍\���̔z��Ɋ��蓖�Ă���ϐ���
% �Ӗ����܂��B
%
% �g�ݍ��݊֐� NUMEL �ɂ��߂���� N �̒l�́A���̃I�u�W�F�N�g�ɑ΂���N
% ���X�݌v�ƈ�v���邱�Ƃ�ۏ؂��邱�Ƃ́A�d�v�Ȃ��Ƃł��B�g�ݍ��݊֐� 
% NUMEL �ɂ��߂���� N �̒l���A���d��`�֐� SUBSREF �ɑ΂���NARGOUT �A
% ���d��`�֐� SUBSASGN �ɑ΂��� NARGIN �̂ǂ��炩�̒l�ƈقȂ��Ă���ꍇ
% NUMEL �́A�N���X SUBSREF �� SUBSASGN �֐��ƈ�v���� N �̒l��߂����߂�
% NUMEL �𑽏d��`����K�v������܂��B�������Ȃ��ƁAMATLAB �́A���d��`��
% �� SUBSREF �� SUBSASGN ���R�[������Ƃ��ɁA�G���[�𔭐������܂��B
%
% �Q�l�FSIZE, PROD, SUBSREF, SUBSASGN, NARGIN, NARGOUT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $ $Date: 2004/04/28 01:51:36 $
%   Built-in function.
