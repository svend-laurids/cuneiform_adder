unit babylonian_math;
INTERFACE
type
	Babylonian = Record
		value : Array of Byte;
		digits : Byte;
	end;
function Math_Power(base, exponent : integer) : integer;
function Babylonian_Set(value : integer) : babylonian;
procedure Babylonian_Write(baby : babylonian);
procedure Writerepeat(value : string; repeats : integer);
procedure Babylonian_Writeoriginal(baby : babylonian);
IMPLEMENTATION
function Math_Power(base, exponent : integer) : integer;
var
	res : integer;
begin
	if exponent = 0 then begin
		exit(1);
	end;
	res := base;
	exponent := exponent-1;
	while exponent <> 0 do begin
		res := res*base;
		exponent := exponent-1;
	end;	
	math_power := res; 
end;
function Babylonian_Set(value : integer) : babylonian;
var
	i, temp, currentplacevalue, currentpower : integer;
	res : babylonian;
begin
	res.digits := 0;
	i := 0;
	temp := 1;
	while ((value - temp) >= 0) do begin
	       	res.digits := res.digits+1;
		temp := math_power(60, res.digits);
	end;
	if res.digits = 0 then begin
		writeln('error');
		halt(0);
	end;
	setlength(res.value, res.digits);
	i := 0;
	while i <> res.digits do begin
		currentplacevalue := res.digits-i-1;
		currentpower := math_power(60, currentplacevalue);
		temp := value div currentpower; 
		res.value[currentplacevalue] := temp; 
		value := value - temp*currentpower;	
		i := i+1;
	end;
	babylonian_set := res;	
end;
procedure Babylonian_Write(baby : babylonian);
var
	i : integer;
begin
	for i := 0 to baby.digits-1 do begin
		write('[', baby.value[i], '], ');
	end;	
	writeln();
end;
procedure Writerepeat(value : string; repeats : integer);
var
	i : integer;
begin
	for i := 0 to repeats-1 do begin
		write(value);
	end;
end;
procedure Babylonian_Writeoriginal(baby : babylonian);
var
	i, tenths, ones : Integer;
begin
	i := baby.digits;
	while i <> 0 do begin
		tenths := baby.value[i-1] div 10;
		if tenths <> 0 then WriteRepeat('S', tenths);
		ones := baby.value[i-1] - 10*tenths;
		if ones <> 0 then WriteRepeat('L', ones);
		Write('   ');
		i := i-1;
	end;
end;
end.
