% STATSET   STATS �I�v�V�����\���̂̍쐬/�C��
%
% OPTIONS = STATSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) �́A�w�肳�ꂽ
% �p�����[�^���w�肳�ꂽ�l�������v�ʂ̃I�v�V�����\���� OPTIONS ���쐬
% ���܂��B�w�肳��Ă��Ȃ��p�����[�^�͂������ [] ���ݒ肳��܂��B���v
% �֐��� OPTIONS ��n���ꍇ�ɁA�p�����[�^�l�Ƃ��� [] ��ݒ肷��ƁA����
% �p�����[�^�̃f�t�H���g�l�𗘗p���邱�Ƃ��Ӗ����܂��B�p�����[�^�����ȗ�
% ���āA���j�[�N�ɋ�ʂł��镶����Ƃ��Ďw�肷�邱�Ƃ��\�ł��B
% ����: ������̒l�̃p�����[�^�ɑ΂��āA�l�ɑ΂��Ċ��S�ȕ����񂪕K�v�ł��B
% �����ȕ����񂪗^����ꂽ�ꍇ�A�f�t�H���g���g���܂��B
%   
% OPTIONS = STATSET(OLDOPTS,'PARAM1',VALUE1,...) �́A�w�肳�ꂽ�l�ŏC��
% ���ꂽ�w�肳�ꂽ�p�����[�^������ OLDOPTS �̃R�s�[���쐬���܂��B
%   
% OPTIONS = STATSET(OLDOPTS,NEWOPTS) �́A�V�����I�v�V�����\���� NEWOPTS 
% �������̃I�v�V�����\���� OLDOPTS �Ɍ������܂��B��łȂ��l������ NEWOPTS 
% ���̔C�ӂ̃p�����[�^�́AOLDOPTS ���̑Ή�����Â��p�����[�^�ɏ㏑��
% ����܂��B
%   
% ���͈����Əo�͈����������Ȃ� STATSET �́A�f�t�H���g���I�v�V�����Ŏg�p
% ���邷�ׂĂ̊֐��ɑ΂��ē����ł���Ƃ��A{} ���Ŏ������f�t�H���g��
% ���Ƀp�����[�^���Ƃ����̉\�Ȓl�����ׂĕ\�����܂��B
% ����̊֐��ɑ΂���֐��̎d�l�̏ڍׂ�����ɂ́A(���Ŏ����悤��) 
% STATSET(STATSFUNCTION) ���g�p���Ă��������B
%
% OPTIONS = STATSET (���͈����������Ȃ�) �́A���ׂẴt�B�[���h�� [] ��
% �ݒ肳�ꂽ�I�v�V�����\���� OPTIONS ���쐬���܂��B
%
% OPTIONS = STATSET(STATSFUNCTION) �́ASTATSFUNCTION ���Ŏw�肳�ꂽ
% �œK���֐��Ɋ֘A���邷�ׂẴp�����[�^���ƃf�t�H���g�l�����I�v�V����
% �\���̂��쐬���܂��BSTATSET �́AOPTIONS ���̃p�����[�^�ɁASTATSFUNCTION 
% �ɑ΂��ėL���łȂ��p�����[�^�� [] ��ݒ肵�܂��B
% ���Ƃ��΁Astatset('factoran') �܂��� statset(@factoran) �́A�֐� 
% 'factoran' �Ɋ֘A���邷�ׂẴp�����[�^���ƃf�t�H���g�l���܂ރI�v�V����
% �\���̂��o�͂��܂��B
%   
% STATSET �p�����[�^:
%      Display     - �\���̃��x�� [ off | notify | final ]  
%      MaxFunEvals - �֐��]���̍ő勖�e�� [ ���̐��� ]
%      MaxIter     - �J��Ԃ��̍ő勖�e�� [ ���̐��� ]
%      TolBnd      - �p�����[�^�̋��E�̎����덷���e�l [ ���̃X�J�� ]
%      TolFun      - �ړI�֐��l�ɑ΂�������덷���e�l [ ���̃X�J�� ]
%      TolX        - ����ɑ΂�������덷���e�l [ ���̃X�J�� ]
%
% �Q�l : STATGET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/02/12 21:37:44 $
