% FINDSTR   ����̕�������ɂ��镶����̌��o
%  
% K = FINDSTR(S1,S2) �́A2�̕�������̒�����������ŁA�ݒ肵������
% �܂��͕����񂪕\�����ʒu�̃C���f�b�N�X���o�͂��܂��B
%
% FINDSTR �́A2�̈������őΏ̂ł��B�܂�AS1 �܂��� S2 �́A����������
% ���ŃT�[�`�����Z���p�^�[���ł���ꍇ������܂��B���̋�����]�܂Ȃ�
% �ꍇ�́A����� STRFIND �𗘗p���Ă��������B
%
% ���
% 
%     s = 'How much wood would a woodchuck chuck?';
%     findstr(s,'a') �́A21���o�͂��܂��B
%     findstr(s,'wood') �́A[10 23] ���o�͂��܂��B
%     findstr(s,'Wood') �́A[] ���o�͂��܂��B
%     findstr(s,' ') �́A[4 9 14 20 22 32] ���o�͂��܂��B
%
% �Q�l�FSTRFIND, STRCMP, STRNCMP, STRMATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:46 $
%   Built-in function.
