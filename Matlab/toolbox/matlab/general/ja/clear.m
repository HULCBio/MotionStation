% CLEAR   ����������ϐ��Ɗ֐�������
% 
% CLEAR�́A���[�N�X�y�[�X���炷�ׂĂ̕ϐ����������܂��B
% CLEAR VARIABLES���A���[�N�X�y�[�X���炷�ׂĂ̕ϐ����������܂��B
% CLEAR GLOBAL�́A���ׂẴO���[�o���ϐ����������܂��B
% CLEAR FUNCTIONS�́A���ׂẴR���p�C�����ꂽM-�t�@�C���AMEX-�t�@�C����
% �������܂��B
%
% CLEAR ALL�́A���ׂĂ̕ϐ��A�O���[�o���ϐ��A�֐��AMEX�����N���������܂��B
% �R�}���h�v�����v�ŁACLEAR ALL �́AJava �p�b�P�[�W�C���|�[�g���X�g������
% ���܂��B
%
% CLEAR IMPORT �́A�R�}���h�v�����v�g�ŁAJava �p�b�P�[�W�C���|�[�g���X�g
% ���������܂��B����́A�֐��̒��ł́A�g�p�ł��܂���B
%
% CLEAR CLASSES�́A�N���X�̒�`���������邱�Ƃ������΁ACLEAR ALL�Ɠ�����
% ���B���[�N�X�y�[�X�̊O���ɑ��݂���I�u�W�F�N�g(���Ƃ��΁A���[�U�f�[�^
% ��A���b�N���ꂽM-�t�@�C���̌Œ�ϐ�)������΁A���[�j���O���������A�N
% ���X�̒�`�͏�������܂���BCLEAR CLASSES�́A�N���X�̃t�B�[���h�̐��܂�
% �͖��O���ς��Ƃ��Ɏg���Ȃ���΂Ȃ�܂���B
%
% CLEAR JAVA �́A (JAVACLASSPATH��p���Ē�`�����) dynamic java path ��
% java �N���X����������邱�Ƃ������ACLEAR ALL �Ɠ����ł��B
%
% CLEAR VAR1 VAR2 ... �́A�w�肵���ϐ����������܂��B���C���h�J�[�h����'*'
% ���g���āA�p�^�[���ɍ����ϐ����������邱�Ƃ��ł��܂��B���Ƃ��΁ACLEAR 
% X*�́A�J�����g�̃��[�N�X�y�[�X����X�Ŏn�܂邷�ׂĂ̕ϐ����������܂��B
%
% CLEAR -REGEXP PAT1 PAT2 �́A���K�\�����g�p����p�^�[�����ׂĂɈ�v����
% ���߂Ɏg�p�ł��܂��B���̃I�v�V�����́A�ϐ����������邾���ł��B
% ���K�\���̎g�p�ɂ��Ă̏ڍׂ𓾂�ɂ́A�R�}���h�v�����v�g�ŁA
% "doc regexp" �Ɠ��͂��Ă��������B
%
% X���O���[�o���̏ꍇ�ACLEAR X�̓J�����g�̃��[�N�X�y�[�X����X����������
% �����A�O���[�o���錾�����֐��ɃA�N�Z�X�ł��܂��B
% CLEAR GLOBAL X�́A�O���[�o���ϐ�X�����S�ɏ������܂��B
% CLEAR GLOBAL -REGEXP PAT �́A���K�\���p�^�[���Ɉ�v����O���[�o���ϐ�
% �������܂��B
% ����̃O���[�o���ϐ����������邽�߂ɂ́AGLOBAL �I�v�V�������ŏ��ɂȂ�
% �K�v�����邱�Ƃɒ��ӂ��Ă��������B�����łȂ��ꍇ�A���ׂẴO���[�o��
% �ϐ�����������܂��B
%
% CLEAR FUN�́A�w�肵���֐����������܂��BFUN���AMLOCK�ɂ�胍�b�N�����
% ����ƁA���������Ɏc��܂��BFUN�̈قȂ�I�[�o���[�h�o�[�W��������ʂ�
% ��ɂ́A�����p�X(�Q�� PARTIALPATH)���g���Ă��������B���Ƃ��΁A'clear 
% inline/display'�́AINLINE ���\�b�h��DISPLAY�݂̂��������A���������̑�
% �̎��s�͎c���܂��B
%
% CLEAR ALL, CLEAR FUN, CLEAR FUNCTIONS �́AM-�t�@�C����ύX������A�N��
% �A����Ƃ��͂����A�֐���Œ�ϐ��ɑ΂���u���[�N�|�C���g�����������
% �̂ŁA�f�o�b�K�̃u���[�N�|�C���g�̏�����Œ�ϐ��̍ď������̌��ʂ�����
% �Ă��܂��B
%
% �ϐ�����֐�����������̏ꍇ�A�֐��`���̃V���^�b�N�X�ACLEAR('name')��
% �g���Ă��������B
%
%
% �p�^�[���}�b�`���O�̗�:
%       clear a*                % "a" �ł͂��܂�ϐ�������
%       clear -regexp ^b\d{3}$  % "b" �ł͂��܂�A 3 digits
%                               %  �������ϐ�������
%       clear -regexp \d        % �C�� digits ���܂ޕϐ�������
%
% �Q�l WHO, WHOS, MLOCK, MUNLOCK, PERSISTENT.

% Copyright 1984-2003 The MathWorks, Inc. 
