% CLUSTERDATA   �f�[�^����N���X�^���쐬
%
% T = CLUSTERDATA(X, CUTOFF) �́A�f�[�^X ����A�N���X�^���쐬���܂��B
% X �́A�傫��M�~N �̍s��ł���AN �̕ϐ��ɑ΂��āAM �̊ϑ��l�Ƃ���
% ��舵���܂��BCUTOFF �́ALINKAGE�ɂ�萶�������K�w�I�ȃc���[��
% �N���X�^�փJ�b�g���邵�����l�ł��B
% 0 < CUTOFF < 2 �̏ꍇ�A�N���X�^�́Ainconsistent�l�� �ACUTOFF ���
% �傫���ꍇ�ɍ쐬����܂� (INCONSISTENT�Q��)�B
% CUTOFF ���A�����ŁACUTOFF >= 2�ł���ꍇ�ACUTOFF �́ALINKAGE�ɂ��
% �쐬�����K�w�I�ȃc���[���ɕۂ����N���X�^�̍ő�̐��ƍl�����܂��B
% �o�� T �́A�e�ϑ��ɑ΂���N���X�^�����܂ޑ傫�� M �̃x�N�g���ł��B
%
% T = CLUSTERDATA(X,CUTOFF) �́A���̃X�e�[�g�����g�Ɠ����ł��B
%     Y = pdist(X, 'euclid');
%     Z = linkage(Y, 'single');
%     T = cluster(Z, 'cutoff', CUTOFF);
%
% T = CLUSTERDATA(X,'PARAM1',VAL1,'PARAM2',VAL2,...) �́A�p�����[�^/�l
% �̑g�ɂ��ݒ�@���g���āA�N���X�^����ɑ΂��āA���R���g���[���\
% �ɂȂ�܂��B�g�p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B:
%
%     �p�����[�^   �l
%     'distance'   PDIST�ŁA�����ꂽ distance metric ���̂����ꂩ�B
%                   (�I�v�V����'minkowski'�ɂ́A�w�� P �̒l�𑱂��邱�Ƃ�
%                    �ł��܂�)�B
%     'linkage'    LINKAGE�ŋ������linkage�@�B
%     'cutoff'     inconsistent���邢��distance measure�ɑ΂���J�b�g�I�t�B
%     'maxclust'   �쐬����N���X�^�̍ő�̐��B
%     'criterion'  'inconsistent'�A���邢�́A'distance' �̂����ꂩ�B
%     'depth'      inconsistent�l�̌v�Z�̂��߂̐[���B
%   
% �Q�l : PDIST, LINKAGE, INCONSISTENT, CLUSTER, KMEANS.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $
