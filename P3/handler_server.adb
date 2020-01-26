with Ada.Strings.Maps;
----------------------

package body Handler_Server is

  use type Ada.Calendar.Time;
      function Time_Image (T: Ada.Calendar.Time) return String is
      begin
          return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
      end Time_Image;

      procedure Buscar_Inativo(M: in Active_Map.Map;
                               Old_Nick: out ASU.Unbounded_String) is
          C: Active_Map.Cursor:= Active_Map.First(M);
          Old_Connection: Ada.Calendar.Time;

        begin
          Old_Nick := Active_Map.Element(C).Key;
          Old_Connection:=Active_Map.Element(C).Value.Last_Connection;

          while Active_Map.Has_Element(C) loop
            if   Active_Map.Element(C).Value.Last_Connection < Old_Connection then
              Old_Connection:= Active_Map.Element(C).Value.Last_Connection;
              Old_Nick:= Active_Map.Element(C).Key;
            end if;
            Active_Map.Next(C);
          end loop;
        end Buscar_Inativo;


      function SacarIP_PUERTO (EP: LLU.End_Point_Type) return ASU.Unbounded_String is
        Port:ASU.Unbounded_String;
        IP:ASU.Unbounded_String;
        LLU_Image: ASU.Unbounded_String;
        espacio:Integer;
        coma:Integer;
      begin
        LLU_Image:=ASU.To_Unbounded_String(LLU.Image(EP));
                    --Sacar el Puerto
                    for k in 1..5  loop
                       espacio := ASU.Index(LLU_Image," ");
                       LLU_Image:= ASU.Tail(LLU_Image, ASU.Length(LLU_Image) - espacio);
                       Port:=LLU_Image;
                    end loop;

                    --Sacar la IP
                    LLU_Image:=ASU.To_Unbounded_String(LLU.Image(EP));

                    for k in 1..2  loop
                       espacio := ASU.Index(LLU_Image," ");
                       LLU_Image:= ASU.Tail(LLU_Image, ASU.Length(LLU_Image) - espacio);
                    end loop;
                    coma := ASU.Index(LLU_Image,",");
                    LLU_Image:= ASU.Head(LLU_Image, coma -1);
                    IP:=LLU_Image;

                    return ASU.To_Unbounded_String( ASU.To_String(IP) & ":" & ASU.To_String(Port));
      end SacarIP_PUERTO;

  procedure Print_Map_Activos is
 C: Active_Map.Cursor:= Active_Map.First(Active_Clients);
  begin
     Ada.Text_IO.Put_Line ("");
     Ada.Text_IO.Put_Line ("ACTIVE CLIENTS");
     Ada.Text_IO.Put_Line ("==============");

     while Active_Map.Has_Element(C) loop
        Ada.Text_IO.Put(ASU.To_String(Active_Map.Element(C).Key));
        Ada.Text_IO.Put(" " & ASU.To_String(SacarIP_PUERTO(Active_Map.Element(C).Value.EP)));
        Ada.Text_IO.Put_Line(" " & Time_Image(Active_Map.Element(C).Value.Last_Connection));
        Active_Map.Next(C);
     end loop;
  end Print_Map_Activos;


  procedure Print_Map_Antiguos is
    ---IMPLEMENTAR INACTIVE CLIENTS
 C: Inactive_Map.Cursor:= Inactive_Map.First(Inactive_Clients);
  begin
     Ada.Text_IO.Put_Line ("");
     Ada.Text_IO.Put_Line ("OLD CLIENTS");
     Ada.Text_IO.Put_Line ("===========");

     while Inactive_Map.Has_Element(C) loop
        Ada.Text_IO.Put(ASU.To_String(Inactive_Map.Element(C).Key));
        Ada.Text_IO.Put_Line(": " & Time_Image(Inactive_Map.Element(C).Value.Last_Connection));
        Inactive_Map.Next(C);
     end loop;
  end Print_Map_Antiguos;




