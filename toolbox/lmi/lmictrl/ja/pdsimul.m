% [t,x,y] = pdsimul(pds,'traj',tf,'ut',xi,options)
%
% �֐�'TRAJ'�ɂ���Đݒ肳�ꂽ�p�����[�^�O���ɉ�����(�A�t�B��)�p�����[�^
% �V�X�e���̃V�~�����[�V�����B�֐�PDSIMUL�́A���`���σV�X�e���̎��ԉ���
% ��ϕ����邽�߂ɁAODE15s���Ăяo���܂��B
%
% �o�͈�����ݒ肵�Ȃ��ƁAPDSIMUL�́A�o�͋O�����v���b�g���܂��B
%
% ����:
%   PDS       �A�t�B���p�����[�^�ˑ��V�X�e��(PSYS���Q��)�B
%   'TRAJ'    �֐���p=TRAJ(t)�́A�p�����[�^�O����ݒ肵�܂��B���̊֐���
%             ����t����͂Ƃ��A�p�����[�^�x�N�g���̒lp���o�͂��܂��B
%   TF        �ϕ��̍ŏI����(initial=0)�B
%   'UT'      ���͊֐���u=UT(t)�B�f�t�H���g�́A�X�e�b�v���͂ł��B
%   XI        �V�X�e���̏������(�f�t�H���g = 0)�B
%   OPTIONS   ODE�ϕ��ɑ΂��鐧��p�����[�^(ODESET���Q��)�B
%
%  �o��:
%   T         �ϕ����ԓ_�B
%   X         ��ԋO��(X(:,1) = 1�Ԗڂ̏�ԓ�)�B
%   Y         �o�͋O��(Y(:,1) = 1�Ԗڂ̏o�͓�)�B
%
% �Q�l�F    GEAR, PSYS, PVEC.



%  Copyright 1995-2002 The MathWorks, Inc. 
