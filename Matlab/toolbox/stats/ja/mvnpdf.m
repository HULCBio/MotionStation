% MVNPDF   ���ϗʐ��K���z���x�֐� (pdf)
%
% Y = MVNPDF(X) �́A�[���̕��ςƁAn�sd��̍s�� X �̊e�s��]�������P��
% �����U�s����g���āA���ϗʐ��K���z�̊m�����x���܂�n�s1��̃x�N�g�� Y 
% ���o�͂��܂��BX �̍s�͊ϑ��ɑΉ����A��͕��U�A�܂��͍��W�ɑΉ����܂��B
%
% Y = MVNPDF(X,MU) �́A���� MU �� X �̊e�s��]�������P�ʋ����U�s���
% �g���āA���ϗʐ��K���z�̖��x���o�͂��܂��BMU �́A1�sd��̃x�N�g���A
% �܂��́A���x��MU �̑Ή�����s���g���� X �̊e�s�ɑ΂��ĕ]�����ꂽ�ꍇ�́A
% n�sd��̍s��ł��BMU �́A�X�J���l�ł��w��ł��܂��B���̏ꍇ�́AMVNPDF 
% ���AX �̃T�C�Y�ɍ����悤�Ƀ��T�C�Y���܂��B
%
% Y = MVNPDF(X,MU,SIGMA) �́A���� MU �ƁAX �̊e�s��]�����������U SIGMA 
% ���g���đ��ϗʐ��K���z�̖��x���o�͂��܂��BSIGMA �́Ad�sd��̍s��A
% �܂��́A���x�� SIGMA �̑Ή�����y�[�W���g���� X �̊e�s�ɑ΂��ĕ]��
% ���ꂽ�ꍇ�A�Ⴆ�΁AMVNPDF �� X(I,:) �� SIGMA(:,:,I) ���g���� Y(I) ��
% �v�Z���ꂽ�ꍇ�́Ad-d-n�z��ł��B���[�U�� SIGMA �݂̂��w�肵�����ꍇ�́A
% �f�t�H���g�l���g�p���邽�߂ɁAMU �ɑ΂��ċ�s���n���Ă��������B
%
% X ���A1�sd��̃x�N�g���ł���ꍇ�AMVNPDF �́AMU �� leading dimension�A
% �܂��� SIGMA �� trailing dimension �Ɉ�v����悤�������s���܂��B
%
% ���:
%
%      mu = [1 -1];
%      Sigma = [.9 .4; .4 .3];
%      X = mvnrnd(mu, Sigma, 10);
%      p = mvnpdf(X, mu, Sigma);
%
% �Q�l : MVNRND, NORMPDF.


%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 16:51:27 $
