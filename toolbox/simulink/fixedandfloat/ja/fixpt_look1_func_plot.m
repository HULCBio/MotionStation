% fixpt_look1_func_plot   - ���z�I�Ȋ֐��Ƃ��̃��b�N�A�b�v�ߎ��̃v���b�g
%
%
% ERRWORST = FIXPT_LOOK1_FUNC_PLOT( XDATA, YDATA, FUNCSTR, XMIN, XMAX,
% XDT, XSCALE, YDT, YSCALE, RNDMETH)?I?AXMIN?(c)?cXMAX?I"I?I?A-?'z"I?E?O?
% "FUNCSTR?d?v???b?g?��?U?�E?B�܂��A�f�[�^�_XDATA��YDATA�ɂ���Č��肳��郋�b
% �N�A�b�v�e�[�u���ߎ����v���b�g���܂��B���z�ƃ��b�N�A�b�v�e�[�u���ߎ��Ƃ̊Ԃ�
% �덷���v���b�g����܂��B���b�N�A�b�v�e�[�u���v�Z�́A���̓f�[�^�^�C�vXDT?A"
% u-I?X?P?[???"?OXSCALE?A?o-I?f?[?^?^?C?vYDT?A?o-I?X?P?[???"?OYSCALE?A?
% o-]?�E?e?U?s???[?hRNDMETH?d-p?��?A?A?"?3?e?U?�E?B
% �����̈����́AFixed-Point Blockset?A-p?��?e-p-@?E?]?��?U?�E?B
% �ň��P�[�X�̌덷ERRWORST?I?A-?'z"I?E?O?"FUNCSTR?A?"?IXMIN?(c)?cXMAX?U?A?
% I?s?-?A?I?O?I?A'a?a'I?e?�E?E'e?`?3?e?U?�E?B
%
% Inputs XDATA    ���b�N�A�b�v�e�[�u���ߎ��ɂ��p����u���[�N�|�C���g�@
% YDATA    �u���[�N�|�C���g�ɑΉ�����o�̓f�[�^�_�@�@FUNCSTR  ���̓x�N�g��x�ɑ�
% ���闝�z�I�Ȋ֐��̏o�͂ɑΉ�����o�̓f�[�^�_���Ƃ��΁A'sin(2*pi*x)' ?U?1/
% 2?I?@'sqrt(x)' XMIN      ?A?��"u-I'lXMAX      �ő���͒l
% XDT       Fixed-Point Blockset�̗p�@��p���Ďw�肵�����̓f�[�^�^�C�v
%  ���Ƃ��΁Asfix(16), ufix(8), float('single') ?@
% XSCALE   Fixed-Point Blockset?I-p-@?d-p?��?A?w'e?3?e?1/2"u-I?X?P?[???"?
% O���Ƃ��΁A2^-6 �͏����_��6�r�b�g�E���Ӗ����܂��BYDT      �o�̓f�[�^�^�C�v
% YSCALE   �o�̓X�P�[�����O
% RNDMETH  �ۂߕ��@
% 'floor' (�f�t�H���g), 'ceil', 'near', 'zero'
%
% Outputs  ERRWORST ���z�I�Ȋ֐��ƃ��b�N�A�b�v�ߎ��Ƃ̊Ԃ̍ň��P�[�X�덷
%
% ���
% xdata = linspace(0,0.25,5).';
% ydata = sin(2*pi*xdata);
% FIXPT_LOOK1_FUNC_PLOT(xdata, ydata, 'sin(2*pi*x)', 0, 0.25, ...
% ufix(8), 2^-8, sfix(16), 2^-14, 'Floor')
%
% �Q�l : SFIX, UFIX,


% Copyright 1994-2002 The MathWorks, Inc.
