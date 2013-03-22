with kelm.file;                  use kelm.file;
with kelm.bits;                  use kelm.bits;

package kelm.sha_256 is

    -- Hash a file
    function hash_file (name: string) return word_t;

    -- Hash a string
    function hash_string (m : string) return word_t;

private

    type sha_256_t is record
        blocks                  : integer; -- total blocks in m; N
        place                   : integer; -- current block
        addendum                : u64; -- 64bit representation of m's length
        digest                  : word_t(1..8); -- hash digest (256 bits)
        schedule                : word_t(1..64); -- round schedule (per block)
        file                    : file_t; -- file operator
    end record;
    
    -- Hash calculation constants
    k : constant word_t(1..64) := ( 
        16#428a2f98#, 16#71374491#, 16#b5c0fbcf#, 16#e9b5dba5#,
        16#3956c25b#, 16#59f111f1#, 16#923f82a4#, 16#ab1c5ed5#,
        16#d807aa98#, 16#12835b01#, 16#243185be#, 16#550c7dc3#,
        16#72be5d74#, 16#80deb1fe#, 16#9bdc06a7#, 16#c19bf174#,
        16#e49b69c1#, 16#efbe4786#, 16#0fc19dc6#, 16#240ca1cc#,
        16#2de92c6f#, 16#4a7484aa#, 16#5cb0a9dc#, 16#76f988da#,
        16#983e5152#, 16#a831c66d#, 16#b00327c8#, 16#bf597fc7#,
        16#c6e00bf3#, 16#d5a79147#, 16#06ca6351#, 16#14292967#,
        16#27b70a85#, 16#2e1b2138#, 16#4d2c6dfc#, 16#53380d13#,
        16#650a7354#, 16#766a0abb#, 16#81c2c92e#, 16#92722c85#,
        16#a2bfe8a1#, 16#a81a664b#, 16#c24b8b70#, 16#c76c51a3#,
        16#d192e819#, 16#d6990624#, 16#f40e3585#, 16#106aa070#,
        16#19a4c116#, 16#1e376c08#, 16#2748774c#, 16#34b0bcb5#,
        16#391c0cb3#, 16#4ed8aa4a#, 16#5b9cca4f#, 16#682e6ff3#,
        16#748f82ee#, 16#78a5636f#, 16#84c87814#, 16#8cc70208#,
        16#90befffa#, 16#a4506ceb#, 16#bef9a3f7#, 16#c67178f2#
    );
    
    -- Initial values for hash calculations
    hash_ref : constant word_t(1..8) := (
        16#6a09e667#, 16#bb67ae85#, 16#3c6ef372#, 16#a54ff53a#,
        16#510e527f#, 16#9b05688c#, 16#1f83d9ab#, 16#5be0cd19#
    );
    
    -- X chooses the bits of the product
    function choose (x, y, z : u32) return u32;

    -- The bits of the product represent the majority of x, y, and z
    function majority (x, y, z : u32) return u32;

    -- Sigma functions; special for sha
    function sigma_zero (x : u32) return u32;
    function sigma_one (x : u32) return u32;

    -- Deviation functions; special for sha
    function dev_zero (x : u32) return u32;
    function dev_one (x : u32) return u32;
    
    -- Construct a schedule to calculate the digest with
    function build_schedule (block : word_t) return word_t;

    -- Update the hash values for one block
    function hash_round (let, sch : word_t) return word_t;

    -- Prepare an sha module for a string input (command line arg)
    function make_sha_256 (m : string) return sha_256_t;
    
end kelm.sha_256;