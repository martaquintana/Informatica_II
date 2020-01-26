with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Ada.Numerics.Discrete_Random;
with Ordered_Maps_G;


procedure Ordered_Maps_Test2 is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;

   type Client_Information is record
       IP: ASU.Unbounded_String;
       Numero: Natural;
     end record;

   package Maps is new Ordered_Maps_G ( Key_Type => ASU.Unbounded_String,
                                        Value_Type => Client_Information,
                                        "=" => ASU."=",
                                        "<" => ASU."<",
                                        Max        => 3);


   procedure Print_Map (M : Maps.Map) is
      C: Maps.Cursor := Maps.First(M);
   begin
      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");

      while Maps.Has_Element(C) loop
         Ada.Text_IO.Put_Line (ASU.To_String(Maps.Element(C).Key) & " " &
                               ASU.To_String(Maps.Element(C).Value.IP) &
                               Natural'Image(Maps.Element(C).Value.Numero));
         Maps.Next(C);
      end loop;
   end Print_Map;




   procedure Do_Put (M: in out Maps.Map; K: ASU.Unbounded_String; V1: ASU.Unbounded_String; V2: Natural) is
    V: Client_Information;
   begin
      V.IP:=V1;
      V.Numero:=V2;
      Ada.Text_IO.New_Line;
      ATIO.Put_Line("Putting " & ASU.To_String(K));
      Maps.Put (M, K, V);
      Print_Map(M);

   exception
      when Maps.Full_Map =>
         Ada.Text_IO.Put_Line("Full_Map");
   end Do_Put;


   procedure Do_Get (M: in out Maps.Map; K: ASU.Unbounded_String) is
      V: Client_Information;
      C: Maps.Cursor := Maps.First(M);
      Success: Boolean;
   begin
      Ada.Text_IO.New_Line;
      ATIO.Put_Line("Getting " & ASU.To_String(K));
      Maps.Get (M, K, V, Success);
      if Success then
         Ada.Text_IO.Put_Line("Value IP: " & ASU.To_String(Maps.Element(C).Value.IP) & "  Value Numero: " &
                               Natural'Image(Maps.Element(C).Value.Numero));
         Print_Map(M);
      else
         Ada.Text_IO.Put_Line("Element not found!");
      end if;
   end Do_Get;


   procedure Do_Delete (M: in out Maps.Map; K: ASU.Unbounded_String) is
      Success: Boolean;
   begin
      Ada.Text_IO.New_Line;
      ATIO.Put_Line("Deleting " & ASU.To_String(K));
      Maps.Delete (M, K, Success);
      if Success then
         Print_Map(M);
      else
         Ada.Text_IO.Put_Line("Element not found!");
      end if;
   end Do_Delete;



   A_Map : Maps.Map;

begin

   Do_Put (A_Map, ASU.To_Unbounded_String("urjc"), ASU.To_Unbounded_String("12.12.12.12"), 12 );
   Do_Put (A_Map,  ASU.To_Unbounded_String("instagram"), ASU.To_Unbounded_String("11.11.11.11"), 11 );
   Do_Put (A_Map,  ASU.To_Unbounded_String("amazon"), ASU.To_Unbounded_String("10.10.10.10"), 10 );
   
   Do_Get(A_Map, ASU.To_Unbounded_String("facebook"));--Not found
   Do_Get(A_Map, ASU.To_Unbounded_String("urjc"));

   Do_Delete(A_Map, ASU.To_Unbounded_String("urjc"));
   Do_Delete(A_Map, ASU.To_Unbounded_String("facebook")); --Not found
   Do_Put (A_Map,  ASU.To_Unbounded_String("hey"), ASU.To_Unbounded_String("13.13.13.13"), 13 );

   Do_Delete(A_Map, ASU.To_Unbounded_String("instagram"));
   Do_Delete(A_Map, ASU.To_Unbounded_String("amazon"));
   Do_Delete(A_Map, ASU.To_Unbounded_String("hey"));

   Do_Get(A_Map, ASU.To_Unbounded_String("amazon"));--Not found

   Do_Put (A_Map,  ASU.To_Unbounded_String("new"), ASU.To_Unbounded_String("1.1.1.1"), 1 );
   Do_Put (A_Map,  ASU.To_Unbounded_String("ada"), ASU.To_Unbounded_String("2.2.2.2"), 2 );
   Do_Put (A_Map,  ASU.To_Unbounded_String("python"), ASU.To_Unbounded_String("3.3.3.3"), 3 );
   Do_Put (A_Map,  ASU.To_Unbounded_String("java"), ASU.To_Unbounded_String("4.4.4.4"), 4 );
   
end Ordered_Maps_Test2;
