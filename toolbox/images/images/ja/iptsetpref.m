% IPTSETPREF   Image Processing Toolbox �̗D�揇�ʂ�ݒ�
%   IPTSETPREF(PREFNAME,VALUE) �́A������ PREFNAME �� VALUE �ɐݒ肷��
%   ���Ƃɂ��AImage Processing Toolbox �̗D��x��ݒ肵�܂��B�ݒ�
%   �́A�J�����g�� MATLAB �Z�b�V�������I������܂ŁA�܂��́A�ݒ肪�ύX
%   �����܂ŗL���ł�(���s�̓x�ɐݒ��L���ɂ���ɂ́A���[�U�� start-
%   up.m �t�@�C���ɁA���̃R�}���h��ݒ肵�Ă�������)�B
%
%   ���̕\�́A�g�p�ł���D��x���ڂ��L�q���Ă��܂��B���̖��O�́A�啶
%   ���������ɖ��֌W�ŁA�ȗ��`���g�p�ł��܂��B
%
%   �ȉ��̗D�揇�ʂ��ݒ�ł��܂��B
%
%   'ImshowBorder'        'loose' (�f�t�H���g) �܂��́A'tight'
%
%        'ImshowBorder' �� 'loose' �̏ꍇ�AIMSHOW �́A�C���[�W�� Figu-
%        re�E�B���h�E�̃G�b�W�̊ԂɁA���鋫�E�������ăC���[�W��\����
%        �܂��B����ŁA���̃��x����^�C�g������\�����邱�Ƃ��ł���
%        ���B'ImshowBorder' �� 'tight' �ɂ���ƁAIMSHOW �́A�C���[�W�S
%        �̂� Figure �̑傫���ɂȂ�悤�Ƀt�B�M���A�̑傫���𒲐�����
%        ���B�]���āA�^�C�g�����̕\���͂���܂���(�C���[�W�����ɏ�
%        �����ꍇ��AFigure �̃C���[�W���ɕʂ̃I�u�W�F�N�g�Ǝ������݂�
%        ��ꍇ�A���E���c�邱�Ƃ�����܂�)�B
%
%   'ImshowAxesVisible'   'on'�A�܂��́A'off'(�f�t�H���g)
%
%        'ImshowAxesVisible' �� 'on' �̏ꍇ�AIMSHOW �͎��̃{�b�N�X�ƍ�
%        �݃��x���t���ŃC���[�W��\�����܂��B'ImShowAxesVisible' �� 
%        'off' �̏ꍇ�AIMSHOW �͎��̃{�b�N�X�⍏�݃��x���Ȃ��̃C���[�W
%        ��\�����܂��B
%
%   'ImshowTruesize'      'auto'(�f�t�H���g)�A�܂��́A'manual'
%
%        'ImshowTruesize' �� 'manual' �ł���ꍇ�AIMSHOW �́ATRUESIZE
%        ���Ăяo���܂���B'ImshowTruesize' �� 'auto' �ł���ꍇ�AIMS-
%        HOW �́ATRUESIZE ���Ăяo�����ǂ����������I�Ɍ��肵�܂�(����
%        �� Figure ���ɁA�C���[�W�Ƃ��̎��ȊO�ɑ��̃I�u�W�F�N�g������
%        ���Ȃ��ꍇ�AIMSHOW �� TRUESIZE ���Ăяo���܂�)�BDISPLAY_OPTI-
%        ON ������ IMSHOW �ɐݒ肷��ƁA�ʂ̕\���p�ɁA���̐ݒ��؂�
%        �������Ƃ��ł��܂��B�܂��́A�C���[�W�̕\����A�}�j���A���� 
%        TRUESIZE ���Ăяo�����Ƃ��ł��܂��B
%
%   'TruesizeWarning'     'on'(�f�t�H���g)�A�܂��́A'off'
%
%        'TruesizeWarning' �� 'on' �̏ꍇ�ATRUESIZE �́A�C���[�W���X�N
%        ���[���ɓK������ɂ͑傫�߂���Ƃ��ɁA���[�j���O��\������
%        ���B'TruesizeWarning' �� 'off' �̏ꍇ�ATRUESIZE �̓��[�j���O
%        ��\�����܂���BIMSHOW ���g���ꍇ�̂悤�ɁA�ԐړI�� TRUESIZE
%        ���Ăяo���Ƃ��ł����A���̗D�揇�ʂ�K�p����̂Œ��ӂ��Ă���
%        �����B
%
%   IPTSETPREF(PREFNAME) �́APREFNAME �̗L���Ȓl��\�����܂��B
%
%   ���
%   ----
%       iptsetpref('ImshowBorder', 'tight')
%
%   �Q�l�FIMSHOW, IPTGETPREF, TRUESIZE



%   Copyright 1993-2002 The MathWorks, Inc.  
