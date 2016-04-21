% [tau,P,S,N] = popov(sys,delta,flag)
%
% ���̊֐��́A�|�|�t�K�͂��g���āA���̑��ݐڑ�
%                   ___________
%                   |         |
%              +----|  Phi(.) |<---+
%              |    |_________|    |
%           w  |                   | y
%              |    ___________    |
%              +--->|         |----+
%                   |   SYS   |
%             ----->|_________|----->
%
%
% ���ADELTA�Őݒ肳�ꂽ�s�m�����N���X�̔C�ӂ̍�p�fPhi�ɑ΂��Ĉ��肩�ǂ�
% �������؂��܂��B���̃N���X�́A�m�����A�܂��́A�Z�N�^�L�E�̔���`�A�܂�
% �́A���ϕs�m�������܂݂܂��B
%
% ���萫�́ATAU < 0�̂Ƃ��B������A���̏ꍇ�APOPOV�́ALyapunov�s��P�ƈ�
% �萫�����؂���搔S��N���o�͂��܂��B
%
% ����:
%  SYS        ���I�V�X�e��(LTISYS���Q��)�B
%  DELTA      �s�m�����N���X�̋L�q(UBLOCK���Q��)�B
%  FLAG       �I�v�V�����B�f�t�H���g��0�ł��BFLAG=1�Ɛݒ肷��ƁA��苭
%             �͂Ȍv�Z�����s���A���p�����[�^�̕s�m�����̕ێ琫���ɘa����
%             ���B
%
% �o��:
%  TAU        �Ή�����LMI����̍œK�ő�ŗL�l�B���o�X�g���萫�́ATAU
%             < 0�̂Ƃ��A���Ȃ킿�APopov�A��LMI�����̂Ƃ��ɕۏ؂����
%             ���B
%  P          x'*P*x�́A���萫�����؂���Lyapunov�֐���2�������ł��B
%  S,N        TAU < 0�Ȃ�΁AS��N�́A���萫�����؂���Popov"�搔"�ł��B
%
% �Q�l�F    QUADSTAB, PDLSTAB, MUSTAB, UBLOCK, UDIAG, UINFO.



% Copyright 1995-2002 The MathWorks, Inc. 
