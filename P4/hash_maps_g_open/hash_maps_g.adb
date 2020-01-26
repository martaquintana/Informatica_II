
package body Hash_Maps_G is

   procedure Get (M      : in out Map;
                  Key    : in Key_Type;
                  Value  : out Value_Type;
                  Success: out Boolean) is

      Pos: Hash_Range := Hash(Key);
    begin
       Success := False;
       while not Success and M.P_Array(Pos).Cell_State /= Empty loop
          if M.P_Array(Pos).Cell_State = Full and then M.P_Array(Pos).Key = Key then
             Value := M.P_Array(Pos).Value;
			       Success := True;
          else
             Pos := Pos + 1;
          end if;
       end loop;
   end Get;


   procedure Put (M    : in out Map;
                  Key  : in Key_Type;
                  Value: in Value_Type) is

      Pos: Hash_Range := Hash(Key);
	    D_Pos: Hash_Range;
	    Found: Boolean := False;
	    D_Mark : Boolean := False;
      Valor: Value_Type;
	    Success: Boolean := False;

    begin
       Valor:= Value;
       Get(M, Key, Valor, Found);
       while not Success and Pos < Hash_Range'Last loop
          if M.P_Array(Pos).Key = Key then
             M.P_Array(Pos).Value := Value;
        		 Success:= True;
          else
             Pos := Pos + 1;
          end if;
       end loop;

       Pos:= Hash(Key);
       while not Found loop
		      if M.P_Array(Pos).Cell_State = Full and then M.P_Array(Pos).Key = Key then
             M.P_Array(Pos).Value := Value;
			       Found:= True;

          else
	           if M.Length = Max then
                raise Full_Map;
	           end if;

	           if M.P_Array(Pos).Cell_State = Empty and not D_Mark then
                 M.P_Array(Pos).Key:= Key;
                 M.P_Array(Pos).Value:= Value;
                 M.P_Array(Pos).Cell_State:= Full;
                 M.Length := M.Length + 1;
                 Found    := True;
             else
                if M.P_Array(Pos).Cell_State = Deleted_Mark and not D_Mark then
                        D_Pos  := Pos;
                        D_Mark := True;

                elsif M.P_Array(Pos).Cell_State = Empty and D_Mark then
                        M.P_Array(D_Pos).Key:= Key;
                        M.P_Array(D_Pos).Value:= Value;
                        M.P_Array(D_Pos).Cell_State:= Full;
                        M.Length := M.Length + 1;
                        Found    := True;

                end if;
                Pos := Pos + 1;
             end if;
          end if;
       end loop;

   end Put;


   procedure Delete (M      : in out Map;
                     Key    : in Key_Type;
                     Success: out Boolean) is
    Pos: Hash_Range := Hash(Key);

    begin
        Success := False;
        while not Success and M.P_Array(Pos).Cell_State /= Empty loop
            if M.P_Array(Pos).Key = Key then
                Success               := True;
                M.Length              := M.Length - 1;
                M.P_Array(Pos).Cell_State := Deleted_Mark;

            else
                Pos := Pos + 1;
            end if;
        end loop;

    end Delete;


   function Map_Length (M: in Map) return Natural is
     begin
         return M.Length;
   end Map_Length;


   function First (M: in Map) return Cursor is
      C : Cursor;
      fin: Boolean:= False;
     begin
        C.M:= M;
        C.Element_A := Hash_Range'First;
        while C.Element_A < Hash_Range'Last and C.M.P_Array(C.Element_A).Cell_State /= Full loop

             C.Element_A := C.Element_A + 1;
         end loop;
         return C;

   end First;

   procedure Next (C: in out Cursor) is

    begin
      C.Element_A :=  C.Element_A + 1;
      while C.Element_A /= Hash_Range'Last and C.M.P_Array(C.Element_A).Cell_State /= Full loop

           C.Element_A := C.Element_A + 1;
      end loop;

   end Next;

   function Has_Element (C: in Cursor) return Boolean is

    begin
        return (C.Element_A /= Hash_Range'Last and C.M.P_Array(C.Element_A).Cell_State = Full);

   end Has_Element;

   function Element (C: in Cursor) return Element_Type is
    begin
        if not Has_Element(C) then

            raise No_Element;

        else
          
        return (Key   => C.M.P_Array(C.Element_A).Key,
                Value => C.M.P_Array(C.Element_A).Value);
        end if;

    end Element;
end Hash_Maps_G;
