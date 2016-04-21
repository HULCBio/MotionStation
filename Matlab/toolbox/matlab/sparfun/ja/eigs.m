% EIGS   ARPACK ��p���čs���2�A3�̌ŗL�l�ƌŗL�x�N�g�������߂܂�
% 
% D = EIGS(A) �́AA �̌ŗL�l�̒��̑傫�����̂���6���x�N�g���Ƃ��ďo�͂�
% �܂��B
%
% [V,D] = EIGS(A) �́AA �̌ŗL�l�̒��̑傫�����̂���6��Ίp�v�f�Ƃ���
% �s�� D �Ƃ��āA�Ή�����ŗL�x�N�g�����s�� V �Ƃ��ďo�͂��܂��B
%
% [V,D,FLAG] = EIGS(A) �́A�����t���O���o�͂��܂��BFLAG �� 0 �̏ꍇ�́A��
% �ׂĂ̌ŗL�l�͎������Ă��܂��B���̏ꍇ�́A�����ꂩ�̂��̂��������Ă�
% �܂���B
%
% EIGS(A,B) �́A��ʉ��ŗL�l��� A*V == B*V*D �������܂��BB �́A�Ώ�(��
% ���̓G���~�[�g)�Ő���ŁAA �Ɠ����T�C�Y�łȂ���΂Ȃ�܂���BEIGS(A,[],...) 
% �́A�W���ŗL�l��� A*V == V*D ���Ӗ����܂��B
%
% EIGS(A,K) �� EIGS(A,B,K) �́A�ŗL�l�̒��̑傫�����̂��� K ���o�͂���
% ���B
%
% EIGS(A,K,SIGMA) �� EIGS(A,B,K,SIGMA) �́ASIGMA ���x�[�X�� K �̌ŗL
% �l���o�͂��܂��B
% 
%      'LM' �܂��� 'SM' - �傫�����ő�܂��͍ŏ�
% �����Ώ̖��ɑ΂��āASIGMA �͂��̂悤�ɂ��ł��܂��B
%      'LA' �܂��� 'SA' - �㐔�I�ɍő�A�ŏ�
%      'BE' - ���[����AK ����̏ꍇ�́A��������1����
% ��Ώ̂ŕ��f���̏ꍇ�́ASIGMA �����̂悤�ɐݒ肵�܂��B
%      'LR' �܂��� 'SR' - ���������ő�܂��͍ŏ�
%      'LI' �܂��� 'SI' - ���������ő�܂��͍ŏ�
% SIGMA ��0���܂ގ����A�܂��͕��f���̃X�J���̏ꍇ�́AEIGS �� SIGMA ��
% �ł��߂��ŗL�l�����o���܂��B�X�J���� SIGMA �ɑ΂��āA�܂��ASIGMA = 0
% �Ɠ����A���S���Y���𗘗p���� SIGMA = 'SM' �̂Ƃ����A���̃P�[�X�̂悤��
% Cholesky �����ł͂Ȃ����߁AB �͑Ώ�(�܂��̓G���~�[�g)�̐��̔������
% ����K�v������܂��B
%
% EIGS(A,K,SIGMA,OPTS) �� EIGS(A,B,K,SIGMA,OPTS) �́A�I�v�V�������w�肵
% �܂��B
% 
%   OPTS.issym: A �̑Ώ̐��܂���AFUN [{0} | 1] �ŕ\�킳��� A-SIGMA*B
%   OPTS.isreal: A �̕��f�����܂���AFUN [{0} | 1]�ŕ\�킳��� A-SIGMA*B
%   OPTS.tol   : �������FRitz�̐���c�� <= tol*NORM(A) [�X�J�� | {eps}]
%   OPTS.maxit : �J��Ԃ��ő�� [���� | {300}]
%   OPTS.p     : Lanczos �x�N�g���̐��F K+1<p<=N [���� | {2K}]
%   OPTS.v0    : �X�^�[�g�x�N�g�� 
%               [N �s 1 ��̃x�N�g�� | {ARPACK�Ń����_���ɔ���}]
%   OPTS.disp  : �x�����̕\�����x�� [0 | {1} | 2]
%   OPTS.cholB : B �́A����Cholesky ���� CHOL(B) [{0} | 1]
%   OPTS.permB : �X�p�[�X B �́ACHOL(B(permB,permB)) [permB | {1:N}]
%
% EIGS(AFUN,N) �́A�s�� A �̑���Ɋ֐� AFUN ���󂯓���܂��B
% Y = AFUN(X) �͈ȉ����o�͂��܂��B
%    A*X            SIGMA ���w�肳��Ă��Ȃ����A'SM' �ȊO�̕�����ł���ꍇ
%    A\X            SIGMA ��0�� 'SM' �ł���ꍇ
%    (A-SIGMA*I)\X  SIGMA ����[���̃X�J��(�W���̌ŗL�l���)�ł���ꍇ
%    (A-SIGMA*B)\X  SIGMA �͔�[���̃X�J��(��ʉ��ŗL�l���)�ł���ꍇ
% N �́AA �̃T�C�Y�ł��BAFUN �ɂ���Ď������ A-SIGMA*I A-SIGMA*B �̍s�� A �́A
% OPTS.isreal �� OPTS.issym �ɂ���đ��Ɏw�肳��Ă��Ȃ���΁A�����Ŕ�Ώ�
% �ł���Ɖ��肳��܂��B������ EIGS �\���̂��ׂĂɂ����āAEIGS(A,...) �́A
% EIGS(AFUN,N,...) �Œu���������܂��B
%
% EIGS(AFUN,N,K,SIGMA,OPTS,P1,...) �� EIGS(AFUN,N,B,K,SIGMA,OPTS,P1,...) 
% �́AAFUN(X,P1,..) �ɓn���t���I�Ȉ�����^���܂��B
%
% ���F
%      A = delsq(numgrid('C',15));  d1 = eigs(A,5,'SM');
% �����Ȃ��̂Ƃ��āAdnRk �́A����1���C���֐��̂Ƃ�
%      function y = dnRk(x,R,k)
%      y = (delsq(numgrid(R,k))) \ x;
% dhRk �̕t���I�Ȉ��� 'C' �� 15 �� EIGS �ɓn���܂��B
%      n = size(A,1);  opts.issym = 1;  d2 = eigs(@dnRk,n,5,'SM', opts,'C',15);
%
% �Q�l�FEIG, SVDS, ARPACKC.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:02:35 $
