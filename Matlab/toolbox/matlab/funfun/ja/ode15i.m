%ODE15I  fully implicit �������������ώ����@(variable order method)
%        �ŉ����܂��B
% [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0) �́ATSPAN = [T0 TFINAL] �̏ꍇ�A
% ���������� Y0,YP0 �Ƃ��āA�����������n f(t,y,y') = 0 ������ T0 ����
% TFINAL �܂Őϕ����܂��B�֐� ODE15I �́A ODEs �ƃC���f�b�N�X 1 ��
% DAE �������܂��B���������́A"consistent" (f(T0,Y0,YP0) = 0 ���Ӗ�
% ���܂�)�łȂ���΂Ȃ�܂���B�֐� DECIC �́A����l�ɋ߂������̂Ȃ� 
% �����������v�Z���܂��B�֐� ODEFUN(T,Y,YP) �́Af(t,y,y') 
% �ɑ��������x�N�g����Ԃ��K�v������܂��B���̔z�� Y �̊e�s�́A
% ��x�N�g�� T �ŕԂ���鎞�ԂɑΉ�������ł��B����̎��� T0,T1,...,
% TFINAL (���ׂđ����A���邢�́A���ׂČ���)�ŁA���𓾂邽�߂ɂ́A
% TSPAN = [T0 T1  ... TFINAL] ���g�p���Ă��������B
%   
% [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS) �́AODESET �֐���
% �쐬���ꂽ�����AOPTIONS �̒l�Œu��������ꂽ�f�t�H���g�̐ϕ�����
% ���g�p���āA��L�̂悤�ɉ����܂��B�ڍׂ́AODESET ���Q�Ƃ��Ă��������B
% ��ʂɎg�p�����I�v�V�����́A�X�J���[���΋��e�덷 'RelTol' 
% ( �f�t�H���g�� 1e-3 ) �� ��΋��e�덷�̃x�N�g�� 'AbsTol' 
% (���ׂĂ̐������f�t�H���g�� 1e-6 ) �ł��B  
%   
% [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS,P1,P2...) �́A�t��
% �p�����[�^ P1,P2,... ���AODEFUN(T,Y,P1,P2...)�Ƃ���ODE �֐���
% OPTIONS �Ɏw�肳�ꂽ���ׂĂ̊֐��ɓn���܂��B�I�v�V�������ݒ肳���
% ���Ȃ��ꍇ�A�v���[�X�z���_�Ƃ��� OPTIONS = [] ���g�p���Ă��������B
%   
% ���R�r�s�� df/dy �� df/dy' �́A�M�����ƌ����̂��߂ɏd�v�ł��B 
% FJAC(T,Y,YP) �� [DFDY, DFDYP] ��Ԃ��ꍇ�A�֐� FJAC �ɑ΂��āA
% 'Jacobian'��ݒ肷�邽�߂ɁAODESET ���g�p���Ă��������BDFDY = [] 
% �̏ꍇ�Adfdy �́A�L�������ɂ��ߎ�����ADFDYP�ɑ΂��Ă����l�ł��B
% 'Jacobian' �I�v�V�������ݒ肳��Ă��Ȃ��ꍇ(�f�t�H���g)�A������
% �s�񂪗L�������ɂ��ߎ�����܂��B

% ODE �֐��́AODEFUN(T,[Y1 Y2 ...],YP) �� [ODEFUN(T,Y1,YP) 
% ODEFUN(T,Y2,YP) ...] ���o�͂���悤�ɃR�[�h�����ꍇ�A
% 'Vectorized' {'on','off'} �Ɛݒ肵�Ă��������B
% ODE �֐� �́AODEFUN(T,Y,[YP1 YP2 ...]) �� 
% [ODEFUN(T,Y,YP1) ODEFUN(T,Y,YP2) ...]���o�͂���悤�ɃR�[�h�����
% �ꍇ�A 'Vectorized' {'off','on'}�Ɛݒ肵�Ă��������B
%  
% df/dy �܂��� df/dy' ���X�p�[�X�s��̏ꍇ�A'JPattern' ��
% �X�p�[�X�p�^�[��, {SPDY,SPDYP} �ɑ΂��Đݒ肵�Ă��������B
% df/dy �̃X�p�[�X�p�^�[���́A f(t,y,yp) �̗v�f i �� y �̗v�f j ��
% �ˑ�����ꍇ�ASPDY(i,j) = 1 �ł���A�����łȂ��ꍇ�A
% 0 �ł���s�� SPDY �ł��Bdf/dy �� �t���s��ł��邱�Ƃ��������߂ɁA
% SPDY = [] ���g�p���Ă��������Bdf/dy' ����� SPDYP �ɑ΂��Ă����l�ł��B 
% 'JPattern' �̃f�t�H���g�̒l�́A{[],[]} �ł��B
%
% [T,Y,TE,YE,IE] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS...) �́A
% �֐� EVENTS �ɑ΂��Đݒ肳���OPTIONS ��'Events' �v���p�e�B��
% ����ꍇ�A��̂悤�ɉ�����A�C�x���g�֐��ƌĂ΂��A
% (T,Y,YP)�̊֐����[���ɂȂ�_�������܂��B�e�֐��ɑ΂��āA
% �ϕ����_�ŏI����ׂ����ǂ����A����сA�[���N���b�V���O�̕�����
% ���ɂȂ邩�ǂ������w�肵�܂��B�����́AEVENTS �ɂ��o�͂����
% 3�̃x�N�g���A [VALUE,ISTERMINAL,DIRECTION]= EVENTS(T,Y,YP) �ł��B
% I�Ԗڂ̃C�x���g�֐��ɑ΂���: VALUE(I) �́A�֐��̒l�ł��B
% �ϕ������̃C�x���g�֐��̃[���_�ŏI������ꍇ�AISTERMINAL(I)=1 
% �ł���A�����łȂ��ꍇ�A0�ł��B���ׂẴ[���_���v�Z����ꍇ(�f�t�H���g)�A
% DIRECTION(I)=0, �C�x���g�֐����������Ă���Ƃ���ł̃[���_�̂݌v�Z����ꍇ�A
% +1, �C�x���g�֐����������Ă���Ƃ���ł̃[���_�̂݌v�Z����ꍇ�A -1 �ł��B 
% �o��TE �́A�C�x���g���N���鎞���̗�x�N�g���ł��BYE �̍s�́A�Ή�
% ������ł���A�x�N�g�� IE �̃C���f�b�N�X�́A�ǂ̃C�x���g���N���邩
% ���w�肵�܂��B    
%   
% SOL = ODE15I(ODEFUN,[T0 TFINAL],Y0,YP0,...) �́AT0 �� TFINAL��
% �Ԃ̔C�ӂ̓_�ł̉��A�܂��́A����1�K���֐���]�����邽�߂� DEVAL ��
% �g�p�����\���̂��o�͂��܂��BODE15I �ɂ��I�����ꂽ�X�e�b�v�́A
% �s�x�N�g�� SOL.x �ɏo�͂���܂��B�e I �ɑ΂��A�� SOL.y(:,I) �́A
% SOL.x(I) �ł̉����܂݂܂��B�C�x���g����������ꍇ�ASOL.xe �́A
% �C�x���g���N����_�̍s�x�N�g���ł��BSOL.ye �̗�́A�Ή������
% �ł���A�x�N�g�� SOL.ie �̃C���f�b�N�X�́A�ǂ̃C�x���g���N���邩
% ���w�肵�܂��B
%
% ���
%      t0 = 1;
%      y0 = sqrt(3/2);
%      yp0 = 0;
%      [y0,yp0] = decic(@weissinger,t0,y0,1,yp0,0);
% ���̗�ł́A y(t0) �ɑ΂��鏉���l���Œ肷�邽�߂�
% �⏕�֐� DECIC ���g�p���܂��B
% Weissinger implicit ODE �ɑ΂���Ay'(t0) �ɑ΂��Ė����̂Ȃ�
% �����l���v�Z���܂��BODE �́AODE15I ���g�p���ĉ�����A���l����
% ��͉��ɑ΂��āA�v���b�g����܂��B
%      [t,y] = ode15i(@weissinger,[1 10],y0,yp0);
%      ytrue = sqrt(t.^2 + 0.5);
%      plot(t,y,t,ytrue,'o');
%
% �Q�l
% �I�v�V�����n���h�����O: ODESET, ODEGET
% �o�͊֐�: ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
% ���̕]��: DEVAL
% ODE �̗�: IHB1DAE, IBURGERSODE

% Jacek Kierzenka and Lawrence F. Shampine
% Copyright 1984-2003 The MathWorks, Inc.
