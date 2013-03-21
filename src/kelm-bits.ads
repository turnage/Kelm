with interfaces;	use interfaces;
with ada.text_io;

package kelm.bits is

    -- Unsigned integer proxies
    type u8  is new Unsigned_8;
    type u16 is new Unsigned_16;
    type u32 is new Unsigned_32;
    type u64 is new Unsigned_64;
    
    -- Composite containers
    type word_t is array(positive range <>) of u32;
    
    -- Constants to preventing constraint errors in typecasting
    -- Also can be used for complements with (x xor trim_uxx)
    trim_u8  : constant := 16#ff#;
    trim_u16 : constant := 16#ffff#;
    trim_u32 : constant := 16#ffffffff#;
    trim_u64 : constant := 16#ffffffffffffffff#;
    
    -- Useful bit constants (big endian)
    MSB : constant := 2#10000000#;	-- most significant bit
    LSB : constant := 2#00000001#;	-- least significant bit
    
    -- Convert binary data to a hex string for display
    function word_to_hex (data : word_t; len : integer) return string;
    
end kelm.bits;