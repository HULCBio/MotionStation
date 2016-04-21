% TPAPS   Thin-plate�������X�v���C��
%
% F = TPAPS(X,Y) �́A�^����ꂽ�f�[�^�T�C�g X(:,j) �Ƃ���ɑΉ�����f�[�^
% �l Y(:,j) �ɑ΂���thin-plate�������X�v���C�� f �� st-�^�ł��B
% �f�[�^�l�́A�X�J���A�x�N�g���A�s��A�܂���N�����z��ł��B
% X(:,j) �́A���ʓ��̈قȂ�_�ł���A�f�[�^�T�C�g�ƌ����ɓ������̃f�[�^�l
% ���Ȃ���΂Ȃ�܂���B
% thin-plate�������X�v���C�� f �́A�d�ݕt���a
%
%                     P*E(f) + (1-P)*R(f) ,
%
% �̂�����̃~�j�}�C�U�ł��B�����ŁAE(f) �́A�덷��ł��B
%
%       E(f) :=  sum_j { | Y(:,j) - f(X(:,j)) |^2 : j=1,...,n }
%
% ����ɁAR(f) �́A���̑e��(roughness)��ł��B
%
%       R(f) := integral  (D_1 D_1 f)^2 + 2(D_1 D_2 f)^2 + (D_2 D_2 f)^2.
%
% �����ŁA�ϕ��́A2�̋�ԑS�̂ɓn���čs���܂��BD_i �́Ai�Ԗڂ̈�����
% �ւ�������������܂��B���̂��߁A�ϕ��́Af ��2��������K�v�Ƃ��܂��B
% �������p�����[�^ P �́A�T�C�g X �Ɉˑ�����ʂ̕��@�őI������܂��B
%
% TPAPS(X,Y,P) �́A0��1�̊Ԃ̐��ł���A�������p�����[�^ P ��^���܂��B
% P ��0����1�܂ŕω�����Ƃ��A�f�[�^�ɑ΂��镽�����X�v���C���́A P ��
% 0�̂Ƃ��̐��`�������ɂ��ŏ����ߎ�����AP ��1�̂Ƃ���thin-plate
% �X�v���C����Ԃ܂ŕω����܂��B
%
% [F,P] = TPAPS(...) �́A�g�p���ꂽ�������p�����[�^���o�͂��܂��B
%
% �x��: �������X�v���C���̌���ɂ́A���݂���f�[�^�_�Ɠ������̖��m����
% �����`�V�X�e���̉����K�v�ł��B���̐��`�V�X�e���̍s��̓t���̂��߁A
% ����������ɂ́A728 �ȏ�̃f�[�^�_�����݂��A�J��Ԃ��̃X�L�[�����g�p
% ����邱���ł̏ꍇ�ł����������Ԃ�������܂��B���̌J��Ԃ��̎�����
% �����́AP �ɂ���ċ����e�����󂯁AP ���傫���قǊɂ₩�ɂȂ�܂��B
% �]���āA��K�͂Ȗ��ɑ΂��ẮA���ԓI�]�T������ꍇ�̂݁A(P ��1�Ƃ���)
% ��Ԃ��g�p���Ă��������B 
%
% ���:
%
%      rand('seed',23); nxy = 31;
%      xy = 2*(rand(2,nxy)-.5); vals = sum(xy.^2);
%      noisyvals = vals + (rand(size(vals))-.5)/5;
%      st = tpaps(xy,noisyvals); fnplt(st), hold on
%      avals = fnval(st,xy);
%      plot3(xy(1,:),xy(2,:),vals,'wo','markerfacecolor','k')
%      quiver3(xy(1,:),xy(2,:),avals,zeros(1,nxy),zeros(1,nxy), ...
%               noisyvals-avals,'r'), hold off
% �́A 31�̃����_���ȃT�C�g�ŁA���Ɋ��炩�Ȋ֐��̒l�𐶐����āA����
% �m�C�Y�������A�����āA�����̃m�C�Y�̂���f�[�^�ɑ΂��āA�������X�v
% ���C�����쐬���܂��B�Č����悤�Ƃ��Ă��錳�̃f�[�^�̌����Ȓl(����)�ƁA
% �������X�v���C���ŕ��������ꂽ�l����m�C�Y�̂���l�ɒB�������
% �v���b�g���܂��B 
%
%      n = 64; t = linspace(0,2*pi,n+1); t(end) = [];
%      values = [cos(t); sin(t)];
%      centers = values./repmat(max(abs(values)),2,1);
%      st = tpaps(centers, values, 1);
%      fnplt(st), axis equal
% �́A�������ꂽ�}�Ɏ������悤�ɁA�P�ʐ����` 
% {x in R^2: |x(j)|<=1, j=1:2} �̓_��P�ʉ~�� {x in R^2: norm(x)<=1} 
% ��ɁA���Ȃ��v����悤�Ɉڂ��A���ʂ��畽�ʂւ̎ʑ�����}���܂��B
%
% �Q�l : CSAPS, SPAPS.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
