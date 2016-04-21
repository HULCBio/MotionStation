% SPCOL B-�X�v���C���I�_�s��
%
% COLLOC = SPCOL(KNOTS,K,TAU) �́A�s��
%
%      [ D^m(i)B_j(TAU(i)) : i=1:length(TAU), j=1:length(KNOTS)-K ] ,
%
% �ł��B�����ŁAD^m(i)B_j �� B_j ��m(i)�������AB_j �́A�ߓ_�� KNOTS ��
% �΂��鎟�� K ��j�Ԗڂ�B-�X�v���C���ATAU �̓T�C�g�̗�ł��BKNOTS �� 
% TAU �́A���ɔ񌸏��ł���Ɖ��肵�܂��B
% ����ɁAm(i) �́A���� #{ j<i : TAU(j) = TAU(i) }�A���� TAU �ɂ����� 
% TAU(i) �̗ݐϑ��d�x�ł��B
%
% ����́ACOLLOC �̑�j�񂪁A�� KNOTS �ɑ΂��鎟�� K ��B-�X�v���C����
% j�ԖځA���Ȃ킿�A�ߓ_�� KNOTS(j:j+K) �Ƃ���B-�X�v���C���̃x�N�g�� 
% TAU �̂��ׂĂ̗v�f�ɂ�����l�ƁA���Ƃɂ��Ɣ������܂ނ��Ƃ��Ӗ����܂��B
% COLLOC ��i�Ԗڂ̍s�́A������B-�X�v���C�����ׂĂ�m(i)�������� TAU(i) 
% �ł̒l���܂݂܂��B�����ŁAm(i) �́ATAU(i) �ɓ����� TAU �̑O�̗v�f�̐�
% �ł��B
%
% ���:
%  tau = [0,0,0,1,1,2];          % �]���āAm �� [0,1,2,0,1,0] �ɓ�����
%                                % �Ȃ�܂��B
%  k = 3; knots = augknt(0:2,k); % �]���āAknots �� [0,0,0,1,2,2,2] ��
%  colloc = spcol(knots,k,tau)   % �������Ȃ�܂��B
%
% �����ŁACOLLOC(:,j)  ��6�̗v�f���܂ނ̂́A0�ł� B_j �̒l�ƁA1���A
% 2�������A���ꂩ��A1�ł� B_j �̒l��1�������A�Ō��2�ł� B_j �̒l�ł��B
% ������ B_j �́A�ߓ_�� knots �ɑ΂���k����B-�X�v���C����j�ԖڂŁA����
% ���΁AB_2 �́Aknots �� B_j �� 0,0,1,2 �Ƃ���B-�X�v���C���ł��B
%
% �w�肵���l�ƁA�ꍇ�ɂ���ẮA�w�肵���T�C�g�ł̂������̔���������
% �X�v���C�����쐬���邽�߂� COLLOC ���g�p���邱�Ƃ��ł��܂��B
% 
% ���:
%      a = -pi; b = pi;  tau = [a a a 0 b b]; k = 5;
%      knots = augknt([a,0,b],k);
%      sp = spmak(knots, ( spcol(knots,k,tau) \ ...
%          [sin(a);cos(a);-sin(a);sin(0);sin(b);cos(b)] ).' )
%
% �́A0�ł��傤��1�̓����ߓ_������� [a,b] ��ł�2���̃X�v���C����
% �^���܂��B���̃X�v���C���� a,0,b �ɂ����āA�����֐����Ԃ��A�܂��Aa ��
% ������1�������2���������A������ b �ɂ�����1����������v�����܂��B
%
% COLLOC = SPCOL(KNOTS,K,TAU,ARG1,ARG2,...) �́A�I�v�V�����̈��� ARG1, 
% ARG2, ... �Ɉˑ�����A���������邢�͊֘A����s���^���܂��B
%
% �I�v�V����������1�� 'slvblk' �̏ꍇ�ACOLLOC �́ASLVBLK �ŕK�v�Ƃ����
% (�X�v���C���ɑ΂��Ďw�肳�ꂽ)�قڃu���b�N�Ίp�Ȍ`���ł��B
%
% �I�v�V����������1�� 'sparse' �̏ꍇ�ACOLLOC �́A�X�p�[�X�s��ł��B
%
% �I�v�V����������1�� 'noderiv' �̏ꍇ�A���d�x�͖�������܂��B���Ȃ킿�A
% ���ׂĂ� i �ɑ΂��� m(i) = 0 �ł��B
%
% B-�X�v���C���̑Q�����́A�s��̗v�f�𐶐����邽�߂Ɏg�p����܂��B
%
% ���:
%      t = [0,1,1,3,4,6,6,6]; x = linspace(t(1),t(end),101); 
%      c = spcol(t,3,x); plot(x,c)
%
% �́A�^����ꂽ�ߓ_�� t �ɑ΂���j�Ԗڂ�2����B-�X�v���C���̒l�̓K�؂ȗ��
% c(:,j) �ɐ������邽�߂� SPCOL ���g�p���܂��B
%
% �Q�l : SLVBLK, SPARSE, SPAPI, SPAP2, BSPLINE.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
