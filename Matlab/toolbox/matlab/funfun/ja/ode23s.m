% ODE23S  �ώ����̃X�e�B�b�t�Ȕ����������̉�@
%
% [T,Y] = ODE23S(ODEFUN,TSPAN,Y0) �́ATSPAN = [T0 TFINAL] �̂Ƃ��A
% ������� Y0 �ŁA���� T0 ���� TFINAL �܂Ŕ����������V�X�e�� y' = f(t,y)
% ��ϕ����܂��B�֐� ODEFUN(T,Y) �́Af(t,y) �ɑΉ������x�N�g�����o��
% ���܂��B���̔z�� Y �̊e�s�́A��x�N�g�� T �ɏo�͂���鎞�ԂɑΉ����܂��B
% ���� T0,T1,...,TFINAL(�P�������܂��͒P������)�ł̉������߂邽�߂ɂ́A
% TSPAN = [T0 T1 ... TFINAL] ���g���Ă��������B
%   
% [T,Y] = ODE23S(ODEFUN,TSPAN,Y0,OPTIONS) �́A�f�t�H���g�̐ϕ��p��
% ���[�^�� OPTIONS �̒l�Œu�������āA��L�̂悤�ɉ����܂��BOPTIONS 
% �́A�֐� ODESET �ō쐬���ꂽ�����ł��B�ڍׂ́A�֐� ODESET ���Q��
% ���Ă��������B��ʓI�Ɏg�p�����I�v�V�����́A�X�J���̑��΋��e�덷
% 'RelTol' (�f�t�H���g�ł� 1e-3)�ƁA��΋��e�덷�x�N�g�� 'AbsTol' (�f�t�H��
% �g�ł͂��ׂĂ̗v�f�� 1e-6)�ł��B  
%      
% [T,Y] = ODE23S(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) �́A
% ODEFUN(T,Y,P1,P2...) �̂悤�ɕt���p�����[�^ P1,P2,... ��ODE�֐��A����� 
% OPTOINS �Ŏw�肵�����ׂĂ̊֐��ɓn���܂��B�I�v�V�������w�肵�Ȃ���
% ���́AOPTIONS = [] ���g���Ă��������B    
%   
% ���R�r�A�� df/dy �́A�v�Z�M�����ƌ������ɕq���ł��BFJAC(T,Y) ��
% ���R�r�A��df/dy ��A�s��df/dy(���R�r�A�����萔�̏ꍇ)���o�͂���ꍇ�A
% ODESET ���g���āA'jacobian'�I�v�V�����Ɋ֐� FJAC ��ݒ肵�Ă��������B
% 'Jacobian' �I�v�V������ݒ肵�Ă��Ȃ��ꍇ(�f�t�H���g)�Adf/dy �́A�L��
% �����ɂ�蓾���܂��BODEFUN(T,[Y1,Y2,...]) ���A[ODEFUN(T,Y1),ODE ...]
% ���o�͂���悤�� ODE �֐����R�[�h������Ă���ꍇ�A'Vectorizes' ��'on'
%  �ɐݒ肵�Ă��������Bdf/dy ���X�p�[�X�s��̏ꍇ�A'JPattern' ��df/dy ��
% �X�p�[�X�p�^�[���ɐݒ肵�Ă��������B���Ȃ킿�Af(t,y) �� i �Ԗڂ̗v�f��
%  y �� j �Ԗڂ̗v�f�Ɉˑ�����ꍇ�� S(i,j) = 1�ŁA���̏ꍇ0�̃X�p�[�X�s
% �� S �ɂȂ�܂��B    
%   
% ODE23S �́A�����łȂ����ʍs��M������� M*y' = f(t,y) ���������Ƃ�
% �ł��܂��BODESET ���g���� 'Mass' �v���p�e�B�Ɏ��ʍs���ݒ肵�܂��B
% �����̔��������������݂���ꍇ�A�X�p�[�X�����͂����肳���邱�ƁA�X
% �p�[�X M(t,y) ���o�͂����邱�Ƃ͏d�v�Ȃ��Ƃł��B'JPattern' �v���p�e�B��
% �g���āAdf/dy �̃X�p�[�X�p�^�[����ݒ肷�邩�A�܂��́AJacobian �v��
% �p�e�B���g���āA�X�p�[�X df/dy ��ݒ肵�܂��BODE15S ��  ODE23T �́A
% ���قȎ��ʍs����܂ޖ����������Ƃ��ł��܂��B     
%   
% [T,Y,TE,YE,IE] = ODE23S(ODEFUN,TSPAN,Y0,OPTIONS...) �́AOPTIONS
% �� 'Events' �v���p�e�B���֐� EVENTS �ɐݒ肳��Ă���ꍇ�͏�L�̂�
% ���ɉ����A�C�x���g�֐��ƌĂ΂�� (T,Y) �̊֐����[���ƂȂ�_�����߂܂��B
% �w�肷��e�֐��ɑ΂��āA�ϕ����[���ŏI�����邩�ǂ����A����у[���N
% ���b�V���O�̕����͏d�v�ł��B�����́AEVENTS: 
% [VALUE,ISTERMINAL,DIRECTION] =
% EVENTS(T,Y) �ɂ���ďo�͂����3�̃x�N�g���ł��BI�Ԗڂ̃C�x���g�֐� 
% �ɑ΂��āAVALUE(I) �́A�ϕ������̃C�x���g�֐��̃[���ŏI������ꍇ��
% �֐� ISTERMINAL(I)=1�̒l�ŁA�����łȂ��ꍇ��0�ł��B���ׂẴ[����
% �v�Z�����(�f�t�H���g)�ꍇ�́ADIRECTION(I)=0 �ŁA�C�x���g�֐�������
% �����_�̂݃[���ł���ꍇ�� +1 �ŁA�C�x���g�֐������������_�̂݃[��
% �ł���ꍇ�� -1 �ł��B�o�� TE �́A�C�x���g���������鎞�Ԃ̗�x�N�g��
% �ł��BYE �̍s�͑Ή�������ŁA�x�N�g�� IE �̃C���f�b�N�X�͂ǂ̃C�x���g
% ���������������w�肵�܂��B    
%
% SOL = ODE23S(ODEFUN,[T0 TFINAL],Y0...) �́AT0 �� TFINAL �Ԃ̔C�ӂ̓_
% �ŁA�����v�Z���邽�߁ADEVAL �Ŏg�p�\�ȍ\���̂��o�͂��܂��B
% ODE23S �őI�����ꂽ�X�e�b�v�́A�s�x�N�g�� SOL.x �ɏo�͂���܂��B
% I �ɑ΂��āA�� SOL.y(:,I) �́ASOL.x(I) �ł̉����܂�ł��܂��B�C�x���g��
% ���o���ꂽ�ꍇ�́ASOL.xe�́A�C�x���g�����������ʒu�������_����\����
% ���s�x�N�g���ł��BSOL.ye �̗�́A�Ή�������ŁA�x�N�g�� SOL.ie ��
% �C���f�b�N�X�́A�C�x���g�������������̂��ǂꂩ�������Ă��܂��B�^�[�~�i
% ���C�x���g�����o�����ꍇ�ASOL.x(end) �́A�C�x���g�����������ʒu�ł�
% �X�e�b�v�̏I�����܂�ł��܂��B�C�x���g�̐��m�Ȉʒu�́ASOL.xe(end)
% �ɕ񍐂���܂��B 
%
% ���
%         [t,y]=ode23s(@vdp1000,[0 3000],[2 0]);   
%         plot(t,y(:,1));
%
% �́A�f�t�H���g�̑��Ό덷 1e-3 �ƃf�t�H���g�̐�Ό덷 1e-6 ���e������
% �g���ăV�X�e�� y' = vdp1000(t,y) �������A���̍ŏ��̗v�f���v���b�g���܂��B
%
% �Q�l
%   ����ODE�\���o: ODE15S, ODE23T, ODE23TB, ODE45, ODE23, ODE113
%   �I�v�V�����̎�舵��: ODESET, ODEGET
%   �o�͊֐�: ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%   ���̌v�Z: DEVAL
%   ODE���: VDPODE, BRUSSODE
%
% ����: 
% ODE �\���o�̍ŏ��̓��͈����� ODESET �֓n���������̃v���p�e�B��
% ���߂́A���̃o�[�W�����ŕύX����Ă��܂��B�o�[�W���� 5 �̃V���^�b�N�X��
% ���݁A�T�|�[�g���Ă��܂����A�V�����@�\�́A�V�����V���^�b�N�X�ł̂ݎg�p
% �\�ł��B�o�[�W���� 5 �̃w���v������ɂ́A���̂悤�ɓ��͂��Ă��������B 
%         more on, type ode23s, more off

% ����:
% �ȉ��ł́AODE23S �� v5 �V���^�b�N�X���L�q���܂��B
%
% [T,Y] = ODE23S('F',TSPAN,Y0) �ł́ATSPAN = [T0 TFINAL] �̏ꍇ�A����������
% Y0 �Ƃ��Ĕ����������n y' = F(t,y) ���A���� T0 ���� TFINAL �܂Őϕ����܂��B
% 'F' �́AODE �t�@�C���̖��O���܂ޕ�����ł��B�֐� F(T,Y) �́A��x�N�g����
% �Ԃ��Ȃ���΂Ȃ�܂���B���̔z�� Y �̊e�s�́A��x�N�g�� T �ɏo�͂���鎞�Ԃ�
% �������܂��B�w�莞�� T0, T1, ..., TFINAL (���ׂđ����A�܂��́A���ׂČ���)
% �ŉ��𓾂邽�߂ɂ́ATSPAN = [T0 T1 ... TFINAL] ���g�p���Ă��������B
%   
% [T,Y] = ODE23S('F',TSPAN,Y0,OPTIONS)  �́AODESET �֐��ō쐬���ꂽ
% �����AOPTIONS �̒l�Œu��������ꂽ�f�t�H���g�̐ϕ��p�����[�^���g�p
% ���ď�L�̂悤�ɉ����܂��B �ڍׂ́AODESET ���Q�Ƃ��Ă��������B
% �ʏ�g�p�����I�v�V�����́A�X�J���[�̑��΋��e�덷 'RelTol' ( �f�t�H���g�́A
% 1e-3 ) �� ��΋��e�덷�̃x�N�g�� 'AbsTol' (�f�t�H���g�́A���ׂĂ̗v�f
% �� 1e-6 ) �ł��B
%   
% [T,Y] = ODE23S('F',TSPAN,Y0,OPTIONS,P1,P2,...) �́A�t���I�ȃp�����[�^
% P1,P2,... �� ODE �t�@�C���� F(T,Y,FLAG,P1,P2,...) �Ƃ��ēn���܂�
% ( ODEFILE ���Q�� )�B�I�v�V�������ݒ肳��Ă��Ȃ��ꍇ�A�v���C�X�z���_�Ƃ��� 
% OPTIONS = [] ���g�p���Ă��������B
%
% ODE �t�@�C���� TSPAN, Y0 ����� OPTIONS ���w��ł��܂� (ODEFILE ���Q��)�B
% TSPAN �܂��� Y0 ����̏ꍇ�AODE23S �ɗ^�����Ă��Ȃ��l�𓾂邽�߂ɁA
% ODE23S �́AODE �t�@�C�� [TSPAN,Y0,OPTIONS] = F([],[],'init') ���R�[�����܂��B
% �R�[�����X�g�̍Ō�̋�̈����́A���Ƃ��΁AODE23S('F') �̂悤�ɏȗ����邱��
% ���ł��܂��B
%   
% ���R�r�s�� dF/dy �́A�v�Z�M�����ƌ������ɕq���ł��B
% dF/dy �����̏ꍇ�A ODESET ���g�p���� JConstant �� 'on' �ɐݒ肵�Ă��������B
% F(T,[Y1 Y2 ...])��[F(T,Y1) F(T,Y2) ...]���o�͂���悤�ɃR�[�h�������ꍇ�A
% Vectorized�� 'on' �ɐݒ肵�Ă��������BdF/dy ���X�p�[�X�s��ŁA
% ODE �t�@�C�����AF([],[],'jpattern') ���AdF/dy �̔�[���������A1�� 0��
% �X�p�[�X�p�^�[���s����o�͂���悤�ɃR�[�h������Ă���ꍇ�A
% JPattern �� 'on' �ɐݒ肵�Ă��������B
%  F(T,Y,'jacobian') �� dF/dy ���o�͂���悤�ɁAODE �t�@�C�����R�[�h��
% ����Ă���ꍇ�A Jacobian �� 'on' �ɐݒ肵�Ă��������B
%   
% ODE23S �́A����قȒ萔�̎��ʍs�� M �������  M*y' = F(t,y) ��
% �������Ƃ��ł��܂��BF(T,Y,'mass') ���萔���o�͂���悤�ɁAODE �t�@�C����
% �R�[�h����Ă���ꍇ�A'M' �Ɏ��ʂ�ݒ肷�邽�߂ɂ́AODESET ��
% �g�p���Ă��������B���ʂ̃f�t�H���g�l�́A'none' �ł��B FEM1ODE, 
% FEM2ODE, �܂��� BATONODE ���Q�Ƃ��Ă��������BODE15S �� ODE23T �́A
% ���َ��ʍs����������������Ƃ��ł��܂��B���ʂ̃f�t�H���g�l�́A
% 'none' �ł��B  ODE Suite �̑��̃\���o�́A��萔�̎��ʍs���������
% �������Ƃ��ł��܂��BODE15S �� ODE23T �́A���َ��ʍs�������������
% ���Ƃ��ł��܂��B 
%   
% [T,Y,TE,YE,IE] = ODE23S('F',TSPAN,Y0,OPTIONS)  �ł́AOPTIONS �� Events
% �v���p�e�B��'on' �ɐݒ肵�āAODE �t�@�C���ɒ�`�����C�x���g�֐���
% �[���N���b�V���O��u���Ă��܂����A��L�̂悤�ɉ����܂��BODE �t�@�C���́A
% F(T,Y,'events') ���K���ȏ����o�͂���悤�ɃR�[�h�����K�v������܂��B
% �ڍׂ́AODEFILE ���Q�Ƃ��Ă��������B�o�� TE �́A�C�x���g���N���鎞�Ԃ�
% ��x�N�g���ł���AYE �̍s���Ή�������ł��B�x�N�g�� IE �̃C���f�b�N�X�́A
% �ǂ̃C�x���g���N���邩���w�肵�܂��B
%   
% �Q�l ODEFILE

% ODE23S  �́A"free" interpolant ���g�p�����V�����C�� Rosenbrock (2,3) �@
% �����s���܂��B�Ǐ��I�ȕ�O�́A�s���܂���B
% �f�t�H���g�ł́A���R�r�s��́A���l�I�ɐ�������܂��B

% �ڍׂ� The MATLAB ODE Suite �ɂ���܂��BL. F. Shampine and
% M. W. Reichelt, SIAM Journal on Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-22-94
%   Copyright 1984-2003 The MathWorks, Inc. 
