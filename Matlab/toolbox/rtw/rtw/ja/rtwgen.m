% RTWGEN   �u���b�N���}����RTW�t�@�C��(model.rtw)���쐬
%       
% RTWGEN�́ARTW�̍\�z�v���V�W�����痘�p����悤�ɐ݌v����Ă��܂��B�\��
% �́A�����[�X���ɈقȂ�܂��B���ڗ��p����悤�ɂ͐݌v����Ă��܂���B
%
% �\���F 
%   [sfcns,buildInfo] = rtwgen('model','OptionName','OptionValue',...)
%
% �ȉ��̃I�v�V�����̖��O�ƒl�̑g�͗L���ł��B    
%
% 'CaseSensitivity'      : 'on'�܂���'off'���w�肵�܂��B���ʎq�ɂ��ẮA
%                          �啶���Ə������̋�ʂ��s���܂��B�f�t�H���g��
%                          on�ł��B
%
% 'ReservedIdentifiers'  : ������̃Z���z��Ƃ��Ďw�肵�܂��B�����́A
%                          �����Ȏ��ʎq�ł��B
%
% 'StringMappings'       : ����́Amodel.rtw�t�@�C������Name�̒l�ɑ΂���
%                          ������}�b�s���O�e�[�u����^���镶����̃Z��
%                          �z��ł��B���Ƃ��΁A{sprintf('\n'),' '} �́A
%                          �j���[���C�����󔒃L�����N�^�ɕϊ����܂��B
%
% 'WriteBlockConnections': 'true'�A�܂��́A'false'���w�肵�܂��B'true'��
%                          �w�肷��ƁAconnections���R�[�h��s-function�u
%                          ���b�N�݂̂łȂ��S�Ẵu���b�N�ɑ΂��āA����
%                          �o���܂��B�܂��ADirectFeedThrough�̐ݒ�́A�u
%                          ���b�N���͂ɑ΂��ď����o����܂��B
%
% 'SrcWorkspace'         : 'base', 'current'�܂���'parent'���w�肵�܂��B
%                          ����́Artwgen�ɑ΂��郏�[�N�X�y�[�X�ł��B
%	
% 'OutputDirectory'      : model.rtw�t�@�C����u���ʒu�B
%
% 'Language'             : 'C', 'Ada', 'none'���w�肳��܂��B�f�t�H���g
%                           ��'C'�ł��B������w�肵�āA�\�񂳂�Ă��鎯
%                           �ʎq�ƕ�����̊��蓖�Ẵf�t�H���g�̃��X�g��
%                           ���̌���ɑ΂��čs���܂��B
%     ReservedIdentsForC:
%   ['auto',      'break',       'case',    'char',      'const',
%    'continue',  'default',     'do',      'double',    'else',
%    'enum',      'extern',      'float',   'for',       'goto',
%    'if',        'int',         'long',    'register',  'return',
%    'short',     'signed',      'sizeof',  'static',    'struct',
%    'switch',    'typedef',     'union',   'unsigned',  'void',
%    'volatile',  'while',       'fortran', 'asm',       'Vector',
%    'Matrix',    'rtInf',       'Inf',     'inf',       'rtMinusInf',
%    'rtNaN',     'NaN',         'nan',     'rtInfi',    'Infi',
%    'infi',      'rtMinusInfi', 'rtNaNi',  'NaNi',      'nani'
%    'TRUE',      'FALSE']
%     ReservedIdentsForAda:
%   ['abort',     'abs',         'abstract','accept',    'access',
%    'aliased',   'all',         'and',     'array',     'at',
%    'begin',     'body',        'case',    'constant',  'declare',
%    'delay',     'delta',       'digits',  'do',        'else',
%    'elsif',     'end',         'entry',   'exception', 'exit',
%    'for',       'function',    'generic', 'goto',      'if',
%    'in',        'is',          'limited', 'loop',      'mod',
%    'new',       'not',         'null',    'of',        'or',
%    'others',    'out',         'package', 'pragma',    'private',
%    'procedure', 'protected',   'raise',   'range',     'record',
%    'rem',       'renames',     'requeue', 'return',    'reverse',
%    'select',    'separate',    'subtype', 'tagged',    'task',
%    'terminate', 'then',        'type',    'until',     'use',
%    'when',      'while',       'with',    'xor',       'Vector',
%    'Matrix',    'rtInf',       'Inf',     'inf',       'rtMinusInf',
%    'rtNaN',     'NaN',         'nan',     'rtInfi',    'Infi',
%    'infi',      'rtMinusInfi', 'rtNaNi',  'NaNi',      'nani',
%    'integer',   'boolean',     'float'}
%    StringMappings:
%    ['\n',' ', '/*','/+', '*/','+/']
%
% �o�͈���
% ----------------
% �ŏ��̏o�͈���sfcns�́A���f�����̑S�Ă�S-function�̃��X�g���܂ރZ���z
% ��ł��B�e�v�f�́A����2�܂���3�̃Z���ŁA1�Ԗڂ̗v�f��S-function�u���b
% �N�̃n���h���ŁA2�Ԗڂ̗v�f��S-function���ŁA�I�v�V������3�Ԗڂ̗v�f��
% S-function ���A�C�����C��������Ă���ꍇ�A(1.0)��ݒ肵�A�I�v�V������
% 4�Ԗڂ̗v�f�́A�����N����K�v������S-function���W���[���ł��B
%
% ��2�o�͈���buildInfo�́A���f���ɑ΂���build�̏����܂ރZ���ł��B
% 
%       {modulesAndNoninlinedSFcns, tlcIncDirs, numStateflowSFcns}
% 
% 1�Ԗڂ̗v�f�́A��C�����C����S-function���Ƃ��̑��̃��W���[����(��ӓI
% ��)���X�g�ł��BPC�ł́A1�Ԗڂ̗v�f�͏������̖��O�݂̂ƂȂ�܂��B2�Ԗ�
% �̗v�f�́A(S-function�ɑ΂���.tlc�t�@�C��������)TLC�̃C���N���[�h�p�X
% �ɑ΂��ėp������f�B���N�g����(��ӓI��)���X�g�ł��B3�Ԗڂ̗v�f�́A
% Stateflow S-function�̐��ł��B
%

%       Copyright 1994-2001 The MathWorks, Inc.

