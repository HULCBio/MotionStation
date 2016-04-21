%ODE45  �����x�̐��x�ŃX�e�B�b�t�łȂ������������������܂�
%
% [T,Y] = ODE45(ODEFUN,TSPAN,Y0) �́ATSPAN = [T0 TFINAL] �̂Ƃ��A
% ������� Y0 �ŁA���� T0 ���� TFINAL �܂Ŕ����������V�X�e�� y' = f(t,y) 
% ��ϕ����܂��B�֐� ODEFUN(T,Y) �́Af(t,y) �ɑΉ������x�N�g�����o��
% ���܂��B���̔z�� Y �̊e�s�́A��x�N�g�� T �ɏo�͂���鎞�ԂɑΉ����܂��B
% ���� T0,T1,...,TFINAL (�P�������܂��͒P������)�ł̉������߂邽�߂ɂ́A
% TSPAN = [T0 T1 ... TFINAL] ���g���Ă��������B     
%   
% [T,Y] = ODE45(ODEFUN,TSPAN,Y0,OPTIONS) �́A�f�t�H���g�̐ϕ��p��
% ���[�^�� OPTIONS �̒l�Œu�������āA��L�̂悤�ɉ����܂��BOPTIONS
% �́A�֐� ODESET �ō쐬���ꂽ�����ł��B�ڍׂ́A�֐� ODESET ���Q��
% ���Ă��������B��ʓI�Ɏg�p�����I�v�V�����́A�X�J���̑��΋��e�덷
% 'RelTol' (�f�t�H���g�ł�1e-3)�ƁA��΋��e�덷�x�N�g�� 'AbsTol' 
% (�f�t�H���g�ł͂��ׂĂ̗v�f��1e-6)�ł��B
%   
% [T,Y] = ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) �́A
% ODEFUN(T,Y,P1,P2...) �̂悤�ɁA�t���p�����[�^ P1,P2,... ��ODE�֐��A
% ����� OPTIONS�Ŏw�肵�����ׂĂ̊֐��ɓn���܂��B�I�v�V�������w�肵��
% ���ꍇ�́AOPTIONS = [] ���g���Ă��������B   
%
% ODE45 �́A�����łȂ����ʍs�� M(t,y) ������� M(t,y)*y' = f(t,y) ��
% �����܂��BMASS(T,Y) �����ʍs��̒l���o�͂���ꍇ�́AODESET ���g����
% �֐� MASS �� 'Mass'�v���p�e�B��ݒ肵�܂��B���ʍs�񂪒萔�̏ꍇ�́A
% �s��� 'Mass' �I�v�V�����̒l�Ƃ��Ďg���܂��B���ʍs�񂪏�ԕϐ� Y ��
% �ˑ������A�֐� MASS ��1�̓��͈��� T �Ƌ��ɌĂяo�����ꍇ�́A
% 'MStateDependence' �� 'none' �ɐݒ肵�Ă��������BODE15S �� ODE23T �́A
% ���قȎ��ʍs����܂ޖ����������Ƃ��ł��܂��B
%
% [T,Y,TE,YE,IE] = ODE45(ODEFUN,TSPAN,Y0,OPTIONS...) �́AOPTIONS
% �� 'Events' �v���p�e�B���֐� EVENTS �ɐݒ肳��Ă���ꍇ�͏�L�̂�
% ���ɉ����A�C�x���g�֐��ƌĂ΂�� (T,Y) �̊֐����[���ƂȂ�_�����߂܂��B
% �w�肷��e�֐��ɑ΂��āA�ϕ����[���ŏI�����邩�ǂ����A����у[���N
% ���b�V���O�̕����͏d�v�ł��B�����́AEVENTS: 
% [VALUE,ISTERMINAL,DIRECTION] = EVENTS(T,Y) �ɂ���ďo�͂����3��
% �x�N�g���ł��AI�Ԗڂ̃C�x���g�֐��ɑ΂��āAVALUE(I) �́A�ϕ�������
% �C�x���g�֐��̃[���ŏI������ꍇ�͊֐� ISTERMINAL(I)=1�̒l�ŁA����
% �łȂ��ꍇ��0�ł��B���ׂẴ[�����v�Z�����(�f�t�H���g)�ꍇ�́A
% DIRECTION(I)=0 �ŁA�C�x���g�֐������������_�̂݃[���ł���ꍇ�� +1 
% �ŁA�C�x���g�֐������������_�̂݃[���ł���ꍇ�� -1 �ł��B�o�� TE �́A
% �C�x���g���������鎞�Ԃ̗�x�N�g���ł��BYE �̍s�͑Ή�������ŁA�x�N
% �g�� IE �̃C���f�b�N�X�͂ǂ̃C�x���g���������������w�肵�܂��B    
%
% SOL = ODE45(ODEFUN,[T0 TFINAL],Y0...) �́AT0 �� TFINAL �Ԃ̔C��
% �̓_�ŁA�����v�Z���邽�߁ADEVAL �Ŏg�p�\�ȍ\���̂��o�͂��܂��B
% ODE45 �őI�����ꂽ�X�e�b�v�́A�s�x�N�g�� SOL.x �ɏo�͂���܂��B
% I �ɑ΂��āA�� SOL.y(:,I) �́ASOL.x(I) �ł̉����܂�ł��܂��B�C�x���g��
% ���o���ꂽ�ꍇ�́ASOL.xe�́A�C�x���g�����������ʒu�������_����\����
% ���s�x�N�g���ł��BSOL.ye �̗�́A�Ή�������ŁA�x�N�g�� SOL.ie ��
% �C���f�b�N�X�́A�C�x���g�������������̂��ǂꂩ�������Ă��܂��B�^�[�~�i
% ���C�x���g�����o�����ꍇ�ASOL.x(end) �́A�C�x���g�����������ʒu�ł�
% �X�e�b�v�̏I�����܂�ł��܂��B�C�x���g�̐��m�Ȉʒu�́ASOL.xe(end)
% �ɕ񍐂���܂��B
%
% ���
%         [t,y]=ode45(@vdp1,[0 20],[2 0]);   
%         plot(t,y(:,1));
%
% �́A�f�t�H���g�̑��Ό덷 1e-3 �ƃf�t�H���g�̐�Ό덷 1e-6 ���e������
% �g���ăV�X�e�� y' = vdp1000(t,y) �������A���̍ŏ��̗v�f���v���b�g���܂��B 
%   
% �Q�l
%   ����ODE�\���o: ODE23, ODE113, ODE15S, ODE23S, ODE23T, ODE23TB 
%   �I�v�V�����̎�舵��: ODESET, ODEGET
%   �o�͊֐�: ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%   ���̌v�Z: DEVAL
%   ODE���: RIGIDODE, BALLODE, ORBITODE
%
% ����: 
% ODE �\���o�̍ŏ��̓��͈����� ODESET �֓n���������̃v���p�e�B��
% ���߂́A���̃o�[�W�����ŕύX����Ă��܂��B�o�[�W���� 5 �̃V���^�b�N�X��
% ���݁A�T�|�[�g���Ă��܂����A�V�����@�\�́A�V�����V���^�b�N�X�ł̂ݎg�p
% �\�ł��B�o�[�W���� 5 �̃w���v������ɂ́A���̂悤�ɓ��͂��Ă��������B  
%         more on, type ode45, more off

% ����:
% �ȉ��ł́AODE45 �� v5 �V���^�b�N�X���L�q���܂��B
%
% [T,Y] = ODE45('F',TSPAN,Y0) �ł́ATSPAN = [T0 TFINAL] �̏ꍇ�A����������
% Y0 �Ƃ��Ĕ����������n y' = F(t,y) ���A���� T0 ���� TFINAL �܂Őϕ����܂��B
% 'F' �́AODE �t�@�C���̖��O���܂ޕ�����ł��B�֐� F(T,Y) �́A��x�N�g����
% �Ԃ��Ȃ���΂Ȃ�܂���B���̔z�� Y �̊e�s�́A��x�N�g�� T �ɏo�͂���鎞�Ԃ�
% �������܂��B�w�莞�� T0, T1, ..., TFINAL (���ׂđ����A�܂��́A���ׂČ���)
% �ŉ��𓾂邽�߂ɂ́ATSPAN = [T0 T1 ... TFINAL] ���g�p���Ă��������B
%   
% [T,Y] = ODE45('F',TSPAN,Y0,OPTIONS) �́AODESET �֐��ō쐬���ꂽ
% �����AOPTIONS �̒l�Œu��������ꂽ�f�t�H���g�̐ϕ��p�����[�^���g�p
% ���ď�L�̂悤�ɉ����܂��B �ڍׂ́AODESET ���Q�Ƃ��Ă��������B
% �ʏ�g�p�����I�v�V�����́A�X�J���[�̑��΋��e�덷 'RelTol' ( �f�t�H���g�́A
% 1e-3 ) �� ��΋��e�덷�̃x�N�g�� 'AbsTol' (�f�t�H���g�́A���ׂĂ̗v�f
% �� 1e-6 ) �ł��B
%   
% [T,Y] = ODE45('F',TSPAN,Y0,OPTIONS,P1,P2,...) �́A�t���I�ȃp�����[�^
% P1,P2,... �� ODE �t�@�C���� F(T,Y,FLAG,P1,P2,...) �Ƃ��ēn���܂�
% ( ODEFILE ���Q�� )�B�I�v�V�������ݒ肳��Ă��Ȃ��ꍇ�A�v���C�X�z���_�Ƃ��� 
% OPTIONS = [] ���g�p���Ă��������B
%   
% ODE �t�@�C���� TSPAN, Y0 ����� OPTIONS ���w��ł��܂� (ODEFILE ���Q��)�B
% TSPAN �܂��� Y0 ����̏ꍇ�AODE45 �́AODE45 �������X�g�ŗ^�����Ȃ��l
% �𓾂邽�߂ɁAODE �t�@�C�����R�[�����܂��B[TSPAN,Y0,OPTIONS] = F([],[],'init')% �R�[�����X�g�̍Ō�̋�̈����́A���Ƃ��΁AODE45('F') �̂悤�ɏȗ����邱��
% ���ł��܂��B
%   
% ODE45 �́A����َ��ʍs�� M �������  M(t,y)*y' = F(t,y) ��
% �������Ƃ��ł��܂��BF(T,Y,'mass') ���萔�A���Ԉˑ��A�܂��́A
% time- �� state-�ˑ����鎿�ʍs������ꂼ��o�͂���悤�ɁAODE �t�@�C����
% �R�[�h����Ă���ꍇ�A'M', 'M(t)', �܂��� 'M(t,y)' �Ɏ��ʂ�ݒ肷�邽�߂ɂ́A
% ODESET ���g�p���Ă��������B���ʂ̃f�t�H���g�l�́A'none' �ł��B
% ODE15S �� ODE23T �́A���َ��ʍs����������������Ƃ��ł��܂��B 
%   
% [T,Y,TE,YE,IE] = ODE45('F',TSPAN,Y0,OPTIONS) �ł́AOPTIONS �� Events
% �v���p�e�B��'on' �ɐݒ肵�āAODE �t�@�C���ɒ�`�����C�x���g�֐���
% �[���N���b�V���O��u���Ă��܂����A��L�̂悤�ɉ����܂��BODE �t�@�C���́A
% F(T,Y,'events') ���K���ȏ����o�͂���悤�ɃR�[�h�����K�v������܂��B
% �ڍׂ́AODEFILE ���Q�Ƃ��Ă��������B�o�� TE �́A�C�x���g���N���鎞�Ԃ�
% ��x�N�g���ł���AYE �̍s���Ή�������ł��B�x�N�g�� IE �̃C���f�b�N�X�́A
% �ǂ̃C�x���g���N���邩���w�肵�܂��B
%   
% �Q�l ODEFILE 

% ODE45 �́ADormand , Prince �ɂ��z�I Runge-Kutta (4,5) �@
% (RK5(4)7FM, DOPRI5, DP(4,5), DP54 �ȂǂƂ��Ă΂��j�����s���܂��B
% ����́ADormand, Prince ���玄�I�ɓ����A4 ���� "free" interpolant ���g�p
% ���܂��B�Ǐ��I�ȕ�O���s���܂��B

% �ڍׂ� The MATLAB ODE Suite �ɂ���܂��BL. F. Shampine and
% M. W. Reichelt, SIAM Journal on Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-14-94
%   Copyright 1984-2003 The MathWorks, Inc. 
