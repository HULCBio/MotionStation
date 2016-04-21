% Wavelet Toolbox �̃f��
%
% wavedemo�@  Wavelet Toolbox �̃f��
%
% WAVELET ���Q��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �c�[���{�b�N�X���Ŏg���Ă���h�L�������g������Ă��Ȃ��֐� %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%------------------
% �X���C�h�V���E
%------------------
%   wshowdrv    - Wavelet Toolbox �X���C�h�V���E�̕⏕
%   whelpdem    - �f���̃w���v�֐�
%%-------------------------
% �R�}���h���C�����[�h�̃f��
%-------------------------
%   democmdm    - �R�}���h���C�����[�h�̃f�������s���邽�߂ɗp������
%                 ��v�R�}���h
% 
%   dcmdcasc    - �J�X�P�[�h�A���S���Y���̃f��
%   dcmdcomp    - ���k�̃f��
%   dcmdcw1d    - 1�����A���E�F�[�u���b�g�ϊ��̃f��
%   dcmddeno    - �m�C�Y�����̃f��
%   dcmddw1d    - 1�������U�E�F�[�u���b�g�ϊ��̃f��
%   dcmddw2d    - 2�������U�E�F�[�u���b�g�ϊ��̃f��
%   dcmdextm    - ���E�̘c�݂̃f��
%   dcmdmala    - Mallet �A���S���Y���̃f��
%   dcmdwpck    - �E�F�[�u���b�g�p�P�b�g�̃f��
%----------------
% GUI ���[�h�̃f��
%----------------
%   demoguim    - GUI ���[�h�̃f�������s���邽�߂ɗp�������v�R�}���h%
%   dguicw1d    - 1�����A���E�F�[�u���b�g�ϊ��̃f��
%   dguicwim    - 1�������f�E�F�[�u���b�g�ϊ��̃f��
%   dguicf1d    - Wavelet Coefficients selection 1-D �c�[���̃f��
%   dguicf2d    - Wavelet Coefficients selection 2-D �c�[���̃f��
%   dguide1d    - Density estimation 1-D �c�[���̃f��
%   dguidw1d    - 1�������U�E�F�[�u���b�g�ϊ��̃f�� 
%   dguidw2d    - 2�������U�E�F�[�u���b�g�ϊ��̃f��
%   dguiiext    - �C���[�W�̊g���̃f��
%   dguire1d    - Regression estimation 1-D �c�[���̃f��
%   dguisext    - �M���̊g���̃f��
%   dguisw1d    - 1���� SWT �ɂ��m�C�Y�����̃f��
%   dguisw2d    - 2���� SWT �ɂ��m�C�Y�����̃f��
%   dguiwp1d    - 1�����E�F�[�u���b�g�p�P�b�g�̃f��
%   dguiwp2d    - 2�����E�F�[�u���b�g�p�P�b�g�̃f��
%   dguiwpdi    - �E�F�[�u���b�g�p�P�b�g�\���̃f��
%   dguiwvdi    - �E�F�[�u���b�g�\���̃f��
%----------------
% GUI ���[�h�̃f��
%----------------
%   demoscen    - 1�����E�F�[�u���b�g�̑�\�I�ȃV�i���I�̃f��
%
%   dscedw1d    - 1�����E�F�[�u���b�g�̑�\�I�ȃV�i���I�̃f��(�I�[�g�v
%                 ���C)
%
%-----------------
% �f�����[�e�B���e�B
%------------------
%   demos 	- Wavelet Toolbox �̃f�����X�g
%   dmsgfun     - �f���̃��b�Z�[�W�֐�
%   dguiwait    - �f���ɑ΂��� Waiting function
%   wenamngr	- GUI �f���Ɋ֘A����ݒ��L���ɂ��܂�
%   wdfigutl	- �E�F�[�u���b�g�f���� Figure �Ɋ֘A���郆�[�e�B���e�B
%
%-----------------------------------
% ��: �V�����E�F�[�u���b�g�̒ǉ����@
%-----------------------------------
%   binlwavf 	- �o�����E�F�[�u���b�g�t�B���^ (�o�C�i���E�F�[�u���b�g:
%                 Binlets).
%   binlinfo	- �o�����E�F�[�u���b�g(�o�C�i���E�F�[�u���b�g:Binlets)
%                 �Ɋւ�����
%   lemwavf     - Lemarie �E�F�[�u���b�g�t�B���^
%
%------------------------------------------
% ��: �E�F�[�u���b�g�I�u�W�F�N�g�c���[�̍\�z
%------------------------------------------
%   wtree       - WTREE �I�u�W�F�N�g�̃R���X�g���N�^
%   merge       - �e�m�[�h�̃f�[�^���}�[�W����(�g�ݑւ���)
%   split       - �I�_�̃m�[�h�f�[�^�𕪗�����(��������)
%------------------------------------------
%   rwvtree     - RWVTREE �I�u�W�F�N�g�̃R���X�g���N�^
%   merge       - �e�m�[�h�̃f�[�^���}�[�W����(�g�ݑւ���)
%   plot        - RWVTREE �I�u�W�F�N�g�̃v���b�g
%   split       - �I�_�̃m�[�h�f�[�^�𕪗�����(��������)
%------------------------------------------
%   wvtree      - WVTREE �I�u�W�F�N�g�̃R���X�g���N�^
%   get         - WVTREE �I�u�W�F�N�g�t�B�[���h�̓��e���擾
%   plot        - WVTREE �I�u�W�F�N�g�̃v���b�g
%   recons      - �m�[�h�̌W�����č\��
%------------------------------------------
%   edwttree    - EDWTTREE �I�u�W�F�N�g�̃R���X�g���N�^
%   merge       - �e�m�[�h�̃f�[�^���}�[�W����(�g�ݑւ���)
%   plot        - EDWTTREE �I�u�W�F�N�g�̃v���b�g
%   recons      - �m�[�h�̌W�����č\��
%   split       - �I�_�̃m�[�h�f�[�^�𕪗�����(��������)
%------------------------------------------
%   ex1_wt      - 1�����E�F�[�u���b�g�c���[(WTREE OBJECT)�̗�
%   ex2_wt      - 2�����E�F�[�u���b�g�c���[(WTREE OBJECT)�̗�
%   ex1_rwvt    - 1�����E�F�[�u���b�g�c���[(RWTREE OBJECT)�̗�
%   ex2_rwvt    - 2�����E�F�[�u���b�g�c���[(RWTREE OBJECT)�̗�
%   ex1_wvt     - 1�����E�F�[�u���b�g�c���[(WVTREE OBJECT)�̗�
%   ex2_wvt     - 2�����E�F�[�u���b�g�c���[(WVTREE OBJECT)�̗�
%   ex1_edwt    - 1�����E�F�[�u���b�g�c���[(EDWTTREE OBJECT)�̗�
%------------------------------------------
%




% Copyright 1995-2002 The MathWorks, Inc.
