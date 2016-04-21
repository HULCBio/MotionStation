% ECDFHIST   �o���I�ݐϕ��z�֐�(ecdf)����q�X�g�O�������쐬
%
% N = ECDFHIST(F,X) �́A�o���I�ȗݐϕ��z�֐�(cdf)�l�̃x�N�g�� F �ƕ]���_
% �̃x�N�g�� X ��^���āA10�{�̓��Ԋu�ȃr���ɑ΂��ăq�X�g�O�����o�[��
% �������܂񂾃x�N�g�� N ���o�͂��܂��B�o�[�̍����́A�o���I�ȗݐϕ��z
% �֐��̑�������v�Z����A�e�o�[�ɑ΂���͈͂́A�Ή������Ԃɑ΂���
% �m����\���܂��B
% F ���ł��؂�ꂽ�W�{����v�Z���ꂽ�ꍇ�A���ׂĂ̊m���́A1��菬����
% �Ȃ�܂��B���̈���ŁAHIST �́A�������r���̑����ŁA�͈͂��m����\��
% �Ȃ��o�[�𐶐����܂��B
% 
% N = ECDFHIST(F,X,M) �́AM ���X�J���̏ꍇ�AM �̃r�����g�p���܂��B
% 
% N = ECDFHIST(F,X,C) �́AC ���x�N�g���̏ꍇ�A�w�肳�ꂽ C �ɂ�钆�S��
% �ʒu�̃r�����g�p���܂��B
% 
% [N,C] = ECDFHIST(...) �́AC �Ƀr���̒��S�̈ʒu���o�͂��܂��B
%
% ECDFHIST(...) �́A�o�͈������Ȃ��ƁA���ʂ̃q�X�g�O�����̃o�[�v���b�g
% �𐶐����܂��B
%
% ���:  �����_���Ȍ̏�񐔂ƁA�����_���ȑł��؂�񐔂𐶐����A���m��
% ����^�� pdf ��p���āA�o���I�� pdf �Ɣ�r���܂��B:
%
%       y = exprnd(10,50,1);     % �����_���Ȍ̏�� exponential(10)
%       d = exprnd(20,50,1);     % �h���b�v�A�E�g������ exponential(20)
%       t = min(y,d);            % �����̉񐔂̍ŏ��l���ϑ�
%       censored = (y>d);        % �Ώۂ����s�������ǂ������ϑ�
%
%       % �o���I�� cdf ���v�Z���A���ʂ��q�X�g�O������\�����܂��B
%       [f,x] = ecdf(t,'censoring',censored);
%       ecdfhist(f,x);
%       
%       % ���m�ł���^�� pdf �̃v���b�g���d�˕`�����܂��B
%       hold on;
%       xx = 0:.1:max(t); yy = exp(-xx/10)/10; plot(xx,yy,'g-');
%       hold off;
%
% �Q�l : ECDF, HIST, HISTC.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/09 21:47:22 $
