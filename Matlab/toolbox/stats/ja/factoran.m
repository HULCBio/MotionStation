% FACTORAN   �Ŗޓx�𗘗p�������q����
%
% LAMBDA = FACTORAN(X, M) �́AM �̋��ʈ��q�����݂��鉼���̂��ƂŁA
% ���q�׏d�s��̐�����o�͂��܂��B���͍s�� X �́AD �̕ϐ� (��) ��
% ���Ă� N�̊ϑ� (�s)����\������܂��B�Ŗޓx���肪�������邽��
% �ɂ́AX �̕ϐ��́A���`�Ɨ��A�����ACOV(X) ���t�������N�ł���K�v��
% ����܂��BD�~M �o�͍s�� LAMBDA ��(i,j)�Ԗڂ̗v�f�́Ai�Ԗڂ̕ϐ���
% j�Ԗڂ̈��q�̌W���A���邢�́A�׏d�ł��B�f�t�H���g�ł́A���肳��
% �����q�׏d���Avarimax �(���L�Q��)���g�p���ĉ�]���܂��B
%
% [LAMBDA, PSI] = FACTORAN(X, M) �́AD�s1��̃x�N�g�� PSI �Ɏw�肵��
% ���U�̍Ŗޓx������o�͂��܂��B
%
% [LAMBDA, PSI, T] = FACTORAN(X, M) �́ALAMBDA ����]���邽�߂Ɏg����
% M�sM��̉�]�s�� T ���o�͂��܂��B
%
% [LAMBDA, PSI, T, STATS] = FACTORAN(X, M) �́A���ʈ��q�̐��� M �ł���
% �Ƃ����A�������Ɋ֘A��������܂ލ\���̂��o�͂��܂��BSTATS �́A����
% �t�B�[���h����\������܂��B
%
%      loglike - �ΐ��ޓx���ő�ɂ���l
%          dfe - ���R�x�̌덷�x�� == ((D-M)^2 - (D+M))/2
%        chisq - �A�������ɑ΂���J�C��擝�v�ߎ�
%            p - �A�������ɑ΂���right-tail�L�Ӑ���
%
% FACTORAN �́ASTATS.dfe �����ŁAPSI �Ɏw�肷�镪�U�̐��肪���ׂĐ���
% �Ȃ��ꍇ�ASTATS.chisq �� STATS.p ���o�͂��܂���B
% FACTORAN �́AX �������U�s��ŁA���[�U���œK�� 'Nobs' �p�����[�^(�ȉ�
% �Q��)���g�p���Ȃ��ꍇ�ASTATS.chisq �� STATS.p ���o�͂��܂���B
%
% [LAMBDA, PSI, T, STATS, F] = FACTORAN(X, M) �́A�X�Ɉ��q�X�R�A�Ƃ��Ă�
% �m����N�sM��̍s�� F �̋��ʈ��q�̗\�����o�͂��܂��BF �̍s�͗\����
% �Ή����A��͈��q�ɑΉ����܂��BFACTORAN �́AX �������U�s�񂾂� F ��
% �v�Z���邱�Ƃ��ł��܂���BFACTORAN �́ALAMBDA �Ɋւ��Ă͓������
% �p���� F ����]���܂��B
%
% [ ... ] = FACTORAN(..., 'PARAM1',val1, 'PARAM2',val2, ...) �́A���͂�
% ��`���邽�߂ɁA�I�v�V�����p�����[�^��/�g�̑g�ݍ��킹���w�肵�A���f��
% �ɓ��Ă͂߂�̂Ɏg��ꂽ���l�I�ȍœK�����R���g���[�����A�o�͂̏ڍׂ�
% �w�肷�邱�Ƃ��ł��܂��B�g�p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B:
%
%      'Xtype'     - X �̓��̓^�C�v [ {'data'} | 'covariance' ]
%      'Start'     - �œK���ɂ����� PSI �ɑ΂���o���_�̑I����@�B�ȉ�
%                    ����I���ł��܂�:
%                            'random' - ���U��l���z(0,1) �l��I�����܂��B
%                        {'Rsquared'} - �X�P�[�����q��DIAG(INV(CORRCOEF(X)))
%                                       �̐ςƂ��āA�o���_�̃x�N�g����I��
%                                       ���܂��B
%                    positive integer - 'random' ���g�p���Ă��ꂼ���
%                                       �����������s���邽�߂̍œK���̐�
%                              matrix - �����ȊJ�n�_�ł���D�sR��̍s��B
%                                       �e���1�̊J�n�x�N�g���ŁAFACTORAN
%                                       �́AR �̍œK�������s���܂��B
%      'Delta'     - �ŖލœK���̊ԁA�w�肵�����UPSI�ɑ΂��鉺�E
%                    [ 0 <= ���̃X�J�� < 1 | {0.005} ]
%      'OptimOpts' - STATSET �ɂ�萶�������ŖލœK���̂��߂̃I�v�V�����B
%                    �p�����[�^���ƃf�t�H���g�l�ɂ��ẮA
%                    STATSET('factoran') ���Q�Ƃ��Ă��������B
%      'Nobs'      - X �������U�s��̂Ƃ��AX �̐���Ɏg�p���ꂽ�ϑ���
%                    [ positive integer ]
%      'Scores'    - F ��\������̂Ɏg�p������@
%                    [ {'wls'} | 'Bartlett' | 'regression' | 'Thomson' ]
%      'Rotate'    - ���q�׏d�ƃX�R�A����]���邽�߂Ɏg�p������@
%                    [ 'none' | {'varimax'} | 'orthomax' | 'procrustes'
%                    | 'promax' | function ]
%
% ��]�֐��́A�Ⴆ�΁A@ROTATEFUN �̂悤�ɁA@ ���g�p���Ďw�肷�邱�Ƃ�
% �ł��A�ȉ��̂悤�Ȍ`���łȂ���΂Ȃ�܂���B
%
%         function [B, T] = ROTATEFUN(A, P1, P2, ...),
%
% �����ł́A��]���Ȃ����q�׏d��D�sM��̍s�� A �������Ƃ��Ď��A�[���A
% ���邢�͍X�ɕt���I�Ȗ��Ɉˑ�������� P1, P2, ..., �������A��]���q
% �׏d��D�sM��̍s�� B �ƑΉ�����D�sD��̉�]�s��T���o�͂��܂��B
%
% [ ... ] = FACTORAN(..., 'Rotate', ROTATEFUN, 'UserArgs', P1, P2, ...)
% �́A�֐� ROTATEFUN �ɒ��ڈ��� P1, P2, ... ��n���܂��B
%
% 'Rotate' �� 'varimax', 'orthomax' �̏ꍇ�A�t���I�ȃp�����[�^�͈ȉ���
% �悤�ɂȂ�܂��B:
%   
%      'Normalize'   - ��]�̊Ԃɉ׏d�s��̗�𐳋K�����邩�ǂ�����
%                      �����t���O  [ {'on'} | 'off' ]
%      'RelTol'      - ���ΓI�Ȏ����̋��e�x
%                      [ ���̃X�J�� | {sqrt(eps)} ]
%      'Maxit'       - �J��Ԃ����� [ ���̐��� | {250} ]
%      'CoeffOM'     - varimax �ɑ΂��Ė�������܂����A����� orthomax �
%                      ���`����W�� [ 0 <= �X�J�� <= 1 | {1} ]
%
% Rotate' �� 'promax' �̏ꍇ�A���[�U�� promax �ɂ���ē����Ŏg�p�����
% orthomax ��]���R���g���[�����邽�߂ɏ�L4�̃p�����[�^���g�p����
% ���Ƃ��ł��܂��B'promax' �ɑ΂���t���I�ȃp�����[�^�́A�ȉ��̒ʂ�ł��B
%
%      'PowerPM'     - �쐬���ꂽ promax �^�[�Q�b�g�s��ɑ΂���w��
%                      [ �X�J�� >= 1 | {4} ]
%
% 'Rotate' �� 'procrustes' �̏ꍇ�A�t���I�ȃp�����[�^�͈ȉ��̒ʂ�ł��B:
%
%      'TargetProcr' - �^�[�Q�b�g���q�׏d(�K�{) [ D-by-M �s�� ]
%      'TypeProcr'   - ��]�̃^�C�v [ {'oblique'} | 'orthogonal' ]
%
% ���:
%
%      load carbig;
%      X = [Acceleration Displacement Horsepower MPG Weight]; 
%      X = X(all(~isnan(X),2),:);
%      [Lambda, Psi, T, stats, F] = factoran(X, 2, 'scores', 'regr')
%
%      % ���肳�ꂽ�����U����v�Z����܂����A��������ł��B
%      [Lambda, Psi, T] = factoran(cov(X), 2, 'Xtype', 'cov')
%
%      % promax ��]���g�p���܂��B
%      [Lambda, Psi, T] = factoran(X, 2, 'rotate','promax', 'power',2)
%
%      % ��]�֐��������Ƃ��ēn���܂��B
%      [Lambda Psi T] = ...
%           factoran(X, 2, 'rotate', @myrotation, 'userargs', 1, 'two')
%
% �Q�l : OPTIMSET, PROCRUSTES, PRINCOMP, PCACOV.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2003/04/21 19:42:37 $
