% DEFUZZ �����o�V�b�v�֐��̔�t�@�W�B��
% 
% �\��
%   out = defuzz(x,mf,type)
% 
% �ڍ�
% defuzz(x,mf,type) �́A�ݒ肵���ϐ��lx�ŁA���ꂼ��ɑΉ����郁���o�V�b
% �v�֐� mf���A���� type �ɏ]���đI��������t�@�W�B���@���g���Ĕ�t�@�W
% �B���l out ���o�͂��܂��B�ϐ� type �́A���̒���1�ɑΉ����܂��B
% 
% centroid  : �ʐϏd�S�@
% bisector  : �ʐϓ񕪖@
% mom       : �ő啽�ϒl
% som       : �ő�l�̍ŏ����@
% lom       : �ő�l�̍ő剻�@
% 
% type �Őݒ肵�����̂���q�̂��̂ɑΉ����Ȃ��ꍇ�A���[�U�ݒ�̊֐��Ƃ�
% �Ĉ����܂��Bx �� mf �́A��t�@�W�B�������o�͂��쐬���邽�߂ɁA���[�U
% �֐��ɓn����܂��B
% 
% ���
%    x = -10:0.1:10;
%    mf = trapmf(x,[-10 -8 -4 7]);
%    xx = defuzz(x,mf,'centroid');
% 
% ����ɁA�����̗��ɂ��ẮADEFUZZDM �����������������B



%   Copyright 1994-2002 The MathWorks, Inc. 
