%WARNING ���[�j���O���b�Z�[�W�̕\��
% WARNING('MSGID', 'MESSAGE') �́ADISP �̂悤�Ƀ��[�j���O���b�Z�[�W MESSAGE 
% ��\�����܂����AWARNING �ł̓��b�Z�[�W�̕\����}�����邱�Ƃ��ł��܂��B
% MSGID �́A���[�j���O�����j�[�N�Ɏ��ʂ��邽�߂Ɏg�p�ł��郁�b�Z�[�W���ʎq�ł��B

% ���b�Z�[�W���ʎq�́A<component>[:<component>]:<mnemonic>�̌`���̕�����ł��B
% �����ŁA<component> �� <mnemonic> �́A�p����������ł��B���b�Z�[�W���ʎq��
% ��́A'MATLAB:divideByZero' �ł��B���ʎq�́A���[�j���O�̕\����I��I�ɗ��p�\

% ���邢�͕s�\�ɂ��邽�߂ɁA�p���邱�Ƃ��ł��܂��BWARNING �́A���b�Z�[�W���ʎq

% �̑啶���Ə���������ʂ��܂���BMESSAGE �́A\t or \n �̂悤�ȁA�G�X�P�[�v
% �V�[�N�G���X���܂ޕ�����ł��B WARNING �́A�����̗��K�؂ȃe�L�X�g������
% �ϊ����܂��B
%
% WARNING('MSGID', 'MESSAGE', A, ...) �́A�����������[�j���O���b�Z�[�W��
% �\�����܂��B�G�X�P�[�v�V�[�N�G���X�ɉ����A������ MESSAGE �́A�֐� SPRINTF 
% �ɂ��T�|�[�g�����C����ϊ��w��q(e.g., %s or %d)���܂݂܂��B 
% �ǉ��̈��� A, ... �́A�����̎w��q�ɑ�������l��^���܂��B�����̈����́A
% ������A�܂��́A�X�J���[�̐��l�������Ƃ��ł��܂��B�L���ȕϊ��w��q��
% �ւ�����́AHELP SPRINTF ���Q�Ƃ��Ă��������B
%
% WARNING('MESSAGE', ...) �́A�����������[�j���O���b�Z�[�W��\�����܂��B
% �G�X�P�[�v�V�[�N�G���X�ɉ����A������ MESSAGE �́A�֐� SPRINTF �ɂ��
% �T�|�[�g�����C����ϊ��w��q(���Ƃ��΁A%s �܂��� %d)���܂݂܂��B 
% MSGID �������Ȃ����߁A���[�j���O�ɑ΂��郁�b�Z�[�W���ʎq�́A�f�t�H���g
% �ɂ��A��̕�����ɂȂ�܂��B���̂悤�ȃ��[�j���O�́A�f�t�H���g��
% ���[�j���O��Ԃɏ]���ċ@�\���A'all' ���ʎq���g���Đݒ肵�܂�(���L���Q��)�B
%       
% WARNING('MESSAGE') �́A�����������Ȃ����[�j���O���b�Z�[�W��\�����܂��B
% ������ MESSAGE �Ɋ܂܂��A�G�X�P�[�v�V�[�N�G���X �܂��� �ϊ��q
% �́A����炪�\�킷�e�L�X�g�ɕϊ�����܂���BMSGID �������Ȃ����߁A
% ���[�j���O�ɑ΂��郁�b�Z�[�W���ʎq�́A�f�t�H���g�ɂ��A��̕�����ɂȂ�܂��B

% ���̂悤�ȃ��[�j���O�́A�f�t�H���g�̃��[�j���O��Ԃɏ]���ċ@�\���A'
% all' ���ʎq���g���Đݒ肵�܂�(���L���Q��)�B
%
% ����: ���b�Z�[�W���ʎq���g�p���A�����̂Ȃ����b�Z�[�W��\�����邽�߂ɂ́A
% �����g�p���Ă��������B
%
%       WARNING('MSGID', '%s', 'MESSAGE')
%
% WARNING('OFF', 'MSGID') �́A���b�Z�[�W���ʎq��MSGID �ł��郏�[�j���O
% �̕\����}�����܂��B
%
% WARNING('ON', 'MSGID') �́A���b�Z�[�W���ʎq�� MSGID �ł��郏�[�j���O
% ��\�����܂��B
%
% WARNING('QUERY', 'MSGID') �́A���b�Z�[�W���ʎq�� MSGID �ł��郏�[�j���O
% �̏��('on' �܂��� 'off')��������܂��B
% 
% S = WARNING(ARG, 'MSGID') �́AARG �� 'on' �܂��� 'off' �̂����ꂩ��
% �ꍇ�AMSGID�ɂ���Ď��ʂ���郏�[�j���O�ɑ΂��郏�[�j���O��Ԃ��
% �肵�A�O�̃��[�j���O��Ԃ��t�B�[���h 'identifier' ����� 'state' ��
% ���\���̂Ƃ��� S �ɏo�͂��܂��BARG �� 'query' �̏ꍇ�́AS �͎w��
% �������[�j���O�̃J�����g�̏�Ԃ��擾���܂��B����́A�ύX����܂���B
%
% MSGID ��2�Ԗڂ̈����Ƃ���WARNING �ɓn�����ꍇ�́AMSGID �� ��
% �ׂẴ��[�j���O�� disabled, enabled, queried�ł��� 'all' �ł����܂�
% �܂���B�܂��A�Ō�ɕ\�����ꂽ���[�j���O�� disabled, enabled, queried 
% �ł���  'last' �ł����܂��܂���B
%
% WARNING ON BACKTRACE �́A���[�j���O���\�������Ƃ��ɁA���[�j���O
% �𔭐������t�@�C���ƍs�ԍ���\�����܂��B
%
% WARNING OFF BACKTRACE �́A���[�j���O���\�������Ƃ��ɁA���[�j���O
% �𔭐������t�@�C���ƍs�ԍ���\�����܂���B
%
% WARNING ON VERBOSE �́A���[�j���O���\�������Ƃ��ɁA���[�j���O
% ���ʎq���܂ރw���v�e�L�X�g�̃G�L�X�g���s��������܂��B
%
% WARNING OFF VERBOSE �́A���[�j���O���\�������Ƃ��ɁA���[�j���O
% ���ʎq���܂ރw���v�e�L�X�g�̃G�L�X�g���s��\��������܂���B
%
% S = WARNING('QUERY', ARG) �́AARG �� 'BACKTRACE' �܂��� 'VERBOSE' �̂Ƃ��A
% ARG ���܂ރt�B�[���h 'identifier'�� ARG �̃J�����g��Ԃ��܂ރt�B�[���h
% 'state' �����\���̂��o�͂��܂��B
%
% WARNING(S) �́AS ���t�B�[���h 'identifier' �����'state' �����\����
% �̂Ƃ��A�ȉ��Ɠ����ł��B
%
%       for k = 1:length(S), warning(S(k).state, S(k).identifier); end
%
% ����������ƁAWARNING �́A�o�͂�����̂Ɠ����\���̂���͂Ƃ��Ď�
% ����A����́A���[�j���O�̏�Ԃ������̑O�̒l�Ƀ��X�g�A���邽�߂�
% ���p���邱�Ƃ��ł��܂��B
%
% �Q�l SPRINTF, LASTWARN, DISP, ERROR, ERRORDLG, WARNDLG.

%   Copyright 1984-2002 The MathWorks, Inc.
