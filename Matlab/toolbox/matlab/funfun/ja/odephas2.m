% ODEPHAS2  2�����ʑ����ʂ�ODE�o�͊֐�
% 
% �֐� odephas2 �� 'OutputFcn' �v���p�e�B�Ƃ���ODE�\���o�ɓn�����Ƃ��A
% ���Ȃ킿�Aoptions = odeset('OutputFcn',@odephas2) �̂Ƃ��A�\���o�͊e��
% �ԃX�e�b�v���ɁAODEPHAS2(T,Y,'') ���Ăяo���܂��B�֐� ODEPHAS2 �́A
% �v�Z���ꂽ�ʂ�ɓn�������̍ŏ���2�̗v�f���A���͈̔͂Ƀ_�C�i
% �~�b�N�ɒ��߂��Ȃ���v���b�g���܂��B�����2�̗v�f���v���b�g���邽�߂�
% �́AODE�\���o�ɓn����� 'OutputSel' �v���p�e�B�ɃC���f�b�N�X���w�肵��
% ���������B
%   
% �ϕ��̊J�n���ɁA�\���o�͏o�͊֐������������邽�߂ɁA
% ODEPHAS2(TSPAN,Y0,'init') ���Ăяo���܂��B���̃x�N�g���� Y �ł���V��
% �����ԓ_�ւ̐ϕ��X�e�b�v�̌�ŁA�\���o�� STATUS = ODEPHAS2(T,Y,'').
% ���Ăяo���܂��B�\���o�� 'Refine' �v���p�e�B��1���傫���ꍇ(ODESET��
% �Q��)�́AT �͂��ׂĂ̐V�����o�͎��Ԃ��܂ޗ�x�N�g���ŁAY �͑Ή�����
% ��x�N�g������Ȃ�z��ł��BSTOP�{�^����������Ă����STATUS��
% �o�͒l�� 1 �ŁA�����łȂ���� 0 �ł��B�ϕ����I������ƁA�\���o��
% ODEPHAS2([],[],'done') ���Ăяo���܂��B
%
% ODE�\���o���t���I�ȓ��̓p�����[�^�Ƌ��ɌĂяo�����ꍇ�A���Ƃ��΁A   
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) �ɂ����āA�\���o�̓p��
% ���[�^���o�͊֐��ɓn���܂��B���Ƃ��΁AODEPHAS2(T,Y,'',P1,P2...) �̂悤
% �ɍs���܂��B  
%   
% �Q�l �F ODEPLOT, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.



%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:31 $
