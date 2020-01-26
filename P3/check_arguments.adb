
package body Check_Arguments is

function Checking_Natural return Natural
 is
	Numero: Natural:= 5; --Valor por defecto
  begin
	Numero:= Natural'Value(ACL.Argument(2));
	--Ada.Text_IO.Put_Line(Natural'Image(Numero));
	return Numero;
exception
when CONSTRAINT_ERROR =>

	--Ada.Text_IO.Put_Line(Natural'Image(Numero));
	--raise Max_Clients_Error;
	return 0;


end Checking_Natural;

function Checking_Integer return Integer
 is
	Numero: Integer:= 0; --Valor por defecto
  begin
	Numero:= Integer'Value(ACL.Argument(1));
	return Numero;
exception
when CONSTRAINT_ERROR =>
	--Ada.Text_IO.Put_Line(Integer'Image(Numero));
	raise Check_Arguments_Error;
	return Numero;


end Checking_Integer;
end Check_Arguments;
