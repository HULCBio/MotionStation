% DEVAL  �������������̉����v�Z���܂�
%
% SXINT = DEVAL(SOL,XINT) �́A�x�N�g��XINT�̂��ׂĂ̗v�f�ɑ΂���
% �������������̉��������܂��BSOL�́A�����l���\���o(ODE45, 
% ODE23, ODE113, ODE15S, ODE23S, ODE23T, ODE23TB)�A���E�l���
% �\���o(BVP4C)�A�x������������\���o(DDE23)�ɂ���ďo�͂����\��
% �̂ł��AXINT�̗v�f�́A��� [SOl.x(1) SOL.x(end)] ���ɂȂ���΂Ȃ��
% ����B�e I �ɑ΂��āASXINT(:,I) �́AXINT(I) �ɑΉ�������ł��B 
%
% SXINT = DEVAL(SOL,XINT,IDX) �́A��L�̂悤�Ɏ��s���܂����AIDX�Ƀ��X�g
% ���ꂽ�C���f�b�N�X�������̗v�f�݂̂��o�͂��܂��B   
%
% SXINT = DEVAL(XINT,SOL) �� SXINT = DEVAL(XINT,SOL,IDX) �����p�ł��܂��B
%
% [SXINT,SPXINT] = DEVAL(...) �́A��L�̂悤�ɕ]�����܂����A�����Ԃ���
% �������̂P�K���֐��̒l���o�͂��܂��B
%
% ���_���E�l���ɑ΂��āABVP4C ���g�p���ē���ꂽ���́A���E�ŕs�A���ł���
% �\��������܂��B���E�_ XC �ɑ΂��āADEVAL �́AXC �̍��ƉE����̋Ɍ���
% ���ς��o�͂��܂��B�Ɍ��l�𓾂邽�߂ɂ́ADEVAL �̈��� XINT 
% �� XC �����킸���ɏ������A���邢�́A�킸���ɑ傫���ݒ肵�Ă��������B
%
% �Q�l
%    ODE �\���o:  ODE45, ODE23, ODE113, ODE15S, 
%                 ODE23S, ODE23T, ODE23TB, ODE15I 
%    DDE �\���o:  DDE23
%    BVP �\���o:  BVP4C

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
