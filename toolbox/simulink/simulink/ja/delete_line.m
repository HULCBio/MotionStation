% DELETE_LINE   Simulink�V�X�e�����烉�C�����폜
%
% DELETE_LINE('SYS','OPORT','IPORT')�́A�w�肵���u���b�N�o�͒[�q 'OPORT'����
% �w�肵���u���b�N���͒[�q 'IPORT' �܂ł̃��C�����폜���܂��B'OPORT'�� '
% IPORT' �́A�u���b�N���ƒ[�q���ʎq����\������� 'block/port' �`���̕�����
% �ł��B�قƂ�ǂ̃u���b�N�[�q�́A'Gain/1'��'Sum/2'�̂悤�ɁA�ォ�牺�܂��͍�
% ����E�ɔԍ��t�����邱�Ƃɂ���Ď��ʂ��܂��BEnable,Trigger, State�[�q�́A
% 'subsystem_name/Enable'�� 'Integrator/State'��'subsystem_name/Ifaction'
% �̂悤�ɖ��O�Ŏ��ʂ���܂��B
%
% DELETE_LINE('SYSTEM',[X Y]) �́A�w�肵���_(X,Y)���܂ރV�X�e���̃��C����
% 1�����݂���΁A������폜���܂��B
%
% ���:
%
% delete_line('mymodel','Sum/1','Mux/2')
%
% �́ASum�u���b�N��Mux�u���b�N��2�Ԗڂ̓��͂ɐڑ����Ă��郉�C����mymodel
% ���f������폜���܂��B
%
% �Q�l : ADD_LINE.


% Copyright 1990-2002 The MathWorks, Inc.
