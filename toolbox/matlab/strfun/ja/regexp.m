% REGEXP   ���K�\���̈�v
%
% START = REGEXP(STRING,EXPRESSION) �́A���K�\�������� EXPRESSION ��
% ��v���� STRING ���̕���������̃C���f�b�N�X���܂ލs�x�N�g�� START 
% ���o�͂��܂��B
%
% EXPRESSION ���̈ȉ��̃V���{���́A����̈Ӗ��������܂�:
%
%              �V���{��   �Ӗ�
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
%                  |     �O�̕����\���A�܂��͌�̕����\���ƈ�v
%                  \w    �P��ƈ�v [a-z_A-Z0-9]
%                  \W    �P��łȂ����� [^a-z_A-Z0-9]
%                  \d    �����ƈ�v [0-9]
%                  \D    �����łȂ����� [^0-9]
%                  \s    �󔒂ƈ�v [ \t\r\n\f]
%                  \S    �󔒂łȂ����� [^ \t\r\n\f]
%            \<WORD\>    ���m�ɒP��ƈ�v
%
% ���
%      str = 'bat cat can car coat court cut ct caoueouat';
%      pat = 'c[aeiou]+t';
%      regexp(str, pat)
%         �o�͂́A [5 17 28 35] �ł��B
%
%      ����́Ac����n�܂��āAt �ŏI���A���̒���1�܂��͂���ȏ��
%      �ꉹ���܂ޒP��Ɉ�v����C���f�b�N�X�̍s�x�N�g���ɂȂ�܂��B
%
% STRING �܂��� EXPRESSION �̂ǂ��炩��������̃Z���z��ł���ꍇ�A
% REGEXP �́A�C���f�b�N�X�̍s�x�N�g���� M�~N �̃Z���z����o�͂��܂��B
% 
% ���
%    str = {'Madrid, Spain' 'Romeo and Juliet' 'MATLAB is great'};
%    pat = '\s';
%    regexp(str, pat)
%       �o�͂́A{[8]; [6 10]; [7 10]}�ł��B
%
%    STRING��EXPRESSION�̗����������񂩂�Ȃ�Z���z��̏ꍇ�AREGEXP�́A
%    STRING��EXPRESSION�̃V�[�P���V�����Ɉ�v����v�f�̃C���f�b�N�X��
%    ��Ȃ�s�x�N�g���̃Z���z��ł��BSTRING��EXPRESSION�̗v�f���́A��v
%    ���Ȃ���΂Ȃ�܂���B
%
% [START,FINISH] = REGEXP(STRING,EXPRESSION) �́ASTART ���̕���������
% �ɑΉ�����Ō�̃L�����N�^�̃C���f�b�N�X���܂ޕt���I�ȍs�x�N�g��
% FINISH ���o�͂��܂��B
%
% ���
%    str = {'Madrid, Spain' 'Romeo and Juliet' 'MATLAB is great'};
%    pat = {'\s', '\w+', '[A-Z]'};
%    regexp(str, pat)
%       �o�͂́A{[8]; [1 7 11]; [1 2 3 4 5 6]}�ł��B
%
%    ����́A'Madrid, Spain'���̋󔒁A'Romeo and Juliet' ���̑S�P��A
$    'MATLAB is great'���̑啶���ƈ�v����C���f�b�N�X����Ȃ�s�x�N�g
%     ���̃Z���z��ł��B
%
% [START,FINISH] = REGEXP(STRING,EXPRESSION) �́ASTART���̑Ή�����T
% �u������̍Ō�̕����̃C���f�b�N�X���܂ލs�x�N�g��FINISH���o�͂��܂��B
%
% ���
%      str = 'regexp helps you relax';
%      pat = '\w*x\w*';
%      [s,f] = regexp(str, pat)
%         �o�͂́A�ȉ��̂Ƃ���ł��B
%            s = [1 18]
%            f = [6 22]
%
%      ����́A���� x ���܂ޒP������o���܂��B
%
% [START,FINISH,TOKENS] = REGEXP(STRING,EXPRESSION) �́ASTART ����� 
% FINISH ���̕���������ɑΉ�����͈͓��̕�����̏W��(�g�[�N��)�̎n��
% ��ƏI���̃C���f�b�N�X�ł��� 1�~N �̃Z���z�� TOKENS ���o�͂��܂��B
% �g�[�N���́AEXPRESSION ���̊��ʂɂ���Ď�����܂��B
%
% ���
%      str = 'six sides of a hexagon';
%      pat = 's(\w*)s';
%      [s,f,t] = regexp(str, pat)
%         �o�͂́A�ȉ��̂Ƃ���ł��B
%            s = [5]
%            f = [9]
%            t = {[6 8]}
%
%      ����́A���� s ���܂܂ꂽ��������������o���܂��B
%
% �f�t�H���g�ł́AREGEXP �́A���ׂĈ�v������̂��o�͂��܂��B�ŏ��Ɉ�
% �v�������������o����ɂ́AREGEXP(STRING,EXPRESSION,'once') ���g�p��
% �Ă��������B��v������̂�������Ȃ��ꍇ�ASTART�AFINISH�A����� 
% TOKENS �́A��ɂȂ�܂��B
%
% MATCH = REGEXP(STRING, EXPRESSION, 'match') �́AEXPRESSION�ɂ��
% ��v���镔�������񂩂�Ȃ�Z���z����o�͂��܂��B
%
% MATCH = REGEXP(STRING, EXPRESSION, 'match', 'once') �́AEXPRESSION
% �ɂ���v���镔����������o�͂��܂��B
%
% TOKENS = REGEXP(STRING, EXPRESSION, 'tokens') �́AEXPRESSION�̊���
% �t���̕����\���ɂ���v���镔��������̃Z���z�񂩂�Ȃ�Z���z����o��
% ���܂��B
%
% TOKENS = REGEXP(STRING, EXPRESSION, 'tokens', 'once') �́AEXPRESSION
% �̊��ʕt���̕����\���ɂ���v���镔��������̃Z���z����o�͂��܂��B
%
% NAMES = REGEXP(STRING, EXPRESSION, 'names') �́AEXPRESSION�̎w�肳
% �ꂽ�g�[�N���ɂ���v���镔�������񂩂�Ȃ�Z���z����o�͂��܂��B�w��
% �����g�[�N���́A�p�^�[�� (?<name>...)�ɂ�莦����܂��B�estruct�́A
% EXPRESSION���̎w�肳�ꂽ�g�[�N���ɑΉ�����t�B�[���h�������A������
% �t�B�[���h�́AEXPRESSION���̎w�肳�ꂽ�g�[�N���ƈ�v���镔�����������
% �݂܂��B
%
% REGEXP �́Ainternational character sets ���T�|�[�g���Ă��܂���B
%
% �Q�l:  REGEXPI, REGEXPREP, STRCMP, STRFIND, FINDSTR, STRMATCH.



%
%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:06:58 $
