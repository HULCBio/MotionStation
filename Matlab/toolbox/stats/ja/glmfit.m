% GLMFIT   ��ʉ����`���f���̂��Ă͂�
%
% B=GLMFIT(X,Y,DISTR) �́A�\���ϐ��s��X�A����Y�A���zDISTR�Ɉ�ʉ����`
% ���f�������Ă͂߂܂��B�o��B�́A�W������l�̃x�N�g���ł��B�w��\��
% ���z�́A'normal'�A'binomial'�A'poisson'�A'gamma'�A'inverse gaussian'
% �ł��B
% ���z�p�����[�^�́A���������N���g����X�̗�̊֐��Ƃ��Ă��Ă͂߂܂��B
%
% B=GLMFIT(X,Y,DISTR,LINK,'ESTDISP',OFFSET,PWTS,'CONST')�́A�œK����
% ���Ă���ɂ��ߍׂ����R���g���[�����܂��BLINK�́A���������N�̑����
% �g���郊���N�֐��ł��B'ESTDISP'�́A�W���덷�̌v�Z�œ񍀕��z�܂���
% �|���\�����z�̕��U�p�����[�^�𐄒肷��Ƃ�'on'�ɂ��A���_�I�ȕ��U�p��
% ���[�^�l���g���Ƃ���'off'�ɂ��܂�(���肳�ꂽ���U�́A��ɑ��̕��z��
% �g���܂��j�BOFFSET �́A1.0�ƌŒ肳�ꂽ�W���l�ł���t���I�ȗ\���q��
% ���Ďg����x�N�g���ł��BPWTS�́AX��Y�̊e����l�̐U���ƂȂ�悤�ȁA
% ���炩���ߗ^����ꂽ�d�݂̃x�N�g���ł��B'CONST'�́A�萔���𐄒肷��
% �ꍇ�A'on' (�f�t�H���g)�ɂ��A�ȗ�����ꍇ�A'off'�ɂ��Ă��������B�萔
% ���̌W���́AB�̍ŏ��̗v�f�ł��B(X�̍s����ɒ���1�̗����͂��Ȃ���
% ������)
%
% LINK �́A���z�p�����[�^mu�Ɨ\���q xb �̐��`�����̊Ԃ� f(mu) = xb ��
% ���Ē�`�����֐�f���`���܂��BLINK�Œ�`�����f�͈ȉ��̂����ꂩ��
% �Ȃ�܂��B
%    - ���̕����� 'identity'�A'log'�A'logit'�A'probit'�A
%      'comploglog'�A'reciprocal'�A'logloglink'
%    - ����P�Bmu = xb^P �Ƃ��Ē�`����܂�
%    - {@FL @FD @FI}�̌`���̃Z���z��B3�̊֐��̓����N(FL)�A�����N��
%      ���֐�(FD)�A�����N�̋t�֐�(FI)���`���܂��B
%    - �����N�A���֐��A�t�֐������N���`���邽�߂�3��inline�֐��̃Z���z��
%
% [B,DEV,STATS]=GLMFIT(...) �́A�ǉ��̌��ʂ��o�͂��܂��BDEV�́A�𑜓x
% �x�N�g���̕Ε��ł��BSTATS�́A�ȉ��̃t�B�[���h���܂܂��\���̂ł��B
% dfe(�덷�̎��R�x)�As(���_�l�܂��͐���l�̕��U�p�����[�^)�A
% sfit(����l�̕��U�p�����[�^)�Ase(�W������lb�̕W���덷�̃x�N�g��)�A 
% coeffcorr(b�̑��֍s��)�At(b�̂����v��)�Ap(b��p-�l)�A
% resid(�c���̃x�N�g��)�Aresidp(Pearson�c���̃x�N�g��)�A
% residd(�Ε��c���̃x�N�g��)�Aresida(Anscombe�c���̃x�N�g��)
%
% ���:
%	    b = glmfit(x, [y N], 'binomial', 'probit')
%      ���̗���x��y�ɑ΂���probit��A�ɂ��Ă͂߂܂��B�e�X��y(i)�́A
%      N(i)�̎��s�ł̐������ł��B
%
% �Q�l : GLMVAL, REGRESS.


%   Author:  Tom Lane, 2-8-2000
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:12:10 $
