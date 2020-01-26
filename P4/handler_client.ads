with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Lower_Layer_UDP;
with Chat_Messages;

package Handler_Client is
package LLU renames Lower_Layer_UDP;
package ASU renames Ada.Strings.Unbounded;
package CM renames Chat_Messages;
use type CM.Message_Type;

procedure Client_Handler (From : in LLU.End_Point_Type;
                          To : in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type);

end Handler_Client;
