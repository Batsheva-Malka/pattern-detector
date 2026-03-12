// Pattern Detector Sequence Item
// Transaction object for stimulus generation
`include "uvm_macros.svh"
import uvm_pkg::*;

class pattern_detector_seq_item extends uvm_sequence_item;
    
    // Randomized inputs
    rand bit [63:0] data_stream_a;
    rand bit [63:0] data_stream_b;
    rand bit        mode_select;      // 0 = Full Adjustment, 1 = Mask-Based
    rand bit [31:0] pattern_mask;
    //because in eda you cant use a soft constraint, we went around it.
    // שינוי: הוספת משתנה בקרה שמאפשר ל-Sequence לאשר מסכת אפס בלי להשתמש ב-constraint_mode
    rand bit allow_zero_mask = 0; 
    
    // Output (captured by monitor)
    bit             pattern_match;
    
    // UVM automation macros
    `uvm_object_utils_begin(pattern_detector_seq_item)
        `uvm_field_int(data_stream_a, UVM_ALL_ON)
        `uvm_field_int(data_stream_b, UVM_ALL_ON)
        `uvm_field_int(mode_select,   UVM_ALL_ON)
        `uvm_field_int(pattern_mask,  UVM_ALL_ON)
        `uvm_field_int(pattern_match, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // Constructor
    function new(string name = "pattern_detector_seq_item");
        super.new(name);
    endfunction
    
    // Constraints for different test scenarios
    
    // שלב 1 המעודכן: שימוש ב-dist במקום soft כדי לפתור שגיאות קומפילציה ב-EDA
    constraint c_default {
        // התפלגות מודים 50/50
        mode_select dist { 0 := 50, 1 := 50 };

        // שינוי: התפלגות דאטה ממוקדת לסגירת חורי ה-Coverage של cp_pattern_types_a
        data_stream_a[31:0] dist {
            32'h00000000 := 10,
            32'hFFFFFFFF := 10,
            32'hAAAAAAAA := 10,
            32'h55555555 := 10,
            [1:32'hFFFFFFFE] := 60 // כל שאר הערכים האקראיים
        };

        // שינוי: התפלגות דאטה ממוקדת לסגירת חורי ה-Coverage של cp_pattern_types_b
        data_stream_b[31:0] dist {
            32'h00000000 := 10,
            32'hFFFFFFFF := 10,
            32'hAAAAAAAA := 10,
            32'h55555555 := 10,
            [1:32'hFFFFFFFE] := 60
        };

        // שינוי: סיכוי של 20% ליצור התאמה מושלמת כדי לסגור את ה-Cross של Match/No-Match
        data_stream_a == data_stream_b dist { 1 := 20, 0 := 80 };
    }

    // שינוי: אילוץ מסיכה תקינה שמתחשב במשתנה הבקרה allow_zero_mask
    // זה מונע את השגיאה של "Member c_mask_valid not found" כי ה-Sequence לא צריך לכבות את האילוץ
    constraint c_mask_valid {
        (mode_select == 1 && allow_zero_mask == 0) -> pattern_mask != 0;
    }
    
endclass