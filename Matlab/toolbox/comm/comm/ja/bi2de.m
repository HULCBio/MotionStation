% BI2DE �o�C�i���x�N�g����10�i���ɕϊ����܂��B
%
% D = BI2DE(B) �́A�o�C�i���x�N�g�� B ��10�i�� D �ɕϊ����܂��BB ���s��
% �̏ꍇ�A�ϊ��́A�s�����ɏ�������A�o�� D �́A10�i���̗�x�N�g���ł��B
% �o�C�i�����͂̃f�t�H���g�̕����́ARight-MSB �ŁAB �̒��̍ŏ��̗v�f�́A
% �ŉ��ʃr�b�g��\���܂��B
%
% ���͍s��ɉ����āA2�̃I�v�V����������^���邱�Ƃ��ł��܂��B
%
% D = BI2DE(...,P) �́A��� P �̃x�N�g����10�i���l�ɕϊ����܂��B
%
% D = BI2DE(...,FLAG) �́AFLAG ���g���āA���͕��������肵�܂��BFLAG �́A
% 'right-msb'�A�ƁA'left-msb'��2�̒l��ݒ肷�邱�Ƃ��ł��܂��B
% FLAG �� 'right-msb' ��ݒ肷��ƁA�֐��̃f�t�H���g�̋�������ύX����
% �܂���B
% 'left-msb' ��ݒ肷��ƁA���͕������t�ɂȂ�܂��B�܂�MSB�����ƂȂ�܂��B
%
% ���F
%    >> B = [0 0 1 1; 1 0 1 0];
%    >> T = [0 1 1; 2 1 0];
%
%    >> D = bi2de(B)    >> D = bi2de(B,'left-msb')    >> D = bi2de(T,3)
%       D =                D =                           D =
%        12                   3                             12
%         5                  10                              5
%
% �Q�l�F DE2BI.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:34:11 $
