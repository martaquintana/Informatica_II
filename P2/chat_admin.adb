with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;


procedure Chat_Admin is

  package LLU renames Lower_Layer_UDP;
  package ASU renames Ada.Strings.Unbounded;
  package ACL renames Ada.Command_Line;
  package CM renames Chat_Messages;

  use type CM.Message_Type;


  Server_EP: LLU.End_Point_Type;
  Admin_EP: LLU.End_Point_Type;
  Buffer:    aliased LLU.Buffer_Type(1024);
  Expired : Boolean;

  Password: ASU.Unbounded_String;
  Puerto: Integer;


  Mess: CM.Message_Type;

  Usage_Error: exception;

  Option: Natural;
  Quit: Boolean := False;
  Nick_To_Ban: ASU.Unbounded_String;
  Data: ASU.Unbounded_String;


begin
   if ACL.Argument_Count /= 3 then
      raise Usage_Error;
   end if;
   Password := ASU.To_Unbounded_String(ACL.Argument(3));
   Puerto := Integer'Value(ACL.Argument(2));
   Server_EP := LLU.Build((LLU.To_IP(ACL.Argument(1))), Puerto);

 -- Construye un End_Point libre cualquiera y se ata a él
   LLU.Bind_Any(Admin_EP);
   LLU.Reset(Buffer);

   while not Quit loop

     Ada.Text_IO.New_Line(1);
     Ada.Text_IO.Put_Line("Options");
     Ada.Text_IO.Put_Line("1 Show writers collection");
     Ada.Text_IO.Put_Line("2 Ban writer");
     Ada.Text_IO.Put_Line("3 Shutdown server");
     Ada.Text_IO.Put_Line("4 Quit");
     Ada.Text_IO.New_Line(1);
     Ada.Text_IO.Put("Your option? ");
     Option := Natural'Value(Ada.Text_IO.Get_Line);

     LLU.Reset(Buffer);

     if Option = 4 then
        Quit := True;

     elsif Option = 1 then
       Ada.Text_IO.New_Line(1);

       Mess:= CM.Collection_Request;
       CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje Collection Request
       LLU.End_Point_Type'Output(Buffer'Access, Admin_EP); --Envia el Admin_EP
       ASU.Unbounded_String'Output(Buffer'Access, Password); -- envia la contraseña(Password)
       LLU.Send(Server_EP,Buffer'Access);

       LLU.Reset(Buffer);
       --Si no se obtiene mensaje en 5 sengundos --> la contraseña es incorrecta
       LLU.Receive(Admin_EP, Buffer'Access, 5.0, Expired);

       if Expired then
            Ada.Text_IO.Put_Line ("Incorrect password.");
            Quit := True;
       else
          Mess := CM.Message_Type'Input(Buffer'Access);
          if Mess = CM.Collection_Data then
             Data := ASU.Unbounded_String'Input(Buffer'Access);
             Ada.Text_IO.Put_Line(ASU.To_String(Data));
          end if;

       end if;


     elsif Option = 2 then
       Ada.Text_IO.Put("Nick to ban? ");
       Nick_To_Ban := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

       Mess:= CM.Ban;
       CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje Ban
       ASU.Unbounded_String'Output(Buffer'Access, Password); -- envia la contraseña(Password)
       ASU.Unbounded_String'Output(Buffer'Access, Nick_To_Ban); --Envia el nick que quiere borrar


     elsif Option = 3 then
       Ada.Text_IO.Put_Line("Server shutdown sent");
       Mess:= CM.Shutdown;
       CM.Message_Type'Output(Buffer'Access, Mess); -- envia el Mensaje
       ASU.Unbounded_String'Output(Buffer'Access, Password); -- envia la contraseña( Password)

     else

       Ada.Text_IO.Put_Line("Sorry, Options are only 1, 2, 3 or 4");

     end if;

     LLU.Send(Server_EP,Buffer'Access);

   end loop;

   LLU.Finalize;


exception

   when Usage_Error =>
         Ada.Text_IO.Put_Line("./chat_admin <HOSTSERVER> <PORTSERVER>  <PASSWORD> ");
         LLU.Finalize;

   when Ex:others =>
         Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                               Ada.Exceptions.Exception_Name(Ex) & " en: " &
                               Ada.Exceptions.Exception_Message(Ex));
         LLU.Finalize;


end Chat_Admin;
