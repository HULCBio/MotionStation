% ACTXCONTROL   ActiveX�R���g���[���̍쐬
% 
%  H = ACTXCONTROL('PROGID', POSITION, PARENT, ...
%           ['CALLBACK' | {EVENT1 E_HANDLER1; EVENT2 E_HANDLER2; ...}])
% �́AActiveX�R���g���[�����`���܂��B
%
% H�́A�R���g���[���̃f�t�H���g�C���^�t�F�[�X�̃n���h���ԍ��ł��B
%
% PROGID�́AActiveX�I�u�W�F�N�g�̃v���O����ID�ŁAACTXCONTROL�̓��͈���
% �Ƃ��Ă̂ݗp�����܂��B
%
% POSITION�́A�ꏊ��\���x�N�g���ŁA���Ɏw�肵�Ȃ��ꍇ�ɂ́A�f�t�H���g�l
% [20 20 60 60]�ƂȂ�܂��B
%
% PARENT�́AHandle Graphics figure�E�B���h�E��Simulink�V�X�e���E�B���h�E
% �ɕ`�悷�邽�߂̃n���h���ł��BPARENT�̃f�t�H���g�l�́AGCF�ł��B
% 
% CALLBACK�́A�g�p����C�x���g�n���h����^���܂��BCALLBACK�̃f�t�H���g
% �l�́A''�ł��B
% 
% EVENTx E_HANDLERx�́A��g�̃C�x���g(���O�A�܂��́A�ԍ��̂ǂ��炩�Ŏw
% �肷��)�ƁA���̃C�x���g�ɑ΂���n���h���ł��B
% 
%  ���: 
%
%      h=actxcontrol('mwsamp.mwsampctrl.2')
%   
% �Q�l : ACTXSERVER


% Copyright 1984-2002 The MathWorks, Inc.
