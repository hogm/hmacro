create or replace library kernel32 is
	'C:\Winnt\system32\KERNEL32.DLL';
/
create or replace function GetComputerNameA (
	ComputerName out varchar2 /* コンピュータ名が戻される */
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
/* ret = 非0: 正常終了  0: 異常終了 */
var Name varchar2(2000);
begin
	/* コンピュータ名を知るI */
	:ret := GetComputerNameA(:Name);
end;
/
print
