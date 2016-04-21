% SYMAMD  �Ώ̂ȋߎ��ŏ��x�����̒u��
% 
% P = SYMAMD (S) �́AS(p,p) ���AS �������X�p�[�X��Cholesky���q������
% �悤�Ȓu���x�N�g�� p ���o�͂��܂��B�����ŁAS �́A�Ώ̐���s��ł��B
% ���΂��΁ASYMAMD �́A�Ώ̂Ő���łȂ��s��ɂ��@�\���܂��BSYMAMD �́A
% SYMMMD ���������ŁA���ǂ��������o�͂��܂��B�s�� S �́A�Ώ̂Ɖ���
% ����܂��B�����ɉ��O�p�`�����݂̂��Q�Ƃ���܂��BS �́A�����s��łȂ�
% ��΂Ȃ�܂���B
%
%    Usage:  P = symamd (S)
%            P = symamd (S, knobs)
%            [P, stats] = symamd (S)
%            [P, stats] = symamd (S, knobs)
%
% knobs �́A�I�v�V�����̃X�J�����͈����ł��BS �� n �sn ��̏ꍇ�Aknobs*n 
% �v�f��葽���̗�ƍs�́A�����t�������O�ɏ�������A�o�͒u�� P �̍Ō�
% �̕����ɏ����t�����܂��Bknobs �p�����[�^�����݂��Ȃ��ꍇ�́Aspparms 
% ('wh_frac') ������ɗp�����܂��B
%
% stats �́A�I�v�V������20�v�f����Ȃ�o�̓x�N�g���ŁA���͍s�� S �̏���
% �␳�����Ɋւ���f�[�^���o�͂��܂��B�������v�ʂ́Astats (1:3) �ɏo��
% ����܂��Bstats (1) = stats (2) �́ASYMAMD �ɂ�薳������閧�̍s���A
% �܂��́A��̍s���̐��ŁAstats (3) �́ASYMAND �ɂ��g�p���ꂽ����
% �f�[�^�\���ɓK�p���ꂽ�K�[�x�b�W�R���N�V�����̐�
% (�� 8.4*nnz(tril(S,-1)) + 9*n )�ł��B
%
% MATLAB�g�ݍ��݊֐��́A�d���̂Ȃ��v�f�����e��̒��ŁA��[���̍s�C��
% �f�b�N�X�𑝉����鏇�A�e��̗v�f�����񕉂ł��鐳�����^�̃X�p�[�X�s���
% �쐬���܂��B�s�񂪐������^�łȂ��ꍇ�́ASYMAND �͌p������邩�A���邢��
% ����Ȃ���������܂���B�d�����镔�������݂�����(�s�C���f�b�N�X������
% ��̒��ɕ�����\���)�A������̒��̍s�ɃC���f�b�N�X�Ɉُ킪����ꍇ�́A
% SYMAMD �́A�d�����镔���𖳎����āA�s�� S �̓����R�s�[�̊e����\�[�g
% ���邱�Ƃɂ��A�����̃G���[��␳���邱�Ƃ��ł��܂��B�s�񂪁A����
% �����Ő������^�̂��̂łȂ��ASYMAMD ���A���łȂ��ꍇ�A�G���[���b�Z�[�W
% ���v�����g����A�o�͈���(P �܂��� stats)���߂���܂���BSYMAMD �́A
% �X�p�[�X�s����`�F�b�N����ȒP�ȕ��@�ŁA���ꂪ�������^�̍s�񂩔ۂ���
% ���ׂ邱�Ƃ��ł��܂��B
%
% stats (4:7) �́ASYMAMD ���p���\���ǂ����̏���񋟂��܂��Bstats(4) 
% ���[���̏ꍇ�͍s���OK �ŁA�����ȏꍇ��1�ł��Bstats(5) �́A�\�[�g�����
% ���Ȃ��A�܂��͏d�����Ă���v�f���܂ލł��E�̗�������A���̂悤�ȗ�
% ���݂��Ȃ��ꍇ��0�ł��Bstats(6) �́Astats(5) �ŗ^����ꂽ��C���f�b�N�X��
% �̏����ǂ��z�񂳂�Ă��Ȃ��s�C���f�b�N�X�A�܂��͏d�����邤���̍ŐV�̂���
% ���܂�ł��܂��B���̂悤�ȍs�C���f�b�N�X�����݂��Ȃ��ꍇ�̓[���ł��B
% stats(7) �́A�����ǂ�����ł��Ȃ��s�C���f�b�N�X�A�܂��͏d������s�C��
% �f�b�N�X�̐��������܂��B
%
% stats (8:20) �́ASYMAMD �̃J�����g�o�[�W�����ł͏�Ƀ[���ł�(������
% �o�[�W�����ŗ��p)�B
%
% ���Ԃ́A������c���[��post-ordering�ɏ]���Ă��܂��B
%
%    Authors:
%
%    The authors of the code itself are Stefan I. Larimore and Timothy A.
%    Davis (davis@cise.ufl.edu), University of Florida.  The algorithm was
%    developed in collaboration with John Gilbert, Xerox PARC, and Esmond
%    Ng, Oak Ridge National Laboratory.
%
%    Date:
%
%       January 31, 2000.  Version 2.0.  The above comments revised on
%       June 20, 2000 (no change to the code).
%
%    Acknowledgements:
%
%       This work was supported by the National Science Foundation, under
%       grants DMS-9504974 and DMS-9803599.
%
% �Q�l �F COLMMD, COLPERM, SSPARMS, COLAMD, SYMMMD, SYMRCM.


%  Used by permission of the Copyright holder.  This version has been modified
%  by The MathWorks, Inc. and their revision information is below:
%  $Revision: 1.4.4.1 $ $Date: 2004/04/28 02:03:39 $

