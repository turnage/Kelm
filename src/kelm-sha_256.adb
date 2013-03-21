
package body kelm.sha_256 is

    -- Generate a digest for a file's contents using sha 256
    -- -- called: outside of Kelm; assume no conditions
    -- -- name: filename to digest
    -- -- returns: digest of the file (in binary format)
    function hash_file (name: string) return word_t is
        data : word_t(1..8) := (others => 0);
    begin
        return hash_string(file_return(name));
    end hash_file;

    -- Generate a digest for a string using sha 256
    -- -- called: outside of Kelm; assume no conditions
    -- -- m: sring to digest
    -- -- return: digest of the string (in a binary format)
    function hash_string (m : string) return word_t is
        module : sha_256_t := make_sha_256 (m);
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
            module.schedule := build_schedule(block);
            module.digest := hash_round(module.digest, module.schedule);
        end loop;

        return module.digest;
    end hash_string;

    ----------------------------------------------------------------------------
    -- PRIVATE SECTION ---------------------------------------------------------
    ----------------------------------------------------------------------------
    
    -- Based on x, the bits of the product will be chosen from y and z.
    -- -- called: in hash calculation
    -- -- x: choice engine
    -- -- y: choice source
    -- -- z: choice source
    -- -- returns: product chosen from sources by the engine
    function choose (x, y, z : u32) return u32 is
    begin
        return (x and y) xor ((not x) and z);
    end choose;

    -- The bits of the product represent the majority of x, y, and z, in a two
    -- out of three style of selection.
    -- -- called: in hash calculation
    -- -- x: choice source
    -- -- y: choice source
    -- -- z: choice source
    -- -- returns: resulting octet of a two-out-three for each bit
    function majority (x, y, z : u32) return u32 is
    begin
        return (x and y) xor (x and z) xor (y and z);
    end majority;

    -- Sigma functions; special for sha.
    -- called: in hash calculation
    -- x: source
    -- returns: result of wizardry
    function sigma_zero (x : u32) return u32 is
    begin
        return rotate_right(x, 2)  xor
               rotate_right(x, 13) xor
               rotate_right(x, 22);
    end sigma_zero;

    function sigma_one (x : u32) return u32 is
    begin
        return rotate_right(x, 6)  xor
               rotate_right(x, 11) xor
               rotate_right(x, 25);
    end sigma_one;
    -- End Sigma functions.

    -- Deviation functions; special for sha.
    -- called: in schedule construction
    -- x: source
    -- returns: result of wizardry
    function dev_zero (x : u32) return u32 is
    begin
        return rotate_right(x, 7)  xor
               rotate_right(x, 18) xor
               shift_right(x, 3);
    end dev_zero;

    function dev_one (x : u32) return u32 is
    begin
        return rotate_right(x, 17)  xor
               rotate_right(x, 19)  xor
               shift_right(x, 10);
    end dev_one;
    -- End Deviation functions.
    
    -- Construct a schedule to be used for hash calculation. Schedules are
    -- unique for each block (M[i]).
    -- -- called: directly preceding hash calculation for each block
    -- -- block: block of the message to make a schedule from
    -- -- returns: a full schedule
    function build_schedule (block : word_t) return word_t is
        temp : word_t(1..64) := (others => 0);
    begin
        for t in positive range 1..16 loop
            temp(t) := block(t);
        end loop;
        
        for t in positive range 17..64 loop
            temp(t) := dev_one(temp(t - 2)) + temp(t - 7) +
                       dev_zero(temp(t - 15)) + temp(t - 16);
        end loop;

        return temp;
    end build_schedule;
    
    -- Calculate one round (complete process for one M[i]), and update the
    -- intermediate hash values for it.
    -- -- called: in algorithm hubs (file or string)
    -- -- let: letters; intermediate hash values
    -- -- sch: schedule for the current message block
    -- -- returns: resulting values of the hash calculation
    function hash_round (let : word_t; sch : word_t) return word_t is
        temp : word_t(1..8);
        t1, t2, a, b, c, d, e, f, g, h : u32 := 0;
    begin
        a := let(1);
        b := let(2);
        c := let(3);
        d := let(4);
        e := let(5);
        f := let(6);
        g := let(7);
        h := let(8);

        for t in positive range 1..64 loop
            t1 := h + sigma_one(e) + choose(e, f, g) + k(t) + sch(t);
            t2 := sigma_zero(a) + majority(a, b, c);
            h := g;
            g := f;
            f := e;
            e := d + t1;
            d := c;
            c := b;
            b := a;
            a := t1 + t2;
        end loop;
        
        temp(1) := let(1) + a;
        temp(2) := let(2) + b;
        temp(3) := let(3) + c;
        temp(4) := let(4) + d;
        temp(5) := let(5) + e;
        temp(6) := let(6) + f;
        temp(7) := let(7) + g;
        temp(8) := let(8) + h;

        return temp;
    end hash_round;

    -- Prepare an sha module for a string input (command line arg). The string
    -- has a maximum length of 1024 characters. Padding as made according to the
    -- NIST specification for sha256.
    -- -- called: in algorithm hubs prior to hash calculation
    -- -- m: stringto parse and prepare metadata for
    -- -- returns: an appropriately configured sha module
    function make_sha_256 (m : string) return sha_256_t is
        l : u64 := m'length * 8;
        k : u8 := u8((512 - ((l + 8 + 64) mod 512)) / 8);
        temp : sha_256_t;
    begin
        temp.place := 0;
        if ((((u64(k) * 8) + l + 8) mod 512) > 0) then
            temp.blocks := integer(((u64(k) * 8) + l) / 512) + 1;
        else
            temp.blocks := integer(((u64(k) * 8) + l) / 512);
        end if;
        temp.addendum := l;
        return temp;
    end make_sha_256;

end kelm.sha_256;