with ada.direct_io;
with ada.text_io;
with ada.io_exceptions;
with ada.directories;
with kelm.bits;                  use kelm.bits;

package kelm.file is

    NAME_LENGTH : constant := 256;

    type file_t is record
        size                : integer; -- Size of the file in bytes
        unit                : integer; -- Bytes to read at a time
        place               : integer; -- Current block
        safe_unit           : integer; -- Flags for ciphers to add padding
        name                : string(1..NAME_LENGTH); -- Name of the file
    end record;
    
    -- Check to see if a file exists
    function file_exists (name : string) return boolean;

    -- Create a file tracker
    function file_open (name : string; unit : integer) return file_t;

    -- Read unit bytes from a file object, and compile them into a string
    procedure file_read (obj : in out file_t; buffer : out string);
    
    -- Return the entire contents of a file as a string
    function file_return (name : string) return string;

    -- Write unit bytes to a file object
    --procedure file_write (obj : in out file_t; buffer : in string);
    
private

    -- Make sure the file_read function doesn't overstep file size
    function file_unit_check (obj : file_t) return integer;

end kelm.file;