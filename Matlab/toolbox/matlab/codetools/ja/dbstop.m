%DBSTOP �u���[�N�|�C���g�̐ݒ�
% �R�}���h DBSTOP �́AM-�t�@�C���֐��̎��s���ꎞ�I�ɒ�~����Ƃ��Ɏg���A
% ���[�J���̃��[�N�X�y�[�X�̓��e�𒲂ׂ邱�Ƃ��ł��܂��B���̃R�}���h�ɂ́A
% ���̂������̃^�C�v�����݂��܂��B 
%
%   (1)  DBSTOP IN MFILE AT LINENO
%   (2)  DBSTOP IN MFILE AT SUBFUN
%   (3)  DBSTOP IN MFILE
%   (4)  DBSTOP IN MFILE AT LINENO IF EXPRESSION
%   (5)  DBSTOP IN MFILE AT SUBFUN IF EXPRESSION
%   (6)  DBSTOP IN MFILE IF EXPRESSION
%   (7)  DBSTOP IF ERROR 
%   (8)  DBSTOP IF CAUGHT ERROR 
%   (9)  DBSTOP IF WARNING 
%   (10) DBSTOP IF NANINF  ���邢��  DBSTOP IF INFNAN
%   (11) DBSTOP IF ERROR IDENTIFIER
%   (12) DBSTOP IF CAUGHT ERROR IDENTIFIER
%   (13) DBSTOP IF WARNING IDENTIFIER
%
% MFILE �́AM-�t�@�C���̖��O�A�܂��́AMATLABPATH���Ε����p�X���ł���K�v
% ������܂� (�Q�� PARTIALPATH)�BLINENO �́AMFILE ���̃��C�����ł���A
% SUBFUN�@�́AMFILE ���̃T�u�֐����ł��BEXPRESSION �́A���s�\�ȏ�������
% �܂ޕ�����ł��BIDENTIFIER �́AMATLAB MessageIdentifier �ł� (���b�Z�[�W
% ���ʎq�̋L�q�ɑ΂���ERROR�̃w���v�Q��)�B�L�[���[�h AT, IN �̓I�v�V�����ł��B
% 
%   10�̃^�C�v�́A���̂��̂ł��B
%
%   (1)  MFILE ���̎w�肵�����C���ԍ��Œ�~���܂��B
%   (2)  MFILE �̎w�肵���T�u�֐��Œ�~���܂��B
%   (3)  MFILE �̍ŏ��̎��s�\�ȃ��C���Œ�~���܂��B
%   (4-6) EXPRESSION ��true �ɕ]������ꍇ���̂ݒ�~���邱�Ƃ������A(1)-(3)��
%        ���l�ł��BEXPRESSION �́A�u���[�N�|�C���g�ɉ�ƁAMFILE �̃��[�N
%        �X�y�[�X�ŁA( EVAL �ɂ��ꍇ�̂悤��) �ɕ]������A�X�J���̘_���l 
%        (true �܂��� false) �ɕ]�������K�v������܂��B
%   (7)  TRY...CATCH �u���b�N���Ō��o����Ȃ����s���G���[���N���� M-�t�@�C��
%        �֐����Œ�~�������N�����܂��Bcatch ����Ȃ��������s���G���[�̌�A 
%        M-�t�@�C���̎��s���ĊJ���邱�Ƃ͂ł��܂���B
%   (8)  TRY...CATCH �u���b�N���Ō��o���ꂽ���s���G���[�̌����ƂȂ� M-�t�@�C��
%        �֐��Œ�~���܂��B���s���G���[��catch �����AM-�t�@�C���̎��s���ĊJ
%        �ł��܂��B
%   (9)  ���s�����[�j���O�̌����ɂȂ� M-�t�@�C���֐����Œ�~���܂��B
%   (10) ������(Inf)�A�܂��́ANaN �����m���ꂽ�ʒu�ɑ��݂��� 
%        M-�t�@�C���̒��Œ�~���܂��B
%   (11-13) ���b�Z�[�W���ʎq�� IDENTIFIER �ł���G���[�܂��̓��[�j���O
%         �ɂ����āAMATLAB ����~���邱�Ƃ������A(7)-(9)�Ɠ��l�ł��B   
%         ( IDENTIFIER ������̕����� 'all' �̏ꍇ�A�����́A(7)-(9)
%           �Ɠ�����������܂��B)
%
% MATLAB ���A�u���[�N�|�C���g�ɏo��ƁA�f�o�b�O���[�h�ɓ���܂��B
% ����ƁA�v�����v�g���AK>>�ɕς��A�f�o�b�O���j���[�� 
% "Open M-Files when Debugging" �̐ݒ�Ɉ˂�A�f�o�b�K�E�B���h�E���A�N�e�B�u
% �ɂȂ�܂��B�C�ӂ�MATLAB �R�}���h���v�����v�g�ɑ΂��ē��͂ł��܂��B
% M-�t�@�C���̎��s���ĊJ����ɂ́ADBCONT �܂��́ADBSTEP ���g����
% ���������B�f�o�b�K���甲���o���ɂ́ADBQUIT ���g���Ă��������B
%
%   �Q�l DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%        DBSTATUS, DBQUIT, ERROR, EVAL, LOGICAL, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
