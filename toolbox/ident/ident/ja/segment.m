% SEGMENT �f�[�^�̕����Ƌ}���ɕω�����V�X�e���̐���
% 
%   [segm,V] = SEGMENT(z,nn,r2,q)
%
%   z : IDDATA �I�u�W�F�N�g�A�܂��́A�o�� - ���̓f�[�^�s�� z = [y u]
%       ���[�`���́A�P�o�̓f�[�^�p�ł��B
%   nn: ARX�A�܂��́AARMAX ���f���̎��� nn = [na nb nk]�A�܂��́Ann = 
%       [na nb nc nk]�ł��B
%       ARX�A�܂��́AARMAX ���Q�ƁB�A���S���Y���́A�����̓V�X�e�������
%       �����܂��B
%
%   r2   : ���덷�̕��U(�f�t�H���g�F�v�Z�������́A�������A���肵���ق���
%          �ǂ�)
%   q    : �e�T���v���ŁA�V�X�e�����}�ς���\��(�f�t�H���g 0.01)
%   segm : �������ꂽ�f�[�^�̃p�����[�^�B�s k �́A�T���v���ԍ� k �ł��B
%          �p�����[�^�́A�A���t�@�x�b�g���ɗ^�����܂��B
%   V : �ϐ� segm �ɑΉ����鑹���֐�
%       ���ϐ��� th ��r2 �̐���l�́A
%
%       [segm,V,th,r2] = SEGMENT(z,nn)
%
%      �ŗ^�����܂��B
%   
% ���I�Ȑ݌v�ϐ����A���̂悤�ɐݒ�ł��܂��B
%
%    [segm,V,th,r2]=SEGMENT(z,nn,r2,q,R1,M,th0,P0,ll,mu)
%
%    R1        : �}�ς���p�����[�^�̋����U�s��(�f�t�H���g�́A�P�ʍs��)
%    M         : �g�p���郂�f���̐� (�f�t�H���g�� 5)
%    th0       : �����p�����[�^���� (�s�x�N�g��)
%    P0        : ���������U�s�� (�f�t�H���g 10*I)�B ll:�e���f���̒��ŁA
%                �ی삳���f�[�^�̒���(�f�t�H���g 1)�Bmu: r2-����ł̖Y
%                �p�t�@�N�^ (�f�t�H���g 0.97)�B
% �Q�l���� : P. Andersson Int J Control, Nov 1985.



%   Copyright 1986-2001 The MathWorks, Inc.