procedure Server_Handler (From : in LLU.End_Point_Type;
                          To : in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type) is

    Client_EP_Receive: LLU.End_Point_Type;
    Client_EP_Handler: LLU.End_Point_Type;

    Mess : CM.Message_Type;
    Comentario: ASU.Unbounded_String;
    Nickname: ASU.Unbounded_String;

    Old_Nick: ASU.Unbounded_String;
    C: Active_Map.Cursor:= Active_Map.First(Active_Clients);
    Acogido: Boolean := True;
    Encontrado:Boolean :=False;



    procedure Send_To_All(M:Active_Map.Map;
                          P_Buffer: access LLU.Buffer_Type;
                          Nick: ASU.Unbounded_String) is
      C: Active_Map.Cursor := Active_Map.First(M);
      Element : Active_Map.Element_Type;
    begin
        while Active_Map.Has_Element(C) loop
          Element:= Active_Map.Element(C);
          if ASU.To_String(Element.Key)= ASU.To_String(Nick) then
            Active_Map.Next(C);
          else
            LLU.Send(Element.Value.EP, P_Buffer);
            Active_Map.Next(C);
          end if;
        end loop;

    end Send_To_All;

    procedure Print_Map (M : Active_Map.Map) is
   C: Active_Map.Cursor:= Active_Map.First(M);
    begin
       Ada.Text_IO.Put_Line ("");
       Ada.Text_IO.Put_Line ("Map");
       Ada.Text_IO.Put_Line ("===");

       while Active_Map.Has_Element(C) loop
          Ada.Text_IO.Put_Line (ASU.To_String(Active_Map.Element(C).Key));
          Active_Map.Next(C);
       end loop;
    end Print_Map;


