% function [bnd,q,dd,gg] = genmu(m,c,blk)
%
% ��ʉ�mu�̏�E�̌v�Z
%
% [I - Delta M;C]�́Anorm < 1/BND�ł���BLK���̂��ׂĂ̐ۓ���Delta�̗��
% �����N�������Ȃ��悤�ɕۏ؂���Ă��܂��B����́ADD��GG�ɏo�͂��ꂽ�X�P
% �[�����O�s��ɂ���Ċm�F�����悤�ɁAmu(M+QC)<=BND�ł���s��Q�ɂ����
% �ۏ؂���Ă��܂��B
%
% �Q�l  MU, CMMUSYN



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
