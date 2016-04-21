% REGEXPI   �ꍇ�ɂ��Ȃ����K�\���̈�v
%
% START = REGEXPI(STRING,EXPRESSION) �́A�ꍇ�ɂ�����炸�A���K�\����
% ������ EXPRESSION �ƈ�v���� STRING ���̕���������̃C���f�b�N�X����
% �ލs�x�N�g�� START ���o�͂��܂��B
%
% EXPRESSION ���̈ȉ��̃V���{���́A����̈Ӗ��������܂�:
%
%              �V���{��  �Ӗ�
%              --------  --------------------------------
%                  ^     �����̎n�܂�
%                  $     �����̍Ō�
%                  .     �C�ӂ̃L�����N�^
%                  \     ���̕�����̈��p
%                  *     0��ȏ�ň�v
%                  +     1��ȏ�ň�v���邩�A���ׂĈ�v
%                  ?     0��A�܂���1��ȏ��v���邩�A�ŏ��񐔂ň�v
%                  {}    ����͈͂ň�v
%                  []    �L�����N�^�̐ݒ�
%                  [^]   �L�����N�^�̐ݒ������
%                  ()    �O���[�v�̕������K�\��
%                  |     �O�̃T�u�\���A�܂��͌�̃T�u�\���ƈ�v
%                  \w    �P��ƈ�v [a-z_A-Z0-9]
%                  \W    �P��łȂ����� [^a-z_A-Z0-9]
%                  \d    �����ƈ�v [0-9]
%                  \D    �����łȂ����� [^0-9]
%                  \s    �󔒂ƈ�v [ \t\r\n\f]
%                  \S    �󔒂łȂ����� [^ \t\r\n\f]
%             <WORD\>    ���m�ɒP��ƈ�v
%
% ���
%      str = 'My flowers may bloom in May';
%      pat = 'm\w*y';
%      regexpi(str, pat)
%         �o�͂́A[1 12 25] �ł��B
%
%      ����́A�ꍇ�ɂ�����炸�Am �Ŏn�܂��� y �ŏI���P��Ɉ�v����
%      �C���f�b�N�X�̍s�x�N�g���ɂȂ�܂��B
%
% STRING �܂��́AEXPRESSION �́A������̃Z���z��̂����ꂩ�ł���ꍇ�A
% REGEXPI �́A�C���f�b�N�X�̍s�x�N�g���� M�~N �̃Z���z����o�͂��܂��B
%
% STRING��EXPRESSION�̗����������񂩂�Ȃ�Z���z��̏ꍇ�AREGEXPI �́A
% STRING��EXPRESSION�̃V�[�P���V�����Ɉ�v����v�f�̃C���f�b�N�X�̍s�x�N
% �g������Ȃ�Z���z����o�͂��܂��BSTRING��EXPRESSION�̗v�f���́A��v
% ���Ȃ���΂Ȃ�܂���B
%
% [START,FINISH] = REGEXPI(STRING,EXPRESSION) �́ASTART ���̕���������
% �ɑΉ�����Ō�̃L�����N�^�̃C���f�b�N�X���܂ޕt���I�ȍs�x�N�g��
% FINISH ���o�͂��܂��B
%
% [START,FINISH,TOKENS] = REGEXPI(STRING,EXPRESSION) �́ASTART ����� 
% FINISH ���̕���������ɑΉ�����͈͓��̕�����̏W��(�g�[�N��)�̎n��
% ��ƏI���̃C���f�b�N�X�ł��� 1�~N �̃Z���z�� TOKENS ���o�͂��܂��B
% �g�[�N���́AEXPRESSION ���̊��ʂɂ���Ď�����܂��B
%
% �f�t�H���g�ł́AREGEXPI �́A��v������̂����ׂďo�͂��܂��B�ŏ��Ɉ�
% �v�������������o����ɂ́AREGEXPI(STRING,EXPRESSION,'once') ���g�p��
% �Ă��������B��v������̂�������Ȃ��ꍇ�ASTART�AFINISH�A����� 
% TOKENS �́A��ɂȂ�܂��B
%
% MATCH = REGEXPI(STRING, EXPRESSION, 'match') �́AEXPRESSION�ɂ��
% ��v���镔�������񂩂�Ȃ�Z���z����o�͂��܂��B
%
% MATCH = REGEXPI(STRING, EXPRESSION, 'match', 'once') �́AEXPRESSION
% �ɂ���v���镔����������o�͂��܂��B
%
% TOKENS = REGEXPI(STRING, EXPRESSION, 'tokens') �́AEXPRESSION�̊���
% �t���̕����\���ɂ���v���镔��������̃Z���z�񂩂�Ȃ�Z���z����o��
% ���܂��B
%
% TOKENS = REGEXPI(STRING, EXPRESSION, 'tokens', 'once') �́AEXPRESSION
% �̊��ʕt�������\���ɂ���v���镔�������񂩂�Ȃ�Z���z����o�͂��܂��B
%
% NAMES = REGEXPI(STRING, EXPRESSION, 'names') �́AEXPRESSION�̎w�肳��
% ���g�[�N���ƈ�v���镔�������񂩂�Ȃ�struct�z����o�͂��܂��B�w�肵��
% �g�[�N���́A�p�^�[��(?<name>...)�ɂ�莦����܂��B�estruct�́A
% EXPRESSION���̎w�肳�ꂽ�g�[�N���ɑΉ�����t�B�[���h�������A������
% �t�B�[���h�́AEXPRESSION���̎w�肳�ꂽ�g�[�N���ƈ�v���镔�����������
% �݂܂��B
%
% REGEXPI �́Ainternational character sets ���T�|�[�g���Ă��܂���B
%
% �Q�l:  REGEXP, REGEXPREP, STRCMPI, STRFIND, FINDSTR, STRMATCH.
%



%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:06:59 $
