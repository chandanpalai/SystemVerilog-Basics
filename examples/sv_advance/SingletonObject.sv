
class my_obj;

   string myState;

   static my_obj myObj;

   // Making constructor local restricts
   // any call to new() outside of the
   // class
   local function new();
   endfunction

   // Creator method
   static function my_obj getObject();
      if(myObj == null)
         myObj = new();
      return myObj;
   endfunction

endclass //my_obj

// Top Module      
module singleton_pattern;

   my_obj anObject;
   my_obj firstObj, secondObj;

   initial
   begin

      // Illegal call to local constructor
      //anObject = new();
 
      firstObj  = my_obj::getObject();
      firstObj.myState = "This is Me!";
      $display("Object Status | First  Object State: %s", firstObj.myState);

      secondObj = my_obj::getObject();
      $display("Object Status | Second Object State: %s", secondObj.myState);
   end

endmodule //singleton_pattern


