% FEATHER   �t�F�U�[�v���b�g
% 
% FEATHER(U,V) �́A�����ɉ��������Ԋu�̓_����o�͂������Ƃ��āAU �� 
% V �̐����������x�x�N�g�����v���b�g���܂��BFEATHER �́A�p�X�ɉ�����
% �I�����ꂽ�����Ƌ��x�f�[�^��\������̂ɕ֗��ł��B
%
% FEATHER(Z) �́A���f�� Z �ɑ΂��āAFEATHER(REAL(Z),IMAG(Z)) �Ɠ����ł��B
% FEATHER(...,'LineSpec') �́A'LineSpec' �Ŏw�肵���J���[�ƃ��C���X�^�C��
% ���g�p���܂�(�g�p�\�Ȓl�ɂ��Ă�PLOT ���Q��)�B
%
% FEATHER(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = FEATHER(...) �́Aline�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g����
% �o�͂��܂��B
%
% ���:
%      theta = (-90:10:90)*pi/180; r = 2*ones(size(theta));
%      [u,v] = pol2cart(theta,r);
%      feather(u,v), axis equal
%
% �Q�l�FCOMPASS, ROSE, QUIVER.


%   Charles R. Denham, MathWorks 3-20-89
%   Modified 1-2-92, ls.
%   Modified 12-7-93 Mark W. Reichelt
%   Copyright 1984-2002 The MathWorks, Inc. 
