% HPRECON   H-�O������̃X�p�[�XCholesky����
%
% [R,PVEC] = HPRECON(H,UPPERBANDW,DM,DG) �́A�X�p�[�XCholesky�������v�Z
% ���܂��B(�����s�� M ��(�ʏ��)�͈͕t���̑O������̓]�u���s���܂��B)
%                M = DM*H*DM + DG
% �����ŁADM �� DG �́A�񕉂̃X�p�[�X�Ίp�s��ł��B
% R'*R �́AM(pvec,pvec) ���ߎ����܂��B���Ȃ킿�A
%          R'*R = M(pvec,pvec)
% �ł��B
%
% H �́A�^��Hessian�ł͂���܂���BH ���^��Hessian�Ɠ����傫���̏ꍇ�AH �́A
% �O����� R �̌v�Z�Ɏg���܂��B
% ����ȊO�̏ꍇ�A�ȉ��̎��ɑ΂���Ίp�O��������v�Z���܂��B
%               M = DM*DM + DG
%
% 0 < UPPERBANDW <  n �̏ꍇ�AR �̍��ш敝�́AUPPERBANDW �ɂȂ�܂��B
% UPPERBANDW >= n �̏ꍇ�AR �̍\���́Asymmmd�̏����t����p���� H �̃X�p�[�X
% Cholesky���q�����ɑΉ����܂��B(�����t���́APVEC �ɏo�͂���܂��B)


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:01:57 $
