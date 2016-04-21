% Spline Toolbox
% Version 3.2.1 (R14) 05-May-2004 
%
% GUI
%   splinetool - �������̃X�v���C���ߎ��@�̃f�����X�g���[�V����
%   bspligui   - �ߓ_�̊֐��Ƃ��Ă�B-�X�v���C���Ɋւ������
%
% �X�v���C���̍쐬
%                         
%   csape    - ��X�̒[�_���������L���[�r�b�N�X�v���C�����
%   csapi    - �ߓ_�łȂ��[�_���������L���[�r�b�N�X�v���C�����
%   csaps    - �L���[�r�b�N�������X�v���C��
%   cscvn    - ���R�܂��͎����I�ȃL���[�r�b�N�X�v���C���Ȑ�
%   getcurve - �L���[�r�b�N�X�v���C���Ȑ��̑Θb�I�ȍ쐬
%   ppmak    - pp-�^�X�v���C���̑g����
%
%   spap2    - �ŏ����X�v���C���ߎ�
%   spapi    - �X�v���C�����
%   spaps    - �������X�v���C��
%   spcrv    - �ϓ��ȋ敪�ɂ�鐧��_����̃X�v���C���Ȑ�
%   spmak    - B-�^�X�v���C���̑g����
%
%   rpmak    - rp-�^�L���X�v���C���̑g����
%   rsmak    - rB-�^�L���X�v���C���̑g����
%
%   stmak    - st-�^�L���X�v���C���̑g����
%   tpaps    - Thin-plate�������X�v���C��
%
% �X�v���C���̑��� (B-�^, pp-�^, rB-�^, st-�^, ...�̔C�ӂ̌^�A
%                          1�ϐ��܂��͑��ϐ�)
%   fnbrk    - �^�̖��O�ƍ\���v�f
%   fnchg    - �^�̍\���v�f�̕ύX
%   fncmb    - �֐��̎Z�p
%   fnder    - �֐��̔���
%   fndir    - �֐��̕�������
%   fnint    - �֐��̐ϕ�
%   fnjmp    - �֐��̔�сA���Ȃ킿�Af(x+) - f(x-) 
%   fnmin    - (�^����ꂽ��Ԃł�)�֐��̍ŏ��l
%   fnplt    - �֐��̃v���b�g
%   fnrfn    - ����^�̃u���[�N�|�C���g�A���邢�́A�ߓ_�̉���
%   fntlr    - �e�C���[(Taylor)�W���A���邢�́A������
%   fnval    - �֐��̕]��
%   fnzeros  - (�^����ꂽ��Ԃł�)�֐��̗�_
%   fn2fm    - �ݒ肳�ꂽ�^�ւ̕ϊ�
%
% �ߓ_�A�u���[�N�|�C���g�A�T�C�g�̎�z
%   aptknt   - �K�؂Ȑߓ_��
%   augknt   - �ߓ_��̑���
%   aveknt   - �ߓ_�̕���
%   brk2knt  - ���d�x�����u���[�N�|�C���g��ߓ_�ɕϊ�
%   chbpnt   - �K�؂ȃf�[�^�T�C�g (Chebyshev-Demko �_)
%   knt2brk  - �ߓ_�񂩂�u���[�N�|�C���g�֕ϊ����A���d�x��\��
%   knt2mlt  - �ߓ_�̑��d�x
%   newknt   - �V�����u���[�N�|�C���g�̕��z
%   optknt   - �œK�Ȑߓ_�̕��z
%   sorted   - ���b�V���T�C�g�ɑ΂���T�C�g�̈ʒu�t��
%
% �X�v���C���쐬�c�[��
%   spcol    - B-�X�v���C���I�_�s��
%   stcol    - �_�݂���ϊ��I�_�s��
%   slvblk   - �قڃu���b�N�Ίp�Ȑ��`�V�X�e���̉�
%   bkbrk    - �قڃu���b�N�Ίp�ȍs��̈ꕔ
%   chckxywp - *AP* �R�}���h�ɑ΂���`�F�b�N�ƒ���
%
% �X�v���C���ϊ��c�[��
%   splpp    - �Ǐ��I��B-�W�����獶�̃e�C���[(Taylor)�W����
%   sprpp    - �Ǐ��IB-�W������E�̃e�C���[(Taylor)�W����
%
% �f�����X�g���[�V����
%   splexmpl - �������̊ȒP�ȗ��
%   spalldem - B-�^�ւ̓���
%   ppalldem - pp-�^�ւ̓���
%   bspline  - B-�X�v���C���Ƃ��̑������̍\���v�f���v���b�g
%   pckkntdm - �ߓ_�̑I��
%   csapidem - �L���[�r�b�N�X�v���C����Ԃ̃f��
%   csapsdem - �L���[�r�b�N�������X�v���C���̃f��
%   spapidem - �X�v���C����Ԃ̃f��
%   getcurv2 - GETCURVE �̃X���C�h�V���[�o�[�W����
%   histodem - �q�X�g�O�����̕������̃f��
%   chebdem  - ���U���X�v���C���̃f��
%   difeqdem - �K�E�X�_�ł̑I�_�ɂ��ODE�̉�@
%   spcrvdem - �X�v���C���Ȑ��̃f��
%   tspdem   - 2�ϐ��e���\���σX�v���C���̃f��
%
% �֐��ƃf�[�^
%   franke   - Franke��2�ϐ��e�X�g�֐�
%   subplus  - ������
%   titanium - �e�X�g�f�[�^
%
% �X�v���C���ƃc�[���{�b�N�X�̏��
%   spterms  - spline toolbox�̗p��̐���
%
% �p�~���ꂽ�֐�
%   pplst    - pp-�^�̃X�v���C���ɂ��Ă̗��p�\�ȑ���̂܂Ƃ�
%   splst    - B-�^�̃X�v���C���ɂ��Ă̗��p�\�ȑ���̂܂Ƃ�
%   bsplidem - ��������B-�X�v���C��


%   Copyright 1987-2004  C. de Boor and The MathWorks, Inc.
