% ODEPLOT   ODE�o�͊֐�
%
% �֐� 'odeplot' ���A'OutputFcn' �v���p�e�B�Ƃ���ODE�\���o�ɓn�����Ƃ��A
% ���Ȃ킿�Aoptions = odeset('OutputFcn',@odeplot) �̂Ƃ��A�\���o�͎��ԃX
% �e�b�v���ɁAODEPLOODEPLOT(T,Y,'') ���Ăяo���܂��B�֐� ODEPLOT �́A
% �v�Z�̎��s���ɓn���ꂽ���̂��ׂĂ̗v�f���A�v���b�g�̎��͈̔͂��_�C�i
% �~�b�N�ɒ��߂��āA�v���b�g���܂��B����̗v�f�݂̂��v���b�g���邽�߂ɂ́A
% ODE�\���o�ɓn����� 'OutputSel' �v���p�e�B�ɃC���f�b�N�X���w�肵�Ă�����
% ���BODEPLOT�́A�o�͈����Ȃ��ł́A�\���o�̃f�t�H���g�̏o�͊֐��ł��B
%   
% �ϕ��̊J�n���ɁA�\���o�͏o�͊֐������������邽�߂ɁA
% ODEPLOT(TSPAN,Y0,'init') ���Ăяo���܂��B���̃x�N�g���� Y �ł��鎞��
% �_ T �ւ̐ϕ��X�e�b�v�̌�ŁA�\���o�́ASTATUS = ODEPLOT(T,Y,'') ��
% �Ăяo���܂��B�\���o�� 'Refine' �v���p�e�B��1���傫���ꍇ(ODESET��
% �Q��)�́AT �͂��ׂĂ̐V�����o�͎��Ԃ��܂ޗ�x�N�g���ŁAY �͑Ή�����
% ��x�N�g������Ȃ�z��ł��BSTOP�{�^����������Ă����STATUS��
% �o�͒l�� 1�ŁA�����łȂ���� 0 �ł��B�ϕ����I������ƁA�\���o�� 
% ODEPLOT([],[],'done') ���Ăяo���܂��B
%
% ODE�\���o���t���I�ȓ��̓p�����[�^�Ƌ��ɌĂяo�����ꍇ�A���Ƃ��΁A
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) �ɂ����āA�\���o�̓p��
% ���[�^���o�͊֐��ɓn���܂��B���Ƃ��΁AODEPLOT(T,Y,'',P1,P2...) �̂悤
% �ɍs���܂��B  
%   
% �Q�l �F ODEPHAS2, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:33 $
