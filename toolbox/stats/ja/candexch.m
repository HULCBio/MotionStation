% CANDEXCH   �s�������g�p�������W�������D-�œK���v��
%
% RLIST = CANDEXCH(C,NROWS) �́A�s�����A���S���Y�����g�p���āA���W��C 
% ����D-�œK���v���݌v���܂��BC �́A�eN �_�ŁAP ���f�����ڂ̒l���܂�
% N�~P�s��ł��BNROWS �́A�v��ł̊�]�̍s���ł��B RLIST �́A�I���s��
% ���X�g���钷�� NROWS �̃x�N�g���ł��B
%
% �֐� CANDEXCH �́A�o���_�ƂȂ�v�� X �������_���ɑI�����A�s�����A���S
% ���Y�����g�p���āAX �̍s�� C �̍s�ƌJ��Ԃ��u�������āAX'* X �̍s��
% �����ǂ��܂��B
%
% RLIST = CANDEXCH(C,NROWS,'PARAM1',VALUE1,'PARAM2',VALUE2,...) �́A
% �p�����[�^/�l �̑g ��ݒ肵�āA�v��̍쐬���X�ɃR���g���[�����܂��B
% ���p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B
%
%      �p�����[�^   �l
%      'display'    �J��Ԃ���(�f�t�H���g = 'on')�̕\�����R���g���[��
%                   ���邽�߂ɁA'on' ���邢�� 'off' �̂����ꂩ�ƂȂ�܂��B
%      'init'       NROWS�~P �s��Ƃ��Ă̏����݌v(�f�t�H���g�́AC �̍s��
%                   �����_���ȃT�u�Z�b�g�ł�)�B
%      'maxiter'    �J��Ԃ��̍ő�� (�f�t�H���g = 10)�B
%
% �֐�ROWEXCH �́A�܂��A�s�����A���S���Y�����g�p����D-�œK�v��𐶐�
% ���܂����A�w�肵�����f���ɓK���Ȍ��W�����������܂��B 
%
% ���:  ���W���ɐ���������ꍇ�AD-�œK�v����쐬���܂��B���̂��߁A�֐�
% ROWEXCH�́A�K�؂ł͂���܂���B
%   
%      F = (fullfact([5 5 5])-1)/4;   % unit cube�ł̗v���̐ݒ�
%      T = sum(F,2)<=1.51;            % �����ɓK������s�̌��o
%      F = F(T,:);                    % �����̍s�̂ݏ���
%      C = [ones(size(F,1),1) F F.^2];% �萔�Ƃ��ׂĂ�2��̍����܂�
%                                     % ���f�����̌v�Z
%      R = candexch(C,12);            % D-�œK12-�_�T�u�Z�b�g�̌��o
%      X = F(R,:);                    % �v���̐ݒ�̎擾
%
% �Q�l : CANDGEN, ROWEXCH, CORDEXCH, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:10:35 $
