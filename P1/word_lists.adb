
package body Word_Lists is

   P_Aux: Word_List_Type;
   P_Aux2:Word_List_Type;

   procedure Free is new
     Ada.Unchecked_Deallocation(Cell,Word_List_Type);


   procedure Add_Word (List: in out Word_List_Type;
                       Word: in ASU.Unbounded_String) is
      es_nueva_palabra:Boolean;
   begin
      es_nueva_palabra:=True;
      P_Aux2:= List;
      while P_Aux2 /= null and es_nueva_palabra loop
        -- Extension 2
         if Ada.Characters.Handling.To_Lower(ASU.To_String(Word))
          = ASU.To_String(P_Aux2.Word) then
            es_nueva_palabra:=False;
            P_Aux2.Count := P_Aux2.Count + 1;
         end if;
         P_Aux2:= P_Aux2.Next;
      end loop;

      P_Aux:=List;
      if es_nueva_palabra then

         if List = null then
           -- Extension 2 las palabras las guarda en minuscula siempre
            List := new Cell'(ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Word))), 1,null);
            return;
         end if;

         while P_Aux.Next /= null loop
            P_Aux:=P_Aux.Next;
         end loop;
         -- Extension 2
         P_Aux.Next:= new Cell'(ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Word))), 1,null);

      end if;
   end Add_Word;


   procedure Delete_Word (List: in out Word_List_Type;
                          Word: in ASU.Unbounded_String) is
     aux:Word_List_Type:=null;
     esta_en_lista:Boolean;
   begin
      P_Aux2:= List;
      esta_en_lista:=False;
      if not esta_en_lista and P_Aux2 = null then
         raise Word_List_Error;

      elsif ASU.To_String(Word) = ASU.To_String(P_Aux2.Word) then --SI ES LA PRIMERA DE LA LISTA
         List:= P_Aux2.Next;
         Free(P_Aux2);
         esta_en_lista:=True;

      else
         while P_Aux2 /= null and not esta_en_lista loop
            aux:=P_Aux2;
            P_Aux2:= P_Aux2.Next;
            if not esta_en_lista and P_Aux2 = null then
               raise Word_List_Error;
            end if;

            if ASU.To_String(Word) = ASU.To_String(P_Aux2.Word) then
               aux.Next:=P_Aux2.Next;
               Free(P_Aux2);
               esta_en_lista:=True;

            end if ;
         end loop;
      end if ;

   end Delete_Word;


   procedure Search_Word (List: in Word_List_Type;
                          Word: in ASU.Unbounded_String;
                          Count: out Natural) is
   begin
      P_Aux2:= List;
      Count:=0;
      while P_Aux2 /= null and Count = 0 loop
        if ASU.To_String(Word) = ASU.To_String(P_Aux2.Word) then
           Count:= P_Aux2.Count;
        else
           Count:=0;
        end if;
        P_Aux2:= P_Aux2.Next;
      end loop;

   end Search_Word;


   procedure Max_Word (List: in Word_List_Type;
                       Word: out ASU.Unbounded_String;
                       Count: out Natural) is
      Mayor:Natural:=0;
   begin
      P_Aux2:= List;
      Count:=0;
      if P_Aux2 = null then
         raise Word_List_Error;
      else
         while P_Aux2 /= null  loop
            if Mayor < P_Aux2.Count then
               Mayor:= P_Aux2.Count;
               Word:=P_Aux2.Word;
               Count:=P_Aux2.Count;
            end if;
            P_Aux2:= P_Aux2.Next;
         end loop;
      end if ;
   end Max_Word;


   procedure Print_All (List: in  Word_List_Type) is

   begin
      if List /= null then
         P_Aux:= List;
         while P_Aux /= null loop
            Ada.Text_IO.Put("|"& ASU.To_String(P_Aux.Word) & "| -");
            Ada.Text_IO.Put_Line(Integer'Image(P_Aux.Count));
            P_Aux:= P_Aux.Next;
         end loop;
      else
         Ada.Text_IO.Put_Line("No words.");
      end if;
   end Print_All;

   ---Extension 3
   procedure Delete_List (List: in out Word_List_Type) is
     aux:Word_List_Type:=null;

   begin

     while List /= null loop
        aux:=List.Next;
        Free(List);
        List:=aux;
     end loop;

   end Delete_List;



end Word_Lists;
