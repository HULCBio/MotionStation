% SPAPS   �������X�v���C��
%
% [SP,VALUES] = SPAPS(X,Y,TOL)�́A�f�[�^ X, Y �ւ̃L���[�r�b�N������
% �X�v���C�� f ��B-�^�ƁA�K�v�ł���΁AX �ł̒l���o�͂��܂��B
% �������X�v���C���́Aj=1:length(X) �Ƃ��āA�^����ꂽ�f�[�^�l Y(:,j) 
% ���f�[�^�T�C�g X(j) �ŋߎ����܂��B�f�[�^�l�́A�X�J���A�x�N�g���A�s��A
% �܂���N�����z��ł��B
% �����T�C�g�̃f�[�^�_�́A������(���d)���ςɂ���Ēu���������A
% ���e�덷 TOL �́A����ɉ����Č������܂��B
%
% �������X�v���C�� f �́A�덷�
%
%       E(f) :=  sum_j { W(j)*( Y(:,j) - f(X(j)) )^2 : j=1,...,n }
%
% �� TOL �Ɣ�ׂď������傫���Ȃ����ׂĂ̊֐� f ��ŁA�e��(roughness)
% �
%
%       F(D^M f) := integral |D^M f(t)|^2 dt  on  min(X) < t < max(X)
%
% ���ŏ��ɂ��܂��B
%
% �����ŁAX �� Y �́A�����T�C�g�����C�ӂ̃f�[�^�_���A�Ή�����d�݂�
% �a���d�݂Ƃ��邻���̕��ςɂ���āA�u�����������ʂł��B�܂��A�^��
% ��ꂽ TOL �́A����ɑ΂��Č�������܂��B
% D^M f �́Af ��M�������������܂��B
% �d�� W �́AE(f) �� F(y-f) �ɑ΂��镡����`���̋ߎ��ɂȂ�悤�ɑI��
% ����܂��B
% ���� M �́A2���I������܂��B�]���āAD^M f �́Af ��2�������ł��B M ��
% ���̑I���ɂ��Af �̓L���[�r�b�N�������X�v���C���ł��B
% ����́Af ���AE(f) �� TOL ���������Ȃ�悤�I�����ꂽ�������p�����[�^ 
% RHO ������
%
%                     rho*E(f) + F(D^2 f) ,
%
% �̃��j�[�N�ȃ~�j�}�C�U�Ƃ��č\������邽�߂ł��B
% �䂦�ɁAFN2FM(SP,'pp') �́ACPAPS(X,Y,RHO/(1+RHO)) ����̏o�͂�(�ۂ߂܂�)
% �����ɂȂ�K�v������܂��B
%
% [SP,VALUES,RHO] = SPAPS(X,Y,...) �́ARHO ���o�͂��܂��B
%
% TOL ��0�̂Ƃ��A�ϓ������ԃL���[�r�b�N�X�v���C���������܂��B
% TOL �����ł���ꍇ�A-TOL �́A�g�p����� RHO �̒l�Ƃ��ĉ��߂���܂��B
%
% �f�[�^�l Y(:,j) ���A�X�J���ł͂Ȃ��A�傫�� d �ł���Ƃ��A�e t �ɑ΂��āA
% f(t) �� D^M f(t) ���܂��傫�� d �ł��B�]���āA�S�̂�prod(d)�̗v�f��
% �����A�� |Y(:,j) - f(X(j))|^2 �� |D^M f(t)|^2 ���A������prod(d)��
% �v�f�̓��a���������ƂɂȂ�܂��B
%
% �O���b�h�����ꂽ�f�[�^�̏ꍇ�́A�ȉ��Ř_���܂��B
%
% ���:
%
%      x = linspace(0,2*pi,21); y = sin(x) + (rand(1,21)-.5)*.2;
%      sp = spaps(x,y, (.05)^2*(x(end)-x(1)) );
%
% �́A���݂���m�C�Y�̂Ȃ��f�[�^�ɂ��Ȃ�߂����Ƃ��\�z�����A�m�C�Y�t��
% �f�[�^�ւ̋ߎ����o�͂��܂��B����́A���݃f�[�^���������ω�����֐�����
% �Ȃ�A�g�p����� TOL ���m�C�Y�̑傫���ɑ΂��K���ȑ傫���ł��邽�߂ł��B
%
%   SPAPS(X,Y,TOL,W)
%   SPAPS(X,Y,TOL,M)
%   SPAPS(X,Y,TOL,W,M)
%   SPAPS(X,Y,TOL,M,W)
% ����炷�ׂẮAM = 1(���`)����� M = 3(5��)(�f�t�H���g�� M = 2�Ƃ͕ʂ�)
% �Ƃ��Č��ݐ�������Ă��� M ���AW �����/�܂��� M �ɖ����I�ɗ^���܂��B
%
% TOL ���X�J���ł͂Ȃ��ނ����Ƃ��邱�Ƃɂ��A���炩���̗v����ς���
% ���Ƃ��\�ł��B���̏ꍇ�A�e��(roughness)��́A���̎��œ����܂��B
%
%                    integral lambda(t) (D^M f(t))^2 dt ,
%
% �����ŁAlambda �́A�u���[�N�|�C���g X �����敪�I�Ȓ萔�֐��ŁA����
% ��� (X(i-1) .. X(i)) �ł̒l�́A���ׂĂ� i �ɂ����� TOL(i) �ł��B����A
% TOL(1) �́A���������v������鋖�e�덷 TOL �Ƃ��ĉ��߂���܂��B
%
% ���:
%
%    sp1 = spaps(x,y, [(.025)^2*(x(end)-x(1)),ones(1,10),repmat(.1,1,10)] );
%
% �́A�O�̗�Ɠ����f�[�^�Ƌ��e�덷���g�p���܂����A�e��(roughness)�̏d�݂�
% ��Ԃ̉E�����ł�����.1�ɂ��邱�ƂŁA�����ł͍r������ǂ����K�؂�
% �t�B�b�e�B���O��^���܂��B
% ��r�̂��߂ɗ����̗�������v���b�g�́A���ɂ�蓾���܂��B
%
%    fnplt(sp); hold on, fnplt(sp1,'r'), plot(x,y,'ok'), hold off
%    title('Two cubic smoothing splines')
%    xlabel('the red one has reduced smoothness requirement in right half.')
%
% SPAPS({X1,...,Xr},Y,...) �́Ar�̃x�N�g�� X1, ..., Xr �ɂ���Ďw��
% �����r���������`�̊i�q��̃f�[�^�l Y �ɑ΂��镽�����X�v���C����^��
% �܂��B�����̃x�N�g�� X1, ..., Xr �́A�قȂ钷��������������܂���B
% Y �́A[d,length(X1), ..., length(Xr)] �̑傫���������܂��B
% Y ���Ar�����̔z��ł��邪�A[length(X1), ..., length(Xr)] �̑傫����
% �ꍇ�Ad �́A[1] �ł���Ɖ��߂���܂��B���Ȃ킿�A�֐��́A�X�J���l�ł��B
% �i�q�f�[�^�̏ꍇ�A�I�v�V�����̈��� M �́A1�̐����ł��邩�A���邢�́A 
% (�W��{1,2,3}�����)������r�v�f�̃x�N�g���ł��B�܂��A�I�v�V�����̈��� 
% W �́A���� r �̃Z���z��ł��邱�Ƃ��v������܂��B������ W{i} ��(�f�t�H
% ���g�̑I���𓾂邽��)�ɋ󂩁A���邢�́Ai=1:r �� X{i} �Ɠ���������
% �x�N�g���̂����ꂩ�ł��B
% �܂��A���̏ꍇ�A���� TOL ���Z���z��łȂ���΁ATOL �́Ar�̕K�v��
% ���e�덷���w�肷��r�v�f�̃x�N�g���ł��邩�A�����Ȃ��΁A�ŏ��̗v�f��
% r�̕ϐ����ꂼ��ɂ����ėv������鋖�e�덷�Ƃ��Ďg�p����Ȃ���΂Ȃ�
% �܂���B
%
% ���:
%      x = -2:.2:2; y=-1:.25:1; [xx,yy] = ndgrid(x,y); 
%      z = exp(-(xx.^2+yy.^2)) + (rand(size(xx))-.5)/30; 
%      sp = spaps({x,y},z,8/(60^2));  fnplt(sp)
%
% �́A2�ϐ��֐�����̃m�C�Y�̂���f�[�^�����炩�ɋߎ������}�𐶐����܂��B
% ������ NDGRID �ł͂Ȃ��AMESHGRID ���g�p����ƁA�G���[�ɂȂ�܂��B
%
% �Q�l : SPAPI, SPAP2, CSAPS, TPAPS.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.