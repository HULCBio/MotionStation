% [gopt,pdk,R,S]=hinfgs(pds,r,gmin,tol,tolred)
%
% ���σp�����[�^�ɂ��āA�A�t�B���ˑ��ł���p�����[�^�ˑ��V�X�e���̃Q�C
% ���X�P�W���[�����OHinf�R���g���[���B�����̃p�����[�^�́A�����ԂŊϑ�
% �����Ɖ��肳��܂��B
%
% ���̊֐��́A2��Hinf���\�A�v���[�`���������܂��B
%
% ����:
%  PDS       �p�����[�^�ˑ��v�����g(PSYS���Q��)�B
%  R         D22�̎�����ݒ肷��1�s2��x�N�g���B
% 
%                     R(1) = �ϑ��ʂ̐�
%                     R(2) = ����ʂ̐�
% 
%  GMIN      GOPT�ɑ΂���^�[�Q�b�g�l�B�œKGOPT���v�Z����ɂ́AGMIN = 0
%            �Ɛݒ肵�Ă��������B���\GAMMA���B���\���ǂ������e�X�g����
%            �ɂ́AGMIN = GAMMA�Ɛݒ肵�Ă�������(�f�t�H���g = 0)�B
%  TOL       �œK���\GOPT�̖ڕW���ΐ��x(�f�t�H���g = 1e-2)�B
%  TOLRED    �I�v�V����(�f�t�H���g�l= 1e-4)�B
%            ���̏ꍇ�A�᎟���������s����܂��B
%                   rho(X*Y) >=  (1 - TOLRED) * GAMA^2
%
% �o��
%  PDK       �Q�C���X�P�W���[�����O�R���g���[���̃|���g�s�b�N�\��
%            PDK = [K1 , ... ,Kn]�B
%            �[�_�R���g���[��Kj�́APOLYDEC�ɂ���ė^������̂Ɠ��l�ɁA
%            �p�����[�^�{�b�N�X��j�Ԗڂ̒[�_�Ɋ֘A�t�����܂��B
%  GOPT      GMIN=0�Ȃ�΍œK���\�A�����łȂ���ΒB���\�Ȑ��\< GMIN�B
%  R,S       ����LMI�V�X�e���̉��B
%
% �Q�l�F    PSYS, POLYDEC, PDSIMUL, HINFLMI.



% Copyright 1995-2002 The MathWorks, Inc. 
