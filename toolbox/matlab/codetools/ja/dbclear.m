%DBCLEAR �u���[�N�|�C���g�̍폜
% DBCLEAR �R�}���h�́A�Ή����� DBSTOP �ɂ��ݒ肳���u���[�N�|�C���g��
% �폜���܂��B���̃R�}���h�ɂ́A���̂悤�ȁA�������̌`��������܂��B
%
%   (1)  DBCLEAR IN MFILE AT LINENO
%   (2)  DBCLEAR IN MFILE AT SUBFUN
%   (3)  DBCLEAR IN MFILE
%   (4)  DBCLEAR IF ERROR
%   (5)  DBCLEAR IF CAUGHT ERROR
%   (6)  DBCLEAR IF WARNING
%   (7)  DBCLEAR IF NANINF  �܂���  DBCLEAR IF INFNAN
%   (8)  DBCLEAR IF ERROR IDENTIFIER
%   (9)  DBCLEAR IF CAUGHT ERROR IDENTIFIER
%   (10) DBCLEAR IF WARNING IDENTIFIER
%   (11) DBCLEAR ALL
%
% MFILE �́AM-�t�@�C�����A�܂��́AMATLABPATH-���Ε����p�X�� 
% (PARTIALPATH ���Q��)�ł���K�v������܂��BLINENO �́AMFILE ����
% ���C�����ł���ASUBFUN�́AMFILE ���̃T�u�֐����ł��BIDENTIFIER �́A
% MATLAB Message Identifier (message identifiers �ɂ��ẮAERROR ��
% �w���v���Q�� ) �ł��B�L�[���[�h AT ����� IN �́A�I�v�V�����ł��B
% 
% ��L�̌`���́A���̂悤�ɓ��삵�܂��B
%
%   (1)  MFILE �̃��C�� LINENO �̃u���[�N�|�C���g���폜���܂��B
%   (2)  MFILE �̎w�肳�ꂽ�T�u�֐��̍ŏ��̎��s�\�ȃ��C���Ńu���[�N�|�C���g
%�@�@�@�@���폜���܂��B
%   (3)  MFILE ���̂��ׂẴu���[�N�|�C���g���폜���܂��B
%   (4)  �ݒ肳��Ă���ꍇ�ADBSTOP IF ERROR �X�e�[�g�����g ����� 
%        DBSTOP IF ERROR IDENTIFIER �X�e�[�g�����g���������܂��B
%   (5)  �ݒ肳��Ă���ꍇ�ADBSTOP IF CAUGHT ERROR �X�e�[�g�����g 
%        ����� DBSTOP IF CAUGHT ERROR IDENTIFIER �X�e�[�g�����g���������܂��B
%   (6)  �ݒ肳��Ă���ꍇ�ADBSTOP IF WARNING �X�e�[�g�����g ����� 
%        DBSTOP IF WARNING IDENTIFIER �X�e�[�g�����g���������܂�
%   (7)  ������ �� NaNs ��DBSTOP ��ݒ肳��Ă���ꍇ�A�������܂��B
%   (8)  �w�肵��IDENTIFIER �ɑ΂��� DBSTOP IF ERROR IDENTIFIER 
%        �X�e�[�g�����g���������܂��B
%        DBSTOP IF ERROR �܂��� DBSTOP IF ERROR ALL ���ݒ肳��Ă���ꍇ�A
%        �w�肵�����ʎq�̂��̐ݒ����������ƁA�G���[�ɂȂ�܂��B 
%   (9)  �w�肵��IDENTIFIER �ɑ΂���DBSTOP IF CAUGHT ERROR IDENTIFIER 
%        �X�e�[�g�����g���������܂��B DBSTOP IF CAUGHT ERROR �܂��� 
%        DBSTOP IF CAUGHT ERROR ALL���ݒ肳��Ă���ꍇ�A�w�肵�����ʎq��
%        ���̐ݒ����������ƁA�G���[�ɂȂ�܂��B 
%   (10) �w�肳�ꂽIDENTIFIER �ɑ΂��� DBSTOP IF WARNING IDENTIFIER �X�e�[�g
%        �����g���������܂��B
%        IDENTIFIER. DBSTOP IF WARNING �܂��� DBSTOP IF WARNING ALL ���ݒ�
%        ����Ă���ꍇ�A�w�肵�����ʎq�̂��̐ݒ����������ƃG���[�ɂȂ�܂��B
%   (11) ��L��(4)-(7)�ɏq�ׂ��悤�ɁA���ׂĂ�M-�t�@�C���̃u���[�N�|�C���g
%        ���������܂��B
%
% �Q�l DBSTEP, DBSTOP, DBCONT, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%      DBQUIT, ERROR, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
