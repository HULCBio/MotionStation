%PROFILE �v���t�@�C���֐����s����
% PROFILE ON �́A�v���t�@�C�����J�n���A����ȑO�ɋL�^���ꂽ�v���t�@�C��
% �̓��v���N���A���܂��B
%
% PROFILE ON �ɁA-HISTORY �I�v�V�����𑱂��邱�Ƃ��ł��܂��B
%
% -HISTORY
% ���̃I�v�V�������w�肳�ꂽ�ꍇ�A�֐��Ăяo���������|�[�g����������
% ��悤�Ȋ֐��Ăяo���̐��m�ȃV�[�P���X���L�^���܂��B���ӁFMATLAB�́A
% 10000���������̊֐���I���C�x���g���L�^���܂���B������MATLAB�́A
% ���̂悤�Ȑ������z���Ă��A���̃v���t�@�C���̓��v�ʂ͋L�^�������܂��B
%
% PROFILE OFF  �́A�v���t�@�C���̎��s�𒆎~���܂��B
%
% PROFILE VIEWER �́A�v���t�@�C���𒆎~���A�O���t�B�J���ȃv���t�@�C��
% �u���E�U���J���܂��BPROFILE VIEWER �ɑ΂���o�͂́A�v���t�@�C���E�B
% ���h�E����HTML�t�@�C���ł��B�֐��̃v���t�@�C���y�[�W�̉��Ƀ��X�g����
% ���t�@�C���́A�R�[�h�̊e�s�̍�������4�̗�Ƃ��Ď�����܂��B
%       �� 1 (��) �́A���C���ɔ�₳�ꂽ���Ԃ̍��v(s)�ł��B
%       �� 2 (��) �́A���C�����R�[�����鐔�ł��B
%       �� 3 �́A���C���ԍ��ł�
%
% PROFILE RESUME �́A����ȑO�ɋL�^���ꂽ�֐��̓��v�ʂ��N���A���Ȃ��ŁA
% �v���t�@�C�����ăX�^�[�g���܂��B
%
% PROFILE CLEAR �́A���ׂĂ̋L�^���ꂽ�v���t�@�C�����v�ʂ��N���A���܂��B
%
% S = PROFILE('STATUS') �́A�J�����g�̃v���t�@�C����ԂɊւ�����
% ���܂ލ\���̂��o�͂��܂��BS �́A���̃t�B�[���h���܂݂܂��B
%
%       ProfilerStatus   -- 'on' �܂��� 'off'
%       DetailLevel      -- 'mmex', �܂��� 'builtin'
%       HistoryTracking  -- 'on' �܂��� 'off'
%
% STATS = PROFILE('INFO') �́A�v���t�@�C�����~���A�J�����g�̃v���t�@�C��
% ���v�ʂ��܂ލ\���̂��o�͂��܂��B
% STATS �́A���̃t�B�[���h���܂݂܂��B
%
%       FunctionTable    -- �Ăт����ꂽ�֐��ɂ��Ă̓��v���܂ލ\���̔z��
%       FunctionHistory  -- �֐��Ăяo�������e�[�u��
%       ClockPrecision   -- �v���t�@�C�����ԑ���̐��x
%       ClockSpeed       -- cpu�̐���N���b�N���x(���邢��0)
%       Name             -- �v���t�@�C���̖��O(���Ƃ��΁AMATLAB)
%
% FunctionTable �z��́ASTATS �\���̂̍ł��d�v�ȕ����ł��B���̃t�B�[���h�́A
% ���̂��̂ł��B
%
%       FunctionName     -- �T�u�֐����t�@�����X���܂ށA�֐���
%       FileName         -- �t�@�C�����́A���S�ɏ����̍������p�X�ł�
%       Type             -- M-�t�@���N�V�����AMEX-�t�@���N�V����
%       NumCalls         -- ���̊֐����Ăяo����鎞�Ԑ�
%       TotalTime        -- ���̊֐��ɔ�₳��鎞�Ԃ̍��v
%       Children         -- FunctionTable �́Achild �֐��ɃC���f�b�N�X��t���܂�
%       Parents          -- FunctionTable �́Aparent �֐��ɃC���f�b�N�X��t���܂�
%       ExecutedLines    -- ���C�����̏ڍׂ���舵���z�� (���L�Q��)
%       IsRecursive      -- �֐����ċA�I�ł��邩�ǂ������肷��u�[���A���l
%
% ExecutedLines �z��ɂ́A�������̗񂪂���܂��B�� 1 �́A���s�����
% ���C�����ł��B���C�������s����Ȃ������ꍇ�ɂ́A���̍s��Ɍ���܂���B
% �� 2 �́A���s���ꂽ���Ԑ��ł��B�� 3 �́A���̃��C���ɔ�₳�ꂽ���Ԃ�
% ���v�ł��B����: �� 3 �̘a�́A�K�������֐��� TotalTime �܂ŉ������܂���B
%
% ���:
%
%       profile on
%       plot(magic(35))
%       profile viewer
%
%       profile on -history
%       plot(magic(4));
%       p = profile('info');
%       for n = 1:size(p.FunctionHistory,2)
%           if p.FunctionHistory(1,n)==0
%               str = 'entering function: ';
%           else
%               str = ' exiting function: ';
%           end
%           disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName]);
%       end
%
% �Q�l PROFVIEW.

%   Copyright 1984-2003 The MathWorks, Inc. 
