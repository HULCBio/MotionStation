% STRFIND   ������̂̒��̕����̌��o
% 
% K = STRFIND(TEXT,PATTERN) �́A������ TEXT �̒��ŁA���� PATTERN ���o��
% ����ŏ��̃C���f�b�N�X���o�͂��܂��B
%
% STRFIND �́APATTERN �� TEXT ���������ꍇ�́A��� [] ���o�͂��܂��B
% S2 �̒��� S1���A���邢�́AS1 �̒��� S2 ���܂܂�Ă���ꍇ�̌��o�ɂ́A
% FINDSTR ���g���Ă��������B
%
% ���F
%       s = 'How much wood would a woodchuck chuck?';
%       strfind(s,'a')    �́A21���o�͂��܂��B
%       strfind('a',s)    �́A[] ���o�͂��܂��B
%       strfind(s,'wood') �́A[10 23] ���o�͂��܂��B
%       strfind(s,'Wood') �́A[] ���o�͂��܂��B
%       strfind(s,' ')    �́A[4 9 14 20 22 32] ���o�͂��܂��B
%
% �Q�l�FFINDSTR, STRFIND, STRCMP, STRNCMP, STRMATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:07:10 $
%   Built-in function.

