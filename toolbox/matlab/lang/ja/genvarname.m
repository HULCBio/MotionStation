%GENVARNAME �^����炽��₩�琳���� MATLAB �ϐ������\�����܂�
% VARNAME = GENVARNAME(CANDIDATE) �́A������ CANDIDATE ����\�����ꂽ
% �������ϐ��� VARNAME���o�͂��܂��BCANDIDATE �́A������܂��͕������
% �Z���z��ɂȂ邱�Ƃ��ł��܂��B
%
% ������ MATLAB �ϐ����́A�ŏ��̃L�����N�^�������ŁA������̒�����
% <= NAMELENGTHMAX �ł���悤�ȁA�����A�����A�A���_�[�X�R�A��
% ������ł��B
%
% CANDIDATE ��������̃Z���z��ł���ꍇ�AVARNAME �ɏo�͂���錋�ʂ�
% ������̃Z���z��́A�݂��Ɉ�ӓI�ł��邱�Ƃ��ۏ؂���܂��B 
%
% VARNAME = GENVARNAME(CANDIDATE, PROTECTED) �́APROTECTED �̖��O���X�g
% �����ӓI�ł��鐳�����ϐ�����Ԃ��܂��BPROTECTED �́A������܂���
% ������̃Z���z��ɂȂ�܂��B
%
% ���:
%     genvarname({'file','file'})     % {'file','file1'} ���o��
%     a.(genvarname(' field#')) = 1   %  a.field0x23 = 1 ���o��
%
%     okName = true;
%     genvarname('ok name',who)       % ������ 'okName1' ���o��
%
% �Q�l ISVARNAME, ISKEYWORD, ISLETTER, NAMELENGTHMAX, WHO, REGEXP.

%   Copyright 1984-2003 The MathWorks, Inc.
