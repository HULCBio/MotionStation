% TEXTWRAP   �^����ꂽUI�R���g���[���ɑ΂��ēK�؂ɉ��s���ꂽ������s��
%���o��
%
% OUTSTRING = TEXTWRAP(UIHANDLE,INSTRING) �́A������̃Z���z��
% (OUTSTRING)���o�͂��܂��B����́A�^����ꂽuicontrol�̓����ŁA�K�؂�
% ���s����Ă��܂��B 
%
% OUTSTRING �́A�Z���z�񏑎��̓K�؂ɉ��s���ꂽ������s��ł��B
%
% UIHANDLE �́A�����񂪔z�u�����I�u�W�F�N�g�̃n���h���ԍ��ł��B
%
% INSTRING �́A�Z���z��ł��B�i���̉��s�́A�e�X�̃Z���ɑ΂��Ď��������
% ���܂��B�z��̊e�Z���́A�e�X�̒i���ƍl�����A������x�N�g���݂̂�
% �܂܂Ȃ���΂Ȃ�܂���B�i�����L�����b�W���^�[���ŋ�؂��Ă���ꍇ�́A
% TEXTWRAP �̓L�����b�W���^�[���Œi���̍s�����s���܂��B
%
% OUTSTRING = TEXTWRAP(INSTRING�ACOLS) �́A�i�����L�����b�W���^�[��
% �ŋ�؂��Ă��Ȃ���΁A�s�� COLS �̈ʒu�ŉ��s����Ă���A������̃Z��
% �z����o�͂��܂��B�i���ɁA�L�����N�^ COLS ���Ȃ��ꍇ�́A�i�����̃e�L�X�g
% �͉��s���܂���B 
% 
% ���̊֐��́A���̂悤�ɌĂяo�����Ƃ��ł��܂��B
% 
%    [OUTSTRING,POSITION] = TEXTWRAP(UIHANDLE,INSTRING)
% 
% �����ŁAPOSITION�́Auicontrol�̐��������ʒu�ŁAuicontrol�̒P�ʂ�
% �\�킳��܂��B
% [OUTSTRING,POSITION] = TEXTWRAP(UIHANDLE,INSTRING,COLS)���@�\���܂��B
% ���̏ꍇ�AOUTSTRING �� COLS �ŉ��s����A���������ʒu���o�͂���܂��B


%  Loren Dean 
%   Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $
