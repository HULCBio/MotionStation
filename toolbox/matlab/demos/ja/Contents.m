% ���ƃf��
%
% MATLAB�AToolbox�ASimulink�̃f�������邽�߂ɂ́A�R�}���h���C���ŁA
% 'demo' �Ɠ��͂��Ă��������B
%
%
% MATLAB/�C���g���_�N�V����
%   demo        - MATLAB, Toolbox, Simulink�̃f��
%
% MATLAB/�s��
%   intro       - MATLAB�̊�{�I�ȍs�񉉎Z�̏Љ�B
%   inverter    - �t�s��̃f���B
%   buckydem    - Buckminster Fuller geodesic dome�̌����O���t�B
%   sparsity    - �X�p�[�X���̓x�����̃f���B
%   matmanip    - �s�񑀍�B
%   eigmovie    - �Ώ̌ŗL�Z�o�����ߒ��̕\���B
%   rrefmovie   - �s�̊K�i�^�̏����ߒ��̕\���B
%   delsqdemo   - ��X�̗̈�ł̗L���������v���X���Z�q�B
%   sepdemo     - �L���v�f�̃��b�V���̃Z�p���[�^�B
%   airfoil     - NASA airfoil�̃X�p�[�X�s��̕\���B
%   eigshow     - �s��̌ŗL�l�̃O���t�B�J���ȃf���B
%
% MATLAB/���l
%   funfuns     - ���̊֐��������Ƃ��Ďg���֐��̃f���B
%   fitdemo     - �V���v���b�N�X�A���S���Y�����g��������`�J�[�u�t�B�b�g�B
%   sunspots    - FFT: ������11.08�̏ꍇ�̎���́H
%   e2pi        - 2�����̃r�W���A���ȉ�@�Be^pi��pi^e�ł͂ǂ��炪�傫�����B
%   bench       - MATLAB�x���`�}�[�N�B
%   fftdemo     - �����L���t�[���G�ϊ��B
%   census      - 2000�N�̕č��̐l���̗\�z�B
%   spline2d    - 2������GINPUT��SPLINE�B
%   lotkademo   - ������������̉�@�̗�B
%   quaddemo    - �K�����ϖ@
%   zerodemo    - fzero���g�����[���̌����B
%   fplotdemo   - �֐��̃v���b�g�B
%   quake       - Loma Prieta�n�k�B
%   qhulldemo   - �U�z�f�[�^�̕��ނƓ��}�B
%   expmdemo1   - Pade �ߎ����g�����s��w���B
%   expmdemo2   - Taylor �������g�����s��w���B
%   expmdemo3   - �ŗL�l�ƌŗL�x�N�g�����g�����s��w���B
%
% MATLAB/����
%   graf2d      - 2�����v���b�g�BMATLAB�ł�XY�v���b�g�B
%   graf2d2     - 3�����v���b�g�BMATLAB�ł�XYZ�v���b�g�B
%   grafcplx    - MATLAB�ł̕��f�֐��v���b�g�B
%   lorenz      - Lorenz chaotic attractor�̋O���̃v���b�g�B
%   imageext    - �J���[�}�b�v�̃C���[�W�F�J���[�}�b�v�̎�ނ̕ύX�B
%   xpklein     - Klein�{�g���̃f���B
%   vibes       - �U���̃��[�r�[�FL-�^���̐U���B
%   xpsound     - �����̉����FMATLAB�̉����@�\�B
%   imagedemo   - MATLAB�̃C���[�W�@�\�̃f���B
%   penny       - penny�f�[�^���g������X�̕\�����ʁB
%   earthmap    - �n���̕\���B
%   xfourier    - �t�[���G�ϊ��̃O���t�B�b�N�f���B
%   cplxdemo    - ���f����ϐ��Ƃ���֐��\���B
%
% MATLAB/����
%   xplang      - MATLAB����̏Љ�B
%   hndlgraf    - Handle Graphics��line�v���b�g�B
%   graf3d      - Handle Graphics��surface�v���b�g�B
%   hndlaxis    - Handle Graphics��axes�B
%   nesteddemo  - �l�X�g���ꂽ�֐��̗�B
%   anondemo    - Anonymous Function �̗�B
%
% MATLAB/����������
%   odedemo     - ODE suite�ϕ��̃f���B
%   odeexamples - MATLAB ODE/DAE/BVP/PDE ���̃u���E�U�B
% MATLAB/ODEs
%   ballode     - �o�E���h����{�[���̃f���B
%   brussode    - ���w�����̃��f�����O�̃X�e�B�b�t�Ȗ��(Brusselator)�B
%   burgersode  - Burgers ���������ړ����b�V�����@���g���ĉ����B
%   fem1ode     - ���ς̃}�X�s������X�e�B�b�t�Ȗ��B
%   fem2ode     - �s���ςȃ}�X�s������X�e�B�b�t�Ȗ��B
%   hb1ode      - Hindmarsh��Byrne�̃X�e�B�b�t�Ȗ��1�B
%   orbitode    - ORBITDEMO�Ŏg�p���鐧�����ꂽ3�̖��B
%   rigidode    - �O�͂̂Ȃ����̂�Euler�������B
%   vdpode      - �p�����[�^���\��van der Pol������(�傫��mu�ɑ΂���
%                 �X�e�B�b�t)�B
% MATLAB/DAEs
%   hb1dae      - �ۑ����ɏ]�����X�e�B�b�t�� DAE�B
%   amp1dae     - �d�C��H����̃X�e�B�b�t�� DAE�B
% MATLAB/Fully Implicit Differential Equations
%   iburgersode - Burgers ���������C���v���V�b�g�����������(ODE)�n�Ƃ��ĉ����B
%   ihb1dae     - �ۑ�������̃X�e�B�b�t�ȃC���v���V�b�g�����㐔������(DAE)�B
% MATLAB/DDEs
%   ddex1       - DDE23�̗��1
%   ddex2       - DDE23�̗��2
% MATLAB/BVPs   
%   twobvp      - �����ȈӖ���2�̉������� BVP�B
%   mat4bvp     - Mathieu �̕�������4�Ԗڂ̌ŗL�l�̌��o�B
%   shockbvp    - �����Ax = 0 �ŃV���b�N�w�����B
%   fsbvp       - ������ԏ�ł� Falkner-Skan BVP�B
%   emdenbvp    - Emden ������ - ���ٍ������� BVP�B
%   threebvp    - 3�_���E�l���
% MATLAB/PDEs   
%   pdex1       - PDEPE�ɑ΂�����1
%   pdex2       - PDEPE�ɑ΂�����2
%   pdex3       - PDEPE�ɑ΂�����3
%   pdex4       - PDEPE�ɑ΂�����4
%   pdex5       - PDEPE�ɑ΂�����5
%
% Extras/�M������
%   knot        - 3�����̐ߓ_���͂ފǁB
%   quivdemo    - quiver�֐��̃f���B
%   klein1      - Klein�{�g���̍쐬�B
%   cruller     - cruller�̍쐬�B
%   tori4       - 4�̑g�ݍ��킳�ꂽ�ւ̍쐬�B
%   spharm2     - ���ʒ��a�֐��̍쐬�B
%   modes       - L�^�̖���12�̃��[�h�̃v���b�g�B
%   logo        - MATLAB L�^���̃��S�̕\���B
%
% Extras/�Q�[��
%   fifteen     - �X���C�f�B���O�p�Y���B
%   xpbombs     - �}�C���X�C�[�o�Q�[���B
%   life        - Conway�̐l���Q�[���B
%   soma        - Soma�L���[�u�B
%
% Extras/���̑�
%   truss       - ���̋Ȃ��̃A�j���[�V�����B
%   travel      - ����Z�[���X�}�����B
%   spinner     - �J���[�̕t�������C���̉�]�B
%   xpquad      - Superquadrics�̃v���b�g�̃f���B
%   codec       - �A���t�@�x�b�g�̕�����/�������B
%   xphide      - �^�����̃I�u�W�F�N�g�̉����ʁB
%   makevase    - ��]����surface�̍쐬�ƃv���b�g�B
%   wrldtrv     - �n����̑�~�q�s���[�g�B
%   logospin    - MATLAB�̃��S�̉�]�̃��[�r�[�B
%   crulspin    - cruller���[�r�[�̉�]�B
%   quatdemo    - Quaternion ��]�B
%   chaingui    - �s��A����Z�œK���B
%
% General Demo/�⏕�֐�
%   cmdlnwin    - �R�}���h���C���f���̎��s�̂��߂̃Q�[�g�E�F�C���[�`���B
%   cmdlnbgn    - �R�}���h���C���f���̐ݒ�B
%   cmdlnend    - �R�}���h���C���f���̌�̃N���[���A�b�v�B
%   finddemo    - �X��Toolbox�ŉ\�ȃf���̌����B
%
% MATLAB/�⏕�֐�
%   bucky       - Buckminster Fuller geodesic dome�̃O���t�B
%   peaks       - 2�ϐ��̊֐��̗��B
%   membrane    - MATLAB�̃��S�̏o�́B
%
%
% �Q�l �F SIMDEMOS


%   Copyright 1984-2004 The MathWorks, Inc. 
