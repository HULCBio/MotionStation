% MODRED   ���f���̏�Ԃ̒᎟����
%
% RSYS = MODRED(SYS,ELIM)�A�܂��́ARSYS = MODRED(SYS,ELIM,'mdc') �́A
% �x�N�g�� ELIM �Ŏw�肳�ꂽ��Ԃ��폜���邱�ƂŁA��ԋ�ԃ��f�� SYS ��
% �᎟�������s���܂��B��ԃx�N�g���́A�c������� X1 �ƍ폜������� 
% X2 �ɕ�������܂��B
%
%    A = |A11  A12|      B = |B1|    C = |C1 C2|
%        |A21  A22|          |B2|
%    .
%    x = Ax + Bu,   y = Cx + Du  (�܂��́A���U���Ԃł̍���������)
%
% X2 �̕ω����̓[���ɐݒ肳��A���ʂ̕������� X1 �ɂ��ĉ�����܂��B
% ���ʂ̃V�X�e���́ALENGTH(ELIM) �������Ȃ���Ԃ������A��� ELIM ������
% �ɑ������肷����̂Ƃ݂Ȃ���܂��B���̃��f���ƒ᎟�������ꂽ���f���́A
% DC�Q�C������v���܂�(�����)�B
%
% RSYS = MODRED(SYS,ELIM,'del') �́A�P�ɏ�� X2 ���폜���܂��B����́A
% �T�^�I�Ɏ��g���̈�ł��ǂ��ߎ��𐶐����܂����ADC �Q�C���̈�v�͕ۏ�
% ����܂���B
%
% SYS �� BALREAL �ŕ��t������A�O���~�A���� M �̏����ȑΊp�v�f�̂���
% �ꍇ�AMODRED �ɂ���čŌ�� M ��Ԃ��폜���邱�Ƃɂ���āA���f����
% �᎟�������܂��B
%
% �Q�l : BALREAL, SS.


%   J.N. Little 9-4-86
%   Revised: P. Gahinet 10-30-96
%   Copyright 1986-2002 The MathWorks, Inc. 
