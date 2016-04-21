% [gopt,K] = hinfric(P,r)
% [gopt,K,X1,X2,Y1,Y2,Preg] = hinfric(P,r,gmin,gmax,tol,options)
%
% �A�����ԃv�����gP(s)�ɑ΂��āA���[GMIN,GMAX]�ł̍œKHinf���\GOPT�ƁA
% ���𖞑�����Hinf���S�R���g���[��K(s)���v�Z���܂��B
% 
%    * �v�����g������I�Ɉ��艻���܂��B
%    * ���[�v�Q�C����GOPT�ȉ��ɂ��܂��B
% 
% HINFRIC�́ARiccati�x�[�X�̃A�v���[�`���������܂��B�v�����g�́A�K�v�Ȃ�
% �ΐ��K������܂��B
%
% GOPT�݂̂��v�Z���邽�߂ɂ́A�o�͈�����1�����ݒ肵��HINFRIC�����s����
% ���B���͈���GMIN, GMAX, TOL, OPTIONS�́A�܂Ƃ߂ďȗ����邱�Ƃ��ł��܂��B
%
% ����:
%  P          �v�����g��SYSTEM�s��(LTISYS���Q��)�B
%  R          D22�̎�����ݒ肷��1�s2��x�N�g���B���Ȃ킿�A
%                   R(1) = �ϑ��ʂ̐�(K�̓���)
%                   R(2) = ����ʂ̐�(K�̏o��)
%  GMIN,GMAX  GOPT�̋��E�B���̋��E��ݒ肵�Ȃ����߂ɂ́AGMIN = GMAX = 0
%             �Ɛݒ肵�܂��B�lGAMA�����ł��邩�ǂ������e�X�g����ɂ́A
%             GMIN = GMAX = GAMA�Ɛݒ肵�܂��B
%  TOL        GOPT�̖ڕW���ΐ��x(�f�t�H���g = 1e-2)�B
%  OPTIONS    ���l�v�Z�p�̐���p�����[�^�̃I�v�V������3�v�f�x�N�g���B
%             OPTIONS(1): ���[0,1]���̒l�ŁA�f�t�H���g=0�ł��B�l���傫
%                         ���قǁA�R���g���[���̏�ԋ�ԍs��̃m�����͏�
%                         �����Ȃ�܂��B
%             OPTIONS(2): ���[0,1]���̒l�ŁA�f�t�H���g=0�ł��B�l���傫
%                         ���قǁAjw���̖ʂ̃[���ɂ�������[�v�̌�����
%                         �ǂ��Ȃ�܂��B
%             OPTIONS(3): �f�t�H���g=1e-3�B
%                         ���̏ꍇ�A�᎟���������s����܂��B
%                         rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% �o��:
%  GOPT       ���[GMIN,GMAX]�ł̍œKHinf���\�B
%  K          gamma = GOPT�ɑ΂���Hinf���S�R���g���[���B
%  X1,X2,..   X = X2/X1��Y = Y2/Y1�́Agamma = GOPT�ɑ΂���2��HinfRic-
%             cati�������̉��ł��B
%  PREG       P(s)�����قȂ�΁A���K�����ꂽ�v�����g
%
% �Q�l�F    HINFLMI, DHINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
