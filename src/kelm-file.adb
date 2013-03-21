
package body kelm.file is

    -- Check to see if the operating system can find the file
    -- -- called: before calling file_open to make sure a file is there
    -- -- name: filename to check
    -- -- returns: true if present; false it not
    function file_exists (name : string) return boolean is
        reader : ada.text_io.file_type;
    begin
        ada.text_io.open(reader, ada.text_io.in_file, name);
        ada.text_io.close(reader);
        return true;
    exception
        when ada.text_io.name_error =>
            return false;
    end file_exists;

    -- Create a file tracker.
    -- -- called: when a cipher is invoked for file interaction
    -- -- name: filename to open
    -- -- unit: amount of bytes to read per call to file_read
    -- -- mo: 1 for ascii hex; 0 for binary
    -- -- returns: a file tracker with the requested metadata
    function file_open (name : string; unit : integer) return file_t is
        temp : file_t;
    begin
        temp.place := 1;
        temp.safe_unit := unit;
        
        -- File tracker's name field will remain null if the file doesn't exist
        temp.name(1..NAME_LENGTH) := (others => character'val(0));
        if ((name'length <= NAME_LENGTH) and (file_exists(name))) then
                temp.name(1..name'length) := name;
                temp.size := integer(ada.directories.size(name));
        end if;
        
        temp.unit := unit;
        return temp;
    end file_open;

    -- Read a block of size obj.unit from the file into the string buffer.
    -- -- called: when a cipher is invoked for file interaction (iterated)
    -- -- obj: file tracker record
    -- -- buffer: string to write to (must be at least length obj.unit)
    procedure file_read (obj : in out file_t; buffer : out string) is
        safe_unit : integer := file_unit_check(obj);
        subtype file_block is string(1..safe_unit);
        package file_io is new ada.direct_io(file_block);
        reader : file_io.file_type;
    begin
        file_io.open(reader, file_io.in_file, obj.name);
        file_io.read(reader,
                     buffer(buffer'first..safe_unit),
                     file_io.count((obj.unit * (obj.place - 1)) + 1));
        file_io.close(reader);
        obj.place := obj.place + 1;
        
        if (obj.unit /= safe_unit) then
            obj.safe_unit := safe_unit;
        end if;
        
    exception
        when ada.io_exceptions.end_error =>
                obj.unit := obj.unit;
    end file_read;

    -- Return an entire file as a string.
    -- -- called: from ciphers or hashes calling files
    -- -- name: filename to read
    -- -- return: file contents
    function file_return (name : string) return string is
        module : file_t := file_open(name, integer'last);
        buffer : string(1..module.size) := (others => character'val(0));
    begin
        file_read(module, buffer);
        return buffer;
    end file_return;
    
    ----------------------------------------------------------------------------
    -- PRIVATE SECTION ---------------------------------------------------------
    ----------------------------------------------------------------------------

    -- Limit read size to the remaining entropy if the unit size exceeds it.
    -- -- called: from file_read to ensure safe limits
    -- -- name: filename to check
    -- -- unit: unitsize to check
    -- -- returns: either unit size or the remaining entropy
    function file_unit_check (obj : file_t) return integer is
        file_size : integer := integer(ada.directories.size(obj.name));
        past_data : integer := obj.unit * (obj.place - 1);
        safe_unit : integer := obj.unit;
    begin
        if (file_size < (obj.unit * obj.place)) then
                safe_unit := file_size - past_data;
        end if;
        return safe_unit;
    end file_unit_check;

end kelm.file;