% FNBRK   �^�̖��O�܂��͍\���v�f
%
% FNBRK(FN,PART) �́AFN �ɂ���֐��ɂ��Ďw�肳�ꂽ PART ���o�͂��܂��B
% PART �̂قƂ�ǂ̑I���ɂ��ẮA����� FN �ɂ���֐��ɂ��Ă̏���
% �������̗v�f�ł��BPART �̂������̑I���ɂ��ẮAFN �ɂ���֐���
% �֘A�����������̊֐��̌^�ł��B
% PART ��������̏ꍇ�A�֘A���镶����̍ŏ��̕���(������)�̂݁A�w�肷��
% �K�v������܂��B
%
% FN �̌^�Ɋւ�炸�APART �ɂ͂��̂��̂��w�肵�܂��B
%
%      'dimension'     �֐��̃^�[�Q�b�g�̎���
%      'variables'     �֐��̗̈�̎���
%      'coefficients'  ���ʂȌ^�̌W��
%      'interval'      �֐��̊�{���
%      'form'          FN �ɂ���֐����L�q���邽�߂Ɏg�p�����^
%      [A B]           (A, B �̓X�J��)�B�����^�ł����A��� [A .. B] ���
%                      FN �ɂ���1�ϐ��֐��̋L�q�𓾂܂��B��{��Ԃ� 
%                      [A .. B] �ɕϊ�����܂��Bm�ϐ��֐��ɑ΂��ẮA
%                      ���̎w�肪 [A B] �Ƃ����`����m�̗v�f�����Z��
%                      �z��̌`�ɂȂ��Ă��Ȃ���΂Ȃ�܂���B
%      [] �́AFN ���ύX���ꂸ�ɏo�͂���܂�(FN ��m�ϐ��֐��̂Ƃ��Ɏg�p)�B
%
% FN �̌^�Ɉˑ����āA�ȉ��̗v�f���w��ł��܂��B
%
% FN���AB-�^ (���邢�́ABB-�^, rB-�^)�̏ꍇ�APART �́A
%
%      'knots'         �ߓ_��
%      'coefficients'  B-�X�v���C���W��
%      'number'        �W���̐�
%      'order'         �X�v���C���̑���������
%
% FN �� pp-�^ (���邢�́Arp-�^)�̏ꍇ�APART �́A
%
%      'breaks'        �u���[�N�|�C���g�̗�
%      'coefficients'  �Ǐ��I�ȑ������̌W��
%      'pieces'        �������敪�̐�
%      'order'         �X�v���C���̑������̎���
%      ���� j          j�Ԗڂ̑������敪��pp-�^
%
% FN �� st-�^ �̏ꍇ�APART �́A
%
%      'centers'       ���S
%      'coefficients'  �W��
%      'number'        �W���̐�
%      'type'          st-�^�̃^�C�v
%
% FN ���Am>1�Ƃ��āAm�ϐ��̃e���\���ς̃X�v���C�����܂ނȂ�΁APART �́A
% ������łȂ��ꍇ�A���� m �̃Z���z��łȂ���΂Ȃ�܂���B
%
% [OUT1, ..., OUTo] = FNBRK(FN, PART1, ..., PARTi) �́Aj=1:o �ł̕����� 
% PARTj �ɂ���ėv�������v�f�� OUTj �ɏo�͂��܂��B������ o<=i �ł��B
%
% FNBRK(FN) �́A�����o�͂��܂��񂪁A���p�\�ł���ꍇ�A���ׂĂ̗v�f��
% ���ɁA'form' ��\�����܂��B
% 
% ���:
%
%      coefs = fnbrk( fn, 'coef' );
%
% �́Afn �̃X�v���C���̌W�� (����B-�^ ���邢�́A����pp-�^����̌W��)��
% �o�͂��܂��B 
%
%      p1 = fn2fm(spline(0:4,[0 1 0 -1 1]),'B-');
%      p2 = fnrfn(spmak(augknt([0 4],4),[-1 0 1 2]),2);
%      p1plusp2 = spmak( fnbrk(p1,'k'), fnbrk(p1,'c')+fnbrk(p2,'c') );
%
% �́A2�̊֐� p1 �� p2 ��(�_�Ɋւ���) �a��^���܂��B����́A�����Ƃ�
% �����ߓ_��œ����^�[�Q�b�g�̎����������������̃X�v���C���ł��邽�߁A
% �@�\���܂��B
%
%      x = 1:10; y = -2:2; [xx, yy] = ndgrid(x,y);
%      pp = csapi({x,y},sqrt((xx -4.5).^2+yy.^2));
%      ppp = fnbrk(pp,{4,[-1 1]});
%
% �́A�����` [b4,b5] x [-1,1] �� pp-�^ �X�v���C���ƈ�v����X�v���C����
% �^���܂��B�����ŁAb4, b5 �́A1�Ԗڂ̕ϐ��ɑ΂���u���[�N�|�C���g���
% 4�Ԗڂ�5�Ԗڂ̓_�ł��B 
%
% �Q�l : SPMAK, PPMAK, RSMAK, RPMAK, STMAK, SPBRK, PPBRK, RSBRK, RPBRK, 
%        STBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
