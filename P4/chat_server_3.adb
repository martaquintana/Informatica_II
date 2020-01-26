with Hash_Maps_G;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Handler_Server;
with Ada.Characters.Handling;
with Check_Arguments;


procedure Chat_Server_3 is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ACH renames Ada.Characters.Handling;
   package CA renames Check_Arguments;

   Server_EP: LLU.End_Point_Type;
   Puerto: Integer;
   Nickname: ASU.Unbounded_String;

   Option: Character;
   Max_Clients: Natural:= 0;

   Usage_Error: exception;
   Number_Clients_Error: exception;

 begin

   if ACL.Argument_Count /= 2 then   --  2-->(Port and Max_Clients)
      raise Usage_Error;
   end if;
   -- construye un End_Point en una dirección y puerto concretos
   -- PUERTO y Max_Clients INTRODUCIDO POR EL TERMINAL
   -- Comprobar que son correctos con el Check_Arguments
   Puerto:= CA.Checking_Integer;
   Max_Clients:= CA.Checking_Natural;
   if Max_Clients < 2 or Max_Clients > 50 then
   --- debe ser  2 < Max_Clients < 50
      raise Number_Clients_Error;
   end if;

   Server_EP := LLU.Build (LLU.To_IP(LLU.Get_Host_Name), Puerto);
   --Ada.Text_IO.Put_Line("Estoy en : " & LLU.Get_Host_Name);
   --Ada.Text_IO.Put_Line("con la IP : " & LLU.To_IP(LLU.Get_Host_Name));

   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP,Handler_Server.Server_Handler'Access);

   ----MENU OPCIONES VISUALIZACIÓN CLIENTES DEL SERVER-----
   loop
      Ada.Text_IO.Get_Immediate(Option);
      if ACH.To_Lower(Option) = 'l' then
        Handler_Server.Print_Map_Activos;
      elsif ACH.To_Lower(Option) = 'o' then
        Handler_Server.Print_Map_Antiguos;
      end if;
   end loop;


 exception

   when Usage_Error =>
         Ada.Text_IO.Put_Line("./chat_server_3 <PORTSERVER> <MAX-CLIENTS>");
         LLU.Finalize;
   when Number_Clients_Error =>
         Ada.Text_IO.Put_Line("MAX-CLIENTS el rango es de 2 a 50");
         LLU.Finalize;

   when Constraint_Error =>
         Ada.Text_IO.Put_Line(" El puerto debe ser 4 dígitos y");
         Ada.Text_IO.Put_Line("el máximo de clientes debe ser un número natural entre 2 y 50");
         LLU.Finalize;

   when CA.Check_Arguments_Error =>
	       Ada.Text_IO.Put_Line("Error Entering Port: El puerto debe ser 4 dígitos, lo sentimos.");
         LLU.Finalize;

   when Ex:others =>
         Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                               Ada.Exceptions.Exception_Name(Ex) & " en: " &
                               Ada.Exceptions.Exception_Message(Ex));
         LLU.Finalize;


end Chat_Server_3;
