%ODEXTEND  �����������̏����l���̉����g�����܂�
% 
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL) �́ASOL �ɃX�g�A���ꂽ�������
% [SOL.x(1), TFINAL] �܂Ŋg�����܂��BSOL �́AODE �\���o�Ő������ꂽ
% ODE�̉��̍\���̂ł��B�֐� ODEFUN(T,Y) �́A���֐���]�����܂��B
% ODEXTEND �́ASOL �𐶐������̂Ɠ���ODE�\���o���g�p���āA����
% SOL.x(end) ����TFINAL�܂Őϕ����邱�Ƃɂ������g�����܂��B
% �f�t�H���g�ł́AODEXTEND �́A �����ϕ��̏��������Ƃ���
% SOL.y(:,end)���g�p���܂��BSOL �̌v�Z�Ɏg�p�����A���֐��A�ϕ���
% �����A�ǉ��̓��͈����́A���̉��̍\���̂̈ꕔ�ɃX�g�A����܂��B
% �����̒l���ς�Ȃ��ꍇ�AODEXTEND�@�ɓn�����K�v�͂���܂���B
% SOL.x(1) �� TFINAL �̊Ԃ̔C�ӂ̓_�Ŋg�����ꂽ����]�����邽�߂ɂ́A
% DEVAL �� SOLEXT ���g�p���Ă��������B 
%
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT) �́A��L�̂悤��
% �����܂��BSOL.X(end) �ł̐V�������������Ƃ��āA��x�N�g��
% YINIT ���g�p���āAODE15I���g�p���ē���ꂽ�����g�����邽�߂ɂ́A
% �V���^�b�N�X SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,[YINIT,YPINIT]) 
% ���g�p���Ă��������B�����ŁA��x�N�g�� YPINIT �́A���̏�����
% ���֐��ł��B
%
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT,OPTIONS) �́AOPTIONS ��
% �w�肳�ꂽ�ϕ��������g�p���āASOL �̌v�Z�Ɏg�p���ꂽ�l��u�������A
% ��L�̂悤�ɉ����܂��BOPTIONS �v���p�e�B�̐ݒ�ɂ��Ă̏ڍׂ́A
% ODESET ���Q�Ƃ��Ă��������B�V���� YINIT ���ݒ肳��Ă��Ȃ��ꍇ�A
% �v���[�X�z���_�Ƃ���YINIT = [] ���g�p���Ă��������B
%
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT,OPTIONS,P1,P2...)  �́A
% �ǉ��̃p�����[�^P1,P2,... ��ODEFUN(T,Y,P1,P2...) �Ƃ��āAODE �֐��ƁA
% OPTIONS �Ɏw�肳�ꂽ���ׂĂ̊֐��ɓn���܂��B�ǉ��̃p�����[�^
% �́ASOL �̌v�Z�Ɏg�p���ꂽ�l�ƈقȂ�ꍇ�Ɍ���A�w�肵�Ă��������B
% �I�v�V�������ݒ肳��Ă��Ȃ��ꍇ�A�v���[�X�z���_�Ƃ��� �A
% OPTIONS = [] ���g�p���Ă��������B
%
% ���
%      sol=ode45(@vdp1,[0 10],[2 0]); 
%      sol=odextend(sol,@vdp1,20); 
%      plot(sol.x,sol.y(1,:));
% ���̗�ł́A��� [0 10] �ŃV�X�e�� y' = vdp1(t,y) ���������߂ɁA
% ODE45 ���g�p���܂��B���̌�A���� [0 20] �܂Ŋg�����A���̍ŏ��̗v�f��
% �v���b�g���܂��B
%
% �Q�l
% ODE �\���o: ODE23, ODE45, ODE113, ODE15S, 
%             ODE23S, ODE23T, ODE23TB
% �C���v���V�b�g ODE �\���o: ODE15I
% �I�v�V�����n���h�����O: ODESET, ODEGET
% ���̕]��: DEVAL

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
