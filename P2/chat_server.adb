with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Collections;

procedure Chat_Server is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   package CC renames Client_Collections;
   use type CM.Message_Type;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;
   Reply: ASU.Unbounded_String;
   Expired : Boolean;
   Puerto: Integer;

   Nickname: ASU.Unbounded_String;
   Mess: CM.Message_Type;
   Comentario: ASU.Unbounded_String;


   Writers: CC.Collection_Type;
   Readers: CC.Collection_Type;

   --Parte opcional--- Extension--
   Admin_EP: LLU.End_Point_Type;
   Admin_Password: ASU.Unbounded_String;
   Password: ASU.Unbounded_String;
   Data: ASU.Unbounded_String;
   Nick_To_Ban: ASU.Unbounded_String;
   Shutdown: Boolean := False;

   Usage_Error: exception;

begin

   if ACL.Argument_Count /= 2 then   --2 (port and password extension)
      raise Usage_Error;
   end if;

   -- construye un End_Point en una dirección y puerto concretos
   -- PUERTO INTRODUCIDO POR EL TERMINAL
   Puerto:= Integer'Value(ACL.Argument(1));
   Password:= ASU.To_Unbounded_String(ACL.Argument(2)); --extension
   Server_EP := LLU.Build (LLU.To_IP(LLU.Get_Host_Name), Puerto);
   --Ada.Text_IO.Put_Line("Estoy en : " & LLU.Get_Host_Name);
   --Ada.Text_IO.Put_Line("con la IP : " & LLU.To_IP(LLU.Get_Host_Name));

   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP);

    -- bucle infinito
   while not Shutdown loop
      -- reinicializa (vacía) el buffer para ahora recibir en él
      LLU.Reset(Buffer);

      -- espera 1000.0 segundos a recibir algo dirigido al Server_EP
      --   . si llega antes, los datos recibidos van al Buffer
      --     y Expired queda a False
      --   . si pasados los 1000.0 segundos no ha llegado nada, se abandona
      --     la espera y Expired queda a True
      LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);

      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
         -- mensaje que llega
         Mess:= CM.Message_Type'Input(Buffer'Access);

         if Mess = CM.Init then
            begin
               Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
               Nickname := ASU.Unbounded_String'Input (Buffer'Access);

               if ASU.To_String(Nickname) = "reader" then
                  CC.Add_Client (Readers, Client_EP, Nickname, False);
                  Ada.Text_IO.Put_Line ("INIT received from "& ASU.To_String(Nickname));

               else
                  CC.Add_Client (Writers, Client_EP, Nickname, True);
                  Ada.Text_IO.Put_Line ("INIT received from "& ASU.To_String(Nickname));
                  LLU.Reset (Buffer);
                  CM.Message_Type'Output(Buffer'Access, CM.Server);
                  ASU.Unbounded_String'Output(Buffer'Access,ASU.To_Unbounded_String("server"));
                  ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String(ASU.To_String(Nickname) & " joins the chat"));
                  CC.Send_To_All(Readers,Buffer'Access);

               end if;

            exception
               when CC.Client_Collection_Error =>
                  Ada.Text_IO.Put("INIT received from "& ASU.To_String(Nickname));
                  Ada.Text_IO.Put_Line(". IGNORED, nick already used");
            end;

          elsif Mess = CM.Writer then
             begin
                Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
                Nickname:= CC.Search_Client(Writers,Client_EP);
                Comentario := ASU.Unbounded_String'Input (Buffer'Access);

                Ada.Text_IO.Put_Line ("WRITER received from "& ASU.To_String(Nickname) & ": " & ASU.To_String(Comentario) );

                LLU.Reset (Buffer);

                CM.Message_Type'Output(Buffer'Access, CM.Server);
                ASU.Unbounded_String'Output(Buffer'Access,Nickname);
                ASU.Unbounded_String'Output(Buffer'Access, Comentario);
                CC.Send_To_All(Readers,Buffer'Access);

             exception
                when  CC.Client_Collection_Error =>
                      Ada.Text_IO.Put_Line ("WRITER received from unknown client. IGNORED");

             end;

          ----Extension de la práctica, interación con Chat_Admin----
          elsif Mess = CM.Collection_Request then

                Admin_EP := LLU.End_Point_Type'Input(Buffer'Access); --Recive el Admin_EP
                Admin_Password := ASU.Unbounded_String'Input(Buffer'Access); -- recibe la contraseña

                if ASU.To_String(Admin_Password) = ASU.To_String(Password) then
                  Ada.Text_IO.Put_Line("LIST_REQUEST received");
                  LLU.Reset (Buffer);
                  CM.Message_Type'Output(Buffer'Access, CM.Collection_Data);
                  Data := ASU.To_Unbounded_String(CC.Collection_Image (Writers));
                  ASU.Unbounded_String'Output(Buffer'Access, Data);
                  LLU.Send(Admin_EP,Buffer'Access);
                else
                   Ada.Text_IO.Put_Line("LIST_REQUEST received. IGNORED, incorrect password");
                end if;
          elsif Mess = CM.Ban then
             begin
                Admin_Password := ASU.Unbounded_String'Input(Buffer'Access); --  recive la contraseña
                Nick_To_Ban := ASU.Unbounded_String'Input(Buffer'Access); -- nick que quiere borrar el admin

                if ASU.To_String(Admin_Password) = ASU.To_String(Password) then
                  CC.Delete_Client (Writers,Nick_To_Ban);
                  Ada.Text_IO.Put_Line("Ban received for " & ASU.To_String(Nick_To_Ban));
                else
                     Ada.Text_IO.Put_Line("Ban received for " & ASU.To_String(Nick_To_Ban) & ". IGNORED, incorrect password");
                end if;

             exception
               when CC.Client_Collection_Error =>
                  Ada.Text_IO.Put_Line("Ban received for " & ASU.To_String(Nick_To_Ban) & ". IGNORED, nick not found");
             end;


          elsif Mess = CM.Shutdown then
                Admin_Password := ASU.Unbounded_String'Input(Buffer'Access); --  recive la contraseña
                if ASU.To_String(Admin_Password) = ASU.To_String(Password) then
                   Ada.Text_IO.Put_Line("SHUTDOWN received");
                   Shutdown := True;
                end if;
          end if;

       end if;
   end loop;

   LLU.Finalize;

exception

  when Usage_Error =>
         Ada.Text_IO.Put_Line("./chat_server <PORTSERVER> <PASSWORD>");
         LLU.Finalize;

   when Ex:others =>
         Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                               Ada.Exceptions.Exception_Name(Ex) & " en: " &
                               Ada.Exceptions.Exception_Message(Ex));
         LLU.Finalize;


end Chat_Server;
