% ODESET   ODE��OPTIONS�\���̂̍쐬�܂��͕ύX
%
% OPTIONS = ODESET('NAME1',VALUE1,'NAME2',VALUE2,...) �́A�ݒ肵��
% �v���p�e�B���w�肵���l�����ϕ��I�v�V�����̍\����OPTIONS���쐬��
% �܂��B�w�肳��Ă��Ȃ��v���p�e�B�́A�f�t�H���g�̒l�������܂��B�v���p�e�B
% ����ӓI�Ɏ��ʂ��铪�������^�C�v���邾���ŏ\���ł��B�v���p�e�B���ɑ�
% ���ẮA�啶���Ə������̋�ʂ͖�������܂��B
%   
% OPTIONS = ODESET(OLDOPTS,'NAME1',VALUE1,...) �́A�����̃I�v�V����
% �\����OLDOPTS���X�V���܂��B
%   
% OPTIONS = ODESET(OLDOPTS,NEWOPTS) �́A�V�����I�v�V�����\����
% NEWOPTS�Ɗ����̃I�v�V�����\����OLDOPTS��g�����܂��B�V�����v��
% �p�e�B�́A�Ή�����Â��v���p�e�B���X�V���܂��B
%   
% ���͈������w�肵�Ȃ� ODESET �́A���ׂẴv���p�e�B���Ǝ�蓾��l��
% �\�����܂��B
%   
% ODESET�̃v���p�e�B
%   
% RelTol - ���΋��e�덷  [ ���̃X�J�� {1e-3} ]
% ���̃X�J���l�́A���x�N�g���̂��ׂĂ̗v�f�ɓK�p����A���ׂẴ\���o�ŁA
% �f�t�H���g�� 1e-3(0.1%�̐��x)�ł��B�e�ϕ��X�e�b�v�ł̐���덷�́A
% e(i) < =  max(RelTol*abs(y(i)),AbsTol(i)) �𖞑����܂��B
%
% AbsTol - ��΋��e�덷  [ ���̃X�J���܂��̓x�N�g�� {1e-6} ]
% ���x�N�g���̂��ׂĂ̗v�f�ɓK�p����X�J���l�̋��e�덷�B���e�덷�̃x�N�g
% ���̗v�f�́A���x�N�g���̑Ή�����v�f�ɓK�p����܂��BAbsTol �̃f�t�H���g
% �́A���ׂẴ\���o��1e-6�ł��BRelTol ���Q�Ƃ��Ă��������B
%   
% NormControl -  ���̃m�����Ɋւ���R���g���[���G���[  [ on | {off} ]
% ���̃v���p�e�B�� 'on' �ɐݒ肷��ƁA�\���o�́A�e�ϕ��X�e�b�v�ł̃R��
% �g���[���G���[�� norm(e) <= max(RelTol*norm(y),AbsTol) �ɂ��܂��B�f�t�H��
% �g�ł́A�\���o�͂�茵���ȗv�f�P�ʂ̃G���[�R���g���[���𗘗p���܂��B
%   
% Refine - �o�͂̏C���t�@�N�^  [ ���̐��� ]
% ���̃v���p�e�B�́A�o�͓_���𑝉������邱�ƂŁA��芊�炩�ȏo�͂��쐬��
% �܂��BRefine �̃f�t�H���g�́AODE45��4�ł���ȊO���ׂẴ\���o��1�ł��B 
% length(TSPAN) > 2 �ł��邩�A���邢��ODE�\���o�������\���̂Ƃ��ďo��
% ����ꍇ�́ARefine �͓K�p����܂���B
%   
% OutputFcn - �C���X�g�[���\�ȏo�͊֐��� [ �֐� ]
% ���̏o�͊֐��́A�e���ԃX�e�b�v���Ƀ\���o�ɂ��Ăяo����܂��B�\���o��
% �o�͈����Ȃ��ŌĂяo���ƁAOutputFcn �̃f�t�H���g�͊֐� odeplot �ɂȂ�
% �܂��B�����łȂ���΁AOutputFcn �̃f�t�H���g�� [] �ł��B
%   
% OutputSel - �o�͂���C���f�b�N�X�̑I��  [ �����̃x�N�g�� ]
% ���̃C���f�b�N�X�x�N�g���́A���x�N�g���̂ǂ̗v�f�� OutputFcn �ɓn�����
% �����w�肵�܂��BOutputSel �́A���ׂĂ̗v�f�̃f�t�H���g�ł��B
%   
% Stats - �ϕ��̌v�Z�R�X�g�̓��v�ʂ̕\��  [ on | {off} ]
%   
% Jacobian - ���R�r�A���֐� [ �֐� | �萔�s�� ]
% ���̃v���p�e�B�ɂ́A�֐� FJac (FJac(t,y) �� dF/dy ���o�͂���ꍇ)�A�܂��́A
% dF/dy �̒萔�l��ݒ肵�܂��B   
% ODE15I �� F(t,y,y') = 0 �������ꍇ�A���̃v���p�e�B���֐�
% [dFdy, dFdyp] = FJac(t,y,yp) �A�܂��́A�萔�l�̃Z���z��A{dF/dy,dF/dyp} 
% �ɐݒ肵�܂��B
%      
% JPattern - �X�p�[�X�p�^�[���̃��R�r�A�� [ �X�p�[�X�s�� ]
% ���̃v���p�e�B�ɂ́AF(t,y) �̐��� i �� y �̐��� j �Ɉˑ�����ꍇ�� 1�A
% �����łȂ��ꍇ�� 0 ��v�f�Ƃ���X�p�[�X�s�� S ��ݒ肵�܂��B
% ODE15I �� F(t,y,y') = 0 �������ꍇ�A���̃v���p�e�B���A 
% {dFdyPattern,dFdypPattern}, ���ꂼ�� dF/dy ��dF/dy' �̃X�p�[�X
% �p�^�[���ɐݒ肵�܂��B
%   
% Vectorized - �x�N�g�������ꂽ ODE �֐�  [ on | {off} ]
% ���̃v���p�e�B�� 'on' �ɐݒ肷��ƁAODE�֐� F ���R�[�h�������ꍇ�A
% F(t,[y1 y2 ...]) �́A[F(t,y1) F(t,y2) ...] ���o�͂��܂��B 
% ODE15I �� F(t,y,y') = 0 �������ꍇ�A���̃v���p�e�B���A{yVect,ypVect}
% �ɐݒ肵�܂��ByVect �� 'on' �ɐݒ�ƁAF(t,[y1 y2 ...],yp) �� 
% [F(t,y1,yp) F(t,y2,yp) ...] ���o�͂��AypVect ��'on' 
% �ɐݒ�ƁAF(t,y,[yp1 yp2 ...]) �� [F(t,y,yp1) F(t,y,yp2) ...]
% ���o�͂��܂��B
%   
% Events - �C�x���g�̈ʒu  [ �֐� ]
% �C�x���g�����o���邽�߁A���̃v���p�e�B�ɃC�x���g�֐���ݒ肵�Ă��������B
%   
% Mass - ���ʍs�� [ �萔�s�� | �֐� ]
% ��� M*y' = f(t,y) �ɑ΂��āA���̃v���p�e�B��萔���ʍs��̒l�ɐݒ肵
% �܂��B���ԁA�܂��́A��Ԉˑ��̎��ʍs��ɑ΂��āA���̃v���p�e�B�����ʍs
% ���]������֐��ɐݒ肵�܂��B
%
% MStateDependence - ���ʍs��� y �̈ˑ��� [ none | {weak} | strong ] 
% ��� M(t)*y' = F(t,y) �ɑ΂��āA���̃v���p�e�B�� 'none' �ɐݒ肵�܂��B
% 'weak' �� 'strong' �͋��� M(t,y) �������܂����A'weak' �́A�㐔��������
% �������ɋߎ����g���A�I�\���o�ɂȂ�܂��B
%   
% MassSingular - ���ʍs�񂪐����łȂ�  [ yes | no | {maybe} ]
% ���ʍs�񂪐����ȏꍇ�́A���̃v���p�e�B�� 'no' �ɐݒ肵�Ă��������B
%
% MvPattern - dMv/dy �̃X�p�[�X�p�^�[�� [ �X�p�[�X�s�� ]
% �C�ӂ� k �ɑ΂��āAM(t,y) �� (i,k) �v�f���Ay �� j �Ԗڂ̗v�f�Ɉˑ�����
% ����ꍇ�� 1�A���̑��̏ꍇ�� 0 ��v�f�Ƃ���X�p�[�X�s�� S(i,j) ��
% ���̃v���p�e�B�ɐݒ肵�Ă��������B  
%
% InitialSlope - �������z yp0 �Ƃ̐����� [ �x�N�g�� ]
% yp0 �́AM(t0,y0)*yp0 = F(t0,y0) �𖞑����܂��B
%
% InitialStep - ��������鏉���X�e�b�v�T�C�Y  [ ���̃X�J�� ]
% �\���o�́A�ŏ��ɂ��̒l�������Ă݂܂��B�f�t�H���g�ł́A�\���o�͎���
% �I�ɏ����X�e�b�v�T�C�Y�����肵�܂��B 
%   
% MaxStep - �X�e�b�v�T�C�Y�̏��  [ ���̃X�J�� ]
% MaxStep �̃f�t�H���g�́A���ׂẴ\���o�ɂ����āA��� tspan ��1/10�ł��B
%
% BDF - ODE15S�ł̌�ޔ������̎g�p  [ on | {off} ]
% ���̃v���p�e�B�́AODE15S�Ńf�t�H���g�̐��l�������̑���ɁA��ޔ�����
% (Gear's�@)���g�p���邩�ǂ������w�肵�܂��B 
%
% MaxOrder - ODE15S �̍ő原��  [ 1 | 2 | 3 | 4 | {5} ]
%   
% �Q�l ODEGET, ODE45, ODE23, ODE113, ODE15I, ODE15S, ODE23S, ODE23T, ODE23TB.
%
%
%
% ����: 
% ODE�\���o�̍ŏ��̓��͈����� ODESET �֓n���������̃v���p�e�B��
% ���߂́A���̃o�[�W�����ŕύX����Ă��܂��B�o�[�W���� 5 �̃V���^�b�N�X��
% ���݁A�T�|�[�g���Ă��܂����A�V�����@�\�́A�V�����V���^�b�N�X�ł̂ݎg�p
% �\�ł��B�o�[�W���� 5 �̃w���v������ɂ́A���̂悤�ɓ��͂��Ă��������B  
%         more on, type odeset, more off

% ����:
% �ȉ��ł́Av5 �ŗ��p�\�ȃv���p�e�B���q�ׂ܂��B
%
% RelTol - ���΋��e�덷  [ ���̃X�J�� {1e-3} ]
% ���̃X�J���l�́A���x�N�g���̂��ׂĂ̗v�f�ɓK�p����A���ׂẴ\���o�ŁA
% �f�t�H���g�� 1e-3(0.1%�̐��x)�ł��B�e�ϕ��X�e�b�v�ł̐���덷�́A
% e(i) < =  max(RelTol*abs(y(i)),AbsTol(i)) �𖞑����܂��B.
%
% AbsTol - ��΋��e�덷  [ ���̃X�J���܂��̓x�N�g�� {1e-6} ]
% ���x�N�g���̂��ׂĂ̗v�f�ɓK�p����X�J���l�̋��e�덷�B���e�덷�̃x�N�g
% ���̗v�f�́A���x�N�g���̑Ή�����v�f�ɓK�p����܂��BAbsTol �̃f�t�H���g
% �́A���ׂẴ\���o��1e-6�ł��BRelTol ���Q�Ƃ��Ă��������B
%   
% Refine - �o�͂̏C���t�@�N�^  [ ���̐��� ]
% ���̃v���p�e�B�́A�o�͓_���𑝉������邱�ƂŁA��芊�炩�ȏo�͂��쐬��
% �܂��BRefine �̃f�t�H���g�́AODE45��4�ł���ȊO���ׂẴ\���o��1�ł��B 
% length(TSPAN) > 2 �ł��邩�A���邢��ODE�\���o�������\���̂Ƃ��ďo��
% ����ꍇ�́ARefine �͓K�p����܂���B
%
% OutputFcn - �C���X�g�[���\�ȏo�͊֐��� [ �֐� ]
% ���̏o�͊֐��́A�e���ԃX�e�b�v���Ƀ\���o�ɂ��Ăяo����܂��B�\���o��
% �o�͈����Ȃ��ŌĂяo���ƁAOutputFcn �̃f�t�H���g�͊֐� odeplot �ɂȂ�
% �܂��B�����łȂ���΁AOutputFcn �̃f�t�H���g�� [] �ł��B
%   
% OutputSel - �o�͂���C���f�b�N�X�̑I��  [ �����̃x�N�g�� ]
% ���̃C���f�b�N�X�x�N�g���́A���x�N�g���̂ǂ̗v�f�� OutputFcn �ɓn�����
% �����w�肵�܂��BOutputSel �́A���ׂĂ̗v�f�̃f�t�H���g�ł��B
%
% Stats - �ϕ��̌v�Z�R�X�g�̓��v�ʂ̕\��  [ on | {off} ]
%   
% Jacobian - ���R�r�A���֐� [ �֐� | �萔�s�� ]
% ���̃v���p�e�B�́A�֐� FJac (FJac(t,y) �� dF/dy ���o�͂���ꍇ)�A�܂��́A
% dF/dy �̒萔�l�ɐݒ肵�܂��B   
%   
% JConstant - Constant Jacobian matrix dF/dy  [ on | {off} ]
% ���R�r�s�� dF/dy ���萔�̏ꍇ�A���̃v���p�e�B�� 'on' �ɐݒ肵�Ă��������B
%
% JPattern - ODE �t�@�C�����痘�p�ł��郄�R�r�A���X�p�[�X�p�^�[�� [ on | {off} ]

% ODE �t�@�C�����A F([],[],'jpattern') ��dF/dy �̔�[�������� 1 �����X�p�[�X
% �s����o�͂���悤�ɃR�[�h������Ă���ꍇ�A���̃v���p�e�B��'on' �ɐݒ肵��
% ���������B
%   
% Vectorized - Vectorized ODE file  [ on | {off} ]
% ODE �t�@�C�����A F(t,[y1 y2 ...]) ��[F(t,y1) F(t,y2) ...] ���o�͂���悤��
% �R�[�h������Ă���ꍇ�A���̃v���p�e�B��'on' �ɐݒ肵�Ă��������B
%   
% Events - �C�x���g�̈ʒu  [ on | {off} ]
% F(t,y,'events') ���C�x���g�֐��̒l���o�͂���悤�� ODE �t�@�C�����R�[�h��
% ����Ă���ꍇ�A���̃v���p�e�B��'on' �ɐݒ肵�Ă��������B���� ODEFILE ��
% �Q�Ƃ��Ă��������B
%   
% Mass - ODE �t�@�C�����痘�p�ł��鎿�ʍs�� [ {none} | M | M(t) | M(t,y) ]
% F(t,[],'mass') �����ʍs����o�͂���悤�ɁAODE �t�@�C�����R�[�h�������
% ����ꍇ�A���̃v���p�e�B�� 'none' ����ύX���Ă��������B  'M' �́A����
% ���ʍs��������A'M(t)' �́A���ԂɈˑ����鎿�ʍs��������A'M(t,y)' �́A
% time- �� state-�ˑ����鎿�ʍs��������܂��B
%   
% MassSingular - ���ʍs�񂪐����łȂ�  [ yes | no | {maybe} ]
% �@���ʍs�񂪐����ȏꍇ�́A���̃v���p�e�B�� 'no' �ɐݒ肵�Ă��������B
%   
% MaxStep - �X�e�b�v�T�C�Y�̏��  [ ���̃X�J�� ]
%   MaxStep �̃f�t�H���g�́A���ׂẴ\���o�ɂ����āA��� tspan ��1/10�ł��B
%
% InitialStep - ��������鏉���X�e�b�v�T�C�Y  [ ���̃X�J�� ]
% �\���o�́A�ŏ��ɂ��̒l�������Ă݂܂��B�f�t�H���g�ł́A�\���o�͎���
% �I�ɏ����X�e�b�v�T�C�Y�����肵�܂��B 
%   
% MaxOrder - ODE15S �̍ő原��  [ 1 | 2 | 3 | 4 | {5} ]
%   
% BDF - ODE15S�ł̌�ޔ������̎g�p  [ on | {off} ]
% ���̃v���p�e�B�́AODE15S�Ńf�t�H���g�̐��l�������̑���ɁA��ޔ�����
% (Gear's�@)���g�p���邩�ǂ������w�肵�܂��B 
%   
% NormControl -  ���̃m�����ɑ΂��鑊�Ό덷�̐���  [ on | {off} ]
% �e�ϕ��X�e�b�v�̌덷�� norm(e) <= max(RelTol*norm(y),AbsTol) ��
% ���䂷��悤�ɁA���̃v���p�e�B�� 'no' �ɐݒ肵�Ă��������B
% �f�t�H���g�ł́A�\���o�́A��茵�����v�f���̌덷������g�p���܂��B  

%   Mark W. Reichelt and Lawrence F. Shampine, 5/6/94
%   Copyright 1984-2003 The MathWorks, Inc. 

