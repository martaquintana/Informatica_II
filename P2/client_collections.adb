with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Exceptions;



package body Client_Collections is


   procedure Free is new
      Ada.Unchecked_Deallocation(Cell,Cell_A);


   procedure Add_Client (Collection: in out Collection_Type;
                         EP: in LLU.End_Point_Type;
                         Nick: in ASU.Unbounded_String;
                         Unique: in Boolean) is

      P_Aux: Cell_A := null;
      es_nuevo_cliente: Boolean := True;

   begin

      P_Aux:= Collection.P_First;

      if Collection.Total = 0 then
         P_Aux:= new Cell'(EP,Nick,Collection.P_First);
         Collection.P_First:=P_Aux;
         Collection.Total := Collection.Total + 1;
      else
         P_Aux:= Collection.P_First;

         while P_Aux /= null and es_nuevo_cliente loop
            if ASU.To_String(Nick) = ASU.To_String(P_Aux.Nick) and  Unique then
               --Escritores
               es_nuevo_cliente :=False;
               raise Client_Collection_Error;

            elsif ASU.To_String(Nick) = ASU.To_String(P_Aux.Nick) and not Unique then
               --Lectores
               es_nuevo_cliente :=True;

            end if;
               P_Aux:= P_Aux.Next;

         end loop;
            if es_nuevo_cliente then
               P_Aux:= new Cell'(EP,Nick,Collection.P_First);
               Collection.P_First:=P_Aux;
               Collection.Total := Collection.Total + 1;
            end if;

      end if;
            --Ada.Text_IO.Put_Line(Natural'Image(Collection.Total));

   end Add_Client;


   procedure Delete_Client (Collection: in out Collection_Type;
                            Nick: in ASU.Unbounded_String) is

      P_Aux: Cell_A :=null;
      aux: Cell_A :=null;
      esta_en_lista: Boolean := False;

   begin

      P_Aux:= Collection.P_First;
      if not esta_en_lista and P_Aux = null then
         raise Client_Collection_Error;

      elsif ASU.To_String(Nick) = ASU.To_String(P_Aux.Nick) then --SI ES LA PRIMERA DE LA LISTA
         Collection.P_First:= P_Aux.Next;
         Free(P_Aux);
         Collection.Total := Collection.Total - 1;
         esta_en_lista:=True;

      else
         P_Aux:=Collection.P_First;
         while P_Aux /= null and not esta_en_lista loop
            aux:=P_Aux;
            P_Aux:= P_Aux.Next;
            if not esta_en_lista and P_Aux = null then
               raise Client_Collection_Error;
            end if;

            if ASU.To_String(Nick) = ASU.To_String(P_Aux.Nick) then
               aux.Next:=P_Aux.Next;
               Free(P_Aux);
               Collection.Total := Collection.Total - 1;
               esta_en_lista:=True;
            end if ;
         end loop;
      end if ;

   end Delete_Client;


   function Search_Client (Collection: in Collection_Type;
                           EP: in LLU.End_Point_Type)
                           return ASU.Unbounded_String is

      P_Aux: Cell_A :=null;
      esta_en_lista: Boolean := False;
      Nick :ASU.Unbounded_String ;
      use type LLU.End_Point_Type;

   begin

      if Collection.Total /= 0 then
         P_Aux:= Collection.P_First;
         while P_Aux /= null and not esta_en_lista loop
            if EP = P_Aux.all.Client_EP then
               Nick:= P_Aux.Nick;
               esta_en_lista:=True;
            end if;
               P_Aux := P_Aux.Next;
         end loop;
      end if;

      if not esta_en_lista then
         raise Client_Collection_Error;
      else
         return Nick;
      end if;
   end Search_Client;


   procedure Send_To_All (Collection: in Collection_Type;
                          P_Buffer: access LLU.Buffer_Type) is

      P_Aux:Cell_A;

   begin

      P_Aux:=Collection.P_First;
      while P_Aux /= null loop
         LLU.Send(P_Aux.Client_EP,P_Buffer);
         P_Aux := P_Aux.Next;
      end loop;
   end  Send_To_All;


   function Collection_Image (Collection: in Collection_Type)
                               return String is
      P_Aux:Cell_A;
      Port:ASU.Unbounded_String;
      IP:ASU.Unbounded_String;
      LLU_Image: ASU.Unbounded_String;
      espacio:Integer;
      coma:Integer;
      fin:Boolean := False;
      All_Collection : ASU.Unbounded_String := ASU.To_Unbounded_String("");

      begin

         P_Aux := Collection.P_First;
         while P_Aux /= null loop
            LLU_Image:=ASU.To_Unbounded_String(LLU.Image(P_Aux.Client_EP));
            --Sacar el Puerto
            for k in 1..5  loop
               espacio := ASU.Index(LLU_Image," ");
               LLU_Image:= ASU.Tail(LLU_Image, ASU.Length(LLU_Image) - espacio);
               Port:=LLU_Image;
            end loop;

            --Sacar la IP
            LLU_Image:=ASU.To_Unbounded_String(LLU.Image(P_Aux.Client_EP));

            for k in 1..2  loop
               espacio := ASU.Index(LLU_Image," ");
               LLU_Image:= ASU.Tail(LLU_Image, ASU.Length(LLU_Image) - espacio);
            end loop;
            coma := ASU.Index(LLU_Image,",");
            LLU_Image:= ASU.Head(LLU_Image, coma -1);
            IP:=LLU_Image;

            All_Collection :=ASU.To_Unbounded_String( ASU.To_String(All_Collection) &
                             ASCII.LF & ASU.To_String(IP) & ":" & ASU.To_String(Port) & " " &
                             ASU.To_String(P_Aux.Nick));

            P_Aux:= P_Aux.Next;
         end loop;

         return ASU.To_String(All_Collection);

   end Collection_Image;


end Client_Collections;
