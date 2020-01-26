with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Hash_Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);

   procedure Get (M       : in out Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
    begin
       P_Aux := M.P_Array(Hash(Key));
       Success := False;
       while not Success and P_Aux /= null Loop
          if P_Aux.Key = Key then
             Value := P_Aux.Value;
             Success := True;
          end if;
          P_Aux := P_Aux.Next;
       end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : in  Key_Type;
                  Value : in Value_Type) is
      P_Aux : Cell_A;
      Found : Boolean;
    begin
       -- Si ya existe Key, su Value cambia
       P_Aux := M.P_Array(Hash(Key));
       Found := False;
       while not Found and P_Aux /= null loop
          if P_Aux.Key = Key then
             P_Aux.Value := Value;
             Found := True;
          end if;
          P_Aux := P_Aux.Next;
       end loop;

       --Sino  lo encuentra lo añadimos
       if not Found  then
          if M.Length = MAX then
             raise Full_Map;
          end if;
          M.P_Array(Hash(Key)) := new Cell'(Key, Value,  M.P_Array(Hash(Key)));
          M.Length := M.Length + 1;
       end if;
   end Put;


   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
      P_Previous : Cell_A;
    begin
       Success := False;
       P_Previous := null;
       P_Current  := M.P_Array(Hash(Key));

       while not Success and P_Current /= null  loop
          if P_Current.Key = Key then
             if P_Previous /= null then
                P_Previous.Next := P_Current.Next;
             end if;
             if M.P_Array(Hash(Key)) = P_Current then
                M.P_Array(Hash(Key)) := M.P_Array(Hash(Key)).Next;
             end if;
             M.Length := M.Length - 1;
             Free (P_Current);
             Success := True;
          else
             P_Previous := P_Current;
             P_Current := P_Current.Next;
          end if;
      end loop;

   end Delete;


   function Map_Length (M : Map) return Natural is
    begin
       return M.Length;
   end Map_Length;

   function First (M: Map) return Cursor is
      C : Cursor;
      fin: Boolean:= False;
    begin
       C.M := M;
       C.Pos:= Hash_Range'First;
       while not fin and  M.P_Array(C.Pos) = null  loop
          if C.Pos = Hash_Range'Last then
             C.Pos := Hash_Range'First;
             fin:= True;
          end if;
          C.Pos:= C.Pos + 1;
       end loop;
       C.Element_A:= M.P_Array(C.Pos);
       return C;
   end First;

   procedure Next (C: in out Cursor) is
     fin: Boolean:= False;
    begin
       if C.Element_A.Next /= null then
          C.Element_A := C.Element_A.Next;
       elsif C.Pos >= Hash_Range'First then
          while not fin loop
             C.Pos := C.Pos + 1;
             C.Element_A := C.M.P_Array(C.Pos);
             if C.Element_A /= null or C.Pos = Hash_Range'Last then
             fin := True;
             end if;
          end loop;
       end if;
   end Next;

   function Has_Element (C: Cursor) return Boolean is
    begin
       if C.Element_A /= null then
          return True;
       else
          return False;
       end if;
   end Has_Element;


   function Element (C: Cursor) return Element_Type is
    begin
      if C.Element_A /= null then
         return (Key   => C.Element_A.Key,
                 Value => C.Element_A.Value);
      else
         raise No_Element;
      end if;
   end Element;


end Hash_Maps_G;
