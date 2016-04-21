% REGEXPREP   ���K�\�����g���ĕ�����̒u������
%
% S = REGEXPREP(STRING,EXPRESSION,REPLACE) �́ASTRING ���̕�����̐��K
% �\�� EXPRESSION �ɑ���������̂��ׂĂ𕶎��� REPLACE �ɒu�������܂��B
% �V����������Ƃ��ďo�͂���܂��BREGEXPREP �Ɉ�v������̂��������
% ���ꍇ�ASTRING �͕ύX���ꂸ�ɏo�͂���܂��B
%
% STRING�AEXPRESSION �܂��́AREPLACE ���A�C�ӂ̕�����̃Z���z��ł���
% �ꍇ�AREGEXPREP �́AL�~M�~N �̕�����̃Z���z����o�͂��܂��B�����ŁA
% L �́ASTRING ���̕�����̐��AM �́AEXPRESSION ���̐��K�\���̐��AN ��
% REPLACE ���̕�����̐��ł��B
%
% �f�t�H���g�ŁAREGEXPREP �́A�啶���A���������ׂĂɈ�v���镶�����
% �u�������A������̏W��(�g�[�N��)���g�p���܂���B�\�ȃI�v�V������
% �ȉ��̂Ƃ���ł��B
%
%      'ignorecase'   - EXPRESSION ���ASTRING �Ɉ�v����L�����N�^��
%                       �ꍇ�͖������܂��B
%      'preservecase' - ('ignorecase' �ɂ��)�A��v����ꍇ�͖������܂����A
%                       �u��������Ƃ��ɁASTRING ���ɑΉ�����L�����N�^��
%                       �ꍇ�́AREPLACE �L�����N�^���㏑���������܂��B
%      'once'         - STRING ���� EXPRESSION �ɍŏ��ɑ������镶����
%                       �̂ݒu�������܂��B
%      N              - STRING ���� EXPRESSION �ɑ������� N�Ԗڂ̕�����
%                       �̂ݒu�������܂��B
%
% REGEXPREP �́Ainternational character sets ���T�|�[�g���Ă��܂���B
%
% ���:
%    str = 'My flowers may bloom in May';
%    pat = 'm(\w*)y';
%    regexprep(str, pat, 'April')
%       �o�͂́A'My flowers April bloom in May' �ł��B
%
%    regexprep(str, pat, 'April', 'preservecase')
%       �o�͂́A'April flowers april bloom in April' �ł��B
%
%    str = 'I walk up, they walked up, we are walking up, she walks.'
%    pat = 'walk(\w*) up'
%    regexprep(str, pat, 'ascend$1')
%       �o�͂́A'I ascend, they ascended, we are ascending, she walks.'
%       �ł��B
%
% �Q�l:  REGEXP, REGEXPI, STRREP, STRCMP, STRNCMP, FINDSTR, STRMATCH.


%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:07:00 $
