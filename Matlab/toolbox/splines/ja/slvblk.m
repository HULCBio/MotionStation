% SLVBLK   �u���b�N�Ίp���`�V�X�e���̉�@
%
% SLVBLK(BLOKMAT,B) �́A�قڃu���b�N�Ίp�Ȍ^�̃X�v���C����(���Ƃ��΁A
% SPCOL �ŏo�͂����悤��) BLOKMAT �Ɋi�[���ꂽ�s�� A �������`�V�X�e�� 
% A*X=B �̉���(���������)�o�͂��܂��B
%
% �V�X�e�����ߌ���(���Ȃ킿�������̐������m����������)�̏ꍇ�A
% �ŏ��������o�͂���܂��B 
%
% SLVBLK(BLOKMAT,B,W) �́A�d�ݕt�� l_2 �̘a���ŏ�������x�N�g�� X ��
% �o�͂��܂��B
%
%      sum_j W(j)*( (A*X-B)(j) )^2 .
%
% ����́A�V�X�e�����ߌ���̏ꍇ�A�L���ł��B
% W �ɑ΂���f�t�H���g�́A�� [1,1,1,...]�ł��B
%
% ���:
% ���̃X�e�[�g�����g�ł́A����m�C�Y�̓������f�[�^�𐶐����܂��B
% ���ꂩ��A2�̓��Ԋu�ɕ��񂾐ߓ_�����L���[�r�b�N�X�v���C���ɂ��
% �f�[�^�ɑ΂��āASLVBLK ��p���ĕ�����`���̏d�݂ɂ���ďd�ݕt����ꂽ
% �ŏ�2��ߎ������肵�A���ʂ��v���b�g���܂��B
%   
%      rand('seed',27);
%      x = [0,sort(rand(1,31)),1]*(2*pi);
%      y = sin(x)+(rand(1,33)-.5)/10;
%      k = 4; knots = augknt(linspace(x(1),x(end),3),k);
%      dx = diff(x); w = ([dx 0] + [0 dx])/2;
%      sp = spmak(knots,slvblk(spcol(knots,k,x,'slvblk','noderiv'),y.',w).');
%      fnplt(sp,2); hold on, plot(x,y,'ok'), hold off
%
% �Q�l : SPCOL, SPAPS, SPAPI, SPAP2.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
