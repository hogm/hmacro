create or replace library kernel32 is
	'C:\Winnt\system32\KERNEL32.DLL';
/
create or replace function GetComputerNameA (
	ComputerName out varchar2 /* �R���s���[�^�����߂���� */
) return binary_integer is
	language C
	name "GetComputerNameA"
	library kernel32
	calling standard PASCAL
	parameters (
		ComputerName 
		, ComputerName LENGTH
	);
/
set linesize 80 pagesize 1000 long 4000;
var ret number;
/* ret = ��0: ����I��  0: �ُ�I�� */
var Name varchar2(2000);
begin
	/* �R���s���[�^����m��I */
	:ret := GetComputerNameA(:Name);
end;
/
print
