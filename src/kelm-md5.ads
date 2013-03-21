with kelm.bits;                  use kelm.bits;
with kelm.file;                  use kelm.file;

package kelm.md5 is

private

    type mda5_t is record
        blocks                  : integer; -- total blocks in m; N
        place                   : integer; -- current block
        addendum                : u64; -- 64bit representation of m's length
        digest                  : word_t(1..8); -- hash digest (256 bits)
        file                    : file_t; -- file operator
    end record;

    -- Hash calculation constants
    t : constant word_t (1..64) := (
        16#d76aa478#, 16#e8c7b756#, 16#242070db#, 16#c1bdceee#,
        16#f57c0faf#, 16#4787c62a#, 16#a8304613#, 16#fd469501#,
        16#698098d8#, 16#8b44f7af#, 16#ffff5bb1#, 16#895cd7be#,
        16#6b901122#, 16#fd987193#, 16#a679438e#, 16#49b40821#,
        16#f61e2562#, 16#c040b340#, 16#265e5a51#, 16#e9b6c7aa#,
        16#d62f105d#, 16#02441453#, 16#d8a1e681#, 16#e7d3fbc8#,
        16#21e1cde6#, 16#c33707d6#, 16#f4d50d87#, 16#455a14ed#,
        16#a9e3e905#, 16#fcefa3f8#, 16#676f02d9#, 16#8d2a4c8a#,
        16#fffa3942#, 16#8771f681#, 16#6d9d6122#, 16#fde5380c#,
        16#a4beea44#, 16#4bdecfa9#, 16#f6bb4b60#, 16#bebfbc70#,
        16#289b7ec6#, 16#eaa127fa#, 16#d4ef3085#, 16#04881d05#,
        16#d9d4d039#, 16#e6db99e5#, 16#1fa27cf8#, 16#c4ac5665#,
        16#f4292244#, 16#432aff97#, 16#ab9423a7#, 16#fc93a039#,
        16#655b59c3#, 16#8f0ccc92#, 16#ffeff47d#, 16#85845dd1#,
        16#6fa87e4f#, 16#fe2ce6e0#, 16#a3014314#, 16#4e0811a1#,
        16#f7537e82#, 16#bd3af235#, 16#2ad7d2bb#, 16#eb86d391#
    );

    -- Initial values for hash calculation
    hash_ref : constant word_t := (
        16#01234567#, 16#89abcdef#, 16#fedcba98#, 16#76543210#
    );

    -- Bitwise operations special for md5
    function f (x, y, z : u32) return u32;
    function g (x, y, z : u32) return u32;
    function h (x, y, z : u32) return u32;
    function i (x, y, z : u32) return u32;
    -- End mda5's bitwise operations

    -- Round operations special for md5
    function round_one (a, b, c, d, k, s, co : u32) return u32;
    function round_two (a, b, c, d, k, s, co : u32) return u32;
    function round_three (a, b, c, d, k, s, co : u32) return u32;
    function round_four (a, b, c, d, k, s, co : u32) return u32;
    -- End round operations special for md5

end kelm.md5;