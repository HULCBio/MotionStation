% SORTED   ���b�V���T�C�g�ɑ΂���T�C�g�̈ʒu�t��
%
% POINTER = SORTED(MESHSITES, SITES) �́A�ȉ��̏����ɏ]���s�x�N�g���ł��B
%
% ���ׂĂ� j ��
% POINTER(j) = #{ i : MESHPOINTS(i)  <=  sort(SITES)(j) }
%
% �]���āAMESHPOINTS �� SITES �̗������񌸏��̏ꍇ�A
%
% ���ׂĂ� j ��
% MESHSITES(POINTER(j))  <=  SITES(j)  <  MESHSITES(POINTER(j)+1)
%
% �ƂȂ�APOINTER(j) ��0�ɓ������Ƃ��́ASITES(j) < MESHSITES(1) �ł���
% ���Ƃ��Ӗ����Alength(MESHSITES) �ɓ������Ƃ��́AMESHSITES(end) <= SITES(j) 
% �ł��邱�Ƃ��Ӗ����܂��B
%
% ���:
%
%      sorted( 1:4 , [0 1 2.1 2.99 3.5 4 5])
%
% �́AMESHSITES �Ƃ��� 1:4 ���ASITES �Ƃ��� [0 1 2.1 2.99 3.5 4 5] ���w��
% ���܂��B�܂��A
%
%      sorted( 1:4 , [2.99 5 4 0 2.1 1 3.5])
% 
% �Ƃ��Ă��A�o�� [0 1 2 2 3 4 4] ���^�����܂��B
%
% �Q�l : PPUAL, SPVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
