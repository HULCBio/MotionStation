% MPOLES   �d������ɂƂ��̑��d�x�̎���
% 
% [MULTS�AIDX] = mpoles( P�ATOL )
%   P       : �ɂ̃��X�g
%   TOL     : 2�̋ɂ������ł���Ƃ��̃`�F�b�N�̂��߂̋��e�l(�f�t�H���g
%             �́A1.0e-03)
%   REORDER : �ɂ̃\�[�g���s����?  0 = �\�[�g���Ȃ��A1 = �\�[�g���s��
%             (�f�t�H���g)
%   MULTS   : �ɂ̑��d�x�̃��X�g
%   IDX     : P�̃\�[�g�Ɏg�p����C���f�b�N�X
% 
% ����: ����́ARESIDUEZ �̕⏕�֐��ł��B
%
% ���:
%     ����:  P = [1 3 1 2 1 2]
%     �o��: [MULTS�AIDX] = mpoles(P)
%                 MULTS' = [1 1 2 1 2 3]�AIDX' = [2 4 6 1 3 5]
%                 P(IDX) = [3 2 2 1 1 1]
% MULTS�́A���������W�J�ł̊e�X�̋ɂ̎w�����܂݂܂��B
%
% RESIDUEZ �ɂ��^����ꂽ�����Ƌɂ��Ή�����Ƃ��̂悤�ɁA�ɂ��~����
% �\�[�g����Ȃ��ꍇ������܂��B���̏ꍇ�AREORDER = 0 �Ɛݒ肵�Ă��������B
% ���Ƃ��΁A
%     ����:  P = [1 3 1 2 1 2]
%     �o��: [MULTS�AIDX] = mpoles(P,[],0)
%                 MULTS' = [1 2 3 1 1 2]�AIDX' = [1 3 5 2 4 6]
%                 P(IDX) = [1 1 1 3 2 2]
%
%   ���� P �̃T�|�[�g�N���X
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.