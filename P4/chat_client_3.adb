with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Ada.Characters.Handling;
with Chat_Messages;
with Handler_Client;


procedure Chat_Client_3 is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ACH renames Ada.Characters.Handling;
   package CM renames Chat_Messages;
   use type CM.Message_Type;

   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Expired : Boolean;

   Puerto: Integer;
   Quit:Boolean:= False;

   Nickname: ASU.Unbounded_String;
   Mess: CM.Message_Type;
   Comentario:   ASU.Unbounded_String;

   Usage_Error: exception;
   Server_Error:exception;
   Admision_Error:exception;

   Acogido: Boolean;


 begin

   if ACL.Argument_Count /= 3 then
      raise Usage_Error;
   end if;
   -- Construye el End_Point en el que está atado el servidor
   --Nicknames siempre me los guardo en minuscula
   Nickname:= ASU.To_Unbounded_String(ACH.To_Lower(ACL.Argument(3)));
   Puerto:= Integer'Value(ACL.Argument(2));
   Server_EP := LLU.Build((LLU.To_IP(ACL.Argument(1))), Puerto);

   -- Construye un End_Point libre cualquiera y se ata a él
   LLU.Bind_Any(Client_EP_Receive);
   LLU.Bind_Any(Client_EP_Handler,Handler_Client.Client_Handler'Access);

   --Iniciar sesion
   --LLU.Reset(Buffer);
   Mess:= CM.Init;
   CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje INIT
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive); --Envia el Client_EP_Receive
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler); --Envia el Client_EP_Handler
   ASU.Unbounded_String'Output(Buffer'Access, Nickname); -- envia el Nickname
   -- envía el contenido del Buffer al server
   LLU.Send(Server_EP, Buffer'Access);


   LLU.Reset(Buffer);
   --Si transcurridos 10 segundos el cliente no ha recibido el Welcome
   LLU.Receive(Client_EP_Receive, Buffer'Access,10.0, Expired);

   if Expired then
        raise Server_Error;
   end if;

   Mess := CM.Message_Type'Input(Buffer'Access);
   Acogido := Boolean'Input(Buffer'Access);

   if not Acogido then
      raise Admision_Error;
   end if;

   if Mess = CM.Welcome and Acogido then
      Ada.Text_IO.Put_Line ("Mini-Chat v3.0: Welcome " & ASU.To_String(Nickname));
   else
      raise Admision_Error;
   end if;

  ------ NICKNAME CUALQUIERA--> WRITER MENOS server! ----------
   while not Quit loop
      LLU.Reset(Buffer);

      Mess:= CM.Writer;
      CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje Writer
      LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler); --Envia el Client_EP_Handler
      ASU.Unbounded_String'Output(Buffer'Access,Nickname); --Nickname del cliente
      Ada.Text_IO.Put(">> ");
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
   ----------------Logout---------------------------
   LLU.Reset(Buffer);
   Mess := CM.Logout;
   CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje Logout
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler); --Envia el Client_EP_Handler
   ASU.Unbounded_String'Output(Buffer'Access,Nickname); --Nickname del cliente
   LLU.Send(Server_EP, Buffer'Access);
   -- termina Lower_Layer_UDP
   LLU.Finalize;

 exception

   when Usage_Error =>
         Ada.Text_IO.Put_Line ("./chat_client_3 <HOSTSERVER> <PORTSERVER>  <NICKNAME> ");
         LLU.Finalize;

   when Server_Error =>
         Ada.Text_IO.Put_Line ("Server unreachable");
         LLU.Finalize;

   when Constraint_Error =>
         Ada.Text_IO.Put_Line ("Error Entering Port : El puerto deben ser 4 dígitos");
         LLU.Finalize;

   when Admision_Error =>
         Ada.Text_IO.Put_Line ("Mini-Chat v3.0 IGNORED new user " & ASU.To_String(Nickname) & ", nick already used");
         LLU.Finalize;

   when Ex:others =>
         Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                               Ada.Exceptions.Exception_Name(Ex) & " en: " &
                               Ada.Exceptions.Exception_Message(Ex));
         LLU.Finalize;


end Chat_Client_3;
