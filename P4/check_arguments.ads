with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;

package Check_Arguments is

   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;

   Check_Arguments_Error: exception;

   function Checking_Natural return Natural;
   function Checking_Integer return Integer;

end Check_Arguments;
