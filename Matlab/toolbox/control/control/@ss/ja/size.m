% SIZE   LTI���f���̃T�C�Y�Ǝ���
%
% D = SIZE(SYS) �́A
%   * NU ���� NY �o�͂̒P���LTI���f�� SYS �ɑ΂��āA2�v�f�̍s�x�N�g��
%     D = [NY NU]
%   * NU ���� NY �o�͂̒P���LTI���f���� S1*...*Sp �z��ɑ΂��āA
%     �s�x�N�g�� 
%     D = [NY NU S1 S2 ... Sp] ���o�͂��܂��B
% 
% SIZE(SYS) �́A�����t���\�����쐬���܂��B
%
% [NY,NU,S1,...,Sp] = SIZE(SYS) �́A
%   * �o�͐� NY
%   * ���͐� NU 
%   * LTI �z��̃T�C�Y S1,...,Sp (LTI���f�����z��̂Ƃ�)��ʁX�̏o�͈���
%     �ɏo�͂��܂��B���̂悤�ɏo�͂�I�����邱�Ƃ��ł��܂��B
%   NY = SIZE(SYS,1) �́A�o�͐��݂̂��o�͂��܂��B
%   NU = SIZE(SYS,2) �́A���͐��݂̂��o�͂��܂��B
%   Sk = SIZE(SYS,2+k) �́Ak�Ԗڂ�LTI�z��̒������o�͂��܂��B
%
% NS = SIZE(SYS,'order') �́A���f���̎���(��ԋ�ԃ��f���ɑ΂����Ԃ̐�)
% ���o�͂��܂��BLTI�z��̏ꍇ�A���ׂẴ��f�����������������ꍇ�́ANS
% �̓X�J���ŁA���̏ꍇ�́A�e���f�����ɔz��Ŏ������o�͂��܂��B
%
% FRD���f���̏ꍇ�A
% 
%   NF = SIZE(SYS,'freq') 
% 
% �͎��g���_�̐����o�͂��܂��B
% 
% �Q�l : NDIMS, ISEMPTY, ISSISO, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
