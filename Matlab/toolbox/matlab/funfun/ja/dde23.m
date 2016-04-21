% DDE23  �萔�x������x�����������(DDEs)�̉�@
%
% SOL = DDE23(DDEFUN,LAGS,HISTORY,TSPAN) �́ADDEs 
% y'(t) = f(t,y(t),y(t - tau_1),...,y(t - tau_k)) �������܂��B�萔�̐��̒x��
% tau_1,...,tau_k �́A�x�N�g��LAGS�Ƃ��ē��͂���܂��B�֐� DDEFUN(T,Y,Z) ��
% f(t,y(t),y(t - tau_1),...,y(t - tau_k)) �ɑΉ������x�N�g�����o�͂���K�v��
% ����܂��BDDEFUN�̌Ăяo���ɂ����āAT �̓J�����g�� t �ŁA�x�� tau_j = 
% LAGS(J) �ɑ΂��ė�x�N�g�� Y �� y(t) ���ߎ����AZ(:,j) �� y(t - tau_j) ��
% �ߎ����܂��BDDE�́AT0 < TF ���� TSPAN = [T0 TF] �̂Ƃ�T0����TF��
% �ϕ�����܂��Bt <= T0 �ł̉��́A3��ނ̕��@�� HISTORY �ɂ��w�肳
% ��܂��BHISTORY �́A��x�N�g�� y(t)  ���o�͂��� t �̊֐��ł��By(t) ��
% �萔�̏ꍇ�́AHISTORY �͂��̗�x�N�g���ł��B����DDE23�̌Ăяo����
% �O��T0�̐ϕ��𑱂���ꍇ�́AHISTORY �͂��̌Ăяo���̉�SOL�ł��B
%
% DDE23�́A[T0,TF] �ŘA���ȉ��𐶐����܂��B���́ADDE23�̏o��SOL��
% �֐�DEVAL���g���ē_TINT�ɂ����ĕ]������܂�: YINT = DEVAL(SOL,TINT). 
% �o��SOL�́A���̗v�f�����\���̂ł��B
%     SOL.x  -- DDE23�ɂ��I�����ꂽ���b�V��
%     SOL.y  -- SOLx�̃��b�V���_�ɂ����� y(t) �̋ߎ�
%     SOL.yp -- SOLx�̃��b�V���_�ɂ����� y'(t) �̋ߎ�
%     SOL.solver -- 'dde23'
%
% SOL = DDE23(DDEFUN,LAGS,HISTORY,TSPAN,OPTIONS) �́A�f�t�H���g
% �̃p�����[�^���֐�DDESET�ɂ���č쐬���ꂽ�\����OPTIONS���̒l��
% �u�������āA��L�������܂��B�ڍׂ́ADDESET���Q�Ƃ��Ă��������B��ʓI
% �Ɏg�p�����I�v�V�����́A�X�J���̑��΋��e�덷 'RelTol' (�f�t�H���g�ł�
% 1e-3 )�ƁA��΋��e�덷�x�N�g�� 'AbsTol' (�f�t�H���g�ł͂��ׂĂ̗v�f��
% 1e-6)�ł��B
%
% SOL = DDE23(DDEFUN,LAGS,HISTORY,TSPAN,OPTIONS,P1,P2,...) �́A
% DDEFUN(T,Y,Z,P1,P2,...) �� HISTORY(T,P1,P2,...) �̂悤��(�֐��ł����
% ����) history �ɓn���悤�ɁA�ǉ��p�����[�^ P1,P2,... ��DDE�֐��ɓn���A
% OPTOINS�Ŏw�肵�����ׂĂ̊֐��ɓn���܂��B �I�v�V�������ݒ肳��Ă�
% �Ȃ��ꍇ�́AOPTIONS = [] ���g���Ă��������B
%
% DDE23�́AT0(history)�����O�̉��̕s�A����AT0�̌�ł�t�̊��m�̒l
% �ł̕������̌W���̕s�A�����A�����̕s�A���̈ʒu�� 'Jumps' �I�v�V����
% �̒l�Ƃ��ăx�N�g���ɗ^�����Ă���ꍇ�́A�����̖����������Ƃ��ł�
% �܂��B 
%
% �f�t�H���g�ł́A���̏����l�́AT0 �ɂ����� HISTORY �ɂ��o�͂����
% �l�ł��B'InitialY' �v���p�e�B�̒l�ɂ���ẮA�قȂ鏉���l���^������
% �ꍇ������܂��B
%
% OPTIONS �� 'Events' �v���p�e�B���֐�EVENTS�ɐݒ肳��Ă���ƁA
% DDE23�͏�L�̂悤�ɉ����A�C�x���g�֐� g(t,y(t),y(t - tau_1),...,y(t - tau_k)) % ���[���ƂȂ�_�����߂܂��B �w�肷��e�֐��ɑ΂��āA�ϕ����[���ŏI��
% ���邩�ǂ����A����у[���N���b�V���O�̕����͏d�v�ł��B�����́A
% EVENTS: [VALUE,ISTERMINAL,DIRECTION] = EVENTS(T,Y,Z) �ɂ���ďo
% �͂����3�̃x�N�g���ł��Bi�Ԗڂ̃C�x���g�֐��ɑ΂��āAVALUE(I) �́A
% �ϕ������̃C�x���g�֐��̃[���ŏI������ꍇ�́A�֐� ISTERMINAL(I) = 1
% �̒l�ŁA�����łȂ��ꍇ��0�� ���B���ׂẴ[�����v�Z�����(�f�t�H���g)��
% ���� DIRECTION(I) = 0 �ŁA�C�x���g�֐������������_�̂݃[���ł���ꍇ
% �� 1 �ŁA�C�x���g�֐������������_�̂݃[���ł���ꍇ�� -1 �ł��B�t�B�[
% ���h SOL.xe �́A�C�x���g���������鎞�Ԃ̗�x�N�g���ł��BSOL.ye �̍s�́A
% �Ή�������ŁA�x�N�g�� SOL.ie �̃C���f�b�N�X�́A�ǂ̃C�x���g����������
% �����w�肵�܂��B
%   
% ���    
%         sol = dde23(@ddex1de,[1, 0.2],@ddex1hist,[0, 5]);
% �́A��� [0, 5] �ɂ�����lags ��1�����0.2�ŁA�֐�ddex1de�ɂ���Čv�Z��
% ���x������������������܂��Bhistory�́A�֐�ddex1hist�ɂ����t <= 0
% �ɑ΂��Čv�Z����܂��B���� [0 5] ��100�̓��Ԋu�ȓ_�ɂ����Čv�Z��
% ��܂��B 
%         tint = linspace(0,5);
%         yint = deval(sol,tint);
% �ȉ��ɂ���ăv���b�g���܂��B
%         plot(tint,yint);
% DDEX1�́A�T�u�֐����g�������̖�肪�ǂ̂悤�ɃR�[�h������邩������
% �܂��B���̗��ɂ��ẮADDEX2���Q�Ƃ��Ă��������B  
%   
% �Q�l �F DDESET, DDEGET, DEVAL.

%   DDE23 tracks discontinuities and integrates with the explicit Runge-Kutta
%   (2,3) pair and interpolant of ODE23. It uses iteration to take steps
%   longer than the lags.

%   Details are to be found in Solving DDEs in MATLAB, L.F. Shampine and
%   S. Thompson, Applied Numerical Mathematics, 37 (2001). 

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:52:10 $
