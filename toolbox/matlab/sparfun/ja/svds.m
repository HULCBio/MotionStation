% SVDS   ���ْl����
% 
% A ��M�sN��̏ꍇ�ASVDS(A,...) �� EIGS(B,...) �ŏo�͂����ŗL�l�ƌŗL
% �x�N�g���𑀍삵�AB = [SPARSE(M,M) A; A' SPARSE(N,N)] �̂Ƃ��ɁAA ��
% ���ْl�Ɠ��كx�N�g�������߂܂��B�Ώ̍s�� B �̐��̌ŗL�l�́AA �̓��ْl
% �Ɠ����ł��B
%
% S = SVDS(A) �́AA �̓��ْl�̂����傫��6���o�͂��܂��B
%
% S = SVDS(A,K) �́AA �̓��ْl�̂����傫�� K ���v�Z���܂��B
%
% S = SVDS(A,K,SIGMA) �́A�X�J���V�t�g SIGMA �̋ߖT�� K �̓��ْl��
% �v�Z���܂��B���Ƃ��΁AS = SVDS(A,K,0) �́A���ْl�̂��������� K ��
% �v�Z���܂��B
%
% S = SVDS(A,K,'L') �́A���ْl�̂����ő�� K ���v�Z���܂�(�f�t�H���g)�B
%
% S = SVDS(A,K,SIGMA,OPTIONS) �́A�p�����[�^��ݒ肵�܂�(EIGS ���Q��)�B
%
% �t�B�[���h��	   �p�����[�^	                         �f�t�H���g
%
% OPTIONS.tol      �����̋��e�l�B                         1e-10
%                  NORM(A*V-U*S,1) < =  tol * NORM(A,1)
% OPTIONS.maxit    �ő唽�����B               	          300
% OPTIONS.disp     �e�J��Ԃ��ŕ\��������ْl�̐��B       0
%
% [U,S,V] = SVDS(A,...) �́A���كx�N�g�����v�Z���܂��BA ��M �s N ��ŁA
% K �̓��ْl���v�Z�����ƁAU �͗񂪐��K������ M �s K ��̍s��ŁAS �� 
% K �s K ��̑Ίp�s��AV �͗񂪐��K������ N �s K ��̍s��ł��B
%
% [U,S,V,FLAG] = SVDS(A,...) �́A�����̃t���O���o�͂��܂��BEIGS ������
% ����΁ANORM(A*V-U*S,1) < =  TOL * NORM(A,1) �ŁAFLAG ��0�ł��BEIGS ��
% �������Ȃ���΁AFLAG ��1�ł��B
%
% ����: SVDS �́A�傫���X�p�[�X�s��̓��ْl�����߂邽�߂̍ł��ǂ����@
% �ł��B���̂悤�ȍs��̂��ׂĂ̓��ْl�����߂邽�߂ɂ́ASVD(FULL(A))
% �́ASVDS(A,MIN(SIZE(A))) �����K���Ă��܂��B
%
% ���:
%    load west0479
%    sf = svd(full(west0479))
%    sl = svds(west0479,10)
%    ss = svds(west0479,10,0)
%    s2 = svds(west0479,10,2)
%
% sl �͍~����10�̓��ْl���܂ރx�N�g���ŁAss �͏�����10�̓��ْl���܂�
% �x�N�g���ŁAs2 ��2�̋ߖT��west0479��10�̓��ْl���܂ރx�N�g���ł��B
%
% �Q�l�FSVD, EIGS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:38 $
