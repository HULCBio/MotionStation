% ODEPRINT  �R�}���h�E�B���h�E�ւ̈�� ODE �o�͊֐�
%
% �֐� odeprint ���A'OutputFcn' �v���p�e�B�Ƃ���ODE�\���o�ɓn�����Ƃ��A
% ���Ȃ킿�Aoptions = odeset('OutputFcn',@odeprint) �̂Ƃ��A�\���o�͊e��
% �ԃX�e�b�v�̌�ŁAODEODEPRINT(T,Y,'') ���Ăяo���܂��B�֐� ODEPRINT
% �́A�v�Z�̎��s���ɓn���ꂽ���̂��ׂĂ̗v�f��������܂��B����̗v�f
% �݂̂�������邽�߂ɂ́AODE�\���o�ɓn����� 'OutputSel' �v���p�e�B��
% �C���f�b�N�X���w�肵�Ă��������B
%   
% �ϕ��̊J�n���ɁA�\���o�͏o�͊֐������������邽�߂ɁA
% ODEPRINT(TSPAN,Y0,'init') ���Ăяo���܂��B���̃x�N�g���� Y �ł���V��
% �����ԓ_ T �ւ̐ϕ��X�e�b�v�̌�ŁA�\���o�́ASTATUS = ODEPRINT(T,Y,'')
% ���Ăяo���܂��B�\���o�� 'Refine' �v���p�e�B�� 1 ���傫���ꍇ(ODESET
% ���Q��)�́AT �͂��ׂĂ̐V�����o�͎��Ԃ��܂ޗ�x�N�g���ŁAY �͑Ή���
% ���x�N�g������Ȃ�z��ł��BODEPRINT�́A���STATUS = 0���o�͂�
% �܂��B �ϕ����I������ƁA�\���o��ODEPRINT([],[],'done') ���Ăяo���܂��B
%
% ODE�\���o���t���I�ȓ��̓p�����[�^�Ƌ��ɌĂяo�����ꍇ�A���Ƃ��΁A   
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) �ɂ����āA�\���o�̓p��
% ���[�^���o�͊֐��ɓn���܂��B���Ƃ��΁AODEPRINT(T,Y,'',P1,P2...) �̂悤��
% �s���܂��B  
%   
% �Q�l �F ODEPLOT, ODEPHAS2, ODEPHAS3, ODE45, ODE15S, ODESET.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:34 $
