
package body Handler_Client is

procedure Client_Handler (From : in LLU.End_Point_Type;
                          To : in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type) is

    Mess : CM.Message_Type;
    Reply: ASU.Unbounded_String;
    Nick: ASU.Unbounded_String;

begin
  --Mensajes que le llegan del server
  Ada.Text_IO.Put_Line("");
  Mess := CM.Message_Type'Input(P_Buffer);
  Nick := ASU.Unbounded_String'Input(P_Buffer);
  Reply:= ASU.Unbounded_String'Input(P_Buffer);
  Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Reply));
  Ada.Text_IO.Put(">>");
  LLU.Reset(P_Buffer.all);

  end Client_Handler;

end Handler_Client;
