% MANOVACLUSTER    manova1�̏o�͂ŗp������O���[�v���ς̃N���X�^
%
% MANOVACLUSTER(STATS)�́AMANOVA1�����STATS�\���̂̏o�͂�single linkage 
% �A���S���Y���̓K�p�ɂ��v�Z���ꂽ�O���[�v���ς̃N���X�^�����O��\��
% ���邽�߂̎��`�}���쐬���܂��B���̊֐�����̃O���t�B�J���ȏo�͂Ɋւ���
% �ڍׂ́ADENDROGRAM ���Q�Ƃ��Ă��������B
%
% MANOVACLUSTER(STATS,METHOD)�́Aingle linkage�̑���� METHOD �A���S
% ���Y�����g���܂��B�\�Ȏ�@�͈ȉ��̂Ƃ���ł��B
%
%      'single'   --- �ł��߂�����
%      'complete' --- �ł���������
%      'average'  --- ���ϋ���
%      'centroid' --- �d�S�܂ł̋���
%      'ward'     --- �����̓��a
%
% H = MANOVACLUSTER(...)�́A���C���n���h���̃x�N�g����Ԃ��܂��B
%
% �Q�l : MANOVA1, DENDROGRAM, LINKAGE, PDIST, CLUSTER,
%        CLUSTERDATA, INCONSISTENT.


%   Tom Lane, 12-17-99
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $
