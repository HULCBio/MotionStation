% MLE   �Ŗސ���
%
% PHAT = MLE(DIST,DATA) �́A�x�N�g�� DATA ���̃T���v�����g���āADIST ��
% �ݒ肳��Ă��镪�z�ɑ΂���Ŗސ���l���o�͂��܂��B
%  
% [PHAT, PCI] = MLE(DIST,DATA,ALPHA,P1) �́A�^����ꂽ�f�[�^�̍Ŗސ���l��
% 100(1-ALPHA)%�̐M����Ԃ��o�͂��܂��BALPHA �̓I�v�V�����ł��B�f�t�H���g
% �ł́AALPHA = 0.05�ŁA95%�̐M����ԂɑΉ����܂��BP1 �́A�񍀕��z�݂̂�
% �g������̂ŁA���s�񐔂�^����I�v�V���������ł��B
%
% DIST �́A�ȉ��̂����ꂩ�ł��B:
%      'beta'
%      'bernoulli'
%      'bino' �܂��� 'binomial'
%      'ev' �܂��� 'extreme value'
%      'exp' �܂��� 'exponential'
%      'gam' �܂��� 'gamma'
%      'geo' �܂��� 'geometric'
%      'norm' �܂��� 'normal'
%      'poiss' �܂��� 'poisson'
%      'rayl' �܂��� 'rayleigh'
%      'unid' �܂��� 'discrete uniform'
%      'unif' �܂��� 'uniform'
%      'wbl' �܂��� 'weibull'
%
% �Q�l : BETAFIT, BINOFIT, EXPFIT, GAMFIT, NORMFIT, POISSFIT,
%        RAYLFIT, WBLFIT, UNIFIT.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:27 $