begin
  --Mensajes que le llegan de los clientes
  --LLU.Reset(P_Buffer.all);
  -- mensaje que llega

   Mess:= CM.Message_Type'Input(P_Buffer);
   if Mess = CM.Init then

             Client_EP_Receive := LLU.End_Point_Type'Input (P_Buffer);
             Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
             Nickname := ASU.Unbounded_String'Input(P_Buffer);
             Ada.Text_IO.Put ("INIT received from "& ASU.To_String(Nickname));

             Values_Active_Map.EP:= Client_EP_Handler;
             Values_Active_Map.Last_Connection:= Ada.Calendar.Clock;
             -----
             ---COMPROBAR QUE PUEDE ENTRAR O NO
             -----
             Active_Map.Get(Active_Clients, Nickname, Values_Active_Map, Encontrado);
             if Encontrado or  ASU.To_String(Nickname) = "server" then
               Acogido := False;
               Ada.Text_IO.Put_Line(": IGNORED. nick already used ");
             end if;

             if Acogido then
                begin
                ---GUARDARLO---
                Ada.Text_IO.Put_Line(": ACCEPTED");
                LLU.Reset (P_Buffer.all);
                CM.Message_Type'Output(P_Buffer, CM.Welcome);
                Boolean'Output(P_Buffer,Acogido);


                --ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String(ASU.To_String(Nickname) & " joins the chat"));
                LLU.Send(Client_EP_Receive,P_Buffer); --ENVIARSELO

                --AÑADIR EL NUEVO
                Active_Map.Put(Active_Clients, Nickname,Values_Active_Map);
                --VER SI ES ACEPTADO O NO SI hay error Active_Map.Full_Map -> Excepción
              --Print_Map(Active_Clients);

                LLU.Reset (P_Buffer.all);

                CM.Message_Type'Output(P_Buffer,CM.Server);
                ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String("server"));
                ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String(ASU.To_String(Nickname) & " joins the chat"));
                Send_To_All(Active_Clients, P_Buffer,Nickname);
                LLU.Reset(P_Buffer.all);

                exception
                --SI HAY MAXIMO DE CLIENTES:
                when Active_Map.Full_Map =>

                --AÑADIR A LISTA DE ANTIGUOS CLIENTES
                  Values_Inactive_Map.Last_Connection:= Ada.Calendar.Clock;
                  --Buscar NICK QUE LLEVE MAS TIEMPO SIN ESCRIBIR
                  Buscar_Inativo(Active_Clients, Old_Nick);
                  Inactive_Map.Put(Inactive_Clients, Old_Nick,Values_Inactive_Map);
                  --ENVIAR MENSAJE DE BANNED
                  LLU.Reset (P_Buffer.all);

                  CM.Message_Type'Output(P_Buffer,CM.Server);
                  ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String("server"));
                  ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String(ASU.To_String(Old_Nick) & " banned for being idle too long"));
                  Send_To_All(Active_Clients, P_Buffer,Nickname);
                  LLU.Send(Client_EP_Receive,P_Buffer); --ENVIARSELO Tambien al que entra
                  LLU.Reset(P_Buffer.all);

                  --BORRAR EL MÄS ANTIGUO DE LOS ACTIVOS --> SIEMPRE VA A SER EL PRIMERO DE LA LISTA
                  Active_Map.Delete(Active_Clients, Old_Nick,Encontrado);

                  Active_Map.Put(Active_Clients, Nickname,Values_Active_Map);
                --AÑADIR NUEVO y ENVIAR A LOS DEMAS
                  Active_Map.Put(Active_Clients, Nickname,Values_Active_Map);
                  LLU.Reset (P_Buffer.all);

                  CM.Message_Type'Output(P_Buffer,CM.Server);
                  ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String("server"));
                  ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String(ASU.To_String(Nickname) & " joins the chat"));
                  Send_To_All(Active_Clients, P_Buffer,Nickname);
                  LLU.Reset(P_Buffer.all);
              end;


             else

               LLU.Reset (P_Buffer.all);
               CM.Message_Type'Output(P_Buffer, CM.Welcome);
               Boolean'Output(P_Buffer,Acogido);
               LLU.Send(Client_EP_Receive,P_Buffer); --ENVIARSELO
               LLU.Reset (P_Buffer.all);

           end if;

        elsif Mess = CM.Writer then


              Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
              Nickname:= ASU.Unbounded_String'Input (P_Buffer);
              Comentario := ASU.Unbounded_String'Input (P_Buffer);

              ---Comprobar NICK Y EP----
              Values_Active_Map.EP:= Client_EP_Handler;
              Values_Active_Map.Last_Connection:= Ada.Calendar.Clock;
              Active_Map.Get(Active_Clients, Nickname, Values_Active_Map, Encontrado);

              if Encontrado then
                Values_Active_Map.Last_Connection:= Ada.Calendar.Clock;
              -- si está:
              --Actualizar Última conexión
              Active_Map.Put(Active_Clients, Nickname,Values_Active_Map);
              Ada.Text_IO.Put_Line ("WRITER received from "& ASU.To_String(Nickname) & ": " & ASU.To_String(Comentario) );

              LLU.Reset (P_Buffer.all);

              CM.Message_Type'Output(P_Buffer, CM.Server);
              ASU.Unbounded_String'Output(P_Buffer,Nickname);
              ASU.Unbounded_String'Output(P_Buffer, Comentario);
              Send_To_All(Active_Clients,P_Buffer,Nickname);
              LLU.Reset (P_Buffer.all);
            else
              Ada.Text_IO.Put_Line("unknown client. IGNORED");

          end if;


        elsif Mess = CM.Logout then
          Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
          Nickname := ASU.Unbounded_String'Input(P_Buffer);
          ----COMPROBAR NICK Y EP-------------
          Values_Inactive_Map.EP:= Client_EP_Handler;
          Values_Inactive_Map.Last_Connection:= Ada.Calendar.Clock;
          Active_Map.Get(Active_Clients, Nickname, Values_Active_Map, Encontrado);
          if Encontrado then

          --- si está:

          Ada.Text_IO.Put_Line("LOGOUT received from " & ASU.To_String(Nickname));

          ---Borrarlo de clientes activos
          Active_Map.Delete(Active_Clients, Nickname,Encontrado);

          --- Añadir a clientes viejos
          Inactive_Map.Put(Inactive_Clients, Nickname,Values_Inactive_Map);


          LLU.Reset(P_Buffer.all);
          CM.Message_Type'Output(P_Buffer,CM.Server);
          ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String("server"));
          ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String(ASU.To_String(Nickname) & " leaves the chat"));
          Send_To_All(Active_Clients,P_Buffer,Nickname);
          LLU.Reset(P_Buffer.all);
        else
          Ada.Text_IO.Put_Line("unknown client. IGNORED");
        end if;

     end if;

end Server_Handler;

end Handler_Server;
