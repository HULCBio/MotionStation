% TABLE1   1������table look-up
% 
% Y = TABLE1(TAB,X0) �́ATAB ��1��ڂ� X0 �𒲂ׁA�e�[�u�� TAB ������`
% ��Ԃ��ꂽ�s�̃e�[�u�����o�͂��܂��BTAB �́A1��ڂɃL�[�̒l���܂݁A
% �c��̗�Ƀf�[�^���܂ލs��ł��BTAB �̕�Ԃ��ꂽ�s�́AX0 �̊e�v�f��
% �΂��ďo�͂���܂��BTAB ��1��ڂ́A�P���֐��łȂ���΂Ȃ�܂���B
%
% ���:
%    tab = [(1:4)' magic(4)];
%    y = table1(tab,1:4);
% �́Ay = magic(4) ���o�͂��邽�߂ɂ́A�����̈������@�ł��B
%
% �֐� TABLE1 �͔p�~���ꂽ�֐��Ȃ̂ŁAINTERP1 �܂��� INTERP1Q ���g����
% ���������B
%
% �Q�l�FINTERP1, INTERP2, TABLE2.


%   Tomas Schoenthal 5-1-85
%   Egbert Kankeleit 1-15-87
%   Revised by L. Shure 2-3-87
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:57 $
