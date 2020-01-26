with Maps_G;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Lower_Layer_UDP;
with Chat_Messages;
with Ada.Text_IO;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Check_Arguments;



package Handler_Server is
package LLU renames Lower_Layer_UDP;
package ASU renames Ada.Strings.Unbounded;
package CM renames Chat_Messages;
package ACL renames Ada.Command_Line;
package CA renames Check_Arguments;
use type CM.Message_Type;
use type Ada.Calendar.Time;

type Client_Information is record
    EP: LLU.End_Point_Type;
    Last_Connection: Ada.Calendar.Time;
  end record;

--MAPAS--
    MAX_Clients : Natural := CA.Checking_Natural;
    package Active_Map is new Maps_G (Key_Type => ASU.Unbounded_String,
                                      Value_Type => Client_Information,
                                      "=" => ASU."=",
                                      MAX => MAX_Clients);


    Active_Clients: Active_Map.Map;
    Values_Active_Map: Client_Information;

    --MAPAS--
   package Inactive_Map is new Maps_G (Key_Type => ASU.Unbounded_String,
                                          Value_Type => Client_Information,
                                          "=" => ASU."=",
                                          MAX => 150 );


        Inactive_Clients: Inactive_Map.Map;
        Values_Inactive_Map: Client_Information;





procedure Server_Handler (From : in LLU.End_Point_Type;
                          To : in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type) ;

procedure Print_Map_Activos;
procedure Print_Map_Antiguos;

end Handler_Server;
