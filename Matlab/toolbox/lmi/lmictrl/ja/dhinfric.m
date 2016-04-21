% [gopt,K,X1,X2,Y1,Y2] = dhinfric(P,r,gmin,gmax,tol,options)
%
% ���U���ԃv�����gP(z)�ɑ΂��āA���[GMIN,GMAX]�ł̍œKHinf���\GOPT�ƁA
% ���𖞑�����Hinf���S�R���g���[��K(s)���v�Z���܂��B
% 
%    * �v�����g������I�Ɉ��艻���܂��B
%    * ���[�v�Q�C����GOPT�ȉ��ɂ��܂��B
% 
% DHINFRIC�́ARiccati�x�[�X�̃A�v���[�`���������܂��B
%
% GOPT�݂̂��v�Z���邽�߂ɂ́A�o�͈�����1�����ݒ肵��DHINFRIC�����s��
% �܂��B���͈���GMIN, GMAX, TOL, OPTIONS�́A�܂Ƃ߂ďȗ����邱�Ƃ��ł���
% ���B
%
% P(z)�Ɋւ���O��:  ����/���o�AD12��D21�̓t�������N�B
%
% ����:
%  P          �v�����g��SYSTEM�s��(LTISS���Q��)�B
%  R          D22�̎�����ݒ肷��1�s2��̃x�N�g���B���Ȃ킿�A
% 
%                      R(1) = �ϑ��ʂ̐�
%                      R(2) = ����ʂ̐�
% 
% GMIN,GMAX  GOPT�̋��E�B���̂悤�ȋ��E��ݒ肵�Ȃ����߂ɂ́AGMIN = GMAX
%            = 0�Ɛݒ肵�܂��B�lGAMA�����ł��邩�ǂ������e�X�g���邽��
%            �ɂ́AGMIN = GMAX = GAMA�Ɛݒ肵�܂��B
%  TOL        GOPT�̖ڕW���ΐ��x(�f�t�H���g = 1e-2)�B
%  OPTIONS    ���l�v�Z�p�̐���p�����[�^�̃I�v�V������3�v�f�x�N�g��
%             OPTIONS(1): ���g�p�B
%             OPTIONS(2): ���[0,1]�̒l�ŁA�f�t�H���g=0�ł��B�l���傫��
%             �قǁA�P�ʉ~�̃[���̖ʂł̕��[�v�������ǂ��Ȃ�܂��B
%             OPTIONS(3): �f�t�H���g=1e-3�B
%                         ���̏ꍇ�A�᎟���������s����܂��B
%                             rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% �o��:
%  GOPT       ���[GMIN,GMAX]�ł̍œKHinf���\�B
%  K          gamma = GOPT�ɑ΂���Hinf���S�R���g���[���B
%  X1,X2,..   X = X2/X1��Y = Y2/Y1�́Agamma = GOPT�ɑ΂���2��HinfRic-
%             cati�������̉��ł��B
%
% �Q�l�F    DHINFLMI.



% Copyright 1995-2002 The MathWorks, Inc. 
