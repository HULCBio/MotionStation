% CDFPLOT   �W�{�̌o���I�ȗݐϕ��z�֐���\��
%
% CDFPLOT(X) �́A�f�[�^�T���v���x�N�g�� X �̒��̊ϑ��l�̌o���I�ȗݐϕ��z
% �֐�(CDF)���v���b�g���܂��BX �́A�s�x�N�g���ł��A��x�N�g���ł��\��
% �܂���B�����āA���镪�z�̊�ŁA�ϑ����ꂽ�����_���ȃT���v����\�킵��
% ����Ƃ��܂��B
% 
% H = CDFPLOT(X) �́AX �̒��̃f�[�^�ɑ΂��Čo���I��(�܂��́A�W�{)�ݐ�
% ���z�֐� F(X) ���v���b�g���܂��B�o���I�ȗݐϕ��z�֐� F(x) �́A����
% �悤�ɒ�`����܂��B�W�{�x�N�g�� x �̂��ׂĂ̒l�ɑ΂��āA
% 
%   F(x) = (x ��菬�������������ϑ��l�̐� )/(�ϑ�����)
% 
% X �� NaN �ŕ\�킹�錇���l���܂�ł���ꍇ(IEEE �ł́ANaN �ŕ\���㐔
% �\��)�A�����̊ϑ��ʂ́A��������܂��B
% 
% H �́A�o���I�ȗݐϕ��z�֐���(Line �I�u�W�F�N�g��)�n���h���ԍ��ł��B
% 
% [H,STATS] = CDFPLOT(X) �́A���̃t�B�[���h�ɓ��v�ʂ��܂Ƃ߂��\���̂�
% �o�͂��܂��B
% 
%       STATS.min    = �x�N�g�� X �̍ŏ��l
%       STATS.max    = �x�N�g�� X �̍ő�l
%       STATS.mean   = �x�N�g�� X �̕��ϒl
%       STATS.median = �x�N�g�� X �̒����l
%       STATS.std    = �x�N�g�� X �̕W���΍�
% 
% �ʓI�Ȏ��o���ɉ����A�o���I�ȗݐϕ��z�֐��́AKolmogorov-Smirnov �����
% �悤�ȁA���蓝�v�ʂ��A���肵�����_�I�ȗݐϕ��z�֐�����傫�������
% ����悤�ȉ�������̓K���x������ꍇ�ɗL���Ȃ��̂ł��B
% 
% �Q�l : QQPLOT, KSTEST, KSTEST2, LILLIETEST


% Author(s): R.A. Baker, 08/14/98
% Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $   $ Date: 1998/01/30 13:45:34 $
