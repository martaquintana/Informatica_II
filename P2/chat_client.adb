with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Ada.Characters.Handling;
with Chat_Messages;

procedure Chat_Client is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ACH renames Ada.Characters.Handling;
   package CM renames Chat_Messages;
   use type CM.Message_Type;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Expired : Boolean;
   Shutdown : Boolean := False;

   Puerto: Integer;
   Salir: Integer := 3;
   Quit:Boolean:= False;

   Nickname: ASU.Unbounded_String;
   Mess: CM.Message_Type;
   Comentario:   ASU.Unbounded_String;
   Reply:   ASU.Unbounded_String;
   --Nickname de los mensajes  que le llegan al lector;
   Nick: ASU.Unbounded_String;

   Usage_Error: exception;



begin

   if ACL.Argument_Count /= 3 then
      raise Usage_Error;
   end if;
   -- Construye el End_Point en el que está atado el servidor
   --Nicknames siempre me los guardo en minuscula
   Nickname:= ASU.To_Unbounded_String(ACH.To_Lower(ACL.Argument(3)));
   Puerto:= Integer'Value(ACL.Argument(2));
   Server_EP := LLU.Build((LLU.To_IP(ACL.Argument(1))), Puerto);
   --Hay que poner ./client f-l3209-pc19 9001   (Donde esta el server)

   -- Construye un End_Point libre cualquiera y se ata a él
   LLU.Bind_Any(Client_EP);

   --Iniciar sesion
   LLU.Reset(Buffer);
   Mess:= CM.Init;
   CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje INIT
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP); --Envia el Client_EP
   ASU.Unbounded_String'Output(Buffer'Access, Nickname); -- envia el Nickname
   -- envía el contenido del Buffer al server
   LLU.Send(Server_EP, Buffer'Access);

  ---------NICKNAME READER-------------------

   if ASU.To_String(Nickname) = "reader" then
      while not Shutdown  loop
         LLU.Reset(Buffer);
         --Espera 60 segundos y si ve que no le contestan informa de que el Plazo se ha expirado y se cierra la conexion
         LLU.Receive(Client_EP, Buffer'Access, 60.0, Expired);
         if Expired then
            Ada.Text_IO.Put_Line ("Plazo expirado");
            Shutdown := True;
         else
            Mess := CM.Message_Type'Input(Buffer'Access);
            Nick := ASU.Unbounded_String'Input(Buffer'Access);
            Reply:= ASU.Unbounded_String'Input(Buffer'Access);
            Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Reply));
         end if;
      end loop;
      LLU.Finalize;

   else
  ------ NICKNAME CUALQUIERA--> WRITER ----------
      while not Quit loop
         LLU.Reset(Buffer);
         Mess:= CM.Writer;
         CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje Writer
         LLU.End_Point_Type'Output(Buffer'Access, Client_EP); --Envia el Client_EP
         Ada.Text_IO.Put("Message: ");
         Comentario:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

         if ASU.To_String(Comentario) /= ".quit" then
            ASU.Unbounded_String'Output(Buffer'Access, Comentario);
            -- envía el contenido del Buffer
            LLU.Send(Server_EP, Buffer'Access);


         else
            Quit :=True;
         end if;
      end loop;

   -------------------------------------------------

   end if;

   -- termina Lower_Layer_UDP
   LLU.Finalize;

exception

  when Usage_Error =>
        Ada.Text_IO.Put_Line ("./chat_client <HOSTSERVER> <PORTSERVER>  <NICKNAME> " );
        LLU.Finalize;

   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client;
