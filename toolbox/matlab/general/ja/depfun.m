%DEPFUN  M/P-�t�@�C���̉e������֐��̈ʒu
% TRACE_LIST = DEPFUN(FUN) �́AFUN �̏]���֐����̃Z���z����o�͂��܂��B
% FUN �́A�R�[������֐��ɒ��ڊ֗^���܂��B���Ȃ킿�AFUN �́AFUN ���R�[��
% �����֐��ɂ��R�[�������֐��ȂǂɁA���ړI�ɂ͊֗^���܂���B
% ���M�������Ɋ�Â��A�t�@�C������͂���A�I������܂��B
% �ʏ퐶������� TRACE_LIST �́AFUN �����ۂɕ]������Ă��R�[������Ȃ�
% 'extra' �t�@�C�����܂݂܂��B�t�@�C���́A�I���W�i���̈����ɂ��
% ���X�g����A�ǉ��̏]���t�@�C���̕��בւ���ꂽ���X�g�������܂��B 
% �������ꂽ�����t�@�C���́A�ŏI���X�g���珜����܂���B
% �X�N���v�g M-�t�@�C���͊܂܂�܂����A��͂���܂���B
%
% MATLABPATH ���A'���ΓI��' �f�B���N�g�����܂ޏꍇ�A�����̃f�B���N�g����
% �t�@�C���͂������ '���ΓI��' �p�X�������܂��B
%
% [TRACE_LIST, BUILTINS, MATLAB_CLASSES] = DEPFUN(FUN) �́AFUN �₻���
% �]������֐��ɂ���ăR�[������邷�ׂĂ� MATLAB �g�ݍ��݊֐��� MATLAB 
% �N���X�̃Z���z����o�͂��܂��B
%
% ���ׂẲ\�ȏo�͈����������� DEPFUN �ɑ΂���V���^�b�N�X�������܂��B
%    [TRACE_LIST, BUILTINS, MATLAB_CLASSES, PROB_FILES, PROB_SYMBOLS,...
%                EVAL_STRINGS, CALLED_FROM, OPAQUE_CLASSES] = DEPFUN(FUN)
% �����ŁA�����͂��̈Ӗ��������Ă��܂��B
%
% PROB_FILES �́ADEPFUN �����߁A�z�u�A�A�N�Z�X�ł��Ȃ� M/P �t�@�C���̍\
% ���̔z��ł��B���߂Ɋւ�����_�́AMATLAB �̃V���^�b�N�X�G���[�̌���
% �ɂȂ�܂��B
% �\���̂̃t�B�[���h�́A���̂��̂ɂȂ邱�Ƃ��ł��܂��B
%
%          .name       - �t�@�C���ւ̃p�X
%          .listindex  - trace_list �C���f�b�N�X
%          .errmsg     - �G���[���b�Z�[�W������
%
% PROB_SYMBOLS [NOT IMPLEMENTED] �́A���̃V���{���� DEPFUN ���A�֐��A�܂��́A
% �ϐ��Ƃ��ĉ������Ƃ��ł��Ȃ����Ƃ������\���̔z��ł��B
% �\���̂̃t�B�[���h�́A���̂��̂ɂȂ邱�Ƃ��ł��܂��B     
%
%          .name       - �V���{����
%          .fcn_id     - trace_list �C���f�b�N�X��double�̔z��
%
% EVAL_STRINGS [NOT IMPLEMENTED] �́ATRACE_LIST �̒��̊֐����A eval, evalc, 
% evalin, feval �����R�[�����Ă���ꏊ�������\���̔z��ł��Beval �₻���
% ���l�Ȋ֐����]�����镶����́ATRACE_LIST �̒��ɑ��݂��Ȃ��֐����g�p���܂��B
% �\���̂̃t�B�[���h�́A���̂��̂ɂȂ邱�Ƃ��ł��܂��B
%
%          .fcn_name   - �t�@�C���̃p�X
%          .lineno     - �t�@�C���̃��C���ԍ���double�̔z��
%
% CALLED_FROM �́A�e�v�f�� double�̔z��̃Z���z��ł���A���ꂪ�֐����R�[��
% ���邩�������܂��BCALLED_FROM �́A TRACE_LIST(CALLED_FROM{i}) ��
% TRACE_LIST{i} ���R�[������ FUN �̂��ׂĂ̊֐������X�g����悤�ɔz��
% ����܂��BCALLED_FROM �� TRACE_LIST �́A���������ł��B ���double�̔z��́A
% trace_list �t�@�C�����Q�Ƃ���Ȃ������t�@�C���ł���A�܂��́A�I��
% �ɒǉ������Q�Ƃ���Ȃ� 'special' �t�@�C���ł��邱�Ƃ��Ӗ����܂��B
%
% OPAQUE_CLASSES �́A TRACE_LIST �̒���1�܂��͕����̃t�@�C���ɂ��g�p�����
% Java ����� COM �N���X�����܂� 'opaque' �N���X���̃Z���z��ł��B
%
% [...] = DEPFUN(FILE1,FILE2,...) �́A���ԂɌX�̃t�@�C�����������܂��B
% FILEN �́A�t�@�C���̃Z���z��ɂȂ邱�Ƃ��ł��܂��B
%
% [...] = DEPFUN(FIG_FILE) �́A.FIG  �t�@�C�� FIG_FILE �̒��ɒ�`����Ă���
% GUI �̃R�[���o�b�N������̊ԂŁA�]���֐���T�����܂��B
%
% DEPFUN �́A�I�v�V�����̃R���g���[�����͕�����������Ă��܂��B
%
%    '-toponly' 	�]������t�@�C���ɑ΂��ăf�t�H���g�̃��J�[�V�u
%                       �ȃT�[�`��ύX���A����ɂ��DEPFUN �́A�g�ݍ�
%                       �݁AM/P/MEX �t�@�C����ADEPFUN �ւ̓��͂Ƃ���
%                       ���X�g����Ă���֐����ł̂ݎg����N���X��
%                       �ꗗ���o�͂��邱�Ƃ��Ӗ����܂��B
%    '-verbose'		�ǉ��̓������b�Z�[�W���o�͂��܂��B
%    '-quiet'           �T�v�̏o�͂��s���܂���B �G���[���b�Z�[�W�A
%                       ���[�j���O���b�Z�[�W�̂ݏo�͂��܂��B�f�t�H���g
%                       �ł́A�T�v�̃��|�[�g���R�}���h�E�B���h�E�ɕ\��
%                       ����܂��B
%    '-print','file'    �t�@�C���Ƀt�����|�[�g���o�͂��܂��B
%    '-all'             ���p�\�Ȃ��ׂĂ̍��ӂ��v�Z���A���|�[�g��
%                       ���ʂ�\�����܂��B�w�肵�������̂ݏo�͂��܂��B
%    '-notrace'		�I���W�i���̈����ȊO�Ƀg���[�X���o�͂��܂���B
%			�p�X�ɂ���ꍇ�A.fig �t�@�C���ɑ΂���R�[���o�b�N
%                       ���������܂��B
%    '-expand'		�R�[�����ꂽ���́A�܂��� �R�[�����X�g�̃C���f�b�N�X
%                       �ƂƂ��Ƀt���p�X���w�肵�܂�
%    '-calltree'	���X�g�̑���ɃR�[�����X�g���o�͂��܂��B
%			����́A�R�[�����ꂽ���̂̃��X�g����]���ȃX�e�b�v��
%			���ē����܂��B
%
%    Output:
%
%      Summary:
%
%        ==========================================================
%        depfun report summary:
%
%          or
%
%        depfun report summary: (top only)
%        ----------------------------------------------------------
%        -> trace list:       ### files  (total)
%			      ### files  (total arguments)
%                             ### files  (arguments off MATLABPATH)
%                             ### files  (argument duplicates on MATLABPATH)
%                             ### files  (argument duplicates off MATLABPATH)
%        -> builtin list:     ### names
%        -> MATLAB classes:   ### names  (builtin, MATLAB OOPS)
%        -> problem list:     ### files  (argument)
%                             ### files  (other)
%        -> problem symbols:  NOT IMPLEMENTED
%        -> eval strings:     NOT IMPLEMENTED
%        -> called from list: ### files  (argument unreferenced)
%                             ### files  (argument referenced)
%                             ### files  (other referenced)
%			      ### files  (other unreferenced)
%
%           OR if -calltree is passed
%
%        -> call list:        ### files  (argument with no calls)
%                             ### files  (argument with calls)
%                             ### files  (other with calls)
%			      ### files  (other with no calls)
%        -> opaque classes:   ### names  (Java, etc.)
%        ----------------------------------------------------------
%        Note: 1. Use argument  '-quiet' to not print this summary.
%	       2. Use arguments '-print','file' to produce a full
%                 report in file.
%              3. Use argument  '-all' to display all possible
%                 left hand side arguments in the report(s).
%        ==========================================================
%
%      Full:
%
%        depfun report:
%  
%           or
%
%        depfun report: (top only)
%
%        -> trace list:   
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%
%           OR if called from list is generated then:
%
%           For complete list: See -> called from:
%
%           Files not on MATLABPATH:
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%
%           HG factory callback names:
%           ----------------------------------------------------------
%           ...
%           ----------------------------------------------------------
%  
%        -> builtin list:
%           ----------------------------------------------------------
%           1: <name>
%           ...
%           ----------------------------------------------------------
%  
%        -> MATLAB classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem list:
%           ----------------------------------------------------------
%           #: <file>
%              <message>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem symbols: NOT IMPLEMENTED
%  
%        -> eval strings:    NOT IMPLEMENTED
%  
%        -> called from list: (by trace list)
%
%           OR if -calltree is passed
%
%        -> call list: (by trace list)
%           ----------------------------------------------------------
%           1: <file>
%              <called from (or call) array>
%
%              OR if -expand is passed
%               
%              <called from (or call) array with actual path>
%
%           2: <file>
%              <called from (or call) array>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%  
%        -> opaque classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%
% �Q�l DEPDIR, CKDEPFUN

%    DEPFUN has additional undocumented optional control input strings.
%
%    '-savetmp' 	saves any temporary M-files in the current
%                       directory.
%    '-nosort'		does not sort the dependency files found.
%
%    Copyright 1984-2004 The MathWorks, Inc. 
