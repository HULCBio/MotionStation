% ECDF   �o���ݐϕ��z�֐�(Kaplan-Meier)
%
% [F,X] = ECDF(Y) �́A�o���I�� cdf �Ƃ��Ă��m����A�ݐϕ��z�֐�(cdf)��
% Kaplan-Meier ������v�Z���܂��BY �́A�f�[�^�l�̃x�N�g���ł��BF �́A
% X �ɂ����ċ��߂��o���I�� cdf �l�̃x�N�g���ł��B
%
% [F,X,FLO,FUP] = ECDF(Y) �́Acdf �ɑ΂���M����������я�����o�͂��܂��B
% �����͈̔͂́AGreenwood �̌������g���Čv�Z����A�����M����Ԃł�
% ����܂���B
%
% [...] = ECDF(Y,'PARAM1',VALUE1,'PARAM2',VALUE2,...) �́A�ȉ�����I��
% ���ꂽ ���O/�l �̑g�ݍ��킹�ŕt���I�ȃp�����[�^���w�肵�܂��B
%
%      ���O          �l
%      'censoring'   ���m�Ɋϑ����ꂽ�ϑ��l�ɑ΂���0���A�E���ł��؂��
%                    �ϑ��l�ɑ΂���1�ƂȂ�AX �Ɠ����傫���̘_���x�N�g��
%                    �ł��B�f�t�H���g�ł́A�S�Ă̊ϑ��l���Ō�܂Ŋϑ�
%                    ����܂��B
%      'frequency'   �񕉂̐����J�E���g���܂܂�� X �Ɠ����傫���̃x�N
%                    �g���ł��B���̃x�N�g����j�Ԗڂ̗v�f�́AX ��j�Ԗڂ�
%                    �v�f���ϑ����ꂽ�񐔂������܂��B�f�t�H���g��X��
%                    �v�f���Ƃ̊ϑ��l�ɑ΂���1�ł��B
%      'alpha'       100*(1-alpha)% �̐M�����x���ɑ΂���0����1�̊Ԃ̒l
%                    �ł��B�f�t�H���g�� 95% �̐M����\�� alpha=0.05 ��
%                    �Ȃ�܂��B
%      'function'    'cdf' (�f�t�H���g)�A'survivor'�A�܂��� 'cumulative 
%                    hazard' ����I�����ꂽ�A�o�͈��� F �Ƃ��ĕԂ����
%                    �֐��̃^�C�v�ł��B
%
% ���: �����_���Ȍ̏�񐔂ƁA�����_���ȑł��؂�񐔂𐶐����A���m��
% ����^�� cdf ��p���āA�o���I�� cdf �Ɣ�r���܂��B
%
%       y = exprnd(10,50,1);     % �����_���Ȍ̏�� exponential(10)
%       d = exprnd(20,50,1);     % �h���b�v�A�E�g������ exponential(20)
%       t = min(y,d);            % �����̉񐔂̍ŏ��l���ϑ�
%       censored = (y>d);        % �Ώۂ����s�������ǂ������ϑ�
%
%       % �o���I�� cdf �ƐM����Ԃ��v�Z���\�����܂��B
%       [f,x,flo,fup] = ecdf(t,'censoring',censored);
%       stairs(x,f);
%       hold on;
%       stairs(x,flo,'r:'); stairs(x,fup,'r:');
%
%       % ���m�ł���^�� cdf �̃v���b�g���d�˕`�����܂��B
%       xx = 0:.1:max(t); yy = 1-exp(-xx/10); plot(xx,yy,'g-')   
%       hold off;
%
% �Q�l : CDFPLOT.


% Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/11/26 19:56:09 $

