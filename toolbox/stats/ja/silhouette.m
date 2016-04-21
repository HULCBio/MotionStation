% SILHOUETTE   �N���X�^�f�[�^�̗֊s���v���b�g
%
% SILHOUETTE(X, CLUST) CLUST �Œ�`���ꂽ�N���X�^���ƂɁAN�~P �f�[�^
% �s�� X �ɑ΂���N���X�^�̗֊s���v���b�g���܂��BX �̍s�͓_�ɑΉ����A
% ��́A���W�ɑΉ����܂��BCLUST �́A�e�_�ɑ΂���N���X�^�̃C���f�b�N�X��
% �܂ސ��l�z�񂩁A�e�_�ɑ΂���N���X�^�����܂ޕ�����̃Z���z�񂩕����s��
% �ł��BSILHOUETTE �́A�����l�ɑ΂��Ă� CLUST ���� NaN ���󕶎����p���A
% X �̑Ή�����s�͖�������܂��B�f�t�H���g�ł́ASILHOUETTE �́AX �̓_��
% �� Euclidean �����̓����g�p���܂��B
%
% S = SILHOUETTE(X, CLUST) �́A�N���X�^�̗֊s��\�����܂��񂪁AN�~1 ��
% �x�N�g�� S �ɗ֊s�l���o�͂��܂��B
%
% [S,H] = SILHOUETTE(X, CLUST) �́A�֊s���v���b�g���A�֊s�l�� N�~1 ��
% �x�N�g�� S �Ƃ��āAfigure�̃n���h���� H �Ƃ��ďo�͂��܂��B
%
% [...] = SILHOUETTE(X, CLUST, DISTANCE) �́ADISTANCE �Ŏw�肳�ꂽ�_��
% �̋����̊���g���ė֊s���v���b�g���܂��BDISTANCE �͈ȉ��̂��̂���
% �I�����܂��B:
%
%     'Euclidean'    - Euclidean ����
%    {'sqEuclidean'} - Euclidean �����̓��
%     'cityblock'    - ��΋���(�ʖ� L1)�̘a
%     'cosine'       - 1����(�x�N�g���Ƃ��Ĉ���ꂽ)�_�̊Ԃ̊p�x��
%                      �R�T�C�����������l
%     'correlation'  - 1����(�l�̌n��Ƃ��Ĉ���ꂽ)�_�̊Ԃ̕W�{���ւ�
%                      �������l
%     'Hamming'      - �قȂ���W�̃p�[�Z���e�[�W
%     'Jaccard'      - �قȂ��[���̍��W�̃p�[�Z���e�[�W
%     vector         - PDIST �ō쐬���ꂽ�x�N�g���`���ł̐��l�I�ȋ���
%                      �s�� (X �́A���̏ꍇ�g�p���ꂸ�A���S�� [] ��ݒ�
%                      ���邱�Ƃ��\�ł�)
%     function       - @DISTFUN �̂悤�ɁA@ ��p���Ďw�肵�������֐�
%
% �����֐��͈ȉ��̌`���łȂ���΂Ȃ�܂���B
%
%       function D = DISTFUN(X0, X, P1, P2, ...),
%
% �����Ƃ���1�� 1�~P �s��̓_ X0 �ƁA�_ X �� N�~P �s��ɁA�[���ȏ��
% �t���I�Ȗ��ŗL�̈��� P1,P2, ..., ���Ƃ�A�����āAX �̊e�_(��)��
% X0 �̊Ԃ̋����� N�~1 �x�N�g�� D ���o�͂��܂��B
%
% [...] = SILHOUETTE(X, CLUST, DISTFUN, P1, P2, ...) �́A�֐� DISTFUN
% �ɁA���ڈ��� P1, P2, ... ��n���܂��B
%
% �e�_�ɑ΂���֊s�l�́A���̓_�����̃N���X�^���̓_�ɔ�ׂāA���g�̃N��
% �X�^���̓_�Ƃǂꂾ���������Ă��邩�Ƃ�����ŁA-1����1�܂ł̒l��
% �Ƃ�܂��B����͈ȉ��̂悤�ɒ�`����܂��B
%
%    S(i) = (min(AVGD_BETWEEN(i,k)) - AVGD_WITHIN(i))
%                            / max(AVGD_WITHIN(i), min(AVGD_BETWEEN(i,k)))
%
% �����ŁAAVGD_WITHIN(i) �́Ai�Ԗڂ̓_���玩�g�̃N���X�^���̑��̓_�ւ�
% ���ϋ����ŁAAVGD_BETWEEN(i,k) �́Ai�Ԗڂ̓_���瑼�̃N���X�^ k �̓_�ւ�
% ���ϋ����ł��B
%
% ���:
%
%    X = [randn(10,2)+ones(10,2); randn(10,2)-ones(10,2)];
%    cidx = kmeans(X, 2, 'distance', 'sqeuclid');
%    s = silhouette(X, cidx, 'sqeuclid');
%
% �Q�l : KMEANS, LINKAGE, DENDROGRAM, PDIST.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/05/08 18:43:59 $

