% ADD_LINE   Simulink�V�X�e���Ƀ��C����t��
%
% ADD_LINE('SYS','OPORT','IPORT') �́A�V�X�e���ɑ΂��钼�����A�w�肵���u���b
% �N�o�͒[�q'OPORT'����w�肵���u���b�N���͒[�q'IPORT'�ɒǉ����܂��B'
% OPORT'�� 'IPORT' �́A�u���b�N���ƒ[�q���ʎq����\������� 'block/port' �`
% ���̕�����ł��B�قƂ�ǂ̃u���b�N�[�q�́A'Gain/1'��'Sum/2'�̂悤�ɁA�ォ��
% ���܂��͍�����E�ɔԍ��t�����邱�Ƃɂ���Ď��ʂ��܂��BEnable,Trigger,
% State�[�q�́A'subsystem_name/Enable'�� 'Integrator/State'�̂悤�ɖ��O�Ŏ�
% �ʂ���܂��B
%
% ADD_LINE('SYS',POINTS) �́A�Z�O�����g���������C�����V�X�e���ɕt�����܂��B
% POINTS �z��̊e�s�́A���C���Z�O�����g��̓_��x���W��y���W���w�肵�܂��B
% ���_�́A�E�B���h�E�̍�����ɂ���܂��B
% �M���́A�ŏ��̍s�Œ�`�����_����ŏI�s�Œ�`�����_�܂ŗ���܂��B
% �V�������C���̊J�n�������̃��C���̏o�͂܂��̓u���b�N�ɋ߂��ꍇ�ɐڑ����s
% ���܂��B���l�ɁA���C���̏I�[�������̓��͂ɋ߂��ꍇ�ɐڑ����s���܂��B
%
% ADD_LINE('SYS','OPORT','IPORT', 'AUTOROUTING','ON') �́AADD_LINE('SYS','
% OPORT','IPORT') �Ɠ��l�ɁA�C�ӂ̃u���b�N����荞�ނ悤�ɒ����Ō������܂��B
% �f�t�H���g�� 'off' �ł��B
%
% ���:
%
% add_line('mymodel','Sine Wave/1','Mux/1')
%
% �́ASine Wave�u���b�N�̏o�͂�Mux�u���b�N�̍ŏ��̓��͂��A�Ԃ̃u���b�N��
% mymodel�V�X�e���Ƀ��C����ǉ����܂��B
%
% add_line('mymodel','Sine Wave/1','Mux/1','autorouting','on')
%
% �́ASine Wave�u���b�N�̏o�͂�Mux�u���b�N�̍ŏ��̓��͂��A�Ԃ̃u���b�N��
% ��荞�ނ悤�ɒ����Ō������Đڑ�����悤�ɁAmymodel �V�X�e���Ƀ��C����
% �ǉ����܂��B
%
% add_line('mymodel',[20 55; 40 10; 60 60])
%
% �́A(20,55)����(40,10),(60,60)�܂ŐL�т郉�C����mymodel�V�X�e���ɒǉ� ����
% ���B(60,60).
%
%
% �Q�l : DELETE_LINE.


% Copyright 1990-2002 The MathWorks, Inc.
