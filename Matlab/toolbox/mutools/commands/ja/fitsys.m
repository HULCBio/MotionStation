% function sys = fitsys(frdata,order,weight,code,idnum,discflg)
%
% FITSYS�́AWEIGHT��(�I�v�V�����Ƃ���)��`���ꂽ���g���ˑ��d�݂��g���āA
% ���g�������f�[�^FRDATA������ORDER�̓`�B�֐��ŋߎ����܂��B
%
% FRDATA : �^����ꂽ���g�������f�[�^��VARYING�s��B����́A�s�܂��͗��
%          VARYING�s��łȂ���΂Ȃ�܂���B
% ORDER  : �f�[�^���ߎ�����SYSTEM�s��̎����B
% WEIGHT : VARYING/SYSTEM/CONSTANT�s��B�ŏ����ߎ��̏d�݂Ƃ��Ďg����
%          ��(�f�t�H���g=1)�B
% CODE   : 0 - SYS�̋ɂ̈ʒu�ɐ����͂���܂���(�f�t�H���g)�B
%          1 - SYS�͈���ȍŏ��ʑ��ɐ�������AFRDATA��1�s1���VARYING�s
%              ��łȂ���΂Ȃ�܂���B
%          2 - �L���ߎ��ɐ��������̂ŁASYS�͈���ł��B
% IDNUM  : �ŏ����̌J��Ԃ���(�f�t�H���g = 2)
% DISCFLG: DISCFLG == 1(�f�t�H���g=0)�̏ꍇ�A���ׂĂ̎��g���f�[�^�͒P��
%          �~�f�[�^�Ƃ��ĉ��߂���ASYS�͗��U���ԂƂ��ĉ��߂���܂��BDI-
%          SCFLG == 0�̏ꍇ�A���g���f�[�^�́A�����ɉ��߂���ASYS�͘A����
%          �Ԃɉ��߂���܂��B4�Ԗڂ̈��� CODE�́A�I�v�V�����ł��BCODE ==
%          0(�f�t�H���g)�̏ꍇ�A�L�����ߎ��́A������󂯂܂���BCODE == 
%          1 �̏ꍇ�AMU�V���Z�V�X���[�`���ŁA�L�����ߎ��́A�����ɑ΂��āA
%          �X�y�N�g��������P�ɍs�����ƂŁA����ŁA�ŏ��ʑ��ł��邱�Ƃ�
%          �����ɂȂ�܂��B���̏ꍇ�A����FRDATA�́A�v���O����GENPHASE��
%          �瓾���A����́A���ɁA����ŁA�ŏ��ʑ��`�B�֐��ɑΉ����Ă�
%          �܂��B



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
