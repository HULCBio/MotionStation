% PDIST   �ϑ��Ԃ̋���
%
% Y = PDIST(X) �́AM�sN��̍s�� X ���̊e�ϑ��̑g�ݍ��킹�Ԃ� Euclidean
% �������܂ރx�N�g�� Y ���o�͂��܂��BX �̍s�́A�ϑ��ɑΉ����A��͕ϐ���
% �Ή����܂��BY �́AM*(M-1)/2�s1��̃x�N�g���ŁAX���̊ϑ��� M*(M-1)/2�g
% �ɑΉ����܂��B
%
% Y = PDIST(X, DISTANCE) �́ADISTANCE ��p���� Y ���v�Z���܂��B�ȉ�����
% �I���\�ł��B:
% 
%       'euclidean'   - Euclidean����
%       'seuclidean'  - �e���W�̓��a�����W�̕W�{���U�ɂ��d�ݕt���̋t
%                       �ƂȂ�W����Euclidean����
%       'cityblock'   - City Block����
%       'mahalanobis' - �}�n���m�r�X(Mahalanobis)����
%       'minkowski'   - �w��2�Ƃ���~���R�t�X�L�[(Minkowski)����
%       'cosine'      - 1����(�x�N�g���Ƃ��Ĉ�����)�ϑ��Ԃ̊p�x���܂�
%                       �R�T�C�����������l
%       'correlation' - 1����(�l�̌n��Ƃ��Ĉ�����)�ϑ��Ԃ̕W�{���ւ�
%                       �������l
%       'hamming'     - �قȂ���W�̃p�[�Z���e�[�W�ƂȂ�Hamming����
%       'jaccard'     - 1����قȂ��[���̍��W�̃p�[�Z���e�[�W�ƂȂ�
%                       Jaccard�W�����������l
%       function      - @ ��p���Ďw�肳�ꂽ�����֐��A�Ⴆ�� @DISTFUN
% 
% �����֐��́A�ȉ��̌`���łȂ���΂Ȃ�܂���B
%
%         function D = DISTFUN(XI, XJ, P1, P2, ...),
%
% �����Ƃ��āA2��L�sN��̍s�� XI ��XJ �ƁA�[���A�܂��͕t���I�Ȗ��ŗL��
% ���� P1, P2, ... �����AK�Ԗڂ̗v�f���ϑ� XI(K,:) �� XJ(K,:) �Ԃ̋���
% �ƂȂ�L�s1��̋����̃x�N�g�� D ���o�͂��܂��B
%
% Y = PDIST(X, DISTFUN, P1, P2, ...) �́A�֐� DISTFUN �ɒ��ڈ��� P1, P2, ...
% ��n���܂��B
%
% Y = PDIST(X, 'minkowski', P) �́A���̃X�J���̎w�� P ��p���ă~���R�t�X�L�[
% (Minkowski)�������v�Z���܂��B
%
% �o�� Y �́A�Ⴆ�΁A�t����M�sM��̋����s��̉E��O�p�̂悤�ɁA
% ((1,2),(1,3),..., (1,M),(2,3),...(2,M),.....(M-1,M)) �̏��ɔz�u����܂��B
% �ϑ� (I < J) ��I�Ԗڂ�J�Ԗڂ̊Ԃ̋������擾����ɂ́AY((I-1)*(M-I/2)+J-I)
% �̌������g�����A�܂��́A(I,J) �̓��͂��ϑ� I �Ɗϑ� J �Ԃ̋����Ɠ�����
% �Ȃ�M�sM��̐����Ώ̍s����o�͂���⏕�֐� Z = SQUAREFORM(Y) ���g������
% �ǂ��炩�ł��B
%
% ���:
%
%      X = randn(100, 5);                 % �������̃����_���_
%      Y = pdist(X, 'euclidean');         % �d�ݕt������Ȃ�����
%      Wgts = [.1 .3 .3 .2 .1];           % ���W�̏d�ݕt��
%      Ywgt = pdist(X, @weucldist, Wgts); % �d�ݕt�����ꂽ����
%
%      function d = weucldist(XI, XJ, W) % �d�ݕt�����ꂽeuclidean����
%      d = sqrt((XI-XJ).^2 * W');
%
% �Q�l : SQUAREFORM, LINKAGE, SILHOUETTE.


%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $
