% IDPOLGET �́Aidpoly �̕⏕�֐��ł��B 
% IDPOLGET �́AIDSS ���f���Ɠ����� IDPOLY ���쐬���A.Utility.Idpoly �ɃX
% �g�A���܂��B
% 
%   [idpol, sys1, flag] = IDPOLGET(sys,noises,ts)
%
%   idpol        : IDPOLY ���f���̔z��A�e�o�͂Ɉ��
%          
%   sys1         : sys1.Utility.Idpoly �ɃX�g�A����Ă��� idpol ������ 
%                  sys�A�����́Anoisecnv(sys) �ɑ΂��Čv�Z����܂��B
%   flag = 1     �FIDPOLY ���f�����A�O�Ɍv�Z����Ă��Ȃ��ꍇ
%
%   noises = 'g' : ���ׂẴm�C�Y�������͂Ƃ��Ď�舵���A�����̊Ԃ�
%                  ���ւ��v�Z����܂��B
%   noises = 'd' : �m�C�Y�t�B���^ H �͑Ίp�ł���ƁA���肵�Ă��܂��B
%
%   ab = 'a' �̏ꍇ�Aidpolget �́Anoisecnv(sys,'norm') �ɑΉ����� IDPOLY
%        ���f�����o�͂��܂��B
%        - �m�C�Y����舵�� (�f�t�H���g)
%   ab = 'b' �̏ꍇ�Aidpolget �́Anoisecnv(sys) �ɑΉ����� IDPOLY ���f��
%        ���o�͂��܂��B
%        - �m�C�Y����舵���B��҂́Asys1.Utility.Idpolyboth �ɃX�g�A����
%          �܂��B



%   Copyright 1986-2001 The MathWorks, Inc.
