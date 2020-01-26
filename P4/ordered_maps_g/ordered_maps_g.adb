
package body Ordered_Maps_G is

   procedure Binary_Search (M: in Map;
                            Key: in Key_Type;
                            Index: out Natural;
                            Success:out Boolean) is
      ---[Lim_Inf, ... , Mitad, ... , Lim_Sup]
      --Busca de mitad en mitad--> Funciona para Put y Delete
      Lim_Inf: Natural := 1;
      Mitad: Natural ;
      Lim_Sup: Natural := M.Length;
     begin
	      Success := False;
        if M.Length = 0 then
           Index := 1;
           Success:= False;
        else
           while Lim_Inf <= Lim_Sup and not Success loop
              Mitad := (Lim_Inf+Lim_Sup)/2;
              if Key = M.P_Array(Mitad).Key then
                 Success:= True;
                 Index:= Mitad;
              elsif  Key < M.P_Array(Mitad).Key then
                 Lim_Sup:= Mitad - 1;
              else
                 Lim_Inf:= Mitad + 1;
              end if;
           end loop;
           if not Success and  Key < M.P_Array(Mitad).Key then
              Index := Mitad;
           else
              Index := Mitad + 1;
           end if;
        end if;
   end Binary_Search;


   procedure Get (M       :in out Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      Mitad:Natural:= M.Length/2;
    begin
       Success := False;
       if M.Length /= 0 then
	        if Mitad < 1 then
	           Mitad := 1;
	        end if;
          if Key = M.P_Array(Mitad).Key then
             Success := True;
             Value:= M.P_Array(Mitad).Value;
          end if;
          if Key < M.P_Array(Mitad).Key then
             while Mitad >= 1 loop
                if Key = M.P_Array(Mitad).Key then
                   Success := True;
                   Value:= M.P_Array(Mitad).Value;
                end if;
                Mitad:= Mitad - 1;
             end loop;
          else
             while Mitad <= M.Length  loop
                if Key = M.P_Array(Mitad).Key then
                   Success := True;
                   Value:= M.P_Array(Mitad).Value;
                end if;
                Mitad:= Mitad + 1;
             end loop;
          end if;
       end if;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is
      Found : Boolean;
      Index:Natural:=1;
    begin
       --Mirar a ver si está o el index
       Binary_Search(M,Key,Index,Found);
       if Found then
          M.P_Array(Index).Value := Value;
       end if;

       -- Si no hemos encontrado Key añadimos donde le corresponda
       if not Found  then
          if M.Length = 0 then
             M.P_Array(1).Key := Key;
             M.P_Array(1).Value := Value;
             M.P_Array(1).Full := True;
             M.Length := M.Length + 1;
          else
             if M.Length < Max then
                for I in reverse Index..M.Length loop
                    M.P_Array(I + 1).Key := M.P_Array(I).Key;
                    M.P_Array(I + 1).Value := M.P_Array(I).Value;
                    M.P_Array(I + 1).Full := True;
                end loop;
                M.P_Array(Index).Key := Key;
                M.P_Array(Index).Value := Value;
                M.P_Array(Index).Full := True;
                M.Length := M.Length + 1;
             else
                raise Full_Map;
             end if;
          end if;
       end if;

   end Put;


   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      Index:Natural:=1;
    begin
	     Success := False;
       Binary_Search(M,Key,Index,Success);
       if Success then
          --Borrar y Reordenar
          --Reordenar desde el el siguiente al que queremos borrar
          for I in (Index) .. M.Length loop
             M.P_Array(I - 1 ).Key := M.P_Array(I).Key;
             M.P_Array(I - 1 ).Value := M.P_Array(I).Value;
             M.P_Array(I - 1 ).Full := True;
          end loop;
          --Para que el ultimo sea False porque lo hemos borrado.
          M.P_Array(M.Length).Full := False;
          M.Length := M.Length-1;
       end if;

   end Delete;


   function Map_Length (M : Map) return Natural is
    begin
      return M.Length;
   end Map_Length;


   function First (M: Map) return Cursor is
       Aux_Cursor: Cursor;
       begin
           Aux_Cursor.M := M;
           Aux_Cursor.Element_A := 1;
           return Aux_Cursor;
   end First;


   procedure Next (C: in out Cursor) is
     begin
         C.Element_A :=  C.Element_A +1;

   end Next;


   function Has_Element (C: Cursor) return Boolean is
    begin
       return C.M.P_Array(C.Element_A).Full;
   end Has_Element;


   function Element (C: Cursor) return Element_Type is
    begin
       if not Has_Element(C) then
          raise No_Element;
       else
          return (C.M.P_Array(C.Element_A).Key, C.M.P_Array(C.Element_A).Value);
       end if;
   end Element;


end Ordered_Maps_G;
