% WHICH   �֐��ƃt�@�C���̈ʒu�̏o��
% 
% WHICH FUN �́A�֐� FUN �̃t���p�X����\�����܂��B���[�N�X�y�[�X�̒���
% �ϐ��A�g�ݍ��݊֐��A���[�h���ꂽSimulink���f���A�܂��̓��[�h���ꂽJava�N��
% �X���̃��\�b�h�́A���̖��O���ϐ��A�g���֐��ASimulink���f���A�܂��͕�����
% ���[�h���ꂽJava�N���X���̃��\�b�h�ł��邱�Ƃ��������b�Z�[�W��\�����܂��B
% WHICH ���g�ł́A�N���X�p�X��ɑ��݂���Java�N���X�̃��\�b�h��T������̂�
% �ł��B
%
% WHICH FUN -ALL �́AFUN �Ƃ������O�������ׂĂ̊֐��̃p�X��\�����܂��B
% -ALL �t���O�́AWHICH �̂��ׂĂ̌`���Ŏg�����Ƃ��ł��܂��B
%
% WHICH FILE.EXT �́A�w�肵���t�@�C�����J�����g���[�L���O�f�B���N�g���A�܂���
% MATLAB�p�X��ɑ��݂���ꍇ�A�t�@�C���̃t���p�X����\�����܂��B EXIST ��
% �g���āA�t�@�C�������̏ꏊ�ɑ��݂��邩�ۂ����`�F�b�N�ł��܂��B
%
% WHICH FUN1 IN FUN2 �́AM-�t�@�C�� FUN2 �̒��̊֐� FUN1 �̃p�X����\
% �����܂��BFUN2 ���f�o�b�O���Ă���ԁAWHICH FUN1�́A�������Ƃ��s���܂��B
% ���̂��Ƃ𗘗p���āA�T�u�֐��܂��̓v���C�x�[�g�Ȋ֐����p�X��̊֐��̑���
% �ɌĂяo�����Ƃ��ł��邩�ǂ��������肷�邱�Ƃ��ł��܂��B
%
% WHICH FUN(A,B,C) �́A�^����ꂽ���͈������g���Ċ֐��̃p�X��\�����܂��B
% ���Ƃ��΁Ag = inline('sin(x)') �̂Ƃ��Awhich feval(g) �́Ainline/feval.m
% ���Ăэ��܂�邱�Ƃ������܂��BS = java.lang.String('my Java string') ��
% �Ƃ��Awhich toLowerCase(S) �́A�N���X java.lang.String �̒��� toLowerCase 
% ���\�b�h���Ăэ��܂�邱�Ƃ������܂��B
%
% S = WHICH(...) �́AWHICH �̌��ʂ��X�N���[���ɕ\���������ɁA������S��
% �o�͂��܂��BS �́A�g�ݍ��݊֐��⃏�[�N�X�y�[�X�ϐ��ɑ΂��Ă͕�����
% 'built-in' �܂��� 'variable' �ł��B�o�͈���������Ƃ��́AWHICH ���֐��`��
% �Ŏg��Ȃ���΂Ȃ�܂���B
%
% W = WHICH(...,'-all') �́AWHICH �̕����T�[�`�o�[�W�����̌��ʂ��A�Z���z��
% W �ɏo�͂��܂��BW �́A�ʏ�X�N���[���ɕ\�������p�X�̕�������܂݂܂��B
% 
% �Q�l�FDIR, HELP, WHO, WHAT, EXIST, LOOKFOR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:45 $
%   Built-in function.
