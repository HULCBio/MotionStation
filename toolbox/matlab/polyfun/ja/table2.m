% TABLE2   2������table look-up
% 
% Z = TABLE2(TAB,X0,Y0) �́ATAB ��1��ڂ� X0 ��1�s�ڂ� Y0 �𒲂ׁA2����
% �̃e�[�u�� TAB ������`��Ԃ��ꂽ���ʕ������o�͂��܂��BTAB �́A1�s�ڂ�
% 1��ڂɃL�[�̒l���܂݁A�c��̃u���b�N�Ƀf�[�^���܂ލs��ł��B1�s�ڂ�
% 1��ڂ́A�P���֐��łȂ���΂Ȃ�܂���BTAB(1,1) �̃L�[�͖�������܂��B
%
% ���:
%    tab = [NaN 1:4; (1:4)' magic(4)];
%    y = table2(tab,1:4,1:4)
% �́Ay = magic(4) ���o�͂��邽�߂ɂ́A�����̈������@�ł��B
%
% �֐� TABLE2 �͔p�~���ꂽ�֐��Ȃ̂ŁAINTERP2 ���g���Ă��������B
%
% �Q�l�FINTERP2, TABLE1.


%   Paul Travers 7-14-87
%   Revised JNL 3-15-89
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:58 $
