% COLAMD  ��̍ŏ��x�����u���ɋߎ�
%
% P = COLAMD (S) �́A�X�p�[�X�s�� S �ɑ΂��āA�ŏ��x�����̒u���x�N�g��
% �ɋߎ���������o�͂��܂��B��Ώ̍s�� S �ɑ΂��āAS(:,P) �́AS �����A
% �X�p�[�X�� LU �����ɂȂ�܂��BS(:,P)'*S(:,P) �� Cholesky �������AS'*S 
% �� Cholesky ���������A�X�p�[�X�ɂȂ�܂��BCOLAMD �́ACOLMMD ���
% �������ŁA���ǂ�������o�͂��܂��B
%
% �g�p�@�F   P = colamd (S)
%            P = colamd (S, knobs)
%            [P, stats] = colamd (S)
%            [P, stats] = colamd (S, knobs)
%
% knobs �́A�I�v�V������2�v�f���̓x�N�g���ł��BS ��m�sn��̏ꍇ�́A
% (knobs (1))*n ���������̗v�f������s�͖�������܂��B(knobs (2))*m ��
% ��������̗v�f������́A���ԕt���̑O�ɍ폜����A�o�͓]�u�s�� P �̍�
% ��ɏ��ԕt�����܂��Bknobs �p�����[�^�����݂��Ȃ��ꍇ�́Aknobs (1)
% �� knobs (2)�ɑ΂��āAspparms ('wh_frac') ������ɗp�����܂��B
%
% stats �́A�I�v�V������20�v�f����Ȃ�o�̓x�N�g���ŁA���͍s�� S �̏���
% �Ɛ������Ɋւ�����������܂��B���ԓ��v�ʂ� stats (1:3) �ŕ\�킳��A
% stats(1)��stats(2) �́ACOLAMD �ɂ�薳������閧�̍s�A��܂��͋��
% �s�A��̐��ł��Bstats(3) �́ACOLAMD �Ŏg�p���������f�[�^�\����
% �ɓK�p����Ă���K�[�x�b�W�R���N�V�����̉񐔂ŁA�����悻 size 2.2*nnz(S)
% + 4*m + 7*n �̐������ɂȂ�܂��B
%
% MATLAB�g�ݍ��݊֐��́A�d���̂Ȃ��v�f�����e��̒��Ŕ�[���̍s�C��
% �f�b�N�X�𑝉����鏇�ɁA�e��̗v�f�����񕉂ł��鐳�����^�̃X�p�[�X�s
% ����쐬���܂��B�s�񂪐������^�łȂ��ꍇ�́ACOLAMD �͌p�������ꍇ
% ������A�����łȂ��ꍇ������܂��B�d�����镔�������݂�����(�s�C���f�b�N
% �X��������̒��ɕ�����\���)�A������̒��̍s�ɃC���f�b�N�X�Ɉُ킪
% ����ꍇ�́ACOLAMD �́A�d�����镔���𖳎����āA�s�� S �̓����R�s�[
% �̊e����\�[�g���邱�Ƃɂ��A�����̃G���[��␳���邱�Ƃ��ł��܂��B�s
% �񂪁A���̌����Ő������^�̂��̂łȂ��ACOLAMD ���p���ł��Ȃ��ꍇ�́A
% �G���[���b�Z�[�W���v�����g����A�o�͈���(P �܂��� stats)���o�͂���܂�
% ��BCOLAMD �́A�X�p�[�X�s����`�F�b�N����ȒP�ȕ��@�ŁA���ꂪ������
% �^�̍s�񂩔ۂ��𒲂ׂ邱�Ƃ��ł��܂��B
%
% stats (4:7) �́ACOLAMD ���p���\�ł��邩�ǂ����̏���񋟂��܂��B
% stats(4)���[���̏ꍇ�s���OK �ŁA1�̏ꍇ�������Ȃ����̂ł��Bstats(5)
% �́A�\�[�g����Ă��Ȃ��A�܂��͏d�����Ă���v�f���܂񂾍ł��E�̗����
% ���A���̂悤�ȗ񂪑��݂��Ȃ��ꍇ��0�ł��Bstats(6) �́Astats(5)�ŗ^�����
% ���C���f�b�N�X���̏����ǂ��z�񂳂�Ă��Ȃ��s�C���f�b�N�X�A�܂��́A
% �d���̍ŐV�̂��̂��܂�ł��܂��B���̂悤�ȍs�C���f�b�N�X�����݂��Ă���
% ���ꍇ�̓[���ł��Bstats(7)�́A�����ǂ�����ł��Ȃ��s�C���f�b�N�X�A�܂�
% �́A�d���̐��������܂��B
%
% stats (8:20) �́ACOLAMD �̃J�����g�o�[�W�����ł͏�Ƀ[���ł�(�����̃o
% �[�W�����ŗ��p)�B
%
% ���Ԃ́A��폜�c���[�̏��ԕt���ɏ]���Ă��܂��B
%
% Authors: 
%   Stefan I. Larimore and Timothy A. Davis, University of Florida,
%   (davis@cise.ufl.edu); in collaboration with John Gilbert, Xerox PARC,
%    and Esmond Ng, Oak Ridge National Laboratory.  This work was suppo-
%    rted by the National Science Foundation, under grants DMS-9504974 
%    and DMS-9803599.
%    COLAMD and SYMAMD are available at http://www.cise.ufl.edu/~davis/
%    colamd.
%
% Date:
%
%    January 31, 2000.  Version 2.0.  The above comments revised on
%    June 20, 2000 (no change to the code).
%
% Acknowledgements:
%
%    This work was supported by the National Science Foundation, under
%    grants DMS-9504974 and DMS-9803599.
%
% �Q�l�F COLMMD, COLPERM, SSPARMS, SYMAMD, SYMMMD, SYMRCM.


%  Used by permission of the Copyright holder.  This version has been modified
%  by The MathWorks, Inc. and their revision information is below:
%  $Revision: 1.4.4.1 $ $Date: 2004/04/28 02:02:31 $

