% KMEANS   K���σN���X�^�����O
%
% IDX = KMEANS(X, K) �́AK �̃N���X�^�� N�~P �f�[�^�s�� X �̓_�𕪊�
% ���܂��B���̋敪�́A���ׂẴN���X�^�ɂ킽���ăN���X�^�̒��S�_�ւ�
% �����̃N���X�^���̘a���ŏ������܂��BX �̍s�́A�_�ɑΉ����A��͕ϐ���
% �Ή����܂��BKMEANS �́A�e�_�̃N���X�^�̃C���f�b�N�X���܂ށAN�~1 ��
% �x�N�g�� IDX ���o�͂��܂��B�f�t�H���g�ł́AKMEANS �́AEuclidean 
% �����̓���p���܂��B
%
% [IDX, C] = KMEANS(X, K) �́AK�~P �s�� C �� K �̃N���X�^���S�̈ʒu
% ���o�͂��܂��B
%
% [IDX, C, SUMD] = KMEANS(X, K) �́A1�~K �x�N�g�� sumD �ɒ��S�_�ւ̋���
% �̃N���X�^���̘a���o�͂��܂��B
%
% [IDX, C, SUMD, D] = KMEANS(X, K) �́AN�~K �s�� D �Ɋe�_���炷�ׂĂ�
% ���S�ւ̋������o�͂��܂��B
%
% [ ... ] = KMEANS(..., 'PARAM1',val1, 'PARAM2',val2, ...) �́AKMEANS ��
% �g�p����锽���A���S���Y�����R���g���[�����邽�߂ɁA�I�v�V�����̃p��
% ���[�^�̖��O�ƒl�̑g���w�肷�邱�Ƃ��\�ł��B�p�����[�^�͈ȉ��̒ʂ�
% �ł��B:
%
% 'Distance' - KMEANS ���ŏ��ɂ��ׂ�P������Ԃɂ����鋗���̑���@�B
%              �ȉ�����I�����܂��B:
%          {'sqEuclidean'} - Euclidean �����̓��
%           'cityblock'    - ��΋���(�ʖ� L1)�̘a
%           'cosine'       - 1����(�x�N�g���Ƃ��Ĉ���ꂽ)�_�̊Ԃ̊p�x
%                            �̃R�T�C�����������l
%           'correlation'  - 1����(�l�̌n��Ƃ��Ĉ���ꂽ)�_�̊Ԃ̕W�{
%                            ���ւ��������l
%           'Hamming'      - �قȂ�r�b�g�̃p�[�Z���e�[�W
%                            (2�l�̃f�[�^�ɑ΂��Ă̂ݓK��)
%
% 'Start' - "seeds"�Ƃ��Ă��m����A�N���X�^�̏����̒��S�ʒu��I������
%           ���߂Ɏg������@�B�ȉ�����I�����܂��B:
%               {'sample'} - �����_���� X ���� K �̊ϑ���I��
%                'uniform' - X �͈̔͂����l�Ƀ����_���� K �_��I���B
%                            Hamming �����ɑ΂��Ă͎w��ł��܂���B
%                'cluster' - X �� 10% �������_���ɒ��o���\���̃N���X�^
%                            �����O�����s���܂��B���̗\���N���X�^�����O
%                            �̏����l�� 'sample' ��p���Čv�Z����܂��B
%                matrix    - �J�n�ʒu�� K�~P �s��B���̏ꍇ�AK �ɑ΂���
%                            [] ��n���AKMEANS �ɂ��̍s��̍ŏ��̎���
%                            ���� K �𐄑������邱�Ƃ��ł��܂��B3��
%                            �̎������� 'Replicates' �ɑ΂���l���w��
%                            �����悤�ɁA3�����z���^���邱�Ƃ��ł�
%                            �܂��B
%
% 'Replicates' - ���ꂼ��V���������̒��S�̐ݒ���g���N���X�^�����O��
%                �J��Ԃ��� [ ���̐��� | {1}]
% 'Maxiter' - �J��Ԃ��ő吔 [ ���̐��� | {100}]
%
% 'EmptyAction' - ����N���X�^��������\������ϑ����ׂĂ������ꍇ��
%                 ���A�N�V�����B�ȉ�����I�����܂��B:
%             {'error'}    - �덷�Ƃ��ċ�̃N���X�^����舵��
%              'drop'      - ��̏ꍇ�ɔC�ӂ̃N���X�^���������AC �� D
%                            �ɑΉ�����l�� NaN ��ݒ�
%              'singleton' - ���S��������Ƃ�������̊ϑ�����V����
%                            �N���X�^���쐬
%
% 'Display' - �\�����x�� [ 'off' | {'notify'} | 'final' | 'iter' ]
%
% ���:
%
%     X = [randn(20,2)+ones(20,2); randn(20,2)-ones(20,2)];
%     [cidx, ctrs] = kmeans(X, 2, 'dist','city', 'rep',5, 'disp','final');
%     plot(X(cidx==1,1),X(cidx==1,2),'r.', ...
%          X(cidx==2,1),X(cidx==2,2),'b.', ctrs(:,1),ctrs(:,2),'kx');
%
% �Q�l : LINKAGE, CLUSTERDATA, SILHOUETTE.


%   Copyright 1993-2000 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/05/30 16:13:31 $
