% SET_PARAM   Simulink�V�X�e���p�����[�^�ƃu���b�N�p�����[�^��ݒ�
%
% SET_PARAM('OBJ','PARAMETER1',VALUE1,'PARAMETER2',VALUE2,...) �� 'OBJ'�́A
% �V�X�e���A�܂��́A�u���b�N�̃p�X���ł���A�w�肵���p�����[�^���w�肵���l�ɐ�
% �肵�܂��B�p�����[�^���ɂ��ẮA�啶���Ə������̋�ʂ͂���܂���B�l�̕���
% ��ɂ��ẮA�啶���Ə������͋�ʂ���܂��B�_�C�A���O�{�b�N�X�̍��ڂɑΉ�
% ����p�����[�^�́A���ׂĕ�����̒l�������Ă��܂��B
%
% ���:
%
% set_param('vdp','Solver','ode15s','StopTime','3000')
%
% �́Avdp�V�X�e���� Solver ����� StopTime �p�����[�^��ݒ肵�܂��B
%
% set_param('vdp/Mu','Gain','1000')
%
% �́Avdp�V�X�e�����̃u���b�N Mu �� Gain ��1000(�X�e�B�b�t)�ɐݒ肵�܂��B
%
% set_param('vdp/Fcn','Position',[50 100 110 120])
%
% �́Avdp�V�X�e������ Fcn �u���b�N�� Position ��ݒ肵�܂��B
%
% set_param('mymodel/Zero-Pole','Zeros','[2 4]','Poles','[1 2 3]')
%
% �́Amymodel�V�X�e������ Zero-Pole �u���b�N�ɑ΂��� Zeros ����� Poles
% �p�����[�^��ݒ肵�܂��B
%
% set_param('mymodel/Compute','OpenFcn','my_open_fcn')
%
% �́Amymodel�V�X�e������ Compute �u���b�N�� OpenFcn �R�[���o�b�N�p�� ���[�^��
% �ݒ肵�܂��B�֐� 'my_open_fcn' �́A���[�U�� Compute �u���b�N���_�u���N���b�N
% ����Ǝ��s����܂��B�@
%
% �Q�l : GET_PARAM, FIND_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
