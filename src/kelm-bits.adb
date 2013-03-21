package body kelm.bits is

    function word_to_hex (data : word_t; len : integer) return string is
        package hex_io is new ada.text_io.integer_io(long_long_integer);
        val : integer := 0;
        mid : string (1..12);
        temp : string(1..(len * 9)) := (others => '0');
    begin
        -- Copy every word
        for i in positive range 1..len loop
            hex_io.put(to => mid,
                       item => long_long_integer(data(i)),
                       base => 16);
            
            -- Find where the string content starts
            val := 1;
            while ((mid(val) = ' ') and (val <= 12)) loop
                val := val + 1;
            end loop;
            
            -- Use the last entry as a delimeter
            mid(12) := ' ';
            temp(((i - 1) * 9) + val..(i * 9)) := mid(val + 3..12);
        end loop;
        return temp;
    end word_to_hex;

end kelm.bits;