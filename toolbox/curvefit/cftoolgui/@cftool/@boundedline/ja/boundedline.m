% BOUNDEDLINE �M���͈͂��܂񂾊֐����C�����쐬
% H = BOUNDEDLINE(FUN) �́A�֐� FUN ���x�[�X�ɂ������C�����쐬���܂��B
% FUN �́A�x�N�g�� X ����͂��āAX �Őݒ肵���_�Ōv�Z���� FUN �̒l��v
% �f�Ƃ���x�N�g�����o�͂��܂��B
%
% H = BOUNDEDLINE(FUN,SHOWBOUNDS,CONFLEVEL,DFE) �́A�M���͈͂��R���g��
% �[�����܂��BSHOWBOUNDS �� 'on'(�f�t�H���g)�Ɛݒ肷��ƁA�͈͂��\����
% ��A'off'�̏ꍇ�͔�\���ɂȂ�܂��BCONFLEVEL �́A�M�����x����ݒ肷��
% ���̂ŁA�f�t�H���g�́A0.95 �ł��BDFE �́A�덷�ɑ΂��鎩�R�x�ŁA�f�t�H
% ���g�́AInf �ł��B
%
% H = BOUNDEDLINE(FUN,...,'-userargs',{P1,P2,...}) ���g���āA���[�U�ݒ�
% �̈������AFUN �ɓn�����Ƃ��ł��܂��B�����̐ݒ�́A�J���}�ŕ��������^��
% �ݒ肵�܂��B���Ƃ��΁A���̂悤�ɂ��܂��B
% 
%    feval(FUN,X,P1,P2,...).
%
% H = BOUNDEDLINE(FUN,...,'String','STR') �́AString �v���p�e�B�̏����l��
% 'STR' �Őݒ肵�܂��B
%
% H = BOUNDEDLINE(FUN,...,PROP1,VALUE1,PROP2,VALUE2,...) �́A�^����ꂽ�l
% �ɐݒ肳�ꂽ�v���p�e�B�������C�����쐬���܂��B���Ƃ��΁A'color', 'b' 
% �̂悤�ȃy�A�Őݒ肵�܂��B

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
