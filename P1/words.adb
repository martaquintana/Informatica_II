--Marta Quintana Portales ISAM  Práctica 1 INFORMÁTICA 2

--Este programa lee un fichero y cuenta el número de veces que sale cada palabra
--e imprime la palabra más frecuente:  ./words <fichero>
--Tambien hay una opcion de menú:  ./words -i <fichero>
--y puedes elegir que Añada(1), Elimine(2), Busque(3) una palabra o
--que las Imprima(4) todas, al Salir(5) te dice la más frecuente.

with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Word_Lists;
with Ada.Strings.Maps;
with Ada.Characters.Handling;

procedure Words is

package ACL renames Ada.Command_Line;
package ASU renames Ada.Strings.Unbounded;

   procedure Leer_Palabras (List: in out Word_Lists.Word_List_Type;
                            File_Name: in ASU.Unbounded_String) is
      Usage_Error: exception;
      File: Ada.Text_IO.File_Type;
      Finish: Boolean;
      Line: ASU.Unbounded_String;
      Word_Size :Natural :=0;
      Word: ASU.Unbounded_String;
      Final_Linea: Boolean;

   begin
      if ACL.Argument_Count /= 1 and ACL.Argument_Count /= 2 then
         raise Usage_Error;
      end if;

      Ada.Text_IO.Open(File, Ada.Text_IO.In_File, ASU.To_String(File_Name));
      Finish := False;
      Final_Linea := False;

      while not Finish loop
         begin
            Final_Linea:=False;
            Line := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(File));

            while not Final_Linea loop
               Word_Size := ASU.Index (Line, Ada.Strings.Maps.To_Set(" ,.-")); -- Extension 1
               --Para los que solo tengan una palabra
               if Word_Size = 0 and ASU.To_String(Line) /= "" then
                  Word:= Line;
                  --Extension 2 las palabras las guarda en minuscula
                  Word:= ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Word)));
                  --GUARDA EN LA LISTA
                  Word_Lists.Add_Word( List, Word );
                  Line := ASU.Tail (Line, ASU.Length(Line)-ASU.Length(Line));
                  Final_Linea:=True;
               --Vacio
               elsif Word_Size = 0 then
                  Final_Linea:=True;
                  --Para que no guarde los espacios
               elsif Word_Size = 1 then
                  Line := ASU.Tail (Line, ASU.Length(Line)-Word_Size);
               else
                  Word := ASU.Head (Line, Word_Size-1);
                  Word:= ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Word)));
                  --GUARDA EN LA LISTA
                  Word_Lists.Add_Word( List, Word );
                  Line := ASU.Tail (Line, ASU.Length(Line)-Word_Size);
                  --Elimina palabra guardada y asi sigue leyendo
               end if;
            end loop;

         exception
  	        when Ada.IO_Exceptions.End_Error =>
  	           Finish := True;
         end;
      end loop;

      Ada.Text_IO.Close(File);

   end Leer_Palabras;


   procedure Menu (List: in out Word_Lists.Word_List_Type;
                   Option: out Natural)is
      Count:Natural;
      Word: ASU.Unbounded_String;

   begin
      Ada.Text_IO.New_Line(1);
      Ada.Text_IO.Put_Line("Options");
      Ada.Text_IO.Put_Line("1 Add word");
      Ada.Text_IO.Put_Line("2 Delete word");
      Ada.Text_IO.Put_Line("3 Search word");
      Ada.Text_IO.Put_Line("4 Show all words");
      Ada.Text_IO.Put_Line("5 Quit");
      Ada.Text_IO.New_Line(1);
      Ada.Text_IO.Put("Your option? ");
      Option := Natural'Value(Ada.Text_IO.Get_Line);


      if Option = 4 then
         Ada.Text_IO.New_Line(1);
         Word_Lists.Print_All( List );

      elsif Option = 3 then
         Ada.Text_IO.Put("Word? ");
         Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
         Word_Lists.Search_Word( List,Word,Count );
         Ada.Text_IO.New_Line(1);
         Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) &"| -" & Natural'Image(Count));


      elsif Option = 2 then

         Ada.Text_IO.Put("Word? ");
         Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
         Word_Lists.Delete_Word( List,Word);
         Ada.Text_IO.New_Line(1);
         Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) &"| " & "deleted");


      elsif Option = 1 then

         Ada.Text_IO.Put("Word? ");
         Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
         Word_Lists.Add_Word(List,Word);
         Ada.Text_IO.Put_Line("Word |" & ASU.To_String(Word) &"| " & "added");

      elsif Option /= 5 then
        Ada.Text_IO.New_Line(1);
        Ada.Text_IO.Put_Line("Sorry, options are only 1, 2, 3, 4 or 5");

      end if ;
      exception

         when Word_Lists.Word_List_Error =>
              Ada.Text_IO.Put_Line("No words.");
        
         when Constraint_Error =>
              Ada.Text_IO.Put_Line("Sorry, options are only 1, 2, 3, 4 or 5");
   end Menu;


procedure final_programa (List: in out Word_Lists.Word_List_Type) is
  Mas_Frecuente:Natural;
  Word_MasFrecuente:ASU.Unbounded_String;
begin
  Word_Lists.Max_Word( List, Word_MasFrecuente,Mas_Frecuente);
  Ada.Text_IO.Put_Line( "The most frequent word: |"& ASU.To_String(Word_MasFrecuente) &"| -" & Natural'Image(Mas_Frecuente));
  Ada.Text_IO.New_Line(1);
  ----Extension 3 Borrar lista
   Word_Lists.Delete_List(List);

  exception

     when Word_Lists.Word_List_Error =>
          Ada.Text_IO.Put_Line("No words.");
          Ada.Text_IO.New_Line(1);

end final_programa;



--- AQUI EMPIEZA PROGRAMA WORDS---
   List:Word_Lists.Word_List_Type := null;
   File_Name: ASU.Unbounded_String;
   Usage_Error: exception;
   Option:Natural;

begin

   if ACL.Argument_Count /= 1 and ACL.Argument_Count /= 2   then

      raise Usage_Error;

   elsif ACL.Argument(1)="-i" and ACL.Argument_Count = 2 then

      File_Name := ASU.To_Unbounded_String(ACL.Argument(2));
      Leer_Palabras(List,File_Name);
      Menu(List,Option);

      while Option /= 5 loop
         Menu (List,Option);
      end loop;
      if Option = 5 then
        Ada.Text_IO.New_Line(1);
        final_programa(List);
      end if;

   else
      File_Name := ASU.To_Unbounded_String(ACL.Argument(1));
      Leer_Palabras(List,File_Name);
      final_programa(List);

   end if;

----Mensajes de Error----
   exception
      when Usage_Error =>
         Ada.Text_IO.Put_Line("usage: words [-i] <filename>");

      when Ada.IO_Exceptions.Name_Error =>

         if ACL.Argument_Count = 1 and ACL.Argument(1)/="-i"  then

            Ada.Text_IO.Put_Line(ACL.Argument(1) & ": file not found");

         elsif  ACL.Argument_Count = 2 and ACL.Argument(1)="-i" then

            Ada.Text_IO.Put_Line(ACL.Argument(2) & ": file not found");

           while Option /= 5 loop
             Menu (List,Option);
           end loop;

           if Option = 5 then
             final_programa(List);

           end if;

         else

            Ada.Text_IO.Put_Line("usage: words [-i] <filename>");

         end if;

end Words;
