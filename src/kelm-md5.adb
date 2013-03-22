package body kelm.md5 is

    -- Generate a digest for a file's contents using md5
    -- -- called: outside of Kelm; assume no conditions
    -- -- name: filename to digest
    -- -- returns: digest of the file (in binary format)
    function hash_file (name: string) return word_t is
        data : word_t(1..8) := (others => 0);
    begin
        return hash_string(file_return(name));
    end hash_file;

    -- Generate a digest for a string using md5
    -- -- called: outside of Kelm; assume no conditions
    -- -- m: sring to digest
    -- -- return: digest of the string (in a binary format)
    function hash_string (m : string) return word_t is
        module : md5_t := make_md5(m);
        data : word_t(1..(16 * module.blocks)) := (others => 0);
        shift : array (1..4) of integer := (24, 16, 8, 0);
        block : word_t(1..16);
        mid : string(1..m'length + 1);
    begin
        -- Append the one bit
        mid(1..m'length) := m;
        mid(m'length + 1) := character'val(MSB);

        -- Interpret the string as binary data
        for i in positive range 1..mid'length loop
            data(((i - 1) / 4) + 1) := data(((i - 1) / 4) + 1) xor
                               shift_left(u32(character'pos(mid(i))),
                               shift(((i - 1) mod 4) + 1));
        end loop;
        
        -- Append 64bit addendum
        data(data'last- 1) := u32(shift_right(module.addendum, 32));
        data(data'last) := u32(module.addendum and trim_u32);

        -- Prepare hash values
        module.digest := hash_ref;

        -- Calculate hash
        for i in positive range 1..module.blocks loop
            block := data(((i - 1) * 16) + 1..(i * 16));
            module.digest := hash_round(module.digest, block);
        end loop;

        return module.digest;
    end hash_string;
    
    ----------------------------------------------------------------------------
    -- PRIVATE SECTION ---------------------------------------------------------
    ----------------------------------------------------------------------------

    -- Primitive functions special for md5
    -- -- called: during round functions
    -- -- x: eye of newt
    -- -- y: tale of lizard
    -- -- z: juice of kraken
    -- -- returns: result of ancient witchcraft
    function f (x, y, z : u32) return u32 is
    begin
        return ((x and y) or ((not x) and z));
    end f;

    function g (x, y, z : u32) return u32 is
    begin
        return ((x and z) or (y and (not z)));
    end g;

    function h (x, y, z : u32) return u32 is
    begin
        return (x xor y xor z);
    end h;

    function i (x, y, z : u32) return u32 is
    begin
        return (y xor (x or (not z)));
    end i;
    -- End primitive functions special to md5

    -- Round operations special for md5
    -- -- called: from algorithm hub
    -- -- a, b, c, d: hash intermediate values
    -- -- k: element from message block
    -- -- s: amount to circularly shift
    -- -- i: constant from the sine table
    function round_one (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + f(b, c, d) + k + co, integer(s)) + b;
    end round_one;

    function round_two (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + g(b, c, d) + k + co, integer(s)) + b;
    end round_two;

    function round_three (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + h(b, c, d) + k + co, integer(s)) + b;
    end round_three;

    function round_four (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + i(b, c, d) + k + co, integer(s)) + b;
    end round_four;
    -- End round operations special for md5

    -- Calculate one round (complete process for one M[i]), and update the
    -- intermediate hash values for it.
    -- -- called: in algorithm hub
    -- -- let: letters; intermediate hash values
    -- -- sch: current message block (16 words)
    -- -- returns: resulting values of the hash calculation
    function hash_round (let, sch : word_t) return word_t is
        temp : word_t := let;
        aa, bb, cc, dd : u32 := 0;
    begin
        aa := let(1);
        bb := let(2);
        cc := let(3);
        dd := let(4);
        
        -- Round one
        aa := round_one(aa, bb, cc, dd, sch(1),  S(1, 1), t(1));
        dd := round_one(dd, aa, bb, cc, sch(2),  S(1, 2), t(2));
        cc := round_one(cc, dd, aa, bb, sch(3),  S(1, 3), t(3));
        bb := round_one(bb, cc, dd, aa, sch(4),  S(1, 4), t(4));
        
        aa := round_one(aa, bb, cc, dd, sch(5),  S(1, 1), t(5));
        dd := round_one(dd, aa, bb, cc, sch(6),  S(1, 2), t(6));
        cc := round_one(cc, dd, aa, bb, sch(7),  S(1, 3), t(7));
        bb := round_one(bb, cc, dd, aa, sch(8),  S(1, 4), t(8));
        
        aa := round_one(aa, bb, cc, dd, sch(9),  S(1, 1), t(9));
        dd := round_one(dd, aa, bb, cc, sch(10), S(1, 2), t(10));
        cc := round_one(cc, dd, aa, bb, sch(11), S(1, 3), t(11));
        bb := round_one(bb, cc, dd, aa, sch(12), S(1, 4), t(12));
        
        aa := round_one(aa, bb, cc, dd, sch(13), S(1, 1), t(13));
        dd := round_one(dd, aa, bb, cc, sch(14), S(1, 2), t(14));
        cc := round_one(cc, dd, aa, bb, sch(15), S(1, 3), t(15));
        bb := round_one(bb, cc, dd, aa, sch(16), S(1, 4), t(16));
        
        -- Round Two
        aa := round_one(aa, bb, cc, dd, sch(2),  S(2, 1), t(17));
        dd := round_one(dd, aa, bb, cc, sch(7),  S(2, 2), t(18));
        cc := round_one(cc, dd, aa, bb, sch(12), S(2, 3), t(19));
        bb := round_one(bb, cc, dd, aa, sch(1),  S(2, 4), t(20));
        
        aa := round_one(aa, bb, cc, dd, sch(6),  S(2, 1), t(21));
        dd := round_one(dd, aa, bb, cc, sch(11), S(2, 2), t(22));
        cc := round_one(cc, dd, aa, bb, sch(16), S(2, 3), t(23));
        bb := round_one(bb, cc, dd, aa, sch(5),  S(2, 4), t(24));
        
        aa := round_one(aa, bb, cc, dd, sch(10), S(2, 1), t(25));
        dd := round_one(dd, aa, bb, cc, sch(15), S(2, 2), t(26));
        cc := round_one(cc, dd, aa, bb, sch(4),  S(2, 3), t(27));
        bb := round_one(bb, cc, dd, aa, sch(9),  S(2, 4), t(28));
        
        aa := round_one(aa, bb, cc, dd, sch(14), S(2, 1), t(29));
        dd := round_one(dd, aa, bb, cc, sch(3),  S(2, 2), t(30));
        cc := round_one(cc, dd, aa, bb, sch(8),  S(2, 3), t(31));
        bb := round_one(bb, cc, dd, aa, sch(13), S(2, 4), t(32));
        
        -- Round Three
        aa := round_one(aa, bb, cc, dd, sch(6),  S(3, 1), t(33));
        dd := round_one(dd, aa, bb, cc, sch(9),  S(3, 2), t(34));
        cc := round_one(cc, dd, aa, bb, sch(12), S(3, 3), t(35));
        bb := round_one(bb, cc, dd, aa, sch(15), S(3, 4), t(36));
        
        aa := round_one(aa, bb, cc, dd, sch(2),  S(3, 1), t(37));
        dd := round_one(dd, aa, bb, cc, sch(5),  S(3, 2), t(38));
        cc := round_one(cc, dd, aa, bb, sch(8),  S(3, 3), t(39));
        bb := round_one(bb, cc, dd, aa, sch(11), S(3, 4), t(40));
        
        aa := round_one(aa, bb, cc, dd, sch(14), S(3, 1), t(41));
        dd := round_one(dd, aa, bb, cc, sch(1),  S(3, 2), t(42));
        cc := round_one(cc, dd, aa, bb, sch(4),  S(3, 3), t(43));
        bb := round_one(bb, cc, dd, aa, sch(7),  S(3, 4), t(44));
        
        aa := round_one(aa, bb, cc, dd, sch(10), S(3, 1), t(45));
        dd := round_one(dd, aa, bb, cc, sch(13), S(3, 2), t(46));
        cc := round_one(cc, dd, aa, bb, sch(16), S(3, 3), t(47));
        bb := round_one(bb, cc, dd, aa, sch(3),  S(3, 4), t(48));
        
        -- Round Four
        aa := round_one(aa, bb, cc, dd, sch(1),  S(4, 1), t(49));
        dd := round_one(dd, aa, bb, cc, sch(8),  S(4, 2), t(50));
        cc := round_one(cc, dd, aa, bb, sch(15), S(4, 3), t(51));
        bb := round_one(bb, cc, dd, aa, sch(6),  S(4, 4), t(52));
        
        aa := round_one(aa, bb, cc, dd, sch(13), S(4, 1), t(53));
        dd := round_one(dd, aa, bb, cc, sch(4),  S(4, 2), t(54));
        cc := round_one(cc, dd, aa, bb, sch(11), S(4, 3), t(55));
        bb := round_one(bb, cc, dd, aa, sch(2),  S(4, 4), t(56));
        
        aa := round_one(aa, bb, cc, dd, sch(9),  S(4, 1), t(57));
        dd := round_one(dd, aa, bb, cc, sch(16), S(4, 2), t(58));
        cc := round_one(cc, dd, aa, bb, sch(7),  S(4, 3), t(59));
        bb := round_one(bb, cc, dd, aa, sch(14), S(4, 4), t(60));
        
        aa := round_one(aa, bb, cc, dd, sch(5),  S(4, 1), t(61));
        dd := round_one(dd, aa, bb, cc, sch(12), S(4, 2), t(62));
        cc := round_one(cc, dd, aa, bb, sch(3),  S(4, 3), t(63));
        bb := round_one(bb, cc, dd, aa, sch(10), S(4, 4), t(64));

        temp(1) := temp(1) + aa;
        temp(2) := temp(2) + bb;
        temp(3) := temp(3) + cc;
        temp(4) := temp(4) + dd;

        return temp;
    end hash_round;
    
    -- Prepare an sha module for a string input (command line arg). Padding is
    -- made according to the specification for md5.
    -- -- called: in algorithm hubs prior to hash calculation
    -- -- m: stringto parse and prepare metadata for
    -- -- returns: an appropriately configured sha module
    function make_md5 (m : string) return md5_t is
        b : u64 := m'length * 8;
        k : u8 := u8((512 - ((b + 8 + 64) mod 512)) / 8);
        temp : md5_t;
    begin
        temp.place := 0;
        if ((((u64(k) * 8) + b + 8) mod 512) > 0) then
            temp.blocks := integer(((u64(k) * 8) + b) / 512) + 1;
        else
            temp.blocks := integer(((u64(k) * 8) + b) / 512);
        end if;
        temp.addendum := b;
        return temp;
    end make_md5;
    
end kelm.md5;