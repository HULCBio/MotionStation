% RANDSAMPLE   ����וW�{�̕������o�܂��͔񕜌����o
%
% Y = RANDSAMPLE(N,K) �́A���� 1:N ����A(�񕜌���)��l������ׂ�
% ���o���ꂽ�l��1�sK��̃x�N�g���Ƃ��� Y ���o�͂��܂��B
%
% Y = RANDSAMPLE(POPULATION,K) �́A�x�N�g�� POPULATION ���̒l����A
% (�񕜌���)��l������ׂɒ��o���ꂽ K �̒l���o�͂��܂��B
%
% Y = RANDSAMPLE(...,REPLACE) �́AREPLACE ���^�̏ꍇ�A�������o���s���A 
% REPLACE ���U(�f�t�H���g)�̏ꍇ�A�񕜌��̕W�{���o�͂��܂��B
%
% Y = RANDSAMPLE(...,true,W) �́A���̏d�� W ��p���ďd�ݕt�����ꂽ�W�{��
% �o�͂��܂��BW �́A�����̏ꍇ�A�m���̃x�N�g���ł��B���̊֐��́A��������
% �d�݂��̕W�{���T�|�[�g���Ă��܂���B
%
% ���:  �w�肳�ꂽ�m���ɂ�蕜�����g���āA�L�����N�^ ACGT �̃����_����
%        �n��𐶐����܂��B
%
%      R = randsample('ACGT',48,true,[0.15 0.35 0.35 0.15])
%
% �Q�l : RAND, RANDPERM.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/18 17:33:20 $
