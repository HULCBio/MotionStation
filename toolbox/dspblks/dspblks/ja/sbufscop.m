% sbufscop   Simulink�̃x�N�g���X�R�[�vS-Function
%
% sbufscop �́AHandle Graphics Figure �E�C���h�E���̓��̓x�N�g�����v���b�g
% ���� SIMULINK S-Function �ł��BFigure�́AScope �u���b�N�̃t�������g���āA
% ���t�����A�^�O���t�����܂��B
%
% ���̓x�N�g���́A�T���v���f�[�^�̃x�N�g���A�܂��́A���g���̃x�N�g���Ƃ���
% ���߂���܂��B���̍\���Ŏg���܂��B
% 
%    sbufscop(T,X,U,FLAG,SCALING,DOMAIN,FIGPOS,YLABELSTR,RADS)
% 
% �ŏ���4�̓��͈��� T, X, U, FLAG�́ASimulink�ŕK�v��4�̓��͈����ł��B
% ���̈����̐������A���Ɏ����܂��B:
%	    SCALING �́AX-���͈̔͂̐ݒ�
%	    DOMAIN �́A���͂����ԗ̈悩�A���g���̈悩�̐ݒ�
%	    FIGPOS �́AScope Figure�E�C���h�E�̈ʒu��ݒ肷��s�N�Z���P
%                      �ʂŕ\�킵���ʒu��\�킷�����`�ł��B
%	    YLABELSTR �́AY-����ݒ肷��ǉ��I�v�V�����̈����ł��B  
%                     �f�t�H���g�́A'Magnitude'�ł��B
%	    RADS �́AX-���̒P�ʂ�ݒ肷��ǉ��I�v�V�����̈����ł��B 
%	              1 �̏ꍇ�AX-���̒P�ʂ̓��W�A���ŁA
%	              0(�f�t�H���g) �̏ꍇ�AHertz(Hz)�ɂȂ�܂��B


%   7/22/94
%   Revised: T. Krauss 20-Sep-94, D. Orofino 1-Feb-97, S. Zlotkin 20-Feb-97
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.6.1 $  $Date: 2003/07/22 21:03:54 $
